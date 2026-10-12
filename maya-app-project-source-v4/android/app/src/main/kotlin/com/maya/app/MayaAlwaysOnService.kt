package com.maya.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class MayaAlwaysOnService : Service() {
    private val CHANNEL_ID = "MayaAlwaysOnChannel"
    private val NOTIFICATION_ID = 1002

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        initAmbientVoiceListener()
    }

    private fun initAmbientVoiceListener() {
        // Continuous Porcupine Wake-Word & Streaming VAD Pipeline
        // Listens for "માયા" or direct action phrases hands-free
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("માયા સક્રિય છે (Maya Always-On Active)")
            .setContentText("હંમેશા તમારી વાત સાંભળવા અને મદદ કરવા તૈયાર છે")
            .setSmallIcon(R.drawable.ic_stat_maya)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Maya Ambient Voice Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
}