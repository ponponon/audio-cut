package cn.quniv.audio_cut

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private const val channelName = "cn.quniv.audio_cut/device_saver"
        private const val requestSavePermission = 43102
        private val publicRelativePath =
            "${Environment.DIRECTORY_MUSIC}/AudioCut"
    }

    private data class SaveArgs(
        val sourcePath: String,
        val fileName: String,
        val mimeType: String,
    )

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingSaveArgs: SaveArgs? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            if (call.method != "saveAudio") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val sourcePath = call.argument<String>("sourcePath")
            val fileName = call.argument<String>("fileName")
            val mimeType = call.argument<String>("mimeType") ?: "audio/mpeg"
            if (sourcePath == null || fileName == null) {
                result.error("bad_args", "sourcePath and fileName are required", null)
                return@setMethodCallHandler
            }
            requestSave(SaveArgs(sourcePath, fileName, mimeType), result)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode == requestSavePermission) {
            val result = pendingPermissionResult
            val args = pendingSaveArgs
            pendingPermissionResult = null
            pendingSaveArgs = null
            if (result != null && args != null) {
                val granted =
                    grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED
                if (granted) {
                    saveNow(args, result)
                } else {
                    result.error(
                        "permission_denied",
                        "Storage permission is required to save exports on this Android version.",
                        null,
                    )
                }
            }
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun requestSave(args: SaveArgs, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            pendingPermissionResult = result
            pendingSaveArgs = args
            requestPermissions(
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                requestSavePermission,
            )
            return
        }
        saveNow(args, result)
    }

    private fun saveNow(args: SaveArgs, result: MethodChannel.Result) {
        val source = File(args.sourcePath)
        if (!source.isFile) {
            result.error("missing_source", "Exported audio file was not found.", null)
            return
        }
        try {
            val displayPath =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveWithMediaStore(source, args)
                } else {
                    saveToPublicMusic(source, args)
                }
            result.success(mapOf("displayPath" to displayPath))
        } catch (error: Exception) {
            result.error("save_failed", error.message ?: "Unable to save the export.", null)
        }
    }

    private fun saveWithMediaStore(source: File, args: SaveArgs): String {
        val relativeFolder = publicRelativePath
        val resolver = contentResolver
        val fileName = uniqueFileName(args.fileName) { candidate ->
            resolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Audio.Media._ID),
                "${MediaStore.Audio.Media.DISPLAY_NAME}=? AND " +
                    "${MediaStore.Audio.Media.RELATIVE_PATH}=?",
                arrayOf(candidate, "$relativeFolder/"),
                null,
            ).use { cursor -> cursor != null && cursor.count > 0 }
        }
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Audio.Media.MIME_TYPE, args.mimeType)
            put(MediaStore.Audio.Media.RELATIVE_PATH, "$relativeFolder/")
            put(MediaStore.Audio.Media.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("MediaStore insert failed.")
        try {
            resolver.openOutputStream(uri)?.use { output ->
                source.inputStream().use { input -> input.copyTo(output) }
            } ?: throw IllegalStateException("Unable to open the MediaStore output.")
            val ready = ContentValues().apply {
                put(MediaStore.Audio.Media.IS_PENDING, 0)
            }
            resolver.update(uri, ready, null, null)
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
        return "$relativeFolder/$fileName"
    }

    @Suppress("DEPRECATION")
    private fun saveToPublicMusic(source: File, args: SaveArgs): String {
        val musicDirectory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_MUSIC,
        )
        val directory = File(musicDirectory, "AudioCut")
        if (!directory.isDirectory && !directory.mkdirs()) {
            throw IllegalStateException("Unable to create $publicRelativePath.")
        }
        val fileName = uniqueFileName(args.fileName) { candidate ->
            File(directory, candidate).exists()
        }
        val target = File(directory, fileName)
        source.inputStream().use { input ->
            target.outputStream().use { output -> input.copyTo(output) }
        }
        MediaScannerConnection.scanFile(
            this,
            arrayOf(target.absolutePath),
            arrayOf(args.mimeType),
            null,
        )
        return "$publicRelativePath/$fileName"
    }

    private fun uniqueFileName(preferred: String, taken: (String) -> Boolean): String {
        if (!taken(preferred)) return preferred
        val dotIndex = preferred.lastIndexOf('.')
        val base =
            if (dotIndex > 0) preferred.substring(0, dotIndex) else preferred
        val extension =
            if (dotIndex > 0) preferred.substring(dotIndex) else ""
        var index = 1
        while (true) {
            val candidate = "$base ($index)$extension"
            if (!taken(candidate)) return candidate
            index++
        }
    }
}
