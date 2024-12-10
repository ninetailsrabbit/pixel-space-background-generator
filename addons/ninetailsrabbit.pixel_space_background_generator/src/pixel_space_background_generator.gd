class_name PixelSpaceBackgroundGenerator extends Control

const BackgroundStarScene: PackedScene = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/components/background_star.tscn")

@export var tiled: bool = false
@export var tile_offset: float = 10.0
@export var reduce_background: bool = false
@export var current_color_scheme: GradientTexture1D = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/color_schemes/Colorscheme.tres")
@export_category("Stars")
## Set to zero to calculate the amount based on the viewport size
@export var amount_of_stars: int = 0

@onready var stars: ColorRect = $Stars
@onready var nebulae: ColorRect = $Nebulae
@onready var star_container: Node2D = $StarContainer
@onready var planet_container: Node2D = $PlanetContainer

var planet_objects: Array[Variant] = []
var star_objects: Array[Variant] = []


func generate_new() -> void:
	var aspect: Vector2 = Vector2(size.x / size.y, 1.0) if size.x > size.y else Vector2(1.0, size.x / size.y)
	
	print("aspect ", aspect)
	stars.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
	stars.material.set_shader_parameter("pixels", max(size.x, size.y))
	stars.material.set_shader_parameter("uv_correct", aspect)
	
	create_stars()
	

func create_stars() -> void:
	for star in star_objects:
		star.queue_free()
		
	star_objects.clear()
	
	var stars_amount: int = amount_of_stars if amount_of_stars > 0 else max(1, int(max(size.x, size.y) / 20)) 
	
	for i in randi() % stars_amount:
		create_star()


func create_star() -> void:
	var place_position: Vector2
	
	if tiled:
		place_position = Vector2(int(randf_range(tile_offset, size.x - tile_offset)), int(randf_range(tile_offset, size.y - tile_offset)))
	else:
		place_position = Vector2(int(randf_range(0, size.x)), int(randf_range(0, size.y)))

	
	var background_star = BackgroundStarScene.instantiate()
	background_star.position = place_position
	star_container.add_child(background_star)
	star_objects.append(background_star)
	
