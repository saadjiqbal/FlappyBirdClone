extends Node

@onready var bird = $Bird
@onready var death_sound = $DeathSound
@onready var fall_sound = $FallSound
@onready var flap_sound = $FlapSound
@onready var game_over_canvas = $GameOver
@onready var ground = $Ground
@onready var input_timer = $InputTimer
@onready var score_label = $ScoreLabel
@onready var score_sound = $ScoreSound
@onready var pipe_timer = $PipeTimer

@export var pipe_scene : PackedScene

const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200
const SCROLL_SPEED : int = 2

var death_sound_played : bool
var fall_sound_played : bool
var game_running : bool
var game_over : bool
var ground_height : int
var pipes : Array
var screen_size : Vector2i
var scroll
var score

func _ready():
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game() -> void:
	death_sound_played = false
	fall_sound_played = false
	game_running = false
	game_over = false
	scroll = 0
	score = 0
	
	get_tree().call_group("Pipes", "queue_free")
	pipes.clear()
	
	score_label.text = str(score)
	
	game_over_canvas.hide()
	generate_pipes()
	
	bird.reset()

func start_game():
	game_running = true
	bird.flying = true
	bird.flap()
	pipe_timer.start()

func stop_game():
	pipe_timer.stop()
	game_over_canvas.show()
	bird.flying = false
	game_running = false
	game_over = true

func _process(delta):
	if game_over == false:
		if Input.is_action_just_pressed("flap"):
			if game_running == false:
				start_game()
			else:
				if bird.flying:
					bird.flap()
					flap_sound.play()
					check_top()
		
	if game_running:  
		scroll += SCROLL_SPEED
		
		if scroll >= screen_size.x:
			scroll = 0
		
		ground.position.x = -scroll
		
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.score.connect(score_increase)
	add_child(pipe)
	pipes.append(pipe)

func check_top():
	if bird.position.y < 0:
		if !death_sound_played:
			death_sound.play()
			death_sound_played = true
		bird.falling = true
		stop_game()

func bird_hit():
	if !death_sound_played:
		death_sound.play()
		death_sound_played = true

	bird.falling = true

	if bird.falling && !fall_sound_played:
		fall_sound.play()
		fall_sound_played = true

	stop_game()

func score_increase():
	score_sound.play()
	score += 1
	score_label.text = str(score)

func _on_ground_hit():
	if !death_sound_played:
		death_sound.play()
		death_sound_played = true
	bird.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()
