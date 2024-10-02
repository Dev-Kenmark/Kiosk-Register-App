import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:self_service_kiosk_app/screens/create_transaction.dart';
import 'package:self_service_kiosk_app/screens/welcome_screen.dart';
import 'package:self_service_kiosk_app/theme/theme.dart';
import 'package:self_service_kiosk_app/widgets/custom_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionDetails extends StatefulWidget {
  const TransactionDetails({super.key});
  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {

  final _formTransactionDetailsKey = GlobalKey<FormState>();
  final GlobalKey _qrKey = GlobalKey();
  bool isButtonDisabled = false; // Button state tracker
  dynamic externalDir = '/storage/emulated/0/Download';
  String? data;
  String? fullName;
  String? givenName, middleName, surName, suffix, dateOfBirth, contactNo, gender, nationality, civilStatus, address;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getData();
    setState(() {
      isLoading = false; // Set loading to false once data is loaded
    });
    data = await _getQRCode();
  }

  Future<void> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    givenName = prefs.getString('GivenName') ?? '';
    middleName = prefs.getString('MiddleName') ?? '';
    surName = prefs.getString('Surname') ?? '';
    suffix = prefs.getString('Suffix') ?? '';
    dateOfBirth = prefs.getString('DateOfBirth') ?? '';
    contactNo = prefs.getString('ContactNo') ?? '';
    gender = prefs.getString('Gender') ?? '';
    nationality = prefs.getString('Nationality') ?? '';
    civilStatus = prefs.getString('CivilStatus') ?? '';
    address = prefs.getString('Address') ?? '';

    fullName = '$givenName $middleName $surName';

    if(suffix == 'NONE')
    {
      suffix = '';
    }
    if(surName != '')
      {
        fullName = '$fullName $suffix';
      }
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('GivenName', '' ?? '');
    await prefs.setString('MiddleName', '' ?? '');
    await prefs.setString('Surname', '' ?? '');
    await prefs.setString('Suffix', '' ?? '');
    await prefs.setString('DateOfBirth', '' ?? '');
    await prefs.setString('ContactNo', '' ?? '');
    await prefs.setString('Gender', '' ?? '');
    await prefs.setString('Nationality', '' ?? '');
    await prefs.setString('CivilStatus', '' ?? '');
    await prefs.setString('Address', '' ?? '');
  }

  Future<String?> _getQRCode() async {
    final String qrCode = '$givenName|$middleName|$surName|$suffix|$dateOfBirth|$contactNo|$gender|$nationality|$civilStatus|$address';
    return qrCode;
  }


  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else {
      // Handle permission denial
      print("Storage permission denied");
    }
  }

  Future<void> _captureAndSavePng() async{
    try
    {
      await _requestPermissions(); // Request permissions

      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String formatDateTime(DateTime dateTime)
      {
        return '${dateTime.year}_${dateTime.month.toString().padLeft(2, '0')}_${dateTime.day.toString().padLeft(2, '0')}_'
            '${dateTime.hour.toString().padLeft(2, '0')}_${dateTime.minute.toString().padLeft(2, '0')}_'
            '${dateTime.second.toString().padLeft(2, '0')}';
      }

      String fileName = 'qr_code_${formatDateTime(DateTime.now())}.png';

      final file = await File('$externalDir/$fileName').create();
      await file.writeAsBytes(pngBytes);
      if(!mounted) return;
      const snackBarSaved = SnackBar(content: Text('QR Code saved to gallery'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarSaved);

    }
    catch(e)
    {
      if(!mounted) return;
      const snackBarSaved = SnackBar(content: Text('Something went wrong!!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarSaved);
    }
  }


  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); // Show loading indicator
    }

    return CustomScaffold(
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                // Show dialog when QR code is tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        // Close the dialog when tapped
                        Navigator.of(context).pop();
                      },
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur effect
                        child: Dialog(
                          backgroundColor: Colors.transparent, // Transparent background for the dialog
                          insetPadding: EdgeInsets.zero,
                          child: Center(
                            child: Container(
                              width: 350,  // Width of the QR code container
                              height: 350, // Height of the QR code container
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: QrImageView(
                                data: data ?? '',
                                size: 300, // QR size inside the dialog
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
                ),
                child: RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(data: data ?? ''),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10,),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                setState(() {
                  _captureAndSavePng();
                });
              },
              child: const Text(
                'Save QR Code',
                style: TextStyle(
                  fontSize: 15
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),

          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
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
                          'Transaction Details',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary
                          ),),
                        const SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600 ,
                              color: Colors.black, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            fullName ?? 'No name provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Birth Date',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dateOfBirth ?? 'No Date of Birth provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Contact Number',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            contactNo ?? 'No Contact Number provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            gender ?? 'No Gender provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Nationality',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            nationality ?? 'No Nationality provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Civil Status',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            civilStatus ?? 'No Civil Status provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),


                        const SizedBox(height: 5,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            address ?? 'No Address provided',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87, // Use color directly
                            ),
                          ),
                        ),

                        const SizedBox(height: 15,),


                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(

                            onPressed: () {
                              _resetData();
                              // Delay the navigation by 2 seconds
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const WelcomeScreen(),
                                ), (Route<dynamic> route) => false, // Remove all previous routes
                              );
                            },
                            child: const Text('Reset Details'),
                          ),
                        ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: ()
                        {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const WelcomeScreen(),
                            ), (Route<dynamic> route) => false, // Remove all previous routes
                          );
                        },
                        child: const Text('Go to Main Menu'),
                      ),
                    ),

                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                )
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              child: Text(
                                'Powered by Allcard',
                                style: TextStyle(
                                  color: Colors.black45
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                )
                            ),
                          ],
                        ),
                        const SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Logo(Logos.mastercard),
                            Logo(Logos.visa),
                            Logo(Logos.android),
                            Logo(Logos.apple),

                          ],
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
