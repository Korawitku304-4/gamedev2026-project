extends Node2D

@export var time_per_anim: float = 15.0 # นับถอยหลังท่าละ 15 วินาที

var timer_label: Label
var anim_label: Label
var characters: Array[Node2D] = []

var current_time_left: float = 15.0
var is_counting: bool = false
var has_started: bool = false # ตัวแปรเช็กว่าเริ่มหรือยัง

func _ready() -> void:
	# ค้นหา Label จาก CanvasLayer
	timer_label = find_child("TimerLabel", true, false) as Label
	anim_label = find_child("AnimLabel", true, false) as Label
	
	if not timer_label:
		timer_label = find_child("Label", true, false) as Label

	# เก็บโหนดตัวละครทั้งหมด และซ่อนไว้ก่อน
	for child in get_children():
		if child is Node2D:
			characters.append(child)
			child.hide()
			
	# โชว์ตัวละครตัวแรกขึ้นมาแบบนิ่งๆ ก่อนเริ่ม
	if characters.size() > 0:
		characters[0].show()
	
	# แสดงข้อความบอกให้ผู้ใช้คลิก
	if anim_label:
		anim_label.text = "Click Screen to Start!"
	if timer_label:
		timer_label.text = "Ready..."

func _input(event: InputEvent) -> void:
	# ถ้ายังไม่ได้เริ่ม และมีการคลิกเมาส์ซ้าย (หรือกดปุ่มใดๆ)
	if not has_started:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			has_started = true
			run_showcase()

func _process(delta: float) -> void:
	# นับถอยหลังเมื่อการทำงานเริ่มแล้ว
	if is_counting and current_time_left > 0:
		current_time_left -= delta
		if current_time_left < 0:
			current_time_left = 0
		
		if timer_label:
			timer_label.text = "Time Left: %2d s" % int(ceil(current_time_left))

func run_showcase() -> void:
	var total_shows = min(4, characters.size())
	
	for i in range(total_shows):
		# ซ่อนตัวก่อนหน้า
		for c in characters:
			c.hide()
			
		var current_char = characters[i]
		current_char.show()
		
		# รีเซ็ตเวลา 15 วิ
		current_time_left = time_per_anim
		is_counting = true
		
		# เล่น Animation
		var current_anim_name = ""
		var anim_player = _find_animation_player(current_char)
		
		if anim_player:
			var anim_list = anim_player.get_animation_list()
			
			for a_name in anim_list:
				if a_name.to_lower() in current_char.name.to_lower() or current_char.name.to_lower() in a_name.to_lower():
					current_anim_name = a_name
					break
			
			if current_anim_name == "":
				for a_name in anim_list:
					if a_name != "RESET":
						current_anim_name = a_name
						break
			
			if current_anim_name != "":
				anim_player.stop()
				anim_player.play(current_anim_name)
		
		# แสดงชื่อท่าปัจจุบัน
		if anim_label:
			var display_name = current_anim_name if current_anim_name != "" else current_char.name
			anim_label.text = "Action (%d/%d): %s" % [i + 1, total_shows, display_name.capitalize()]
		
		# รอจนหมดเวลา 15 วิ
		await get_tree().create_timer(time_per_anim).timeout
		is_counting = false

	# เมื่อครบทั้ง 4 ท่า
	if timer_label:
		timer_label.text = "Time Left: 0s"
	get_tree().quit() # ปิดเกมอัตโนมัติ

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var res = _find_animation_player(child)
		if res:
			return res
	return null
