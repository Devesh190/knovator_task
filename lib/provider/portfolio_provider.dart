import 'dart:async';
import 'package:flutter/material.dart';

import '../model/holding.dart';
import '../repo/coin_repository.dart';
import '../repo/portfolio_repository.dart';

enum SortOption { byValueDesc, byNameAsc }

class PortfolioProvider extends ChangeNotifier {
  final CoinRepository coinRepo;
  final PortfolioRepository portfolioRepo;

  List<Holding> holdings = [];
  Map<String, double> currentPrices = {};
  Map<String, double> previousPrices = {};
  SortOption sortOption = SortOption.byValueDesc;
  Timer? _autoRefreshTimer;
  bool loading = false;

  PortfolioProvider(this.coinRepo, this.portfolioRepo) {
    _init();
  }

  Future<void> _init() async {
    loading = true;
    notifyListeners();
    await coinRepo.ensureCoinList();
    holdings = await portfolioRepo.getAllHoldings();
    await refreshPrices();
    _startAutoRefresh(const Duration(minutes: 5));
    loading = false;
    notifyListeners();
  }

  Future<void> refreshPrices() async {
    if (holdings.isEmpty) return;
    try {
      loading = true;
      notifyListeners();

      final ids = holdings.map((h) => h.coinId).toList();

      await coinRepo.refreshCoinPrices(ids);

      currentPrices.clear();
      for (final id in ids) {
        final coin = coinRepo.getCoin(id);
        if (coin != null) {
          currentPrices[id] = coin.currentPrice;
        }
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  double get totalValue {
    double sum = 0;
    for (var h in holdings) {
      final price = currentPrices[h.coinId] ?? h.lastPrice;
      sum += (price * h.quantity);
    }
    return sum;
  }

  Future<void> addOrUpdateHolding(String coinId, double quantity) async {
    Holding? existing;
    try {
      existing = holdings.firstWhere((h) => h.coinId == coinId);
    } catch (_) {
      existing = null;
    }
    if (existing != null) {
      existing.quantity += quantity;
      await portfolioRepo.saveHolding(existing);
    } else {
      final h = await portfolioRepo.createHolding(coinId, quantity);
      holdings.add(h);
    }
    await refreshPrices();
    notifyListeners();
  }

  Future<void> removeHolding(int id) async {
    await portfolioRepo.deleteHolding(id);
    holdings.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  void _startAutoRefresh(Duration interval) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) async {
      await refreshPrices();
    });
  }

  void changeSort(SortOption option) {
    sortOption = option;
    if (option == SortOption.byNameAsc) {
      holdings.sort((a, b) => a.coinId.compareTo(b.coinId)); // or use coin name
    } else {
      holdings.sort((a, b) {
        final av = (currentPrices[a.coinId] ?? a.lastPrice) * a.quantity;
        final bv = (currentPrices[b.coinId] ?? b.lastPrice) * b.quantity;
        return bv.compareTo(av);
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
