import 'dart:async';
import 'dart:convert';

import 'package:docusign_flutter/model/captive_signing_model.dart';
import 'package:flutter/services.dart';

import 'model/auth_model.dart';

class DocusignFlutter {
  static const MethodChannel _channel = MethodChannel('docusign_flutter');

  static Future<bool> auth(AuthModel authModel) async {
    try {
      String json = jsonEncode(authModel);
      await _channel.invokeMethod('login', [json]);
      return true;
    } catch (exception) {
      return false;
    }
  }

  static Future<void> captiveSigning(CaptiveSigningModel captiveSigningModel) async {
    String json = jsonEncode(captiveSigningModel);
    await _channel.invokeMethod('captiveSinging', [json]);
  }
}
