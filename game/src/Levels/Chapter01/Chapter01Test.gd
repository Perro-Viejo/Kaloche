extends Node2D
# ⠿⠿⠿⠿ Variables ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿

var _follow_b_tween: Tween

onready var _rocberto: Pickable = find_node('Rocberto')
onready var _fishes_cnt: Node2D = find_node('Fishes')

# ⠿⠿⠿⠿ Functions ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
func _ready() -> void:
	$ParallaxForeground/ParallaxTrees.show()
	
	for fish in _fishes_cnt.get_children():
		var tween := Tween.new()
		var follow: PathFollow2D = fish.get_node('PathFollow')
		var fish_anim: AnimatedSprite = follow.get_node('Fish')
		add_child(tween)

		tween.interpolate_property(
			follow, 'unit_offset',
			0, 1, 8,
			Tween.TRANS_SINE, Tween.EASE_OUT
		)
		tween.interpolate_property(
			fish_anim, 'self_modulate:a',
			1, 0, 1,
			Tween.TRANS_SINE, Tween.EASE_OUT,
			6
		)
		tween.start()


func _on_OverlayArea_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.play('idle')
#		$Player/Overlay.show()


func _on_OverlayArea_body_shape_exited(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.stop()
#		$Player/Overlay.hide()
