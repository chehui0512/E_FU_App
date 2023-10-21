// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
      (json['ax'] as num).toDouble(),
      (json['ay'] as num).toDouble(),
      (json['az'] as num).toDouble(),
      (json['gx'] as num).toDouble(),
      (json['gy'] as num).toDouble(),
      (json['gz'] as num).toDouble(),
      (json['pitch'] as num).toDouble(),
      (json['times'] as num).toDouble(),
      (json['sets_no'] as num).toDouble(),
      (json['item_id'] as num).toDouble(),
      json['i_id'] as int,
    )..timestream = DateTime.parse(json['timestream'] as String);

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'ax': instance.ax,
      'ay': instance.ay,
      'az': instance.az,
      'gx': instance.gx,
      'gy': instance.gy,
      'gz': instance.gz,
      'pitch': instance.pitch,
      'times': instance.times,
      'sets_no': instance.sets_no,
      'item_id': instance.item_id,
      'i_id': instance.i_id,
      'timestream': instance.timestream.toIso8601String(),
    };

RecordSender _$RecordSenderFromJson(Map<String, dynamic> json) => RecordSender(
      record: (json['record'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      detail: (json['detail'] as List<dynamic>)
          .map((e) => RecordSenderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecordSenderToJson(RecordSender instance) =>
    <String, dynamic>{
      'record': instance.record,
      'detail': instance.detail.map((e) => e.toJson()).toList(),
    };

RecordSenderItem _$RecordSenderItemFromJson(Map<String, dynamic> json) =>
    RecordSenderItem(
      done: (json['done'] as List<dynamic>)
          .map((e) => DoneItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      score: (json['score'] as num).toDouble(),
      user_id: json['user_id'] as String,
    );

Map<String, dynamic> _$RecordSenderItemToJson(RecordSenderItem instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'done': instance.done.map((e) => e.toJson()).toList(),
      'score': instance.score,
    };

ArrangeDate _$ArrangeDateFromJson(Map<String, dynamic> json) => ArrangeDate(
      json['arrangeId'] as String,
      (json['raw'] as List<dynamic>)
          .map((e) => Record.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['done'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
    );

Map<String, dynamic> _$ArrangeDateToJson(ArrangeDate instance) =>
    <String, dynamic>{
      'arrangeId': instance.arrangeId,
      'done': instance.done.map((k, e) => MapEntry(k.toString(), e)),
      'raw': instance.raw.map((e) => e.toJson()).toList(),
    };
