/// Utility class for mapping email addresses to usernames.
class UsernameMapper {
  /// Maps an email to a username by trimming, lowercasing, and replacing '@' and '.' with '_'.
  static String emailToUsername(String email) {
    return email
        .trim()
        .toLowerCase()
        .replaceAll('@', '_')
        .replaceAll('.', '_');
  }

  /// Best-effort friendly display name from a Cognito username or email.
  static String displayNameFrom(String usernameOrEmail) {
    final trimmed = usernameOrEmail.trim();
    if (trimmed.isEmpty) return 'Traveller';

    if (trimmed.contains('@')) {
      return _titleCase(trimmed.split('@').first.replaceAll('.', ' '));
    }

    // Cognito usernames created via [emailToUsername], e.g. travellyapp_qut_gmail_com.
    final localPart = trimmed.split('_').first;
    if (localPart.isNotEmpty) {
      return _titleCase(localPart);
    }
    return trimmed;
  }

  static String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}