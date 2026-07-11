extends Control

# 确定攻击目标信号
signal determine_attack_target_signal

@onready var fight_menu: VBoxContainer = $FightMenu
@onready var button_audio: AudioStreamPlayer3D = $FightMenu/ButtonAudio
@onready var fight_menu_next_lv: VBoxContainer = $FightMenuNextLv
@onready var attack_pointer: Sprite3D = $"../AttackPointer" # 攻击光标

var current_fight_menu_list: Array
var button_list: Array
var button_next_lv_list: Array
var pointer: Sprite2D
var pointer_index: int # 光标处在第几个索引
var pointer_pre_index: int # 光标处在第几个索引
var pointer_lv_index: int # 光标处在第几层菜单
var attack_pointer_index: int # 攻击光标索引
var pointer_texture = preload("res://resource/sprite/buttons/pointer.png")
var select_stream = preload("res://music/sound_effect/select.wav")
var enter_stream = preload("res://music/sound_effect/enter.wav")
var fight_menu_list = load("res://scripts/data/menu/fight_menu_data.gd").new().fight_menu_list

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 创建菜单按钮
	var pointer_init_position
	for i in range(fight_menu_list.size()):
		var menu_name = fight_menu_list[i].menu_name
		var button = Button.new()
		button.text = menu_name
		fight_menu.add_child(button)
		button_list.append(button)
		if i == 0:
			pointer_init_position = button.global_position
			pointer_init_position.y += button.size.y / 2
	
	# 创建菜单光标
	pointer = Sprite2D.new()
	pointer.texture = pointer_texture
	pointer.global_position = pointer_init_position
	pointer.visible = false
	self.add_child(pointer)
	pointer_index = 0
	pointer_lv_index = 0
	current_fight_menu_list = fight_menu_list
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

## 处理按键输入
func _unhandled_key_input(event: InputEvent) -> void:
	# 处于攻击选择中
	if attack_pointer.visible == true:
		# 选择攻击目标
		self.select_attack_target()
		
		# 确定的攻击目标
		determine_attack_target()
			
	# 菜单不可见
	if fight_menu.visible == false:
		return	
	
	# 上下移动光标选择菜单
	select_menu()
	
	# 确认
	confirm_menu()
			
	# 取消
	cancel_menu()
	
	
# 取消菜单
func cancel_menu():
	if Input.is_action_pressed("ui_cancel"):
		if pointer_lv_index == 1:
			pointer_index = pointer_pre_index
			pointer_pre_index = 0
			var button = button_list[pointer_index]
			pointer.global_position = button.global_position
			pointer.global_position.y += button.size.y / 2
			pointer_lv_index = 0
			fight_menu_next_lv.visible = false
			current_fight_menu_list = fight_menu_list
			button_audio.stream = enter_stream
			button_audio.playing = true
		
			
## 确认菜单
func confirm_menu():
	if Input.is_action_pressed("ui_accept"):			
		var current_fight_menu = current_fight_menu_list[pointer_index]
		var next_lv_menu: Array = current_fight_menu.next_lv_menu
		var next_lv_menu_size = next_lv_menu.size()
		var pointer_position
		# 有下一级菜单
		if next_lv_menu_size != null && next_lv_menu_size != 0:
			for i in range(next_lv_menu_size):
				var menu_name = next_lv_menu[i].menu_name
				var button = Button.new()
				button.text = menu_name
				fight_menu_next_lv.add_child(button)
				button_next_lv_list.append(button)
				if i == 0:
					pointer_position = button.global_position
					pointer_position.y += button.size.y / 2
					#pointer_button = button
			
			pointer_lv_index = 1
			pointer_pre_index = pointer_index
			pointer_index = 0
			fight_menu_next_lv.visible = true
			pointer.global_position = pointer_position
			current_fight_menu_list = next_lv_menu
			button_audio.stream = enter_stream
			button_audio.playing = true
		
		# 攻击
		elif pointer_index == 0 && pointer_lv_index == 0:
			var fight = get_parent()
			var fighting_id = fight.fighting_id
			var fight_unit = fight.fighting_unit_map[fighting_id]
			var enemy_scene_map = fight.enemy_scene_map
			
			var battle_lv = fight_unit.battle_lv
			var weapons = fight_unit.weapons
			if weapons != null:
				var attack_type = weapons.attack_type
				var attack_target = weapons.attack_target
				var weapons_battle_lv = weapons.battle_lv
				#if attack_type == Attack_Type.MELEE:
					#if attack_target == Attack_Target.FOE_ONE:
				fight_menu.visible = false
				pointer.visible = false
				button_audio.stream = enter_stream
				button_audio.playing = true
				var enemy_scene = enemy_scene_map.values()[0]
				attack_pointer.global_position = enemy_scene.global_position
				attack_pointer.global_position.z += 0.05
				attack_pointer.visible = true
				attack_pointer_index = 0


## 选择菜单
func select_menu():
	# 判断在哪一层菜单
	var current_button_list
	if pointer_lv_index == 0:
		current_button_list = button_list
	elif pointer_lv_index == 1:
		current_button_list = button_next_lv_list
		
	if Input.is_action_pressed("ui_down"):
		pointer_index += 1
		if pointer_index > current_button_list.size() - 1:
			pointer_index = 0
		button_audio.stream = select_stream
		button_audio.playing = true
	elif Input.is_action_pressed("ui_up"):
		pointer_index -= 1
		if pointer_index < 0:
			pointer_index = current_button_list.size() - 1
		button_audio.stream = select_stream
		button_audio.playing = true
		
	var pointer_button = current_button_list[pointer_index]
	pointer.global_position = pointer_button.global_position
	pointer.global_position.y += pointer_button.size.y / 2


## 确定攻击目标
func determine_attack_target():
	if Input.is_action_pressed("ui_accept"):
		determine_attack_target_signal.emit(attack_pointer_index)
		attack_pointer.visible = false
				

## 选择攻击目标
func select_attack_target():
	var fight = get_parent()
	#var fighting_id = fight.fighting_id
	#var fight_unit = fight.fighting_unit_map[fighting_id]
	#var player_scene_map = fight.player_scene_map
	var enemy_scene_map = fight.enemy_scene_map
	
	# 上下左右移动光标
	if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_right"):
		attack_pointer_index += 1
		button_audio.stream = select_stream
		button_audio.playing = true
	if Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_left"):
		attack_pointer_index -= 1
		button_audio.stream = select_stream
		button_audio.playing = true
	
	if attack_pointer_index < 0:
		attack_pointer_index = enemy_scene_map.values().size() - 1
	elif attack_pointer_index >= enemy_scene_map.values().size():
		attack_pointer_index = 0
	
	# 移动位置
	var enemy_scene = enemy_scene_map.values()[attack_pointer_index]
	attack_pointer.global_position = enemy_scene.global_position
	attack_pointer.global_position.z += 0.05
	
func show_fight_menu():
	fight_menu.visible = true
	
	
func hide_fight_menu():
	fight_menu.visible = false
	

## 行动动画
## action_name 行动名称
func action_name_animation(action_name):
	var skill_name = action_name
	var skill_name_label = get_node("SkillName")
	skill_name_label.text = skill_name
	skill_name_label.visible = true
	var skill_name_label_position = skill_name_label.position
	var skill_name_label_position_tween = Vector2(skill_name_label_position)
	skill_name_label_position_tween.y -= 10
	var skill_name_label_tween = skill_name_label.create_tween()
	skill_name_label_tween.tween_property(skill_name_label, "position", skill_name_label_position_tween, 1)
	skill_name_label_tween.tween_callback(skill_name_label.set_visible.bind(false))
	skill_name_label_tween.tween_callback(skill_name_label.set_position.bind(skill_name_label_position))
