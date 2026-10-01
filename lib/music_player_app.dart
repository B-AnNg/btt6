import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1a001a),
      ),
      home: const MusicPlayerHome(),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Danh sách link nhạc MP3 online (không cần lưu file vào máy)
  final List<String> _onlineSongs = [
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  ];

  // Danh sách thông tin bài hát (Tiêu đề & Nghệ sĩ)
  final List<Map<String, String>> _songDetails = [
    {'title': 'Song Title 1', 'artist': 'Artist Name 1'},
    {'title': 'Song Title 2', 'artist': 'Artist Name 2'},
    {'title': 'Song Title 3', 'artist': 'Artist Name 3'},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Lắng nghe trạng thái phát nhạc
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Lắng nghe tổng thời lượng bài hát
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    // Lắng nghe tiến trình thời gian phát hiện tại
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    // Tự động chuyển bài khi phát xong
    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Phát nhạc từ URL online
  Future<void> _playSong() async {
    final url = _onlineSongs[_currentSongIndex];
    await _audioPlayer.play(UrlSource(url));
  }

  // Tạm dừng
  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
  }

  // Dừng hẳn
  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  // Bài tiếp theo
  void _nextSong() {
    setState(() {
      if (_currentSongIndex < _onlineSongs.length - 1) {
        _currentSongIndex++;
      } else {
        _currentSongIndex = 0; // Vòng lại bài đầu
      }
    });
    _playSong();
  }

  // Bài trước đó
  void _previousSong() {
    setState(() {
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        _currentSongIndex = _onlineSongs.length - 1; // Quay về bài cuối
      }
    });
    _playSong();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _songDetails[_currentSongIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALBUM / PLAYLIST'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF330033), Color(0xFF120012)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // --- PHẦN 1: ĐĨA NHẠC & THÔNG TIN ---
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.music_note : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    currentSong['title']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentSong['artist']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // --- PHẦN 2: THANH PROGRESS & ĐIỀU KHIỂN ---
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      activeColor: Colors.pinkAccent,
                      inactiveColor: Colors.white24,
                      min: 0,
                      max: _duration.inSeconds.toDouble() > 0
                          ? _duration.inSeconds.toDouble()
                          : 1.0,
                      value: _position.inSeconds.toDouble().clamp(
                            0.0,
                            _duration.inSeconds.toDouble() > 0
                                ? _duration.inSeconds.toDouble()
                                : 1.0,
                          ),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          onPressed: _previousSong,
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            size: 56,
                            color: Colors.pinkAccent,
                          ),
                          onPressed: () {
                            if (_isPlaying) {
                              _pauseSong();
                            } else {
                              _playSong();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, size: 36),
                          onPressed: _stopSong,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          onPressed: _nextSong,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- PHẦN 3: DANH SÁCH BÀI HÁT ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: _songDetails.length,
                        itemBuilder: (context, index) {
                          final isSelected = _currentSongIndex == index;
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            title: Text(
                              _songDetails[index]['title']!,
                              style: TextStyle(
                                color: isSelected ? Colors.pinkAccent : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              _songDetails[index]['artist']!,
                              style: const TextStyle(fontSize: 12, color: Colors.white54),
                            ),
                            trailing: const Text('3:00', style: TextStyle(color: Colors.white54)),
                            onTap: () {
                              setState(() {
                                _currentSongIndex = index;
                              });
                              _playSong();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}