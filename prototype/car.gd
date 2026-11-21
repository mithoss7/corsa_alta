extends CharacterBody3D

var steering := 0.0
var reversing := false
var previous_brake := false

func assemble(course) -> void:
	var shell: Material = course.material(Color("#ae3025"))
	var glass: Material = course.material(Color("#243540"))
	var rubber: Material = course.material(Color("#262727"))
	var lamp: Material = course.material(Color("#ff6950"))
	course.box(self, Vector3(0,0.68,0), Vector3(1.84,0.58,4.15), shell)
	course.box(self, Vector3(0,1.13,0.15), Vector3(1.49,0.48,1.96), glass)
	course.box(self, Vector3(0,1.39,0.19), Vector3(1.52,0.09,1.75), shell)
	for side in [-1, 1]:
		course.box(self, Vector3(0.64*side,0.72,2.08), Vector3(0.45,0.17,0.05), lamp)
		for axle in [-1, 1]:
			var wheel := MeshInstance3D.new()
			var tire := CylinderMesh.new()
			tire.top_radius = 0.33
			tire.bottom_radius = 0.33
			tire.height = 0.21
			tire.radial_segments = 12
			wheel.mesh = tire
			wheel.material_override = rubber
			add_child(wheel)
			wheel.position = Vector3(side*0.89,0.34,axle*1.3)
			wheel.rotation.z = PI/2
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8,1,4.1)
	collider.shape = shape
	add_child(collider)
	collider.position.y = 0.67
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

func drive(dt: float, throttle: bool, brake: bool, turn: float, grass: bool) -> void:
	var forward := -transform.basis.z
	var right := transform.basis.x
	var speed := velocity.dot(forward)
	if brake and not previous_brake and velocity.length() < 0.12:
		reversing = true
	if not brake or throttle:
		reversing = false
	previous_brake = brake
	steering = move_toward(steering, turn, dt * 2.3)
	var drive_force := 0.0
	if throttle:
		drive_force = 5.5 if speed >= 0 else 10.0
	elif reversing and speed > -5.0:
		drive_force = -3.0
	elif brake and speed > 0:
		drive_force = -minf(10.5, speed / dt)
	var friction := 4.0 if grass else 9.6
	var rolling_drag := 1.9 if grass else 0.23
	var drag_factor := 0.022 if grass else 0.0035
	velocity = velocity.move_toward(Vector3.ZERO, (rolling_drag + velocity.length_squared()*drag_factor)*dt)
	velocity += forward * drive_force * dt
	var lateral := velocity.dot(right)
	var grip := maxf(0.45, sqrt(maxf(0.0, 1.0 - pow(minf(1.0, absf(drive_force)/friction), 2))))
	velocity -= right * clampf(lateral, -friction*grip*dt, friction*grip*dt)
	var yaw_rate := speed * tan(steering * 0.54) / 2.55
	var yaw_limit := friction / maxf(2.5, absf(speed)) * 1.25
	rotate_y(-clampf(yaw_rate, -yaw_limit, yaw_limit) * dt)
	move_and_slide()
