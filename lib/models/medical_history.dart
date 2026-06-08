class MedicalHistory {
  String? historyId;
  String petId; // FK to Pet.petId
  String appointmentId; // FK to Appointment.appointmentId
  String date;
  String diagnosis;
  String treatment;
  String notes;

  MedicalHistory({
    this.historyId,
    required this.petId,
    required this.appointmentId,
    required this.date,
    required this.diagnosis,
    required this.treatment,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'petId': petId,
      'appointmentId': appointmentId,
      'date': date,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    return MedicalHistory(
      historyId: map['historyId'] as String?,
      petId: map['petId'] as String? ?? '',
      appointmentId: map['appointmentId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      treatment: map['treatment'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }

  MedicalHistory copyWith({
    String? historyId,
    String? petId,
    String? appointmentId,
    String? date,
    String? diagnosis,
    String? treatment,
    String? notes,
  }) {
    return MedicalHistory(
      historyId: historyId ?? this.historyId,
      petId: petId ?? this.petId,
      appointmentId: appointmentId ?? this.appointmentId,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
    );
  }
}
