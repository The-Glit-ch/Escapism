extends Control

# Spotify player UI code thing
# this may cause me pain

# Mini UI's
onready var _music_player_ui : Control = $MusicPlayer
onready var _server_offline_ui : Control = $ServerOffline

# MusicPlayer/SongInfoRow/*
onready var _song_cover : TextureRect = $MusicPlayer/SongInfoRow/SongCover
onready var _song_title : Label = $MusicPlayer/SongInfoRow/TextInfo/Title
onready var _song_artist : Label = $MusicPlayer/SongInfoRow/TextInfo/Artist

# MusicPlayer/PlaybackInfoRow/*
onready var _current_timestamp : Label = $MusicPlayer/PlaybackInfoRow/CurrentTimeStamp
onready var _progress_bar : ProgressBar = $MusicPlayer/PlaybackInfoRow/ProgressBar
onready var _end_timestamp : Label = $MusicPlayer/PlaybackInfoRow/EndtimeStamp

# MusicPlayer/PlaybackOptionsRow/*
onready var _prev_track : TextureButton = $MusicPlayer/PlaybackOptionsRow/PrevTrack
onready var _play_pause : TextureButton = $MusicPlayer/PlaybackOptionsRow/PlayPause
onready var _next_track : TextureButton = $MusicPlayer/PlaybackOptionsRow/NextTrack

# ServerOffline/InfoContainer/*
onready var _retry_btn : Button = $ServerOffline/InfoContainer/RetryConnection

# HTTP
var _image_dl : HTTPRequest = HTTPRequest.new()

# Song data
var _prev_song
var _current_song
var _end_ms
var isPlaying : bool setget _update_playing_state

# Updater
var _count : int = 0
var _updater : Timer =  Timer.new()

func _ready():
	# Set up the image downloader
	add_child(_image_dl)
	_image_dl.connect("request_completed", self, "_image_downloaded")
	
	# Set up the updater
	add_child(_updater)
	_updater.connect("timeout", self, "_update_time_data")
	_updater.wait_time = 3
	
	# Connect the buttons
	_prev_track.connect("pressed", self, "_goto_prev_track")
	_play_pause.connect("pressed", self, "_play_pause_track")
	_next_track.connect("pressed", self, "_goto_next_track")
	_retry_btn.connect("pressed", self, "_retry_server_connection")
	
	# Spotify magic
	EmssClient.connect_to(EmssClient.Connection.SPOTIFY, self, "_spotify_return_data")
	EmssClient.connect_to(EmssClient.Connection.SERVER_EVENT, self, "_emss_server_event")
	
	# Initial request
	_spotify_request({"uri":"/me/player/currently-playing"})
	
# Connections
func _image_downloaded(res, code, headers, body):
	var _image : Image = Image.new()
	var _texture : ImageTexture = ImageTexture.new()
	var _err = _image.load_jpg_from_buffer(body)

	if _err != OK:
		print("Error downloading image")

	yield(get_tree(),"idle_frame")
	_texture.create_from_image(_image, 0)
	_song_cover.texture = _texture

func _goto_next_track():
	EmssClient.request_spotify_data({"uri":"/me/player/next"})

func _play_pause_track():
	if isPlaying:
		EmssClient.request_spotify_data({"uri":"/me/player/pause"})
		_updater.stop()
		_update_playing_state(false)
	else:
		EmssClient.request_spotify_data({"uri":"/me/player/play"})
		_updater.start()
		_update_playing_state(true)

func _goto_prev_track():
	EmssClient.request_spotify_data({"uri":"/me/player/previous"})

func _retry_server_connection():
	EmssClient._http.request(EmssClient.base_uri)

func _update_time_data():
	if _count >= 4:
		_count = 0
		EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})
	else:
		_count += 1
	
	var _current_time_seconds = floor((_progress_bar.value * _end_ms) / 1000)
	var _new_time_seconds = floor(_current_time_seconds + 3)
	
	_progress_bar.value = (_new_time_seconds * 1000) / _end_ms
	_current_timestamp.text = "%s:%s" % [min_format(_new_time_seconds), sec_format(_new_time_seconds)]

# Custom Functions
func min_format(_seconds : float):
	if int(_seconds) / 60 < 10:
		return "0%s" % [int(_seconds) / 60]
	else:
		return int(_seconds) / 60
	
func sec_format(_seconds : float):
	if int(_seconds) % 60 < 10:
		return "0%s" % [int(_seconds) % 60]
	else:
		return int(_seconds) % 60

func _spotify_request(data : Dictionary):
	if EmssClient.isOnline:
		EmssClient.request_spotify_data(data)

# Setget
func _update_playing_state(value : bool):
	isPlaying = value
	
	var _image_pause = preload("res://assets/textures/ui/pause.png")
	var _image_play = preload("res://assets/textures/ui/right.png")
	
	match isPlaying:
		true:
			_play_pause.texture_normal = _image_pause
			_play_pause.texture_pressed = _image_pause
			_play_pause.texture_hover = _image_pause
		false:
			_play_pause.texture_normal = _image_play
			_play_pause.texture_pressed = _image_play
			_play_pause.texture_hover = _image_play

# Emss connections
func _emss_server_event(server_status : Dictionary):
	if server_status.isOnline == true:
		_spotify_request({"uri":"/me/player/currently-playing"})
		_music_player_ui.visible = true
		_server_offline_ui.visible = false
	else:
		_music_player_ui.visible = false
		_server_offline_ui.visible = true

func _spotify_return_data(endpoint : String, data : Dictionary):
	match endpoint:
		"/me/player/currently-playing":
			# Start update timer
			_updater.start()
			
			# Updating if the song is playing
			_update_playing_state(data.is_playing)
				
			# JSON Shortcuts
			var _album_data = data.item.album
			
			# Get important info
			# Song info row
			var _song_cover_data = _album_data.images[1].url
			var _song_title_data = data.item.name
			var _song_artist_data = _album_data.artists[0].name
			
			# Playback info row
			var _current_timestamp_data = data.progress_ms
			var _end_timestamp_data = data.item.duration_ms
			var _progress_bar_pos = (_current_timestamp_data / _end_timestamp_data)
			
			_current_song = _song_title_data
			
			#Song info row
			if _current_song != _prev_song:
				_prev_song = _current_song
				_image_dl.request(_song_cover_data)
				_song_title.text = _song_title_data if _song_title_data.length() < 26 else _song_title_data.left(25) + "..."
				_song_artist.text = _song_artist_data if _song_artist_data.length() < 26 else _song_artist_data.left(25) + "..."
			
			# Playback info row
			_end_ms = _end_timestamp_data
			
			var _current_seconds = floor(_current_timestamp_data / 1000)
			var _end_seconds = floor(_end_timestamp_data / 1000)
			
			_current_timestamp.text = "%s:%s" % [min_format(_current_seconds), sec_format(_current_seconds)]
			_end_timestamp.text = "%s:%s" % [min_format(_end_seconds), sec_format(_end_seconds)]
			_progress_bar.value = _progress_bar_pos
		"/me/player/next":
			EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})
		"/me/player/previous":
			EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})
		"/me/player/pause":
			EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})
		"/me/player/play":
			EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})
