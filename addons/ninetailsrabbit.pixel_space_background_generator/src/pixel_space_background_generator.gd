@tool
class_name PixelSpaceBackgroundGenerator extends Control

const BackgroundStarScene: PackedScene = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/components/background_star.tscn")
const BackgroundPlanetScene: PackedScene = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/components/planet.tscn")
const DefaultColorScheme: ColorGradient = preload("res://addons/ninetailsrabbit.pixel_space_background_generator/src/color_schemes/gradients/desert.tres")
const DefaultBackgroundColor: Color = Color("171711")

@export var button_Generate_New: String
@export var tiled: bool = false:
	set(value):
		if value != tiled:
			tiled = value
			_update()
@export var tile_offset: float = 10.0
@export var reduce_background: bool = false:
	set(value):
		if value != reduce_background:
			reduce_background = value
			_update()
@export var background_color: Color = DefaultBackgroundColor:
	set(value):
		if value != background_color:
			background_color = value
			change_background_color(background_color)
@export var current_color_scheme: ColorGradient = DefaultColorScheme:
	set(value):
		if value != current_color_scheme:
			current_color_scheme = value
			_update()
@export var show_stars_behind: bool = true:
	set(value):
		if value != show_stars_behind:
			show_stars_behind = value
			_update()
@export var show_planets_behind: bool = true:
	set(value):
		if value != show_planets_behind:
			show_planets_behind = value
			_update()
@export_category("Export")
@export_dir var export_path: String = "res://space_backgrounds"
@export var button_Export_Background: String

@export_category("Stars")
@export var display_stars: bool = true:
	set(value):
		if value != display_stars:
			display_stars = value
			_update()
@export var display_stars_dust: bool = true:
	set(value):
		if value != display_stars_dust:
			display_stars_dust = value
			_update()
@export var auto_based_on_viewport_size: bool = true:
	set(value):
		if auto_based_on_viewport_size != value:
			auto_based_on_viewport_size = value
			notify_property_list_changed()
			_update()
## Set to zero to calculate the amount based on the viewport size
@export var fixed_amount_of_stars: int = 0:
	set(value):
		if value != fixed_amount_of_stars:
			fixed_amount_of_stars = value
			_update()
## When fixed amount of stars is zero this value will be used on a range creation
@export var min_amount_of_stars: int = 0:
	set(value):
		if value != min_amount_of_stars:
			min_amount_of_stars = value
			_update()
## When fixed amount of stars is zero this value will be used on a range creation
@export var max_amount_of_stars: int = 0:
	set(value):
		if value != max_amount_of_stars:
			max_amount_of_stars = value
			_update()
@export_category("Planets")
@export var display_planets: bool = true:
	set(value):
		if value != display_planets:
			display_planets = value
			_update()
## Set to zero to calculate the amount based on the viewport size
@export var fixed_amount_of_planets: int = 0:
	set(value):
		if value != fixed_amount_of_planets:
			fixed_amount_of_planets = value
			_update()
## When fixed amount of planets is zero this value will be used on a range creation
@export var min_amount_of_planets: int = 0:
	set(value):
		if value != min_amount_of_planets:
			min_amount_of_planets = value
			_update()
## When fixed amount of planets is zero this value will be used on a range creation
@export var max_amount_of_planets: int = 1:
	set(value):
		if value != max_amount_of_planets:
			max_amount_of_planets = value
			_update()
@export_category("Nebulae")
@export var display_nebulaes: bool = true:
	set(value):
		if value != display_nebulaes:
			display_nebulaes = value
			_update()

@onready var background: ColorRect = $CanvasLayer/Background
@onready var stars_dust: ColorRect = $StarsDust
@onready var nebulae: ColorRect = $Nebulae
@onready var stars_container: Node2D = $StarsContainer
@onready var planet_container: Node2D = $PlanetContainer


var planet_objects: Array[Variant] = []
var star_objects: Array[Variant] = []
var aspect: Vector2 = Vector2.ONE


func _validate_property(property: Dictionary):
	if property.name in ["fixed_amount_of_stars", "min_amount_of_stars", "max_amount_of_stars"]:
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR if auto_based_on_viewport_size else PROPERTY_USAGE_EDITOR


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		generate_new()
	

func _ready() -> void:
	change_background_color(background_color)
	remove_stars()
	remove_planets()
	
	stars_container.show_behind_parent = show_stars_behind
	planet_container.show_behind_parent = show_planets_behind
	
	aspect = _calculate_aspect()
	resized.connect(on_resized)
	

func generate_new() -> void:
	_create_stars_dust()
	_create_stars()
	_create_planets()
	_create_nebulae()
	
	
func change_background_color(new_color: Color) -> void:
	if background:
		background.color = new_color
	
	
func _update() -> void:
	if Engine.is_editor_hint() or (not Engine.is_editor_hint() and is_node_ready()):
		_update_stars()
		_update_planets()
		_update_nebulaes()


func _update_stars() -> void:
	stars_dust.visible = display_stars_dust
	stars_container.visible = display_stars
	stars_container.show_behind_parent = show_stars_behind
	
	stars_dust.material.set_shader_parameter("should_tile", tiled)
	stars_dust.material.set_shader_parameter("reduce_background", reduce_background)
	stars_dust.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
	
	if display_stars and star_objects.is_empty():
		_create_stars()
		
	for star in star_objects:
		star.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
		

func _update_planets() -> void:
	planet_container.visible = display_planets
	planet_container.show_behind_parent = show_planets_behind
	
	if display_planets and planet_objects.is_empty() \
		or planet_objects.size() != fixed_amount_of_planets:
		_create_planets()


	for planet in planet_objects:
		planet.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
		

func _update_nebulaes() -> void:
	nebulae.visible = display_nebulaes
	
	nebulae.material.set_shader_parameter("should_tile", tiled)
	nebulae.material.set_shader_parameter("reduce_background", reduce_background)
	nebulae.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
	

#region Stars
func _create_stars_dust() -> void:
	stars_dust.visible = display_stars_dust
	
	if display_stars_dust:
		stars_dust.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
		stars_dust.material.set_shader_parameter("pixels", max(size.x, size.y))
		stars_dust.material.set_shader_parameter("uv_correct", aspect)
		stars_dust.material.set_shader_parameter("should_tile", tiled)
		stars_dust.material.set_shader_parameter("reduce_background", reduce_background)
		stars_dust.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)


func _create_stars() -> void:
	_set_owner_to_edited_scene_root(stars_container)
	remove_stars()
	
	if display_stars:
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
	background_star.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
	stars_container.add_child(background_star)
	star_objects.append(background_star)
	
	_set_owner_to_edited_scene_root(background_star)


func remove_stars() -> void:
	for star in stars_container.get_children():
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
	nebulae.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
	
#endregion

#region Planets
func _create_planets() -> void:
	_set_owner_to_edited_scene_root(planet_container)
	remove_planets()
	
	planet_container.visible = display_planets
	
	if display_planets:
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
	planet.material.set_shader_parameter("colorscheme", current_color_scheme.gradient)
	planet_container.add_child(planet)
	planet_objects.append(planet)
	
	_set_owner_to_edited_scene_root(planet)
	

func remove_planets() -> void:
	for planet in planet_container.get_children():
		planet.queue_free()
			
	planet_objects.clear()
#endregion


func toggle_nebulae() -> void:
	nebulae.visible = !nebulae.visible


func toggle_stars() -> void:
	stars_container.visible = !stars_container.visible


func toggle_stars_dust() -> void:
	stars_dust.visible = !stars_dust.visible


func toggle_planets() -> void:
	planet_container.visible = !planet_container.visible


func _calculate_aspect() -> Vector2:
	return Vector2(size.x / size.y, 1.0) if size.x > size.y else Vector2(1.0, size.x / size.y)


func _export_as_image() -> Error:
	await RenderingServer.frame_post_draw
	
	var viewport: Viewport = get_viewport()
	var space_background: Image = viewport.get_texture().get_image()
	
	var create_dir_error: Error = DirAccess.make_dir_recursive_absolute(export_path)
	
	if create_dir_error != OK:
		push_error("PixelSpaceBackgroundGenerator: Can't create directory '%s'. Error: %s" % [export_path, error_string(create_dir_error)])
		return create_dir_error
		
	var screenshot_save_error = space_background.save_png("%s/%s.png" % [export_path, Time.get_datetime_string_from_system().replace(":", "_")])
	
	if screenshot_save_error != OK:
		push_error("PixelSpaceBackgroundGenerator: Can't save screenshot image '%s'. Error: %s" % [export_path, error_string(screenshot_save_error)])
	
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		
	return screenshot_save_error


func _set_owner_to_edited_scene_root(node: Node) -> void:
	if Engine.is_editor_hint() and node.get_tree():
		node.owner = node.get_tree().edited_scene_root
	

func _on_tool_button_pressed(text: String) -> void:
	match text:
		"Export Background":
			_export_as_image()
		"Generate New":
			generate_new()


func on_resized() -> void:
	aspect = _calculate_aspect()
	
	stars_dust.material.set_shader_parameter("pixels", max(size.x, size.y))
	stars_dust.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("uv_correct", aspect)
