class Sales {
  int? saleid;
  int userid; // FK to User
  String date;
  double totalamount;
  String paymentStatus;
  String paymentMethod;
  String paymentDate;

  Sales({
    this.saleid,
    required this.userid,
    required this.date,
    required this.totalamount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'saleid': saleid,
      'userid': userid,
      'date': date,
      'totalamount': totalamount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
    };
  }

  factory Sales.fromMap(Map<String, dynamic> map) {
    return Sales(
      saleid: map['saleid'],
      userid: map['userid'],
      date: map['date'],
      totalamount: map['totalamount'],
      paymentStatus: map['payment_status'],
      paymentMethod: map['payment_method'],
      paymentDate: map['payment_date'],
    );
  }
}

