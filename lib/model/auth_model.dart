class AuthModel {
  late final String accessToken;
  late final String accountId;
  late final String userId;
  late final String userName;
  late final String email;
  late final String host;
  late final String integratorKey;

  AuthModel({required this.accessToken,
    required this.accountId,
    required this.userId,
    required this.userName,
    required this.email,
    required this.host,
    required this.integratorKey,});

  AuthModel.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        accountId = json['accountId'],
        userId = json['userId'],
        userName = json['userName'],
        email = json['email'],
        host = json['host'],
        integratorKey = json['integratorKey'];

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'accountId': accountId,
    'userId': userId,
    'userName': userName,
    'email': email,
    'host': host,
    'integratorKey': integratorKey,
  };
}