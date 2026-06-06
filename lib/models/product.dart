class Product {
  int? productid;
  String productname;
  String category;
  String description;
  double price;
  int stockquantity;

  Product({
    this.productid,
    required this.productname,
    required this.category,
    required this.description,
    required this.price,
    required this.stockquantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productid': productid,
      'productname': productname,
      'category': category,
      'description': description,
      'price': price,
      'stockquantity': stockquantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productid: map['productid'],
      productname: map['productname'],
      category: map['category'],
      description: map['description'],
      price: map['price'],
      stockquantity: map['stockquantity'],
    );
  }
}

