import 'package:freezed_annotation/freezed_annotation.dart';
part 'custom_setting_model.freezed.dart';

part 'custom_setting_model.g.dart';

@freezed
class CustomSettingModel with _$CustomSettingModel {
  const factory CustomSettingModel(
      {@Default('') String type,
      @Default('') String media,
      @JsonKey(name: 'customization_settings')
      @Default(<Config>[])
      List<Config> configList}) = _CustomSettingModel;

  factory CustomSettingModel.fromJson(Map<String, dynamic> json) =>
      _$CustomSettingModelFromJson(json);
}

@freezed
class ConfigCore with _$ConfigCore {
  const factory ConfigCore(
      {@Default(0.0) double top,
      @Default(0.0) double left,
      @Default(Dimension()) Dimension dimensions,
      @Default('FFFFFF') String fontColor}) = _ConfigCore;

  factory ConfigCore.fromJson(Map<String, dynamic> json) =>
      _$ConfigCoreFromJson(json);
}

@freezed
class Config with _$Config {
  const factory Config(
      {@Default('') String value,
      @Default('') String title,
      @JsonKey(name: 'configs')
      @Default(ConfigCore())
      ConfigCore cofigSettings}) = _Config;

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

@freezed
class Dimension with _$Dimension {
  const factory Dimension({
    @Default(300) double width,
    @Default(50) double height,
  }) = _Dimension;

  factory Dimension.fromJson(Map<String, dynamic> json) =>
      _$DimensionFromJson(json);
}
