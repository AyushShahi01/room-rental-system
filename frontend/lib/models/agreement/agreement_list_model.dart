import 'agreement_json_utils.dart';
import 'agreement_model.dart';
class AgreementListModel {
  AgreementListModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int? count;
  final dynamic next;
  final dynamic previous;
  final List<Result> results;

  factory AgreementListModel.fromJson(Map<String, dynamic> json) {
    return AgreementListModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] == null
          ? []
          : List<Result>.from(json['results']!.map((x) => Result.fromJson(x))),
    );
  }
}

class Result {
  Result({
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

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
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
  }
  AgreementModel toAgreementModel() {
    return AgreementModel(
      id: id,
      booking: booking,
      content: content,
      rentPrice: rentPrice,
      rentMode: rentMode,
      fixedDurationType: fixedDurationType,
      fixedDurationValue: fixedDurationValue,
      initialRent: initialRent,
      incrementEvery: incrementEvery,
      incrementType: incrementType,
      increaseBy: increaseBy,
      houseRules: houseRules,
      additionalDescription: additionalDescription,
      landlordIsSigned: landlordIsSigned,
      landlordSignedAt: landlordSignedAt,
      isSigned: isSigned,
      signedAt: signedAt,
      createdAt: createdAt,
    );
  }
}
