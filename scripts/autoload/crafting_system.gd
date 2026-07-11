extends Node
## 合成系统 (CraftingSystem)
## 允许玩家用收集的材料合成物品和装备
## 作为 Autoload 单例运行

## 合成配方
class Recipe:
	var id: String
	var result_id: String        ## 产物物品ID
	var result_name: String      ## 产物名称
	var result_type: int         ## 产物类型 (0=消耗品, 1=武器, 2=防具, 3=饰品)
	var materials: Dictionary    ## 所需材料 {item_id: count}
	var coins_cost: int = 0      ## 金币消耗
	var unlocked: bool = true    ## 是否已解锁

## 所有配方
var recipes: Dictionary = {}

func _ready() -> void:
	_init_recipes()

## 初始化合成配方
func _init_recipes() -> void:
	# 消耗品配方
	_register("craft_potion", "potion", "恢复药", 0,
		{"ant_chitin": 1}, 20)
	_register("craft_antidote", "antidote", "解毒药", 0,
		{"ant_chitin": 2}, 30)
	_register("craft_repair_kit", "repair_kit", "修理包", 0,
		{"machine_part": 2, "scrap_metal": 3}, 50)

	# 武器配方
	_register("craft_iron_sword", "iron_sword", "铁剑", 1,
		{"scrap_metal": 5, "machine_part": 1}, 100)
	_register("craft_energy_gun", "energy_gun", "能量枪", 1,
		{"ancient_chip": 1, "machine_part": 3}, 300)

	# 防具配方
	_register("craft_ant_armor", "ant_armor", "蚁壳护甲", 2,
		{"ant_chitin": 5}, 80)
	_register("craft_mech_armor", "mech_armor", "机械护甲", 2,
		{"machine_part": 4, "scrap_metal": 4}, 150)

	# 饰品配方
	_register("craft_power_chip", "power_chip", "力量芯片", 3,
		{"ancient_chip": 2, "machine_part": 2}, 500)

## 注册配方
func _register(id: String, result_id: String, result_name: String, result_type: int, materials: Dictionary, coins: int = 0) -> void:
	var recipe := Recipe.new()
	recipe.id = id
	recipe.result_id = result_id
	recipe.result_name = result_name
	recipe.result_type = result_type
	recipe.materials = materials
	recipe.coins_cost = coins
	recipes[id] = recipe

## 检查是否可以合成
func can_craft(recipe_id: String) -> bool:
	if not recipes.has(recipe_id):
		return false
	var recipe = recipes[recipe_id]
	if not recipe.unlocked:
		return false

	# 检查金币
	if GameData.coins < recipe.coins_cost:
		return false

	# 检查材料
	for material_id in recipe.materials.keys():
		var required = recipe.materials[material_id]
		var have = _count_item(material_id)
		if have < required:
			return false

	return true

## 合成物品
func craft(recipe_id: String) -> bool:
	if not can_craft(recipe_id):
		return false

	var recipe = recipes[recipe_id]

	# 消耗金币
	GameData.coins -= recipe.coins_cost
	GameData.coins_changed.emit(GameData.coins)

	# 消耗材料
	for material_id in recipe.materials.keys():
		var required = recipe.materials[material_id]
		_remove_item(material_id, required)

	# 添加产物
	_add_item(recipe.result_id, recipe.result_name, recipe.result_type, 1)

	print("[Crafting] 合成成功: " + recipe.result_name)
	return true

## 计算背包中某物品数量
func _count_item(item_id: String) -> int:
	var count = 0
	for item in GameData.inventory:
		if item.id == item_id:
			count += item.count
	return count

## 移除物品
func _remove_item(item_id: String, count: int) -> void:
	var remaining = count
	var to_remove = []
	for item in GameData.inventory:
		if item.id == item_id and remaining > 0:
			var take = min(item.count, remaining)
			item.count -= take
			remaining -= take
			if item.count <= 0:
				to_remove.append(item)
	for item in to_remove:
		GameData.inventory.erase(item)
	GameData.inventory_changed.emit()

## 添加物品
func _add_item(item_id: String, item_name: String, item_type: int, count: int) -> void:
	var item := GameData.Item.new()
	item.id = item_id
	item.name = item_name
	item.type = item_type
	item.count = count
	item.stackable = (item_type == 0)  # 消耗品可堆叠
	GameData.add_item(item)

## 获取所有配方
func get_all_recipes() -> Array:
	return recipes.values()

## 获取已解锁配方
func get_unlocked_recipes() -> Array:
	var result = []
	for recipe in recipes.values():
		if recipe.unlocked:
			result.append(recipe)
	return result

## 获取合成产物描述
func get_result_description(result_id: String) -> String:
	match result_id:
		"potion": return "恢复50HP"
		"antidote": return "解除中毒"
		"repair_kit": return "战车恢复100装甲"
		"iron_sword": return "攻击力+20"
		"energy_gun": return "攻击力+35, 远程武器"
		"ant_armor": return "防御力+15"
		"mech_armor": return "防御力+25"
		"power_chip": return "攻击力+10, 速度+5"
		_: return ""
