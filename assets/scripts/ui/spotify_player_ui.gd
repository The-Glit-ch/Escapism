extends Control

# Spotify player UI code thing
# this may cause me pain

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

# HTTP
var _image_dl : HTTPRequest = HTTPRequest.new()

# Updater
var _prev_song
var _current_song
var _updater : Timer =  Timer.new()

func _ready():
	# Set up the image downloader
	add_child(_image_dl)
	_image_dl.connect("request_completed", self, "_image_downloaded")
	
	# Set up the updater
	add_child(_updater)
	_updater.connect("timeout", self, "_update")
	_updater.wait_time = 10
	
	# Spotify magic
	EmssClient.connect_to(EmssClient.Connection.SPOTIFY, self, "_spotify_return_data")
	
	# Initial request
	EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})

func _image_downloaded(res, code, headers, body):
	var _image : Image = Image.new()
	var _texture : ImageTexture = ImageTexture.new()
	var _err = _image.load_jpg_from_buffer(body)
		
	if _err != OK:
		print("ERR downloading image")
		
	_texture.create_from_image(_image)
	_song_cover.texture = _texture

func _update():
	EmssClient.request_spotify_data({"uri":"/me/player/currently-playing"})

func _spotify_return_data(data : Dictionary):
	# Start update timer
	_updater.start()
	
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
	
	# Start showing that info
	
	#Song info row
	if _current_song != _prev_song:
		_prev_song = _current_song
		_image_dl.request(_song_cover_data)
		_song_title.text = _song_title_data if _song_title_data.length() < 26 else _song_title_data.left(25) + "..."
		_song_artist.text = _song_artist_data
	
	# Playback info row
	
	# This is just pain
	var _current_secs = floor(_current_timestamp_data / 1000)
	var _end_secs = floor(_end_timestamp_data / 1000)
	
	var _cm
	var _cs
	
	var _em
	var _es
	
	if int(_current_secs) / 60 < 10:
		_cm = "0%s" % [int(_current_secs) / 60]
	else:
		_cm = int(_current_secs) / 60
	
	if int(_current_secs) % 60 < 10:
		_cs = "0%s" % [int(_current_secs) % 60]
	else:
		_cs = int(_current_secs) % 60

	if int(_end_secs) / 60 < 10:
		_em = "0%s" % [int(_end_secs) / 60]
	else:
		_em = int(_end_secs) / 60
	
	if int(_end_secs) % 60 < 10:
		_es = "0%s" % [int(_end_secs) % 60]
	else:
		_es = int(_end_secs) % 60
	
	_current_timestamp.text = "%s:%s" % [_cm, _cs]
	_end_timestamp.text = "%s:%s" % [_em, _es]
	_progress_bar.value = _progress_bar_pos
