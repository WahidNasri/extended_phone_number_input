import 'package:extended_phone_number_input/consts/enums.dart';
import 'package:extended_phone_number_input/phone_number_controller.dart';
import 'package:extended_phone_number_input/phone_number_input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Phone Number Input'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text('bottom sheet mode'),
              const PhoneNumberInput(
                initialCountry: 'SA',
                locale: 'it',
                countryListMode: CountryListMode.bottomSheet,
                contactsPickerPosition: ContactsPickerPosition.suffix,
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('dialog mode'),
              const PhoneNumberInput(
                initialCountry: 'SA',
                locale: 'it',
                countryListMode: CountryListMode.dialog,
                contactsPickerPosition: ContactsPickerPosition.suffix,
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('custom border & custom controller'),
              PhoneNumberInput(
                initialCountry: 'TN',
                locale: 'ar',
                controller: PhoneNumberInputController(
                  context,
                ),
                countryListMode: CountryListMode.dialog,
                contactsPickerPosition: ContactsPickerPosition.suffix,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.purple)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.purple)),
                errorText: 'error',
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('bottom picker widget with custom widget'),
              const PhoneNumberInput(
                initialCountry: 'YE',
                locale: 'it',
                countryListMode: CountryListMode.dialog,
                contactsPickerPosition: ContactsPickerPosition.bottom,
                pickContactIcon: Card(
                  color: Colors.blueGrey,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'select from contacts',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('custom picker icon , no flag, hint'),
              const PhoneNumberInput(
                locale: 'it',
                countryListMode: CountryListMode.bottomSheet,
                contactsPickerPosition: ContactsPickerPosition.suffix,
                pickContactIcon: Icon(Icons.add),
                showSelectedFlag: false,
                hint: 'XXXXXXXXXXX',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
