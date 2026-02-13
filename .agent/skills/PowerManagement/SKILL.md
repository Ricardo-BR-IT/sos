---
name: PowerManagement
description: Techniques for maximizing battery life and solar charging efficiency in SOS nodes.
---

# Skill: Power Management

This skill covers power system optimization for long-duration, off-grid SOS node operation.

## 1. Sleep Mode Strategies
| Mode                    | Current Draw | Wake Source        | Use Case                           |
|-------------------------|--------------|--------------------|------------------------------------|
| Deep Sleep              | < 10 µA      | RTC Timer, GPIO    | Scheduled "Wake and Scan"          |
| Light Sleep (WiFi off)  | ~500 µA      | Timer, Interrupt   | Listening for hardware events      |
| Modem Sleep (WiFi on)   | ~15 mA       | DTIM Interval      | Keeping mesh connection alive      |
| Active                  | ~80-240 mA   | N/A                | Active transmit/receive            |

## 2. MPPT Solar Charging
- **MPPT (Maximum Power Point Tracking)**: Continuously adjusts the load on the solar panel to extract peak power.
- **Algorithm**: Perturb & Observe (P&O) is simple. Sample voltage/current, increase duty cycle if $P_{new} > P_{old}$.
- **ICs**: Consider BQ25895, CN3791 for integrated solutions.

## 3. Battery Selection
| Chemistry   | Nominal V | Capacity | Temp Range   | Cycles | Notes                       |
|-------------|-----------|----------|--------------|--------|-----------------------------|
| Li-ion      | 3.7V      | High     | 0°C to 45°C  | 500    | Common, risk of thermal runaway. |
| LiFePO4     | 3.2V      | Medium   | -20°C to 60°C| 2000+  | **Recommended for SOS.** Stable, safe. |
| Supercap    | 2.7V      | Low      | -40°C to 65°C| 1M+    | Burst power, limited storage. |

## 4. Power Budget Calculation
$T_{life} = \frac{C_{battery}}{I_{avg}}$
Where:
- $C_{battery}$: Capacity in mAh.
- $I_{avg}$: $T_{sleep} \times I_{sleep} + T_{active} \times I_{active}$ per period.
