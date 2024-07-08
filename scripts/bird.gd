extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const FLAP_SPEED : int = -600
const GRAVITY : int = 2500
const MAX_VELOCITY : int = 600
const START_POS = Vector2(100,400)

var flying : bool = false
var falling : bool = false

func _ready() -> void:
	reset()

func reset() -> void:
	falling = false
	flying = false
	position = START_POS
	set_rotation_degrees(0)

func _physics_process(delta) -> void:
	
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		if velocity.y > MAX_VELOCITY:
			velocity.y = MAX_VELOCITY

		if flying:
			set_rotation_degrees(velocity.y * 0.02)
			animated_sprite_2d.play("flap")
		elif falling:
			set_rotation_degrees(90)
			animated_sprite_2d.stop()
		
		move_and_collide(velocity * delta)
	else:
		animated_sprite_2d.stop()

func flap():
	velocity.y = FLAP_SPEED
