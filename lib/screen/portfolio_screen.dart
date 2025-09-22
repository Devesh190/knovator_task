import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/portfolio_provider.dart';
import 'all_coins_screen.dart';


class PortfolioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.holdings.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Portfolio'),
            actions: [
              PopupMenuButton(
                onSelected: (val) =>
                    provider.changeSort(val as SortOption),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: SortOption.byValueDesc,
                      child: Text("Sort by Value")),
                  const PopupMenuItem(
                      value: SortOption.byNameAsc,
                      child: Text("Sort by Name")),
                ],
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.refreshPrices(),
            child: ListView.builder(
              itemCount: provider.holdings.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: Text(
                      "Total Value: \$${provider.totalValue}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                final h = provider.holdings[index - 1];
                final price =
                    provider.currentPrices[h.coinId] ?? h.lastPrice;
                final value = price * h.quantity;

                // check price change
                final prev = provider.previousPrices[h.coinId];
                Color? priceColor;
                if (prev != null) {
                  if (price > prev) priceColor = Colors.green;
                  if (price < prev) priceColor = Colors.red;
                }

                return Dismissible(
                  key: ValueKey(h.id),
                  background: Container(child:Icon(Icons.delete_outline_outlined,color: Colors.white,), color: Colors.red),
                  onDismissed: (_) => provider.removeHolding(h.id),
                  child: ListTile(
                    title: Text(h.coinId),
                    subtitle: Text(
                        "${h.quantity} coins @ \$$price"),
                    trailing: Text(
                      "\$$value",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: priceColor),
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllCoinsScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),

        );
      },
    );
  }
}
