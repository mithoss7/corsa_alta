extends Node3D

const Course = preload("res://course.gd")
const Car = preload("res://car.gd")
const BENCH_SECONDS := 24.0

var course := Course.new()
var car := Car.new()
var camera := Camera3D.new()
var hud := Label.new()
var info := Label.new()
var state := "ready"
var suspended_state := ""
var countdown := 0.0
var elapsed := 0.0
var benchmark := false
var bench_start := 0
var last_frame := 0
var intervals: Array[int] = []

func _ready() -> void:
	add_child(course)
	add_child(car)
	car.assemble(course)
	add_child(camera)
	camera.fov = 66
	camera.far = 800
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52,-28,0)
	sun.light_energy = 1.15
	add_child(sun)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#accadb")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#dee6ec")
	env.ambient_light_energy = 0.75
	camera.environment = env
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(hud)
	layer.add_child(info)
	hud.position = Vector2(35,28)
	hud.add_theme_font_size_override("font_size",32)
	info.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.grow_horizontal = Control.GROW_DIRECTION_BOTH
	info.add_theme_font_size_override("font_size",34)
	for label in [hud,info]:
		label.add_theme_constant_override("outline_size",6)
		label.add_theme_color_override("font_outline_color",Color("#242424"))
	reset_car()
	info.text = "Corsa Alta · Épingle d’essai\nEntrée pour démarrer\nZ accélérer · S freiner / reculer · Q D tourner"
	benchmark = "--mesure" in OS.get_cmdline_user_args()
	if benchmark:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		info.hide()
		bench_start = Time.get_ticks_usec()

func reset_car() -> void:
	car.position = course.center_at(0)
	car.rotation = Vector3.ZERO
	car.velocity = Vector3.ZERO
	car.yaw_rate = 0
	car.steering = 0
	car.previous_brake = false
	car.reversing = false
	camera.position = car.position + Vector3(0,3.6,7.7)
	follow(1)
	elapsed = 0

func start_run() -> void:
	reset_car()
	countdown = 3.0
	state = "countdown"
	info.text = "3"

func follow(weight: float) -> void:
	var target := car.position + car.transform.basis.z*7.7 + Vector3.UP*3.6
	camera.position = camera.position.lerp(target,weight)
	camera.look_at(car.position - car.transform.basis.z*4.5 + Vector3.UP*0.9)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not benchmark and state in ["running","countdown"]:
		pause_run()

func pause_run() -> void:
	suspended_state = state
	state = "paused"
	info.text = "Pause\nÉchap reprendre · R recommencer · F10 quitter"

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F10:
		get_tree().quit()
	elif benchmark:
		return
	elif event.keycode == KEY_ESCAPE:
		if state == "paused":
			state = suspended_state
			info.text = ""
		elif state in ["running","countdown"]:
			pause_run()
	elif event.keycode == KEY_ENTER and state in ["ready","finished"]:
		start_run()
	elif event.keycode == KEY_R and state == "paused":
		start_run()

func _physics_process(dt: float) -> void:
	if benchmark:
		return
	if state == "countdown":
		countdown -= dt
		info.text = str(ceili(countdown))
		if countdown <= 0:
			state = "running"
			info.text = ""
	elif state == "running":
		var turn := float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_Q))
		var grass := course.road_distance(car.position) > course.ROAD_HALF_WIDTH
		var before := car.position
		car.drive(dt,Input.is_key_pressed(KEY_Z),Input.is_key_pressed(KEY_S),turn,grass)
		elapsed += dt
		var finish := course.center_at(course.LENGTH)
		if before.z < finish.z and car.position.z >= finish.z and absf(car.position.x-finish.x) <= course.ROAD_HALF_WIDTH:
			state = "finished"
			info.text = "Arrivée · %.2f s\nEntrée pour recommencer" % elapsed
	follow(1.0 - exp(-8.0 * dt))
	hud.text = "%d km/h     %.2f s" % [roundi(car.velocity.length()*3.6),elapsed]

func _process(_dt: float) -> void:
	if not benchmark:
		return
	var now := Time.get_ticks_usec()
	var seconds := (now - bench_start) / 1_000_000.0 - 3.0
	if seconds < 0:
		return
	if last_frame > 0:
		intervals.append(now - last_frame)
	last_frame = now
	var distance := clampf(seconds / BENCH_SECONDS,0,1) * course.LENGTH
	car.position = course.center_at(distance)
	car.look_at(course.center_at(distance+0.1))
	follow(1)
	hud.text = "Mesure du rendu     %.2f s" % seconds
	if seconds >= BENCH_SECONDS and intervals.size() > 0:
		var over := 0
		var total := 0
		for usec in intervals:
			total += usec
			if usec > 16667:
				over += 1
		var mean_fps := 1e6 * intervals.size() / total
		var in_budget := 100.0 * (intervals.size() - over) / intervals.size()
		print("MESURE GPU=%s moteur=%s resolution=%s images=%d moyenne=%.1f ips dans_budget=%.2f%% max=%.2f ms" % [
			RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_method(),
			DisplayServer.window_get_size(), intervals.size(), mean_fps, in_budget, intervals.max()/1000.0])
		get_tree().quit()
