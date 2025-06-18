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
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jippymart.customer/play_integrity"
    private val TAG = "MainActivity"
    private val API_KEY = "AIzaSyCdLXK7dE_uPBxZ0tzVuL85o9-vyXkwIyk"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize Firebase App Check
        val firebaseAppCheck = FirebaseAppCheck.getInstance()
        firebaseAppCheck.installAppCheckProviderFactory(
            PlayIntegrityAppCheckProviderFactory.getInstance()
        )
        
        // For debug builds, also install the debug provider
        if (BuildConfig.DEBUG) {
            firebaseAppCheck.installAppCheckProviderFactory(
                com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory.getInstance()
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(PlayIntegrityPlugin())
        
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
                        result.success(mapOf(
                            "token" to response.token(),
                            "nonce" to nonce
                        ))
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