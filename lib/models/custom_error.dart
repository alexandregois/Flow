class CustomError {
  bool success;
  int messageCode;
  String messageText;

  CustomError({
    this.success,
    this.messageCode,
    this.messageText,
  });

  factory CustomError.fromJson(Map<String, dynamic> json) {
    return json == null || json.isEmpty
        ? null
        : CustomError(
            success: json['success'],
            messageCode: json['messageCode'],
            messageText: json['messageText']);
  }
}
