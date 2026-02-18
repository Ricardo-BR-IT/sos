/**
 * SOS MODULE: DEAD DROP
 * LocalStorage Encrypted Safe.
 */

const DeadDrop = {
    init: () => {
        console.log(">>> Dead Drop Module Loaded");
    },

    save: async (key, text, password) => {
        const enc = new TextEncoder();
        const msgData = enc.encode(text);
        const salt = crypto.getRandomValues(new Uint8Array(16));
        const iv = crypto.getRandomValues(new Uint8Array(12));

        const keyMaterial = await crypto.subtle.importKey(
            "raw", enc.encode(password), { name: "PBKDF2" }, false, ["deriveKey"]
        );

        const aesKey = await crypto.subtle.deriveKey(
            { name: "PBKDF2", salt: salt, iterations: 100000, hash: "SHA-256" },
            keyMaterial, { name: "AES-GCM", length: 256 }, false, ["encrypt"]
        );

        const encrypted = await crypto.subtle.encrypt(
            { name: "AES-GCM", iv: iv }, aesKey, msgData
        );

        const bundle = {
            salt: Array.from(salt),
            iv: Array.from(iv),
            data: Array.from(new Uint8Array(encrypted))
        };

        localStorage.setItem(`DEAD_DROP_${key}`, JSON.stringify(bundle));
        console.log("Dead Drop Saved");
    },

    load: async (key, password) => {
        const raw = localStorage.getItem(`DEAD_DROP_${key}`);
        if (!raw) return null;

        const bundle = JSON.parse(raw);
        const salt = new Uint8Array(bundle.salt);
        const iv = new Uint8Array(bundle.iv);
        const data = new Uint8Array(bundle.data);
        const enc = new TextEncoder();

        const keyMaterial = await crypto.subtle.importKey(
            "raw", enc.encode(password), { name: "PBKDF2" }, false, ["deriveKey"]
        );

        const aesKey = await crypto.subtle.deriveKey(
            { name: "PBKDF2", salt: salt, iterations: 100000, hash: "SHA-256" },
            keyMaterial, { name: "AES-GCM", length: 256 }, false, ["decrypt"]
        );

        try {
            const decrypted = await crypto.subtle.decrypt(
                { name: "AES-GCM", iv: iv }, aesKey, data
            );
            return new TextDecoder().decode(decrypted);
        } catch (e) {
            console.error("Decryption Failed (Wrong Password?)");
            return null;
        }
    }
};
