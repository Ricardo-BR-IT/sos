package com.resgatesos.server;

import com.google.gson.Gson;
import com.resgatesos.core.MeshNode;
import com.resgatesos.core.SosEnvelope;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.Collections;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class ServerMain {
    public static void main(String[] args) throws Exception {
        Map<String, String> flags = parseArgs(args);
        int meshPort = readPort(flags, "mesh-port", 4000, "SOS_MESH_PORT");
        int httpPort = readPort(flags, "port", 8080, "SOS_HTTP_PORT");
        String webRoot = resolveWebRoot(flags);
        int telemetryRetention = readInt(flags, "telemetry-retention", 7, "SOS_TELEMETRY_RETENTION_DAYS");
        Path dataDir = resolveDataDir(flags);
        boolean mqttEnabled = readBool(flags, "mqtt-enable", true, "SOS_MQTT_ENABLE");
        int mqttPort = readInt(flags, "mqtt-port", 1883, "SOS_MQTT_PORT");
        String mqttHost = readString(flags, "mqtt-host", "0.0.0.0", "SOS_MQTT_HOST");
        boolean coapEnabled = readBool(flags, "coap-enable", true, "SOS_COAP_ENABLE");
        int coapPort = readInt(flags, "coap-port", 5683, "SOS_COAP_PORT");
        HardwareProfile hardwareProfile = HardwareProfile.detect(dataDir);

        MeshNode node = new MeshNode("Java Server", meshPort);
        TelemetryStore telemetry = new TelemetryStore(dataDir, telemetryRetention);
        String telemetrySession = "java-" + UUID.randomUUID();
        node.onMessage(envelope -> {
            printMessage(envelope);
            appendTelemetry(telemetry, buildTelemetryEvent(
                    telemetrySession,
                    node.getPublicId(),
                    "mesh_message",
                    Map.of(
                            "type", envelope.type,
                            "sender", envelope.sender)));
        });
        node.start();

        appendTelemetry(telemetry, buildTelemetryEvent(
                telemetrySession,
                node.getPublicId(),
                "server_start",
                Map.of(
                        "httpPort", httpPort,
                        "meshPort", meshPort,
                        "webRoot", webRoot,
                        "mqttEnabled", mqttEnabled,
                        "mqttPort", mqttPort,
                        "coapEnabled", coapEnabled,
                        "coapPort", coapPort)));
        appendTelemetry(telemetry, buildTelemetryEvent(
                telemetrySession,
                node.getPublicId(),
                "hardware_profile",
                hardwareProfile.toMap()));

        HttpServer server = HttpServer.create(new InetSocketAddress(httpPort), 0);
        server.createContext("/status", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            Map<String, Object> payload = new HashMap<>();
            payload.put("edition", "server");
            payload.put("id", node.getPublicId());
            payload.put("httpPort", httpPort);
            payload.put("meshPort", meshPort);
            payload.put("webRoot", webRoot);
            payload.put("assistantVersion", AssistantEngine.VERSION);
            payload.put("telemetryRetentionDays", telemetryRetention);
            payload.put("dataDir", dataDir.toString());
            payload.put("hardwareFlags", hardwareProfile.toMap().get("flags"));
            payload.put("mqttEnabled", mqttEnabled);
            payload.put("mqttPort", mqttPort);
            payload.put("coapEnabled", coapEnabled);
            payload.put("coapPort", coapPort);
            sendJson(exchange, payload);
        });

        server.createContext("/sos", exchange -> {
            if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            Map<String, Object> payload = new HashMap<>();
            payload.put("message", "SOS Java Server");
            try {
                node.sendBroadcast("sos", payload);
                sendJson(exchange, Map.of("ok", true));
            } catch (Exception e) {
                send(exchange, 500, "Broadcast failed");
            }
        });

        server.createContext("/broadcast", exchange -> {
            if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            String body = readBody(exchange.getRequestBody());
            Map<String, Object> data = new Gson().fromJson(body, Map.class);
            if (data == null || !data.containsKey("type")) {
                send(exchange, 400, "Missing type");
                return;
            }
            String type = data.get("type").toString();
            Map<String, Object> payload = data.containsKey("payload")
                    ? (Map<String, Object>) data.get("payload")
                    : new HashMap<>();
            try {
                node.sendBroadcast(type, payload);
                sendJson(exchange, Map.of("ok", true));
            } catch (Exception e) {
                send(exchange, 500, "Broadcast failed");
            }
        });

        server.createContext("/assistant/catalog", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            sendJson(exchange, AssistantEngine.catalog());
        });

        server.createContext("/assistant", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())
                    && !"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            Map<String, String> params = new LinkedHashMap<>(parseQuery(exchange.getRequestURI()));
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                String body = readBody(exchange.getRequestBody());
                if (!body.trim().isEmpty()) {
                    Map<String, Object> data = new Gson().fromJson(body, Map.class);
                    params.putAll(extractParams(data));
                }
            }
            if (params.isEmpty()) {
                sendJson(exchange, AssistantEngine.catalog());
                return;
            }
            sendJson(exchange, AssistantEngine.build(params));
        });

        server.createContext("/telemetry", exchange -> {
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                String body = readBody(exchange.getRequestBody());
                if (body == null || body.trim().isEmpty()) {
                    send(exchange, 400, "Empty payload");
                    return;
                }
                List<Map<String, Object>> events = parseTelemetryPayload(body);
                if (events.isEmpty()) {
                    send(exchange, 400, "Invalid telemetry payload");
                    return;
                }
                int count;
                try {
                    count = telemetry.append(events);
                } catch (IOException e) {
                    send(exchange, 500, "Failed to store telemetry");
                    return;
                }
                sendJson(exchange, Map.of("ok", true, "count", count));
                return;
            }
            if ("GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                Map<String, String> params = parseQuery(exchange.getRequestURI());
                int limit = parseIntParam(params, "limit", 200);
                Instant since = parseInstantParam(params.get("since"));
                List<Map<String, Object>> events;
                try {
                    events = telemetry.loadRecent(limit, since);
                } catch (IOException e) {
                    send(exchange, 500, "Failed to read telemetry");
                    return;
                }
                sendJson(exchange, events);
                return;
            }
            send(exchange, 405, "Method Not Allowed");
        });

        server.createContext("/telemetry/summary", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            Map<String, String> params = parseQuery(exchange.getRequestURI());
            Instant since = parseInstantParam(params.get("since"));
            Map<String, Object> summary;
            try {
                summary = telemetry.summary(since);
            } catch (IOException e) {
                send(exchange, 500, "Failed to summarize telemetry");
                return;
            }
            sendJson(exchange, summary);
        });

        server.createContext("/telemetry/export", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            Map<String, String> params = parseQuery(exchange.getRequestURI());
            int limit = parseIntParam(params, "limit", 1000);
            Instant since = parseInstantParam(params.get("since"));
            String format = params.getOrDefault("format", "csv");
            if ("csv".equalsIgnoreCase(format)) {
                String csv;
                try {
                    csv = telemetry.exportCsv(limit, since);
                } catch (IOException e) {
                    send(exchange, 500, "Failed to export telemetry");
                    return;
                }
                exchange.getResponseHeaders().add("Content-Type", "text/csv; charset=utf-8");
                send(exchange, 200, csv);
                return;
            }
            List<Map<String, Object>> events;
            try {
                events = telemetry.loadRecent(limit, since);
            } catch (IOException e) {
                send(exchange, 500, "Failed to export telemetry");
                return;
            }
            sendJson(exchange, events);
        });

        server.createContext("/hardware", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            sendJson(exchange, hardwareProfile.toMap());
        });

        MqttBroker mqttBroker = null;
        if (mqttEnabled) {
            mqttBroker = new MqttBroker(mqttPort, mqttHost);
            try {
                mqttBroker.start();
                appendTelemetry(telemetry, buildTelemetryEvent(
                        telemetrySession,
                        node.getPublicId(),
                        "mqtt_start",
                        Map.of("port", mqttPort, "host", mqttHost)));
            } catch (IOException e) {
                appendTelemetry(telemetry, buildTelemetryEvent(
                        telemetrySession,
                        node.getPublicId(),
                        "mqtt_error",
                        Map.of("error", e.toString())));
            }
        }

        CoapBridge coapBridge = null;
        if (coapEnabled) {
            coapBridge = new CoapBridge(node, coapPort);
            coapBridge.start();
            appendTelemetry(telemetry, buildTelemetryEvent(
                    telemetrySession,
                    node.getPublicId(),
                    "coap_start",
                    Map.of("port", coapPort)));
        }

        Path staticRoot = Paths.get(webRoot).toAbsolutePath().normalize();
        server.createContext("/", exchange -> {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
                send(exchange, 405, "Method Not Allowed");
                return;
            }
            serveStatic(exchange, staticRoot);
        });

        server.setExecutor(null);
        server.start();
        System.out.println("[server] Mesh online. HTTP on :" + httpPort);
        System.out.println("[server] Web root: " + staticRoot);
        if (mqttEnabled) {
            System.out.println("[server] MQTT broker on :" + mqttPort);
        }
        if (coapEnabled) {
            System.out.println("[server] CoAP server on :" + coapPort);
        }
    }

    private static void printMessage(SosEnvelope envelope) {
        String shortId = envelope.sender;
        if (shortId.length() > 10) {
            shortId = shortId.substring(0, 10);
        }
        System.out.println("[server] message type=" + envelope.type +
                " from=" + shortId);
    }

    private static String readBody(InputStream stream) throws IOException {
        return new String(stream.readAllBytes(), StandardCharsets.UTF_8);
    }

    private static Map<String, String> parseArgs(String[] args) {
        Map<String, String> flags = new HashMap<>();
        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            if (!arg.startsWith("--")) {
                continue;
            }
            String key = arg.substring(2);
            String value = "true";
            int eqIndex = key.indexOf('=');
            if (eqIndex >= 0) {
                value = key.substring(eqIndex + 1);
                key = key.substring(0, eqIndex);
            } else if (i + 1 < args.length && !args[i + 1].startsWith("--")) {
                value = args[i + 1];
                i++;
            }
            flags.put(key, value);
        }
        return flags;
    }

    private static int readPort(Map<String, String> flags, String key, int fallback, String envKey) {
        String value = flags.getOrDefault(key, System.getenv(envKey));
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static int readInt(Map<String, String> flags, String key, int fallback, String envKey) {
        String value = flags.getOrDefault(key, System.getenv(envKey));
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static boolean readBool(Map<String, String> flags, String key, boolean fallback, String envKey) {
        String value = flags.getOrDefault(key, System.getenv(envKey));
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        String normalized = value.trim().toLowerCase();
        if ("true".equals(normalized) || "1".equals(normalized) || "yes".equals(normalized)) {
            return true;
        }
        if ("false".equals(normalized) || "0".equals(normalized) || "no".equals(normalized)) {
            return false;
        }
        return fallback;
    }

    private static String readString(Map<String, String> flags, String key, String fallback, String envKey) {
        String value = flags.getOrDefault(key, System.getenv(envKey));
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }

    private static String resolveWebRoot(Map<String, String> flags) {
        String envRoot = System.getenv("SOS_WEB_ROOT");
        String flagRoot = flags.get("web-root");
        if (flagRoot != null && !flagRoot.trim().isEmpty()) {
            return flagRoot;
        }
        if (envRoot != null && !envRoot.trim().isEmpty()) {
            return envRoot;
        }
        Path localWeb = Paths.get("web");
        if (Files.exists(localWeb)) {
            return localWeb.toString();
        }
        Path devWeb = Paths.get("apps", "web_portal", "out-server");
        if (Files.exists(devWeb)) {
            return devWeb.toString();
        }
        return ".";
    }

    private static Path resolveDataDir(Map<String, String> flags) {
        String flagRoot = flags.get("data-dir");
        String envRoot = System.getenv("SOS_DATA_DIR");
        String root = (flagRoot != null && !flagRoot.trim().isEmpty())
                ? flagRoot
                : (envRoot != null && !envRoot.trim().isEmpty() ? envRoot : "data");
        return Paths.get(root).toAbsolutePath().normalize();
    }

    private static Map<String, String> parseQuery(URI uri) {
        Map<String, String> params = new LinkedHashMap<>();
        String query = uri.getRawQuery();
        if (query == null || query.isEmpty()) {
            return params;
        }
        String[] pairs = query.split("&");
        for (String pair : pairs) {
            String[] parts = pair.split("=", 2);
            if (parts.length == 0) {
                continue;
            }
            String key = decode(parts[0]);
            String value = parts.length > 1 ? decode(parts[1]) : "";
            params.put(key, value);
        }
        return params;
    }

    private static int parseIntParam(Map<String, String> params, String key, int fallback) {
        String value = params.get(key);
        if (value == null || value.trim().isEmpty())
            return fallback;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static Instant parseInstantParam(String value) {
        if (value == null || value.trim().isEmpty())
            return null;
        try {
            return Instant.parse(value.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static String decode(String value) {
        return value.replace("+", " ");
    }

    private static Map<String, String> extractParams(Map<String, Object> data) {
        Map<String, String> params = new LinkedHashMap<>();
        if (data == null) {
            return params;
        }
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            if (value == null) {
                continue;
            }
            if (value instanceof List) {
                List<?> items = (List<?>) value;
                List<String> parts = new ArrayList<>();
                for (Object item : items) {
                    if (item != null) {
                        parts.add(item.toString());
                    }
                }
                params.put(key, String.join(",", parts));
            } else {
                params.put(key, value.toString());
            }
        }
        return params;
    }

    private static List<Map<String, Object>> parseTelemetryPayload(String body) {
        Object decoded = new Gson().fromJson(body, Object.class);
        if (decoded == null)
            return Collections.emptyList();
        if (decoded instanceof Map) {
            return List.of((Map<String, Object>) decoded);
        }
        if (decoded instanceof List) {
            List<?> raw = (List<?>) decoded;
            List<Map<String, Object>> events = new ArrayList<>();
            for (Object item : raw) {
                if (item instanceof Map) {
                    events.add((Map<String, Object>) item);
                }
            }
            return events;
        }
        return Collections.emptyList();
    }

    private static Map<String, Object> buildTelemetryEvent(
            String sessionId,
            String nodeId,
            String event,
            Map<String, Object> data) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("schema", 1);
        payload.put("ts", Instant.now().toString());
        payload.put("event", event);
        payload.put("level", "info");
        payload.put("app", "java_server");
        payload.put("edition", "server");
        payload.put("sessionId", sessionId);
        payload.put("nodeId", nodeId);
        payload.put("platform", "java");
        payload.put("data", data);
        return payload;
    }

    private static void appendTelemetry(TelemetryStore telemetry, Map<String, Object> event) {
        try {
            telemetry.append(List.of(event));
        } catch (IOException ignored) {
        }
    }

    private static void serveStatic(HttpExchange exchange, Path root) throws IOException {
        String path = exchange.getRequestURI().getPath();
        if (path == null || path.isEmpty()) {
            path = "/";
        }
        if (path.endsWith("/")) {
            path = path + "index.html";
        }
        Path target = root.resolve(path.substring(1)).normalize();
        if (!target.startsWith(root)) {
            send(exchange, 403, "Forbidden");
            return;
        }
        if (Files.isDirectory(target)) {
            target = target.resolve("index.html");
        }
        if (!Files.exists(target)) {
            Path notFound = root.resolve("404.html");
            if (Files.exists(notFound)) {
                sendFile(exchange, 404, notFound);
                return;
            }
            send(exchange, 404, "Not Found");
            return;
        }
        sendFile(exchange, 200, target);
    }

    private static void sendFile(HttpExchange exchange, int code, Path file) throws IOException {
        String contentType = contentTypeFor(file);
        if (contentType != null) {
            exchange.getResponseHeaders().add("Content-Type", contentType);
        }
        byte[] bytes = Files.readAllBytes(file);
        exchange.sendResponseHeaders(code, bytes.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(bytes);
        }
    }

    private static String contentTypeFor(Path file) {
        String name = file.getFileName().toString().toLowerCase();
        if (name.endsWith(".html"))
            return "text/html; charset=utf-8";
        if (name.endsWith(".css"))
            return "text/css; charset=utf-8";
        if (name.endsWith(".js"))
            return "application/javascript; charset=utf-8";
        if (name.endsWith(".json"))
            return "application/json; charset=utf-8";
        if (name.endsWith(".png"))
            return "image/png";
        if (name.endsWith(".jpg") || name.endsWith(".jpeg"))
            return "image/jpeg";
        if (name.endsWith(".svg"))
            return "image/svg+xml";
        if (name.endsWith(".ico"))
            return "image/x-icon";
        if (name.endsWith(".zip"))
            return "application/zip";
        if (name.endsWith(".apk"))
            return "application/vnd.android.package-archive";
        if (name.endsWith(".jar"))
            return "application/java-archive";
        return "application/octet-stream";
    }

    private static void send(HttpExchange exchange, int code, String text) throws IOException {
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
        exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        exchange.sendResponseHeaders(code, bytes.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(bytes);
        }
    }

    private static void sendJson(HttpExchange exchange, Object payload) throws IOException {
        String json = new Gson().toJson(payload);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
        send(exchange, 200, json);
    }
}
