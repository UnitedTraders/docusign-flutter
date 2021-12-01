package com.unitedtraders.mobile.docusign_flutter;

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class DataBrokerSingleton {
    companion object {
        val instance = DataBrokerSingleton()
    }

    var captiveSigningResult: Result? = null
    var captiveSigningCall: MethodCall? = null
}