import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _passengerController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _autoApproval = false;
  List<String> _stops = []; // Store stops as a list

  final List<String> _cityOptions = [
    'Arnavutköy',
    'Ataşehir',
    'Avcılar',
    'Bağcılar',
    'Bakırköy',
    'Bayrampaşa',
    'Beşiktaş',
    'Beykoz',
    'Beylikdüzü',
    'Beyoğlu',
    'Bostancı',
    'Büyükçekmece',
    'Çekmeköy',
    'Derince',
    'Dilovası',
    'Dudullu',
    'Esenler',
    'Esenyurt',
    'Eyüp',
    'Fatih',
    'Gebze',
    'Gölcük',
    'Güngören',
    'Kadıköy',
    'Kartal',
    'Maltepe',
    'Pendik',
    'Sarıyer',
    'Silivri',
    'Şişli',
    'Tuzla',
    'Üsküdar',
    'Ümraniye',
    'Zeytinburnu',
  ];

  List<String> _filteredCityOptions = [];
  bool _isDepartureFocused = false;
  bool _isArrivalFocused = false;

  void _validateAndSubmit() async {
    // Validate that required fields are filled
    if (_departureController.text.isNotEmpty &&
        _arrivalController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _passengerController.text.isNotEmpty &&
        _priceController.text.isNotEmpty) {
      // Collect field values
      String departure = _departureController.text;
      String arrival = _arrivalController.text;
      List<String> stops = _stops; // Use the _stops list directly
      String date = _dateController.text;
      String time = _timeController.text;
      int numberOfPassengers = int.parse(_passengerController.text);
      int price = int.parse(_priceController.text);
      bool autoApproval = _autoApproval;

      const String url = 'http://209.38.227.170:3000/trip/create-trip';

      try {
        SharedPreferences prefs2 = await SharedPreferences.getInstance();
        String? id = prefs2.getString('id'); // Retrieve the user ID
        if (id == null) {
          _showErrorPopup('User ID not found. Please log in again.');
          return;
        }

        // Send HTTP POST request
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "userId": id, // Include user ID
            "departure": departure,
            "arrival": arrival,
            "stops": stops, // Include the list of stops
            "date": date,
            "time": time,
            "numberOfPassengers": numberOfPassengers,
            "price": price,
            "autoApproval": autoApproval,
          }),
        );

        // Check response status
        if (response.statusCode == 201) {
          _showSuccessPopup();
        } else {
          final errorResponse = json.decode(response.body);
          _showErrorPopup(errorResponse['msg'] ?? 'Failed to create trip.');
        }
      } catch (error) {
        // Handle network or unexpected errors
        _showErrorPopup('An unexpected error occurred: $error');
      }
    } else {
      // If validation fails, show error popup
      _showErrorPopup('Please fill in all required fields.');
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Success!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: const Text('Trip Created Successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                _resetPage();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Error!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(message), // Display the dynamic error message
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetPage() {
    setState(() {
      _departureController.clear();
      _arrivalController.clear();
      _dateController.clear();
      _timeController.clear();
      _passengerController.clear();
      _priceController.clear();
      _autoApproval = false;
      _stops.clear();
    });
  }

  void _openStopsModal() {
    TextEditingController stopController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stopController,
                decoration: InputDecoration(
                  labelText: 'Add a stop',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (stopController.text.isNotEmpty) {
                    setState(() {
                      _stops.add(stopController.text);
                    });
                    Navigator.pop(context); // Close modal after adding the stop
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Stop',
                  style: TextStyle(
                      color: Colors.white), // Change the text color here
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredCityOptions = _cityOptions;
  }

  void _onDepartureInputChanged(String query) {
    setState(() {
      _filteredCityOptions = _cityOptions
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onArrivalInputChanged(String query) {
    setState(() {
      _filteredCityOptions = _cityOptions
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildLocationInput({
    required String label,
    required TextEditingController controller,
    required bool isFocused,
    required void Function(String) onChanged,
    required Function(String) onSelectLocation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
          onChanged: onChanged,
          onTap: () {
            setState(() {
              _isDepartureFocused = label == "Departure...";
              _isArrivalFocused = label == "Arrival...";
            });
          },
        ),
        if (isFocused)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _filteredCityOptions.length,
              itemBuilder: (context, index) {
                final city = _filteredCityOptions[index];
                return ListTile(
                  title: Text(city),
                  onTap: () {
                    onSelectLocation(city);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromARGB(255, 13, 95, 31)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
            toolbarHeight: 30,
            title: Text(
              "Create Trip",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromARGB(255, 13, 95, 31),
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLocationInput(
              label: 'Departure...',
              controller: _departureController,
              isFocused: _isDepartureFocused,
              onChanged: _onDepartureInputChanged,
              onSelectLocation: (location) {
                _departureController.text = location;
                setState(() {
                  _isDepartureFocused = false;
                });
              },
            ),
            const SizedBox(height: 10),
            _buildLocationInput(
              label: 'Arrival...',
              controller: _arrivalController,
              isFocused: _isArrivalFocused,
              onChanged: _onArrivalInputChanged,
              onSelectLocation: (location) {
                _arrivalController.text = location;
                setState(() {
                  _isArrivalFocused = false;
                });
              },
            ),
            if (_stops.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Stops:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ..._stops.asMap().entries.map((entry) {
                    int index = entry.key;
                    String stop = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stop,
                          style: const TextStyle(fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _stops.removeAt(
                                  index); // Remove the stop from the list
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                ],
              ),
            ElevatedButton(
              onPressed: _openStopsModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 144, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Stops',
                style: TextStyle(
                    color: Colors.white), // Change the text color here
              ),
            ),
            const SizedBox(height: 10),
            _buildDateField(_dateController, context, 'Date'),
            const SizedBox(height: 10),
            _buildTimeField(_timeController, context, 'Time'),
            const SizedBox(height: 10),
            _buildTextField(_passengerController, 'Passengers (e.g., 1)'),
            const SizedBox(height: 10),
            _buildTextField(_priceController, 'Price (e.g., 1)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _autoApproval,
                  onChanged: (value) {
                    setState(() {
                      _autoApproval = value!;
                    });
                  },
                  activeColor: Colors.green,
                ),
                const Text("Auto Approval"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.inriaSans(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, BuildContext context, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toLocal().toString().split(' ')[0];
        }
      },
    );
  }

  Widget _buildTimeField(
      TextEditingController controller, BuildContext context, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.access_time, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          controller.text = pickedTime.format(context);
        }
     },
  );
}
}