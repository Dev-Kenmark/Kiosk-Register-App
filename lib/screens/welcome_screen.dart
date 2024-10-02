import 'package:flutter/material.dart';
import 'package:self_service_kiosk_app/screens/create_transaction.dart';
import 'package:self_service_kiosk_app/screens/transaction_details.dart';
import 'package:self_service_kiosk_app/theme/theme.dart';
import 'package:self_service_kiosk_app/widgets/custom_scaffold.dart';
import 'package:self_service_kiosk_app/widgets/welcome_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget
{
  const WelcomeScreen({super.key});

  Future<String> displayWelcomeMessage() async {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning!";
    } else if (hour >= 12 && hour < 18) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  Future<void> _getData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString('GivenName') ?? '';

    if (fullName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TransactionDetails()),
      );
    } else {
      // Show a dialog if no data is found
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Data Found'),
            content: const Text('Currently No Data Saved.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: FutureBuilder<String>(
                  future: displayWelcomeMessage(),
                  builder: (context, snapshot) {
                    String welcomeText = snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading...'  // Placeholder while loading
                        : '${snapshot.data ?? ''}\n\n';

                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: welcomeText,
                            style: const TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                              text: 'Welcome to Self Service Kiosk App\n',
                              style: TextStyle(
                                fontSize: 20,
                              )
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

            ),
          ),
           Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                   ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      foregroundColor: MaterialStateProperty.all(Colors.black), // Change text color to black
                      elevation: MaterialStateProperty.all(0), // Remove elevation
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      _getData(context);
                    },
                    child: const Text(
                      'Load Data',
                      style: TextStyle(
                          fontSize: 20,
                        fontWeight: FontWeight.w700,

                      ),
                    ),
                  ),
                  const Expanded(
                    child: WelcomeButton(
                        buttonText: 'Create Transaction',
                      onTap: CreateTransaction(),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
