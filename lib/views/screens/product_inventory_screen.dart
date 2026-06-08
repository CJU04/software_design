import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/providers/auth_provider.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/views/widgets/drawer_widget.dart';

class ProductInventoryScreen extends StatefulWidget {
  const ProductInventoryScreen({super.key});

  @override
  State<ProductInventoryScreen> createState() => _ProductInventoryScreenState();
}

class _ProductInventoryScreenState extends State<ProductInventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role;
    final isCustomer = role?.value == 'customer';

    List<Product> products = productProvider.products;
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) => product.productName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedCategory != 'All') {
      products = products.where((product) => product.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
      ),
      drawer: const AppDrawer(currentRoute: '/product_inventory'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 800 : double.infinity;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search Products',
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
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Food', child: Text('Food')),
                          DropdownMenuItem(value: 'Medicine', child: Text('Medicine')),
                          DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text('No products found'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth > 600 ? (constraints.maxWidth - 800) / 2 : 0),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.inventory),
                              title: Text(product.productName),
                              subtitle: Text('${product.category} - ₱${product.price} - Stock: ${product.stockQuantity}'),
                              trailing: isCustomer ? null : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editProduct(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteProduct(product),
                                  ),
                                ],
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
      floatingActionButton: isCustomer ? null : FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addProduct() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    String selectedCategory = 'Food';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Medicine', child: Text('Medicine')),
                        DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                        DropdownMenuItem(value: 'Grooming', child: Text('Grooming')),
                        DropdownMenuItem(value: 'Supplies', child: Text('Supplies')),
                        DropdownMenuItem(value: 'Toys', child: Text('Toys')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Stock Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newProduct = Product(
                  productId: null,
                  productName: nameController.text,
                  category: selectedCategory,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stockQuantity: int.tryParse(stockController.text) ?? 0,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adding product...'), duration: Duration(seconds: 1)),
                );
                try {
                  await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product added successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add product'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(Product product) {
    final nameController = TextEditingController(text: product.productName);
    final categoryController = TextEditingController(text: product.category);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedProduct = Product(
                productId: product.productId,
                productName: nameController.text,
                category: categoryController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                stockQuantity: int.tryParse(stockController.text) ?? 0,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updating product...'), duration: Duration(seconds: 1)),
              );
              try {
                await Provider.of<ProductProvider>(context, listen: false).updateProduct(updatedProduct);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product updated successfully'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update product'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting product...'), duration: Duration(seconds: 1)),
              );
              try {
                await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.productId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete product'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

