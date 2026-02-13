package com.mentalesaude.sos.api;

import java.util.*;
import java.util.concurrent.*;
import java.net.*;
import java.io.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.annotation.*;

/**
 * REST API for managing SOS transport network
 * Provides endpoints for transport configuration, monitoring, and control
 */
@RestController
@RequestMapping("/api/transports")
@CrossOrigin(origins = "*")
public class TransportApi {
    
    private final TransportService transportService;
    private final ObjectMapper objectMapper;
    private final ScheduledExecutorService scheduler;
    
    // In-memory storage for demo (replace with database in production)
    private final Map<String, TransportStatus> transportStatus = new ConcurrentHashMap<>();
    private final Map<String, TransportConfig> transportConfigs = new ConcurrentHashMap<>();
    private final Map<String, List<NetworkNode>> networkNodes = new ConcurrentHashMap<>();
    private final Map<String, List<MessageLog>> messageLogs = new ConcurrentHashMap<>();
    
    public TransportApi() {
        this.transportService = new TransportService();
        this.objectMapper = new ObjectMapper();
        this.scheduler = Executors.newScheduledThreadPool(4);
        initializeDefaultData();
        startPeriodicTasks();
    }
    
    /**
     * Get all transport statuses
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getAllTransportStatus() {
        Map<String, Object> response = new HashMap<>();
        response.put("transports", transportStatus);
        response.put("timestamp", System.currentTimeMillis());
        response.put("summary", calculateSummary());
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get status of specific transport
     */
    @GetMapping("/status/{transportId}")
    public ResponseEntity<TransportStatus> getTransportStatus(
            @PathVariable String transportId) {
        TransportStatus status = transportStatus.get(transportId);
        if (status == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(status);
    }
    
    /**
     * Enable or disable transport
     */
    @PostMapping("/status/{transportId}")
    public ResponseEntity<TransportStatus> setTransportStatus(
            @PathVariable String transportId,
            @RequestBody TransportStatusRequest request) {
        
        TransportStatus status = transportStatus.computeIfAbsent(transportId, k -> {
            TransportStatus newStatus = new TransportStatus();
            newStatus.setTransportId(transportId);
            newStatus.setTimestamp(System.currentTimeMillis());
            return newStatus;
        });
        
        status.setEnabled(request.isEnabled());
        status.setStatus(request.isEnabled() ? "ONLINE" : "OFFLINE");
        status.setLastUpdated(System.currentTimeMillis());
        
        // Trigger transport service action
        if (request.isEnabled()) {
            transportService.enableTransport(transportId);
        } else {
            transportService.disableTransport(transportId);
        }
        
        transportStatus.put(transportId, status);
        
        return ResponseEntity.ok(status);
    }
    
    /**
     * Get transport configuration
     */
    @GetMapping("/config/{transportId}")
    public ResponseEntity<TransportConfig> getTransportConfig(
            @PathVariable String transportId) {
        TransportConfig config = transportConfigs.get(transportId);
        if (config == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(config);
    }
    
    /**
     * Update transport configuration
     */
    @PutMapping("/config/{transportId}")
    public ResponseEntity<TransportConfig> updateTransportConfig(
            @PathVariable String transportId,
            @RequestBody TransportConfig config) {
        
        config.setTransportId(transportId);
        config.setLastUpdated(System.currentTimeMillis());
        
        transportConfigs.put(transportId, config);
        
        // Apply configuration to transport service
        transportService.updateConfiguration(transportId, config);
        
        return ResponseEntity.ok(config);
    }
    
    /**
     * Get all network nodes
     */
    @GetMapping("/nodes")
    public ResponseEntity<Map<String, Object>> getNetworkNodes() {
        Map<String, Object> response = new HashMap<>();
        response.put("nodes", networkNodes);
        response.put("totalNodes", networkNodes.values().stream().mapToInt(List::size).sum());
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get nodes for specific transport
     */
    @GetMapping("/nodes/{transportId}")
    public ResponseEntity<List<NetworkNode>> getTransportNodes(
            @PathVariable String transportId) {
        List<NetworkNode> nodes = networkNodes.getOrDefault(transportId, new ArrayList<>());
        return ResponseEntity.ok(nodes);
    }
    
    /**
     * Add network node
     */
    @PostMapping("/nodes/{transportId}")
    public ResponseEntity<NetworkNode> addNetworkNode(
            @PathVariable String transportId,
            @RequestBody NetworkNode node) {
        
        node.setTransportId(transportId);
        node.setNodeId(UUID.randomUUID().toString());
        node.setJoinedAt(System.currentTimeMillis());
        
        networkNodes.computeIfAbsent(transportId, k -> new ArrayList<>()).add(node);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(node);
    }
    
    /**
     * Remove network node
     */
    @DeleteMapping("/nodes/{transportId}/{nodeId}")
    public ResponseEntity<Void> removeNetworkNode(
            @PathVariable String transportId,
            @PathVariable String nodeId) {
        
        List<NetworkNode> nodes = networkNodes.get(transportId);
        if (nodes != null) {
            nodes.removeIf(node -> node.getNodeId().equals(nodeId));
        }
        
        return ResponseEntity.noContent().build();
    }
    
    /**
     * Send message through specific transport
     */
    @PostMapping("/send/{transportId}")
    public ResponseEntity<MessageResponse> sendMessage(
            @PathVariable String transportId,
            @RequestBody MessageRequest request) {
        
        try {
            String messageId = UUID.randomUUID().toString();
            
            // Log message
            MessageLog log = new MessageLog();
            log.setMessageId(messageId);
            log.setTransportId(transportId);
            log.setSenderId(request.getSenderId());
            log.setRecipientId(request.getRecipientId());
            log.setMessage(request.getMessage());
            log.setTimestamp(System.currentTimeMillis());
            log.setStatus("SENT");
            
            messageLogs.computeIfAbsent(transportId, k -> new ArrayList<>()).add(log);
            
            // Send through transport service
            boolean success = transportService.sendMessage(
                transportId, 
                request.getSenderId(), 
                request.getRecipientId(), 
                request.getMessage()
            );
            
            MessageResponse response = new MessageResponse();
            response.setMessageId(messageId);
            response.setSuccess(success);
            response.setTimestamp(System.currentTimeMillis());
            
            if (success) {
                response.setStatus("DELIVERED");
            } else {
                response.setStatus("FAILED");
                log.setStatus("FAILED");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            MessageResponse response = new MessageResponse();
            response.setSuccess(false);
            response.setError(e.getMessage());
            response.setTimestamp(System.currentTimeMillis());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * Broadcast message through all enabled transports
     */
    @PostMapping("/broadcast")
    public ResponseEntity<BroadcastResponse> broadcastMessage(
            @RequestBody BroadcastRequest request) {
        
        BroadcastResponse response = new BroadcastResponse();
        response.setTimestamp(System.currentTimeMillis());
        
        List<String> successfulTransports = new ArrayList<>();
        List<String> failedTransports = new ArrayList<>();
        
        for (Map.Entry<String, TransportStatus> entry : transportStatus.entrySet()) {
            String transportId = entry.getKey();
            TransportStatus status = entry.getValue();
            
            if (status.isEnabled() && "ONLINE".equals(status.getStatus())) {
                try {
                    boolean success = transportService.sendMessage(
                        transportId, 
                        request.getSenderId(), 
                        null, // Broadcast
                        request.getMessage()
                    );
                    
                    if (success) {
                        successfulTransports.add(transportId);
                    } else {
                        failedTransports.add(transportId);
                    }
                } catch (Exception e) {
                    failedTransports.add(transportId);
                }
            }
        }
        
        response.setSuccessfulTransports(successfulTransports);
        response.setFailedTransports(failedTransports);
        response.setTotalTransports(successfulTransports.size() + failedTransports.size());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get message logs for transport
     */
    @GetMapping("/logs/{transportId}")
    public ResponseEntity<Map<String, Object>> getMessageLogs(
            @PathVariable String transportId,
            @RequestParam(defaultValue = "100") int limit) {
        
        List<MessageLog> logs = messageLogs.getOrDefault(transportId, new ArrayList<>());
        
        // Return most recent logs
        List<MessageLog> recentLogs = logs.stream()
                .sorted((a, b) -> Long.compare(b.getTimestamp(), a.getTimestamp()))
                .limit(limit)
                .collect(java.util.stream.Collectors.toList());
        
        Map<String, Object> response = new HashMap<>();
        response.put("logs", recentLogs);
        response.put("total", logs.size());
        response.put("transportId", transportId);
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get network statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getNetworkStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        // Transport statistics
        int totalTransports = transportStatus.size();
        long enabledTransports = transportStatus.values().stream()
                .mapToLong(status -> status.isEnabled() ? 1 : 0)
                .sum();
        
        // Node statistics
        int totalNodes = networkNodes.values().stream()
                .mapToInt(List::size)
                .sum();
        
        // Message statistics
        int totalMessages = messageLogs.values().stream()
                .mapToInt(List::size)
                .sum();
        
        long sentMessages = messageLogs.values().stream()
                .mapToLong(list -> list.stream()
                        .mapToLong(log -> "SENT".equals(log.getStatus()) ? 1 : 0)
                        .sum())
                .sum();
        
        long failedMessages = messageLogs.values().stream()
                .mapToLong(list -> list.stream()
                        .mapToLong(log -> "FAILED".equals(log.getStatus()) ? 1 : 0)
                        .sum())
                .sum();
        
        stats.put("transports", Map.of(
            "total", totalTransports,
            "enabled", enabledTransports,
            "disabled", totalTransports - enabledTransports
        ));
        
        stats.put("nodes", Map.of(
            "total", totalNodes,
            "connected", totalNodes // Simplified - all nodes are considered connected
        ));
        
        stats.put("messages", Map.of(
            "total", totalMessages,
            "sent", sentMessages,
            "failed", failedMessages,
            "successRate", totalMessages > 0 ? (sentMessages * 100.0 / totalMessages) : 0.0
        ));
        
        stats.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(stats);
    }
    
    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        
        // Check transport service health
        boolean serviceHealthy = transportService.isHealthy();
        
        // Check system resources
        Runtime runtime = Runtime.getRuntime();
        long freeMemory = runtime.freeMemory();
        long totalMemory = runtime.totalMemory();
        double memoryUsage = (double) (totalMemory - freeMemory) / totalMemory * 100;
        
        health.put("status", serviceHealthy ? "HEALTHY" : "UNHEALTHY");
        health.put("timestamp", System.currentTimeMillis());
        health.put("memory", Map.of(
            "free", freeMemory,
            "total", totalMemory,
            "usage", memoryUsage
        ));
        
        return ResponseEntity.ok(health);
    }
    
    /**
     * Initialize default data for demo
     */
    private void initializeDefaultData() {
        // Initialize transport statuses
        String[] transports = {
            "bluetooth_le", "bluetooth_classic", "bluetooth_mesh",
            "wifi_lan", "ethernet", "lorawan", "dtn",
            "secure", "webrtc", "zigbee"
        };
        
        for (String transportId : transports) {
            TransportStatus status = new TransportStatus();
            status.setTransportId(transportId);
            status.setEnabled(false);
            status.setStatus("OFFLINE");
            status.setTimestamp(System.currentTimeMillis());
            transportStatus.put(transportId, status);
        }
        
        // Initialize transport configurations
        for (String transportId : transports) {
            TransportConfig config = new TransportConfig();
            config.setTransportId(transportId);
            config.setPriority("normal");
            config.setTimeout(Duration.ofSeconds(30));
            config.setRetryAttempts(3);
            config.setBufferSize(1024);
            config.setLastUpdated(System.currentTimeMillis());
            transportConfigs.put(transportId, config);
        }
    }
    
    /**
     * Start periodic background tasks
     */
    private void startPeriodicTasks() {
        // Update node status every 30 seconds
        scheduler.scheduleAtFixedRate(() -> updateNodeStatus(), 30, 30, TimeUnit.SECONDS);
        
        // Cleanup old logs every hour
        scheduler.scheduleAtFixedRate(() -> cleanupOldLogs(), 1, 1, TimeUnit.HOURS);
        
        // Generate statistics every 5 minutes
        scheduler.scheduleAtFixedRate(() -> generateStatistics(), 5, 5, TimeUnit.MINUTES);
    }
    
    /**
     * Update node status based on last seen time
     */
    private void updateNodeStatus() {
        long now = System.currentTimeMillis();
        long timeout = Duration.ofMinutes(5).toMillis();
        
        for (List<NetworkNode> nodes : networkNodes.values()) {
            for (NetworkNode node : nodes) {
                if (now - node.getLastSeen() > timeout) {
                    node.setStatus("OFFLINE");
                } else {
                    node.setStatus("ONLINE");
                }
            }
        }
    }
    
    /**
     * Remove old message logs
     */
    private void cleanupOldLogs() {
        long cutoff = System.currentTimeMillis() - Duration.ofHours(24).toMillis();
        
        for (List<MessageLog> logs : messageLogs.values()) {
            logs.removeIf(log -> log.getTimestamp() < cutoff);
        }
    }
    
    /**
     * Generate and store network statistics
     */
    private void generateStatistics() {
        // Implementation for generating periodic statistics
        // This would store to database in production
    }
    
    /**
     * Calculate summary statistics
     */
    private Map<String, Object> calculateSummary() {
        Map<String, Object> summary = new HashMap<>();
        
        long enabledCount = transportStatus.values().stream()
                .mapToLong(status -> status.isEnabled() ? 1 : 0)
                .sum();
        
        long onlineCount = transportStatus.values().stream()
                .mapToLong(status -> status.isEnabled() && "ONLINE".equals(status.getStatus()))
                .sum();
        
        summary.put("total", transportStatus.size());
        summary.put("enabled", enabledCount);
        summary.put("online", onlineCount);
        summary.put("offline", enabledCount - onlineCount);
        
        return summary;
    }
}

// Data classes
class TransportStatusRequest {
    private boolean enabled;
    
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
}

class TransportStatus {
    private String transportId;
    private boolean enabled;
    private String status;
    private long timestamp;
    private long lastUpdated;
    
    // Getters and setters
    public String getTransportId() { return transportId; }
    public void setTransportId(String transportId) { this.transportId = transportId; }
    
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
}

class TransportConfig {
    private String transportId;
    private String priority;
    private Duration timeout;
    private int retryAttempts;
    private int bufferSize;
    private Map<String, Object> customParameters;
    private long lastUpdated;
    
    // Getters and setters
    public String getTransportId() { return transportId; }
    public void setTransportId(String transportId) { this.transportId = transportId; }
    
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    
    public Duration getTimeout() { return timeout; }
    public void setTimeout(Duration timeout) { this.timeout = timeout; }
    
    public int getRetryAttempts() { return retryAttempts; }
    public void setRetryAttempts(int retryAttempts) { this.retryAttempts = retryAttempts; }
    
    public int getBufferSize() { return bufferSize; }
    public void setBufferSize(int bufferSize) { this.bufferSize = bufferSize; }
    
    public Map<String, Object> getCustomParameters() { return customParameters; }
    public void setCustomParameters(Map<String, Object> customParameters) { this.customParameters = customParameters; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
}

class NetworkNode {
    private String nodeId;
    private String transportId;
    private String address;
    private String name;
    private String type;
    private String status;
    private long joinedAt;
    private long lastSeen;
    private Map<String, Object> metadata;
    
    // Getters and setters
    public String getNodeId() { return nodeId; }
    public void setNodeId(String nodeId) { this.nodeId = nodeId; }
    
    public String getTransportId() { return transportId; }
    public void setTransportId(String transportId) { this.transportId = transportId; }
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public long getJoinedAt() { return joinedAt; }
    public void setJoinedAt(long joinedAt) { this.joinedAt = joinedAt; }
    
    public long getLastSeen() { return lastSeen; }
    public void setLastSeen(long lastSeen) { this.lastSeen = lastSeen; }
    
    public Map<String, Object> getMetadata() { return metadata; }
    public void setMetadata(Map<String, Object> metadata) { this.metadata = metadata; }
}

class MessageRequest {
    private String senderId;
    private String recipientId;
    private String message;
    
    // Getters and setters
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    
    public String getRecipientId() { return recipientId; }
    public void setRecipientId(String recipientId) { this.recipientId = recipientId; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}

class MessageResponse {
    private String messageId;
    private boolean success;
    private String status;
    private String error;
    private long timestamp;
    
    // Getters and setters
    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
    
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}

class BroadcastRequest {
    private String senderId;
    private String message;
    
    // Getters and setters
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}

class BroadcastResponse {
    private List<String> successfulTransports;
    private List<String> failedTransports;
    private int totalTransports;
    private long timestamp;
    
    // Getters and setters
    public List<String> getSuccessfulTransports() { return successfulTransports; }
    public void setSuccessfulTransports(List<String> successfulTransports) { this.successfulTransports = successfulTransports; }
    
    public List<String> getFailedTransports() { return failedTransports; }
    public void setFailedTransports(List<String> failedTransports) { this.failedTransports = failedTransports; }
    
    public int getTotalTransports() { return totalTransports; }
    public void setTotalTransports(int totalTransports) { this.totalTransports = totalTransports; }
    
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}

class MessageLog {
    private String messageId;
    private String transportId;
    private String senderId;
    private String recipientId;
    private String message;
    private String status;
    private long timestamp;
    
    // Getters and setters
    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    
    public String getTransportId() { return transportId; }
    public void setTransportId(String transportId) { this.transportId = transportId; }
    
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    
    public String getRecipientId() { return recipientId; }
    public void setRecipientId(String recipientId) { this.recipientId = recipientId; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}
