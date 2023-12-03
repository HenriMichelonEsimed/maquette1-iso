extends ItemQuest

func collect():
	$"../AdminWoman1".interact($"../AdminWoman1".ring_discussion(self))
	return false
