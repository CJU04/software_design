import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetcare_connect/models/product.dart';
import 'package:vetcare_connect/providers/product_provider.dart';
import 'package:vetcare_connect/providers/user_provider.dart';
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
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isCustomer = currentUser?.usertype == 'customer';

    List<Product> products = productProvider.products;
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) => product.productname.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedCategory != 'All') {
      products = products.where((product) => product.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
      ),
      drawer: const AppDrawer(currentRoute: '/product_inventory'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text('No products found'),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text(product.productname),
                          subtitle: Text('${product.category} - ₱${product.price} - Stock: ${product.stockquantity}'),
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
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
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
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                final newProduct = Product(
                  productid: null,
                  productname: nameController.text,
                  category: selectedCategory,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stockquantity: int.tryParse(stockController.text) ?? 0,
                );
                Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(Product product) {
    final nameController = TextEditingController(text: product.productname);
    final categoryController = TextEditingController(text: product.category);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stockquantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
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
            onPressed: () {
              final updatedProduct = Product(
                productid: product.productid,
                productname: nameController.text,
                category: categoryController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                stockquantity: int.tryParse(stockController.text) ?? 0,
              );
              Provider.of<ProductProvider>(context, listen: false).updateProduct(updatedProduct);
              Navigator.pop(context);
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
        content: Text('Are you sure you want to delete ${product.productname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.productid!);
              Navigator.pop(context);
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

