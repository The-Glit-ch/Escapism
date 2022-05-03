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

# Update
var prev_song : String

# Logic start
func _ready():
	add_child(_image_dl)
	
	# Connections
	Spotify.connect("return_data", self, "_spotify_return_data")
	_image_dl.connect("request_completed", self, "_image_downloaded")
	
	_prev_track.connect("pressed", self, "to_prev_song")
	_play_pause.connect("pressed", self, "pause_resume_song")
	_next_track.connect("pressed", self, "to_next_song")
	
	# Initial Request
	Spotify.request({"uri": "/me/player/currently-playing"})

# Custom Functions
func min_format(_ms : float):
	var _seconds = _ms / 1000
	if int(_seconds) / 60 < 10:
		return "0%s" % [int(_seconds) / 60]
	else:
		return int(_seconds) / 60
	
func sec_format(_ms : float):
	var _seconds = _ms / 1000
	if int(_seconds) % 60 < 10:
		return "0%s" % [int(_seconds) % 60]
	else:
		return int(_seconds) % 60

# Callbacks
func to_prev_song():
	pass

func pause_resume_song():
	pass

func to_next_song():
	pass

func _image_downloaded(result, response_code, headers, body):
	var image : Image = Image.new()
	var texture : ImageTexture = ImageTexture.new()
	
	var err = image.load_jpg_from_buffer(body)
	
	if err != OK:
		print("Error downloading image")
	
	yield(get_tree(),"idle_frame")
	texture.create_from_image(image, 0)
	_song_cover.texture = texture

func _spotify_return_data(_data : Dictionary):
	var endpoint = _data.endpoint
	var data = _data.data
	
	match endpoint:
		"/me/player/currently-playing":
			# Song Info Row
			var song_cover_data : String = data.item.album.images[1].url
			var song_title_data : String = data.item.name if data.item.name.length() < 22 else data.item.name.left(21) + "..."
			var song_artist_data : String = data.item.artists[0].name if data.item.artists[0].name.length() < 22 else data.item.artists[0].name.left(21) + "..."
			
			# Playback Info Row
			var current_ms_data : float = data.progress_ms
			var end_ms_data : float = data.item.duration_ms
			var progress_bar : float = current_ms_data / end_ms_data
			
			# Playback Options Row
			var isPlaying : bool = data.is_playing
			
			if prev_song != song_title_data:
				_image_dl.request(song_cover_data)
				_song_title.text = song_title_data
				_song_artist.text = song_artist_data
				
				prev_song = song_title_data

			_current_timestamp.text = "%s:%s" % [min_format(current_ms_data), sec_format(current_ms_data)]
			_end_timestamp.text = "%s:%s" % [min_format(end_ms_data), sec_format(end_ms_data)]
			_progress_bar.value = progress_bar
