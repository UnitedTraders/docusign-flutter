package com.unitedtraders.mobile.docusign_flutter

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle


class CaptiveSigningWrapActivity : AppCompatActivity() {
    companion object {
        private var firstRun: Boolean = true
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_wrap)

        if (!firstRun) {
            firstRun = false
            startCaptiveSigning()
        }
    }

    private fun startCaptiveSigning() {

    }
}