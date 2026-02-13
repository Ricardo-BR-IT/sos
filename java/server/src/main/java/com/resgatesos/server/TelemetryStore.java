package com.resgatesos.server;

import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class TelemetryStore {
    private static final DateTimeFormatter DAY_FORMAT = DateTimeFormatter.BASIC_ISO_DATE;
    private final Path dataDir;
    private final int retentionDays;
    private final Gson gson = new Gson();

    public TelemetryStore(Path baseDir, int retentionDays) throws IOException {
        this.dataDir = baseDir.resolve("telemetry");
        this.retentionDays = Math.max(1, Math.min(retentionDays, 365));
        Files.createDirectories(this.dataDir);
    }

    public synchronized int append(List<Map<String, Object>> events) throws IOException {
        if (events == null || events.isEmpty()) {
            return 0;
        }
        purgeOld();
        Path file = dataDir.resolve(fileNameFor(LocalDate.now(ZoneOffset.UTC)));
        try (BufferedWriter writer = Files.newBufferedWriter(
                file,
                StandardOpenOption.CREATE,
                StandardOpenOption.APPEND)) {
            for (Map<String, Object> event : events) {
                if (event == null) continue;
                event.putIfAbsent("receivedAt", Instant.now().toString());
                writer.write(gson.toJson(event));
                writer.newLine();
            }
        }
        return events.size();
    }

    public synchronized List<Map<String, Object>> loadRecent(int limit, Instant since)
            throws IOException {
        List<Map<String, Object>> results = new ArrayList<>();
        for (Path file : listTelemetryFiles()) {
            if (results.size() >= limit) break;
            try (BufferedReader reader = Files.newBufferedReader(file)) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (results.size() >= limit) break;
                    Map<String, Object> event = parseEvent(line);
                    if (event == null) continue;
                    if (since != null && !isAfter(event, since)) continue;
                    results.add(event);
                }
            }
        }
        return results;
    }

    public synchronized Map<String, Object> summary(Instant since) throws IOException {
        int total = 0;
        Map<String, Integer> byType = new HashMap<>();
        Set<String> nodes = new HashSet<>();
        Instant latest = null;
        Instant earliest = null;

        for (Path file : listTelemetryFiles()) {
            try (BufferedReader reader = Files.newBufferedReader(file)) {
                String line;
                while ((line = reader.readLine()) != null) {
                    Map<String, Object> event = parseEvent(line);
                    if (event == null) continue;
                    if (since != null && !isAfter(event, since)) continue;
                    total++;
                    Object typeObj = event.get("event");
                    if (typeObj != null) {
                        String type = typeObj.toString();
                        byType.put(type, byType.getOrDefault(type, 0) + 1);
                    }
                    Object node = event.get("nodeId");
                    if (node != null) {
                        nodes.add(node.toString());
                    }
                    Instant ts = parseInstant(event.get("ts"));
                    if (ts != null) {
                        if (latest == null || ts.isAfter(latest)) latest = ts;
                        if (earliest == null || ts.isBefore(earliest)) earliest = ts;
                    }
                }
            }
        }

        Map<String, Object> summary = new HashMap<>();
        summary.put("ok", true);
        summary.put("total", total);
        summary.put("byType", byType);
        summary.put("nodes", nodes.size());
        summary.put("from", earliest != null ? earliest.toString() : null);
        summary.put("to", latest != null ? latest.toString() : null);
        return summary;
    }

    public synchronized String exportCsv(int limit, Instant since) throws IOException {
        StringBuilder sb = new StringBuilder();
        sb.append("ts,event,level,app,edition,sessionId,nodeId,platform\n");
        List<Map<String, Object>> events = loadRecent(limit, since);
        for (Map<String, Object> event : events) {
            sb.append(csv(event.get("ts"))).append(',')
                    .append(csv(event.get("event"))).append(',')
                    .append(csv(event.get("level"))).append(',')
                    .append(csv(event.get("app"))).append(',')
                    .append(csv(event.get("edition"))).append(',')
                    .append(csv(event.get("sessionId"))).append(',')
                    .append(csv(event.get("nodeId"))).append(',')
                    .append(csv(event.get("platform"))).append('\n');
        }
        return sb.toString();
    }

    private List<Path> listTelemetryFiles() throws IOException {
        List<Path> files = new ArrayList<>();
        try (var stream = Files.list(dataDir)) {
            stream.filter(path -> path.getFileName().toString().startsWith("telemetry-"))
                    .filter(path -> path.getFileName().toString().endsWith(".jsonl"))
                    .forEach(files::add);
        }
        files.sort(Comparator.comparing(Path::getFileName).reversed());
        return files;
    }

    private void purgeOld() throws IOException {
        LocalDate threshold = LocalDate.now(ZoneOffset.UTC).minusDays(retentionDays);
        for (Path file : listTelemetryFiles()) {
            LocalDate date = dateFromFile(file);
            if (date != null && date.isBefore(threshold)) {
                Files.deleteIfExists(file);
            }
        }
    }

    private LocalDate dateFromFile(Path file) {
        String name = file.getFileName().toString();
        if (!name.startsWith("telemetry-")) return null;
        String datePart = name.replace("telemetry-", "").replace(".jsonl", "");
        if (datePart.length() != 8) return null;
        try {
            return LocalDate.parse(datePart, DAY_FORMAT);
        } catch (Exception ignored) {
            return null;
        }
    }

    private String fileNameFor(LocalDate date) {
        return "telemetry-" + date.format(DAY_FORMAT) + ".jsonl";
    }

    private Map<String, Object> parseEvent(String line) {
        try {
            return gson.fromJson(line, Map.class);
        } catch (Exception ignored) {
            return null;
        }
    }

    private boolean isAfter(Map<String, Object> event, Instant since) {
        Instant ts = parseInstant(event.get("ts"));
        if (ts == null) return false;
        return !ts.isBefore(since);
    }

    private Instant parseInstant(Object value) {
        if (value == null) return null;
        try {
            return Instant.parse(value.toString());
        } catch (Exception ignored) {
            return null;
        }
    }

    private String csv(Object value) {
        if (value == null) return "";
        String text = value.toString().replace("\"", "\"\"");
        if (text.contains(",") || text.contains("\"")) {
            return "\"" + text + "\"";
        }
        return text;
    }
}
