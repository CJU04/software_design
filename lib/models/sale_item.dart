class SaleItem {
  String? salesItemId;
  String? saleId; // FK to Sales.saleId
  String productId; // FK to Product.productId
  int quantity;
  double price;
  double subtotal;

  SaleItem({
    this.salesItemId,
    this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'salesItemId': salesItemId,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      salesItemId: map['salesItemId'] as String?,
      saleId: map['saleId'] as String?,
      productId: map['productId'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SaleItem copyWith({
    String? salesItemId,
    String? saleId,
    String? productId,
    int? quantity,
    double? price,
    double? subtotal,
  }) {
    return SaleItem(
      salesItemId: salesItemId ?? this.salesItemId,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
