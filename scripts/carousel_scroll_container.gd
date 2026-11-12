
class_name CarouselScrollContainer
extends ScrollContainer


@export var selected_scale: float = 1.5
@export var normal_scale: float = 1.0
@export var scale_distance: float = 200.0
@export var enabled: bool = false

func _ready() -> void:
	get_h_scroll_bar().value_changed.connect(_on_scroll)
	_on_scroll()


func _on_scroll(_value: float = 0.0) -> void:
	if enabled == false: return
	var container_center: float = global_position.x + size.x / 2.0

	for each in get_child(0).get_children():
		var item_center: float = each.global_position.x + each.size.x / 2.0
		var distance: float = abs(item_center - container_center)
		var weight: float = clampf(1.0 - distance / scale_distance, 0.0, 1.0)
		var scale_amount: float = lerpf(normal_scale, selected_scale, weight)

		each.offset_transform_scale = Vector2.ONE * scale_amount
		if each.offset_transform_scale != Vector2(1, 1):
			each.z_index = 10
		else:
			each.z_index = 0
