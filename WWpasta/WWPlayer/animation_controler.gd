extends Node2D


@export var animation_tree: AnimationTree
@onready var player: PlayerCharacter = get_owner()

var last_facing_direction: Vector2 = Vector2(0,-1)

func _ready() -> void:
	animation_tree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var idle = !player.velocity
	if !idle:
		last_facing_direction = player.velocity.normalized()
	
	animation_tree.set("parameters/Walk/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/IdleHold/blend_position", last_facing_direction)
	animation_tree.set("parameters/WalkHold/blend_position", last_facing_direction)
