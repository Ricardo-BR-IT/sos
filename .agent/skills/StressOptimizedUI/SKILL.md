---
name: StressOptimizedUI
description: Design principles for emergency/stress situations, focusing on legibility, speed of action, and high-visibility.
---

# Skill: Stress-Optimized UI

This skill provides the design requirements for creating user interfaces that remain effective during high-stress emergency scenarios.

## 1. Interaction Principles
- **One-Motion Action**: Critical actions (like sending an SOS) must require only one physical motion or a very simple, high-confidence gesture (e.g., long-press or triple-tap).
- **Confirmation without Friction**: Avoid "Are you sure?" popups. Use a progressive hold or a swipe to confirm to prevent accidental triggers while maintaining speed.
- **Haptic Confirmation**: Provide distinct vibration patterns for success and failure so the user doesn't need to look at the screen to know their request was sent.

## 2. Visual Requirements
- **High-Contrast Palette**: Use "Safety Orange", "High-Visibility Yellow", and "Luminous Red" on pure black or white backgrounds.
- **Typography**: Use heavy-weight sans-serif fonts (e.g., Roboto Bold, Inter, or specialized dyslexia-friendly fonts). Character height should be at least 4mm on mobile screens.
- **Iconography**: Use universally recognized emergency symbols (e.g., the Red Cross/Crescent, the SOS block). Avoid abstract icons.

## 3. Contextual Awareness
- **Bandwidth Indicators**: Clearly show the "estimated time to delivery" for messages. If the link is slow, use a progress bar even for small text packets.
- **Battery Optimization**: When battery is < 15%, the UI should automatically switch to "Ultra-Contrast Mono" mode and disable all non-essential animations and images.
- **Dynamic Sizing**: Automatically increase text size if the accelerometer detects high vibration (e.g., in a moving rescue vehicle).

## 4. Accessibility Checklist
[ ] Does the UI work with screen readers (TalkBack/VoiceOver)?
[ ] Are all target tap areas at least 44x44 pixels?
[ ] Is the "Big Red Button" visible without scrolling on every relevant screen?
[ ] Is there an audio-only mode for users with low vision or in smoke-filled rooms?
