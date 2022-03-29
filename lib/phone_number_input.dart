import 'package:extended_phone_number_input/consts/strings_consts.dart';
import 'package:extended_phone_number_input/widgets/country_code_list.dart';
import 'package:extended_phone_number_input/models/country.dart';
import 'package:extended_phone_number_input/phone_number_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberInput extends StatefulWidget {
  final PhoneNumberInputController? phoneNumberInputController;
  final String? initialValue;
  final String? initialCountry;
  final List<String>? excludedCountries;
  final List<String>? includedCountries;
  final bool allowPickFromContacts;
  final Widget? pickContactIcon;
  final void Function(String)? onChanged;
  final String? hint;
  final bool showSelectedFlag;
  final InputBorder? border;
  final String locale;
  final String? searchHint;
  final bool allowSearch;
  const PhoneNumberInput(
      {Key? key,
      this.phoneNumberInputController,
      this.onChanged,
      this.initialValue,
      this.initialCountry,
      this.excludedCountries,
      this.allowPickFromContacts = true,
      this.pickContactIcon,
      this.includedCountries,
      this.hint,
      this.showSelectedFlag = true,
      this.border,
      this.locale = 'en',
      this.searchHint,
      this.allowSearch = true})
      : super(key: key);

  @override
  _CountryCodePickerState createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<PhoneNumberInput> {
  late PhoneNumberInputController _phoneNumberInputController;
  late TextEditingController _phoneNumberTextFieldController;
  Country? _selectedCountry;

  @override
  void initState() {
    if (widget.phoneNumberInputController == null) {
      _phoneNumberInputController = PhoneNumberInputController(context,
          initialCountryCode: widget.initialCountry,
          excludeCountries: widget.excludedCountries,
          includeCountries: widget.includedCountries,
          initialPhoneNumber: widget.initialValue,
      locale: widget.locale);
    } else {
      _phoneNumberInputController = widget.phoneNumberInputController!;
      _phoneNumberInputController.selectValues(
          initialCountryCode: widget.initialCountry,
          excludeCountries: widget.excludedCountries,
          includeCountries: widget.includedCountries,
          initialPhoneNumber: widget.initialValue);
    }

    _phoneNumberTextFieldController = TextEditingController();


    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), _refresh);
    });
    _phoneNumberInputController.addListener(_refresh);

    super.initState();
  }

  void _refresh() {
    _phoneNumberTextFieldController.value = TextEditingValue(
        text: _phoneNumberInputController.phoneNumber,
        selection: TextSelection(
            baseOffset: _phoneNumberInputController.phoneNumber.length,
            extentOffset: _phoneNumberInputController.phoneNumber.length));

    setState(() {
      _selectedCountry = _phoneNumberInputController.selectedCountry;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_phoneNumberInputController.fullPhoneNumber);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: TextFormField(
          controller: _phoneNumberTextFieldController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.allow(kNumberRegex),
          ],
          onChanged: (v) {
            _phoneNumberInputController.innerPhoneNumber = v;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _phoneNumberInputController.validator,
          keyboardType: TextInputType.phone,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: widget.hint,
            border: widget.border,
            hintStyle: const TextStyle(color: Color(0xFFB6B6B6)),
            suffixIcon: Visibility(
              visible: widget.allowPickFromContacts,
              child: widget.pickContactIcon ??
                  IconButton(
                      onPressed: _phoneNumberInputController.pickFromContacts,
                      icon: Icon(
                        Icons.contact_phone,
                        color: Theme.of(context).primaryColor,
                      )),
            ),
            prefixIcon: InkWell(
              onTap: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enableDrag: true,
                    context: context,
                    builder: (_) => CountryCodeList(
                      searchHint: widget.searchHint,
                        allowSearch: widget.allowSearch,
                        phoneNumberInputController:
                            _phoneNumberInputController));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_drop_down),
                  if (_selectedCountry != null && widget.showSelectedFlag)
                    Image.asset(
                      _selectedCountry!.flagPath,
                      height: 12,
                    ),
                  const SizedBox(
                    width: 4,
                  ),
                  if (_selectedCountry != null)
                    Text(
                      _selectedCountry!.dialCode,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: const Color(0xFFB9BFC5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
