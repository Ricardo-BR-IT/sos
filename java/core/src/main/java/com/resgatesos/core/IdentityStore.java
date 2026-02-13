package com.resgatesos.core;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class IdentityStore {
    private static final String FILE_NAME = "identity.json";
    private final File storeFile;

    public IdentityStore() {
        File baseDir = new File(System.getProperty("user.home"), ".resgatesos");
        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }
        this.storeFile = new File(baseDir, FILE_NAME);
    }

    public KeyPair loadOrCreate() throws Exception {
        if (storeFile.exists()) {
            try (FileReader reader = new FileReader(storeFile)) {
                Type type = new TypeToken<Map<String, String>>() {}.getType();
                Map<String, String> data = new Gson().fromJson(reader, type);
                if (data != null && data.containsKey("publicKey") && data.containsKey("privateKey")) {
                    return decodeKeyPair(data.get("publicKey"), data.get("privateKey"));
                }
            }
        }

        KeyPairGenerator generator = KeyPairGenerator.getInstance("Ed25519");
        KeyPair keyPair = generator.generateKeyPair();
        persist(keyPair);
        return keyPair;
    }

    private void persist(KeyPair keyPair) throws Exception {
        Map<String, String> data = new HashMap<>();
        data.put("publicKey", Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded()));
        data.put("privateKey", Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded()));
        try (FileWriter writer = new FileWriter(storeFile)) {
            new Gson().toJson(data, writer);
        }
        try {
            Files.setAttribute(storeFile.toPath(), "dos:hidden", true);
        } catch (Exception ignored) {
        }
    }

    private KeyPair decodeKeyPair(String pubB64, String privB64) throws Exception {
        byte[] pubBytes = Base64.getDecoder().decode(pubB64);
        byte[] privBytes = Base64.getDecoder().decode(privB64);
        KeyFactory keyFactory = KeyFactory.getInstance("Ed25519");
        PublicKey publicKey = keyFactory.generatePublic(new X509EncodedKeySpec(pubBytes));
        PrivateKey privateKey = keyFactory.generatePrivate(new PKCS8EncodedKeySpec(privBytes));
        return new KeyPair(publicKey, privateKey);
    }
}
