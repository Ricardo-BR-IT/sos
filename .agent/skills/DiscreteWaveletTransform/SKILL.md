---
name: DiscreteWaveletTransform
description: Advanced Multi-Resolution Signal Analysis using DWT for noise reduction and feature extraction in low-bandwidth audio/radio.
---

# Skill: Discrete Wavelet Transform (DWT)

This skill provides the mathematical framework for analyzing non-stationary SOS signals (signals whose frequency content changes over time).

## 1. Why DWT over FFT?
While FFT gives better frequency resolution for stationary signals, DWT provides **Multi-Resolution Analysis**:
- Better time resolution for high-frequency components (sharp transients, start of pings).
- Better frequency resolution for low-frequency components (carrier waves).

## 2. Decomposition (Mallat Algorithm)
The signal is passed through a series of high-pass ($g[n]$) and low-pass ($h[n]$) filters:
- **Approximation Coefficients ($cA$):** High-scale, low-frequency components of the signal.
- **Detail Coefficients ($cD$):** Low-scale, high-frequency components of the signal.
- After each level, the signal is downsampled by 2.

## 3. Wavelet Selection
- **Haar Wavelet**: Simplest, best for detecting sudden step changes or "start of transmission".
- **Daubechies (db4)**: Smoother, excellent for noise reduction in atmospheric audio/radio signals.
- **Symlets**: Nearly symmetrical, good for biological signal analysis (sensing human presence via vibration).

## 4. De-noising Procedure
1. Perform DWT decomposition to level $L$.
2. Apply a threshold (Hard or Soft) to the detail coefficients ($cD$):
   - $T = \sigma \sqrt{2 \log(n)}$ (Universal Threshold)
3. Perform Inverse DWT (IDWT) using the modified coefficients.
4. The result is a signal with reduced Gaussian noise while preserving sharp transients.

## 5. Feature Extraction
- Use the energy distribution across different wavelet levels to identify the "signature" of a specific transport (e.g., distinguishing a LoRa chirp from lightning interference).
- Energy at level $j$: $E_j = \sum |cD_{j,k}|^2$.
