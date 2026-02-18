/**
 * SOS MODULE: STEGANOGRAPHY
 * Hides secret text inside image pixel data (LSB).
 */

const Steganography = {
    init: () => {
        console.log(">>> Steganography Module Loaded");
    },

    encode: (imageFile, secretText) => {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = (e) => {
                const img = new Image();
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    canvas.width = img.width;
                    canvas.height = img.height;
                    ctx.drawImage(img, 0, 0);

                    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                    const binaryText = Steganography.textToBinary(secretText + "\\0"); // Null terminator

                    // LSB Encoding
                    let dataIndex = 0;
                    for (let i = 0; i < imgData.data.length; i += 4) {
                        if (dataIndex < binaryText.length) {
                            // Modify Red channel LSB
                            let binaryPixel = imgData.data[i].toString(2);
                            binaryPixel = binaryPixel.substring(0, binaryPixel.length - 1) + binaryText[dataIndex];
                            imgData.data[i] = parseInt(binaryPixel, 2);
                            dataIndex++;
                        } else {
                            break;
                        }
                    }

                    ctx.putImageData(imgData, 0, 0);
                    resolve(canvas.toDataURL());
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(imageFile);
        });
    },

    decode: (imageSrc) => {
        return new Promise((resolve) => {
            const img = new Image();
            img.crossOrigin = "Anonymous";
            img.onload = () => {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                canvas.width = img.width;
                canvas.height = img.height;
                ctx.drawImage(img, 0, 0);

                const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                let binaryText = "";

                for (let i = 0; i < imgData.data.length; i += 4) {
                    const binaryPixel = imgData.data[i].toString(2);
                    binaryText += binaryPixel[binaryPixel.length - 1];
                }

                resolve(Steganography.binaryToText(binaryText));
            };
            img.src = imageSrc;
        });
    },

    textToBinary: (text) => {
        return text.split('').map(char => {
            return char.charCodeAt(0).toString(2).padStart(8, '0');
        }).join('');
    },

    binaryToText: (binary) => {
        let text = "";
        for (let i = 0; i < binary.length; i += 8) {
            const byte = binary.substr(i, 8);
            if (byte === "00000000") break; // Null terminator
            text += String.fromCharCode(parseInt(byte, 2));
        }
        return text;
    },

    /**
     * SOS STEALTH AUDIO (V33)
     * Hides text in the LSB of a WAV file (PCM 16-bit or 8-bit).
     */
    encodeAudio: (audioData, secretText) => {
        const binaryText = Steganography.textToBinary(secretText + "\0");
        const view = new DataView(audioData);

        // Skip header (44 bytes for standard WAV)
        let dataOffset = 44;
        let textIdx = 0;

        for (let i = dataOffset; i < audioData.byteLength && textIdx < binaryText.length; i += 2) {
            // Modify LSB of 16-bit PCM sample
            let sample = view.getInt16(i, true);
            if (binaryText[textIdx] === '1') {
                sample |= 1;
            } else {
                sample &= ~1;
            }
            view.setInt16(i, sample, true);
            textIdx++;
        }
        return audioData;
    },

    decodeAudio: (audioData) => {
        const view = new DataView(audioData);
        let dataOffset = 44;
        let binaryText = "";

        for (let i = dataOffset; i < audioData.byteLength; i += 2) {
            let sample = view.getInt16(i, true);
            binaryText += (sample & 1).toString();
        }
        return Steganography.binaryToText(binaryText);
    }
};
