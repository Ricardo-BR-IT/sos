package com.resgatesos.server;

import com.google.gson.Gson;

import java.io.IOException;
import java.net.NetworkInterface;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class HardwareProfile {
    private final List<String> flags;
    private final List<String> transports;
    private final List<String> interfaces;
    private final List<String> sources;
    private final Map<String, Object> meta;

    private HardwareProfile(
            List<String> flags,
            List<String> transports,
            List<String> interfaces,
            List<String> sources,
            Map<String, Object> meta
    ) {
        this.flags = flags;
        this.transports = transports;
        this.interfaces = interfaces;
        this.sources = sources;
        this.meta = meta;
    }

    public static HardwareProfile detect(Path dataDir) {
        Set<String> flags = new HashSet<>();
        Set<String> transports = new HashSet<>();
        List<String> interfaces = new ArrayList<>();
        List<String> sources = new ArrayList<>();
        Map<String, Object> meta = new HashMap<>();

        interfaces.addAll(detectInterfaces());
        if (!interfaces.isEmpty()) {
            sources.add("auto");
        }

        String envFlags = System.getenv("SOS_HARDWARE_FLAGS");
        if (envFlags != null && !envFlags.trim().isEmpty()) {
            flags.addAll(splitFlags(envFlags));
            sources.add("env_flags");
        }

        Path profilePath = resolveProfilePath(dataDir);
        if (profilePath != null) {
            Object data = readJson(profilePath);
            if (data != null) {
                applyJson(data, flags, transports, meta);
                sources.add("file");
            }
        }

        if (hasEthernetInterface(interfaces)) {
            flags.add("ethernet");
        }

        List<String> flagsList = new ArrayList<>(flags);
        Collections.sort(flagsList);
        List<String> transportList = new ArrayList<>(transports);
        Collections.sort(transportList);

        return new HardwareProfile(
                flagsList,
                transportList,
                interfaces,
                sources,
                meta
        );
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("flags", flags);
        map.put("transports", transports);
        map.put("interfaces", interfaces);
        map.put("sources", sources);
        map.put("meta", meta);
        return map;
    }

    private static List<String> detectInterfaces() {
        List<String> names = new ArrayList<>();
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface networkInterface = interfaces.nextElement();
                names.add(networkInterface.getName());
            }
        } catch (Exception ignored) {
        }
        return names;
    }

    private static boolean hasEthernetInterface(List<String> names) {
        for (String name : names) {
            String lower = name.toLowerCase();
            if (lower.contains("eth") ||
                    lower.contains("en") ||
                    lower.contains("ethernet") ||
                    lower.contains("lan")) {
                return true;
            }
        }
        return false;
    }

    private static List<String> splitFlags(String value) {
        String[] parts = value.split("[,\\s;]+");
        List<String> flags = new ArrayList<>();
        for (String part : parts) {
            String trimmed = part.trim();
            if (!trimmed.isEmpty()) {
                flags.add(trimmed);
            }
        }
        return flags;
    }

    private static Path resolveProfilePath(Path dataDir) {
        String envPath = System.getenv("SOS_HARDWARE_PROFILE");
        List<Path> candidates = new ArrayList<>();
        if (envPath != null && !envPath.trim().isEmpty()) {
            candidates.add(Path.of(envPath.trim()));
        }
        if (dataDir != null) {
            candidates.add(dataDir.resolve("hardware_profile.json"));
            candidates.add(dataDir.resolve("sos_hardware_profile.json"));
        }
        candidates.add(Path.of("hardware_profile.json"));
        candidates.add(Path.of("sos_hardware_profile.json"));

        for (Path path : candidates) {
            if (path != null && Files.exists(path)) {
                return path;
            }
        }
        return null;
    }

    private static Object readJson(Path path) {
        try {
            String content = Files.readString(path);
            return new Gson().fromJson(content, Object.class);
        } catch (IOException ignored) {
            return null;
        }
    }

    @SuppressWarnings("unchecked")
    private static void applyJson(
            Object data,
            Set<String> flags,
            Set<String> transports,
            Map<String, Object> meta
    ) {
        if (data instanceof List) {
            for (Object item : (List<?>) data) {
                if (item != null) flags.add(item.toString());
            }
            return;
        }
        if (data instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) data;
            Object flagObj = map.get("flags");
            if (flagObj instanceof String) {
                flags.addAll(splitFlags(flagObj.toString()));
            } else if (flagObj instanceof List) {
                for (Object item : (List<?>) flagObj) {
                    if (item != null) flags.add(item.toString());
                }
            }
            Object transportObj = map.get("transports");
            if (transportObj instanceof String) {
                transports.addAll(splitFlags(transportObj.toString()));
            } else if (transportObj instanceof List) {
                for (Object item : (List<?>) transportObj) {
                    if (item != null) transports.add(item.toString());
                }
            }
            Object metaObj = map.get("meta");
            if (metaObj instanceof Map) {
                meta.putAll((Map<String, Object>) metaObj);
            }
        }
    }
}
