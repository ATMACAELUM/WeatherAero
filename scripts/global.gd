class_name Global
extends Node

signal update

var carousel_enabled: bool = false:
	set(value):
		carousel_enabled = value
		update.emit()


func _ready() -> void:
	add_to_group("global")
