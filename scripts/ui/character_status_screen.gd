extends Control
## 角色状态详情界面 (CharacterStatusScreen)
## 显示角色的详细属性、装备、技能等信息

@onready var name_label: Label = $Panel/LeftContainer/InfoContainer/NameLabel
@onready var level_label: Label = $Panel/LeftContainer/InfoContainer/LevelLabel
@onready var hp_bar: ProgressBar = $Panel/LeftContainer/StatsContainer/HPRow/HPBar
@onready var hp_label: Label = $Panel/LeftContainer/StatsContainer/HPRow/HPLabel
@onready var exp_bar: ProgressBar = $Panel/LeftContainer/StatsContainer/ExpRow/ExpBar
@onready var exp_label: Label = $Panel/LeftContainer/StatsContainer/ExpRow/ExpLabel
@onready var attack_label: Label = $Panel/LeftContainer/CombatContainer/AttackRow/AttackValue
@onready var defense_label: Label = $Panel/LeftContainer/CombatContainer/DefenseRow/DefenseValue
@onready var speed_label: Label = $Panel/LeftContainer/CombatContainer/SpeedRow/SpeedValue
@onready var weapon_label: Label = $Panel/RightContainer/EquipContainer/WeaponRow/WeaponValue
@onready var armor_label: Label = $Panel/RightContainer/EquipContainer/ArmorRow/ArmorValue
@onready var accessory_label: Label = $Panel/RightContainer/EquipContainer/AccessoryRow/AccessoryValue
@onready var skill_list: VBoxContainer = $Panel/RightContainer/SkillContainer/SkillList
@onready var close_button: Button = $Panel/CloseButton

## 当前显示的角色
var _current_member = null

func _ready() -> void:
        visible = false
        close_button.pressed.connect(close)

## 显示角色状态
## member: PartyMember 对象
func show_status(member) -> void:
        _current_member = member
        _update_display()
        visible = true

## 更新显示
func _update_display() -> void:
        if not _current_member:
                return

        var m = _current_member

        # 基本信息
        name_label.text = m.name
        level_label.text = "Lv. %d" % m.level

        # HP
        hp_label.text = "%d / %d" % [m.current_hp, m.max_hp]
        hp_bar.value = float(m.current_hp) / m.max_hp * 100

        # 经验值
        exp_label.text = "%d / %d" % [m.current_exp, m.max_exp]
        exp_bar.value = float(m.current_exp) / m.max_exp * 100

        # 战斗属性
        attack_label.text = str(m.attack)
        defense_label.text = str(m.defense)
        speed_label.text = str(m.speed)

        # 装备
        weapon_label.text = m.weapon.name if m.weapon else "无"
        armor_label.text = m.armor.name if m.armor else "无"
        accessory_label.text = m.accessory.name if m.accessory else "无"

        # 技能列表
        _update_skill_list(m)

## 更新技能列表
func _update_skill_list(member) -> void:
        # 清除旧列表
        for child in skill_list.get_children():
                child.queue_free()

        # 添加技能
        for skill_id in member.skills:
                var skill = SkillData.get_skill(skill_id)
                if not skill:
                        continue

                var row := HBoxContainer.new()

                var name_lbl := Label.new()
                name_lbl.text = skill.name
                name_lbl.custom_minimum_size = Vector2(120, 0)
                name_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
                name_lbl.add_theme_font_size_override("font_size", 15)
                row.add_child(name_lbl)

                var type_lbl := Label.new()
                match skill.skill_type:
                        0: type_lbl.text = "物理"  # ATTACK
                        1: type_lbl.text = "远程"  # RANGED
                        2: type_lbl.text = "治疗"  # HEAL
                        3: type_lbl.text = "增益"  # BUFF
                        4: type_lbl.text = "减益"  # DEBUFF
                        5: type_lbl.text = "战车"  # TANK_ATTACK
                        6: type_lbl.text = "修理"  # TANK_REPAIR
                        _: type_lbl.text = "未知"
                type_lbl.custom_minimum_size = Vector2(60, 0)
                type_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
                type_lbl.add_theme_font_size_override("font_size", 14)
                row.add_child(type_lbl)

                var power_lbl := Label.new()
                power_lbl.text = "威力 %.1f" % skill.power
                power_lbl.custom_minimum_size = Vector2(80, 0)
                power_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
                power_lbl.add_theme_font_size_override("font_size", 14)
                row.add_child(power_lbl)

                var mp_lbl := Label.new()
                if skill.mp_cost > 0:
                        mp_lbl.text = "MP:%d" % skill.mp_cost
                else:
                        mp_lbl.text = "—"
                mp_lbl.custom_minimum_size = Vector2(60, 0)
                mp_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1))
                mp_lbl.add_theme_font_size_override("font_size", 14)
                row.add_child(mp_lbl)

                skill_list.add_child(row)

## 关闭
func close() -> void:
        visible = false
        queue_free()

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close()
