package com.maya.app

import android.content.Context
import android.os.BatteryManager
import android.telephony.SmsManager

class TelemetryService(private val context: Context) {

    private val CHIRAG_PHONE_NUMBER = "+919876543210" // Configured Son's Number

    /// Automatically formats and sends direct diagnostic SMS report to Chirag's number
    fun sendDiagnosticReportToSon(issueType: String, details: String) {
        val batteryLevel = getBatteryPercentage()
        val messageBody = """
            [MAYA APP DIAGNOSTIC REPORT]
            Alert for Mummy's Device:
            - Issue: $issueType
            - Details: $details
            - Battery Level: $batteryLevel%
            - Action Taken: Automated Telemetry Logged
            Please check Maya App or call Mummy.
        """.trimIndent()

        try {
            val smsManager: SmsManager = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                context.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

            // Dispatch SMS directly to Chirag
            val parts = smsManager.divideMessage(messageBody)
            smsManager.sendMultipartTextMessage(CHIRAG_PHONE_NUMBER, null, parts, null, null)
            println("Diagnostic SMS successfully sent to Chirag's number.")
        } catch (e: Exception) {
            e.printStackTrace()
            println("Failed to send diagnostic SMS: ${e.message}")
        }
    }

    private fun getBatteryPercentage(): Int {
        val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
}