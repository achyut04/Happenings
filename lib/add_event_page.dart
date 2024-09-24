import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/api_services.dart';
import 'package:my_app/get_places.dart';
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
      'AIzaSyBLNERzXQj0brI3aiIr16DLXHAoy_Ggujo';

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

  Future<void> _getPlacePredictions(String input) async {
    try {
      ApiServices apiService = ApiServices();
      GetPlaces places =
          await apiService.getPlaces(input); 

      setState(() {
        _placePredictions = places.predictions ?? [];
      });
    } catch (e) {
      print('Error fetching place predictions: $e');
    }
  }

  Future<void> _selectPlace(String placeId) async {

    final String requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey';

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print('API Response Body: $responseBody');

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
          _placePredictions.clear();
        });
      } else {
        print('Error: Place details not found or missing geometry.');
      }
    } else {
      print('Error fetching place details: ${response.statusCode}');
    }
  }

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

  Future<void> _submitEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        String creatorId = user?.uid ?? '';

        List<String> uploadedImageUrls =
            await _uploadImagesToFirebase(_imagePaths);

        final newEvent = {
          'name': _nameController.text,
          'location': _locationController.text,
          'date': _dateController.text,
          'time': _timeController.text,
          'guest': _guestController.text,
          'description': _descriptionController.text,
          'fees': _feesController.text,
          'type': _selectedType,
          'imagePaths': uploadedImageUrls,
          'creatorId': creatorId,
        };

        await FirebaseFirestore.instance.collection('events').add(newEvent);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(currentIndex: 1),
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

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  suffixIcon: Icon(Icons.location_on),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _getPlacePredictions(value);
                  } else {
                    setState(() {
                      _placePredictions.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8.0),

              if (_placePredictions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _placePredictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _placePredictions[index];
                    return ListTile(
                      title: Text(prediction.description ?? ''),
                      onTap: () {
                        _selectPlace(prediction.placeId!);
                      },
                    );
                  },
                ),
              const SizedBox(height: 16.0),

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

              TextFormField(
                controller: _guestController,
                decoration: const InputDecoration(labelText: 'Special Guest'),
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _feesController,
                decoration: const InputDecoration(labelText: 'Fees'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

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
