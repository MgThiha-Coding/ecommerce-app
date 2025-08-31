
class VerifyCodeRequest {
  final String emailOrPhone;
  final String verificationCode;
  final String deviceName;

  VerifyCodeRequest({
    required this.emailOrPhone,
    required this.verificationCode,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
        "email_or_phone": emailOrPhone,
        "verification_code": verificationCode,
        "device_name": deviceName,
      };
}
