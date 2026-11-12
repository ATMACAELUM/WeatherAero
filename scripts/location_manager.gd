class_name LocationManager
extends Node

signal location_set(lat, long)
signal multiple(dictionary)

const LOAD_URL = "https://ipwho.is/"
const SEARCH_URL = "https://geocoding-api.open-meteo.com/v1/search?name="
const SEARCH_URL_END = "&count=10&language=en&format=json"

@onready var req: HTTPRequest = HTTPRequest.new()

var continent
var continent_code
var postal
var country
var region
var region_code
var city
var country_code
var longitude
var latitude


func _ready() -> void:
	add_to_group("location_manager")
	add_child(req)
	req.request_completed.connect(_on_req_complete)
	get_load_location()


func reset():
	continent = ""
	continent_code = ""
	postal = ""
	country = ""
	region = ""
	region_code = ""
	city = ""
	country_code = ""
	longitude = ""
	latitude = ""

func get_search_location(search):
	var res = req.request(SEARCH_URL + str(search).capitalize() + SEARCH_URL_END)
	
func get_selected_search(search):
	reset()
	if search.has("latitude"):
		latitude = search.get("latitude")
	if search.has("longitude"):
		longitude = search.get("longitude")
	if search.get("country_code"):
		country_code = search.get("country_code")
	if search.get("country"):
		country = search.get("country")
	if search.get("admin1"):
		region = search.get("admin1")
	if search.get("name"):
		city = search.get("name")
	if search.get("postcodes"):
		postal = search.get("postcodes")[0]
	location_set.emit(latitude, longitude)

# Gets the users current location with their IP
func get_load_location():
	var res = req.request(LOAD_URL)



func _on_req_complete(r, rc, h, b: PackedByteArray):
	var parsed = JSON.parse_string(b.get_string_from_utf8())
	if parsed == null: return
	if parsed.has("results"):
		multiple.emit(parsed)
		return
	if parsed.has("continent"):
		continent = parsed.get("continent")
	if parsed.has("continent_code"):
		continent_code = parsed.get("continent_code")
	if parsed.has("country"):
		country = parsed.get("country")
	if parsed.has("country_code"):
		country_code = parsed.get("country_code")
	if parsed.has("region"):
		region = parsed.get("region")
	if parsed.has("region_code"):
		region_code = parsed.get("region_code")
	if parsed.has("city"):
		city = parsed.get("city")
	if parsed.has("postal"):
		postal = parsed.get("postal")
	if parsed.has("latitude"):
		latitude = parsed.get("latitude")
	if parsed.has("longitude"):
		longitude = parsed.get("longitude")
	location_set.emit(latitude, longitude)
