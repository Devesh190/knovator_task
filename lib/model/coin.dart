// lib/models/coin.dart
import 'package:objectbox/objectbox.dart';

@Entity()
class Coin {
  int id;
  String coinId;
  String name;
  String symbol;
  String nameLower;
  String symbolLower;
  String? imageUrl;
  double currentPrice;
  double oldPrice;

  Coin({
    this.id = 0,
    required this.coinId,
    required this.name,
    required this.symbol,
    this.imageUrl,
    this.currentPrice = 0.0,
    this.oldPrice = 0.0,
  })  : nameLower = name.toLowerCase(),
        symbolLower = symbol.toLowerCase();
}
