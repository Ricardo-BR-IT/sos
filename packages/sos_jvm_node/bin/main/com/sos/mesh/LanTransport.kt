package com.sos.mesh

import java.net.ServerSocket
import java.net.Socket
import java.io.PrintWriter
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.ConcurrentHashMap
import javax.jmdns.JmDNS
import javax.jmdns.ServiceInfo
import javax.jmdns.ServiceListener
import javax.jmdns.ServiceEvent
import kotlinx.coroutines.*
import java.net.InetAddress

class LanTransport(val nodeId: String, val port: Int = 4001) {
    private val peers = ConcurrentHashMap<String, PeerInfo>()
    private var serverSocket: ServerSocket? = null
    private var jmdns: JmDNS? = null
    private val scope = CoroutineScope(Dispatchers.IO + Job())

    data class PeerInfo(val id: String, val ip: String, val port: Int)

    fun start() {
        startServer()
        registerService()
        discoverServices()
    }

    private fun startServer() {
        scope.launch {
            try {
                serverSocket = ServerSocket(port)
                println("JVM Node listening on port $port")
                while (isActive) {
                    val client = serverSocket?.accept() ?: break
                    handleClient(client)
                }
            } catch (e: Exception) {
                if (isActive) println("Server socket error: ${e.message}")
            }
        }
    }

    private fun handleClient(socket: Socket) {
        scope.launch {
            try {
                val reader = BufferedReader(InputStreamReader(socket.getInputStream()))
                val line = reader.readLine()
                if (line != null) {
                    val packet = TransportPacket.fromJson(line)
                    println("Received packet from ${packet.s} via LAN: ${packet.id}")
                }
            } catch (e: Exception) {
                println("Client handling error: ${e.message}")
            } finally {
                socket.close()
            }
        }
    }

    private fun registerService() {
        scope.launch {
            try {
                jmdns = JmDNS.create(InetAddress.getLocalHost())
                val info = ServiceInfo.create("_sos._tcp.local.", nodeId, port, "id=$nodeId")
                jmdns?.registerService(info)
                println("Service registered via mDNS: $nodeId")
            } catch (e: Exception) {
                println("mDNS registration error: ${e.message}")
            }
        }
    }

    private fun discoverServices() {
        jmdns?.addServiceListener("_sos._tcp.local.", object : ServiceListener {
            override fun serviceAdded(event: ServiceEvent) {
                jmdns?.requestServiceInfo(event.type, event.name)
            }

            override fun serviceRemoved(event: ServiceEvent) {
                // In some JmDNS versions, info might be null or outdated
                val id = event.info?.getPropertyString("id")
                if (id != null) {
                    peers.remove(id)
                    println("Peer lost: $id")
                }
            }

            override fun serviceResolved(event: ServiceEvent) {
                val id = event.info.getPropertyString("id")
                if (id != null && id != nodeId) {
                    val ip = event.info.inet4Addresses.firstOrNull()?.hostAddress ?: ""
                    if (ip.isNotEmpty()) {
                        peers[id] = PeerInfo(id, ip, event.info.port)
                        println("Peer discovered: $id at $ip:${event.info.port}")
                    }
                }
            }
        })
    }

    fun send(peerId: String, packet: TransportPacket) {
        val peer = peers[peerId] ?: return
        scope.launch {
            try {
                Socket(peer.ip, peer.port).use { socket ->
                    val writer = PrintWriter(socket.getOutputStream(), true)
                    writer.println(packet.toJson())
                }
            } catch (e: Exception) {
                println("Failed to send to $peerId: ${e.message}")
            }
        }
    }

    fun stop() {
        scope.cancel()
        serverSocket?.close()
        jmdns?.unregisterAllServices()
        jmdns?.close()
    }
}
