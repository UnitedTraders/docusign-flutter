package com.unitedtraders.mobile.docusign_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.docusign.androidsdk.DocuSign

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.docusign.androidsdk.dsmodels.DSUser
import com.docusign.androidsdk.exceptions.DSAuthenticationException
import com.docusign.androidsdk.exceptions.DSSigningException
import com.docusign.androidsdk.listeners.DSAuthenticationListener
import com.docusign.androidsdk.listeners.DSCaptiveSigningListener
import com.docusign.androidsdk.util.DSMode
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding



/** DocusignFlutterPlugin */
class DocusignFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun login(@NonNull call: MethodCall, @NonNull result: Result) {
    val params: AuthModel
    try {
      @Suppress("UNCHECKED_CAST")
      val arguments: ArrayList<String> = call.arguments as ArrayList<String>
      val json: String = arguments[0]
      val gson = Gson()
      params = gson?.fromJson(json, AuthModel::class.java)
    } catch (e: Exception) {
      result.error("AuthFailed", null, null)
      return
    }

    // Temporary constant, need be taken from flutter
    val refreshToken = "<<REFRESH_TOKEN>>"
    DocuSign.init(context, integratorKey = params.integratorKey, mode = DSMode.DEBUG)
    val authDelegate = DocuSign.getInstance().getAuthenticationDelegate()
    authDelegate.login(accessToken = params.accessToken, refreshToken = refreshToken,  expiresIn =  28800, context,
      object : DSAuthenticationListener {
        override fun onSuccess(@NonNull user: DSUser) {
          result.success(null)
        }

        override fun onError(@NonNull exception: DSAuthenticationException) {
          result.error("AuthFailed", null, null)
        }
      }
    )
  }

  private fun captiveSinging(@NonNull call: MethodCall, @NonNull result: Result) {
    // TODO необходимо решить проблему с запуском вне Activity, т.к. само создание Intent от нас скрыто - это проблема.
    // TODO ошибки должны быть более информативными
//    val params: CaptiveSigningModel
//    try {
//      @Suppress("UNCHECKED_CAST")
//      val arguments: ArrayList<String> = call.arguments as ArrayList<String>
//      val json: String = arguments[0]
//      val gson = Gson()
//      params = gson?.fromJson(json, CaptiveSigningModel::class.java)
//    } catch (e: Exception) {
//      result.error("CaptiveSingingFailed", null, null)
//      return
//    }
//
//    activity.intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//    DocuSign.getInstance().getSigningDelegate().launchCaptiveSigning(context,
//      envelopeId = params.envelopeId,
//      recipientClientUserId = params.recipientClientUserId,
//      listener = object : DSCaptiveSigningListener {
//        override fun onCancel(envelopeId: String, recipientId: String) {
//          result.error("CaptiveSingingFailed", null, null)
//        }
//
//        override fun onError(envelopeId: String?, exception: DSSigningException) {
//          result.error("CaptiveSingingFailed", null, null)
//        }
//
//        override fun onRecipientSigningError(
//          envelopeId: String,
//          recipientId: String,
//          exception: DSSigningException
//        ) {
//          result.error("CaptiveSingingFailed", null, null)
//        }
//
//        override fun onRecipientSigningSuccess(envelopeId: String, recipientId: String) {
//          print("onRecipientSigningSuccess")
//        }
//
//        override fun onStart(envelopeId: String) {
//          print("onStart")
//        }
//
//        override fun onSuccess(envelopeId: String) {
//          result.success(null)
//        }
//      })
  }

  data class AuthModel (
    val accessToken: String,
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

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity as FlutterActivity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity as FlutterActivity
  }

  override fun onDetachedFromActivity() {
    channel?.setMethodCallHandler(null)
  }
}
