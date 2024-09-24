import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/event_model.dart';
import 'view_event_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, List<Event>>> _fetchEvents() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    DateTime now = DateTime.now();

    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user?.uid ?? '';

    List<Event> events = querySnapshot.docs.map((doc) {
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    List<Event> myEvents = [];
    List<Event> otherEvents = [];

    for (var event in events) {
      try {
        String eventDateTimeString = event.time != null && event.time.isNotEmpty
            ? "${event.date} ${event.time}"
            : "${event.date} 00:00:00";

        DateTime eventDateTime = DateTime.parse(eventDateTimeString);

        print("Event: ${event.name}, DateTime: $eventDateTime");

        if (eventDateTime.isAfter(now)) {
          if (event.creatorId == currentUserId) {
            myEvents.add(event);
          } else {
            otherEvents.add(event);
          }
        }
      } catch (e) {
        print('Error parsing date for event: ${event.name}, error: $e');
      }
    }

    myEvents.sort((a, b) => _compareEventsByDate(a, b));
    otherEvents.sort((a, b) => _compareEventsByDate(a, b));

    return {
      'myEvents': myEvents,
      'otherEvents': otherEvents,
    };
  }

  int _compareEventsByDate(Event a, Event b) {
    DateTime dateA = DateTime.parse(a.time != null && a.time.isNotEmpty
        ? "${a.date} ${a.time}"
        : "${a.date} 00:00:00");
    DateTime dateB = DateTime.parse(b.time != null && b.time.isNotEmpty
        ? "${b.date} ${b.time}"
        : "${b.date} 00:00:00");

    return dateA.compareTo(dateB);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      body: FutureBuilder<Map<String, List<Event>>>(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData ||
              (snapshot.data!['myEvents']!.isEmpty &&
                  snapshot.data!['otherEvents']!.isEmpty)) {
            return const Center(child: Text('No events found.'));
          }

          final myEvents = snapshot.data!['myEvents']!;
          final otherEvents = snapshot.data!['otherEvents']!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (myEvents.isNotEmpty) ...[
                const Text(
                  'My Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                _buildEventList(myEvents),
              ],
              if (otherEvents.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Other Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                _buildEventList(otherEvents),
              ],
            ],
          );
        },
      ),
      backgroundColor: const Color(0xFFF4F6F8),
    );
  }

  Widget _buildEventList(List<Event> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event);
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final imagePath =
        event.imagePaths.isNotEmpty ? event.imagePaths.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewEventPage(event: event),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Event image
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imagePath != null
                        ? NetworkImage(imagePath)
                        : const AssetImage('assets/placeholder.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 55,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.pinkAccent.withOpacity(0.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.date.split('-').last,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      Text(
                        _getMonthAbbreviation(event.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthAbbreviation(String date) {
    final month = DateTime.parse(date).month;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
