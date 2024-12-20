extends Node

@onready var text_box_scene = preload("res://game/interactables/text_box.tscn")
var dialog_lines: Array[String] = []
var current_line_index = 0
var text_box: Node
var text_box_position: Vector2

var sfx: Array[AudioStream]

var is_dialog_active = false
var can_advance_line = false
var show_full_dialogue = false
signal dialog_finished

func start_dialogue(position: Vector2, lines: Array[String], full_dialogue: bool = false, speech_sfx: Array[AudioStream] = []):
	if is_dialog_active:
		return
	
	show_full_dialogue = full_dialogue
	dialog_lines = lines
	text_box_position = position
	sfx = speech_sfx
	_show_text_box()
	
	is_dialog_active = true

func end_dialogue():
	is_dialog_active = false
	current_line_index = 0
	dialog_finished.emit()
	text_box.queue_free()

func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.margin_container.global_position = text_box_position
	
	if show_full_dialogue:
		text_box.display_full_text(dialog_lines[current_line_index])
	else:
		text_box.display_text(dialog_lines[current_line_index], sfx)
	
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event):
	if (
		#TODO Should I have another keybinding for advancing dialog ?
		event.is_action_pressed('interact') &&
		is_dialog_active &&
		can_advance_line
	):
		current_line_index += 1
		
		if current_line_index >= dialog_lines.size():
			end_dialogue()
			return
			
		text_box.queue_free()
		_show_text_box()
