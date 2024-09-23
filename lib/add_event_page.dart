import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/api_services.dart'; // Import the ApiServices class
import 'package:my_app/get_places.dart'; // Import the GetPlaces model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/main.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();
  final _guestController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feesController = TextEditingController();
  List<String> _imagePaths = [];
  String? _selectedType;
  LatLng? _selectedLocationLatLng;
  GoogleMapController? _mapController;
  List<Predictions> _placePredictions = [];

  static const String _googleApiKey =
      'AIzaSyBLNERzXQj0brI3aiIr16DLXHAoy_Ggujo'; // Add your Google API key here

  // Pick images
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imagePaths.addAll(pickedFiles.map((file) => file.path).toList());
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  // Date Picker
  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Get place predictions based on user input
  Future<void> _getPlacePredictions(String input) async {
    try {
      ApiServices apiService = ApiServices();
      GetPlaces places =
          await apiService.getPlaces(input); // Call getPlaces API

      setState(() {
        _placePredictions = places.predictions ?? [];
      });
    } catch (e) {
      print('Error fetching place predictions: $e');
    }
  }

  // Get LatLng from the selected place's placeId
  Future<void> _selectPlace(String placeId) async {
    // Fetch place details and update the map location
    final String requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey';

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Print the entire response body for debugging
      print('API Response Body: $responseBody');

      // Check if the response contains 'result' and 'geometry'
      if (responseBody['result'] != null &&
          responseBody['result']['geometry'] != null) {
        final lat = responseBody['result']['geometry']['location']['lat'];
        final lng = responseBody['result']['geometry']['location']['lng'];

        setState(() {
          _selectedLocationLatLng = LatLng(lat, lng);
          _mapController
              ?.animateCamera(CameraUpdate.newLatLng(_selectedLocationLatLng!));
          _locationController.text =
              responseBody['result']['formatted_address'] ?? 'Unknown Location';
          _placePredictions.clear(); // Clear predictions after selection
        });
      } else {
        print('Error: Place details not found or missing geometry.');
      }
    } else {
      print('Error fetching place details: ${response.statusCode}');
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImagesToFirebase(List<String> imagePaths) async {
    List<String> downloadUrls = [];

    for (String path in imagePaths) {
      File file = File(path);
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('event_images/$fileName');
        TaskSnapshot uploadTask = await storageRef.putFile(file);

        if (uploadTask.state == TaskState.success) {
          String downloadUrl = await uploadTask.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        }
      } catch (e) {
        print('Failed to upload image: $e');
        throw Exception('Failed to upload image: $e');
      }
    }

    return downloadUrls;
  }

  // Submit event data to Firestore
  Future<void> _submitEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Fetch the current user's ID (creatorId)
        final user = FirebaseAuth.instance.currentUser;
        String creatorId = user?.uid ?? ''; // Use the Firebase Auth user ID

        List<String> uploadedImageUrls =
            await _uploadImagesToFirebase(_imagePaths);

        final newEvent = {
          'name': _nameController.text,
          'location': _locationController.text,
          'date': _dateController.text,
          'time': _timeController.text, // Added time field
          'guest': _guestController.text,
          'description': _descriptionController.text,
          'fees': _feesController.text,
          'type': _selectedType,
          'imagePaths': uploadedImageUrls,
          'creatorId': creatorId, // Added creatorId
        };

        // Add event to Firestore
        await FirebaseFirestore.instance.collection('events').add(newEvent);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );

        // Navigate to MainScreen and set the currentIndex to 1
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(
                currentIndex: 1), // Navigate to MainScreen with currentIndex
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image upload button
              _imagePaths.isEmpty
                  ? ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Upload Images'),
                    )
                  : SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            File(_imagePaths[index]),
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 16.0),

              // Event Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Location input with place predictions
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  suffixIcon: Icon(Icons.location_on),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _getPlacePredictions(value); // Fetch predictions
                  } else {
                    setState(() {
                      _placePredictions.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8.0),

              // Display the list of place predictions
              if (_placePredictions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _placePredictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _placePredictions[index];
                    return ListTile(
                      title: Text(prediction.description ?? ''),
                      onTap: () {
                        _selectPlace(prediction
                            .placeId!); // Fetch LatLng based on placeId
                      },
                    );
                  },
                ),
              const SizedBox(height: 16.0),

              // Date picker
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Time picker
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: _selectTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Guest input
              TextFormField(
                controller: _guestController,
                decoration: const InputDecoration(labelText: 'Special Guest'),
              ),
              const SizedBox(height: 16.0),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              // Fees input
              TextFormField(
                controller: _feesController,
                decoration: const InputDecoration(labelText: 'Fees'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Event Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: ['Conference', 'Workshop', 'Seminar', 'Webinar']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an event type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: _submitEvent,
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
