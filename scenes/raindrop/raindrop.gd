extends RigidBody2D

func _process(delta: float) -> void:
	var water = get_node("/root/Main/Water")
	# Water 노드를 찾아 설정
	var index = water.get_closest_point_index(global_position.x)
	# 가장 가까운 포인트 인덱스를 얻음
	if global_position.y >= water.get_point_y_position(index):
	# 물 표면보다 현재 객체가 아래에 있으면
		water.splash_point(index, linear_velocity.y)
		# 물 표면에 튕겨서 영향을 미치는 값을 물 표면으로 전파
		queue_free()
		# 현재 객체 삭제
