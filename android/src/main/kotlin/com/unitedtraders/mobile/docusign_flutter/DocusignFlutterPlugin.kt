package com.unitedtraders.mobile.docusign_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** DocusignFlutterPlugin */
class DocusignFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "docusign_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "login" -> login(call = call, result = result)
      "captiveSinging" -> captiveSinging(call = call, result = result)
      else -> result.notImplemented()
    }
  }

  private fun login(@NonNull call: MethodCall, @NonNull result: Result) {
    result.notImplemented()
  }

  private fun captiveSinging(@NonNull call: MethodCall, @NonNull result: Result) {
    result.notImplemented()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity as FlutterActivity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    val newActivity = binding.activity as? FlutterActivity
    if (newActivity != null) {
      activity = newActivity.activity
    }
  }

  override fun onDetachedFromActivity() {
    channel.setMethodCallHandler(null)
  }

  data class AuthModel (
    val accessToken: String,
    val expiresIn: Int,
    val accountId: String,
    val userId: String,
    val userName: String,
    val email: String,
    val host: String,
    val integratorKey: String,
  )

  data class CaptiveSigningModel(
    val envelopeId: String,
    val recipientUserName: String,
    val recipientEmail: String,
    val recipientClientUserId: String,)
}
