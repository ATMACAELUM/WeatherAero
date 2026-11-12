class_name WeatherManager
extends Node

const API_URL = "https://api.open-meteo.com/v1/forecast"
const WEATHER_CODES: Dictionary = {
	0: "Clear sky",
	1: "Mainly clear",
	2: "Partly cloudy",
	3: "Overcast",
	45: "Fog",
	48: "Depositing rime fog",
	51: "Light drizzle",
	53: "Moderate drizzle",
	55: "Dense drizzle",
	56: "Light freezing drizzle",
	57: "Dense freezing drizzle",
	61: "Slight rain",
	63: "Moderate rain",
	65: "Heavy rain",
	66: "Light freezing rain",
	67: "Heavy freezing rain",
	71: "Slight snowfall",
	73: "Moderate snowfall",
	75: "Heavy snowfall",
	77: "Snow grains",
	80: "Slight rain showers",
	81: "Moderate rain showers",
	82: "Violent rain showers",
	85: "Slight snow showers",
	86: "Heavy snow showers",
	95: "Thunderstorm",
	96: "Thunderstorm with slight hail",
	97: "Heavy thunderstorm",
	99: "Thunderstorm with heavy hail"
}

const MONTHS: Dictionary = {
		1: "January",
		2: "February",
		3: "March",
		4: "April",
		5: "May",
		6: "June",
		7: "July",
		8: "August",
		9: "September",
		10: "October",
		11: "November",
		12: "December"
	}

signal weather_updated

@onready var req: HTTPRequest = HTTPRequest.new()

var stored_weather

var params = {
	
}

func _ready() -> void:
	add_to_group("weather_manager")
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm == null: return
	lm.location_set.connect(get_weather)
	add_child(req)
	req.request_completed.connect(_on_req_complete)


func get_weather(lat, long):
	var lm = get_tree().get_first_node_in_group("location_manager") as LocationManager
	if lm == null: return
	params = {
		"latitude": lat,
		"longitude": long,
		"hourly": "temperature_2m,weather_code",
		}
	var url = API_URL
	url += "?"
	var c = 0
	for key in params.keys():
		url += key
		url += "="
		url += str(params.get(key))
		if c != params.size() - 1:
			url += "&"
		c+=1
	var res = req.request(url)


func _on_req_complete(result, response, h, b: PackedByteArray):
	var json = JSON.parse_string(b.get_string_from_utf8())
	stored_weather = json
	weather_updated.emit(json)
	
