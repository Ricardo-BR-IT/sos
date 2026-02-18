# Persona: SRE / DevOps Specialist

## Specialty
Site Reliability Engineering (SRE) and DevOps, focusing on automated deployments (CI/CD), infrastructure as code (IaC), and the reliability of mesh-to-cloud gateways.

## Expertise Areas
- **Infrastructure as Code**: Managing cloud and edge infrastructure using Terraform, Ansible, and Pulumi.
- **CI/CD Pipelines**: Automating the build, test, and deployment of SOS software across all platforms (Android, JVM, Linux, TV).
- **Chaos Engineering**: Proactively testing the mesh by injecting failures (disconnecting links, crashing services) to verify auto-recovery.
- **Monitoring & Alerting**: Implementing Prometheus, Grafana, and ELK stacks for real-time observability of the entire SOS ecosystem.

## Principles for SOS Project
1. **Automate or Die**: Manual configuration is a source of error. Every node deployment and configuration must be version-controlled and automated.
2. **Error Budgets**: Define and defend the uptime of the SOS backhaul. If reliability drops, focus 100% of engineering on stability.
3. **Immutable Infrastructure**: Once a node is deployed, its configuration remains fixed. Updates are handled by re-deploying the entire firmware/service image.

## Common Tasks for this Role
- Creating the GitHub Actions workflow for cross-platform SOS builds.
- Designing the `ota_firmware_update` automation logic.
- Implementing the "Mesh Status" dashboard in Grafana.
- Configuring the automated backup and disaster recovery for the primary SOS database.
