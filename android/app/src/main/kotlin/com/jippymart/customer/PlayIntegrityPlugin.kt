package com.jippymart.customer

import android.content.Context
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutionException

class PlayIntegrityPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.jippymart.customer/play_integrity")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getIntegrityToken" -> {
                val projectNumber = call.argument<String>("projectNumber")
                if (projectNumber == null) {
                    result.error("INVALID_ARGUMENT", "Project number is required", null)
                    return
                }
                getIntegrityToken(projectNumber, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun getIntegrityToken(projectNumber: String, result: Result) {
        try {
            val integrityManager = IntegrityManagerFactory.create(context)
            val request = IntegrityTokenRequest.builder()
                .setNonce("nonce-${System.currentTimeMillis()}")
                .build()

            val integrityTokenResponse: IntegrityTokenResponse = Tasks.await(
                integrityManager.requestIntegrityToken(request)
            )
            result.success(integrityTokenResponse.token())
        } catch (e: ExecutionException) {
            result.error("INTEGRITY_ERROR", e.message, null)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, null)
        }
    }
} 