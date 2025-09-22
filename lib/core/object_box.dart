import 'package:objectbox/objectbox.dart';
import '../model/coin.dart';
import '../model/holding.dart';
import '../objectbox.g.dart';



class ObjectBox {
  late final Store store;
  late final Box<Coin> coinBox;
  late final Box<Holding> holdingBox;

  ObjectBox._create(this.store) {
    coinBox = Box<Coin>(store);
    holdingBox = Box<Holding>(store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
