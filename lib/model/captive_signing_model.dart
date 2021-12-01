class CaptiveSigningModel {
  late final String envelopeId;
  late final String recipientUserName;
  late final String recipientEmail;
  late final String recipientClientUserId;

  CaptiveSigningModel({required this.envelopeId,
    required this.recipientUserName,
    required this.recipientEmail,
    required this.recipientClientUserId});

  CaptiveSigningModel.fromJson(Map<String, dynamic> json)
      : envelopeId = json['envelopeId'],
        recipientUserName = json['recipientUserName'],
        recipientEmail = json['recipientEmail'],
        recipientClientUserId = json['recipientClientUserId'];

  Map<String, dynamic> toJson() => {
    'envelopeId': envelopeId,
    'recipientUserName': recipientUserName,
    'recipientEmail': recipientEmail,
    'recipientClientUserId': recipientClientUserId,
  };
}