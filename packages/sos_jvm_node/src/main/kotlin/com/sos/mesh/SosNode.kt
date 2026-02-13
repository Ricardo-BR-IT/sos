package com.sos.mesh

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.encodeToString

@Serializable
enum class SosPacketType {
    HELLO, HELLO_ACK, DATA, SOS, PING, PONG, DISCOVERY
}

@Serializable
data class TransportPacket(
    val id: String,
    val s: String, // senderId
    val r: String? = null, // recipientId
    val t: Int, // type index
    val p: JsonObject, // payload
    val ts: Long, // timestamp
    val ttl: Int = 3,
    val sig: String? = null,
    val m: JsonObject? = null // metadata
) {
    fun toJson(): String = Json.encodeToString(this)
    
    companion object {
        fun fromJson(json: String): TransportPacket = Json.decodeFromString(json)
    }
}

class SosNode(val nodeId: String) {
    private val seenIds = mutableSetOf<String>()
    private val transport = LanTransport(nodeId)

    fun start() {
        transport.start()
        println("SosNode $nodeId started")
    }

    fun handleIncomingPacket(packet: TransportPacket) {
        if (packet.id in seenIds) return
        seenIds.add(packet.id)
        
        val type = if (packet.t < SosPacketType.values().size) SosPacketType.values()[packet.t] else "UNKNOWN"
        println("Node $nodeId processed packet: ${packet.id} of type $type from ${packet.s}")
        
        // Flooding logic: re-broadcast if needed
    }

    fun stop() {
        transport.stop()
    }
}
