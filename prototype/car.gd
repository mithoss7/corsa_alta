extends CharacterBody3D

const MASS_KG := 1200.0
const YAW_INERTIA := 1950.0 # kg·m²
const FRONT_ARM := 1.2 # metres ahead of the centre of mass
const REAR_ARM := 1.4
const GRAVITY := 9.81
const ASPHALT_MU := 0.95
const GRASS_MU := 0.40

var yaw_rate := 0.0 # rad/s, positive for a right turn
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
			wheel.position = Vector3(side*0.89,0.34,-FRONT_ARM if axle == -1 else REAR_ARM)
			wheel.rotation.z = PI/2
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8,1,4.1)
	collider.shape = shape
	add_child(collider)
	collider.position.y = 0.67
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

func drive(dt: float, throttle: bool, brake: bool, turn: float, grass: bool) -> void:
	var speed := velocity.dot(-transform.basis.z)
	if brake and not previous_brake and velocity.length() < 0.12:
		reversing = true
	if not brake or throttle:
		reversing = false
	previous_brake = brake
	steering = move_toward(steering, turn, dt * 2.3)
	var traction := 0.0
	var braking := brake and not reversing and not throttle
	if throttle:
		traction = minf(6400.0, 90000.0 / maxf(absf(speed), 1.0))
	elif reversing and speed > -5.0:
		traction = -3200.0
	# Short steps keep the stiff tyre response stable, including near standstill.
	var steps := maxi(1, ceili(dt * 240.0))
	for step in range(steps):
		integrate_forces(dt / steps, traction, braking, grass)
	move_and_slide()

func integrate_forces(dt: float, traction: float, braking: bool, grass: bool) -> void:
	var right := transform.basis.x
	var normal := transform.basis.y
	# Integrate weight in the road plane first so the brakes can hold at rest.
	velocity += Vector3.DOWN.slide(normal) * GRAVITY * dt
	var front_share := REAR_ARM / (FRONT_ARM + REAR_ARM)
	var front := axle_force(FRONT_ARM, front_share, steering * 0.54, 68000.0, traction, braking, grass, dt)
	var rear := axle_force(-REAR_ARM, 1.0 - front_share, 0.0, 76000.0, traction, braking, grass, dt)
	var air_resistance := -0.40 * velocity.length() * velocity
	velocity += (front + rear + air_resistance) * (dt / MASS_KG)
	var yaw_moment := FRONT_ARM * front.dot(right) - REAR_ARM * rear.dot(right)
	yaw_rate += yaw_moment * dt / YAW_INERTIA
	rotate_object_local(Vector3.UP, -yaw_rate * dt)

func axle_force(arm: float, share: float, angle: float, stiffness: float, traction: float,
		braking: bool, grass: bool, dt: float) -> Vector3:
	var normal := transform.basis.y
	var wheel_forward := (-transform.basis.z).rotated(normal, -angle)
	var wheel_right := wheel_forward.cross(normal)
	var contact_velocity := velocity + transform.basis.x * (arm * yaw_rate)
	var longitudinal := contact_velocity.dot(wheel_forward)
	var lateral := contact_velocity.dot(wheel_right)
	var load_n := MASS_KG * GRAVITY * normal.y * share
	var rolling := load_n * (0.12 if grass else 0.015)
	var resistance := rolling + (11500.0 * share if braking else 0.0)
	# Dissipative forces can stop a wheel but must not propel it in reverse.
	var fx := traction * share - signf(longitudinal) * minf(resistance, absf(longitudinal) * MASS_KG * share / dt)
	var slip_angle := atan2(lateral, maxf(absf(longitudinal), 1.5))
	var fy := -stiffness * slip_angle
	var forces := Vector2(fx, fy).limit_length(load_n * (GRASS_MU if grass else ASPHALT_MU))
	return wheel_forward * forces.x + wheel_right * forces.y
