extends Zone

func check_quest_advance():
	if GameState.main_quest.current.key > "QAMain0" and $AccessCard1 != null:
		$AccessCard1.visible = true
