import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'package:my_app/main.dart';
import 'package:workmanager/workmanager.dart';
import 'event_model.dart';
import 'edit_event_page.dart'; // The page where the user can edit the event

class ViewEventPage extends StatefulWidget {
  final Event event;

  const ViewEventPage({required this.event, Key? key}) : super(key: key);

  @override
  _ViewEventPageState createState() => _ViewEventPageState();
}

class _ViewEventPageState extends State<ViewEventPage> {
  late String _mainImagePath;
  String? currentUserId;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _mainImagePath =
        widget.event.imagePaths.isNotEmpty ? widget.event.imagePaths.first : '';
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
      if (widget.event.registeredUsers.contains(currentUserId)) {
        isRegistered = true;
      }
    });
  }

  Future<void> _confirmDeleteEvent() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
              'Are you sure you want to delete this event? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _deleteEvent();
    }
  }

  Future<void> _deleteEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(currentIndex: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  Future<void> _scheduleNotificationForEvent(Event event) async {
    DateTime eventDateTime = DateTime.parse(event.date + ' ' + event.time);
    DateTime notificationTime =
        eventDateTime.subtract(const Duration(hours: 1));

    await Workmanager().registerOneOffTask(
      "event_notification_${event.id}",
      "notify_event",
      initialDelay: notificationTime.difference(DateTime.now()),
      inputData: {
        'eventId': event.id,
        'eventName': event.name,
        'eventTime': event.time,
      },
    );
  }

  Future<void> _registerForEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'registeredUsers': FieldValue.arrayUnion([currentUserId])
      });

      setState(() {
        isRegistered = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(currentIndex: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to register: $e')));
    }
  }

  Future<void> _unregisterForEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'registeredUsers': FieldValue.arrayRemove([currentUserId])
      });

      setState(() {
        isRegistered = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unregistered successfully')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(currentIndex: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to unregister: $e')));
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (currentUserId == widget.event.creatorId) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventPage(event: widget.event),
                  ),
                );
                if (result == 'event_updated') {
                  setState(() {});
                  Navigator.pop(context, 'event_updated');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteEvent(),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),
                  const SizedBox(height: 24.0),
                  _buildEventDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (currentUserId != widget.event.creatorId)
          ? FloatingActionButton(
              onPressed: () {
                if (isRegistered) {
                  _unregisterForEvent();
                } else {
                  _registerForEvent();
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: isRegistered ? 'Unregister' : 'Register',
              child: Icon(
                isRegistered ? Icons.person_remove : Icons.person_add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildMainImage() {
    return _mainImagePath.isNotEmpty
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              _mainImagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Image not found'));
              },
            ),
          )
        : const Center(child: Text('No Image'));
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.event.imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = widget.event.imagePaths[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _mainImagePath = imagePath;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              width: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _mainImagePath == imagePath
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image not found'));
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailCard('Event Details', [
          DetailItem(
              icon: Icons.location_on,
              label: 'Location',
              value: widget.event.location),
          DetailItem(
              icon: Icons.calendar_today,
              label: 'Date',
              value: widget.event.date),
          if (widget.event.time.isNotEmpty)
            DetailItem(
                icon: Icons.access_time,
                label: 'Time',
                value: widget.event.time),
          if (widget.event.guest.isNotEmpty)
            DetailItem(
                icon: Icons.person,
                label: 'Special Guest',
                value: widget.event.guest),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Additional Information', [
          if (widget.event.description.isNotEmpty)
            DetailItem(
                icon: Icons.info_outline,
                label: 'Description',
                value: widget.event.description),
          DetailItem(
              icon: Icons.currency_rupee,
              label: 'Fees',
              value: widget.event.fees),
          if (widget.event.type != null)
            DetailItem(
                icon: Icons.category,
                label: 'Event Type',
                value: widget.event.type!),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(String title, List<DetailItem> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Icon(item.icon, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class DetailItem {
  final IconData icon;
  final String label;
  final String value;

  DetailItem({required this.icon, required this.label, required this.value});
}
