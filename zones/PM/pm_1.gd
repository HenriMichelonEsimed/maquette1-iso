extends Zone

func _on_orange_button_using(_is_used):
	$Stair/DistantDoor.use()

func _on_orange_button_2_using(_is_used):
	GameState.events_queue.postEvent("pm_pm_2", "DistantDoor", "use")
