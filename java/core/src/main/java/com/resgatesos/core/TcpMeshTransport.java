package com.resgatesos.core;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Consumer;

public class TcpMeshTransport implements MeshTransport {
    private final int port;
    private ServerSocket serverSocket;
    private final List<Socket> sockets = new CopyOnWriteArrayList<>();
    private Consumer<String> onMessage;
    private String localId;
    private MdnsService mdnsService;

    public TcpMeshTransport(int port) {
        this.port = port;
    }

    @Override
    public void start() throws Exception {
        serverSocket = new ServerSocket(port);
        Thread acceptThread = new Thread(() -> {
            while (!serverSocket.isClosed()) {
                try {
                    Socket socket = serverSocket.accept();
                    registerSocket(socket);
                } catch (Exception e) {
                    break;
                }
            }
        }, "mesh-accept");
        acceptThread.setDaemon(true);
        acceptThread.start();

        mdnsService = new MdnsService(port, localId, this::connect);
        mdnsService.start();
    }

    @Override
    public void stop() {
        try {
            if (mdnsService != null) mdnsService.stop();
            for (Socket socket : sockets) socket.close();
            if (serverSocket != null) serverSocket.close();
        } catch (Exception ignored) {
        }
    }

    @Override
    public void broadcast(String message) {
        for (Socket socket : sockets) {
            try {
                PrintWriter writer = new PrintWriter(new OutputStreamWriter(socket.getOutputStream()), true);
                writer.println(message);
            } catch (Exception e) {
                sockets.remove(socket);
            }
        }
    }

    @Override
    public void onMessage(Consumer<String> handler) {
        this.onMessage = handler;
    }

    @Override
    public void setLocalId(String id) {
        this.localId = id;
    }

    public void connect(String host, int port) {
        try {
            Socket socket = new Socket(host, port);
            registerSocket(socket);
        } catch (Exception ignored) {
        }
    }

    private void registerSocket(Socket socket) {
        sockets.add(socket);
        Thread thread = new Thread(() -> {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (onMessage != null) onMessage.accept(line);
                }
            } catch (Exception ignored) {
            } finally {
                sockets.remove(socket);
                try {
                    socket.close();
                } catch (Exception ignored) {
                }
            }
        }, "mesh-socket");
        thread.setDaemon(true);
        thread.start();
    }
}

