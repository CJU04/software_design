import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/inventory_log.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/inventory_log_provider.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';
import 'package:vetcare_connect/views/screens/access_denied_screen.dart';

class InventoryLogsScreen extends StatefulWidget {
  const InventoryLogsScreen({super.key});

  @override
  State<InventoryLogsScreen> createState() => _InventoryLogsScreenState();
}

class _InventoryLogsScreenState extends State<InventoryLogsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<InventoryLogProvider>(context, listen: false).loadInventoryLogs();
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role;
    final isCustomer = role?.value == 'customer';

    if (isCustomer) {
      return const AccessDeniedScreen();
    }

    final inventoryLogProvider = Provider.of<InventoryLogProvider>(context);
    final inventoryLogsAll = inventoryLogProvider.inventoryLogs;

    // Cache ProductProvider and products outside the list item builder.
    // This avoids repeatedly looking up the provider for every row.
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    List<InventoryLog> inventoryLogs = inventoryLogsAll;

    if (_searchQuery.isNotEmpty) {
      inventoryLogs = inventoryLogs.where((log) => log.date.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Logs'),
      ),
      drawer: const AppDrawer(currentRoute: '/inventory_logs'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 800 : double.infinity;
            double horizontalPadding =
                constraints.maxWidth > 600 ? (constraints.maxWidth - 800) / 2 : 0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Inventory Logs',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                inventoryLogs.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text('No inventory logs found'),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList.builder(
                          itemCount: inventoryLogs.length,
                          itemBuilder: (context, index) {
                            final log = inventoryLogs[index];
                            final product = products.firstWhere(
                              (p) => p.productId == log.productId,
                              orElse: () => Product(
                                productName: 'Unknown Product',
                                category: '',
                                description: '',
                                price: 0.0,
                                stockQuantity: 0,
                              ),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(
                                  '${product.productName} - ${log.reason}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${log.date} - Qty: ${log.quantityChange}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

