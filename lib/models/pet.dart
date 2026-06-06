class Pet {
  int? petid;
  int userid; // FK to User
  String name;
  String type;
  String breed;
  int age;
  String gender;
  String vaccinationStatus;
  String healthNotes;

  Pet({
    this.petid,
    required this.userid,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.vaccinationStatus,
    required this.healthNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'petid': petid,
      'userid': userid,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'gender': gender,
      'vaccination_status': vaccinationStatus,
      'healthnotes': healthNotes,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      petid: map['petid'],
      userid: map['userid'],
      name: map['name'],
      type: map['type'],
      breed: map['breed'],
      age: map['age'],
      gender: map['gender'],
      vaccinationStatus: map['vaccination_status'],
      healthNotes: map['healthnotes'],
    );
  }
}

