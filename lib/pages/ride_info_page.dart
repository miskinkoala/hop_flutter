import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideInfoPage extends StatelessWidget {
  final String departureTime;
  final String startLocation;
  final String endLocation;
  final String date;
  final String price;
  final String driverName;
  final String rating;
  final String seatsAvailable;
  final String carDetails;

  const RideInfoPage({
    Key? key,
    required this.departureTime,
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.price,
    required this.driverName,
    required this.rating,
    required this.seatsAvailable,
    required this.carDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Ride Info",
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRideCard(),
            const SizedBox(height: 20),
            _buildDriverInfo(),
            const SizedBox(height: 10),
            _buildCarDetails(),
            const SizedBox(height: 30),
            _buildButtons(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Developed by SUDO",
                style: GoogleFonts.inriaSans(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 206, 234, 214),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocation(departureTime, startLocation),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      seatsAvailable,
                      style: GoogleFonts.inriaSans(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.arrow_downward, color: Colors.black54),
                SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocation(
                    '', endLocation), // You can adjust accordingly
              ],
            ),
            Text(
              "$date",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$price \$',
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLocation(String time, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          location,
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('images/logo.jpeg'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driverName,
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarDetails() {
    return Column(
      children: [
        _buildIconTextRow(Icons.directions_car, carDetails),
      ],
    );
  }

  Widget _buildIconTextRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inriaSans(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.message, color: Colors.white),
          label: const Text("Message Driver"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.report, color: Colors.white),
          label: const Text("Report Driver"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
     );
}
}