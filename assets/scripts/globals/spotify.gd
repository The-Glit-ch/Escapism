extends Node

# Connection info
var server_ip : String = "127.0.0.1"
var server_port : String = "8080"
var endpoint_route = "http://%s:%s/endpoints?" % [server_ip, server_port]

# HTTP
var _http : HTTPRequest = HTTPRequest.new()

# Siganls
signal return_data

func _ready():
	add_child(_http)
	_http.connect("request_completed", self, "request_successful")


func request(data : Dictionary):
	var qs : HTTPClient = HTTPClient.new()
	_http.request(endpoint_route + qs.query_string_from_dict(data))


func request_successful(result, response_code, headers, body):
	if response_code == 0:
		emit_signal("return_data", {"endpoint": "self", "data": "server_offline"})
	else:
		var response : Dictionary = parse_json(body.get_string_from_utf8())
		
		emit_signal("return_data", response)
