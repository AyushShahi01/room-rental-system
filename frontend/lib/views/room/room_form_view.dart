import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/room_controller.dart';
import '../../controllers/landlord_dashboard_controller.dart';
import '../../models/room/room_detail_model.dart' as detail;
import '../../utils/api_error.dart';
import 'location_picker_view.dart';

class RoomFormView extends StatefulWidget {
  const RoomFormView({
    super.key,
    required this.isEditing,
    required this.onSubmit,
    this.initialRoom,
  });

  final bool isEditing;
  final detail.RoomDetailModel? initialRoom;
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
  final _agreementController = TextEditingController();

  String _rentMode = 'fixed';
  String _fixedDurationType = 'months';
  final _durationValueController = TextEditingController();
  final _initialRentController = TextEditingController();
  String _incrementEvery = 'monthly';
  String _incrementType = 'fixed_amount';
  final _increaseByController = TextEditingController();
  final _houseRulesController = TextEditingController();
  final _additionalDescriptionController = TextEditingController();

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
  double? _latitude;
  double? _longitude;
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];

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
      _agreementController.text = room.agreementPolicy ?? '';
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
      _latitude = double.tryParse(room.latitude?.toString() ?? '');
      _longitude = double.tryParse(room.longitude?.toString() ?? '');
      _agreementController.text = room.agreementPolicy ?? '';
      _rentMode = room.rentMode ?? 'fixed';
      _fixedDurationType = room.fixedDurationType ?? 'months';
      _durationValueController.text = room.fixedDurationValue?.toString() ?? '';
      _initialRentController.text = room.initialRent ?? '';
      _incrementEvery = room.incrementEvery ?? 'monthly';
      _incrementType = room.incrementType ?? 'fixed_amount';
      _increaseByController.text = room.increaseBy ?? '';
      _houseRulesController.text = room.houseRules ?? '';
      _additionalDescriptionController.text = room.additionalDescription ?? '';
    } else {
      _agreementController.text = '';
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
    _agreementController.dispose();
    _durationValueController.dispose();
    _initialRentController.dispose();
    _increaseByController.dispose();
    _houseRulesController.dispose();
    _additionalDescriptionController.dispose();
    super.dispose();
  }

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Room' : 'Add Room'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(colorScheme),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStepContent(colorScheme),
                    _buildNavigationButtons(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ColorScheme colorScheme) {
    final steps = [
      {'title': 'Basic', 'icon': Icons.description_outlined},
      {'title': 'Pricing', 'icon': Icons.payments_outlined},
      {'title': 'Agreement', 'icon': Icons.gavel_outlined},
      {'title': 'Location', 'icon': Icons.map_outlined},
      {'title': 'Images', 'icon': Icons.image_outlined},
      {'title': 'Facilities', 'icon': Icons.home_repair_service_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : (isActive ? colorScheme.primary : Colors.grey.shade100),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? colorScheme.primary
                                : (isCompleted ? Colors.green : Colors.grey.shade300),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : (step['icon'] as IconData),
                          color: isCompleted || isActive ? Colors.white : Colors.grey.shade500,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? colorScheme.primary
                              : (isCompleted ? Colors.green : Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 20,
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colorScheme) {
    switch (_currentStep) {
      case 0:
        return _sectionCard(
          title: 'Basic Details',
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
              'Province',
              controller: _provinceController,
              validator: _required,
            ),
            _buildTextField(
              'City / State',
              controller: _stateController,
              validator: _required,
            ),
            _buildTextField(
              'Ward Number',
              controller: _wardController,
              validator: (value) => _positiveNumber(value, label: 'Ward Number'),
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              'Area Sqft',
              controller: _areaController,
              validator: _optionalPositiveNumber,
              keyboardType: TextInputType.number,
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
              onChanged: (value) => setState(() => _gender = value ?? 'any'),
            ),
          ],
        );
      case 1:
        return _sectionCard(
          title: 'Pricing & Deposits',
          children: [
            _buildTextField(
              'Monthly Rent Price (Rs.)',
              controller: _priceController,
              validator: (value) => _positiveNumber(value, label: 'Price'),
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              'Security Deposit (Rs.)',
              controller: _depositController,
              validator: _optionalPositiveNumber,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              'Maintenance Charges (Rs.)',
              controller: _maintenanceController,
              validator: _optionalPositiveNumber,
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _sectionCard(
              title: 'Agreement',
              children: [
                _buildTextField(
                  'Agreement',
                  controller: _agreementController,
                  maxLines: 15,
                  hintText: 'Enter your house rules (e.g. no pets, quiet hours, guest policy), payment schedule, notice period, and any other relevant agreement terms here...',
                ),
              ],
            ),
          ],
        );

      case 3:
        return _sectionCard(
          title: 'Map & Coordinates',
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GPS Coordinates',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _latitude != null && _longitude != null
                                  ? 'Latitude: ${_latitude!.toStringAsFixed(6)}\nLongitude: ${_longitude!.toStringAsFixed(6)}'
                                  : 'No coordinates set. Tapping on the button below to pick a location on the Map.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.map),
                      label: Text(_latitude != null && _longitude != null
                          ? 'Change Map Location'
                          : 'Open Location Picker Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 4:
        return _sectionCard(
          title: 'Room Images',
          children: [
            if (widget.isEditing && widget.initialRoom?.images != null && widget.initialRoom!.images.isNotEmpty) ...[
              Text(
                'Existing Images',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.initialRoom!.images.length,
                  itemBuilder: (context, index) {
                    final img = widget.initialRoom!.images[index];
                    final url = img.image?.toString() ?? '';
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: url.startsWith('http')
                            ? Image.network(url, fit: BoxFit.cover)
                            : const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Select New Images to Upload',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (_selectedImages.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  final file = _selectedImages[index];
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(file, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Gallery Images'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            _sectionCard(
              title: 'Facilities',
              children: [
                SwitchListTile.adaptive(
                  value: _furnished,
                  title: const Text('Furnished'),
                  secondary: const Icon(Icons.chair_outlined),
                  onChanged: (value) => setState(() => _furnished = value),
                ),
                SwitchListTile.adaptive(
                  value: _wifi,
                  title: const Text('Wi-Fi / Internet'),
                  secondary: const Icon(Icons.wifi_outlined),
                  onChanged: (value) => setState(() => _wifi = value),
                ),
                SwitchListTile.adaptive(
                  value: _ac,
                  title: const Text('Air Conditioning (AC)'),
                  secondary: const Icon(Icons.ac_unit_outlined),
                  onChanged: (value) => setState(() => _ac = value),
                ),
                SwitchListTile.adaptive(
                  value: _bathroom,
                  title: const Text('Attached Bathroom'),
                  secondary: const Icon(Icons.bathtub_outlined),
                  onChanged: (value) => setState(() => _bathroom = value),
                ),
                SwitchListTile.adaptive(
                  value: _parking,
                  title: const Text('Parking Available'),
                  secondary: const Icon(Icons.local_parking_outlined),
                  onChanged: (value) => setState(() => _parking = value),
                ),
                SwitchListTile.adaptive(
                  value: _food,
                  title: const Text('Food / Mess Available'),
                  secondary: const Icon(Icons.restaurant_outlined),
                  onChanged: (value) => setState(() => _food = value),
                ),
                SwitchListTile.adaptive(
                  value: _water,
                  title: const Text('24/7 Water Supply'),
                  secondary: const Icon(Icons.water_drop_outlined),
                  onChanged: (value) => setState(() => _water = value),
                ),
                SwitchListTile.adaptive(
                  value: _waste,
                  title: const Text('Waste Collection'),
                  secondary: const Icon(Icons.delete_outline),
                  onChanged: (value) => setState(() => _waste = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Availability Status',
              children: [
                SwitchListTile.adaptive(
                  value: _available,
                  title: const Text('Active & Available for Rent'),
                  secondary: const Icon(Icons.check_circle_outline),
                  onChanged: (value) => setState(() => _available = value),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _currentStep == 5
                  ? (_isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined))
                  : const Icon(Icons.arrow_forward),
              label: Text(_currentStep == 5
                  ? (widget.isEditing ? 'Update Room' : 'Publish Room')
                  : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    switch (_currentStep) {
      case 0:
        if (_validateStep0()) {
          setState(() => _currentStep = 1);
        }
        break;
      case 1:
        if (_validateStep1()) {
          setState(() => _currentStep = 2);
        }
        break;
      case 2:
        if (_validateStep2()) {
          setState(() => _currentStep = 3);
        }
        break;
      case 3:
        if (_validateStep3()) {
          setState(() => _currentStep = 4);
        }
        break;
      case 4:
        if (_validateStep4()) {
          setState(() => _currentStep = 5);
        }
        break;
      case 5:
        _submit();
        break;
    }
  }

  Future<void> _pickImages() async {
    final pickedList = await _imagePicker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedList.map((x) => File(x.path)));
      });
    }
  }

  bool _validateStep0() {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Title is required');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Description is required');
      return false;
    }
    if (_provinceController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Province is required');
      return false;
    }
    if (_stateController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'City/State is required');
      return false;
    }
    final ward = int.tryParse(_wardController.text.trim());
    if (ward == null || ward <= 0) {
      Get.snackbar('Validation Error', 'Valid Ward Number is required');
      return false;
    }
    if (_areaController.text.trim().isNotEmpty) {
      final area = int.tryParse(_areaController.text.trim());
      if (area == null || area <= 0) {
        Get.snackbar('Validation Error', 'Area must be a positive number');
        return false;
      }
    }
    return true;
  }

  bool _validateStep1() {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar('Validation Error', 'Rent price must be a positive number');
      return false;
    }
    if (_depositController.text.trim().isNotEmpty) {
      final dep = double.tryParse(_depositController.text.trim());
      if (dep == null || dep <= 0) {
        Get.snackbar('Validation Error', 'Security deposit must be a positive number');
        return false;
      }
    }
    if (_maintenanceController.text.trim().isNotEmpty) {
      final maint = double.tryParse(_maintenanceController.text.trim());
      if (maint == null || maint <= 0) {
        Get.snackbar('Validation Error', 'Maintenance charges must be a positive number');
        return false;
      }
    }
    return true;
  }

  bool _validateStep2() {
    return true;
  }

  bool _validateStep3() {
    if (_latitude == null || _longitude == null) {
      Get.snackbar('Validation Error', 'GPS coordinate selection on map is required');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    return true;
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
    String? hintText,
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
          hintText: hintText,
          alignLabelWithHint: maxLines > 1,
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
      'agreement_policy': _agreementController.text.trim(),
      'rent_mode': _rentMode,
      'fixed_duration_type': _fixedDurationType,
      'fixed_duration_value': int.tryParse(_durationValueController.text.trim()),
      'initial_rent': double.tryParse(_initialRentController.text.trim())?.toStringAsFixed(2),
      'increment_every': _incrementEvery,
      'increment_type': _incrementType,
      'increase_by': double.tryParse(_increaseByController.text.trim())?.toStringAsFixed(2),
      'house_rules': _houseRulesController.text.trim(),
      'additional_description': _additionalDescriptionController.text.trim(),
    };

    if (_latitude != null) {
      data['latitude'] = _latitude;
    }
    if (_longitude != null) {
      data['longitude'] = _longitude;
    }

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
      if (widget.isEditing) {
        await widget.onSubmit(data);
        final roomId = widget.initialRoom?.id;
        if (roomId != null) {
          final roomController = Get.isRegistered<RoomController>() ? Get.find<RoomController>() : Get.put(RoomController());
          for (var imgFile in _selectedImages) {
            await roomController.uploadRoomImage(roomId, imgFile);
          }
        }
      } else {
        final roomController = Get.isRegistered<RoomController>() ? Get.find<RoomController>() : Get.put(RoomController());
        final createdRoom = await roomController.createRoom(data);
        if (createdRoom != null && createdRoom.id != null) {
          for (var imgFile in _selectedImages) {
            await roomController.uploadRoomImage(createdRoom.id!, imgFile);
          }
        }
        if (Get.isRegistered<LandlordDashboardController>()) {
          Get.find<LandlordDashboardController>().selectedIndex.value = 1;
        }
      }
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

  Future<void> _pickLocation() async {
    final initialLoc = _latitude != null && _longitude != null
        ? LatLng(_latitude!, _longitude!)
        : null;
    final result = await Get.to(() => LocationPickerView(initialLocation: initialLoc));
    if (result is LatLng) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }
}



