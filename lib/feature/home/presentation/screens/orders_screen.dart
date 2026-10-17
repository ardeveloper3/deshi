import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:deshi/core/data/local/app_database.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('স্থানীয় অর্ডার'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: ColorConst.lightGreen.withAlpha(55),
              child: const Icon(Icons.receipt_long_outlined, size: 19),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Order>>(
        stream: appDatabase.watchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('অর্ডার লোড করা যায়নি: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: ColorConst.lightGreen.withAlpha(180),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'এখনও কোনো অর্ডার নেই',
                    style: TextConst.subheading.copyWith(
                      color: ColorConst.darkGreenColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'আপনার করা অর্ডারগুলো এখানে দেখা যাবে',
                    style: TextStyle(color: ColorConst.muted),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                itemCount: orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: ColorConst.lightGreen.withAlpha(
                              45,
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: ColorConst.darkGreenColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order.productName} · ${order.quantity} pcs',
                                  style: TextStyle(
                                    color: ColorConst.ink,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${order.weight}  •  ${order.address}\n${order.phone}',
                                  style: TextStyle(
                                    color: ColorConst.muted,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '৳${order.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: ColorConst.darkGreenColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
