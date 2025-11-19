// lib/screens/address/address_form.dart (Updated)

import 'package:flutter/material.dart';
import 'package:flutter_app/models/address_model.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/navigation_utils.dart'; 

class AddressForm extends StatefulWidget {
  final ShippingAddress initialAddress;
  final bool isEditing;
  final Function(ShippingAddress) onSave;

  AddressForm({
    super.key,
    required this.initialAddress,
    required this.onSave,
  }) : isEditing = initialAddress.id != null;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late ShippingAddress _currentAddress;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.initialAddress.copyWith();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(_currentAddress);
      NavigationUtils.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.isEditing ? 'Edit Shipping Address' : 'Add New Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              initialValue: _currentAddress.recipientName,
              label: 'Recipient Name',
              onSaved: (value) => _currentAddress = _currentAddress.copyWith(recipientName: value!),
            ),
            // --- Removed Recipient Phone field ---
            
            _buildTextFormField(
              initialValue: _currentAddress.streetAddress,
              label: 'Street Address', // Updated Label
              onSaved: (value) => _currentAddress = _currentAddress.copyWith(streetAddress: value!), // Updated Field
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    initialValue: _currentAddress.city,
                    label: 'City',
                    onSaved: (value) => _currentAddress = _currentAddress.copyWith(city: value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextFormField(
                    initialValue: _currentAddress.province,
                    label: 'Province', // Updated Label
                    onSaved: (value) => _currentAddress = _currentAddress.copyWith(province: value!), // Updated Field
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    initialValue: _currentAddress.zipCode,
                    label: 'ZIP Code',
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _currentAddress = _currentAddress.copyWith(zipCode: value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextFormField(
                    initialValue: _currentAddress.country,
                    label: 'Country',
                    onSaved: (value) => _currentAddress = _currentAddress.copyWith(country: value!),
                  ),
                ),
              ],
            ),
            
            // Checkbox for setting default, only if not currently default
            if (!widget.initialAddress.isDefault && !widget.isEditing) 
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SwitchListTile(
                  title: const Text('Set as default address'),
                  value: _currentAddress.isDefault,
                  onChanged: (bool value) {
                    setState(() {
                      _currentAddress = _currentAddress.copyWith(isDefault: value);
                    });
                  },
                ),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                widget.isEditing ? 'Update Address' : 'Save Address',
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // ... (TextFormField remains the same)
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}