extends PlayerState

@export var hurt_time = 0.5
var sprite_flip: bool = false
var knockback_direction: int = 1

func _ready():
	super()
	await owner.ready
	player.health_component.entity_damaged.connect(_connect_damage_transition)

func _connect_damage_transition(attacker):
	if %StateMachine.state.name == HURT:
		#Hurt is already active state so return
		return
	
	var direction = player.global_position.direction_to(attacker.global_position)
	if direction.x > 0:
		knockback_direction = 1
	else:
		knockback_direction = -1
	
	#in this case, the hurt state is transitioning to itself from other active state
	finished.emit(HURT)

func enter(_previous_state_path: String, _data := {}) -> void:
	player.velocity = Vector2(-player.modifiers.knockback_strength.x * knockback_direction, -player.modifiers.knockback_strength.y)
	player.animated_sprite.play('hurt')
	sprite_flip = player.animated_sprite.flip_h
	await get_tree().create_timer(hurt_time).timeout
	_on_hurt_timer_timeout()
	
func physics_update(delta: float) -> void:
	var input_direction_x := Input.get_axis("move_left", "move_right")
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.08)
	player.velocity.y += player.modifiers.gravity * delta
	player.move_and_slide()
	
func _on_hurt_timer_timeout():
	if not player.is_on_floor():
		finished.emit(FALL)
	#elif Input.is_action_just_pressed("jump"):
		#finished.emit(JUMP)
	elif is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
	else:
		finished.emit(RUN)
