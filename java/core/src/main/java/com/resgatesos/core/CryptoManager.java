package com.resgatesos.core;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.PublicKey;
import java.security.Signature;
import java.util.Base64;

public class CryptoManager {
    private final KeyPair keyPair;

    public CryptoManager() throws Exception {
        IdentityStore store = new IdentityStore();
        this.keyPair = store.loadOrCreate();
    }

    public String getPublicKeyBase64() {
        return Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());
    }

    public String sign(String message) throws Exception {
        Signature signature = Signature.getInstance("Ed25519");
        signature.initSign(keyPair.getPrivate());
        signature.update(message.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(signature.sign());
    }

    public boolean verify(String message, String signatureB64, String publicKeyB64) {
        try {
            byte[] sigBytes = Base64.getDecoder().decode(signatureB64);
            byte[] pubBytes = Base64.getDecoder().decode(publicKeyB64);
            PublicKey publicKey = java.security.KeyFactory.getInstance("Ed25519")
                    .generatePublic(new java.security.spec.X509EncodedKeySpec(pubBytes));
            Signature verifier = Signature.getInstance("Ed25519");
            verifier.initVerify(publicKey);
            verifier.update(message.getBytes(StandardCharsets.UTF_8));
            return verifier.verify(sigBytes);
        } catch (Exception e) {
            return false;
        }
    }
}
