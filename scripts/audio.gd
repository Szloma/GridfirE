extends Node

signal track_ended
# Code adapted from KidsCanCode

var music_volume = -10

var num_players = 12
var bus = "master"
var bus_music = "music"
var music_player : AudioStreamPlayer
var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		
		available.append(p)
		
		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus
	#music
	var p = AudioStreamPlayer.new()
	p.finished.connect(_on_music_finished)
	add_child(p)
	p.volume_db = music_volume
	music_player= p

func set_sfx_volume(value):
	for i in available:
		i.volume_db = value
		
	for i in queue:
		i.volume_db = value

func set_music_volume(value):
	music_player.volume_db=value
	pass

func _on_music_finished():
	track_ended.emit()
func _on_stream_finished(stream): available.append(stream)

func play(sound_path): queue.append(sound_path)

func play_music(sound_path):

	music_player.stream=load(sound_path)
	music_player.play()
func stop_music():
	music_player.stop()

func _process(_delta):

	if not queue.is_empty() and not available.is_empty():
		
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)
		
		available.pop_front()
