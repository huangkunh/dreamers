extends Control

@onready var fight_menu: VBoxContainer = $FightMenu
@onready var button_audio: AudioStreamPlayer3D = $FightMenu/ButtonAudio
@onready var fight_menu_next_lv: VBoxContainer = $FightMenuNextLv
@onready var attack_pointer: Sprite3D = $"../AttackPointer" # 攻击光标

var protection: Dictionary = {
	"menu_name": "保护",
}

var defense: Dictionary = {
	"menu_name": "防卫",
}

var status: Dictionary = {
	"menu_name": "状态",
}

var flee: Dictionary = {
	"menu_name": "逃跑",
}

var boarding_and_landing: Dictionary = {
	"menu_name": "乘降",
}

var slingshot: Dictionary = {
	"menu_name": "弹弓",
}

var golden_jade_clothes: Dictionary = {
	"menu_name": "金缕玉衣",
}

var tea_eggs: Dictionary = {
	"menu_name": "茶叶蛋",
}

var instant_noodles: Dictionary = {
	"menu_name": "泡面",
}

var weapons_slingshot: Dictionary = {
	"menu_name": "弹弓",
}

var fight_menu_attack: Dictionary = {
		"menu_name": "攻击",
		"next_lv_menu": [],		
}

var tool_menu_attack: Dictionary = {
		"menu_name": "工具",
		"next_lv_menu": [tea_eggs, instant_noodles],
}

var equip_menu_attack: Dictionary = {
		"menu_name": "装备",
		"next_lv_menu": [slingshot, golden_jade_clothes],
}

var aided_menu_attack: Dictionary = {
		"menu_name": "辅助",
		"next_lv_menu": [boarding_and_landing, flee, status, defense, protection],
}

var fight_menu_list: Array =[
	fight_menu_attack,
	tool_menu_attack,
	equip_menu_attack,
	aided_menu_attack,
]

var current_fight_menu_list: Array
var button_list: Array
var button_next_lv_list: Array
var pointer: Sprite2D
var pointer_index: int # 光标处在第几个索引
var pointer_pre_index: int # 光标处在第几个索引
var pointer_lv_index: int # 光标处在第几层菜单
var attack_pointer_index: int # 攻击光标索引
var pointer_texture = preload("res://sprite/buttons/pointer.png")
var select_stream = preload("res://music/sound_effect/select.wav")
var enter_stream = preload("res://music/sound_effect/enter.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
func _unhandled_key_input(event: InputEvent) -> void:
	# 处于攻击选择中
	if attack_pointer.visible == true:
		var fight = get_parent()
		var fighting_id = fight.fighting_id
		var fight_unit = fight.fighting_unit_map[fighting_id]
		var player_scene_map = fight.player_scene_map
		var enemy_scene_map = fight.enemy_scene_map
		
		if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_right"):
			attack_pointer_index += 1
		if Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_left"):
			attack_pointer_index -= 1
		
		if attack_pointer_index < 0:
			attack_pointer_index = enemy_scene_map.values().size() - 1
		elif attack_pointer_index >= enemy_scene_map.values().size():
			attack_pointer_index = 0
		
		
		var enemy_scene = enemy_scene_map.values()[attack_pointer_index]
		attack_pointer.global_position = enemy_scene.global_position
		attack_pointer.global_position.z += 0.05
		
			
			
	if fight_menu.visible == false:
		return
	
	# 判断在哪一层
	var current_button_list
	if pointer_lv_index == 0:
		current_button_list = button_list
	elif pointer_lv_index == 1:
		current_button_list = button_next_lv_list
	
	# 上下移动光标
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

	# 确认
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
					pointer_button = button
			
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
			var player_scene_map = fight.player_scene_map
			var enemy_scene_map = fight.enemy_scene_map
			
			var battle_LV = fight_unit.battle_LV
			var weapons = fight_unit.weapons
			if weapons != null:
				var attack_type = weapons.attack_type
				var attack_target = weapons.attack_target
				var weapons_battle_LV = weapons.battle_LV
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
			
	# 取消
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
	
	
func show_fight_menu():
	fight_menu.visible = true
	
	
func hide_fight_menu():
	fight_menu.visible = false
