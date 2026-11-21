extends SceneTree

# Replay keyboard inputs through the prototype using a fixed simulation rate.
var session
var failed := false

func _initialize() -> void:
	call_deferred("run")

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func frames(count: int) -> void:
	for tick in range(count):
		await physics_frame

func check(ok: bool, description: String) -> void:
	if not ok:
		failed = true
		push_error(description)

func run() -> void:
	session = load("res://hairpin.tscn").instantiate()
	root.add_child(session)
	await frames(2)
	key(KEY_ENTER,true)
	key(KEY_ENTER,false)
	await frames(60)
	check(session.state == "countdown" and session.elapsed == 0, "Départ anticipé")
	await frames(130)
	check(session.state == "running", "Le signal de départ doit libérer la voiture")
	key(KEY_Z,true)
	await frames(100)
	key(KEY_Z,false)
	var asphalt_speed: float = session.car.velocity.length()
	check(asphalt_speed > 4 and session.car.position.z < -2, "Accélération sur asphalte")
	key(KEY_ESCAPE,true)
	key(KEY_ESCAPE,false)
	var paused_time: float = session.elapsed
	var paused_position: Vector3 = session.car.position
	await frames(10)
	check(session.state == "paused" and session.elapsed == paused_time and session.car.position == paused_position, "Pause du chrono et de la simulation")
	key(KEY_ESCAPE,true)
	key(KEY_ESCAPE,false)
	key(KEY_D,true)
	await frames(18)
	key(KEY_D,false)
	check(session.car.steering > 0 and session.car.rotation.y < 0, "Braquage progressif à droite")
	key(KEY_Q,true)
	await frames(45)
	key(KEY_Q,false)
	check(session.car.steering < 0, "Braquage à gauche")
	key(KEY_S,true)
	await frames(160)
	check(session.car.velocity.length() < 0.12, "Freinage jusqu’à l’arrêt")
	key(KEY_S,false)
	await frames(2)
	key(KEY_S,true)
	await frames(30)
	key(KEY_S,false)
	check(session.car.velocity.dot(session.car.transform.basis.z) > 0.4, "Marche arrière après un nouvel appui")
	session.reset_car()
	session.car.position.x = -8
	key(KEY_Z,true)
	await frames(100)
	key(KEY_Z,false)
	check(session.car.velocity.length() < asphalt_speed, "L’herbe doit ralentir la voiture")
	session.reset_car()
	session.car.position = session.course.center_at(session.course.LENGTH - 0.5)
	session.car.rotation.y = PI
	key(KEY_Z,true)
	await frames(80)
	key(KEY_Z,false)
	check(session.state == "finished", "Franchissement de la ligne d’arrivée")
	key(KEY_ENTER,true)
	key(KEY_ENTER,false)
	await frames(2)
	check(session.state == "countdown" and session.elapsed == 0, "Nouvel essai depuis le résultat")
	if not failed:
		print("ESSAI CONDUITE OK")
	quit(1 if failed else 0)
