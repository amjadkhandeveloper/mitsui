import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/utils/animations.dart';
import '../../../leave/presentation/widgets/date_time_input_field.dart';
import '../cubit/receipt_cubit.dart';
import '../../domain/entities/receipt.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fueledLitersController = TextEditingController();
  final _odometerReadingController = TextEditingController();

  ReceiptType _selectedType = ReceiptType.fuel;
  DateTime? _receiptDate;
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    _receiptDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _fueledLitersController.dispose();
    _odometerReadingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  void _submitReceipt() {
    if (_formKey.currentState!.validate()) {
      if (_receiptDate == null) {
        Toast.showError(context, 'Please select receipt date');
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null) {
        Toast.showError(context, 'Please enter a valid amount');
        return;
      }

      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        Toast.showError(context, 'Please enter description');
        return;
      }

      double? fueledLiters;
      if (_selectedType == ReceiptType.fuel && _fueledLitersController.text.isNotEmpty) {
        fueledLiters = double.tryParse(_fueledLitersController.text);
      }

      int? odometerReading;
      if (_selectedType == ReceiptType.fuel && _odometerReadingController.text.isNotEmpty) {
        odometerReading = int.tryParse(_odometerReadingController.text);
      }

      context.read<ReceiptCubit>().createReceipt(
            type: _selectedType,
            amount: amount,
            description: description,
            receiptDate: _receiptDate!,
            receiptImage: _receiptImage,
            fueledLiters: fueledLiters,
            odometerReading: odometerReading,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Fuel & Receipts'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<ReceiptCubit, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptCreated) {
            Navigator.pop(context);
          } else if (state is ReceiptError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ReceiptSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Date
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 100),
                    beginOffset: const Offset(0, 0.2),
                    child: DateTimeInputField(
                      label: 'Receipt Date',
                      value: _receiptDate,
                      isDate: true,
                      onTap: (date) {
                        setState(() {
                          _receiptDate = date;
                        });
                      },
                    ),
                  ),
                  // Receipt Type
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 150),
                    beginOffset: const Offset(0, 0.2),
                    child: StyledCard(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.local_gas_station),
                                    title: const Text('Fuel'),
                                    onTap: () {
                                      setState(() {
                                        _selectedType = ReceiptType.fuel;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.local_parking),
                                    title: const Text('Parking'),
                                    onTap: () {
                                      setState(() {
                                        _selectedType = ReceiptType.parking;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.toll),
                                    title: const Text('Toll'),
                                    onTap: () {
                                      setState(() {
                                        _selectedType = ReceiptType.toll;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.receipt),
                                    title: const Text('Other'),
                                    onTap: () {
                                      setState(() {
                                        _selectedType = ReceiptType.other;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Icon(
                                _selectedType == ReceiptType.fuel
                                    ? Icons.local_gas_station
                                    : _selectedType == ReceiptType.parking
                                        ? Icons.local_parking
                                        : _selectedType == ReceiptType.toll
                                            ? Icons.toll
                                            : Icons.receipt,
                                color: AppTheme.mitsuiBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedType == ReceiptType.fuel
                                      ? 'Fuel'
                                      : _selectedType == ReceiptType.parking
                                          ? 'Parking'
                                          : _selectedType == ReceiptType.toll
                                              ? 'Toll'
                                              : 'Other',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Amount
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 200),
                    beginOffset: const Offset(0, 0.2),
                    child: StyledCard(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // Fueled Liters (only for Fuel type)
                  if (_selectedType == ReceiptType.fuel)
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 250),
                      beginOffset: const Offset(0, 0.2),
                      child: StyledCard(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: _fueledLitersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fueled Liters',
                            prefixIcon: const Icon(Icons.local_gas_station),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Odometer Reading (only for Fuel type)
                  if (_selectedType == ReceiptType.fuel)
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      beginOffset: const Offset(0, 0.2),
                      child: StyledCard(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: _odometerReadingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Odometer Reading (km)',
                            prefixIcon: const Icon(Icons.speed),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Description
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 350),
                    beginOffset: const Offset(0, 0.2),
                    child: StyledCard(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // Receipt Image
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 400),
                    beginOffset: const Offset(0, 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Receipt Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StyledCard(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _receiptImage != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            _receiptImage!,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                _receiptImage = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to add receipt image',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 500),
                    beginOffset: const Offset(0, 0.2),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submitReceipt,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Submit Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

