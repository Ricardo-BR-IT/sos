package com.resgatesos.core;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class SosEnvelope {
    public int v;
    public String type;
    public String sender;
    public long timestamp;
    public Map<String, Object> payload;
    public String signature;

    public SosEnvelope() {
    }

    public SosEnvelope(int v, String type, String sender, long timestamp,
            Map<String, Object> payload, String signature) {
        this.v = v;
        this.type = type;
        this.sender = sender;
        this.timestamp = timestamp;
        this.payload = payload;
        this.signature = signature;
    }

    public static SosEnvelope sign(CryptoManager crypto, String type, Map<String, Object> payload) throws Exception {
        long ts = System.currentTimeMillis();
        String sender = crypto.getPublicKeyBase64();
        String body = canonicalBody(1, type, sender, ts, payload);
        String sig = crypto.sign(body);
        return new SosEnvelope(1, type, sender, ts, payload, sig);
    }

    public boolean verify(CryptoManager crypto) {
        String body = canonicalBody(v, type, sender, timestamp, payload);
        return crypto.verify(body, signature, sender);
    }

    public String toJsonString() {
        return new Gson().toJson(toJson());
    }

    public Map<String, Object> toJson() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("v", v);
        data.put("type", type);
        data.put("sender", sender);
        data.put("timestamp", timestamp);
        data.put("payload", payload);
        data.put("signature", signature);
        return data;
    }

    public String canonicalBody() {
        return canonicalBody(v, type, sender, timestamp, payload);
    }

    public static SosEnvelope fromJsonString(String raw) {
        JsonObject obj = new Gson().fromJson(raw, JsonObject.class);
        SosEnvelope envelope = new SosEnvelope();
        envelope.v = obj.get("v").getAsInt();
        envelope.type = obj.get("type").getAsString();
        envelope.sender = obj.get("sender").getAsString();
        envelope.timestamp = obj.get("timestamp").getAsLong();
        envelope.signature = obj.get("signature").getAsString();
        envelope.payload = new Gson().fromJson(obj.get("payload"),
                new com.google.gson.reflect.TypeToken<Map<String, Object>>() {
                }.getType());
        return envelope;
    }

    public String getTarget() {
        Object target = payload != null ? payload.get("target") : null;
        return target == null ? null : target.toString();
    }

    public boolean isBroadcast() {
        String t = getTarget();
        return t == null || t.isEmpty() || "*".equals(t);
    }

    private static String canonicalBody(int v, String type, String sender, long timestamp,
            Map<String, Object> payload) {
        Map<String, Object> body = new HashMap<>();
        body.put("v", v);
        body.put("type", type);
        body.put("sender", sender);
        body.put("timestamp", timestamp);
        body.put("payload", payload);
        return new Gson().toJson(normalize(body));
    }

    private static Object normalize(Object value) {
        if (value instanceof Map) {
            TreeMap<String, Object> sorted = new TreeMap<>();
            ((Map<?, ?>) value).forEach((k, v) -> sorted.put(k.toString(), normalize(v)));
            return sorted;
        }
        if (value instanceof List) {
            return ((List<?>) value).stream().map(SosEnvelope::normalize).toList();
        }
        return value;
    }
}
