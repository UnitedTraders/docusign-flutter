import 'dart:async';
import 'dart:convert';

import 'package:docusign_flutter/model/captive_signing_model.dart';
import 'package:flutter/services.dart';

import 'model/auth_model.dart';

class DocusignFlutter {
  static const MethodChannel _channel = MethodChannel('docusign_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion', []);
    return version;
  }

  static Future<bool> auth(AuthModel authModel) async {
    String json = jsonEncode(authModel);
    final bool isOk = await _channel.invokeMethod('auth', [json]);
    return isOk;
  }

  static Future<void> captiveSigning(CaptiveSigningModel captiveSigningModel) async {
    String json = jsonEncode(captiveSigningModel);
    _channel.invokeMethod('captiveSinging', [json]);
  }
}
