A Highly customizable Phone input Flutter widget that supports country code, validation and contact picker.

<p float="center">
  <img src="https://github.com/WahidNasri/extended_phone_number_input/blob/master/example/screenshots/01.gif" width="30%" />
  <img src="https://github.com/WahidNasri/extended_phone_number_input/blob/master/example/screenshots/02.gif" width="30%" /> 
  <img src="https://github.com/WahidNasri/extended_phone_number_input/blob/master/example/screenshots/03.gif" width="30%" />
</p>

## Features

- Phone number with international validation
- Include only specific countries
- Exclude specific countries
- Set a phone number using a controller (Selected country will be updated automatically)
- Pick a phone number from contacts list

## Getting started
Install the package `extended_phone_number_input`:
```
flutter pub add extended_phone_number_input
```
If you target Android 11+ (API 30+) and want to use the build-in contact picker you need to add the `android.permission.READ_CONTACTS` permission on the AndroidManifest.xml as this permission will be requested automatically.

## Usage
A full and rich example can be found in [`/example`](example/) folder.


### Simple usage
```dart
 PhoneNumberInput(initialCountry: 'SA', locale: 'ar')
```

### Show countries as dialog (default is bottom sheet)
```dart
 const PhoneNumberInput(
    initialCountry: 'US',
    locale: 'en',
    countryListMode: CountryListMode.dialog,
    contactsPickerPosition: ContactsPickerPosition.suffix,
    )
```

### Custom borders
```dart
 PhoneNumberInput(
    initialCountry: 'TN',
    locale: 'fr',
    countryListMode: CountryListMode.dialog,
    contactsPickerPosition: ContactsPickerPosition.suffix,
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.purple)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple))
    )
```

### Select Phone number programmatically
To be able to select a phone number programmatically, we first need to define a `PhoneInputController` :

```dart
PhoneInputController _controller = PhoneInputController(context);
```
```dart
 PhoneNumberInput(
     controller: _controller
    ...
```

Select the desired phone number:
```dart
_controller.phoneNumber = '+1-....'
```

#### Note: 
If you want to set the phone number from contact, The widget already support this feature without the need to use the controller.
