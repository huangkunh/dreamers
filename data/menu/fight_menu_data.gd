extends Node

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
