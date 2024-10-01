extends PathFollow2D

@export var fight_speed: int = 0
@export var player_name: String = ""
@export var albedo_texture_path: String = ""
@export var normal_map_texture_path: String = ""
@export var fight_id: String

@onready var sprite2D: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init_fight_speed(fight_speed_data):
	fight_speed = fight_speed_data.fight_speed
	fight_id = fight_speed_data.fight_id
	player_name = fight_speed_data.player_name
	albedo_texture_path = fight_speed_data.albedo_texture_path
	normal_map_texture_path = fight_speed_data.normal_map_texture_path
	
	var canvas_texture = CanvasTexture.new()
	canvas_texture.normal_texture = load(normal_map_texture_path)
	canvas_texture.diffuse_texture = load(albedo_texture_path)
	
	sprite2D.texture = canvas_texture
