import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/sale_item.dart';
import 'package:vetcare_connect/models/sales.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/models/inventory_log.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/providers/sales_provider.dart';
import 'package:vetcare_connect/providers/sale_item_provider.dart';
import 'package:vetcare_connect/providers/inventory_log_provider.dart';
import 'package:vetcare_connect/services/database_service.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';
import 'package:vetcare_connect/views/screens/access_denied_screen.dart';

class SalesPosScreen extends StatefulWidget {
  const SalesPosScreen({super.key});

  @override
  State<SalesPosScreen> createState() => _SalesPosScreenState();
}

class _SalesPosScreenState extends State<SalesPosScreen> {
  final List<SaleItem> _cart = [];
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
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

    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales POS'),
        backgroundColor: const Color.fromARGB(255, 13, 157, 30),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(currentRoute: '/sales_pos'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop layout: Row with products and cart side by side
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Products',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return InkWell(
                              onTap: () => _addToCart(product),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.productName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('₱${product.price}'),
                                    Text('Stock: ${product.stockQuantity}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Cart',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  _getProductName(item.productId),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Qty: ${item.quantity} x ₱${item.price.toStringAsFixed(2)} = ₱${(item.price * item.quantity).toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total: ₱${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cart.isEmpty ? null : _checkout,
                              child: const Text('Checkout'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile layout: Column with products on top, cart below
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Products',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return InkWell(
                              onTap: () => _addToCart(product),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.productName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('₱${product.price}'),
                                    Text('Stock: ${product.stockQuantity}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Cart',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  _getProductName(item.productId),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Qty: ${item.quantity} x ₱${item.price.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total: ₱${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cart.isEmpty ? null : _checkout,
                              child: const Text('Checkout'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.productId == product.productId);
    int currentQuantityInCart = existingIndex != -1 ? _cart[existingIndex].quantity : 0;

    if (currentQuantityInCart + 1 > product.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient stock for ${product.productName}')),
      );
      return;
    }

    setState(() {
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
        _cart[existingIndex].subtotal = _cart[existingIndex].price * _cart[existingIndex].quantity;
      } else {
        _cart.add(SaleItem(
          salesItemId: null,
          saleId: null,
          productId: product.productId!,
          quantity: 1,
          price: product.price,
          subtotal: product.price,
        ));
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _total = _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  String _getProductName(String productId) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.products.firstWhere(
      (p) => p.productId == productId,
      orElse: () => Product(productId: null, productName: 'Unknown Product', description: '', price: 0.0, stockQuantity: 0, category: ''),
    );
    return product.productName;
  }

  void _checkout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.firebaseUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Create the sale
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final saleItemProvider = Provider.of<SaleItemProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final inventoryLogProvider = Provider.of<InventoryLogProvider>(context, listen: false);

    final sale = Sales(
      saleId: null,
      ownerUid: uid,
      date: DateTime.now().toIso8601String().split('T')[0],
      totalAmount: _total,
      paymentStatus: 'paid',
      paymentMethod: 'cash', // You can add a dialog to choose payment method
      paymentDate: DateTime.now().toIso8601String(),
    );

    final saleId = await DatabaseService().insertSales(sale);

    // Create sale items and update stock
    for (final item in _cart) {
      final saleItem = SaleItem(
        salesItemId: null,
        saleId: saleId,
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        subtotal: item.subtotal,
      );
      await DatabaseService().insertSaleItem(saleItem);

      // Update product stock
      final product = productProvider.products.firstWhere((p) => p.productId == item.productId);
      final updatedProduct = Product(
        productId: product.productId,
        productName: product.productName,
        description: product.description,
        price: product.price,
        stockQuantity: product.stockQuantity - item.quantity,
        category: product.category,
      );
      await DatabaseService().updateProduct(updatedProduct);

      // Add inventory log
      final log = InventoryLog(
        logId: null,
        productId: item.productId,
        quantityChange: -item.quantity,
        date: DateTime.now().toIso8601String().split('T')[0],
        reason: 'Sale',
      );
      await DatabaseService().insertInventoryLog(log);
    }

    // Clear cart and refresh providers
    setState(() {
      _cart.clear();
      _total = 0.0;
    });

    await salesProvider.loadSales();
    await saleItemProvider.loadSaleItems();
    await productProvider.loadProducts();
    await inventoryLogProvider.loadInventoryLogs();

    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sale completed successfully at $timestamp!')),
    );

  }
}

