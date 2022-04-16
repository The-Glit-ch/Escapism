extends Node

# Communicates with the Escapism Microservices Server via HTTPRequests

# Connection settings
var ip : String = "10.205.1.102" # Default
var port : String = "8080" # Default

# Base URI's
var base_uri : String = "http://%s:%s" % [ip, port]
var base_spotify_uri : String = base_uri + "/spotify"

# HTTP
var _http : HTTPRequest = HTTPRequest.new()

# Enums
enum Connection {SPOTIFY, YOUTUBE}

# If server errors out we can just send the prev data again
var _prev_request_name : String
var _prev_request_data : Dictionary

# Signals
signal spotify_return_data

func _ready():
	add_child(_http)
	
	# Connections
	_http.connect("request_completed", self, "_request_complete")
	
func request_spotify_data(query_string : Dictionary):
	_set_prev_data("spotify", query_string)
	_http.request(
		base_spotify_uri + "/endpoints?" +
		HTTPClient.new().query_string_from_dict(query_string)
	)

func connect_to(signal_name : int, object : Node, callback : String):
	match signal_name:
		Connection.SPOTIFY:
			connect("spotify_return_data", object, callback)

func _set_prev_data(name : String, data : Dictionary):
	_prev_request_name = name
	_prev_request_data = data

func _request_complete(result, response_code, headers, body):
	var response : Dictionary = parse_json(body.get_string_from_utf8())

	# Instead of mass emititng a bunch of signals we just check from which microservice
	# we got the data from and then emit the callback signal for that microservice
	match response.from:
		"spotify":
			if response.data != null:
				emit_signal("spotify_return_data", response.endpoint, response.data)
