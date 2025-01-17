import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import this for FilteringTextInputFormatter

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false; // To show/hide the loading indicator
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isChecked = false; // Track the state of the checkbox

  // Function to handle the API call for top-up
  Future<void> topUpBalance(String amount, String cardNumber, String name, String expDate, String cvv) async {
    const String url = 'http://209.38.227.170:3000/users/topupBalance'; // Update to your API URL

    SharedPreferences prefs3 = await SharedPreferences.getInstance();
    String userId = prefs3.getString('id')!; // Throws an error if `id` is null

    Map<String, String> body = {
      '_id': userId,
      'amount': amount,
      'cardNumber': cardNumber,
      'name': name,
      'expDate': expDate,
      'cvv': cvv,
    };

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print(body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String newBalance = responseBody['userBalance'].toString();
        
        // Store the updated balance in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userBalance', newBalance);        
        
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful! New Balance: ${responseBody['userBalance']}')),
        );
        // Pop and return the new balance to the previous screen
        Navigator.pop(context, newBalance);    
      
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to format card number into groups of 4 digits
  String formatCardNumber(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-digit characters
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(cardNumber[i]);
    }
    return formatted.toString();
  }

  // Function to handle Expiration Date formatting (MM/YYYY)
  void handleExpDate(String value) {
    // Ensure the input stops after the correct number of characters (MM/YYYY)
    if (value.length > 7) return; // Stop any input once the length exceeds 7 characters (MM/YYYY)

    if (value.length == 2 && !value.contains('/')) {
      setState(() {
        _expDateController.text = value + '/';
        _expDateController.selection = TextSelection.collapsed(offset: _expDateController.text.length); // Place cursor at the end
      });
    } else if (value.length == 5 && value[2] != '/') {
      setState(() {
        _expDateController.text = value.substring(0, 2) + '/' + value.substring(3);
        _expDateController.selection = TextSelection.collapsed(offset: _expDateController.text.length); // Place cursor at the end
      });
    }
  }

  // Function to validate the CVV input
  String? validateCvv(String value) {
    if (value.isNotEmpty && value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Payment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount TextField with limit to 100000
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount of Charge',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number, // Ensure only number input
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    ],
                    onChanged: (value) {
                      if (int.tryParse(value) != null && int.parse(value) > 100000) {
                        setState(() {
                          _amountController.text = '100000';
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Card Number with formatting
                  TextField(
                    controller: _cardController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Remove non-digit characters and limit to 16 digits
                      String formattedValue = formatCardNumber(value.replaceAll(RegExp(r'[^0-9]'), ''));

                      // Ensure the card number doesn't exceed 16 digits
                      if (formattedValue.replaceAll(' ', '').length <= 16) {
                        setState(() {
                          _cardController.text = formattedValue;
                        });
                      } else {
                        setState(() {
                          _cardController.text = formattedValue.substring(0, 19); // Limit to 16 digits + spaces
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Name Input (Only Alphabetic Characters and Space)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ\s]'))
                    ],
                  ),
                  SizedBox(height: 16),

                  // Expiration Date Input
                  TextField(
                    controller: _expDateController,
                    decoration: InputDecoration(
                      labelText: 'Exp. Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: handleExpDate,
                  ),
                  SizedBox(height: 16),
                  // CVV Input (Hidden Digits) with TextFormField instead of TextField
                  TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true, // Hide CVV digits
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3), // Limit input to 3 digits
                    ],
                    onChanged: (value) {
                      // Ensure the CVV doesn't exceed 3 digits
                      if (value.length > 3) {
                        setState(() {
                          _cvvController.text = value.substring(0, 3); // Limit to 3 digits
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Terms and Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Terms of Service and understand that payment is final and non-refundable.',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Charge Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isChecked ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isChecked
                          ? () {
                              // Extract values from text controllers
                              String amount = _amountController.text;
                              String cardNumber = _cardController.text;
                              String name = _nameController.text;
                              String expDate = _expDateController.text;
                              String cvv = _cvvController.text;

                              if (amount.isEmpty || cardNumber.isEmpty || name.isEmpty || expDate.isEmpty || cvv.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill in all fields')),
                                );
                                return;
                              }

                              // Call the top-up function
                              topUpBalance(amount, cardNumber, name, expDate, cvv);
                            }
                          : null,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Charge',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Text(
              'Developed by SUDO',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
