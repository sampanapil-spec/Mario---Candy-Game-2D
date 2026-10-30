class_name Ninja
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0
const MAX_JUMPS = 2
const MAX_DOUBLE_JUMPS = 2

var alive = true
var can_move = true
var jump_count = 0
var double_jump_charges = 0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var death_sound = $DeathSound

func _physics_process(delta):
	if !alive:
		return

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"
	else:
		jump_count = 0

	# Handle movement and idle animations
	if is_on_floor():
		if abs(velocity.x) > 1:
			animated_sprite_2d.animation = "running"
		else:
			animated_sprite_2d.animation = "idle"

	if can_move:
		# Jumping
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				jump_count = 1
				jump_sound.play()
			elif jump_count < MAX_JUMPS and double_jump_charges > 0:
				velocity.y = JUMP_VELOCITY
				jump_count += 1
				double_jump_charges -= 1
				jump_sound.play()

		# Horizontal movement
		var direction = Input.get_axis("left", "right")

		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Flip sprite
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true

	move_and_slide()

func die() -> void:
	if !alive:
		return

	alive = false
	death_sound.play()
	animated_sprite_2d.animation = "dying"
