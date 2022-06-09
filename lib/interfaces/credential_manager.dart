abstract class CredentialManager {
  void save(credentials);

  String restore();

  bool hasCredentials();

  void removeCredentials();
}
