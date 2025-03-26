extends Node2D

##################################################
const RAINDROP: PackedScene = preload("res://scenes/raindrop/raindrop.tscn")
# 씬을 미리 로드

const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
# 화면 크기 설정

var drop_timer_node: Timer
# 빗방울을 떨어뜨리는 타이머 노드 변수

##################################################
func _ready() -> void:
	drop_timer_node = $DropTimer
	# 타이머 노드 설정
	drop_timer_node.wait_time = 0.1
	# 타이머의 대기 시간을 0.1초로 설정
	drop_timer_node.one_shot = true
	# 타이머를 한 번만 실행하도록 설정
	drop_timer_node.connect("timeout", Callable(self, "_on_drop_timer_timeout"))
	# 타이머의 "timeout" 신호가 발생했을 때 "_on_drop_timer_timeout" 함수가 호출되도록 연결
	drop_timer_node.start()
	# 타이머를 시작하여 빗방울을 생성
	

##################################################
func _on_drop_timer_timeout() -> void:
# 타이머가 만료되면 호출되는 함수
	var raindrop_instance = RAINDROP.instantiate()
	# 미리 로드된 빗방울 씬을 인스턴스화
	raindrop_instance.gravity_scale = 2.0
	# 빗방울에 중력 효과를 두 배로 설정
	raindrop_instance.global_position = Vector2(randf_range(0.0, SCREEN_SIZE.x), -10.0)
	# 빗방울의 초기 위치를 설정
	add_child(raindrop_instance)
	# 생성된 빗방울 객체를 현재 노드에 자식으로 추가하여 화면에 표시
	drop_timer_node.start()
	# 타이머를 다시 시작하여 지속적으로 빗방울을 생성하도록 설정
