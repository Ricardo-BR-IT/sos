# Nó Solar Passivo SOS - Documentação Técnica

**Objetivo**: Nó de retransmissão autônomo que opera por 5+ anos sem manutenção.

---

## 📋 Bill of Materials (BOM)

| Componente | Modelo | Qtd | Preço Est. | Fornecedor |
|------------|--------|-----|------------|------------|
| SoC | ESP32-C6-WROOM-1U | 1 | R$35 | AliExpress/LCSC |
| LoRa Module | Semtech SX1262 (868/915MHz) | 1 | R$25 | AliExpress |
| Bateria | LiFePO4 3.2V 6000mAh | 1 | R$80 | MercadoLivre |
| Painel Solar | 5V 1W Monocristalino | 1 | R$25 | Amazon |
| MPPT Controller | CN3791 (4.2V) | 1 | R$8 | AliExpress |
| Supercapacitor | 2.7V 10F | 1 | R$15 | AliExpress |
| Antena | Dipolo 1/4 wave ou Yagi 3D | 1 | R$5-20 | DIY |
| Gabinete | IP68 Junction Box 100x68x50mm | 1 | R$30 | Ferragem |
| Conectores | SMA-F, cables, misc | - | R$20 | - |

**Custo Total Estimado**: ~R$240-280

---

## ⚡ Diagrama de Potência

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Solar Panel   │────▶│  MPPT CN3791    │────▶│   LiFePO4       │
│   5V 1W         │     │  4.2V Charger   │     │   3.2V 6000mAh  │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   ESP32-C6      │◀────│   LDO 3.3V      │◀────│   Supercap      │
│   + SX1262      │     │   (MCP1700)     │     │   2.7V 10F      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 📊 Cálculo de Autonomia

### Consumo Estimado
| Estado | Corrente | Duração/Ciclo | % do Tempo |
|--------|----------|---------------|------------|
| Deep Sleep | 10 µA | 9 min 55 sec | 99.2% |
| Wake + Scan | 15 mA | 3 sec | 0.5% |
| TX (LoRa) | 120 mA | 200 ms | 0.3% |

### Corrente Média
```
I_avg = (0.992 × 0.01mA) + (0.005 × 15mA) + (0.003 × 120mA)
I_avg = 0.01 + 0.075 + 0.36 = 0.445 mA ≈ 0.5 mA
```

### Autonomia sem Sol
```
T = Capacidade / I_avg = 6000mAh / 0.5mA = 12000 horas = 500 dias
```

### Com Recarga Solar
- Painel 1W @ 5V = 200mA pico
- Média diária (4h sol útil) = 200mA × 4h = 800mAh/dia
- Consumo diário = 0.5mA × 24h = 12mAh/dia
- **Balanço**: +788mAh/dia ✅

> **Conclusão**: Com apenas 4 horas de sol por dia, o nó é energeticamente positivo. Opera indefinidamente.

---

## 🖥️ Firmware (ESP32-C6)

```cpp
#include <Arduino.h>
#include <LoRa.h>
#include <esp_sleep.h>

#define SLEEP_TIME_US (10 * 60 * 1000000ULL) // 10 minutos
#define LORA_FREQ 915E6

void setup() {
    // Inicializa LoRa
    LoRa.begin(LORA_FREQ);
    LoRa.setSpreadingFactor(12); // Máximo alcance
    LoRa.setSignalBandwidth(125E3);
    
    // Verifica se há mensagens pendentes
    int packetSize = LoRa.parsePacket();
    if (packetSize > 0) {
        // Retransmite o pacote
        byte buffer[256];
        int len = 0;
        while (LoRa.available()) {
            buffer[len++] = LoRa.read();
        }
        
        delay(random(100, 500)); // Anti-colisão
        LoRa.beginPacket();
        LoRa.write(buffer, len);
        LoRa.endPacket();
    }
    
    // Desliga LoRa
    LoRa.end();
    
    // Entra em Deep Sleep
    esp_sleep_enable_timer_wakeup(SLEEP_TIME_US);
    esp_deep_sleep_start();
}

void loop() {
    // Nunca chega aqui (Deep Sleep reinicia pelo setup)
}
```

---

## 🔧 Montagem do Gabinete IP68

1. **Preparar o gabinete**: Fure para antena (SMA) e grommet do painel solar.
2. **Instalar painel solar**: Fixe na tampa com silicone UV-resistant.
3. **Montar eletrônica**: Cole a PCB no fundo com fita térmica.
4. **Conectar antena**: Use prensa-cabo ou grommet com silicone.
5. **Selar**: Verifique o O-ring e aplique graxa de silicone.
6. **Teste de estanqueidade**: Submergir por 1h a 30cm.

---

## 📍 Locais de Instalação Recomendados

| Local | Prós | Contras |
|-------|------|---------|
| Topo de Montanha | Alcance máximo, sol pleno | Acesso difícil para manutenção |
| Postes de Luz | Altura okay, acesso fácil | Pode precisar de autorização |
| Torres de Celular | Excelente altura | Requer parceria/contrato |
| Telhados de Prédios | Bom alcance urbano | Obstruções potenciais |
| Árvores Altas | Gratuito, discreto | Sombra variável, vibrações |

---

## 🛡️ Proteções Implementadas

- **Sobrecarga**: CN3791 corta em 4.2V
- **Sobrecorrente**: Fuse de 500mA
- **Inversão de polaridade**: Diodo Schottky na entrada
- **ESD**: TVS na antena SMA
- **Thermal runaway**: LiFePO4 é intrinsecamente seguro

---

## 📦 Kit de Instalação de Campo

- [ ] Nó montado e testado
- [ ] Antena (Yagi 3D ou dipolo)
- [ ] Abraçadeiras UV-resistant (10x)
- [ ] Mastro ou suporte
- [ ] Chave para gabinete
- [ ] Multímetro (verificação)
- [ ] GPS ou app de localização

---

*Projeto desenvolvido pelo Power Electronics Specialist + Antenna Design Expert*
