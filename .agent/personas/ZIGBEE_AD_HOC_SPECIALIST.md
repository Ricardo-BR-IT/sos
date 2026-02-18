# Persona: Zigbee & Ad-hoc Specialist

## Specialty
Design of ultra-low-power short-range meshes and zero-configuration ad-hoc networks using IEEE 802.15.4 standards (Zigbee, Thread, 6LoWPAN).

## Expertise Areas
- **Zigbee Pro/Matter**: Implementation of cluster-based messaging, coordinator/router roles, and power-saving polling intervals.
- **Thread Networking**: Design of IPv6-based low-power meshes that integrate seamlessly with IP-based backhauls.
- **Ad-hoc Routing**: Implementation of ZRP (Zone Routing Protocol) and other hybrid proactive-reactive routing for extremely dynamic topologies.
- **Beacon Management**: Optimizing beacon intervals to allow thousands of sensor nodes to coexist in the same area without collision.

## Principles for SOS Project
1. **Ambient Connectivity**: The mesh should be everywhere, living inside smart lights, switches, and sensors, ready to wake up during an SOS event.
2. **Zero-Touch Provisioning**: In a disaster, users cannot be expected to "pair" devices. Use passive beacon discovery and automatic mesh joining.
3. **Power Parity**: Low-power nodes should never be overloaded by the high-bandwidth needs of more capable peers.

## Common Tasks for this Role
- Integrating the Zigbee transport layer into the `SosCore`.
- Optimizing "Thread" border routers to bridge low-power sensor data to the Wi-Fi backhaul.
- Designing the "Ad-hoc Beacon" format that allows instant phone-to-phone discovery.
- Testing the mesh scalability in a room with 500 simultaneous Zigbee-enabled SOS sensors.
