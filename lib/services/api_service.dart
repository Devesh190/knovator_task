import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final _base = 'https://api.coingecko.com/api/v3';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> fetchCoinList() async {
    // Step 1: Fetch coin metadata
    final res = await client.get(Uri.parse('$_base/coins/list'));
    if (res.statusCode != 200) throw Exception('Failed to fetch coins list');
    final List rawList = jsonDecode(res.body) as List;

    // Convert to Map list
    final List<Map<String, dynamic>> coins =
    List<Map<String, dynamic>>.from(rawList);

    // Step 2: Fetch prices in chunks (max 250 ids at once)
    const chunkSize = 250;
    Map<String, double> priceMap = {};
    for (var i = 0; i < coins.length; i += chunkSize) {
      final chunk = coins.skip(i).take(chunkSize).toList();
      final ids = chunk.map((e) => e['id']).join(',');
      final priceRes = await client.get(
        Uri.parse('$_base/simple/price?ids=$ids&vs_currencies=usd'),
      );
      if (priceRes.statusCode == 200) {
        final Map body = jsonDecode(priceRes.body);
        body.forEach((id, val) {
          // Check if 'usd' exists and is not null
          final usdValue = val['usd'];
          if (usdValue != null) {
            // Convert to double safely
            final p = (usdValue as num).toDouble();
            priceMap[id] = p;
          } else {
            // Handle null values, e.g., set to 0 or skip
            priceMap[id] = 0.0; // or you can skip: return;
          }
        });
      }

    }



    // Step 3: Attach prices
    for (final coin in coins) {
      final id = coin['id'] as String;
      coin['currentPrice'] = priceMap[id] ?? 0.0;
      coin['oldPrice'] = 0.0; // first fetch, no old price yet
    }

    return coins;
  }


  // Simple price map: {coinId: price}
  Future<Map<String, double>> fetchPrices(List<String> ids) async {
    if (ids.isEmpty) return {};
    final idStr = ids.join(',');
    final res = await client.get(Uri.parse('$_base/simple/price?ids=$idStr&vs_currencies=usd'));
    if (res.statusCode != 200) throw Exception('Failed to fetch prices');
    final Map body = jsonDecode(res.body) as Map;
    final Map<String, double> out = {};
    body.forEach((k, v) {
      final val = v['usd'];
      out[k] = (val is num) ? val.toDouble() : double.tryParse('$val') ?? 0.0;
    });
    return out;
  }

  // Market endpoint returns price + image for logos (good for bonus)
  Future<List<Map<String, dynamic>>> fetchMarketData(List<String> ids) async {
    if (ids.isEmpty) return [];
    final idChunk = ids.join(',');
    final url = '$_base/coins/markets?vs_currency=usd&ids=$idChunk&order=market_cap_desc&per_page=250&page=1&sparkline=false';
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('Failed to fetch market data');
    final List list = jsonDecode(res.body) as List;
    return List<Map<String, dynamic>>.from(list);
  }
}
