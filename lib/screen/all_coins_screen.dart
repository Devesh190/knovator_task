// lib/ui/screens/all_coins_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/portfolio_provider.dart';
import '../main.dart';
import '../model/coin.dart';
import '../repo/coin_repository.dart';

class AllCoinsScreen extends StatefulWidget {
  const AllCoinsScreen({super.key});

  @override
  State<AllCoinsScreen> createState() => _AllCoinsScreenState();
}

class _AllCoinsScreenState extends State<AllCoinsScreen> {
  final _searchController = TextEditingController();
  final Map<String, int> _quantities = {}; // coinId -> quantity
  List<Coin> _coins = [];
  List<Coin> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coinRepo = getIt<CoinRepository>();
    await coinRepo.ensureCoinList();
    final list = await coinRepo.searchCoins(""); // all coins
    setState(() {
      _coins = list;
      _filtered = list;
      _loading = false;
    });
  }
  Future<void> _search(String query) async {
    final coinRepo = getIt<CoinRepository>();
    final found = await coinRepo.searchCoins(query);
    setState(() {
      _filtered = found;
    });
  }

  void _showSummarySheet() {
    final provider = context.read<PortfolioProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final selectedCoins = _coins
            .where((c) => (_quantities[c.coinId] ?? 0) > 0)
            .toList();
        double total = 0;
        for (final c in selectedCoins) {
          total += (c.currentPrice * (_quantities[c.coinId] ?? 0));
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7, // max height for sheet
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Selected Coins",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Scrollable part
                Expanded(
                  child: selectedCoins.isEmpty
                      ? const Center(child: Text("No coins selected"))
                      : ListView.builder(
                    itemCount: selectedCoins.length,
                    itemBuilder: (context, index) {
                      final c = selectedCoins[index];
                      final qty = _quantities[c.coinId] ?? 0;
                      final value = c.currentPrice * qty;
                      return ListTile(
                        title: Text("${c.name} (${c.symbol})"),
                        subtitle: Text("Qty: $qty x \$${c.currentPrice}"),
                        trailing: Text("\$$value"),
                      );
                    },
                  ),
                ),

                const Divider(),
                Text(
                  "Total Value: \$$total",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    for (final c in selectedCoins) {
                      final qty = _quantities[c.coinId] ?? 0;
                      if (qty > 0) {
                        await provider.addOrUpdateHolding(c.coinId, qty.toDouble());
                      }
                    }
                    Navigator.pop(ctx); // close sheet
                    Navigator.pop(context); // go back to portfolio screen
                  },
                  child: const Text("Save to Portfolio"),
                )
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Coins"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search coin...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final coin = _filtered[i];
                final qty = _quantities[coin.coinId] ?? 0;

                Icon? arrow;
                if (coin.oldPrice < coin.currentPrice) {
                  arrow = const Icon(Icons.arrow_upward, color: Colors.green);
                } else if (coin.oldPrice > coin.currentPrice) {
                  arrow = const Icon(Icons.arrow_downward, color: Colors.red);
                }

                // Controller for the TextField
                final TextEditingController _controller =
                TextEditingController(text: qty.toString());

                return ListTile(
                  leading: coin.imageUrl != null
                      ? Image.network(coin.imageUrl!, width: 32, height: 32)
                      : const CircleAvatar(child: Icon(Icons.monetization_on)),
                  title: Text("${coin.name} (${coin.symbol})"),
                  subtitle: Text("\$${coin.currentPrice}"),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            final input = _controller.text;
                            final value = int.tryParse(input) ?? 0;
                            setState(() {
                              _quantities[coin.coinId] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSummarySheet,
        icon: const Icon(Icons.check),
        label: const Text("Review"),
      ),
    );
  }
}
