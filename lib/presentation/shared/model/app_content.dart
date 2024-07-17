import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/model/custom_setting_model.dart';

part 'app_content.freezed.dart';
part 'app_content.g.dart';

@freezed
class AppContentModel with _$AppContentModel {
  const factory AppContentModel(
          {@Default(CustomSettingModel()) CustomSettingModel data}) =
      _AppContentModel;

  factory AppContentModel.fromJson(Map<String, dynamic> json) =>
      _$AppContentModelFromJson(json);
}
