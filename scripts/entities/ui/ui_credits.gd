extends Control


@export_multiline var names : Array[String]
@export var text : RichTextLabel


# Fades a CanvasItem (Control, Sprite2D, etc.) from transparent to opaque
func fade_in(node: CanvasItem, duration: float = 0.5) -> Tween:
	node.modulate.a = 0.0  # Start fully transparent
	node.visible = true # Ensure node is visible
	
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

# Fades a CanvasItem from opaque to transparent, optionally hiding it afterward
func fade_out(node: CanvasItem, duration: float = 0.5, hide_on_complete: bool = true) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	
	if hide_on_complete:
		tween.tween_callback(func(): node.visible = false)
	
	return tween

func _on_visibility_changed() -> void:
	if visible:
		await get_tree().create_timer(5).timeout
		print_credits()

func print_credits():
	for x in names:
		text.text = x
		fade_in(text, 1.5)
		await get_tree().create_timer(4.5).timeout
		fade_out(text, 1.5)
		await text.visibility_changed
	await get_tree().create_timer(3).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
