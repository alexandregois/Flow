class RefreshTokenException implements Exception {
  String cause;

  RefreshTokenException(this.cause);
}

class InstallationRefusedException implements Exception {
  String cause;

  InstallationRefusedException(this.cause);
}
