# Kit Antena Yagi Imprimível 3D para SOS LoRa

**Ganho**: ~10 dBi direcional  
**Frequência**: 868 MHz (EU) / 915 MHz (US/BR)  
**Custo**: < R$20 em materiais  
**Tempo de Construção**: ~2 horas

---

## 📋 Lista de Materiais (BOM)

| Item | Quantidade | Especificação | Fonte |
|------|------------|---------------|-------|
| Filamento PLA/PETG | ~100g | Qualquer cor | Impressora 3D |
| Fio de cobre esmaltado | 2m | 2mm diâmetro | Loja de eletrônica |
| Tubo PVC ou Cabo de vassoura | 1m | 20-25mm diâmetro | Ferragem |
| Conector SMA fêmea | 1 | Painel ou chassis | AliExpress |
| Cabo coaxial RG58 | 1m | 50Ω, com conectores | Loja de eletrônica |
| Parafusos M3 | 8 | 10mm comprimento | Ferragem |

---

## 📐 Dimensões dos Elementos (915 MHz)

| Elemento | Comprimento (mm) | Distância do Refletor (mm) |
|----------|------------------|----------------------------|
| Refletor | 172 | 0 (referência) |
| Dipolo Ativo | 158 | 52 |
| Diretor 1 | 150 | 95 |
| Diretor 2 | 146 | 152 |
| Diretor 3 | 143 | 218 |

> **Para 868 MHz**: Multiplique todos os valores por 1.054

---

## 🖨️ Arquivos STL para Impressão

### Suportes de Elementos
```
yagi_element_holder.stl     # Suporte para cada elemento (imprimir 5x)
yagi_boom_connector.stl     # Conector para o boom/tubo principal
yagi_sma_mount.stl          # Suporte para conector SMA no dipolo
yagi_tripod_mount.stl       # (Opcional) Suporte para tripé fotográfico
```

### Configurações de Impressão
- **Camada**: 0.2mm
- **Preenchimento**: 20%
- **Material**: PETG (preferido, melhor UV-resistant) ou PLA
- **Suportes**: Não necessários

---

## 🔧 Instruções de Montagem

### Passo 1: Preparar os Elementos
1. Corte 5 pedaços de fio de cobre nos comprimentos especificados.
2. Dobre cada fio em formato de "U" para encaixar nos suportes impressos.

### Passo 2: Preparar o Dipolo Ativo
1. O dipolo é o único elemento conectado eletricam ente.
2. Corte o dipolo em DUAS metades (79mm cada para 915MHz).
3. Solde um lado ao pino central do conector SMA.
4. Solde o outro lado à malha/ground do conector SMA.

```
   ┌────── 79mm ──────┐
   │                  │
   ●──────────────────○──────────────────●
   │                  │
   └── Central SMA ───┴─── Ground SMA ───┘
```

### Passo 3: Montar no Boom
1. Encaixe os suportes impressos no tubo/cabo de vassoura.
2. Fixe com parafusos M3 se necessário.
3. Posicione os elementos nas distâncias corretas.

### Passo 4: Testar
1. Conecte ao rádio LoRa ou NanoVNA.
2. Verifique VSWR < 1.5 na frequência alvo.
3. Se VSWR alto, ajuste ligeiramente o comprimento do dipolo.

---

## 📊 Performance Esperada

| Métrica | Valor |
|---------|-------|
| Ganho | ~10 dBi |
| Abertura Horizontal | ~50° |
| Abertura Vertical | ~40° |
| Relação Frente/Costas | ~15 dB |
| Impedância | 50Ω (matched) |

---

## 📷 Diagrama de Radiação

```
        Direção de Máximo Ganho
                 ↑
                 │
        ╭────────┴────────╮
       ╱                   ╲
      ╱    LÓBULO PRINCIPAL ╲
     │                       │
     │         ●●●●●         │   ← Antena aqui
     │                       │
      ╲                     ╱
       ╲                   ╱
        ╰─────────────────╯
              Refletor
                 │
                 ↓
           Lóbulo Traseiro
            (Atenuado)
```

---

## ⚠️ Notas Importantes

1. **Polarização**: Esta antena é polarizada linearmente (vertical).
   - Certifique-se de que a antena do outro lado também está vertical.
   - Mismatch de polarização = -3dB de perda.

2. **Apontamento**: A antena é direcional.
   - Use uma bússola para apontar para o gateway/repetidor.
   - Pequenos ajustes de ângulo fazem grande diferença.

3. **Condições Climáticas**: 
   - PETG resiste melhor a UV que PLA.
   - Em áreas de muita chuva, aplique verniz spray nos elementos de cobre.

---

## 🔗 Downloads

- [yagi_915mhz_full_kit.zip](#) - Todos os STLs + Este guia em PDF
- [yagi_868mhz_full_kit.zip](#) - Versão para Europa/África

---

*Projeto desenvolvido pelo Conselho dos 39 Especialistas SOS*
