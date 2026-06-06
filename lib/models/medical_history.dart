class MedicalHistory {
  int? historyid;
  int petid; // FK to Pet
  int appointmentid; // FK to Appointment
  String date;
  String diagnosis;
  String treatment;
  String notes;

  MedicalHistory({
    this.historyid,
    required this.petid,
    required this.appointmentid,
    required this.date,
    required this.diagnosis,
    required this.treatment,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyid': historyid,
      'petid': petid,
      'appointmentid': appointmentid,
      'date': date,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    return MedicalHistory(
      historyid: map['historyid'],
      petid: map['petid'],
      appointmentid: map['appointmentid'],
      date: map['date'],
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      notes: map['notes'],
    );
  }
}

