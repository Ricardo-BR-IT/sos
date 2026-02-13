package com.resgatesos.core;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Consumer;

public class MeshRouter {
    private final CryptoManager crypto;
    private final MeshTransport transport;
    private final Map<String, Long> seen = new ConcurrentHashMap<>();
    private Consumer<SosEnvelope> onMessage;

    public MeshRouter(CryptoManager crypto, MeshTransport transport) {
        this.crypto = crypto;
        this.transport = transport;
    }

    public void setOnMessage(Consumer<SosEnvelope> onMessage) {
        this.onMessage = onMessage;
    }

    public void handleRaw(String raw) {
        SosFrame frame;
        try {
            frame = SosFrame.fromJsonString(raw);
        } catch (Exception e) {
            try {
                SosEnvelope legacy = SosEnvelope.fromJsonString(raw);
                frame = SosFrame.wrap(legacy, 1);
            } catch (Exception ex) {
                return;
            }
        }

        SosEnvelope envelope = frame.envelope;
        if (!envelope.verify(crypto)) return;
        if (!SosFrame.computeId(envelope).equals(frame.id)) return;
        if (seen.containsKey(frame.id)) return;
        seen.put(frame.id, Instant.now().toEpochMilli());

        boolean forMe = envelope.isBroadcast() ||
                crypto.getPublicKeyBase64().equals(envelope.getTarget());
        if (forMe && onMessage != null) {
            onMessage.accept(envelope);
        }

        if (frame.ttl > 0) {
            SosFrame forwarded = new SosFrame(frame.id, frame.ttl - 1, frame.hops + 1, envelope);
            transport.broadcast(forwarded.toJsonString());
        }
    }

    public void broadcast(String type, Map<String, Object> payload, int ttl) throws Exception {
        SosEnvelope envelope = SosEnvelope.sign(crypto, type, payload);
        SosFrame frame = SosFrame.wrap(envelope, ttl);
        transport.broadcast(frame.toJsonString());
    }

    public void sendDirect(String targetId, String type, Map<String, Object> payload, int ttl) throws Exception {
        payload.put("target", targetId);
        broadcast(type, payload, ttl);
    }
}

