import 'package:flutter/material.dart';
import 'dart:async';

import 'package:docusign_flutter/docusign_flutter.dart';
import 'package:docusign_flutter/model/auth_model.dart';
import 'package:docusign_flutter/model/captive_signing_model.dart';

void main() {
  runApp(const MyApp());
}

const String accessToken = r'<<NEED_CHANGE>>';
const String accountId = r'<<NEED_CHANGE>>';
const String email = r'<<NEED_CHANGE>>';
const int expiresIn = 28800;
const String host = r'<<NEED_CHANGE>>';
const String integratorKey = r'<<NEED_CHANGE>>';
const String userId = r'<<NEED_CHANGE>>';
const String userName = r'<<NEED_CHANGE>>';

const String envelopeId = r'<<NEED_CHANGE>>';
const String recipientClientUserId = r'<<NEED_CHANGE>>';
const String recipientEmail = r'<<NEED_CHANGE>>';
const String recipientUserName = r'<<NEED_CHANGE>>';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _authStatus;
  bool? _signingStatus;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: [
            Text('Auth status: ${_convertStatus(_authStatus)}\n'),
            ElevatedButton(
              onPressed: () => _auth(),
              child: const Text('Auth'),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                    'Signing status: ${_convertStatus(_signingStatus)}\n')),
            ElevatedButton(
              onPressed: () => _captiveSign(),
              child: const Text('CaptiveSign'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _auth() async {
      var authModel = AuthModel(
          accessToken: accessToken,
          expiresIn: expiresIn,
          accountId: accountId,
          email: email,
          host: host,
          integratorKey: integratorKey,
          userId: userId,
          userName: userName,);
      var result = await DocusignFlutter.auth(authModel);
      setState(() {
        _authStatus = result;
      });
  }

  Future<void> _captiveSign() async {
    var result = false;
    try {
      var captiveSigningModel = CaptiveSigningModel(
        envelopeId: envelopeId,
        recipientClientUserId: recipientClientUserId,
        recipientEmail: recipientEmail,
        recipientUserName: recipientUserName,
      );
      await DocusignFlutter.captiveSigning(captiveSigningModel);
      result = true;
    } on Exception {
      result = false;
    }

    setState(() {
      _signingStatus = result;
    });
  }

  String _convertStatus(bool? status) {
    if (status != null) {
      return status ? 'success' : 'failed';
    }
    return 'none';
  }
}
