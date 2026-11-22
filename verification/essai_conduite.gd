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

func braking_distance(grass: bool) -> float:
	session.reset_car()
	session.state = "running"
	session.car.position.x = -8.0 if grass else 0.0
	var start: Vector3 = session.car.position
	session.car.velocity = -session.car.basis.z * (80.0 / 3.6)
	key(KEY_S, true)
	for tick in range(500):
		await physics_frame
		if session.car.velocity.length() < 0.05:
			break
	check(session.car.velocity.length() < 0.05, "La voiture doit atteindre l’arrêt")
	var stop: Vector3 = session.car.position
	await frames(60)
	check(session.car.position.distance_to(stop) < 0.01, "Frein maintenu : la voiture doit rester arrêtée")
	key(KEY_S, false)
	check(absf(session.course.to_local(stop).y) < 0.002, "Le freinage doit rester dans le plan de la route")
	return start.distance_to(stop)

func select_from_menu(code: Key) -> void:
	if session.state == "running":
		key(KEY_ESCAPE, true)
		key(KEY_ESCAPE, false)
	key(code, true)
	key(code, false)
	await frames(2)
	check(session.state == "ready", "La sélection doit préparer un nouveau départ")

func verify_grade(dry_distance: float) -> void:
	var distances: Array[float] = []
	var speeds: Array[float] = []
	for code: Key in [KEY_F2,KEY_F3]:
		await select_from_menu(code)
		var uphill := code == KEY_F2
		check(session.course.ramp and session.downhill != uphill, "Sens sélectionné")
		var start: Vector3 = session.car.position
		var destination: Vector3 = session.course.to_global(session.course.center_at(session.course.length_m() if uphill else 0.0))
		var along := destination - start
		var grade := along.y / Vector2(along.x, along.z).length()
		check(absf(grade - (0.10 if uphill else -0.10)) < 0.0001, "Pente signée du trajet")
		key(KEY_ENTER, true)
		key(KEY_ENTER, false)
		await frames(120)
		check(session.car.position.is_equal_approx(start), "La voiture reste en place au décompte")
		key(KEY_Z, true)
		for tick in range(75):
			if session.state != "countdown":
				break
			await physics_frame
		check(session.state == "running", "Départ au clavier sur la rampe")
		await frames(120)
		key(KEY_Z, false)
		speeds.append(session.car.velocity.length() * 3.6)
		var rise: float = session.car.position.y - start.y
		check(rise > 0 if uphill else rise < 0, "La voiture suit le dénivelé dans le sens choisi")
		key(KEY_D, true)
		await frames(30)
		key(KEY_D, false)
		check(session.car.yaw_rate > 0 and session.car.basis.y.is_equal_approx(session.course.basis.y), "Le lacet suit la normale à la route")
		check(absf(session.course.to_local(session.car.position).y) < 0.002, "La trajectoire braquée reste sur la route inclinée")
		var distance := await braking_distance(false)
		distances.append(distance)
		var angle := atan(grade)
		var decel: float = session.car.GRAVITY * (session.car.ASPHALT_MU * cos(angle) + sin(angle))
		var ideal := (80.0 / 3.6) ** 2 / (2.0 * decel)
		check(absf(distance - ideal) < 0.05 * ideal, "Distance d’arrêt sur la pente")
		# Start near the opposite end and cross the finish under its own power.
		session.reset_car()
		session.car.position = destination - along.normalized() * 1.5
		key(KEY_Z, true)
		await frames(140)
		key(KEY_Z, false)
		check(session.state == "finished", "La ligne doit conclure le trajet dans le sens choisi")
	check(distances[0] < dry_distance and dry_distance < distances[1], "Ordre des trois distances d’arrêt")
	check(speeds[0] > 0 and speeds[1] > speeds[0], "L’accélération à commande égale doit être supérieure en descente")
	print("Plein gaz pendant 2 s : montée %.2f km/h, descente %.2f km/h" % [speeds[0], speeds[1]])
	print("80–0 km/h, distance sur route : montée +10 %% %.2f m, plat %.2f m, descente −10 %% %.2f m" % [distances[0],dry_distance,distances[1]])
	await select_from_menu(KEY_F1)
	check(not session.course.ramp and session.car.basis.y.is_equal_approx(Vector3.UP), "Retour à l’épingle plate")

func angle_after_twenty_metres(kmh: float) -> float:
	session.reset_car()
	# An isolated dry skidpad gives both speeds the same surface and no walls.
	session.state = "ready"
	session.car.position = Vector3(100,0,0)
	session.car.velocity = Vector3.FORWARD * (kmh / 3.6)
	var distance := 0.0
	for tick in range(300):
		await physics_frame
		var previous: Vector3 = session.car.position
		session.car.drive(1.0 / Engine.physics_ticks_per_second, false, false, 1.0, false)
		distance += previous.distance_to(session.car.position)
		if distance >= 20.0:
			break
	check(distance >= 20.0, "La mesure du virage doit couvrir vingt mètres")
	return atan2(session.car.velocity.x, -session.car.velocity.z)

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
	var dry_distance := await braking_distance(false)
	var grass_distance := await braking_distance(true)
	# d = v²/(2 μg) on level ground. Air resistance and discrete steps shorten the stop slightly.
	for sample in [[dry_distance,session.car.ASPHALT_MU],[grass_distance,session.car.GRASS_MU]]:
		var ideal: float = (80.0 / 3.6) ** 2 / (2.0 * sample[1] * session.car.GRAVITY)
		check(absf(sample[0] - ideal) < ideal * 0.05, "Distance d’arrêt incompatible avec l’adhérence")
	print("Freinage 80–0 km/h : %.2f m sur asphalte, %.2f m sur herbe" % [dry_distance, grass_distance])
	var slow_angle := await angle_after_twenty_metres(40)
	var fast_angle := await angle_after_twenty_metres(80)
	check(slow_angle > fast_angle and fast_angle > 0, "À braquage identique, la voiture doit tourner plus large à grande vitesse")
	await verify_grade(dry_distance)
	if not failed:
		print("ESSAI CONDUITE OK")
	quit(1 if failed else 0)
