extends ItemQuest

func collect():
	$"../AdminWoman1".ring_action()
	$"../AdminWoman1".interact()
	return false
