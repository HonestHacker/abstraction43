extends Window

@export var list: ItemList

func show_savelist() -> void:
	list.clear()
	var files := SaveloadManager.get_savefile_list()
	for file in files:
		list.add_item(file)

func _ready() -> void:
	close_requested.connect(hide)
	show_savelist()


func _on_saves_item_activated(index: int) -> void:
	hide()
	$"..".load_game_pressed.emit(SaveloadManager.get_savefile_list()[index])


func _on_about_to_popup() -> void:
	show_savelist()
