package com.jippymart.customer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import android.os.Bundle
import android.util.Log
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jippymart.customer/play_integrity"
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize Play Integrity service
        // playIntegrityService = PlayIntegrityService(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val integrityManager = IntegrityManagerFactory.create(applicationContext)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getIntegrityToken") {
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        // Generate a random UUID and encode it in base64
                        val uuid = java.util.UUID.randomUUID().toString()
                        val nonce = android.util.Base64.encodeToString(
                            uuid.toByteArray(),
                            android.util.Base64.NO_WRAP
                        )
                        
                        val request = IntegrityTokenRequest.builder()
                            .setNonce(nonce)
                            .build()
                        
                        val response = integrityManager.requestIntegrityToken(request).await()
                        result.success(response.token())
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting integrity token", e)
                        result.error("INTEGRITY_ERROR", e.message, null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
} 