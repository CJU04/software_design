class Appointment {
  int? appointmentid;
  int petid; // FK to Pet
  int userid; // FK to User (customer who booked)
  int? assignedUserId; // FK to User (staff/vet assigned)
  String date;
  String time;
  String reason;
  String status;

  Appointment({
    this.appointmentid,
    required this.petid,
    required this.userid,
    this.assignedUserId,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentid': appointmentid,
      'petid': petid,
      'userid': userid,
      'assignedUserId': assignedUserId,
      'date': date,
      'time': time,
      'reason': reason,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentid: map['appointmentid'],
      petid: map['petid'],
      userid: map['userid'],
      assignedUserId: map['assignedUserId'],
      date: map['date'],
      time: map['time'],
      reason: map['reason'],
      status: map['status'],
    );
  }
}

