class SaleItem {
  int? salesitemid;
  int? saleid; // FK to Sales
  int productid; // FK to Product
  int quantity;
  double price;
  double subtotal;

  SaleItem({
    this.salesitemid,
    this.saleid,
    required this.productid,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'salesitemid': salesitemid,
      'saleid': saleid,
      'productid': productid,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      salesitemid: map['salesitemid'],
      saleid: map['saleid'],
      productid: map['productid'],
      quantity: map['quantity'],
      price: map['price'],
      subtotal: map['subtotal'],
    );
  }
}

