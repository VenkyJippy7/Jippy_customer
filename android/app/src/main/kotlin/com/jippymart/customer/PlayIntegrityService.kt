package com.jippymart.customer

import android.content.Context
import android.util.Log
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.tasks.await
import java.util.Base64
import java.util.UUID

class PlayIntegrityService(private val context: Context) {
    private val integrityManager = IntegrityManagerFactory.create(context)

    suspend fun getIntegrityToken(): String = withContext(Dispatchers.IO) {
        try {
            // Generate a nonce for this request
            val nonce = generateNonce()
            Log.d("PlayIntegrity", "Generated nonce: $nonce")
            
            // Create the integrity token request
            val request = IntegrityTokenRequest.builder()
                .setNonce(nonce)
                .build()

            // Request the integrity token
            val response = integrityManager.requestIntegrityToken(request).await()
            Log.d("PlayIntegrity", "Received token response")
            
            // Return the token
            response.token()
        } catch (e: Exception) {
            Log.e("PlayIntegrity", "Error getting integrity token: ${e.message}", e)
            throw e
        }
    }

    private fun generateNonce(): String {
        // Generate a random UUID and encode it in base64
        val uuid = UUID.randomUUID().toString()
        return Base64.getEncoder().encodeToString(uuid.toByteArray())
    }

    companion object {
        // API endpoint for Play Integrity
        const val PLAY_INTEGRITY_API_ENDPOINT = "https://playintegrity.googleapis.com/v1/token"
        private const val TAG = "PlayIntegrityService"
    }
} 