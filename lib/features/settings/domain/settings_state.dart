import 'package:equatable/equatable.dart';

/// State đại diện cấu hình app — persist qua SharedPreferences.
///
/// Hiện tại scope nhỏ chỉ gồm 2 toggle phản hồi tap bàn phím
/// (sound + vibration). Mở rộng sau khi cần.
class SettingsState extends Equatable {
  const SettingsState({this.soundEnabled = true, this.vibrationEnabled = true});

  final bool soundEnabled;
  final bool vibrationEnabled;

  SettingsState copyWith({bool? soundEnabled, bool? vibrationEnabled}) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [soundEnabled, vibrationEnabled];
}
