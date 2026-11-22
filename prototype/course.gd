extends Node3D

const STRAIGHT := 110.0
const RADIUS := 19.0
const ROAD_HALF_WIDTH := 4.6
const LENGTH := 2.0 * STRAIGHT + PI * RADIUS
const RAMP_LENGTH := 240.0 # Distance along the asphalt in metres.
const GRADE := 0.10 # Rise / horizontal run.

var ramp := false

func length_m() -> float:
	return RAMP_LENGTH if ramp else LENGTH

func center_at(distance: float) -> Vector3:
	if ramp or distance < STRAIGHT:
		return Vector3(0, 0, -distance)
	var arc := distance - STRAIGHT
	if arc < PI * RADIUS:
		var angle := arc / RADIUS
		return Vector3(RADIUS * (1.0 - cos(angle)), 0, -STRAIGHT - RADIUS * sin(angle))
	return Vector3(2 * RADIUS, 0, -STRAIGHT + arc - PI * RADIUS)

func road_distance(p: Vector3) -> float:
	if ramp:
		return absf(p.x)
	if p.z < -STRAIGHT:
		return absf(Vector2(p.x - RADIUS, p.z + STRAIGHT).length() - RADIUS)
	return minf(absf(p.x), absf(p.x - 2.0 * RADIUS))

func crossed_finish(before: Vector3, after: Vector3, downhill: bool) -> bool:
	var end_distance := 0.0 if downhill else length_m()
	var finish := center_at(end_distance)
	var approach := center_at(end_distance + (1.0 if downhill else -1.0))
	var direction := (finish - approach).normalized()
	var from_line := (before - finish).dot(direction)
	var to_line := (after - finish).dot(direction)
	if from_line >= 0 or to_line < 0:
		return false
	var crossing := before.lerp(after, -from_line / (to_line - from_line))
	return absf((crossing - finish).dot(direction.cross(Vector3.UP))) <= ROAD_HALF_WIDTH

func material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	return mat

func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.material_override = mat
	parent.add_child(item)
	item.position = pos
	return item

func strip(offset: float, width: float, height: float, mat: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var previous_a := Vector3.ZERO
	var previous_b := Vector3.ZERO
	for step in range(166):
		var distance := lerpf(-20, length_m() + 20, step / 165.0)
		var center := center_at(distance) + Vector3.UP * height
		var side := (center_at(distance + 0.1) - center_at(distance - 0.1)).normalized().cross(Vector3.UP)
		var a := center + side * (offset - width / 2)
		var b := center + side * (offset + width / 2)
		if step > 0:
			for vertex: Vector3 in [previous_a, previous_b, a, previous_b, b, a]:
				surface.set_normal(Vector3.UP)
				surface.add_vertex(vertex)
		previous_a = a
		previous_b = b
	var ribbon := MeshInstance3D.new()
	ribbon.mesh = surface.commit()
	ribbon.material_override = mat
	add_child(ribbon)

func _ready() -> void:
	if ramp:
		rotation.x = atan(GRADE)
	box(self, Vector3(0,-0.6,0), Vector3(1600,1,1600), material(Color("#6f865a")))
	var asphalt := material(Color("#49494a"))
	var paint := material(Color("#ddd7b9"))
	asphalt.cull_mode = BaseMaterial3D.CULL_DISABLED
	paint.cull_mode = BaseMaterial3D.CULL_DISABLED
	strip(0, 2 * ROAD_HALF_WIDTH, 0, asphalt)
	for edge in [-1, 1]:
		strip(edge * (ROAD_HALF_WIDTH - 0.24), 0.13, 0.018, paint)
	for distance in range(0, int(length_m()), 10):
		var mark := box(self, center_at(distance) + Vector3.UP * 0.025, Vector3(0.13,0.02,2.5), paint)
		mark.basis = Basis.looking_at(center_at(distance + 0.5) - center_at(distance))
	box(self, center_at(length_m()) + Vector3.UP * 0.04, Vector3(9,0.03,0.55), paint)
	if ramp:
		box(self, center_at(0) + Vector3.UP * 0.04, Vector3(9,0.03,0.55), paint)
		var marker := material(Color("#306aa3"))
		for side in [-1, 1]:
			box(self, center_at(RAMP_LENGTH / 2) + Vector3(side * (ROAD_HALF_WIDTH + 0.7),0.7,0), Vector3(0.35,1.4,0.35), marker)
	else:
		add_median()
	add_landscape(paint)

func add_median() -> void:
	# The rocky median physically separates the two straights.
	var ridge := StaticBody3D.new()
	add_child(ridge)
	ridge.position = Vector3(RADIUS, 1.1, 76)
	var dimensions := Vector3(14, 2.4, 368)
	var stone := material(Color("#827d6c"))
	box(ridge, Vector3.ZERO, dimensions, stone)
	var shape := BoxShape3D.new()
	shape.size = dimensions
	var collision := CollisionShape3D.new()
	collision.shape = shape
	ridge.add_child(collision)

func add_landscape(paint: Material) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 417
	var evergreen := CylinderMesh.new()
	evergreen.radial_segments = 7
	evergreen.bottom_radius = 1.7
	evergreen.top_radius = 0.0
	evergreen.height = 7.0
	evergreen.material = material(Color("#365a48"))
	for i in range(115):
		var tree := MeshInstance3D.new()
		tree.mesh = evergreen
		add_child(tree)
		var x := rng.randf_range(-105,-11) if i % 2 == 0 else rng.randf_range(50,140)
		var height_scale := rng.randf_range(0.75,1.7)
		tree.scale = Vector3.ONE * height_scale
		tree.position = Vector3(x,3.5*height_scale-0.1,rng.randf_range(-195,70))
		tree.rotation.x = -rotation.x
	for distance in range(5, int(length_m()), 12):
		var normal := (center_at(distance + 1) - center_at(distance)).normalized().cross(Vector3.UP)
		var outside := center_at(distance) - normal * (ROAD_HALF_WIDTH + 0.6)
		box(self, outside + Vector3.UP*0.43, Vector3(0.16,0.86,0.16), paint)
	for i in range(36):
		var mountain := MeshInstance3D.new()
		var peak := CylinderMesh.new()
		peak.radial_segments = 7
		peak.bottom_radius = rng.randf_range(48, 105)
		peak.top_radius = rng.randf_range(0, 9)
		peak.height = rng.randf_range(45, 100)
		mountain.mesh = peak
		mountain.material_override = material(Color("#667567").darkened(rng.randf_range(0,0.25)))
		add_child(mountain)
		var angle := TAU * i / 36.0
		# Keep the distant skyline fixed in world space when the test road tilts.
		mountain.global_position = Vector3(19 + cos(angle)*260, -3, -50 + sin(angle)*260)
		mountain.global_rotation = Vector3.ZERO
