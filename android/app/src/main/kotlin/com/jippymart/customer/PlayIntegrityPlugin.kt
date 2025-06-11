package com.jippymart.customer

import android.content.Context
import android.util.Log
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID

class PlayIntegrityPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val TAG = "PlayIntegrityPlugin"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.jippymart.customer/play_integrity")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getIntegrityToken" -> {
                try {
                    Log.d(TAG, "Initializing Integrity Manager")
                    val integrityManager = IntegrityManagerFactory.create(context)
                    
                    // Generate a unique nonce for each request
                    val nonce = UUID.randomUUID().toString()
                    Log.d(TAG, "Generated nonce: $nonce")
                    
                    Log.d(TAG, "Creating Integrity Token Request")
                    val request = IntegrityTokenRequest.builder()
                        .setNonce(nonce)
                        .build()
                    
                    Log.d(TAG, "Requesting Integrity Token")
                    integrityManager.requestIntegrityToken(request)
                        .addOnSuccessListener { response: IntegrityTokenResponse ->
                            Log.d(TAG, "Successfully got integrity token")
                            result.success(response.token())
                        }
                        .addOnFailureListener { e ->
                            Log.e(TAG, "Failed to get integrity token", e)
                            result.error("INTEGRITY_ERROR", "Failed to get integrity token: ${e.message}", null)
                        }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in getIntegrityToken", e)
                    result.error("INTEGRITY_ERROR", "Error in getIntegrityToken: ${e.message}", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
} 