---
description: Workflow for calculating and optimizing power budget for long-term node deployment.
---

# Workflow: Power Budget Calculation

Use the `PowerManagement` skill for theory and formulas.

## Steps

1. **Define Duty Cycle**
   - `T_active_sec`: Time in Active mode (e.g., 5 seconds for TX/RX per 10 minutes).
   - `T_sleep_sec`: Time in Deep Sleep (e.g., 595 seconds).
   - `Period_sec`: Total cycle time (e.g., 600 seconds or 10 minutes).

2. **Measure Currents**
   - Connect an ammeter (e.g., Nordic PPK2) to the power line.
   - Measure `I_active` (e.g., 120 mA) and `I_sleep` (e.g., 8 µA).

3. **Calculate Average Current**
   ```
   I_avg = (T_active * I_active + T_sleep * I_sleep) / Period
   I_avg = (5 * 0.120 + 595 * 0.000008) / 600
   I_avg = (0.6 + 0.00476) / 600 = ~ 1.01 mA
   ```

4. **Estimate Battery Life**
   - Capacity: 3000 mAh LiFePO4.
   ```
   T_life = C / I_avg = 3000 / 1.01 = ~2970 hours = ~124 days
   ```

5. **Factor in Solar Input (if applicable)**
   - Average daily solar harvest: ~X Wh.
   - Daily consumption: $24h \times I_{avg} \times V_{nom}$.
   - If Harvest > Consumption, the system is self-sustaining.

6. **Document & Adjust**
   - If life is too short, reduce duty cycle or active current.
   - Document final budget in the node's hardware spec sheet.
