extends Control
## 战车HUD (TankHUD)
## 驾驶战车时显示的状态界面
## 显示: 装甲值/燃料/弹药/速度

@onready var armor_bar: ProgressBar = $VBoxContainer/ArmorRow/ArmorBar
@onready var armor_label: Label = $VBoxContainer/ArmorRow/ArmorLabel
@onready var fuel_bar: ProgressBar = $VBoxContainer/FuelRow/FuelBar
@onready var fuel_label: Label = $VBoxContainer/FuelRow/FuelLabel
@onready var ammo_label: Label = $VBoxContainer/AmmoRow/AmmoLabel
@onready var tank_name_label: Label = $VBoxContainer/TankNameLabel
@onready var exit_hint: Label = $VBoxContainer/ExitHint

var _tank_id: String = ""

func _ready() -> void:
	visible = false
	# 连接 TankSystem 信号
	TankSystem.tank_entered.connect(_on_tank_entered)
	TankSystem.tank_exited.connect(_on_tank_exited)
	TankSystem.tank_damaged.connect(_on_tank_damaged)
	TankSystem.fuel_changed.connect(_on_fuel_changed)

func _process(_delta: float) -> void:
	if visible and _tank_id:
		# 持续更新燃料消耗 (驾驶时)
		var tank = TankSystem.tanks.get(_tank_id)
		if tank:
			armor_label.text = "%d / %d" % [tank.current_hp, tank.max_hp]
			armor_bar.value = float(tank.current_hp) / tank.max_hp * 100
			fuel_label.text = "%d / %d" % [tank.current_fuel, tank.max_fuel]
			fuel_bar.value = float(tank.current_fuel) / tank.max_fuel * 100
			ammo_label.text = "弹药: %d / %d" % [tank.current_ammo, tank.max_ammo]

func _on_tank_entered(tank_id: String) -> void:
	_tank_id = tank_id
	var tank = TankSystem.tanks.get(tank_id)
	if tank:
		tank_name_label.text = "🚗 " + tank.name
	visible = true

func _on_tank_exited(_tank_id: String) -> void:
	_tank_id = ""
	visible = false

func _on_tank_damaged(_tank_id: String, _new_hp: int) -> void:
	# 受伤闪烁
	if visible:
		var tw := create_tween()
		tw.tween_property(armor_bar, "modulate", Color(1, 0.3, 0.3), 0.1)
		tw.tween_property(armor_bar, "modulate", Color.WHITE, 0.3)

func _on_fuel_changed(_tank_id: String, _new_fuel: int) -> void:
	pass  # 在 _process 中持续更新
