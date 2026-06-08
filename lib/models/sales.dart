class Sales {
  String? saleId;
  String ownerUid; // FK to FirebaseUser.uid
  String date;
  double totalAmount;
  String paymentStatus;
  String paymentMethod;
  String paymentDate;

  Sales({
    this.saleId,
    required this.ownerUid,
    required this.date,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'ownerUid': ownerUid,
      'date': date,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate,
    };
  }

  factory Sales.fromMap(Map<String, dynamic> map) {
    return Sales(
      saleId: map['saleId'] as String?,
      ownerUid: map['ownerUid'] as String? ?? '',
      date: map['date'] as String? ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      paymentDate: map['paymentDate'] as String? ?? '',
    );
  }

  Sales copyWith({
    String? saleId,
    String? ownerUid,
    String? date,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentDate,
  }) {
    return Sales(
      saleId: saleId ?? this.saleId,
      ownerUid: ownerUid ?? this.ownerUid,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}
