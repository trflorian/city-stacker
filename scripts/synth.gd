class_name Synth
extends RefCounted
## Procedural audio. All sounds are generated at runtime so the game ships
## without any audio files.

const MIX_RATE := 22050


## Short click played when the house is released from the crane.
static func snap() -> AudioStreamWAV:
	var length := int(0.07 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(length)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in length:
		var t := float(i) / MIX_RATE
		var click := sin(TAU * 1700.0 * t) * exp(-t * 90.0)
		var noise := rng.randf_range(-1.0, 1.0) * exp(-t * 120.0)
		samples[i] = 0.5 * click + 0.35 * noise
	return _to_stream(samples)


## Soft thud played when a house lands.
static func blop() -> AudioStreamWAV:
	var length := int(0.18 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(length)
	var phase := 0.0
	for i in length:
		var t := float(i) / MIX_RATE
		var freq := lerpf(260.0, 90.0, minf(t / 0.12, 1.0))
		phase += TAU * freq / MIX_RATE
		var attack := minf(t / 0.004, 1.0)
		samples[i] = 0.8 * sin(phase) * attack * exp(-t * 22.0)
	return _to_stream(samples)


## Calm looping chiptune: bass, arpeggio and a bell melody over C - Am - F - G.
static func music() -> AudioStreamWAV:
	const BPM := 96.0
	const BEAT := 60.0 / BPM
	var chords := [
		[48, 52, 55, 60], # C
		[45, 48, 52, 57], # Am
		[41, 45, 48, 53], # F
		[43, 47, 50, 55], # G
	]
	# one note per beat, -1 is a rest
	var melody := [
		76, -1, 74, 72, 72, -1, 69, 67, 69, -1, 72, -1, 71, -1, 67, -1,
		76, -1, 79, 76, 72, -1, 74, 76, 77, -1, 76, 72, 74, -1, -1, -1,
	]
	var bars := 8
	var length := int(bars * 4 * BEAT * MIX_RATE)
	var buffer := PackedFloat32Array()
	buffer.resize(length)

	for bar in bars:
		var chord: Array = chords[bar % 4]
		var bar_start := bar * 4 * BEAT
		for beat in 4:
			# bass on every beat, root and fifth alternating
			var bass_note: int = chord[0] - 12 if beat % 2 == 0 else chord[2] - 12
			_add_note(buffer, bar_start + beat * BEAT, BEAT * 0.9, bass_note, 0.22, 0)
			# arpeggio in eighth notes
			for eighth in 2:
				var idx := (beat * 2 + eighth) % 4
				_add_note(buffer, bar_start + (beat + eighth * 0.5) * BEAT, BEAT * 0.45,
						chord[idx] + 12, 0.07, 1)
			var mel_note: int = melody[(bar * 4 + beat) % melody.size()]
			if mel_note > 0:
				_add_note(buffer, bar_start + beat * BEAT, BEAT * 1.6, mel_note, 0.1, 2)

	var stream := _to_stream(buffer)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = length
	return stream


## Renders one note into the buffer, wrapping around so the loop is seamless.
## wave: 0 = triangle, 1 = soft square, 2 = bell (sine with overtone)
static func _add_note(buffer: PackedFloat32Array, start: float, duration: float,
		midi: int, volume: float, wave: int) -> void:
	var freq := 440.0 * pow(2.0, (midi - 69) / 12.0)
	var first := int(start * MIX_RATE)
	var count := int(duration * MIX_RATE)
	var size := buffer.size()
	var decay := 3.0 / duration
	for i in count:
		var t := float(i) / MIX_RATE
		var p := fmod(t * freq, 1.0)
		var s: float
		match wave:
			0:
				s = 4.0 * absf(p - 0.5) - 1.0
			1:
				s = (1.0 if p < 0.5 else -1.0) * 0.6 + sin(TAU * p) * 0.4
			_:
				s = sin(TAU * p) + 0.3 * sin(TAU * p * 3.0) * exp(-t * 8.0)
		var env := minf(t / 0.01, 1.0) * exp(-t * decay) * minf((duration - t) / 0.02, 1.0)
		buffer[(first + i) % size] += s * env * volume


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
