package com.sos.flasher

import android.app.Activity
import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.RecoverySystem
import android.widget.*
import java.io.File

/**
 * SOS ROM Flasher — OTA Self-Installer
 *
 * Flow:
 * 1. Detect phone model and architecture
 * 2. Check Project Treble support
 * 3. Download correct SOS-ROM image
 * 4. Reboot to recovery and flash
 */
class FlasherActivity : Activity() {

    companion object {
        const val ROM_BASE_URL = "https://github.com/Ricardo-BR-IT/sos/releases/latest/download"
        const val TAG = "SOS-Flasher"
    }

    private lateinit var statusText: TextView
    private lateinit var detailsText: TextView
    private lateinit var progressBar: ProgressBar
    private lateinit var flashButton: Button
    private lateinit var deviceInfo: DeviceInfo

    data class DeviceInfo(
        val model: String,
        val manufacturer: String,
        val arch: String,
        val sdkVersion: Int,
        val isTreble: Boolean,
        val isAB: Boolean,
        val ramMB: Long,
        val storageFreeGB: Long
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Build UI programmatically (no XML for simplicity)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 48, 48, 48)
            setBackgroundColor(0xFF1A1A1A.toInt())
        }

        // Title
        TextView(this).apply {
            text = "⚡ SOS RESGATE — ROM Flasher"
            textSize = 22f
            setTextColor(0xFF00FF00.toInt())
            setPadding(0, 0, 0, 32)
            layout.addView(this)
        }

        // Status
        statusText = TextView(this).apply {
            text = "Analyzing device..."
            textSize = 16f
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(0, 0, 0, 16)
            layout.addView(this)
        }

        // Details
        detailsText = TextView(this).apply {
            text = ""
            textSize = 12f
            setTextColor(0xFFAAAAAA.toInt())
            setPadding(0, 0, 0, 32)
            layout.addView(this)
        }

        // Progress
        progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            max = 100
            progress = 0
            setPadding(0, 0, 0, 32)
            layout.addView(this)
        }

        // Flash Button
        flashButton = Button(this).apply {
            text = "🔄 Transform into SOS Node"
            textSize = 16f
            setBackgroundColor(0xFF333333.toInt())
            setTextColor(0xFF00FF00.toInt())
            isEnabled = false
            setOnClickListener { startFlashing() }
            layout.addView(this)
        }

        // Warning
        TextView(this).apply {
            text = "\n⚠️ WARNING: This will replace your current Android system.\n" +
                   "Your data will be ERASED. Make sure to backup first.\n" +
                   "The phone will still work for calls and mesh networking."
            textSize = 11f
            setTextColor(0xFFFF6666.toInt())
            layout.addView(this)
        }

        setContentView(layout)

        // Start device analysis
        analyzeDevice()
    }

    private fun analyzeDevice() {
        val runtime = Runtime.getRuntime()
        val ramMB = runtime.maxMemory() / (1024 * 1024)

        val dataDir = Environment.getDataDirectory()
        val freeGB = dataDir.freeSpace / (1024 * 1024 * 1024)

        // Check Project Treble support
        val isTreble = try {
            val prop = Runtime.getRuntime().exec("getprop ro.treble.enabled")
            prop.inputStream.bufferedReader().readLine()?.trim() == "true"
        } catch (e: Exception) { false }

        // Check A/B partition scheme
        val isAB = try {
            val prop = Runtime.getRuntime().exec("getprop ro.build.ab_update")
            prop.inputStream.bufferedReader().readLine()?.trim() == "true"
        } catch (e: Exception) { false }

        // Determine architecture
        val arch = when {
            Build.SUPPORTED_ABIS.any { it.contains("arm64") } -> "arm64"
            Build.SUPPORTED_ABIS.any { it.contains("armeabi") } -> "arm"
            Build.SUPPORTED_ABIS.any { it.contains("x86_64") } -> "x86_64"
            else -> "arm"
        }

        deviceInfo = DeviceInfo(
            model = "${Build.MANUFACTURER} ${Build.MODEL}",
            manufacturer = Build.MANUFACTURER,
            arch = arch,
            sdkVersion = Build.VERSION.SDK_INT,
            isTreble = isTreble,
            isAB = isAB,
            ramMB = ramMB,
            storageFreeGB = freeGB
        )

        // Display results
        val details = buildString {
            appendLine("📱 Model: ${deviceInfo.model}")
            appendLine("🏗️ Architecture: ${deviceInfo.arch}")
            appendLine("📦 Android SDK: ${deviceInfo.sdkVersion} (Android ${Build.VERSION.RELEASE})")
            appendLine("🧩 Project Treble: ${if (deviceInfo.isTreble) "✅ YES" else "❌ NO"}")
            appendLine("🔄 A/B Partitions: ${if (deviceInfo.isAB) "✅ YES" else "❌ NO"}")
            appendLine("💾 RAM: ${deviceInfo.ramMB} MB")
            appendLine("💿 Free Storage: ${deviceInfo.storageFreeGB} GB")
        }
        detailsText.text = details

        // Determine compatibility
        when {
            !deviceInfo.isTreble -> {
                statusText.text = "❌ Device is NOT Treble-compatible.\nSOS-ROM requires Project Treble (Android 8+)."
                statusText.setTextColor(0xFFFF3333.toInt())
            }
            deviceInfo.sdkVersion < 26 -> {
                statusText.text = "❌ Android version too old.\nMinimum: Android 8.0 (SDK 26)"
                statusText.setTextColor(0xFFFF3333.toInt())
            }
            deviceInfo.storageFreeGB < 2 -> {
                statusText.text = "❌ Not enough storage.\nNeed at least 2GB free."
                statusText.setTextColor(0xFFFF3333.toInt())
            }
            else -> {
                val romFile = "sos-rom-${deviceInfo.arch}-ota.zip"
                statusText.text = "✅ Device compatible!\nRecommended ROM: $romFile"
                statusText.setTextColor(0xFF00FF00.toInt())
                flashButton.isEnabled = true
            }
        }
    }

    private fun startFlashing() {
        val romFile = "sos-rom-${deviceInfo.arch}-ota.zip"
        val downloadUrl = "$ROM_BASE_URL/$romFile"

        statusText.text = "⬇️ Downloading SOS-ROM..."
        flashButton.isEnabled = false
        progressBar.progress = 10

        // Download using Android DownloadManager
        val request = DownloadManager.Request(Uri.parse(downloadUrl)).apply {
            setTitle("SOS-ROM Download")
            setDescription("Downloading mesh node firmware...")
            setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, romFile)
            setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
        }

        val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        val downloadId = dm.enqueue(request)

        // Monitor download
        registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val id = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1)
                if (id == downloadId) {
                    progressBar.progress = 80
                    statusText.text = "✅ Download complete. Preparing flash..."

                    val file = File(
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                        romFile
                    )

                    try {
                        // Attempt OTA install via RecoverySystem
                        progressBar.progress = 90
                        statusText.text = "🔄 Rebooting to Recovery to install..."
                        RecoverySystem.installPackage(context, file)
                    } catch (e: Exception) {
                        statusText.text = "⚠️ Auto-flash failed.\nManual steps:\n" +
                            "1. Copy $romFile to SD Card\n" +
                            "2. Reboot to Recovery (Vol↓ + Power)\n" +
                            "3. Select 'Install from ZIP'\n" +
                            "4. Choose $romFile"
                        statusText.setTextColor(0xFFFFAA00.toInt())
                    }
                }
            }
        }, IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE), RECEIVER_EXPORTED)
    }
}
