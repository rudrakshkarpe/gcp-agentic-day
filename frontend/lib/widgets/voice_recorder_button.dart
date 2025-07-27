import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../config/app_theme.dart';

class VoiceRecorderButton extends StatefulWidget {
  final Function(File, String) onRecordingComplete;
  final bool isEnabled;

  const VoiceRecorderButton({
    Key? key,
    required this.onRecordingComplete,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _VoiceRecorderButtonState createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isRecording = false;
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!widget.isEnabled) return;
    
    final audioService = Provider.of<AudioService>(context, listen: false);
    
    if (!audioService.hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ಮೈಕ್ರೋಫೋನ್ ಅನುಮತಿ ಅಗತ್ಯ'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    
    final success = await audioService.startRecording();
    if (success) {
      setState(() {
        _isRecording = true;
      });
      _animationController.repeat(reverse: true);
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    final audioService = Provider.of<AudioService>(context, listen: false);
    final audioFile = await audioService.stopRecording();
    
    setState(() {
      _isRecording = false;
    });
    _animationController.stop();
    _animationController.reset();
    
    if (audioFile != null) {
      // For demo purposes, we'll use a placeholder transcript
      // In a real implementation, you might want to show a processing dialog
      // or get the transcript from the API response
      final transcript = 'ಧ್ವನಿ ಸಂದೇಶ ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗಿದೆ';
      widget.onRecordingComplete(audioFile, transcript);
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    
    final audioService = Provider.of<AudioService>(context, listen: false);
    await audioService.cancelRecording();
    
    setState(() {
      _isRecording = false;
    });
    _animationController.stop();
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, child) {
        return GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopRecording(),
          onLongPressCancel: () => _cancelRecording(),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? AppTheme.errorRed 
                        : widget.isEnabled 
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: _isRecording ? [
                      BoxShadow(
                        color: AppTheme.errorRed.withOpacity(_opacityAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Recording instruction widget
class RecordingInstructionWidget extends StatelessWidget {
  const RecordingInstructionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            color: AppTheme.primaryGreen,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            'ಮಾತನಾಡಲು ಒತ್ತಿ ಹಿಡಿಯಿರಿ',
            style: AppTheme.kannadaCaption.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Recording duration display
class RecordingDurationWidget extends StatelessWidget {
  final Duration duration;
  
  const RecordingDurationWidget({
    Key? key,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _formatDuration(duration),
            style: AppTheme.kannadaBody.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
