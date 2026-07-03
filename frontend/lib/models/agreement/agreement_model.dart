import 'agreement_json_utils.dart';

class AgreementModel {  AgreementModel({
    required this.id,
    required this.booking,
    required this.content,
    required this.rentPrice,
    required this.rentMode,
    required this.fixedDurationType,
    required this.fixedDurationValue,
    required this.initialRent,
    required this.incrementEvery,
    required this.incrementType,
    required this.increaseBy,
    required this.houseRules,
    required this.additionalDescription,
    required this.landlordIsSigned,
    required this.landlordSignedAt,
    required this.isSigned,
    required this.signedAt,
    required this.createdAt,
  });

  final int? id;
  final int? booking;
  final String? content;
  final String? rentPrice;
  final String? rentMode;
  final String? fixedDurationType;
  final int? fixedDurationValue;
  final String? initialRent;
  final String? incrementEvery;
  final String? incrementType;
  final String? increaseBy;
  final String? houseRules;
  final String? additionalDescription;
  final bool? landlordIsSigned;
  final DateTime? landlordSignedAt;
  final bool? isSigned;
  final DateTime? signedAt;
  final DateTime? createdAt;

  bool get isTenantSigned => isSigned == true;
  bool get isLandlordSigned => landlordIsSigned == true;

  String get agreementStatusLabel =>
      isTenantSigned ? 'Signed' : 'Pending Tenant Signature';

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      id: parseAgreementId(json['id']),
      booking: parseAgreementId(json['booking']),
      content: parseAgreementString(json['content']),
      rentPrice: parseAgreementString(json['rent_price']),
      rentMode: parseAgreementString(json['rent_mode']),
      fixedDurationType: parseAgreementString(json['fixed_duration_type']),
      fixedDurationValue: parseAgreementId(json['fixed_duration_value']),
      initialRent: parseAgreementString(json['initial_rent']),
      incrementEvery: parseAgreementString(json['increment_every']),
      incrementType: parseAgreementString(json['increment_type']),
      increaseBy: parseAgreementString(json['increase_by']),
      houseRules: parseAgreementString(json['house_rules']),
      additionalDescription: parseAgreementString(json['additional_description']),
      landlordIsSigned: parseAgreementBool(json['landlord_is_signed']),
      landlordSignedAt: DateTime.tryParse(json['landlord_signed_at']?.toString() ?? ''),
      isSigned: parseAgreementBool(json['is_signed']),
      signedAt: DateTime.tryParse(json['signed_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }}
