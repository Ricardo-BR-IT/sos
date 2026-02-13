---
description: Workflow for conducting a full security audit on the mesh infrastructure.
---

# Workflow: Security Audit Protocol

Use the `CryptoProtocols` and `MeshSecurityAudit` skills for theory.

## Steps

1. **Pre-Audit Preparation**
   - Identify all active node public keys in the mesh.
   - Ensure you have access to local packet logs for analysis.

2. **Signature Verification**
   - Pull a sample of 100 recent packets from the log.
   - Verify Ed25519 signature on each. Failure rate MUST be 0%.

3. **Encryption Check**
   - Attempt to read payload of encrypted packets without the private key.
   - Confirm payload is indistinguishable from random data.

4. **Key Exchange Review**
   - Simulate a MITM attack on a new ECDH handshake.
   - Verify that the handshake fails or produces a mismatched session key.

5. **Replay Attack Test**
   - Resend an old, valid, signed packet to the mesh.
   - Confirm that nodes reject the packet based on `timestamp` or `nonce` checks.

6. **Report Generation**
   - Document all findings.
   - Tag any vulnerabilities with severity (P0-P4) and create tasks.

7. **Remediation**
   - Patch critical vulnerabilities immediately.
   - Schedule minor issues for the next sprint.
