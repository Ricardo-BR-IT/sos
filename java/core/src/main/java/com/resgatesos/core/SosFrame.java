package com.resgatesos.core;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class SosFrame {
    public String id;
    public int ttl;
    public int hops;
    public SosEnvelope envelope;

    public SosFrame() {}

    public SosFrame(String id, int ttl, int hops, SosEnvelope envelope) {
        this.id = id;
        this.ttl = ttl;
        this.hops = hops;
        this.envelope = envelope;
    }

    public String toJsonString() {
        return new Gson().toJson(this);
    }

    public static SosFrame wrap(SosEnvelope envelope, int ttl) {
        return new SosFrame(computeId(envelope), ttl, 0, envelope);
    }

    public static SosFrame fromJsonString(String raw) {
        JsonObject obj = new Gson().fromJson(raw, JsonObject.class);
        SosFrame frame = new SosFrame();
        frame.id = obj.get("id").getAsString();
        frame.ttl = obj.get("ttl").getAsInt();
        frame.hops = obj.get("hops").getAsInt();
        frame.envelope = new Gson().fromJson(obj.get("envelope"), SosEnvelope.class);
        return frame;
    }

    public static String computeId(SosEnvelope envelope) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String raw = envelope.canonicalBody() + "|" + envelope.signature;
            byte[] data = raw.getBytes(StandardCharsets.UTF_8);
            byte[] hash = digest.digest(data);
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return Integer.toHexString(envelope.toJsonString().hashCode());
        }
    }
}
