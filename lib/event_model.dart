class Event {
  final String? id; // Add the id field for Firestore document ID
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

  Event({
    this.id, // Add id to the constructor
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
  });

  // Factory method to create an Event object from a Firestore Map
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id, // Set the document ID
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
    );
  }

  // Convert Event object to Firestore Map
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
    };
  }
}
