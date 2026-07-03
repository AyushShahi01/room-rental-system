int? parseAgreementId(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) return parseAgreementId(value['id']);
  return int.tryParse(value.toString());
}

bool? parseAgreementBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value == 1 || value == '1' || value == 'true') return true;
  if (value == 0 || value == '0' || value == 'false') return false;
  return null;
}

String? parseAgreementString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return null;
  return str;
}
