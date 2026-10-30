extends Node2D

var level: int = 1
var score: int = 0
var current_level_root: Node = null

@onready var music_sound = $MusicSound
@onready var score_label = $HUD/ScorePanel/ScoreLabel
@onready var fade = $CanvasLayer/fade

func play_sound():
	music_sound.play()

func _ready() -> void:
	# setup the level
	fade.modulate.a = 1.0 # set at _ready()
	current_level_root = get_node("LevelRoot")
	await _load_level(level, true, false)

# ---------------
# LEVEL MAGENMENT
# ---------------

func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:
	# fade out
	if not first_load:
		await _fade(1.0)
	
	if reset_score:
		score = 0
		score_label.text = "SCORE: 0"
	
	if current_level_root:
		current_level_root.queue_free()
		
	# change level
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	
	# fade in
	await _fade(0.0)

func _setup_level(level_root: Node) -> void:
	# connect exit
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	# connect apples
	var apples = level_root.get_node_or_null("Apples")
	if apples:
		for apple in apples.get_children():
			apple.collected.connect(increase_score)
	
	# connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
	
	# connect spike
	var spikes = level_root.get_node_or_null("Spikes")
	if spikes:
		for spike in spikes.get_children():
			spike.player_died.connect(_on_player_died)
	
	var player = level_root.get_node_or_null("Player")
	if player == null:
		player = level_root.get_node_or_null("Ninja")
	if player == null:
		player = level_root.get_node_or_null("Cyborg")

	if player:
		player.double_jump_charges = 0

#----------------
# SIGNAL HANDLERS
#-----------------

func _on_exit_body_entered(body: Node2D) -> void:
	if body is Player or body is Ninja and body.alive:
		level += 1
		body.can_move = false
		await _load_level(level, false, false)

func _on_player_died(body):
	body.die()
	await _load_level(level, false, true)

#----------------
# SCORE 
#-----------------

func increase_score():
	score += 1
	score_label.text = "SCORE: %s" % score

	var player = current_level_root.get_node_or_null("Player")
	if player == null:
		player = current_level_root.get_node_or_null("Ninja")
	if player == null:
		player = current_level_root.get_node_or_null("Cyborg")

	if player and player.double_jump_charges < player.MAX_DOUBLE_JUMPS:
		player.double_jump_charges += 1

#----------------
# FADE
#-----------------

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished 
