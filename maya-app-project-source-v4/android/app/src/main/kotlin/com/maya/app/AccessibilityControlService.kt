package com.maya.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.Bundle
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AccessibilityControlService : AccessibilityService() {

    companion object {
        var instance: AccessibilityControlService? = null
        var lastSenderName: String = "અજાણ્યો નંબર"
        var lastMessageContent: String = ""
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        }
        this.serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: ""
            val notificationText = event.text.joinToString(" ")

            if (packageName.contains("whatsapp") || packageName.contains("telecom") || packageName.contains("mms")) {
                parseNotificationText(notificationText)
            }
        }
    }

    private fun parseNotificationText(text: String) {
        if (text.contains(":")) {
            val parts = text.split(":", limit = 2)
            lastSenderName = parts[0].trim()
            lastMessageContent = parts[1].trim()
        } else {
            lastSenderName = text
            lastMessageContent = ""
        }
    }

    /// Automatically automates typing and sending messages inside third-party apps like WhatsApp
    fun performAutoSendWhatsApp(message: String): Boolean {
        val rootNode = rootInActiveWindow ?: return false
        val inputNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/entry")
        if (inputNodes.isNotEmpty()) {
            val inputNode = inputNodes[0]
            val arguments = Bundle()
            arguments.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_ARGUMENT, message)
            inputNode.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, arguments)

            // Click Send Button
            val sendNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/send")
            if (sendNodes.isNotEmpty()) {
                sendNodes[0].performAction(AccessibilityNodeInfo.ACTION_CLICK)
                return true
            }
        }
        return false
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}
