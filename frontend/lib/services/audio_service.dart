import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum AudioRecordingState {
  idle,
  recording,
  processing,
}

enum AudioPlaybackState {
  idle,
  playing,
  paused,
}

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  AudioRecordingState _recordingState = AudioRecordingState.idle;
  AudioPlaybackState _playbackState = AudioPlaybackState.idle;
  
  String? _currentRecordingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  
  bool _hasPermission = false;
  String? _errorMessage;

  // Getters
  AudioRecordingState get recordingState => _recordingState;
  AudioPlaybackState get playbackState => _playbackState;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackDuration => _playbackDuration;
  Duration get playbackPosition => _playbackPosition;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;
  bool get isRecording => _recordingState == AudioRecordingState.recording;
  bool get isPlaying => _playbackState == AudioPlaybackState.playing;

  AudioService() {
    _initializePlayer();
    _checkCurrentPermissionStatus();
  }

  Future<void> _checkCurrentPermissionStatus() async {
    try {
      final status = await Permission.microphone.status;
      _hasPermission = status == PermissionStatus.granted;
      notifyListeners();
    } catch (e) {
      print('Failed to check microphone permission status: $e');
    }
  }

  void _initializePlayer() {
    _player.onDurationChanged.listen((duration) {
      _playbackDuration = duration;
      notifyListeners();
    });

    _player.onPositionChanged.listen((position) {
      _playbackPosition = position;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      _playbackState = AudioPlaybackState.idle;
      _playbackPosition = Duration.zero;
      notifyListeners();
    });
  }

  Future<bool> requestPermission() async {
    try {
      // Clear any previous error
      _errorMessage = null;
      notifyListeners();
      
      // Check current permission status first
      final currentStatus = await Permission.microphone.status;
      print('Current microphone permission status: $currentStatus');
      
      if (currentStatus == PermissionStatus.granted) {
        _hasPermission = true;
        notifyListeners();
        return true;
      }
      
      // If permanently denied, don't request again - direct to settings
      if (currentStatus == PermissionStatus.permanentlyDenied) {
        _hasPermission = false;
        _errorMessage = 'Please enable microphone in Settings > Privacy & Security > Microphone > Kisan App';
        notifyListeners();
        return false;
      }
      
      // Request permission with more specific handling
      print('Requesting microphone permission...');
      final status = await Permission.microphone.request();
      print('Permission request result: $status');
      
      _hasPermission = status == PermissionStatus.granted;
      
      if (!_hasPermission) {
        switch (status) {
          case PermissionStatus.denied:
            _errorMessage = 'Microphone access denied. Tap to try again or enable in Settings.';
            break;
          case PermissionStatus.permanentlyDenied:
            _errorMessage = 'Please enable microphone in Settings > Privacy & Security > Microphone > Kisan App';
            break;
          case PermissionStatus.restricted:
            _errorMessage = 'Microphone access is restricted. Check device restrictions.';
            break;
          case PermissionStatus.limited:
            _errorMessage = 'Limited microphone access granted. Some features may not work.';
            break;
          default:
            _errorMessage = 'Microphone permission required. Please enable in Settings.';
        }
      } else {
        _errorMessage = null;
      }
      
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      print('Permission request error: $e');
      _errorMessage = 'Permission error: $e';
      notifyListeners();
      return false;
    }
  }

  // Method to open app settings for permanently denied permissions
  Future<void> openDeviceSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Failed to open app settings: $e');
    }
  }

  Future<bool> startRecording() async {
    try {
      if (!_hasPermission) {
        final granted = await requestPermission();
        if (!granted) return false;
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      
      _recordingState = AudioRecordingState.recording;
      _recordingDuration = Duration.zero;
      _errorMessage = null;
      notifyListeners();

      // Start duration tracking
      _startRecordingTimer();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start recording: $e';
      _recordingState = AudioRecordingState.idle;
      notifyListeners();
      return false;
    }
  }

  void _startRecordingTimer() {
    Stream.periodic(Duration(milliseconds: 100)).listen((event) {
      if (_recordingState == AudioRecordingState.recording) {
        _recordingDuration = _recordingDuration + Duration(milliseconds: 100);
        notifyListeners();
      }
    });
  }

  Future<File?> stopRecording() async {
    try {
      if (_recordingState != AudioRecordingState.recording) return null;

      _recordingState = AudioRecordingState.processing;
      notifyListeners();

      final path = await _recorder.stop();
      
      _recordingState = AudioRecordingState.idle;
      notifyListeners();

      if (path != null && await File(path).exists()) {
        return File(path);
      }
      
      return null;
    } catch (e) {
      _errorMessage = 'Failed to stop recording: $e';
      _recordingState = AudioRecordingState.idle;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_recordingState == AudioRecordingState.recording) {
        await _recorder.stop();
      }
      
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      _recordingState = AudioRecordingState.idle;
      _recordingDuration = Duration.zero;
      _currentRecordingPath = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to cancel recording: $e';
      notifyListeners();
    }
  }

  Future<bool> playAudioFromBase64(String base64Audio) async {
    try {
      // Decode base64 to bytes
      final bytes = base64Decode(base64Audio);
      
      // Create temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${directory.path}/response_audio_$timestamp.mp3');
      
      // Write bytes to file
      await tempFile.writeAsBytes(bytes);
      
      // Verify file was created and has content
      if (!await tempFile.exists() || await tempFile.length() == 0) {
        _errorMessage = 'Failed to create audio file';
        notifyListeners();
        return false;
      }
      
      // Play the file
      await playAudioFile(tempFile);
      
      return true;
    } catch (e) {
      print('Audio playback error: $e');
      _errorMessage = 'Failed to play audio response: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> playAudioFile(File audioFile) async {
    try {
      if (!await audioFile.exists()) {
        _errorMessage = 'Audio file not found';
        notifyListeners();
        return false;
      }

      // Check file size
      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        _errorMessage = 'Audio file is empty';
        notifyListeners();
        return false;
      }

      print('Playing audio file: ${audioFile.path} (${fileSize} bytes)');
      
      // Stop any current playback
      await _player.stop();
      
      // Play the file
      await _player.play(DeviceFileSource(audioFile.path));
      _playbackState = AudioPlaybackState.playing;
      _errorMessage = null;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Audio playback error: $e');
      _errorMessage = 'Failed to play audio: $e';
      _playbackState = AudioPlaybackState.idle;
      notifyListeners();
      return false;
    }
  }

  Future<void> pausePlayback() async {
    try {
      await _player.pause();
      _playbackState = AudioPlaybackState.paused;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to pause playback: $e';
      notifyListeners();
    }
  }

  Future<void> resumePlayback() async {
    try {
      await _player.resume();
      _playbackState = AudioPlaybackState.playing;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to resume playback: $e';
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _playbackState = AudioPlaybackState.idle;
      _playbackPosition = Duration.zero;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop playback: $e';
      notifyListeners();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
