package com.resgatesos.core;

import javax.jmdns.JmDNS;
import javax.jmdns.ServiceEvent;
import javax.jmdns.ServiceInfo;
import javax.jmdns.ServiceListener;
import java.io.IOException;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

public class MdnsService {
    private static final String SERVICE_TYPE = "_sos-mesh._tcp.local.";
    private final int port;
    private final String nodeId;
    private final BiConsumer<String, Integer> onDiscovered;
    private JmDNS jmdns;

    public MdnsService(int port, String nodeId, BiConsumer<String, Integer> onDiscovered) {
        this.port = port;
        this.nodeId = nodeId;
        this.onDiscovered = onDiscovered;
    }

    public void start() {
        try {
            jmdns = JmDNS.create(InetAddress.getLocalHost());
            Map<String, String> props = new HashMap<>();
            props.put("id", nodeId != null ? nodeId.substring(0, Math.min(10, nodeId.length())) : "unknown");
            ServiceInfo serviceInfo = ServiceInfo.create(SERVICE_TYPE, "sos_" + props.get("id"), port, 0, 0, props);
            jmdns.registerService(serviceInfo);
            jmdns.addServiceListener(SERVICE_TYPE, new ServiceListener() {
                @Override
                public void serviceAdded(ServiceEvent event) {
                    jmdns.requestServiceInfo(event.getType(), event.getName(), true);
                }

                @Override
                public void serviceRemoved(ServiceEvent event) {
                }

                @Override
                public void serviceResolved(ServiceEvent event) {
                    ServiceInfo info = event.getInfo();
                    if (info == null || info.getHostAddresses().length == 0) return;
                    String host = info.getHostAddresses()[0];
                    if (host != null) {
                        onDiscovered.accept(host, info.getPort());
                    }
                }
            });
        } catch (IOException ignored) {
        }
    }

    public void stop() {
        if (jmdns != null) {
            try {
                jmdns.unregisterAllServices();
                jmdns.close();
            } catch (IOException ignored) {
            }
        }
    }
}
