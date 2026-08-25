package dev.octo.octo_note

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

/**
 * 极简蓝牙 RFCOMM 传输（SPP）：
 * - 服务端 accept + 客户端 connect，连接以自增 id 标识
 * - 数据经 EventChannel("prinia/bt_events") 以 {event,id,...} 推送
 * - 发送走 MethodChannel("prinia/bt") 的 send(id, bytes)
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "PriniaBt"
        private val SYNC_UUID: UUID = UUID.fromString("8b6d5c1e-4a2f-4c3b-9d0e-1f2a3b4c5d6e")
        private const val REQUEST_ENABLE_BT = 41
        private const val REQUEST_CONNECT_PERM = 42
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var pendingEnableResult: MethodChannel.Result? = null
    private var pendingPermResult: MethodChannel.Result? = null

    private val btAdapter: BluetoothAdapter?
        get() = (getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private val connections = ConcurrentHashMap<Int, BluetoothSocket>()
    private val connId = AtomicInteger(0)
    private var serverSocket: BluetoothServerSocket? = null
    @Volatile private var serverRunning = false

    @SuppressLint("MissingPermission")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "prinia/bt_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                }
                override fun onCancel(args: Any?) {
                    eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "prinia/bt")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "isOn" -> result.success(btAdapter?.isEnabled == true)
                        "myName" -> result.success(btAdapter?.name ?: "")
                        "requestEnable" -> {
                            val adapter = btAdapter
                            if (adapter == null || adapter.isEnabled) {
                                result.success(adapter?.isEnabled == true)
                            } else {
                                pendingEnableResult = result
                                val intent = android.content.Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                                ActivityCompat.startActivity(this, intent, null)
                            }
                        }
                        "requestConnectPermission" -> requestConnectPermission(result)
                        "bondedDevices" -> {
                            requireConnectPermission()
                            val list = btAdapter?.bondedDevices?.map {
                                mapOf("address" to it.address, "name" to (it.name ?: it.address))
                            } ?: emptyList()
                            result.success(list)
                        }
                        "startServer" -> {
                            requireConnectPermission()
                            startServer()
                            result.success(null)
                        }
                        "stopServer" -> {
                            serverRunning = false
                            try { serverSocket?.close() } catch (_: IOException) {}
                            result.success(null)
                        }
                        "connect" -> {
                            requireConnectPermission()
                            val address = call.argument<String>("address")!!
                            connectTo(address, result)
                        }
                        "send" -> {
                            val id = call.argument<Int>("id")!!
                            val data = call.arguments as? Map<*, *>
                            val bytes = data?.get("bytes") as? ByteArray
                                ?: call.argument<ByteArray>("bytes")!!
                            val sock = connections[id]
                            if (sock == null) {
                                result.error("closed", "connection $id closed", null)
                            } else {
                                sock.outputStream.write(bytes)
                                result.success(null)
                            }
                        }
                        "closeConn" -> {
                            connections.remove(call.argument<Int>("id"))?.close()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: SecurityException) {
                    result.error("permission", e.message, null)
                } catch (e: IOException) {
                    result.error("io", e.message, null)
                }
            }
    }

    private fun hasConnectPermission(): Boolean =
        Build.VERSION.SDK_INT < 31 ||
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED

    private fun requireConnectPermission() {
        if (!hasConnectPermission()) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
                REQUEST_CONNECT_PERM,
            )
            throw SecurityException("BLUETOOTH_CONNECT 未授权")
        }
    }

    private fun requestConnectPermission(result: MethodChannel.Result) {
        if (hasConnectPermission()) {
            result.success(true)
            return
        }
        pendingPermResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
            REQUEST_CONNECT_PERM,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CONNECT_PERM) {
            pendingPermResult?.success(grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED)
            pendingPermResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ENABLE_BT) {
            pendingEnableResult?.success(resultCode == RESULT_OK)
            pendingEnableResult = null
        }
    }

    private fun emit(map: Map<String, Any?>) {
        mainHandler.post {
            try { eventSink?.success(map) } catch (_: Exception) {}
        }
    }

    @SuppressLint("MissingPermission")
    private fun startServer() {
        val adapter = btAdapter ?: throw IOException("无蓝牙适配器")
        if (!adapter.isEnabled) throw IOException("蓝牙未开启")
        if (serverRunning) return
        serverRunning = true
        Log.i(TAG, "server started")
        Thread {
            try {
                serverSocket = adapter.listenUsingRfcommWithServiceRecord("PriniaSync", SYNC_UUID)
                while (serverRunning) {
                    val sock = try { serverSocket!!.accept() } catch (_: IOException) { break }
                    if (!serverRunning) { try { sock.close() } catch (_: IOException) {} ; break }
                    Log.i(TAG, "server accepted connection")
                    registerConnection(sock, incoming = true)
                }
            } catch (e: Exception) {
                Log.w(TAG, "server: ${e.message}")
                serverRunning = false
            }
        }.start()
    }

    @SuppressLint("MissingPermission")
    private fun connectTo(address: String, result: MethodChannel.Result) {
        val adapter = btAdapter ?: throw IOException("无蓝牙适配器")
        if (!adapter.isEnabled) throw IOException("蓝牙未开启")
        Thread {
            var sock: BluetoothSocket? = null
            try {
                sock = adapter.getRemoteDevice(address)
                    .createRfcommSocketToServiceRecord(SYNC_UUID)
                sock.connect()
                val id = registerConnection(sock, incoming = false)
                mainHandler.post { result.success(id) }
            } catch (e: Exception) {
                Log.w(TAG, "connect: ${e.message}")
                try { sock?.close() } catch (_: IOException) {}
                mainHandler.post { result.error("connect", e.message, null) }
            }
        }.start()
    }

    @SuppressLint("MissingPermission")
    private fun registerConnection(sock: BluetoothSocket, incoming: Boolean): Int {
        val id = connId.incrementAndGet()
        connections[id] = sock
        val name = try { sock.remoteDevice.name } catch (_: SecurityException) { null }
        Log.i(TAG, "connection opened id=\$id incoming=\$incoming name=\$name")
        emit(mapOf(
            "event" to "opened",
            "id" to id,
            "address" to sock.remoteDevice.address,
            "name" to (name ?: sock.remoteDevice.address),
            "incoming" to incoming,
        ))
        Thread {
            val buf = ByteArray(4096)
            try {
                while (true) {
                    val n = sock.inputStream.read(buf)
                    if (n <= 0) break
                    emit(mapOf(
                        "event" to "data",
                        "id" to id,
                        "bytes" to buf.copyOf(n),
                    ))
                }
            } catch (_: IOException) {}
            connections.remove(id)
            Log.i(TAG, "connection closed id=\$id")
            emit(mapOf("event" to "closed", "id" to id))
        }.start()
        return id
    }
}
