import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/agreement_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/agreement/agreement_model.dart';

class AgreementDetailsView extends StatefulWidget {
  final int bookingId;
  final String roomName;
  final String roomImage;
  final String landlordName;
  final String tenantName;

  const AgreementDetailsView({
    super.key,
    required this.bookingId,
    required this.roomName,
    required this.roomImage,
    required this.landlordName,
    required this.tenantName,
  });

  @override
  State<AgreementDetailsView> createState() => _AgreementDetailsViewState();
}

class _AgreementDetailsViewState extends State<AgreementDetailsView> {
  // Use a per-booking tag so navigating to different bookings never serves
  // stale agreement data from a previous controller instance.
  late final AgreementController controller;
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _durationValueController = TextEditingController();
  final TextEditingController _initialRentController = TextEditingController();
  final TextEditingController _increaseByController = TextEditingController();
  final TextEditingController _houseRulesController = TextEditingController();
  final TextEditingController _additionalDescriptionController =
      TextEditingController();

  String _rentMode = 'Fixed';
  String _fixedDurationType = 'Months';
  String _incrementEvery = 'Monthly';
  String _incrementType = 'Fixed Amount';

  @override
  void initState() {
    super.initState();
    // Create (or retrieve) a controller keyed to this booking so that
    // multiple bookings never share stale agreement state.
    controller = Get.put(
      AgreementController(),
      tag: 'agreement_${widget.bookingId}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAgreementByBooking(widget.bookingId);
    });
  }

  @override
  void dispose() {
    _rentPriceController.dispose();
    _durationValueController.dispose();
    _initialRentController.dispose();
    _increaseByController.dispose();
    _houseRulesController.dispose();
    _additionalDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      // Compute role inside Obx so any role change triggers a rebuild.
      final role = authController.selectedRole.value.toLowerCase();
      final isLandlord = role == 'landlord' || role == 'admin';

      final agreement = controller.agreement.value;
      final isCreateMode = agreement == null && isLandlord;
      final title = isCreateMode ? 'Create Rental Agreement' : 'View Agreement';

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: Obx(() => _buildBody(isLandlord, colorScheme)),
      );
    });
  }

  Widget _buildBody(bool isLandlord, ColorScheme colorScheme) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.agreement.value == null &&
        !isLandlord) {
      return _buildErrorState(colorScheme);
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.agreement.value == null &&
        isLandlord) {
      return _buildErrorState(colorScheme);
    }

    final agreement = controller.agreement.value;

    if (agreement == null) {
      if (!isLandlord) {
        return _buildTenantEmptyState(colorScheme);
      }
      return _buildCreateAgreementForm(colorScheme);
    }

    return _buildViewAgreement(agreement, isLandlord, colorScheme);
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  controller.loadAgreementByBooking(widget.bookingId),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Agreement Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'The landlord has not created an agreement for this booking yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAgreementForm(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            colorScheme,
            title: 'SECTION 1: RENT DETAILS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labeledField(
                  label: 'Rent Price',
                  child: TextField(
                    controller: _rentPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: _inputDecoration(colorScheme, hint: 'Enter rent price'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rent Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Fixed'),
                  value: 'Fixed',
                  groupValue: _rentMode,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) => setState(() => _rentMode = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Increment'),
                  value: 'Increment',
                  groupValue: _rentMode,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) => setState(() => _rentMode = value!),
                ),
                if (_rentMode == 'Fixed') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Fixed Duration Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Months'),
                    value: 'Months',
                    groupValue: _fixedDurationType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setState(() => _fixedDurationType = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Years'),
                    value: 'Years',
                    groupValue: _fixedDurationType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setState(() => _fixedDurationType = value!),
                  ),
                  const SizedBox(height: 12),
                  _labeledField(
                    label: 'Duration Value',
                    child: TextField(
                      controller: _durationValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        colorScheme,
                        hint: _fixedDurationType == 'Months'
                            ? 'Example: 6 Months, 12 Months, 24 Months'
                            : 'Example: 1 Year, 2 Years',
                      ),
                    ),
                  ),
                ],
                if (_rentMode == 'Increment') ...[
                  const SizedBox(height: 16),
                  _labeledField(
                    label: 'Initial Rent',
                    child: TextField(
                      controller: _initialRentController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration:
                          _inputDecoration(colorScheme, hint: 'Enter initial rent'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Increment Every',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  ...[
                    'Monthly',
                    'Every 3 Months',
                    'Every 6 Months',
                    'Yearly',
                  ].map(
                    (option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _incrementEvery,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) =>
                          setState(() => _incrementEvery = value!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Increment Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Fixed Amount'),
                    value: 'Fixed Amount',
                    groupValue: _incrementType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setState(() => _incrementType = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Percentage'),
                    value: 'Percentage',
                    groupValue: _incrementType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) =>
                        setState(() => _incrementType = value!),
                  ),
                  const SizedBox(height: 12),
                  _labeledField(
                    label: 'Increase By',
                    child: TextField(
                      controller: _increaseByController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: _inputDecoration(
                        colorScheme,
                        hint: _incrementType == 'Fixed Amount'
                            ? 'Example: NPR 1000'
                            : 'Example: 10%',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            colorScheme,
            title: 'SECTION 2: HOUSE RULES',
            child: TextField(
              controller: _houseRulesController,
              maxLines: 8,
              decoration: _inputDecoration(
                colorScheme,
                hint:
                    'No smoking inside room.\nNo loud music after 10 PM.\nNo pets without permission.\nKeep room clean.\nReport maintenance through app.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            colorScheme,
            title: 'SECTION 3: ADDITIONAL DESCRIPTION',
            child: TextField(
              controller: _additionalDescriptionController,
              maxLines: 8,
              decoration: _inputDecoration(
                colorScheme,
                hint:
                    'Tenant must pay rent before the 5th of every month. Water and WiFi are included. Electricity is paid separately by the tenant.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Obx(() {
              if (controller.isSubmitting.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return FilledButton.icon(
                onPressed: _submitCreateAgreement,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Agreement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAgreement(
    AgreementModel agreement,
    bool isLandlord,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            colorScheme,
            title: 'Rent Details',
            child: Column(
              children: [
                _readOnlyRow('Rent Price', 'NPR ${agreement.rentPrice ?? '0'}'),
                const Divider(height: 24),
                _readOnlyRow('Rent Mode', _displayRentMode(agreement.rentMode)),
                if (agreement.rentMode == 'fixed') ...[
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Fixed Duration',
                    _displayFixedDuration(agreement),
                  ),
                ],
                if (agreement.rentMode == 'increment') ...[
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Initial Rent',
                    'NPR ${agreement.initialRent ?? '0'}',
                  ),
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Increment Every',
                    _displayIncrementEvery(agreement.incrementEvery),
                  ),
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Increment Type',
                    _displayIncrementType(agreement.incrementType),
                  ),
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Increase By',
                    _displayIncreaseBy(
                      agreement.incrementType,
                      agreement.increaseBy,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            colorScheme,
            title: 'House Rules',
            child: _readOnlyTextBlock(
              agreement.houseRules?.trim().isNotEmpty == true
                  ? agreement.houseRules!
                  : 'No house rules provided.',
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            colorScheme,
            title: 'Additional Description',
            child: _readOnlyTextBlock(
              agreement.additionalDescription?.trim().isNotEmpty == true
                  ? agreement.additionalDescription!
                  : 'No additional description provided.',
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            colorScheme,
            title: 'Agreement Status',
            child: Column(
              children: [
                _readOnlyRow('Agreement Status', agreement.agreementStatusLabel),
                if (isLandlord) ...[
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Tenant Signature Status',
                    agreement.isTenantSigned
                        ? 'Signed by Tenant'
                        : 'Pending',
                    valueColor: agreement.isTenantSigned
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  if (agreement.isTenantSigned) ...[
                    const SizedBox(height: 12),
                    _statusBanner(
                      'Signed by Tenant',
                      Colors.green.shade700,
                      Colors.green.shade50,
                    ),
                  ],
                ] else ...[
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Landlord Signature Status',
                    agreement.isLandlordSigned
                        ? 'Signed by Landlord'
                        : 'Pending',
                    valueColor: agreement.isLandlordSigned
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  if (agreement.isLandlordSigned) ...[
                    const SizedBox(height: 12),
                    _statusBanner(
                      'Signed by Landlord',
                      Colors.green.shade700,
                      Colors.green.shade50,
                    ),
                  ],
                  const Divider(height: 24),
                  _readOnlyRow(
                    'Tenant Signature Status',
                    agreement.isTenantSigned
                        ? 'Signed by Tenant'
                        : 'Pending',
                    valueColor: agreement.isTenantSigned
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  if (agreement.isTenantSigned) ...[
                    const SizedBox(height: 12),
                    _statusBanner(
                      'Signed by Tenant',
                      Colors.green.shade700,
                      Colors.green.shade50,
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (!isLandlord && !agreement.isTenantSigned) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(() {
                if (controller.isSubmitting.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return FilledButton.icon(
                  onPressed: _confirmAndSignAgreement,
                  icon: const Icon(Icons.edit_document),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  label: const Text(
                    'Sign Agreement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  void _submitCreateAgreement() {
    final rentPrice = _rentPriceController.text.trim();
    if (rentPrice.isEmpty) {
      Get.snackbar('Error', 'Rent Price is required.');
      return;
    }

    final payload = <String, dynamic>{
      'rent_price': rentPrice,
      'rent_mode': _rentMode == 'Fixed' ? 'fixed' : 'increment',
      'house_rules': _houseRulesController.text.trim(),
      'additional_description': _additionalDescriptionController.text.trim(),
    };

    if (_rentMode == 'Fixed') {
      final durationValue = int.tryParse(_durationValueController.text.trim());
      if (durationValue == null || durationValue <= 0) {
        Get.snackbar('Error', 'Duration Value is required for Fixed rent mode.');
        return;
      }
      payload['fixed_duration_type'] =
          _fixedDurationType == 'Months' ? 'months' : 'years';
      payload['fixed_duration_value'] = durationValue;
    } else {
      final initialRent = _initialRentController.text.trim();
      final increaseBy = _increaseByController.text.trim();
      if (initialRent.isEmpty) {
        Get.snackbar('Error', 'Initial Rent is required for Increment rent mode.');
        return;
      }
      if (increaseBy.isEmpty) {
        Get.snackbar('Error', 'Increase By is required for Increment rent mode.');
        return;
      }
      payload['initial_rent'] = initialRent;
      payload['increment_every'] = _mapIncrementEvery(_incrementEvery);
      payload['increment_type'] =
          _incrementType == 'Fixed Amount' ? 'fixed_amount' : 'percentage';
      payload['increase_by'] = increaseBy;
    }

    controller.createAgreement(widget.bookingId, payload);
  }

  void _confirmAndSignAgreement() {
    Get.defaultDialog(
      title: 'Sign Agreement',
      middleText:
          'By signing this agreement, you accept all the terms and conditions stated above.',
      textConfirm: 'Sign Now',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.signAgreement(widget.bookingId);
      },
    );
  }

  String _mapIncrementEvery(String value) {
    switch (value) {
      case 'Every 3 Months':
        return 'every_3_months';
      case 'Every 6 Months':
        return 'every_6_months';
      case 'Yearly':
        return 'yearly';
      default:
        return 'monthly';
    }
  }

  String _displayRentMode(String? value) {
    switch (value) {
      case 'fixed':
        return 'Fixed';
      case 'increment':
        return 'Increment';
      default:
        return value ?? 'N/A';
    }
  }

  String _displayFixedDuration(AgreementModel agreement) {
    final value = agreement.fixedDurationValue ?? 0;
    if (agreement.fixedDurationType == 'years') {
      return value == 1 ? '1 Year' : '$value Years';
    }
    return value == 1 ? '1 Month' : '$value Months';
  }

  String _displayIncrementEvery(String? value) {
    switch (value) {
      case 'monthly':
        return 'Monthly';
      case 'every_3_months':
        return 'Every 3 Months';
      case 'every_6_months':
        return 'Every 6 Months';
      case 'yearly':
        return 'Yearly';
      default:
        return value ?? 'N/A';
    }
  }

  String _displayIncrementType(String? value) {
    switch (value) {
      case 'fixed_amount':
        return 'Fixed Amount';
      case 'percentage':
        return 'Percentage';
      default:
        return value ?? 'N/A';
    }
  }

  String _displayIncreaseBy(String? incrementType, String? increaseBy) {
    if (increaseBy == null || increaseBy.isEmpty) return 'N/A';
    if (incrementType == 'percentage') {
      return '$increaseBy%';
    }
    return 'NPR $increaseBy';
  }

  Widget _sectionCard(
    ColorScheme colorScheme, {
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(ColorScheme colorScheme, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    );
  }

  Widget _readOnlyRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyTextBlock(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value,
        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _statusBanner(String text, Color textColor, Color backgroundColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: textColor),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
