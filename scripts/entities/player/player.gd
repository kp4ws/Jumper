extends CharacterBody2D

#Player modifiers
@export var stats : PlayerStats
@onready var animation = %Animation
@onready var collision_shape = %Hitbox
#@onready var respawn_timer = %RespawnTimer

#State
var is_dead = false

func _ready():
	stats.entity_died.connect(_on_die)

func _on_die():
	is_dead = true
	collision_shape.queue_free()

func _physics_process(delta):
	#TODO player should still fall even if dead
	#Ignore player movement if not alive (gravity still applies)
	if is_dead:
		#move_and_slide()
		animation.stop()
		return
		
	move(delta)
	
func move(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += stats.gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.jump_velocity

	#Get input directions: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	#Flip the sprite
	if direction > 0:
		animation.flip_h = false
	elif direction < 0:
		animation.flip_h = true
	
	#Play animations
	if is_on_floor():
		if direction == 0:
			animation.play("idle")
		else:
			animation.play("run")
	else:
		animation.play("jump")
		
	#Apply movement
	if direction:
		velocity.x = direction * stats.speed
	else:
		velocity.x = move_toward(velocity.x, 0, stats.speed)

	move_and_slide()
