extends Node2D

@export var sprite: Sprite2D

enum PlayerState {
	AWAITING_INPUT,
	MOVING,
}
var state = PlayerState.AWAITING_INPUT

var horizontal_movement_amount;
var vertical_movement_amount;

func _ready():
	horizontal_movement_amount = sprite.texture.get_width() / sprite.hframes
	vertical_movement_amount = sprite.texture.get_height() / sprite.vframes


func _process(_delta):
	if state == PlayerState.AWAITING_INPUT:
		var desired_position = position
		if Input.is_action_just_pressed("move-up"):
			desired_position.y -= vertical_movement_amount
		elif Input.is_action_just_pressed("move-down"):
			desired_position.y += vertical_movement_amount
		elif Input.is_action_just_pressed("move-left"):
			desired_position.x -= horizontal_movement_amount
		elif Input.is_action_just_pressed("move-right"):
			desired_position.x += horizontal_movement_amount
		
		if desired_position != position:
			attempt_move_to_position(desired_position)


func attempt_move_to_position(new_position: Vector2):
	if not can_move_to_position(new_position):
		return
	
	state = PlayerState.MOVING
	
	var move_tween := create_tween()
	move_tween.tween_property(self, "position", new_position, 0.2).set_trans(Tween.TRANS_LINEAR)
	move_tween.tween_callback(func(): state = PlayerState.AWAITING_INPUT)
	
	var hop_tween := create_tween()
	hop_tween.tween_property(sprite, "position", Vector2(0, -10), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	hop_tween.tween_property(sprite, "position", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


func can_move_to_position(desired_position: Vector2) -> bool:
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = desired_position
	parameters.collision_mask = 2
	
	var collision_results = get_world_2d().direct_space_state.intersect_point(parameters, 1)
	return collision_results.size() == 0
