package com.unitedtraders.mobile.docusign_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.startActivity
import com.docusign.androidsdk.DSEnvironment
import com.docusign.androidsdk.DocuSign

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.docusign.androidsdk.dsmodels.DSUser
import com.docusign.androidsdk.exceptions.DSAuthenticationException
import com.docusign.androidsdk.listeners.DSAuthenticationListener
import com.docusign.androidsdk.util.DSMode
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName;
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
    val params: AuthModel
    try {
      @Suppress("UNCHECKED_CAST")
      val arguments: ArrayList<String> = call.arguments as ArrayList<String>
      val json: String = arguments[0]
      val gson = Gson()
      params = gson.fromJson(json, AuthModel::class.java)
    } catch (e: Exception) {
      result.error(Constants.errorCommonCode, Constants.errorAuthFailed, "Cannot parse AuthModel json: ${e.message}")
      return
    }

    try {
      val isDemo = params.host.indexOf("demo") != -1
      val dsMode = if (isDemo) DSMode.DEBUG else DSMode.PRODUCTION
      val dsEnvironment = if (isDemo) DSEnvironment.DEMO_ENVIRONMENT else DSEnvironment.PRODUCTION_ENVIRONMENT
      DocuSign.init(context, integratorKey = params.integratorKey, mode = dsMode)
      DocuSign.getInstance().setEnvironment(dsEnvironment)
      val authDelegate = DocuSign.getInstance().getAuthenticationDelegate()
      authDelegate.login(
        accessToken = params.accessToken,
        refreshToken = null,
        expiresIn = params.expiresIn,
        context,
        object : DSAuthenticationListener {
          override fun onSuccess(@NonNull user: DSUser) {
            result.success(null)
          }

          override fun onError(@NonNull exception: DSAuthenticationException) {
            result.error(Constants.errorCommonCode, Constants.errorAuthFailed, exception.message)
          }
        },
        userAccountId = params.accountId,
      )
    } catch (e: Exception) {
      result.error(Constants.errorCommonCode, Constants.errorAuthFailed, e.message)
      return
    }
  }

  private fun captiveSinging(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      DataBrokerSingleton.instance.captiveSigningResult = result
      DataBrokerSingleton.instance.captiveSigningCall = call

      val intent = Intent(context, CaptiveSigningWrapActivity::class.java)
      intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      startActivity(context, intent, null)
    } catch (e: Exception) {
      result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, "Cannot start wrap activity")
    }
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
    @SerializedName("accessToken")
    val accessToken: String,
    @SerializedName("expiresIn")
    val expiresIn: Int,
    @SerializedName("accountId")
    val accountId: String,
    @SerializedName("userId")
    val userId: String,
    @SerializedName("userName")
    val userName: String,
    @SerializedName("email")
    val email: String,
    @SerializedName("host")
    val host: String,
    @SerializedName("integratorKey")
    val integratorKey: String,
  )

  data class CaptiveSigningModel(
    @SerializedName("envelopeId")
    val envelopeId: String,
    @SerializedName("recipientUserName")
    val recipientUserName: String,
    @SerializedName("recipientEmail")
    val recipientEmail: String,
    @SerializedName("recipientClientUserId")
    val recipientClientUserId: String,)
}
