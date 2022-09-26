import 'package:audioplayers/audioplayers.dart';

class AudioPlayerUtils {
  static final AudioPlayerUtils _audioPlayerUtils = AudioPlayerUtils();
  static final _player = AudioPlayer();
  static bool _isMusicPlayed = false;

  static AudioPlayerUtils get instance => _audioPlayerUtils;

  AudioPlayer get player => _player;

  bool get getIsMusicPlayed => _isMusicPlayed;

  set setIsMusicPlayed(bool newStatus) => _isMusicPlayed = newStatus;
}