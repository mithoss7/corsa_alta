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
var downhill := false
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
	show_start()
	benchmark = "--mesure" in OS.get_cmdline_user_args()
	if benchmark:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		info.hide()
		bench_start = Time.get_ticks_usec()

func show_start() -> void:
	state = "ready"
	reset_car()
	var title := "Épingle sur le plat"
	if course.ramp:
		title = "Descente −10 %" if downhill else "Montée +10 %"
	info.text = "%s\nF1 Épingle · F2 Montée · F3 Descente\nEntrée pour démarrer\nZ accélérer · S freiner / reculer · Q D tourner" % title

func select_course(ramp: bool, reverse_run: bool) -> void:
	if course.ramp != ramp:
		remove_child(course)
		course.queue_free()
		course = Course.new()
		course.ramp = ramp
		add_child(course)
	downhill = reverse_run
	show_start()

func reset_car() -> void:
	car.position = course.to_global(course.center_at(course.length_m() if downhill else 0.0))
	car.basis = course.global_basis * Basis(Vector3.UP, PI if downhill else 0.0)
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
	info.text = "Pause\nÉchap reprendre · R recommencer · F10 quitter\nF1 Épingle · F2 Montée · F3 Descente"

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F10:
		get_tree().quit()
	elif benchmark:
		return
	elif state in ["ready","paused","finished"] and event.keycode in [KEY_F1,KEY_F2,KEY_F3]:
		select_course(event.keycode != KEY_F1, event.keycode == KEY_F3)
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
		var before := course.to_local(car.position)
		var grass := course.road_distance(before) > course.ROAD_HALF_WIDTH
		car.drive(dt,Input.is_key_pressed(KEY_Z),Input.is_key_pressed(KEY_S),turn,grass)
		elapsed += dt
		var after := course.to_local(car.position)
		if course.crossed_finish(before, after, downhill):
			state = "finished"
			info.text = "Arrivée · %.2f s\nEntrée pour recommencer\nF1 Épingle · F2 Montée · F3 Descente" % elapsed
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
