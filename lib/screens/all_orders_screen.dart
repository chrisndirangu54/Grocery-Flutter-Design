import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../screens/order_details_screen.dart';
import 'package:fl_chart/fl_chart.dart'; // Import for the chart

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Fetch the list of all orders
    final allOrders = orderProvider
        .allOrders; // Use the appropriate method or property for all orders

    // Placeholder data for order summations (you should replace this with actual data)
    final orderSummations = [
      OrderSummation('Daily', 150),
      OrderSummation('Weekly', 800),
      OrderSummation('Monthly', 3500),
      OrderSummation('Yearly', 42000),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
      ),
      body: Column(
        children: [
          // Order Summation Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
                barGroups: orderSummations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final summation = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        y: summation.amount.toDouble(),
                        colors: [Colors.blueAccent], // Correct color usage
                        width: 20,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Orders List
          Expanded(
            child: allOrders.isEmpty
                ? const Center(child: Text('No orders available'))
                : ListView.builder(
                    itemCount: allOrders.length,
                    itemBuilder: (context, index) {
                      final order = allOrders[index];
                      return ListTile(
                        title: Text(order.description),
                        subtitle: Text('Total Amount: \$${order.totalAmount}'),
                        trailing: Text('Status: ${order.status}'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: order.id,
                            ),
                          ));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class OrderSummation {
  final String period;
  final int amount;

  OrderSummation(this.period, this.amount);
}
