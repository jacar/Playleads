extends SceneTree


const SR := 22050


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://audio"))
	_make_street()
	_make_inside()
	quit()


func _make_street() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2743
	var length := 20.0
	var total := int(length * SR)
	var fade := int(0.6 * SR)
	var left := PackedFloat32Array()
	var right := PackedFloat32Array()
	left.resize(total)
	right.resize(total)
	var lp_l := 0.0
	var lp_r := 0.0
	var rumble := 0.0
	for i in total:
		var t := float(i) / float(SR)
		var white_l := rng.randf_range(-1.0, 1.0)
		var white_r := rng.randf_range(-1.0, 1.0)
		lp_l += (white_l - lp_l) * 0.045
		lp_r += (white_r - lp_r) * 0.045
		var bed := lp_l * 0.55 + lp_r * 0.15
		var bed_r := lp_r * 0.55 + lp_l * 0.15
		rumble += (rng.randf_range(-1.0, 1.0) - rumble) * 0.0025
		var hum := sin(TAU * 48.0 * t) * 0.012 + sin(TAU * 71.0 * t) * 0.006
		var swell := 0.6 + 0.4 * sin(TAU * 0.045 * t + 1.2)
		left[i] = bed * 0.42 * swell + rumble * 0.22 + hum
		right[i] = bed_r * 0.42 * swell + rumble * 0.22 + hum * 0.9
	# passing cars
	for c in 7:
		var start := rng.randf_range(0.2, length - 2.0)
		var dur := rng.randf_range(1.6, 3.2)
		var pan_from := rng.randf_range(-0.9, 0.9)
		var pan_to := -pan_from
		var gain := rng.randf_range(0.08, 0.18)
		var n0 := int(start * SR)
		var n1 := mini(total, n0 + int(dur * SR))
		var clp := 0.0
		for i in range(n0, n1):
			var p := float(i - n0) / float(maxi(1, n1 - n0))
			var env := sin(p * PI)
			var w := rng.randf_range(-1.0, 1.0)
			clp += (w - clp) * 0.18
			var pan := lerpf(pan_from, pan_to, p)
			var gl := gain * env * (1.0 - maxf(0.0, pan))
			var gr := gain * env * (1.0 - maxf(0.0, -pan))
			left[i] += clp * gl
			right[i] += clp * gr
	# distant horns
	for h in 6:
		var start := rng.randf_range(0.0, length - 1.0)
		var base := rng.randf_range(330.0, 470.0)
		var pan := rng.randf_range(-0.8, 0.8)
		var n0 := int(start * SR)
		for beep in 2:
			var b0 := n0 + int(float(beep) * 0.32 * SR)
			var dur := 0.16
			var n1 := mini(total, b0 + int(dur * SR))
			for i in range(b0, n1):
				var p := float(i - b0) / float(maxi(1, n1 - b0))
				var env := sin(p * PI) * 0.03
				var s := sin(TAU * base * float(i) / float(SR)) + 0.4 * sin(TAU * base * 1.5 * float(i) / float(SR))
				left[i] += s * env * (1.0 - maxf(0.0, pan))
				right[i] += s * env * (1.0 - maxf(0.0, -pan))
	# voices murmur
	for v in 14:
		var start := rng.randf_range(0.0, length - 1.2)
		var dur := rng.randf_range(0.35, 0.9)
		var pan := rng.randf_range(-0.7, 0.7)
		var n0 := int(start * SR)
		var n1 := mini(total, n0 + int(dur * SR))
		var vp := 0.0
		for i in range(n0, n1):
			var p := float(i - n0) / float(maxi(1, n1 - n0))
			var env := sin(p * PI) * 0.012
			var w := rng.randf_range(-1.0, 1.0)
			vp += (w - vp) * 0.09
			var am := 0.55 + 0.45 * sin(TAU * rng.randf_range(3.0, 4.2) * float(i) / float(SR))
			left[i] += vp * env * am * (1.0 - maxf(0.0, pan))
			right[i] += vp * env * am * (1.0 - maxf(0.0, -pan))
	# birds
	for b in 5:
		var start := rng.randf_range(0.0, length - 0.5)
		var n0 := int(start * SR)
		for chirp in 3:
			var c0 := n0 + int(float(chirp) * 0.11 * SR)
			var n1 := mini(total, c0 + int(0.06 * SR))
			for i in range(c0, n1):
				var p := float(i - c0) / float(maxi(1, n1 - c0))
				var f := lerpf(2500.0, 3300.0, p)
				var env := sin(p * PI) * 0.006
				left[i] += sin(TAU * f * float(i) / float(SR)) * env
				right[i] += sin(TAU * f * float(i) / float(SR)) * env * 0.8
	# loop the tail into the head
	for i in fade:
		var t := float(i) / float(fade)
		var j := total - fade + i
		left[j] = left[j] * (1.0 - t) + left[i] * t
		right[j] = right[j] * (1.0 - t) + right[i] * t
	_write("res://audio/ambience_calle.res", left, right)


func _make_inside() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 891
	var total := int(9.0 * SR)
	var fade := int(0.4 * SR)
	var left := PackedFloat32Array()
	var right := PackedFloat32Array()
	left.resize(total)
	right.resize(total)
	var lp_l := 0.0
	var lp_r := 0.0
	for i in total:
		var wl := rng.randf_range(-1.0, 1.0)
		var wr := rng.randf_range(-1.0, 1.0)
		lp_l += (wl - lp_l) * 0.02
		lp_r += (wr - lp_r) * 0.02
		var hum := sin(TAU * 60.0 * float(i) / float(SR)) * 0.003
		left[i] = lp_l * 0.16 + hum
		right[i] = lp_r * 0.16 + hum
	for c in 26:
		var start := rng.randf_range(0.0, 8.6)
		var dur := rng.randf_range(0.3, 0.9)
		var pan := rng.randf_range(-0.6, 0.6)
		var gain := rng.randf_range(0.012, 0.03)
		var n0 := int(start * SR)
		var n1 := mini(total, n0 + int(dur * SR))
		var vp := 0.0
		for i in range(n0, n1):
			var p := float(i - n0) / float(maxi(1, n1 - n0))
			var env := sin(p * PI) * gain
			var w := rng.randf_range(-1.0, 1.0)
			vp += (w - vp) * 0.07
			var am := 0.5 + 0.5 * sin(TAU * rng.randf_range(2.4, 4.0) * float(i) / float(SR))
			left[i] += vp * env * am * (1.0 - maxf(0.0, pan))
			right[i] += vp * env * am * (1.0 - maxf(0.0, -pan))
	for k in 12:
		var start := rng.randf_range(0.2, 8.5)
		var n0 := int(start * SR)
		var n1 := mini(total, n0 + int(0.35 * SR))
		var pan := rng.randf_range(-0.5, 0.5)
		for i in range(n0, n1):
			var p := float(i - n0) / float(maxi(1, n1 - n0))
			var env := exp(-p * 7.0) * 0.03
			var s := sin(TAU * 2100.0 * float(i) / float(SR)) + 0.6 * sin(TAU * 3150.0 * float(i) / float(SR))
			left[i] += s * env * (1.0 - maxf(0.0, pan))
			right[i] += s * env * (1.0 - maxf(0.0, -pan))
	for i in fade:
		var t := float(i) / float(fade)
		var j := total - fade + i
		left[j] = left[j] * (1.0 - t) + left[i] * t
		right[j] = right[j] * (1.0 - t) + right[i] * t
	_write("res://audio/ambience_interior.res", left, right)


func _write(path: String, left: PackedFloat32Array, right: PackedFloat32Array) -> void:
	var frames := left.size()
	var bytes := PackedByteArray()
	bytes.resize(frames * 4)
	for i in frames:
		var l := int(clampf(left[i] * 1.6, -1.0, 1.0) * 32767.0)
		var r := int(clampf(right[i] * 1.6, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 4, l)
		bytes.encode_s16(i * 4 + 2, r)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SR
	stream.stereo = true
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frames
	var err := ResourceSaver.save(stream, path)
	print(path, " -> ", err, " bytes=", bytes.size())
