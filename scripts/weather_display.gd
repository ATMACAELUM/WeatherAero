class_name WeatherDisplay
extends Control


@export var search: LineEdit
@export var multi_location_container: Control

@export var city_name_label: Label
@export var country_name_label: Label
@export var todays_weather_label: Label
@export var settings_button: Button
@export var settings_display: Control
@export var weather_bubbles_display: Control
@export var weather_bubble_container: Control



func _ready() -> void:
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm:
		lm.multiple.connect(_on_multiple)
		lm.location_set.connect(_on_location_set)
	var wm = get_tree().get_first_node_in_group("weather_manager") as WeatherManager
	if wm:
		wm.weather_updated.connect(_on_weather_updated)
	search.text_submitted.connect(_on_search_submit)
	gui_input.connect(_on_gui_input)
	settings_button.pressed.connect(_on_settings_pressed)
	
	
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 or event.button_index == 2:
			_clear_multiple()
	
	
func _on_search_submit(txt: String):
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm == null: return
	txt = txt.replace(" ", "+")
	lm.get_search_location(txt)


func _clear_multiple():
	for each in multi_location_container.get_children():
		each.queue_free()


func _on_multiple(result):
	_clear_multiple()
	for each in result.get("results"):
		var btn = Button.new()
		if each.has("name"):
			btn.text = each.get("name")
		btn.text += " "
		if each.has("admin1"):
			btn.text += each.get("admin1")
		btn.text += " "
		if each.has("country_code"):
			btn.text += each.get("country_code")
		btn.pressed.connect(_on_search_selected.bind(each))
		multi_location_container.add_child(btn)


func _on_search_selected(res):
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm == null: return
	lm.get_selected_search(res)
		

func _on_location_set(lat, long):
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm == null: return
	city_name_label.text = lm.city +", " + lm.region
	country_name_label.text = lm.country


func _clear_weather_bubbles():
	for each in weather_bubble_container.get_children():
		each.queue_free()

func _on_weather_updated(weather):
	_clear_weather_bubbles()
	if weather == null or weather.is_empty(): return
	if weather.has("error"): return
	var time = weather.get("hourly").get("time")
	var temp = weather.get("hourly").get("temperature_2m")
	var codes = weather.get("hourly").get("weather_code")
	todays_weather_label.text = str(temp[0]) + "c"
	for i in range(time.size()):
		var bubble = load("res://weather_bubble.tscn").instantiate()
	
		weather_bubble_container.add_child(bubble)
		bubble.setup(time[i], temp[i], int(codes[i]))
		

func _on_settings_pressed():
	if settings_display.visible:
		weather_bubbles_display.visible = true
		settings_display.visible = false
	else:
		weather_bubbles_display.visible = false
		settings_display.visible = true
