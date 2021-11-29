package com.unitedtraders.mobile.docusign_flutter;

import com.docusign.androidsdk.DocuSign
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class DataBrokerSingleton {
    companion object {
        val instance = DataBrokerSingleton()
    }

    var captiveSigningResult: Result? = null
    var captiveSigningCall: MethodCall? = null

    var docuSign: DocuSign? = null
}