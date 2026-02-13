package com.resgatesos.core;

import java.util.function.Consumer;

public interface MeshTransport {
    void start() throws Exception;
    void stop();
    void broadcast(String message);
    void onMessage(Consumer<String> handler);
    void setLocalId(String id);
}
