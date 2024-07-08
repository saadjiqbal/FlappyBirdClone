extends Area2D

signal hit
signal score

func _on_body_entered(_body):
	hit.emit()

func _on_score_area_body_entered(_body):
	score.emit()
