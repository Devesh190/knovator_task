import '../core/object_box.dart';
import '../model/holding.dart';

class PortfolioRepository {
  final ObjectBox _db;

  PortfolioRepository(this._db);

  Future<List<Holding>> getAllHoldings() async {
    return _db.holdingBox.getAll();
  }

  Future<Holding> createHolding(String coinId, double quantity) async {
    final h = Holding(coinId: coinId, quantity: quantity);
    h.id = _db.holdingBox.put(h);
    return h;
  }

  Future<void> saveHolding(Holding h) async {
    _db.holdingBox.put(h);
  }

  Future<void> updateHoldingPrice(int id, double price) async {
    final h = _db.holdingBox.get(id);
    if (h != null) {
      h.lastPrice = price;
      h.lastUpdatedEpoch = DateTime.now().millisecondsSinceEpoch;
      _db.holdingBox.put(h);
    }
  }

  Future<void> deleteHolding(int id) async {
    _db.holdingBox.remove(id);
  }
}
