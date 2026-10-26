class_name Synth
extends RefCounted
## Procedural audio. All sounds are generated at runtime so the game ships without any audio files.

enum Wave { TRIANGLE, SOFT_SQUARE, BELL }

const MIX_RATE := 22050
const MUSIC_BPM := 96.0
## Chord tones (midi notes) of the music loop: C - Am - F - G.
const MUSIC_CHORDS: Array[PackedInt32Array] = [
	[48, 52, 55, 60],
	[45, 48, 52, 57],
	[41, 45, 48, 53],
	[43, 47, 50, 55],
]
## Melody with one row per bar and one note per beat, -1 is a rest.
const MUSIC_MELODY: Array[PackedInt32Array] = [
	[76, -1, 74, 72],
	[72, -1, 69, 67],
	[69, -1, 72, -1],
	[71, -1, 67, -1],
	[76, -1, 79, 76],
	[72, -1, 74, 76],
	[77, -1, 76, 72],
	[74, -1, -1, -1],
]

static var _snap: AudioStreamWAV
static var _blop: AudioStreamWAV


## Short click played when a house is released from the crane.
static func snap() -> AudioStreamWAV:
	if _snap != null:
		return _snap
	var samples := PackedFloat32Array()
	samples.resize(int(0.07 * MIX_RATE))
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in samples.size():
		var t := float(i) / MIX_RATE
		var click := sin(TAU * 1700.0 * t) * exp(-t * 90.0)
		var noise := rng.randf_range(-1.0, 1.0) * exp(-t * 120.0)
		samples[i] = 0.5 * click + 0.35 * noise
	_snap = _to_stream(samples)
	return _snap


## Soft thud played when a house lands.
static func blop() -> AudioStreamWAV:
	if _blop != null:
		return _blop
	var samples := PackedFloat32Array()
	samples.resize(int(0.18 * MIX_RATE))
	var phase := 0.0
	for i in samples.size():
		var t := float(i) / MIX_RATE
		phase += TAU * lerpf(260.0, 90.0, minf(t / 0.12, 1.0)) / MIX_RATE
		var attack := minf(t / 0.004, 1.0)
		samples[i] = 0.8 * sin(phase) * attack * exp(-t * 22.0)
	_blop = _to_stream(samples)
	return _blop


## Calm looping chiptune with bass, arpeggio and a bell melody. Takes a moment, call it from a thread.
static func music() -> AudioStreamWAV:
	var beat := 60.0 / MUSIC_BPM
	var buffer := PackedFloat32Array()
	buffer.resize(int(MUSIC_MELODY.size() * 4 * beat * MIX_RATE))

	for bar in MUSIC_MELODY.size():
		var chord := MUSIC_CHORDS[bar % MUSIC_CHORDS.size()]
		var bar_start := bar * 4 * beat
		for beat_index in 4:
			var beat_start := bar_start + beat_index * beat
			# bass alternates between root and fifth
			var bass_note := chord[0] - 12 if beat_index % 2 == 0 else chord[2] - 12
			_add_note(buffer, beat_start, beat * 0.9, bass_note, 0.22, Wave.TRIANGLE)
			# arpeggio in eighth notes
			for eighth in 2:
				var arp_note := chord[(beat_index * 2 + eighth) % chord.size()] + 12
				_add_note(buffer, beat_start + eighth * beat * 0.5, beat * 0.45, arp_note, 0.07, Wave.SOFT_SQUARE)
			var melody_note := MUSIC_MELODY[bar][beat_index]
			if melody_note > 0:
				_add_note(buffer, beat_start, beat * 1.6, melody_note, 0.1, Wave.BELL)

	var stream := _to_stream(buffer)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = buffer.size()
	return stream


## Renders one note into the buffer, wrapping around at the end so the loop is seamless.
static func _add_note(
	buffer: PackedFloat32Array, start: float, duration: float, midi: int, volume: float, wave: Wave
) -> void:
	var freq := 440.0 * pow(2.0, (midi - 69) / 12.0)
	var first := int(start * MIX_RATE)
	var decay := 3.0 / duration
	for i in int(duration * MIX_RATE):
		var t := float(i) / MIX_RATE
		var p := fmod(t * freq, 1.0)
		var sample: float
		match wave:
			Wave.TRIANGLE:
				sample = 4.0 * absf(p - 0.5) - 1.0
			Wave.SOFT_SQUARE:
				sample = (0.6 if p < 0.5 else -0.6) + sin(TAU * p) * 0.4
			Wave.BELL:
				sample = sin(TAU * p) + 0.3 * sin(TAU * p * 3.0) * exp(-t * 8.0)
		var envelope := minf(t / 0.01, 1.0) * exp(-t * decay) * minf((duration - t) / 0.02, 1.0)
		buffer[(first + i) % buffer.size()] += sample * envelope * volume


static func _to_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
