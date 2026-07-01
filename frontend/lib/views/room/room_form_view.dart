import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/room/room_detail_model.dart';
import '../../utils/api_error.dart';

class RoomFormView extends StatefulWidget {
  const RoomFormView({
    super.key,
    required this.isEditing,
    required this.onSubmit,
    this.initialRoom,
  });

  final bool isEditing;
  final RoomDetailModel? initialRoom;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  @override
  State<RoomFormView> createState() => _RoomFormViewState();
}

class _RoomFormViewState extends State<RoomFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _provinceController = TextEditingController();
  final _stateController = TextEditingController();
  final _wardController = TextEditingController();
  final _areaController = TextEditingController();
  final _depositController = TextEditingController();
  final _maintenanceController = TextEditingController();

  bool _furnished = false;
  bool _wifi = false;
  bool _ac = false;
  bool _bathroom = false;
  bool _parking = false;
  bool _food = false;
  bool _water = false;
  bool _waste = false;
  bool _available = true;
  String _gender = 'any';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRoom != null) {
      final room = widget.initialRoom!;
      _titleController.text = room.title ?? '';
      _descriptionController.text = room.description ?? '';
      _priceController.text = room.price ?? '';
      _provinceController.text = room.province ?? '';
      _stateController.text = room.state ?? '';
      _wardController.text = room.wardNumber?.toString() ?? '';
      _areaController.text = room.areaSqft?.toString() ?? '';
      _depositController.text = room.securityDeposit ?? '';
      _maintenanceController.text = room.maintenanceCharges ?? '';
      _furnished = room.furnishedStatus ?? false;
      _wifi = room.hasWifi ?? false;
      _ac = room.hasAc ?? false;
      _bathroom = room.hasAttachedBathroom ?? false;
      _parking = room.parkingAvailable ?? false;
      _food = room.foodAvailable ?? false;
      _water = room.waterSupplyAvailable ?? false;
      _waste = room.wasteCollectionAvailable ?? false;
      _available = room.isAvailable ?? true;
      _gender = room.genderPreference ?? 'any';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _provinceController.dispose();
    _stateController.dispose();
    _wardController.dispose();
    _areaController.dispose();
    _depositController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Room' : 'Add Room'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(
                title: 'Room Details',
                children: [
                  _buildTextField(
                    'Room Title',
                    controller: _titleController,
                    validator: _required,
                  ),
                  _buildTextField(
                    'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    validator: _required,
                  ),
                  _buildTextField(
                    'Price',
                    controller: _priceController,
                    validator: (value) =>
                        _positiveNumber(value, label: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    'Province',
                    controller: _provinceController,
                    validator: _required,
                  ),
                  _buildTextField(
                    'State',
                    controller: _stateController,
                    validator: _required,
                  ),
                  _buildTextField(
                    'Ward Number',
                    controller: _wardController,
                    validator: (value) =>
                        _positiveNumber(value, label: 'Ward Number'),
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    'Area Sqft',
                    controller: _areaController,
                    validator: _optionalPositiveNumber,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    'Security Deposit',
                    controller: _depositController,
                    validator: _optionalPositiveNumber,
                  ),
                  _buildTextField(
                    'Maintenance Charges',
                    controller: _maintenanceController,
                    validator: _optionalPositiveNumber,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender Preference',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'any', child: Text('Any')),
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (value) =>
                        setState(() => _gender = value ?? 'any'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: _available,
                    title: const Text('Available for rent'),
                    onChanged: (value) => setState(() => _available = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Amenities',
                children: [
                  SwitchListTile.adaptive(
                    value: _furnished,
                    title: const Text('Furnished'),
                    onChanged: (value) => setState(() => _furnished = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _wifi,
                    title: const Text('Wi-Fi'),
                    onChanged: (value) => setState(() => _wifi = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _ac,
                    title: const Text('AC'),
                    onChanged: (value) => setState(() => _ac = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _bathroom,
                    title: const Text('Attached Bathroom'),
                    onChanged: (value) => setState(() => _bathroom = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _parking,
                    title: const Text('Parking'),
                    onChanged: (value) => setState(() => _parking = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _food,
                    title: const Text('Food Available'),
                    onChanged: (value) => setState(() => _food = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _water,
                    title: const Text('Water Supply'),
                    onChanged: (value) => setState(() => _water = value),
                  ),
                  SwitchListTile.adaptive(
                    value: _waste,
                    title: const Text('Waste Collection'),
                    onChanged: (value) => setState(() => _waste = value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(widget.isEditing ? 'Update Room' : 'Save Room'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _positiveNumber(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$label must be greater than 0';
    }
    return null;
  }

  String? _optionalPositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Must be greater than 0';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final priceValue = double.tryParse(_priceController.text.trim());
    final wardValue = int.tryParse(_wardController.text.trim());
    final areaValue = int.tryParse(_areaController.text.trim());
    final depositValue = double.tryParse(_depositController.text.trim());
    final maintenanceValue = double.tryParse(
      _maintenanceController.text.trim(),
    );

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': priceValue!.toStringAsFixed(2),
      'province': _provinceController.text.trim(),
      'state': _stateController.text.trim(),
      'ward_number': wardValue,
      'furnished_status': _furnished,
      'has_wifi': _wifi,
      'has_ac': _ac,
      'has_attached_bathroom': _bathroom,
      'parking_available': _parking,
      'food_available': _food,
      'water_supply_available': _water,
      'waste_collection_available': _waste,
      'gender_preference': _gender,
      'is_available': _available,
    };

    if (areaValue != null && areaValue > 0) {
      data['area_sqft'] = areaValue;
    }
    if (depositValue != null && depositValue > 0) {
      data['security_deposit'] = depositValue.toStringAsFixed(2);
    }
    if (maintenanceValue != null && maintenanceValue > 0) {
      data['maintenance_charges'] = maintenanceValue.toStringAsFixed(2);
    }

    try {
      await widget.onSubmit(data);
      if (mounted) Get.back();
    } on DioException catch (e) {
      if (mounted) {
        final message = extractApiErrorMessage(
          e,
          fallback: 'Failed to save room. Please check your input.',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save room: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
