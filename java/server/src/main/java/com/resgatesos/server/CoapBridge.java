package com.resgatesos.server;

import com.google.gson.Gson;
import com.resgatesos.core.MeshNode;

import org.eclipse.californium.core.CoapResource;
import org.eclipse.californium.core.CoapServer;
import org.eclipse.californium.core.coap.CoAP;
import org.eclipse.californium.core.server.resources.CoapExchange;

import java.util.HashMap;
import java.util.Map;

public class CoapBridge {
    private final CoapServer server;
    private final MeshNode node;
    private final Gson gson = new Gson();

    public CoapBridge(MeshNode node, int port) {
        this.node = node;
        this.server = new CoapServer(port);
        registerResources();
    }

    private void registerResources() {
        server.add(new CoapResource("status") {
            @Override
            public void handleGET(CoapExchange exchange) {
                Map<String, Object> payload = new HashMap<>();
                payload.put("ok", true);
                payload.put("node", node.getPublicId());
                exchange.respond(CoAP.ResponseCode.CONTENT, gson.toJson(payload));
            }
        });

        server.add(new CoapResource("broadcast") {
            @Override
            public void handlePOST(CoapExchange exchange) {
                String body = exchange.getRequestText();
                if (body == null || body.trim().isEmpty()) {
                    exchange.respond(CoAP.ResponseCode.BAD_REQUEST, "Empty payload");
                    return;
                }
                Map<String, Object> data = gson.fromJson(body,
                        new com.google.gson.reflect.TypeToken<Map<String, Object>>() {
                        }.getType());
                if (data == null || !data.containsKey("type")) {
                    exchange.respond(CoAP.ResponseCode.BAD_REQUEST, "Missing type");
                    return;
                }
                String type = data.get("type").toString();
                @SuppressWarnings("unchecked")
                Map<String, Object> payload = data.containsKey("payload")
                        ? (Map<String, Object>) data.get("payload")
                        : new HashMap<>();
                try {
                    node.sendBroadcast(type, payload);
                    exchange.respond(CoAP.ResponseCode.CHANGED, "ok");
                } catch (Exception e) {
                    exchange.respond(CoAP.ResponseCode.INTERNAL_SERVER_ERROR, "Broadcast failed");
                }
            }
        });
    }

    public void start() {
        server.start();
    }

    public void stop() {
        server.stop();
    }
}
