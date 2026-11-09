import 'package:flutter/material.dart';
import 'package:gym_zero/shared/widgets/custom_text.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';

class NewMemberPayload {
  final String name;
  final int age;
  final int? durationMonths;
  final double? price;

  const NewMemberPayload({
    required this.name,
    required this.age,
    this.durationMonths,
    this.price,
  });
}

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (!_formKey.currentState!.validate()) return;

    final durationText = _durationController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(',', '.');

    final duration = durationText.isNotEmpty
        ? int.tryParse(durationText)
        : null;
    final price = priceText.isNotEmpty ? double.tryParse(priceText) : 0.0;

    Navigator.of(context).pop(
      NewMemberPayload(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        durationMonths: duration,
        price: price,
      ),
    );
  }

  String? _validateDuration(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty && _priceController.text.trim().isEmpty) return null;
    final duration = int.tryParse(text);
    if (duration == null || duration <= 0) {
      return 'Enter valid months';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty && _durationController.text.trim().isEmpty) return null;
    final price = double.tryParse(text.replaceAll(',', '.'));
    if (price == null || price < 0) return 'Enter a valid price';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeDark.secondary,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppThemeDark.borderPrimary),
      ),
      title: CustomText(
        text: 'Add Member',
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _nameController,
                  autofocus: true,
                  hintText: 'Name',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _ageController,
                  hintText: 'Age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final age = int.tryParse(value?.trim() ?? '');
                    return age == null || age <= 0 ? 'Enter a valid age' : null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    text: 'Subscription Details',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _durationController,
                        hintText: 'Duration (months)',
                        keyboardType: TextInputType.number,
                        validator: _validateDuration,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        hintText: 'Price',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePrice,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppThemeDark.primary),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveMember,
          style: FilledButton.styleFrom(
            backgroundColor: AppThemeDark.primary,
            foregroundColor: AppThemeDark.textPrimary,
          ),
          child: const Text(
            'Add member',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
