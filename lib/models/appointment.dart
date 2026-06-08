class Appointment {
  String? appointmentId;
  String petId; // FK to Pet.petId
  String ownerUid; // FK to FirebaseUser.uid (customer who booked)
  String? assignedUserId; // FK to FirebaseUser.uid (staff/vet assigned)
  String date;
  String time;
  String reason;
  String status;

  Appointment({
    this.appointmentId,
    required this.petId,
    required this.ownerUid,
    this.assignedUserId,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'petId': petId,
      'ownerUid': ownerUid,
      'assignedUserId': assignedUserId,
      'date': date,
      'time': time,
      'reason': reason,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointmentId'] as String?,
      petId: map['petId'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      assignedUserId: map['assignedUserId'] as String?,
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? '',
    );
  }

  Appointment copyWith({
    String? appointmentId,
    String? petId,
    String? ownerUid,
    String? assignedUserId,
    String? date,
    String? time,
    String? reason,
    String? status,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      petId: petId ?? this.petId,
      ownerUid: ownerUid ?? this.ownerUid,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      date: date ?? this.date,
      time: time ?? this.time,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }
}
