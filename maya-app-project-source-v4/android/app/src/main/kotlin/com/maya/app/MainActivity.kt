package com.maya.app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val NATIVE_CHANNEL = "com.maya.app/xiaomi_native"
    private val BIOMETRIC_CHANNEL = "com.maya.app/biometric"
    private val THREAT_CHANNEL = "com.maya.app/threat_protection"
    private val WHATSAPP_CHANNEL = "com.maya.app/whatsapp_bridge"

    private var mediaPlayer: MediaPlayer? = null
    private var isStrobing = false
    private lateinit var biometricService: BiometricSecurityService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        biometricService = BiometricSecurityService(this)

        // Native Xiaomi Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMiuiAutostart" -> {
                    val openSuccess = openMiuiSetting(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                    result.success(openSuccess)
                }
                "openMiuiBatterySaver" -> {
                    val openSuccess = openMiuiSetting(
                        "com.miui.powerkeeper",
                        "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"
                    )
                    if (!openSuccess) {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "openMiuiBackgroundPopups" -> {
                    val openSuccess = openMiuiSetting(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.permissions.PermissionsEditorActivity"
                    )
                    result.success(openSuccess)
                }
                "startForegroundService" -> {
                    val serviceIntent = Intent(this, MayaXiaomiService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "triggerPhoneFinder" -> {
                    val duration = call.argument<Int>("durationSeconds") ?: 30
                    executePhoneFinder(duration)
                    result.success(true)
                }
                "stopPhoneFinder" -> {
                    stopPhoneFinderRoutine()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Biometric Security Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BIOMETRIC_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanBiometrics" -> {
                    val bioResult = biometricService.scanAndMatchBiometrics()
                    result.success(mapOf(
                        "role" to bioResult.role,
                        "confidence" to bioResult.confidence,
                        "isAuthorized" to bioResult.isAuthorized
                    ))
                }
                else -> result.notImplemented()
            }
        }

        // Threat Protection Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, THREAT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "analyzeIncomingCall" -> {
                    val phone = call.argument<String>("phone") ?: ""
                    val isScam = phone.startsWith("+91140") || phone.startsWith("140")
                    result.success(mapOf(
                        "isScam" to isScam,
                        "threatScore" to if (isScam) 0.95 else 0.05,
                        "warningText" to if (isScam) "મમ્મી જી, આ સ્કેમ / ફ્રોડ કોલ છે." else ""
                    ))
                }
                else -> result.notImplemented()
            }
        }

        // WhatsApp & Notification Query Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WHATSAPP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLastNotificationDetails" -> {
                    val sender = AccessibilityControlService.lastSenderName
                    val text = AccessibilityControlService.lastMessageContent
                    result.success(mapOf(
                        "sender" to sender,
                        "text" to text
                    ))
                }
                "sendWhatsAppMessage" -> {
                    val message = call.argument<String>("message") ?: ""
                    val success = AccessibilityControlService.instance?.performAutoSendWhatsApp(message) ?: false
                    result.success(success)
                }
                "launchApp" -> {
                    val appName = call.argument<String>("appName") ?: ""
                    val intent = when (appName.lowercase()) {
                        "whatsapp", "વોટ્સએપ" -> packageManager.getLaunchIntentForPackage("com.whatsapp")
                        "youtube", "યુટ્યુબ" -> packageManager.getLaunchIntentForPackage("com.google.android.youtube")
                        else -> null
                    }
                    if (intent != null) {
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openMiuiSetting(packageName: String, activityName: String): Boolean {
        return try {
            val intent = Intent().apply {
                component = ComponentName(packageName, activityName)
                putExtra("extra_pkgname", applicationContext.packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun executePhoneFinder(durationSeconds: Int) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.setStreamVolume(
            AudioManager.STREAM_ALARM,
            audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
            0
        )

        if (mediaPlayer == null) {
            mediaPlayer = MediaPlayer.create(this, R.raw.maya_chime_loud)
            mediaPlayer?.isLooping = true
        }
        mediaPlayer?.start()

        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraId = cameraManager.cameraIdList[0]

        isStrobing = true
        Thread {
            val endTime = System.currentTimeMillis() + (durationSeconds * 1000)
            var state = false
            while (System.currentTimeMillis() < endTime && isStrobing) {
                state = !state
                try {
                    cameraManager.setTorchMode(cameraId, state)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                Thread.sleep(150)
            }
            try {
                cameraManager.setTorchMode(cameraId, false)
            } catch (e: Exception) {}
            stopPhoneFinderRoutine()
        }.start()
    }

    private fun stopPhoneFinderRoutine() {
        isStrobing = false
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
        }
        mediaPlayer = null
    }
}
