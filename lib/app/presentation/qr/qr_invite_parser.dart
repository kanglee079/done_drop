class ParsedQrInvite {
  const ParsedQrInvite({this.uid, this.code, this.name});

  final String? uid;
  final String? code;
  final String? name;

  bool get hasUid => uid != null && uid!.isNotEmpty;
  bool get hasCode => code != null && code!.isNotEmpty;
}

ParsedQrInvite? parseQrInvite(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.scheme == 'donedrop' && uri.host == 'add') {
    final uid = normalizeInviteUid(uri.queryParameters['uid']);
    final code = normalizeInviteCode(uri.queryParameters['code']);
    final name = uri.queryParameters['name']?.trim();

    if (uid == null && code == null) {
      return null;
    }

    return ParsedQrInvite(
      uid: uid,
      code: code,
      name: name == null || name.isEmpty ? null : name,
    );
  }

  final uid = normalizeInviteUid(trimmed);
  if (uid != null) {
    return ParsedQrInvite(uid: uid);
  }

  final code = normalizeInviteCode(trimmed);
  if (code != null) {
    return ParsedQrInvite(code: code);
  }

  return null;
}

String? normalizeInviteCode(String? value) {
  if (value == null) return null;
  final normalized = value
      .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
      .toUpperCase()
      .trim();
  if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(normalized)) {
    return null;
  }
  return normalized;
}

String? normalizeInviteUid(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (!RegExp(r'^[A-Za-z0-9]{20,}$').hasMatch(trimmed)) {
    return null;
  }
  return trimmed;
}
