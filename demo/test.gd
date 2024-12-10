extends Control

@onready var pixel_space_background_generator: PixelSpaceBackgroundGenerator = $PixelSpaceBackgroundGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pixel_space_background_generator.generate_new()
