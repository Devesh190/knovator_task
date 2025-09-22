import 'package:objectbox/objectbox.dart';

@Entity()
class Holding {
  int id;
  String coinId;
  double quantity;
  double lastPrice;
  int lastUpdatedEpoch;

  Holding({
    this.id = 0,
    required this.coinId,
    required this.quantity,
    this.lastPrice = 0.0,
    int? lastUpdatedEpoch,
  }) : lastUpdatedEpoch = lastUpdatedEpoch ?? DateTime.now().millisecondsSinceEpoch;
}
