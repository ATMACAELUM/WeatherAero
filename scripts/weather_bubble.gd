class_name WeatherBubble
extends Button

@export var time_label: Label
@export var temp_label: Label
@export var year_label: Label
@export var month_label: Label
@export var day_label: Label
@export var weather_label: Label

var _time
var _temp
var _weather

func setup(time, temp, weather):
	_time = time
	_temp = temp
	_weather = weather
	var wm = get_tree().get_first_node_in_group("weather_manager") as WeatherManager
	if wm == null: return
	var new_d = Time.get_datetime_dict_from_datetime_string(time + ":00", true)

	year_label.text = str(new_d.get("year"))
	time_label.text = str(new_d.get("hour")) + ":" + str(new_d.get("minute"))
	day_label.text = str(new_d.get("day"))
	month_label.text = str(wm.MONTHS.get(new_d.get("month")))
	temp_label.text = str(temp) + "c"
	weather_label.text = str(wm.WEATHER_CODES.get(weather))
