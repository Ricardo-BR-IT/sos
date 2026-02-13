package com.resgatesos.mini;

import com.resgatesos.core.MeshNode;
import com.resgatesos.core.SosEnvelope;

public class MiniMain {
    public static void main(String[] args) throws Exception {
        MeshNode node = new MeshNode("Java Mini", 4000);
        node.onMessage(MiniMain::printMessage);
        node.start();
        System.out.println("[mini] Resgate SOS Mesh online. ID=" + node.getPublicId());
        Thread.currentThread().join();
    }

    private static void printMessage(SosEnvelope envelope) {
        System.out.println("[mini] message type=" + envelope.type +
                " from=" + envelope.sender.substring(0, 10));
    }
}
