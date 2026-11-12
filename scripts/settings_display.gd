class_name SettingsDisplay
extends Control


@export var enable_carousel_button: CheckButton 

func _ready() -> void:
	enable_carousel_button.pressed.connect(_on_carousel_pressed)
	var gl = get_tree().get_first_node_in_group("global") as Global
	gl.update.connect(_on_update)
	_on_update()
	
	
	
	
func _on_update():
	var gl = get_tree().get_first_node_in_group("global") as Global
	if gl == null: return
	
	enable_carousel_button.button_pressed = gl.carousel_enabled
	
	

func _on_carousel_pressed():
	var gl = get_tree().get_first_node_in_group("global") as Global
	if gl == null: return
	gl.carousel_enabled = enable_carousel_button.button_pressed
