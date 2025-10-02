package com.example.smart_fire_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import android.util.Log

class SmsSentReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (resultCode) {
            android.app.Activity.RESULT_OK -> Log.d("SMS_STATUS", "SMS envoyé avec succès")
            SmsManager.RESULT_ERROR_GENERIC_FAILURE -> Log.e("SMS_STATUS", "Échec générique")
            SmsManager.RESULT_ERROR_NO_SERVICE -> Log.e("SMS_STATUS", "Pas de réseau")
            SmsManager.RESULT_ERROR_NULL_PDU -> Log.e("SMS_STATUS", "PDU nul")
            SmsManager.RESULT_ERROR_RADIO_OFF -> Log.e("SMS_STATUS", "Radio désactivée")
            else -> Log.e("SMS_STATUS", "Erreur inconnue: $resultCode")
        }
    }
}