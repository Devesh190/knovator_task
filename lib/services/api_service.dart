import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _base = 'https://api.coingecko.com/api/v3';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> fetchCoinList() async {
    try {
      final res = await client.get(Uri.parse('$_base/coins/list'));
      if (res.statusCode != 200) throw Exception('Failed to fetch coins list (Status: ${res.statusCode})');

      final List rawList = jsonDecode(res.body) as List;
      final List<Map<String, dynamic>> coins = List<Map<String, dynamic>>.from(rawList);

      const chunkSize = 250;
      Map<String, double> priceMap = {};

      for (var i = 0; i < coins.length; i += chunkSize) {
        final chunk = coins.skip(i).take(chunkSize).toList();
        final ids = chunk.map((e) => e['id']).join(',');

        try {
          final priceRes = await client.get(Uri.parse('$_base/simple/price?ids=$ids&vs_currencies=usd'));
          if (priceRes.statusCode == 200) {
            final Map body = jsonDecode(priceRes.body) as Map;
            body.forEach((id, val) {
              final usdValue = val['usd'];
              priceMap[id] = (usdValue is num) ? usdValue.toDouble() : 0.0;
            });
          } else {
            debugPrint('Warning: Failed to fetch prices for chunk ($ids), Status: ${priceRes.statusCode}');
          }
        } catch (e) {
          debugPrint('Error fetching prices for chunk ($ids): $e');
        }
      }

      for (final coin in coins) {
        final id = coin['id'] as String;
        coin['currentPrice'] = priceMap[id] ?? 0.0;
        coin['oldPrice'] = 0.0;
      }

      return coins;
    } catch (e) {
      debugPrint('Error in fetchCoinList: $e');
      return [];
    }
  }

  Future<Map<String, double>> fetchPrices(List<String> ids) async {
    if (ids.isEmpty) return {};
    try {
      final idStr = ids.join(',');
      final res = await client.get(Uri.parse('$_base/simple/price?ids=$idStr&vs_currencies=usd'));
      if (res.statusCode != 200) throw Exception('Failed to fetch prices (Status: ${res.statusCode})');

      final Map body = jsonDecode(res.body) as Map;
      final Map<String, double> out = {};
      body.forEach((k, v) {
        final val = v['usd'];
        out[k] = (val is num) ? val.toDouble() : double.tryParse('$val') ?? 0.0;
      });
      return out;
    } catch (e) {
      debugPrint('Error in fetchPrices: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchMarketData(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final idChunk = ids.join(',');
      final url = '$_base/coins/markets?vs_currency=usd&ids=$idChunk&order=market_cap_desc&per_page=250&page=1&sparkline=false';
      final res = await client.get(Uri.parse(url));
      if (res.statusCode != 200) throw Exception('Failed to fetch market data (Status: ${res.statusCode})');

      final List list = jsonDecode(res.body) as List;
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint('Error in fetchMarketData: $e');
      return [];
    }
  }
}
