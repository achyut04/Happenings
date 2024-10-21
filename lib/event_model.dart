class Event {
  final String? id;
  final String name;
  final String location;
  final String date;
  final String time;
  final String guest;
  final String description;
  final String fees;
  final String? type;
  List<String> imagePaths;
  final String creatorId;
  List<String> registeredUsers;

  Event({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.guest,
    required this.description,
    required this.fees,
    this.type,
    required this.imagePaths,
    required this.creatorId,
    required this.registeredUsers,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      guest: map['guest'] ?? '',
      description: map['description'] ?? '',
      fees: map['fees'] ?? '',
      type: map['type'],
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      creatorId: map['creatorId'] ?? '',
      registeredUsers: List<String>.from(map['registeredUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'date': date,
      'time': time,
      'guest': guest,
      'description': description,
      'fees': fees,
      'type': type,
      'imagePaths': imagePaths,
      'creatorId': creatorId,
      'registeredUsers': registeredUsers,
    };
  }
}
