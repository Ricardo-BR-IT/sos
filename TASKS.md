# Orquestração de Tarefas - Resgate SOS

## Objetivo
Organizar entregas em paralelo com múltiplos agentes, garantindo visibilidade, dependências claras e handoff consistente.

## Fluxo de trabalho
- Cada tarefa tem um único agente responsável
- Atualizar status e checklist ao finalizar o dia
- Toda tarefa registra dependências e arquivos impactados
- Handoff registra progresso, bloqueios e próximos passos
- Concluir tarefa apenas com validação local e revisão concluída

## Estados
| Status | Descrição |
|--------|-----------|
| PENDENTE | Aguardando início |
| EM PROGRESSO | Em execução ativa |
| EM REVISÃO | Implementado, aguardando validação ou revisão |
| BLOQUEADO | Dependência externa impede avanço |
| CONCLUÍDO | Finalizado e validado |

## Agentes Ativos em Paralelo
| Agente | Tarefa principal | Secundária | Status | Bloqueios | Próximo handoff |
|--------|------------------|------------|--------|-----------|-----------------|
| Agente 1 | MESH-CORE-002 | MESH-CORE-005 | EM EXECUÇÃO PARALELA | - | Sincronização de saltos e deduplicação |
| Agente 2 | TRANSPORT-002 | TRANSPORT-003 | EM EXECUÇÃO PARALELA | - | Validação de transportes unificados |
| Agente 3 | SYNC-001 | - | EM EXECUÇÃO PARALELA | - | Integração total com HandshakeManager |
| Agente 8 | MESH-CORE-004 | - | EM EXECUÇÃO PARALELA | - | Diagnósticos em tempo real |

## Quadro do Sprint Atual

### Em Progresso
| ID | Agente | Fase | Prioridade | Dependências | Entregável |
|----|--------|------|------------|-------------|------------|
| MESH-CORE-002 | Agente 1 | Fase 0 | Alta | MESH-CORE-001 | TTL e saltos no mesh (Ativo) |
| MESH-CORE-004 | Agente 8 | Fase 0 | Média | MESH-CORE-002 | Diagnósticos de campo (Ativo) |
| MESH-CORE-005 | Agente 1 | Fase 0 | Média | MESH-CORE-002 | Deduplicação e flooding (Ativo) |
| SYNC-001 | Agente 3 | Fase 0 | Crítica | - | Fila offline store-and-forward (Ativo) |
| TRANSPORT-002 | Agente 2 | Fase 0 | Alta | TRANSPORT-001 | BLE desktop (Windows/Linux) (Ativo) |
| TRANSPORT-003 | Agente 2 | Fase 0 | Alta | - | Wi-Fi LAN mDNS + TCP (Ativo) |

### Em Revisão
| ID | Agente | Fase | Prioridade | Dependências | Entregável |
|----|--------|------|------------|-------------|------------|
| - | - | - | - | - | - |

### Pendente
| ID | Agente | Fase | Prioridade | Dependências | Entregável |
|----|--------|------|------------|-------------|------------|
| TRANSPORT-004 | Agente 2 | Fase 0 | Média | TRANSPORT-003 | Transporte Ethernet |

### Concluídas
| ID | Agente | Fase | Prioridade | Entregável |
|----|--------|------|------------|------------|
| MESH-CORE-001 | Agente 1 | Fase 0 | Alta | Verificação de assinatura e integridade |
| MESH-CORE-003 | Agente 1 | Fase 0 | Alta | Segurança e rotação de chaves |
| TRANSPORT-001 | Agente 2 | Fase 0 | Alta | BLE Mobile |

## Detalhes das Tarefas Ativas

### MESH-CORE-002 - TTL Configurável e Controle de Saltos
Status: EM PROGRESSO  
Prioridade: Alta  
Dependências: MESH-CORE-001  
Arquivos: packages/sos_kernel/lib/mesh/mesh_service.dart, packages/sos_kernel/lib/mesh/sos_frame.dart, packages/sos_kernel/lib/mesh/mesh_peer.dart

Checklist:
- [x] TTL configurável por tipo (SOS=10, Hello=5, Data=8)
- [ ] Contador de saltos (hops) com limite máximo
- [ ] Estratégia de forwarding inteligente (não repetir para mesmos peers)
- [ ] Métricas de eficiência de roteamento

### MESH-CORE-004 - Diagnósticos de Campo Avançados
Status: EM PROGRESSO  
Prioridade: Média  
Dependências: MESH-CORE-002  
Arquivos: packages/sos_kernel/lib/mesh/mesh_diagnostics.dart, packages/sos_kernel/lib/telemetry/telemetry_service.dart

Checklist:
- [x] Ping/pong por transporte específico
- [x] Medição de RTT (Round Trip Time)
- [x] Cálculo de taxa de perda de pacotes
- [ ] Mapa de cobertura de peers por transporte
- [ ] Export de métricas para análise

### MESH-CORE-005 - Otimização de Flooding e Deduplicação
Status: EM PROGRESSO  
Prioridade: Média  
Dependências: MESH-CORE-002  
Arquivos: packages/sos_kernel/lib/mesh/mesh_service.dart

Checklist:
- [ ] Cache LRU de mensagens vistas
- [x] Bloom filter para deduplicação eficiente
- [ ] Forwarding seletivo baseado em histórico
- [ ] Limpeza automática de cache antigo

### TRANSPORT-002 - BLE Transport Desktop (Windows/Linux)
Status: EM PROGRESSO  
Prioridade: Alta  
Dependências: TRANSPORT-001  
Arquivos: packages/sos_transports/lib/transport/ble_transport.dart

Checklist:
- [x] Windows BLE support (win_ble ou similar)
- [x] Linux BLE support (bluez via dbus)
- [x] Unificação de API com mobile
- [ ] Testes de integração

### TRANSPORT-003 - Wi-Fi LAN + mDNS Discovery
Status: EM PROGRESSO  
Prioridade: Alta  
Dependências: -  
Arquivos: packages/sos_transports/lib/transport/wifi_direct_transport.dart, packages/sos_transports/lib/transport/udp_transport.dart

Checklist:
- [x] Publicar serviço mDNS (_sos-mesh._tcp)
- [x] Descoberta de peers na rede
- [x] Conexão TCP entre peers
- [ ] Broadcast via multicast UDP
- [ ] Fallback para unicast

### TRANSPORT-004 - Ethernet Transport
Status: PENDENTE  
Prioridade: Média  
Dependências: TRANSPORT-003  
Arquivos: packages/sos_transports/lib/transport/ethernet_transport.dart

Checklist:
- [ ] Detecção de interfaces Ethernet
- [ ] Configuração de IP estático/dinâmico
- [ ] Comunicação TCP sobre Ethernet

### SYNC-001 - Fila de Mensagens Offline (Store-and-Forward)
Status: EM PROGRESSO  
Prioridade: Crítica  
Dependências: -  
Arquivos: packages/sos_transports/lib/queue/message_queue_manager.dart, packages/sos_vault/lib/db/vault_database.dart, packages/sos_transports/lib/transport/handshake_manager.dart

Checklist:
- [x] Criar tabela pending_messages no Drift
- [x] Implementar MessageQueueManager
- [ ] Integrar com HandshakeManager para disparar envio ao conectar

## Tarefas Concluídas com Detalhes

### MESH-CORE-001 - Verificação de Assinatura e Integridade
Status: CONCLUÍDO  
Prioridade: Alta  
Arquivos: packages/sos_kernel/lib/mesh/sos_frame.dart, packages/sos_kernel/lib/mesh/mesh_service.dart, packages/sos_kernel/lib/sos_kernel.dart, packages/sos_kernel/test/mesh/sos_frame_test.dart

Checklist:
- [x] Adicionar campo de assinatura em SosFrame
- [x] Implementar CryptoManager.sign() para pacotes
- [x] Implementar CryptoManager.verify() para validação
- [x] Adicionar verificação em MeshService.receive()
- [x] Testes unitários para assinatura/verificação
- [x] Documentação de segurança

### MESH-CORE-003 - Revisão de Segurança e Rotação de Chaves
Status: CONCLUÍDO  
Prioridade: Alta  
Arquivos: packages/sos_kernel/lib/identity/crypto_manager.dart, packages/sos_vault/lib/db/vault_database.dart, packages/sos_kernel/lib/mesh/mesh_service.dart

Checklist:
- [x] Auditoria de seeds e armazenamento seguro
- [x] Implementar rotação de chaves periódica
- [x] Backup criptografado da identidade
- [x] Validação de integridade do storage
- [x] Testes de penetração básicos

### TRANSPORT-001 - Finalizar BLE Transport (Android/iOS)
Status: CONCLUÍDO  
Prioridade: Alta  
Arquivos: packages/sos_transports/lib/transport/ble_transport.dart, packages/sos_transports/test/ble_transport_test.dart

Checklist:
- [x] Scan por UUID de serviço MESH
- [x] Conexão e descoberta de características
- [x] Envio/recepção de mensagens BLE
- [x] Reconexão automática
- [x] Testes básicos de unidade

## Template de nova tarefa
ID: AREA-XXX  
Agente: Nome  
Fase: Fase X  
Prioridade: Baixa, Média, Alta, Crítica  
Status: PENDENTE  
Dependências: -  
Arquivos: -  

Checklist:
- [ ] Item 1
- [ ] Item 2

## Template de handoff diário
Tarefa: AREA-XXX  
Status atual:  
Progresso:  
Bloqueios:  
Próximo passo:  
Arquivos tocados:
