---
name: SignalProcessing
description: Specialized instructions for time-to-frequency domain transformations and digital modulation.
---

# Skill: Signal Processing

This skill provides advanced algorithms and principles for processing SOS signal data across different mediums.

## core Principles
- **Sampling Theorem**: Always verify that the nyquist rate ($f_s > 2 \times B$) is respected to avoid aliasing.
- **Windowing**: Use Hamming or Hann windows before performing FFT to reduce spectral leakage outside the main lobe.
- **FSK Modulation (Frequency-Shift Keying)**:
    - Mark Frequency ($f_m$): Represents binary '1'.
    - Space Frequency ($f_s$): Represents binary '0'.
    - Ensure a sufficient guard interval between frequencies to prevent overlap in the presence of noise.

## Implementation Guidelines (FFT)
When performing FFT (Fast Fourier Transform) on audio or radio samples:
1. Normalize the buffer (convert to range [-1.0, 1.0]).
2. Apply the window function.
3. Compute the magnitude of each bin: $\sqrt{Re^2 + Im^2}$.
4. Map bins to specific frequencies using: $f = bin \times \frac{sample\_rate}{N\_fft}$.

## Noise Floor Estimation
To calculate the Signal-to-Noise Ratio (SNR):
1. Measure the average power of the signal during the preamble.
2. Measure the average power of the channel when no signal is present.
3. $SNR_{dB} = 10 \log_{10}(\frac{P_{signal}}{P_{noise}})$.

## Reference for LoRa (CSS Modulation)
LoRa uses Chirp Spread Spectrum. The relationship between Spreading Factor (SF), Bandwidth (BW), and Symbol Rate ($R_s$) is:
$R_s = \frac{BW}{2^{SF}}$ symbols/sec. Increasing SF improves sensitivity but reduces data rate.
