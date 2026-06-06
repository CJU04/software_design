class InventoryLog {
  int? inventoryLogId;
  int productId; // FK to Product
  String date;
  int quantityChange;
  String reason;

  InventoryLog({
    this.inventoryLogId,
    required this.productId,
    required this.date,
    required this.quantityChange,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'inventory_logid': inventoryLogId,
      'productid': productId,
      'date': date,
      'quantity_change': quantityChange,
      'reason': reason,
    };
  }

  factory InventoryLog.fromMap(Map<String, dynamic> map) {
    return InventoryLog(
      inventoryLogId: map['inventory_logid'],
      productId: map['productid'],
      date: map['date'],
      quantityChange: map['quantity_change'],
      reason: map['reason'],
    );
  }
}

