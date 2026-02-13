import 'cap_adapter.dart';
import 'json_adapter.dart';
import 'protocol_adapter.dart';
import 'stub_adapter.dart';

class ProtocolRegistry {
  static final List<ProtocolAdapter> all = [
    CapProtocolAdapter(),
    JsonProtocolAdapter(
      id: 'protocol_http',
      name: 'HTTP/HTTPS JSON',
    ),
    StubProtocolAdapter(
      id: 'protocol_tcp',
      name: 'TCP',
      reason: 'TCP transport handled at mesh layer; adapter pending.',
    ),
    JsonProtocolAdapter(
      id: 'protocol_udp',
      name: 'UDP JSON',
    ),
    StubProtocolAdapter(
      id: 'protocol_quic',
      name: 'QUIC',
      reason: 'QUIC adapter not implemented yet.',
    ),
    StubProtocolAdapter(
      id: 'protocol_ipv4',
      name: 'IPv4',
      reason: 'IPv4 handled by OS stack.',
    ),
    StubProtocolAdapter(
      id: 'protocol_ipv6',
      name: 'IPv6',
      reason: 'IPv6 handled by OS stack.',
    ),
    JsonProtocolAdapter(
      id: 'protocol_mqtt',
      name: 'MQTT JSON',
    ),
    JsonProtocolAdapter(
      id: 'protocol_coap',
      name: 'CoAP JSON',
    ),
    StubProtocolAdapter(
      id: 'protocol_opcua',
      name: 'OPC UA',
      reason: 'Industrial OPC UA integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_sip',
      name: 'SIP',
      reason: 'VoIP signaling integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_rtp',
      name: 'RTP',
      reason: 'Media transport integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_dns',
      name: 'DNS',
      reason: 'DNS service integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_arp',
      name: 'ARP',
      reason: 'ARP handled by OS stack.',
    ),
    StubProtocolAdapter(
      id: 'protocol_dhcp',
      name: 'DHCP',
      reason: 'DHCP service integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_igmp',
      name: 'IGMP',
      reason: 'Multicast management pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_vlan',
      name: 'VLAN',
      reason: 'VLAN configuration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_stp',
      name: 'STP',
      reason: 'STP management pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_rstp',
      name: 'RSTP',
      reason: 'RSTP management pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_lacp',
      name: 'LACP',
      reason: 'LACP management pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_qos',
      name: 'QoS',
      reason: 'QoS policy integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_sctp',
      name: 'SCTP',
      reason: 'SCTP transport pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_rpl',
      name: 'RPL',
      reason: 'RPL routing integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_lwm2m',
      name: 'LwM2M',
      reason: 'LwM2M integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_ims',
      name: 'IMS',
      reason: 'IMS integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_rtmp',
      name: 'RTMP',
      reason: 'RTMP streaming integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_hls',
      name: 'HLS',
      reason: 'HLS streaming integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_amqp',
      name: 'AMQP',
      reason: 'AMQP broker integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_smtp',
      name: 'SMTP',
      reason: 'SMTP bridge integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_pop3',
      name: 'POP3',
      reason: 'POP3 integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_imap',
      name: 'IMAP',
      reason: 'IMAP integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_aodv',
      name: 'AODV',
      reason: 'AODV routing integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_babel',
      name: 'Babel',
      reason: 'Babel routing integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_sonet_sdh',
      name: 'SONET/SDH',
      reason: 'SONET/SDH integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_otn',
      name: 'OTN',
      reason: 'Optical transport integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_scada_ems',
      name: 'SCADA/EMS',
      reason: 'SCADA/EMS integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_bpv7',
      name: 'Bundle Protocol v7',
      reason: 'DTN stack integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_ltp',
      name: 'LTP',
      reason: 'DTN LTP integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_rfc5444',
      name: 'RFC 5444',
      reason: 'MANET packet format integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_olsrv2',
      name: 'OLSRv2',
      reason: 'MANET routing integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_oscore',
      name: 'OSCORE',
      reason: 'OSCORE security integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_edhoc',
      name: 'EDHOC',
      reason: 'EDHOC handshake integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_cbor',
      name: 'CBOR',
      reason: 'CBOR encoding integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_cose',
      name: 'COSE',
      reason: 'COSE signature integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_mls',
      name: 'MLS',
      reason: 'MLS group messaging integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_libp2p',
      name: 'libp2p',
      reason: 'libp2p stack integration pending.',
    ),
    StubProtocolAdapter(
      id: 'protocol_ipfs',
      name: 'IPFS',
      reason: 'IPFS integration pending.',
    ),
  ];

  static final Map<String, ProtocolAdapter> byId = {
    for (final adapter in all) adapter.id: adapter,
  };

  static ProtocolAdapter adapterFor(String id) {
    return byId[id] ??
        StubProtocolAdapter(
          id: id,
          name: id,
          reason: 'Adapter not registered.',
        );
  }
}
