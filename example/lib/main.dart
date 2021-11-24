import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:docusign_flutter/docusign_flutter.dart';
import 'package:docusign_flutter/model/auth_model.dart';
import 'package:docusign_flutter/model/captive_signing_model.dart';

void main() {
  runApp(const MyApp());
}

const String accessToken = r'eyJ0eXAiOiJNVCIsImFsZyI6IlJTMjU2Iiwia2lkIjoiNjgxODVmZjEtNGU1MS00Y2U5LWFmMWMtNjg5ODEyMjAzMzE3In0.AQsAAAABAAUABwAANbf4rK7ZSAgAAHXaBvCu2UgCAAJ3ltDYvipBiNPp15RDK8cVAAEAAAAYAAEAAAAFAAAADQAkAAAAYzk3NzhhY2ItODE4MC00YWNjLWExNjgtM2QxOGRiOTgyZDBmIgAkAAAAYzk3NzhhY2ItODE4MC00YWNjLWExNjgtM2QxOGRiOTgyZDBmEgABAAAACwAAAGludGVyYWN0aXZlMAAAlZHSrK7ZSDcA7nTvijZbqEOtjvAIVQg5pA.vbpxFErKq1cByFynIO8ONpFFZgQpXfDy7-gXjK6Y60zvbY9xxogKqWaVkCU5aAxrkz1j37deYQefL1gZjlCenraL-_snOjjRDRw0H7omGTx-QHSC_KQ7aE8jFqQs5R0iL8csOJgsNJl086_kLbh_z-n2mZkArzlqPc4CGP8MNK3d9PUc8l5z6vvK-SYJIC48StT-tip-OFGDHrpcB-Wv1DB4xVBzkVcbm0FbOCkUCybKhoeLRwKRp2l_8YKz8bWxH_ouYHrqQpNcHbCZDkMCt0DTmCfWtd233yxPZ84h2trHchzuIw9UvmIpo4P2v_J9o6QnNFmfRauj1Spr9cqaIg';
const String accountId = r'41cf0617-a663-4373-b1f1-3abfc2f80afe';
const String email = r'alik@dizraptor.app';
const String host = r'https://demo.docusign.net/restapi';
const String integratorKey = r'c9778acb-8180-4acc-a168-3d18db982d0f';
const String userId = r'd0967702-bed8-412a-88d3-e9d794432bc7';
const String userName = r'Dizraptor';

const String envelopeId = r'050431d9-7981-4f2b-a621-3699ea0036be';
const String recipientClientUserId = r'1000';
const String recipientEmail = r'dilerarc15@gmail.com';
const String recipientUserName = r'Valerio15';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool? _authStatus;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await DocusignFlutter.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
            Text('Running on: $_platformVersion\n'),
            Text('Auth status: ${_getAuthStatus()}\n'),
            ElevatedButton(onPressed: () => _auth(), child: const Text('Auth'),),
            ElevatedButton(onPressed: () => _captiveSign(), child: const Text('CaptiveSign'),),
          ]),
        ),
      ),
    );
  }

  Future<void> _auth() async {
    var result = false;
      try {
        var authModel = AuthModel(
            accessToken: accessToken,
            accountId: accountId,
            email: email,
            host: host,
            integratorKey: integratorKey,
            userId: userId,
            userName: userName);
        result = await DocusignFlutter.auth(authModel);
      } on Exception {
        result = false;
      }

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
    } on Exception {
      print('111 ERROR');
    }

    setState(() {
      _authStatus = result;
    });
  }

  String _getAuthStatus() {
    var status = _authStatus;
    if (status != null) {
      return status ? 'success' : 'failed';
    }

    return 'none';
  }
}
