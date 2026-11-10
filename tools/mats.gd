class_name CityMats
extends RefCounted


static var _cache: Dictionary = {}
static var _noise_tex: Dictionary = {}
static var _noise_nrm: Dictionary = {}


static func m(key: String) -> StandardMaterial3D:
	if not _cache.has(key):
		_cache[key] = _make(key)
	return _cache[key]


static func _make(key: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.9
	match key:
		"asphalt":
			mat.albedo_color = Color(0.20, 0.20, 0.21)
			mat.albedo_texture = _grain("asphalt", 0.55, 0.16, 3, 0.9)
			mat.normal_enabled = true
			mat.normal_texture = _normal("asphalt", 0.35, 3)
			mat.normal_scale = 0.7
			mat.roughness = 0.95
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(0.35, 0.35, 0.35)
		"concrete":
			mat.albedo_color = Color(0.50, 0.46, 0.40)
			mat.albedo_texture = _grain("concrete", 0.32, 0.09, 4, 0.94)
			mat.normal_enabled = true
			mat.normal_texture = _normal("concrete", 0.22, 4)
			mat.normal_scale = 0.35
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(0.4, 0.4, 0.4)
		"curb":
			mat.albedo_color = Color(0.58, 0.55, 0.49)
			mat.albedo_texture = _grain("concrete", 0.32, 0.09, 4, 0.94)
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
		"paint":
			mat.albedo_color = Color(0.78, 0.73, 0.60)
			mat.roughness = 0.8
		"road_line":
			mat.albedo_color = Color(0.82, 0.76, 0.58)
			mat.roughness = 0.85
		"stucco_terra":
			_stucco(mat, Color(0.58, 0.28, 0.18))
		"stucco_ochre":
			_stucco(mat, Color(0.68, 0.47, 0.18))
		"stucco_green":
			_stucco(mat, Color(0.29, 0.36, 0.26))
		"stucco_blue":
			_stucco(mat, Color(0.26, 0.35, 0.42))
		"stucco_cream":
			_stucco(mat, Color(0.74, 0.65, 0.50))
		"stucco_rose":
			_stucco(mat, Color(0.54, 0.33, 0.30))
		"stucco_sand":
			_stucco(mat, Color(0.60, 0.52, 0.39))
		"trim_dark":
			mat.albedo_color = Color(0.17, 0.13, 0.10)
			mat.roughness = 0.75
		"trim_cream":
			mat.albedo_color = Color(0.80, 0.73, 0.60)
			mat.roughness = 0.8
		"wood":
			mat.albedo_color = Color(0.31, 0.20, 0.12)
			mat.roughness = 0.85
			mat.albedo_texture = _grain("wood", 0.22, 0.13, 4, 0.9)
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(2.0, 2.0, 2.0)
		"wood_light":
			mat.albedo_color = Color(0.52, 0.36, 0.21)
			mat.roughness = 0.8
		"counter_wood":
			mat.albedo_color = Color(0.42, 0.27, 0.15)
			mat.roughness = 0.55
		"metal":
			mat.albedo_color = Color(0.38, 0.39, 0.40)
			mat.metallic = 0.75
			mat.roughness = 0.4
		"metal_dark":
			mat.albedo_color = Color(0.13, 0.13, 0.14)
			mat.metallic = 0.6
			mat.roughness = 0.5
		"brass":
			mat.albedo_color = Color(0.72, 0.52, 0.22)
			mat.metallic = 0.85
			mat.roughness = 0.32
		"glass":
			mat.albedo_color = Color(0.20, 0.27, 0.30)
			mat.metallic = 0.55
			mat.roughness = 0.08
		"glass_shop":
			mat.albedo_color = Color(0.55, 0.63, 0.64, 0.22)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.metallic = 0.4
			mat.roughness = 0.06
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		"glass_warm":
			mat.albedo_color = Color(0.95, 0.66, 0.34)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.68, 0.34)
			mat.emission_energy_multiplier = 1.5
			mat.roughness = 0.2
		"lamp_glow":
			mat.albedo_color = Color(1.0, 0.86, 0.60)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.72, 0.38)
			mat.emission_energy_multiplier = 3.0
		"awning_cream":
			mat.albedo_color = Color(0.85, 0.78, 0.62)
			mat.roughness = 0.85
		"awning_terra":
			mat.albedo_color = Color(0.66, 0.29, 0.17)
			mat.roughness = 0.85
		"awning_green":
			mat.albedo_color = Color(0.22, 0.38, 0.29)
			mat.roughness = 0.85
		"awning_blue":
			mat.albedo_color = Color(0.20, 0.31, 0.40)
			mat.roughness = 0.85
		"fabric_red":
			mat.albedo_color = Color(0.60, 0.23, 0.19)
			mat.roughness = 0.95
		"fabric_blue":
			mat.albedo_color = Color(0.27, 0.38, 0.50)
			mat.roughness = 0.95
		"fabric_yellow":
			mat.albedo_color = Color(0.78, 0.60, 0.24)
			mat.roughness = 0.95
		"fabric_white":
			mat.albedo_color = Color(0.86, 0.82, 0.73)
			mat.roughness = 0.95
		"leaf":
			mat.albedo_color = Color(0.28, 0.38, 0.22)
			mat.roughness = 0.9
		"leaf_light":
			mat.albedo_color = Color(0.40, 0.47, 0.28)
			mat.roughness = 0.9
		"terracotta":
			mat.albedo_color = Color(0.52, 0.29, 0.19)
			mat.roughness = 0.9
		"fruit_orange":
			mat.albedo_color = Color(0.88, 0.45, 0.10)
			mat.roughness = 0.6
		"fruit_red":
			mat.albedo_color = Color(0.62, 0.13, 0.11)
			mat.roughness = 0.55
		"fruit_green":
			mat.albedo_color = Color(0.55, 0.62, 0.20)
			mat.roughness = 0.6
		"paper_white":
			mat.albedo_color = Color(0.88, 0.84, 0.74)
			mat.roughness = 0.95
		"paper_blue":
			mat.albedo_color = Color(0.30, 0.43, 0.58)
			mat.roughness = 0.9
		"paper_rose":
			mat.albedo_color = Color(0.66, 0.34, 0.32)
			mat.roughness = 0.9
		"sign_darkgreen":
			mat.albedo_color = Color(0.10, 0.22, 0.16)
			mat.roughness = 0.6
		"sign_blue":
			mat.albedo_color = Color(0.12, 0.19, 0.30)
			mat.roughness = 0.6
		"sign_wood":
			mat.albedo_color = Color(0.25, 0.16, 0.10)
			mat.roughness = 0.7
		"chalk":
			mat.albedo_color = Color(0.10, 0.12, 0.10)
			mat.roughness = 1.0
		"plastic_red":
			mat.albedo_color = Color(0.55, 0.12, 0.10)
			mat.roughness = 0.5
		"plastic_green":
			mat.albedo_color = Color(0.18, 0.34, 0.24)
			mat.roughness = 0.5
		"car_blue":
			mat.albedo_color = Color(0.24, 0.36, 0.44)
			mat.metallic = 0.35
			mat.roughness = 0.32
		"car_red":
			mat.albedo_color = Color(0.48, 0.19, 0.14)
			mat.metallic = 0.3
			mat.roughness = 0.4
		"white":
			mat.albedo_color = Color(0.85, 0.84, 0.79)
			mat.roughness = 0.7
		_:
			mat.albedo_color = Color(0.7, 0.3, 0.7)
	return mat


static func _stucco(mat: StandardMaterial3D, color: Color) -> void:
	mat.albedo_color = color * 1.15
	mat.albedo_texture = _grain("stucco", 0.30, 0.055, 4, 0.96)
	mat.normal_enabled = true
	mat.normal_texture = _normal("stucco", 0.20, 4)
	mat.normal_scale = 0.45
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3(0.30, 0.30, 0.30)
	mat.roughness = 0.94


static func _grain(key: String, freq: float, gain: float, octaves: int, shade: float) -> NoiseTexture2D:
	if _noise_tex.has(key):
		return _noise_tex[key]
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = freq
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	var tex := NoiseTexture2D.new()
	tex.width = 512
	tex.height = 512
	tex.seamless = true
	tex.noise = noise
	var ramp := Gradient.new()
	ramp.set_color(0, Color(shade, shade, shade))
	ramp.set_color(1, Color(1, 1, 1))
	tex.color_ramp = ramp
	_noise_tex[key] = tex
	return tex


static func _normal(key: String, freq: float, octaves: int) -> NoiseTexture2D:
	if _noise_nrm.has(key):
		return _noise_nrm[key]
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = freq
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = octaves
	var tex := NoiseTexture2D.new()
	tex.width = 256
	tex.height = 256
	tex.seamless = true
	tex.as_normal_map = true
	tex.bump_strength = 3.0
	tex.noise = noise
	_noise_nrm[key] = tex
	return tex


