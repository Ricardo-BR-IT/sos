package com.resgatesos.core;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class MeshNode {
    private final CryptoManager crypto;
    private final MeshRouter router;
    private final TcpMeshTransport transport;
    private final Timer helloTimer = new Timer(true);
    private final String displayName;

    public MeshNode(String displayName, int port) throws Exception {
        this.crypto = new CryptoManager();
        this.transport = new TcpMeshTransport(port);
        this.transport.setLocalId(crypto.getPublicKeyBase64());
        this.router = new MeshRouter(crypto, transport);
        this.displayName = displayName;
    }

    public void start() throws Exception {
        transport.onMessage(router::handleRaw);
        transport.start();
        sendHello();
        helloTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                try {
                    sendHello();
                } catch (Exception ignored) {
                }
            }
        }, 30000, 30000);
    }

    public void onMessage(java.util.function.Consumer<SosEnvelope> handler) {
        router.setOnMessage(handler);
    }

    public void sendBroadcast(String type, Map<String, Object> payload) throws Exception {
        router.broadcast(type, payload, 8);
    }

    public void sendHello() throws Exception {
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", displayName);
        payload.put("platform", "java");
        payload.put("appVersion", "0.2.x");
        router.broadcast("hello", payload, 8);
    }

    public String getPublicId() {
        return crypto.getPublicKeyBase64();
    }
}
