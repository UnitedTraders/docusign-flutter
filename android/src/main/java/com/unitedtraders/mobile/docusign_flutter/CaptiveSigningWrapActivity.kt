package com.unitedtraders.mobile.docusign_flutter

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.docusign.androidsdk.DocuSign
import com.docusign.androidsdk.exceptions.DSSigningException
import com.docusign.androidsdk.listeners.DSCaptiveSigningListener
import com.google.gson.Gson


class CaptiveSigningWrapActivity : AppCompatActivity() {
    private var firstRun: Boolean = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_wrap)

        if (firstRun) {
            firstRun = false
            startCaptiveSigning()
        }
    }

    private fun startCaptiveSigning() {
        val result = DataBrokerSingleton.instance.captiveSigningResult ?: return

        val call = DataBrokerSingleton.instance.captiveSigningCall
        if (call == null) {
            result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, "CaptiveSigningCall is null")
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
            result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, "Cannot parse CaptiveSigningModel json: ${e.message}")
            return
        }

        try {
            DocuSign.getInstance().getSigningDelegate().launchCaptiveSigning(this,
                envelopeId = params.envelopeId,
                recipientClientUserId = params.recipientClientUserId,
                listener = object : DSCaptiveSigningListener {
                    override fun onCancel(envelopeId: String, recipientId: String) {
                        result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, "User cancel captive signing")
                        finish()
                    }

                    override fun onError(envelopeId: String?, exception: DSSigningException) {
                        result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, exception.message)
                        finish()
                    }

                    override fun onRecipientSigningError(
                        envelopeId: String,
                        recipientId: String,
                        exception: DSSigningException
                    ) {
                    }

                    override fun onRecipientSigningSuccess(envelopeId: String, recipientId: String) {
                    }

                    override fun onStart(envelopeId: String) {
                    }

                    override fun onSuccess(envelopeId: String) {
                        result.success(null)
                        finish()
                    }
                })
        } catch (e: Exception) {
            result.error(Constants.errorCommonCode, Constants.errorCaptiveSingingFailed, e.message)
        }
    }
}