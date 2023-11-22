extends Control

signal close(node:Node)

@onready var i18n = $Borders/Content/Panel/Borders/Settings/i18n/OptionButton

func _ready():
	for i in range(0, i18n.item_count):
		if (Settings.langs[GameState.settings.lang] == i18n.get_item_text(i)):
			i18n.select(i)

func _on_close():
	close.emit(self)

func _on_button_save_pressed():
	var item = i18n.get_item_text(i18n.selected)
	for lang in Settings.langs:
		if (Settings.langs[lang] == item):
			GameState.settings.lang = lang
			TranslationServer.set_locale(lang)
	_on_close()
