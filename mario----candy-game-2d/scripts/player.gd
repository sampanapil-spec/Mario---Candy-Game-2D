class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const MAX_JUMPS = 1
const MAX_DOUBLE_JUMPS = 3

var alive = true
var can_move = true
var jump_count = 0
var can_double_jump = false
var double_jump_charges = 0  

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var death_sound = $DeathSound

func _physics_process(delta):
	if !alive:
		return

	# 1. Apply gravity & set jumping/falling animation
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"
	else:
		jump_count = 0

	# 2. Set ground animations (idle / running)
	if is_on_floor():
		if abs(velocity.x) > 1:
			animated_sprite_2d.animation = "running"
		else:
			animated_sprite_2d.animation = "idle"

	# 3. Handle Jump & Double Jump Inputs
	if can_move:
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				jump_count = 1
				jump_sound.play()
			elif jump_count < 2 and can_double_jump:
				velocity.y = JUMP_VELOCITY
				jump_count += 1
				can_double_jump = false
				jump_sound.play()

		# 4. Handle Horizontal Movement (Un-indented so it runs whenever `can_move` is true)
		var direction = Input.get_axis("left", "right")

		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# 5. Flip sprite facing direction
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true

	# 6. Apply Movement
	move_and_slide()

func die() -> void:
	if !alive:
		return	

	alive = false
	death_sound.play()
	animated_sprite_2d.animation = "dying"
