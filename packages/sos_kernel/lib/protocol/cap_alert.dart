import 'package:xml/xml.dart';

class CapInfo {
  final String category;
  final String event;
  final String urgency;
  final String severity;
  final String certainty;
  final String? headline;
  final String? description;
  final String? instruction;

  const CapInfo({
    required this.category,
    required this.event,
    required this.urgency,
    required this.severity,
    required this.certainty,
    this.headline,
    this.description,
    this.instruction,
  });

  Map<String, dynamic> toMap() => {
        'category': category,
        'event': event,
        'urgency': urgency,
        'severity': severity,
        'certainty': certainty,
        'headline': headline,
        'description': description,
        'instruction': instruction,
      };

  static CapInfo fromMap(Map<String, dynamic> map) {
    return CapInfo(
      category: map['category']?.toString() ?? 'Safety',
      event: map['event']?.toString() ?? 'General Alert',
      urgency: map['urgency']?.toString() ?? 'Immediate',
      severity: map['severity']?.toString() ?? 'Severe',
      certainty: map['certainty']?.toString() ?? 'Observed',
      headline: map['headline']?.toString(),
      description: map['description']?.toString(),
      instruction: map['instruction']?.toString(),
    );
  }

  static CapInfo fromXml(XmlElement element) {
    return CapInfo(
      category: _text(element, 'category') ?? 'Safety',
      event: _text(element, 'event') ?? 'General Alert',
      urgency: _text(element, 'urgency') ?? 'Immediate',
      severity: _text(element, 'severity') ?? 'Severe',
      certainty: _text(element, 'certainty') ?? 'Observed',
      headline: _text(element, 'headline'),
      description: _text(element, 'description'),
      instruction: _text(element, 'instruction'),
    );
  }
}

class CapAlert {
  final String identifier;
  final String sender;
  final DateTime sent;
  final String status;
  final String msgType;
  final String scope;
  final List<CapInfo> info;

  const CapAlert({
    required this.identifier,
    required this.sender,
    required this.sent,
    required this.status,
    required this.msgType,
    required this.scope,
    required this.info,
  });

  Map<String, dynamic> toMap() => {
        'identifier': identifier,
        'sender': sender,
        'sent': sent.toUtc().toIso8601String(),
        'status': status,
        'msgType': msgType,
        'scope': scope,
        'info': info.map((e) => e.toMap()).toList(),
      };

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('alert', nest: () {
      _node(builder, 'identifier', identifier);
      _node(builder, 'sender', sender);
      _node(builder, 'sent', sent.toUtc().toIso8601String());
      _node(builder, 'status', status);
      _node(builder, 'msgType', msgType);
      _node(builder, 'scope', scope);
      for (final infoEntry in info) {
        builder.element('info', nest: () {
          _node(builder, 'category', infoEntry.category);
          _node(builder, 'event', infoEntry.event);
          _node(builder, 'urgency', infoEntry.urgency);
          _node(builder, 'severity', infoEntry.severity);
          _node(builder, 'certainty', infoEntry.certainty);
          if (infoEntry.headline != null) {
            _node(builder, 'headline', infoEntry.headline!);
          }
          if (infoEntry.description != null) {
            _node(builder, 'description', infoEntry.description!);
          }
          if (infoEntry.instruction != null) {
            _node(builder, 'instruction', infoEntry.instruction!);
          }
        });
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  static CapAlert fromMap(Map<String, dynamic> map) {
    final infoList = <CapInfo>[];
    if (map['info'] is List) {
      for (final entry in map['info']) {
        if (entry is Map<String, dynamic>) {
          infoList.add(CapInfo.fromMap(entry));
        }
      }
    }
    if (infoList.isEmpty) {
      infoList.add(CapInfo.fromMap(map));
    }
    return CapAlert(
      identifier: map['identifier']?.toString() ??
          'SOS-${DateTime.now().millisecondsSinceEpoch}',
      sender: map['sender']?.toString() ?? 'resgatesos@local',
      sent: _parseDate(map['sent']) ?? DateTime.now(),
      status: map['status']?.toString() ?? 'Actual',
      msgType: map['msgType']?.toString() ?? 'Alert',
      scope: map['scope']?.toString() ?? 'Public',
      info: infoList,
    );
  }

  static CapAlert fromXml(String xml) {
    final document = XmlDocument.parse(xml);
    final alert = document.findElements('alert').first;
    final infoElements = alert.findElements('info').toList();
    final infoList = infoElements.isEmpty
        ? [CapInfo.fromXml(alert)]
        : infoElements.map(CapInfo.fromXml).toList();
    return CapAlert(
      identifier: _text(alert, 'identifier') ??
          'SOS-${DateTime.now().millisecondsSinceEpoch}',
      sender: _text(alert, 'sender') ?? 'resgatesos@local',
      sent: _parseDate(_text(alert, 'sent')) ?? DateTime.now(),
      status: _text(alert, 'status') ?? 'Actual',
      msgType: _text(alert, 'msgType') ?? 'Alert',
      scope: _text(alert, 'scope') ?? 'Public',
      info: infoList,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}

void _node(XmlBuilder builder, String name, String value) {
  builder.element(name, nest: value);
}

String? _text(XmlElement element, String name) {
  final node = element.getElement(name);
  if (node == null) return null;
  return node.text.trim().isEmpty ? null : node.text.trim();
}
