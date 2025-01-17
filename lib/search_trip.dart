import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/trip_info.dart';
import 'pages/notifications.dart';

import 'package:intl/intl.dart';


class SearchTripPage extends StatefulWidget {
  const SearchTripPage({super.key});

  @override
  State<SearchTripPage> createState() => _SearchTripPageState();
}

class _SearchTripPageState extends State<SearchTripPage> {
  List<Map<String, dynamic>> _filteredTrips = [];
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Function to fetch trips based on Arrival, Departure, and Date
  Future<void> _fetchTrips() async {
    final arrivalLocation = _arrivalController.text;
    final departureLocation = _departureController.text;
    final date = _dateController.text;

    final url = Uri.parse('http://209.38.227.170:3000/trip/search-trips'); // Replace with your API endpoint

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'arrival': arrivalLocation,
          'departure': departureLocation,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        print("response.body:");
        print(response.body);

        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> tripsData = responseData['enrichedTrips'];

        setState(() {
          _filteredTrips = List<Map<String, dynamic>>.from(tripsData);
        });
      } else {
        // Handle error
        final errorMsg = json.decode(response.body)['msg'] ?? 'Error fetching trips';
        print(errorMsg);
      }
    } catch (error) {
      print("Error fetching trips: $error");
    }
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
              "Search Trips",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildSearchField(_departureController, 'Departure Location'),
            const SizedBox(height: 8),
            _buildSearchField(_arrivalController, 'Arrival Location'),
            const SizedBox(height: 8),
            _buildDateField(_dateController, context, 'Date'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchTrips(); // Fetch trips when clicked
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Search',
                style: GoogleFonts.inriaSans(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTrips.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _filteredTrips[index];
                        return GestureDetector(
                          onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripInfoPage(
                                departureTime: trip['time']?.toString() ?? 'N/A',
                                startLocation: trip['departure']?.toString() ?? 'N/A',
                                endLocation: trip['arrival']?.toString() ?? 'N/A',
                                date: DateFormat('EEEE, MMMM d, y').format(DateTime.parse(trip['date'])),
                                price: trip['price']?.toString() ?? '0',  // Convert to string
                                driverName: trip['driverName']?.toString() ?? 'Unknown',
                                rating: trip['rating']?.toString() ?? '0',  // Convert to string
                                seatsAvailable: trip['numberOfPassengers']?.toString() ?? '0',  // Convert to string
                                carDetails: 'N/A',
                              ),
                            ),
                          );
                          },
                          child: _buildLocationCard(trip),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No trips found. Please search.",
                        style: GoogleFonts.inriaSans(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(TextEditingController controller, String label) {
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
          setState(() {
            controller.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
    );
  }

Widget _buildLocationCard(Map<String, dynamic> trip) {
    return Card(
      color: const Color.fromARGB(255, 206, 234, 214),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocationRow(
                    trip['time'] ?? 'N/A', // Changed from departureTime
                    trip['departure'] ?? 'N/A'), // Changed from startLocation
                Text(
                  '${trip['price']} \$',
                  style: GoogleFonts.inriaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Column(
              children: [
                Icon(Icons.arrow_downward, size: 32, color: Colors.black54),
                SizedBox(height: 0),
              ],
            ),
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocationRow(
                    "             ", // Changed from arrivalTime
                    trip['arrival'] ?? 'N/A'), // Changed from endLocation
                Row(
                  children: [
                    Text(
                      '${trip['participants']?.length ?? 0}/${trip['numberOfPassengers'] ?? 0}', // Shows "0/3" for example
                      style: GoogleFonts.inriaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLocationRow(String time, String location) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: Colors.black54,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          time,
          style: GoogleFonts.inriaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.location_on,
          color: Colors.black54,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: GoogleFonts.inriaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
