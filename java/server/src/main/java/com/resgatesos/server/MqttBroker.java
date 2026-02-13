package com.resgatesos.server;

import io.moquette.broker.Server;
import io.moquette.broker.config.MemoryConfig;

import java.io.IOException;
import java.util.Properties;

public class MqttBroker {
    private final int port;
    private final String host;
    private Server broker;

    public MqttBroker(int port, String host) {
        this.port = port;
        this.host = host;
    }

    public void start() throws IOException {
        Properties props = new Properties();
        props.setProperty("port", Integer.toString(port));
        props.setProperty("host", host);
        props.setProperty("allow_anonymous", "true");
        broker = new Server();
        broker.startServer(new MemoryConfig(props));
    }

    public void stop() {
        if (broker != null) {
            broker.stopServer();
            broker = null;
        }
    }
}
