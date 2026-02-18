/**
 * SOS EXPERIMENTAL MODULE: WebRTC (Secure P2P Comms)
 * Implements Video/Voice calling using the Mesh Messages API for signaling.
 */

const WebRTC = {
    localStream: null,
    remoteStream: null,
    peerConnection: null,
    targetNodeId: null,
    isCaller: false,

    config: {
        iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:stun1.l.google.com:19302' }
        ]
    },

    init: async () => {
        console.log(">>> WebRTC Module Loaded");
        // Check for incoming signals periodically
        setInterval(WebRTC.checkSignals, 3000);
    },

    startCall: async (targetId) => {
        console.log(`>>> Initiating Call to ${targetId}`);
        WebRTC.targetNodeId = targetId;
        WebRTC.isCaller = true;

        // 1. Get User Media
        try {
            WebRTC.localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
            document.getElementById('localVideo').srcObject = WebRTC.localStream;

            // 2. Create Peer Connection
            WebRTC.createPeerConnection();

            // 3. Add Tracks
            WebRTC.localStream.getTracks().forEach(track => {
                WebRTC.peerConnection.addTrack(track, WebRTC.localStream);
            });

            // 4. Create Offer
            const offer = await WebRTC.peerConnection.createOffer();
            await WebRTC.peerConnection.setLocalDescription(offer);

            // 5. Send Offer via Mesh Signaling
            Comms.sendMessage(targetId, `[RTC_OFFER]${JSON.stringify(offer)}`);

            UI.showCallModal(targetId, 'calling');
        } catch (e) {
            console.error("WebRTC Error:", e);
            alert("Camera/Mic Access Denied or Error.");
        }
    },

    acceptCall: async (senderId, offerData) => {
        console.log(`>>> Accepting Call from ${senderId}`);
        WebRTC.targetNodeId = senderId;
        WebRTC.isCaller = false;

        try {
            WebRTC.localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
            document.getElementById('localVideo').srcObject = WebRTC.localStream;

            WebRTC.createPeerConnection();

            WebRTC.localStream.getTracks().forEach(track => {
                WebRTC.peerConnection.addTrack(track, WebRTC.localStream);
            });

            const offer = JSON.parse(offerData);
            await WebRTC.peerConnection.setRemoteDescription(new RTCSessionDescription(offer));

            const answer = await WebRTC.peerConnection.createAnswer();
            await WebRTC.peerConnection.setLocalDescription(answer);

            Comms.sendMessage(senderId, `[RTC_ANSWER]${JSON.stringify(answer)}`);

            UI.showCallModal(senderId, 'connected');

        } catch (e) {
            console.error("Accept Error:", e);
        }
    },

    finalizeCall: async (answerData) => {
        const answer = JSON.parse(answerData);
        await WebRTC.peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
        console.log(">>> Call Established!");
        UI.updateCallStatus('Connected');
    },

    handleCandidate: async (candidateData) => {
        if (WebRTC.peerConnection) {
            const candidate = JSON.parse(candidateData);
            await WebRTC.peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
        }
    },

    createPeerConnection: () => {
        WebRTC.peerConnection = new RTCPeerConnection(WebRTC.config);

        WebRTC.peerConnection.onicecandidate = (event) => {
            if (event.candidate) {
                Comms.sendMessage(WebRTC.targetNodeId, `[RTC_ICE]${JSON.stringify(event.candidate)}`);
            }
        };

        WebRTC.peerConnection.ontrack = (event) => {
            document.getElementById('remoteVideo').srcObject = event.streams[0];
        };
    },

    checkSignals: () => {
        // This hooks into Comms.messages array to look for signals
        // In a real implementation, this would be an event listener
        // For now, we rely on Comms.processMessage to detect [RTC_*] tags
        // This function is a placeholder for aggressive polling if needed
    },

    endCall: () => {
        if (WebRTC.peerConnection) WebRTC.peerConnection.close();
        if (WebRTC.localStream) WebRTC.localStream.getTracks().forEach(track => track.stop());
        WebRTC.peerConnection = null;
        UI.hideCallModal();
    }
};
