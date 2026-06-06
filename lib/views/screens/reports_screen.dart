import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/models/sales.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/providers/sale_item_provider.dart';
import 'package:vetcare_connect/providers/sales_provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
import 'package:vetcare_connect/views/screens/access_denied_screen.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Preload data used by the tabs.
    Provider.of<SalesProvider>(context, listen: false).loadSales();
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    // Customers are not allowed to view reports.
    if (currentUser?.usertype == 'customer') {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sales Report'),
            Tab(text: 'Inventory Report'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/reports'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesReport(),
          _buildInventoryReport(),
        ],
      ),
    );
  }

  Widget _buildSalesReport() {
    final salesProvider = Provider.of<SalesProvider>(context);
    final allSales = salesProvider.sales;

    final filteredSales = _filterSalesByPeriod(allSales, _selectedPeriod);

    final totalSales = filteredSales.fold<double>(
      0.0,
      (sum, sale) => sum + sale.totalamount,
    );
    final totalTransactions = filteredSales.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sales Summary',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: DropdownButton<String>(
                    isDense: true,
                    isExpanded: true,
                    value: _selectedPeriod,
                    items: ['All Time', 'This Month', 'Last Month']
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedPeriod = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Sales:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '₱${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Transactions:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$totalTransactions',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sales by Date',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: filteredSales.map((sale) {
                    final timeDisplay = _extractTimeDisplay(sale.paymentDate);

                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected != true) return;

                        // saleid is nullable in the model; guard to avoid runtime errors.
                        final id = sale.saleid;
                        if (id == null) return;

                        _showSalesDetailsDialog(id, [sale]);
                      },
                      cells: [
                        DataCell(Text(sale.date)),
                        DataCell(Text(timeDisplay)),
                        DataCell(
                          Text(
                            '₱${sale.totalamount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryReport() {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    final lowStockProducts = products.where((p) => p.stockquantity < 10).toList();
    final outOfStockProducts = products.where((p) => p.stockquantity == 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Inventory Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Products:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${products.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Low Stock (<10):',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '${lowStockProducts.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Out of Stock:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '${outOfStockProducts.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.warning_amber,
                  size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'Product Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Stock Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: lowStockProducts.map((product) {
                  final statusColor =
                      product.stockquantity == 0 ? Colors.red : Colors.orange;
                  final statusText =
                      product.stockquantity == 0 ? 'Out of Stock' : 'Low Stock';

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          product.productname,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${product.stockquantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Sales> _filterSalesByPeriod(List<Sales> allSales, String period) {
    if (period == 'All Time') return allSales;

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    if (period == 'This Month') {
      return allSales.where((sale) {
        final saleDate = DateTime.parse(sale.date);
        return saleDate.year == currentMonth.year && saleDate.month == currentMonth.month;
      }).toList();
    }

    return allSales.where((sale) {
      final saleDate = DateTime.parse(sale.date);
      return saleDate.year == lastMonth.year && saleDate.month == lastMonth.month;
    }).toList();
  }

  /// Extract time display from `paymentDate`.
  /// Handles ISO strings like `YYYY-MM-DDTHH:MM:SS...`.
  String _extractTimeDisplay(String paymentDate) {
    try {
      if (paymentDate.contains('T')) {
        final partsIso = paymentDate.split('T');
        if (partsIso.length > 1) {
          final timePart = partsIso[1];
          if (timePart.length >= 8) return timePart.substring(0, 8);
        }
      }

      if (paymentDate.contains(' ')) {
        final partsSpace = paymentDate.split(' ');
        if (partsSpace.length > 1) {
          final timePart = partsSpace[1];
          return timePart.length >= 8 ? timePart.substring(0, 8) : timePart;
        }
      }

      return 'N/A';
    } catch (_) {
      return 'N/A';
    }
  }

  void _showSalesDetailsDialog(int saleId, List<Sales> sales) {
    if (sales.isEmpty) return;

    final sale = sales.first;

    final saleItemProvider = Provider.of<SaleItemProvider>(context, listen: false);
    final saleItems =
        saleItemProvider.saleItems.where((item) => item.saleid == saleId).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Sales Details for Sale #$saleId'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${sale.date}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${_extractTimeDisplay(sale.paymentDate)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Method: ${sale.paymentMethod}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Products Sold:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: saleItems.map<DataRow>((item) {
                        final productProvider =
                            Provider.of<ProductProvider>(dialogContext, listen: false);

                        final product = productProvider.products.firstWhere(
                          (p) => p.productid == item.productid,
                          orElse: () => Product(
                            productid: null,
                            productname: 'Unknown Product',
                            description: '',
                            price: 0.0,
                            stockquantity: 0,
                            category: '',
                          ),
                        );

                        return DataRow(
                          cells: [
                            DataCell(Text(product.productname)),
                            DataCell(Text('${item.quantity}')),
                            DataCell(Text('₱${item.price.toStringAsFixed(2)}')),
                            DataCell(
                              Text('₱${(item.price * item.quantity).toStringAsFixed(2)}'),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Amount: ₱${sale.totalamount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}

