extends Node
## 战车系统 (TankSystem)
## Metal Max 标志性的战车功能
## 管理战车数据、装备、驾驶模式切换

## 战车数据结构
class TankData:
	var id: String
	var name: String
	var description: String
	# 基础属性
	var max_hp: int = 500          ## 装甲值
	var current_hp: int = 500
	var max_fuel: int = 100        ## 最大燃料
	var current_fuel: int = 100
	var max_ammo: int = 30         ## 最大弹药
	var current_ammo: int = 30
	# 战斗属性
	var attack: int = 50           ## 主炮攻击力
	var defense: int = 30          ## 装甲防御
	var speed: int = 8             ## 速度
	# 装备槽
	var main_cannon: Dictionary = {}    ## 主炮
	var sub_weapon: Dictionary = {}     ## 副武器 (机枪等)
	var engine: Dictionary = {}         ## 引擎
	var armor: Dictionary = {}          ## 装甲板
	# 状态
	var is_owned: bool = false     ## 是否拥有
	var is_active: bool = false    ## 是否当前驾驶中
	var sprite_path: String = ""   ## 精灵图路径

## 全局战车列表
var tanks: Dictionary = {}

## 信号
signal tank_entered(tank_id: String)
signal tank_exited(tank_id: String)
signal tank_damaged(tank_id: String, new_hp: int)
signal fuel_changed(tank_id: String, new_fuel: int)

func _ready() -> void:
	_init_default_tanks()

## 初始化默认战车
func _init_default_tanks() -> void:
	# 红色野狼 - 初始战车
	var red_wolf := TankData.new()
	red_wolf.id = "red_wolf"
	red_wolf.name = "红色野狼"
	red_wolf.description = "雷班纳的初始战车，平衡型装甲车。"
	red_wolf.max_hp = 500
	red_wolf.current_hp = 500
	red_wolf.max_fuel = 100
	red_wolf.current_fuel = 100
	red_wolf.max_ammo = 30
	red_wolf.current_ammo = 30
	red_wolf.attack = 50
	red_wolf.defense = 30
	red_wolf.speed = 8
	red_wolf.is_owned = true
	red_wolf.main_cannon = {
		"name": "105mm加农炮",
		"attack": 50,
		"ammo_cost": 1,
	}
	red_wolf.sub_weapon = {
		"name": "7.62mm机枪",
		"attack": 15,
		"ammo_cost": 0,  # 机枪不消耗主炮弹药
	}
	tanks["red_wolf"] = red_wolf

	# 虎式 - 强力战车 (需要找到)
	var tiger := TankData.new()
	tiger.id = "tiger"
	tiger.name = "虎式重坦"
	tiger.description = "旧文明遗留的重型坦克，火力强大但速度慢。"
	tiger.max_hp = 800
	tiger.current_hp = 800
	tiger.max_fuel = 80
	tiger.current_fuel = 80
	tiger.max_ammo = 20
	tiger.current_ammo = 20
	tiger.attack = 80
	tiger.defense = 50
	tiger.speed = 4
	tiger.is_owned = false
	tanks["tiger"] = tiger

## 获取当前驾驶的战车
func get_active_tank() -> TankData:
	for tank in tanks.values():
		if tank.is_active:
			return tank
	return null

## 进入战车
func enter_tank(tank_id: String) -> void:
	if not tanks.has(tank_id):
		return
	var tank = tanks[tank_id]
	if not tank.is_owned:
		return
	# 退出当前战车
	var current = get_active_tank()
	if current:
		current.is_active = false
	tank.is_active = true
	tank_entered.emit(tank_id)
	print("[TankSystem] 进入战车: " + tank.name)

## 退出战车
func exit_tank() -> void:
	var current = get_active_tank()
	if current:
		current.is_active = false
		tank_exited.emit(current.id)
		print("[TankSystem] 退出战车: " + current.name)

## 战车受到伤害
func damage_tank(tank_id: String, amount: int) -> void:
	if not tanks.has(tank_id):
		return
	var tank = tanks[tank_id]
	tank.current_hp = max(0, tank.current_hp - amount)
	tank_damaged.emit(tank_id, tank.current_hp)
	if tank.current_hp <= 0:
		print("[TankSystem] 战车被摧毁: " + tank.name)

## 消耗燃料
func consume_fuel(tank_id: String, amount: int) -> void:
	if not tanks.has(tank_id):
		return
	var tank = tanks[tank_id]
	tank.current_fuel = max(0, tank.current_fuel - amount)
	fuel_changed.emit(tank_id, tank.current_fuel)

## 补给战车 (在城镇)
func resupply_tank(tank_id: String) -> void:
	if not tanks.has(tank_id):
		return
	var tank = tanks[tank_id]
	tank.current_hp = tank.max_hp
	tank.current_fuel = tank.max_fuel
	tank.current_ammo = tank.max_ammo
	print("[TankSystem] 战车补给完成: " + tank.name)

## 获取拥有的战车列表
func get_owned_tanks() -> Array:
	var result = []
	for tank in tanks.values():
		if tank.is_owned:
			result.append(tank)
	return result
