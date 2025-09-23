
import '../core/object_box.dart';
import '../model/coin.dart';
import '../objectbox.g.dart';
import '../services/api_service.dart';

class CoinRepository {
  final ObjectBox _db;
  final ApiService _api;

  CoinRepository(this._db, this._api);

  Future<void> ensureCoinList() async {
    if (_db.coinBox.isEmpty()) {
      final list = await _api.fetchCoinList();
      final coins = list.map((e) {
        return Coin(
          coinId: e['id'],
          name: e['name'],
          symbol: e['symbol'],
          currentPrice: e['currentPrice'] ?? 0.0,
          oldPrice: 0.0,
        );
      }).toList();
      _db.coinBox.putMany(coins);
    }
  }


  Future<List<Coin>> searchCoins(String query) async {
    if (query.isEmpty) {
      final all = _db.coinBox.getAll();
      return all;
    }
    final q = query.toLowerCase();

    final builder = _db.coinBox.query(
      Coin_.nameLower.contains(q) | Coin_.symbolLower.contains(q),
    )..order(Coin_.nameLower);

    final queryObj = builder.build();
    final results = queryObj.find();
    queryObj.close();
    return results;
  }


  Future<List<Map<String, dynamic>>> fetchMarketData(List<String> ids) async {
    return await _api.fetchMarketData(ids);
  }

  void updateCoinImage(String coinId, String imageUrl) {
    final coin = _db.coinBox.query(Coin_.coinId.equals(coinId)).build().findFirst();
    if (coin != null) {
      coin.imageUrl = imageUrl;
      _db.coinBox.put(coin);
    }
  }

  Future<void> refreshCoinPrices(List<String> ids) async {
    final prices = await _api.fetchPrices(ids);
    for (final id in ids) {
      final coin = getCoin(id);
      if (coin != null) {
        coin.oldPrice = coin.currentPrice;
        coin.currentPrice = prices[id] ?? coin.currentPrice;
        _db.coinBox.put(coin);
      }
    }
  }


  Coin? getCoin(String coinId) {
    return _db.coinBox.query(Coin_.coinId.equals(coinId)).build().findFirst();
  }

}
