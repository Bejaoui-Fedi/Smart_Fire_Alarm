package com.example.smart_fire_alarm

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class SmsSender {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    fun attachToEngine(flutterEngine: FlutterEngine, context: Context) {
        this.context = context
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_sender")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phone = call.argument<String>("phone")!!
                    val message = call.argument<String>("message")!!
                    sendSms(phone, message, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendSms(phone: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager = SmsManager.getDefault()
            val sentIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent("SMS_SENT"),
                PendingIntent.FLAG_IMMUTABLE
            )
            
            smsManager.sendTextMessage(phone, null, message, sentIntent, null)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }
}