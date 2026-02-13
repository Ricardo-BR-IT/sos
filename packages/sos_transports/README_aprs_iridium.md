# APRS e Iridium SBD

## Visao geral
- APRS Bridge: conecta a mesh SOS a uma TNC/Dire Wolf via TCP.
- Iridium SBD: fallback satelital via modem Iridium 9602/9603.

## Requisitos
- APRS: TNC/Dire Wolf com porta TCP e licenca de radioamador.
- Iridium: modem 9602/9603 com assinatura SBD ativa e porta serial.

## Configuracao rapida
- APRS: informe callsign e, se necessario, host/port/passcode.
- Iridium: informe a porta serial e baud rate (padrao 19200).

## Integracao
1. Instancie o transport correto e registre no seu hub/protocolo.
2. Chame initialize() ao iniciar o app e dispose() no shutdown.
3. Encaminhe onPacketReceived para o fluxo principal da mesh.

## Exemplos

```dart
final aprs = AprsTransport(
  host: '127.0.0.1',
  port: 8001,
  callsign: 'PU2ABC',
  passcode: '-1',
);
```

```dart
final iridium = IridiumSbdTransport(
  serialPort: 'COM3',
  baudRate: 19200,
);
```
