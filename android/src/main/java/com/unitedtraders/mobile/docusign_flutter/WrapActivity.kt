package com.unitedtraders.mobile.docusign_flutter

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.annotation.NonNull
import com.docusign.androidsdk.DSEnvironment
import com.docusign.androidsdk.DocuSign
import com.docusign.androidsdk.dsmodels.DSUser
import com.docusign.androidsdk.exceptions.DSAuthenticationException
import com.docusign.androidsdk.exceptions.DSSigningException
import com.docusign.androidsdk.listeners.DSAuthenticationListener
import com.docusign.androidsdk.listeners.DSCaptiveSigningListener
import com.google.gson.Gson

import io.flutter.plugin.common.MethodChannel.Result
import org.jetbrains.annotations.NotNull


import com.docusign.androidsdk.listeners.DSOnlineSigningListener


import com.docusign.androidsdk.delegates.DSSigningDelegate




class WrapActivity : AppCompatActivity() {
    private lateinit var result: Result

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_wrap)

        startCaptiveSigning()
    }

    private fun startCaptiveSigning() {
        val call = DataBrokerSingleton.instance.captiveSigningCall
        val result = DataBrokerSingleton.instance.captiveSigningResult
        if (call == null || result == null) {
            return
        }

        val params: DocusignFlutterPlugin.CaptiveSigningModel
        try {
            @Suppress("UNCHECKED_CAST")
            val arguments: ArrayList<String> = call.arguments as ArrayList<String>
            val json: String = arguments[0]
            val gson = Gson()
            params = gson.fromJson(json, DocusignFlutterPlugin.CaptiveSigningModel::class.java)
        } catch (e: Exception) {
            result.error("CaptiveSingingFailed", null, null)
            return
        }

        DocuSign.getInstance().getSigningDelegate().launchCaptiveSigning(this,
            envelopeId = params.envelopeId,
            recipientClientUserId = params.recipientClientUserId,
            listener = object : DSCaptiveSigningListener {
            override fun onCancel(envelopeId: String, recipientId: String) {
                result.error("CaptiveSingingFailed", null, null)
                finish()
            }

            override fun onError(envelopeId: String?, exception: DSSigningException) {
                result.error("CaptiveSingingFailed", null, null)
                finish()
            }

            override fun onRecipientSigningError(
                envelopeId: String,
                recipientId: String,
                exception: DSSigningException
            ) {
                result.error("CaptiveSingingFailed", null, null)
                finish()
            }

            override fun onRecipientSigningSuccess(envelopeId: String, recipientId: String) {
                print("onRecipientSigningSuccess")
            }

            override fun onStart(envelopeId: String) {
                print("onStart")
            }

            override fun onSuccess(envelopeId: String) {
                result.success(null)
                finish()
            }
          })
    }
}