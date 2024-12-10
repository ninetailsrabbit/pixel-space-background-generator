@tool
class_name PixelSpaceBackgroundGenerator extends Control

const BackgroundStarScene: PackedScene = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/components/background_star.tscn")
const BackgroundPlanetScene: PackedScene = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/components/planet.tscn")

@export var tiled: bool = false
@export var tile_offset: float = 10.0
@export var reduce_background: bool = false
@export var current_color_scheme: GradientTexture1D = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/color_schemes/desert.tres")
@export_category("Stars")
@export var display_stars: bool = true
@export var auto_based_on_viewport_size: bool = true:
	set(value):
		if auto_based_on_viewport_size != value:
			auto_based_on_viewport_size = value
			notify_property_list_changed()
## Set to zero to calculate the amount based on the viewport size
@export var fixed_amount_of_stars: int = 0
## When fixed amount of stars is zero this value will be used on a range creation
@export var min_amount_of_stars: int = 0
## When fixed amount of stars is zero this value will be used on a range creation
@export var max_amount_of_stars: int = 0
@export_category("Planets")
@export var display_planets: bool = true
## Set to zero to calculate the amount based on the viewport size
@export var fixed_amount_of_planets: int = 0
## When fixed amount of planets is zero this value will be used on a range creation
@export var min_amount_of_planets: int = 0
## When fixed amount of planets is zero this value will be used on a range creation
@export var max_amount_of_planets: int = 1
@export_category("Nebulae")
@export var display_nebulaes: bool = true


@onready var background: ColorRect = $CanvasLayer/Background
@onready var stars: ColorRect = $Stars
@onready var nebulae: ColorRect = $Nebulae
@onready var star_container: Node2D = $StarContainer
@onready var planet_container: Node2D = $PlanetContainer

var planet_objects: Array[Variant] = []
var star_objects: Array[Variant] = []
var aspect: Vector2 = Vector2.ONE


func _validate_property(property: Dictionary):
	if property.name in ["fixed_amount_of_stars", "min_amount_of_stars", "max_amount_of_stars"]:
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR if auto_based_on_viewport_size else PROPERTY_USAGE_EDITOR
	

func _ready() -> void:
	
	star_container.show_behind_parent = true
	planet_container.show_behind_parent = true
	
	aspect = _calculate_aspect()
	resized.connect(on_resized)
	

func generate_new() -> void:
	_create_stars()
	_create_planets()
	_create_nebulae()

#region Stars
func _create_stars() -> void:
	remove_stars()
	
	if not display_stars:
		return
	
	stars.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
	stars.material.set_shader_parameter("pixels", max(size.x, size.y))
	stars.material.set_shader_parameter("uv_correct", aspect)
	stars.material.set_shader_parameter("should_tile", tiled)
	stars.material.set_shader_parameter("reduce_background", reduce_background)
	
	var stars_amount: int = fixed_amount_of_stars
	
	if auto_based_on_viewport_size or (fixed_amount_of_stars == 0 and min_amount_of_stars == 0 and max_amount_of_stars == 0):
		stars_amount = randi() % (max(1, int(max(size.x, size.y) / 20)))
	elif fixed_amount_of_stars == 0 and (min_amount_of_stars > 0 or max_amount_of_stars > 0):
		stars_amount = randi_range(min_amount_of_stars, max_amount_of_stars)
	
	for i in stars_amount:
		_create_star()


func _create_star() -> void:
	var place_position: Vector2
	
	if tiled:
		place_position = Vector2(int(randf_range(tile_offset, size.x - tile_offset)), int(randf_range(tile_offset, size.y - tile_offset)))
	else:
		place_position = Vector2(int(randf_range(0, size.x)), int(randf_range(0, size.y)))

	
	var background_star = BackgroundStarScene.instantiate()
	background_star.position = place_position
	star_container.add_child(background_star)
	star_objects.append(background_star)
	

func remove_stars() -> void:
	for star in star_objects:
		star.queue_free()
			
	star_objects.clear()
		
#endregion

#region Nebulae
func _create_nebulae() -> void:
	nebulae.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("should_tile", tiled)
	nebulae.material.set_shader_parameter("reduce_background", reduce_background)
	
#endregion

#region Planets
func _create_planets() -> void:
	remove_planets()
	
	if not display_planets:
		return
		
	var planets_amount: int = fixed_amount_of_planets
	
	if fixed_amount_of_planets == 0 and (min_amount_of_planets > 0 or max_amount_of_planets == 0):
		planets_amount = randi_range(min_amount_of_planets, max_amount_of_planets)
		
		
	for i in planets_amount:
		_create_planet()
	

func _create_planet() -> void:
	var min_size = min(size.x, size.y)
	var planet_scale = Vector2.ONE * (randf_range(0.2, 0.7) * randf_range(0.5, 1.0) * min_size * 0.005)
	var place_position: Vector2
	
	if (tiled):
		var planet_offset: float = planet_scale.x * 100.0 * 0.5
		place_position = Vector2(int(randf_range(planet_offset, size.x - planet_offset)), int(randf_range(planet_offset, size.y - planet_offset)))
	else:
		place_position = Vector2(int(randf_range(0, size.x)), int(randf_range(0, size.y)))
	
	var planet = BackgroundPlanetScene.instantiate()
	planet.scale = planet_scale
	planet.position = place_position
	planet_container.add_child(planet)
	planet_objects.append(planet)


func remove_planets() -> void:
	for planet in planet_objects:
		planet.queue_free()
			
	planet_objects.clear()
#endregion


func toggle_nebulae() -> void:
	nebulae.visible = !nebulae.visible


func toggle_stars() -> void:
	star_container.visible = !star_container.visible


func toggle_planet() -> void:
	planet_container.visible = !planet_container.visible


func _calculate_aspect() -> Vector2:
	return Vector2(size.x / size.y, 1.0) if size.x > size.y else Vector2(1.0, size.x / size.y)


func on_resized() -> void:
	aspect = _calculate_aspect()
