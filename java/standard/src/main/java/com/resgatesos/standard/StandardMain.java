package com.resgatesos.standard;

import com.resgatesos.core.MeshNode;
import com.resgatesos.core.SosEnvelope;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

public class StandardMain {
    public static void main(String[] args) throws Exception {
        MeshNode node = new MeshNode("Java Standard", 4000);
        node.onMessage(StandardMain::printMessage);
        node.start();
        System.out.println("[standard] Resgate SOS Mesh online. ID=" + node.getPublicId());
        System.out.println("[standard] Digite 'sos' para broadcast ou 'exit' para sair.");

        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String line;
        while ((line = reader.readLine()) != null) {
            if ("exit".equalsIgnoreCase(line.trim())) break;
            if ("sos".equalsIgnoreCase(line.trim())) {
                Map<String, Object> payload = new HashMap<>();
                payload.put("message", "SOS Java Standard");
                node.sendBroadcast("sos", payload);
            }
        }
    }

    private static void printMessage(SosEnvelope envelope) {
        System.out.println("[standard] message type=" + envelope.type +
                " from=" + envelope.sender.substring(0, 10));
    }
}
