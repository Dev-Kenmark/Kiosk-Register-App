import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:self_service_kiosk_app/screens/transaction_details.dart';
import 'package:self_service_kiosk_app/widgets/custom_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme.dart';
class CreateTransaction extends StatefulWidget {
  const CreateTransaction({super.key});

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}
enum Gender { male, female }

class _CreateTransactionState extends State<CreateTransaction> {

  final _formTransactionDetailsKey = GlobalKey<FormState>();
  bool isButtonDisabled = false; // Button state tracker
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();

  Gender? selectedGender;
  String surname = '';
  String? _selectedSuffix;
  String? _selectedCivilStatus;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Format the selected date and set it to the text field
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _updateData(String givenName, String middleName, String surName,
                           String suffix, String dateOfBirth, String contactNo,
                           String gender, String nationality, String civilStatus,
                           String address,) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('GivenName', givenName ?? '');
    await prefs.setString('MiddleName', middleName ?? '');
    await prefs.setString('Surname', surName ?? '');
    await prefs.setString('Suffix', suffix ?? '');
    await prefs.setString('DateOfBirth', dateOfBirth ?? '');
    await prefs.setString('ContactNo', contactNo ?? '');
    await prefs.setString('Gender', gender ?? '');
    await prefs.setString('Nationality', nationality ?? '');
    await prefs.setString('CivilStatus', civilStatus ?? '');
    await prefs.setString('Address', address ?? '');
  }

  String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return ''; // Handle null or empty case
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                    key: _formTransactionDetailsKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Transaction',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary
                          ),),
                        Text(
                          'Please enter your details',
                          style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: lightColorScheme.primary
                          ),),
                        const SizedBox(height: 30,),
                        TextFormField(
                          controller: _givenNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Given Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Given Name'),
                              hintText: 'Enter Given Name',
                              hintStyle: const TextStyle(
                                  color: Colors.black26
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _middleNameController,
                          validator: (value) {
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Middle Name'),
                              hintText: 'Enter Middle Name',
                              hintStyle: const TextStyle(
                                  color: Colors.black26
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _surnameController,
                          validator: (value) {
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Surname'),
                              hintText: 'Enter Surname',
                              hintStyle: const TextStyle(
                                  color: Colors.black26
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                        const SizedBox(height: 20,),
                        DropdownButtonFormField<String>(
                          value: _selectedSuffix,  // This is the currently selected suffix
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSuffix = newValue;  // Update the selected suffix
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a suffix';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Suffix'),
                            hintText: 'Select Suffix',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'NONE', child: Text('NONE')),
                            DropdownMenuItem(value: 'JR', child: Text('JR')),
                            DropdownMenuItem(value: 'SR', child: Text('SR')),
                            DropdownMenuItem(value: 'II', child: Text('II')),
                            DropdownMenuItem(value: 'III', child: Text('III')),
                            DropdownMenuItem(value: 'IV', child: Text('IV')),
                            DropdownMenuItem(value: 'V', child: Text('V')),
                            DropdownMenuItem(value: 'VI', child: Text('VI')),
                            DropdownMenuItem(value: 'VII', child: Text('VII')),
                          ],
                        ),

                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _dateOfBirthController,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            hintText: 'Select your date of birth',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        readOnly: true, // Prevents user from typing manually
                        onTap: () {
                        // When the field is tapped, show the date picker
                        _selectDate(context);
                        },
                        validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Please select a date';
                        }
                        return null;
                        },
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _contactNoController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Contact Number'),
                              hintText: 'Enter Contact Number',
                              hintStyle: const TextStyle(
                                  color: Colors.black26
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54, // Use color directly
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<Gender>(
                                  value: Gender.male,
                                  groupValue: selectedGender,
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),
                                const Text('Male'),
                              ],
                            ),
                            const SizedBox(width: 20), // Adds spacing between the options
                            Row(
                              children: [
                                Radio<Gender>(
                                  value: Gender.female,
                                  groupValue: selectedGender,
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),
                                const Text('Female'),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _nationalityController,
                          validator: (value) {
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Nationality'),
                              hintText: 'Enter Nationality',
                              hintStyle: const TextStyle(
                                  color: Colors.black26
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),

                        const SizedBox(height: 20,),
                        DropdownButtonFormField<String>(
                          value: _selectedCivilStatus,  // This is the currently selected suffix
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCivilStatus = newValue;  // Update the selected suffix
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a civil status';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Civil Status'),
                            hintText: 'Select Civil Status',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'SINGLE', child: Text('SINGLE')),
                            DropdownMenuItem(value: 'MARRIED', child: Text('MARRIED')),
                            DropdownMenuItem(value: 'WIDOWED', child: Text('WIDOWED')),
                            DropdownMenuItem(value: 'LEGALLY SEPARATED', child: Text('LEGALLY SEPARATED')),
                          ],
                        ),

                        const SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54, // Use color directly
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 5, // Allows multiple lines, adjust the number for the height you want
                          keyboardType: TextInputType.multiline, // Enables multiline input
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter Full Address',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(lightColorScheme.primary),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: isButtonDisabled ? null : () {
                              // Show confirmation dialog
                              FocusScope.of(context).unfocus();

                              showDialog(
                                context: context,
                                builder: (BuildContext contextConfirmation) {
                                  return AlertDialog(
                                    title: const Text('Confirm Transaction'),
                                    content: const Text('Are you sure you want to create this transaction?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(contextConfirmation).pop(); // Close the dialog
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(contextConfirmation).pop(); // Close the confirmation dialog

                                          // Show loading dialog
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext contextLoading) {
                                              return const AlertDialog(
                                                content: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(width: 20),
                                                    Text('Creating Transaction...'),
                                                  ],
                                                ),
                                              );
                                            },
                                          );

                                          _updateData(_givenNameController.text.toUpperCase(), _middleNameController.text.toUpperCase(),
                                              _surnameController.text.toUpperCase(), _selectedSuffix!.toUpperCase(),
                                              _dateOfBirthController.text.toUpperCase(), _contactNoController.text.toUpperCase(),
                                              capitalizeFirstLetter(selectedGender?.name).toUpperCase(), _nationalityController.text.toUpperCase(),
                                              _selectedCivilStatus!.toUpperCase(),_addressController.text.toUpperCase());

                                          // Use the `Future` directly with a callback to handle navigation
                                          Future.delayed(const Duration(seconds: 3), () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.of(context).pop(); // Close the loading dialog
                                            }

                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (e) => const TransactionDetails(),
                                              ), (Route<dynamic> route) => false, // Remove all previous routes
                                            );
                                          });
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: const Text('Submit'),
                          ),
                        ),




                      ],
                    )),
              ),
            ),
          ),
        ],
      ),

    );

  }
}
