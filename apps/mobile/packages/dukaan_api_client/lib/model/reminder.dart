//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Reminder {
  /// Returns a new [Reminder] instance.
  Reminder({
    required this.id,
    required this.business,
    required this.location,
    required this.party,
    required this.partyName,
    required this.channel,
    required this.message,
    required this.amountMinor,
    required this.status,
    required this.providerMessageId,
    required this.sentAt,
    required this.createdAt,
  });

  String id;

  String business;

  String? location;

  String party;

  String partyName;

  ChannelEnum channel;

  String message;

  int amountMinor;

  ReminderStatusEnum status;

  String providerMessageId;

  DateTime? sentAt;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Reminder &&
    other.id == id &&
    other.business == business &&
    other.location == location &&
    other.party == party &&
    other.partyName == partyName &&
    other.channel == channel &&
    other.message == message &&
    other.amountMinor == amountMinor &&
    other.status == status &&
    other.providerMessageId == providerMessageId &&
    other.sentAt == sentAt &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (business.hashCode) +
    (location == null ? 0 : location!.hashCode) +
    (party.hashCode) +
    (partyName.hashCode) +
    (channel.hashCode) +
    (message.hashCode) +
    (amountMinor.hashCode) +
    (status.hashCode) +
    (providerMessageId.hashCode) +
    (sentAt == null ? 0 : sentAt!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Reminder[id=$id, business=$business, location=$location, party=$party, partyName=$partyName, channel=$channel, message=$message, amountMinor=$amountMinor, status=$status, providerMessageId=$providerMessageId, sentAt=$sentAt, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'business'] = this.business;
    if (this.location != null) {
      json[r'location'] = this.location;
    } else {
      json[r'location'] = null;
    }
      json[r'party'] = this.party;
      json[r'party_name'] = this.partyName;
      json[r'channel'] = this.channel;
      json[r'message'] = this.message;
      json[r'amount_minor'] = this.amountMinor;
      json[r'status'] = this.status;
      json[r'provider_message_id'] = this.providerMessageId;
    if (this.sentAt != null) {
      json[r'sent_at'] = this.sentAt!.toUtc().toIso8601String();
    } else {
      json[r'sent_at'] = null;
    }
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Reminder] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Reminder? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Reminder[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Reminder[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Reminder(
        id: mapValueOfType<String>(json, r'id')!,
        business: mapValueOfType<String>(json, r'business')!,
        location: mapValueOfType<String>(json, r'location'),
        party: mapValueOfType<String>(json, r'party')!,
        partyName: mapValueOfType<String>(json, r'party_name')!,
        channel: ChannelEnum.fromJson(json[r'channel'])!,
        message: mapValueOfType<String>(json, r'message')!,
        amountMinor: mapValueOfType<int>(json, r'amount_minor')!,
        status: ReminderStatusEnum.fromJson(json[r'status'])!,
        providerMessageId: mapValueOfType<String>(json, r'provider_message_id')!,
        sentAt: mapDateTime(json, r'sent_at', r''),
        createdAt: mapDateTime(json, r'created_at', r'')!,
      );
    }
    return null;
  }

  static List<Reminder> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Reminder>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Reminder.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Reminder> mapFromJson(dynamic json) {
    final map = <String, Reminder>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Reminder.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Reminder-objects as value to a dart map
  static Map<String, List<Reminder>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Reminder>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Reminder.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'business',
    'location',
    'party',
    'party_name',
    'channel',
    'message',
    'amount_minor',
    'status',
    'provider_message_id',
    'sent_at',
    'created_at',
  };
}

