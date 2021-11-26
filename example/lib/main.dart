import 'package:flutter/material.dart';
import 'dart:async';

import 'package:docusign_flutter/docusign_flutter.dart';
import 'package:docusign_flutter/model/auth_model.dart';
import 'package:docusign_flutter/model/captive_signing_model.dart';

void main() {
  runApp(const MyApp());
}

const String accessToken = r'eyJ0eXAiOiJNVCIsImFsZyI6IlJTMjU2Iiwia2lkIjoiNjgxODVmZjEtNGU1MS00Y2U5LWFmMWMtNjg5ODEyMjAzMzE3In0.AQsAAAABAAUABwAALBnPrbDZSAgAAGw83fCw2UgCAAJ3ltDYvipBiNPp15RDK8cVAAEAAAAYAAEAAAAFAAAADQAkAAAAYzk3NzhhY2ItODE4MC00YWNjLWExNjgtM2QxOGRiOTgyZDBmIgAkAAAAYzk3NzhhY2ItODE4MC00YWNjLWExNjgtM2QxOGRiOTgyZDBmEgABAAAACwAAAGludGVyYWN0aXZlMACAawu5rbDZSDcA7nTvijZbqEOtjvAIVQg5pA.P8tTM1ZOdRw4gGuz2irjJimLlDe5vMULQUIvPOgVeLNFWoE3PdLRpY1rL5eXziLSkNjXapSce-b7BXiLreeyPg55wyBfE7KXpJc2N9TnaeLcPwGh3vdCxXWqg5XSfrCPQ88mDjyBj5p4O9N9pKOsRaxfz5pmgTddVZ2SXV03FOgvlIdHHuWdLpN43_AL94CkQbZRSTsnQSartL4IEbJE41CqY0L37n6v0oaKL2GCFojqLBo3H5T4ECHnKDNeCZRGyOQFSN4MDLoylV-ZliRN_KENKY-1dXrMKnI_5kT6pRao_UHWMOCmuXAy_q8UAwDIw4ARg10DOUhFMe6X5UG-yw';
const String accountId = r'41cf0617-a663-4373-b1f1-3abfc2f80afe';
const String email = r'alik@dizraptor.app';
const String host = r'https://demo.docusign.net/restapi';
const String integratorKey = r'c9778acb-8180-4acc-a168-3d18db982d0f';
const String userId = r'd0967702-bed8-412a-88d3-e9d794432bc7';
const String userName = r'Dizraptor';

const String envelopeId = r'914b4f9f-335f-4162-a53a-b550ca900776';
const String recipientClientUserId = r'1000';
const String recipientEmail = r'dilerarc18@gmail.com';
const String recipientUserName = r'Valerio18';

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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
          accountId: accountId,
          email: email,
          host: host,
          integratorKey: integratorKey,
          userId: userId,
          userName: userName);
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
