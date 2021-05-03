# I didn't like any of the available popups #
# So i made my own one :P #
tool
extends PopupDialog
class_name YesPopupDialog

enum ALIGN {
	Left,
	Center,
	Right,
	Fill
}

enum VALIGN {
	Top,
	Center,
	Bottom,
	Fill
}

var LABEL_PATH = "text"

signal on_answer(did_answer_yes)

export(String, MULTILINE) var text   = ""            setget set_label_text
export(ALIGN)             var align  = ALIGN.Center  setget set_label_align
export(VALIGN)            var valign = VALIGN.Center setget set_label_valign
export(bool)              var hide_on_answer = true

func toggle_pop():
	visible = not visible

# Signals #
func _on_yes_pressed():
	emit_signal("on_answer", true)
	if hide_on_answer:
		visible = false

func _on_no_pressed():
	emit_signal("on_answer", false)
	if hide_on_answer:
		visible = false


# Setters #
func set_label_text(value:String):
	get_node(LABEL_PATH).text = value # Set Label
	text = value                      # Set Local Variable

func set_label_align(value:int):
	get_node(LABEL_PATH).align = value # Set Label
	align = value                      # Set Local Variable

func set_label_valign(value:int):
	get_node(LABEL_PATH).valign = value # Set Label
	valign = value                      # Set Local Variable







