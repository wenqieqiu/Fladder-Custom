class PlayerState {
  final bool playing;
  final bool completed;
  final Duration position;
  final Duration duration;
  final double volume;
  final double rate;
  final bool buffering;
  final Duration buffer;

  const PlayerState({
    this.playing = false,
    this.completed = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100,
    this.rate = 1.0,
    this.buffering = true,
    this.buffer = Duration.zero,
  });

  PlayerState copyWith({
    bool? playing,
    bool? completed,
    bool? buffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
    Duration? buffer,
  }) {
    return PlayerState(
      playing: playing ?? this.playing,
      completed: completed ?? this.completed,
      buffering: buffering ?? this.buffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
      buffer: buffer ?? this.buffer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerState &&
          playing == other.playing &&
          completed == other.completed &&
          position == other.position &&
          duration == other.duration &&
          volume == other.volume &&
          rate == other.rate &&
          buffering == other.buffering &&
          buffer == other.buffer;

  @override
  int get hashCode =>
      playing.hashCode ^
      completed.hashCode ^
      position.hashCode ^
      duration.hashCode ^
      volume.hashCode ^
      rate.hashCode ^
      buffering.hashCode ^
      buffer.hashCode;
}
class PlayerStream {
  final Stream<bool> playing;
  final Stream<bool> completed;
  final Stream<Duration> position;
  final Stream<Duration> duration;
  final Stream<double> volume;
  final Stream<double> rate;
  final Stream<bool> buffering;
  final Stream<Duration> buffer;

  const PlayerStream(
    this.playing,
    this.completed,
    this.position,
    this.duration,
    this.volume,
    this.rate,
    this.buffering,
    this.buffer,
  );

}
