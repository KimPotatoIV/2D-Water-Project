extends Node2D

##################################################
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
# 화면 크기
const POINT_COUNT: int = 192
# 물 표면을 그리기 위한 Line2D의 포인트 개수
const BASE_Y_POSITION: float = 880.0
# 물 표면의 기준 높이 설정. 물 표면이 기본적으로 이 위치에 고정되도록 함
const RESTORE_FORCE: float = 50.0
# 물 표면 기준으로 포인트들이 움직이도록 하는 힘의 크기 
# 이 값이 크면 물 표면을 향해 빨리 복원되며, 작으면 천천히 복원됨
const DAMPING: float = 0.98
# 물 표면의 파동이 점점 감쇠되는 정도를 설정하는 값
# 1에 가까우면 감쇠가 거의 없고, 0에 가까우면 빨리 멈춤
const SPREAD: float = 0.1
# 물결이 퍼지는 정도
# 이 값이 크면 물결이 더 넓게 퍼지고, 작으면 좁게 퍼짐

var line_node: Line2D
# 물 표면을 그릴 노드
# 각 물점의 위치를 연결하여 물 표면을 그리는 데 사용
var polygon_node: Polygon2D
# 물 표면 아래로 확장되는 색깔을 칠할 노드

var water_points_y_position: Array = []
# 물 표면을 구성하는 각 포인트의 y좌표를 저장하는 배열
var water_points_velocity: Array = []
# 각 물 포인트에 대한 속도를 저장하는 배열
# 물 표면의 변화를 시뮬레이션

##################################################
func _ready() -> void:
	line_node = $Line2D
	polygon_node = $Polygon2D
	# 각 노드 설정
	
	for i in range(POINT_COUNT):
		water_points_y_position.append(BASE_Y_POSITION)
		water_points_velocity.append(0)
	# 물 표면을 구성하는 각 포인트들의 초기 상태 설정

##################################################
func _process(delta: float) -> void:
	apply_points_physics(delta)
	# 물 포인트들의 물리적 상태를 업데이트하는 함수 호출
	draw_water()
	# 물을 그리는 함수 호출

##################################################
func apply_points_physics(delta) -> void:
# 물 포인트들의 물리적 변화를 계산하는 함수
	for i in range(POINT_COUNT):
		water_points_y_position[i] += water_points_velocity[i] * delta
		# 물 포인트의 현재 y좌표는 속도에 비례하여 이동하도록 설정
		
		var force = (BASE_Y_POSITION - water_points_y_position[i]) * RESTORE_FORCE
		# 물 표면을 향한 복원력 계산
		# 물 포인트가 BASE_Y_POSITION을 향하도록 하는 힘을 계산
		# 이 힘이 클수록 물 포인트가 빠르게 원위치로 돌아감
		water_points_velocity[i] += force * delta
		# 힘을 속도에 추가하여 물 포인트가 복원되도록 함
		
		water_points_velocity[i] *= DAMPING
		# 속도에 감쇠를 적용하여 물 표면의 진동이 점점 약해짐
		# 물 표면이 계속해서 진동하는데, DAMPING을 곱하여 시간이 지나면서 점차 진동이 약해짐
	
	var new_positions: Array = water_points_y_position.duplicate()
	# 물 포인트들의 상호작용을 계산하기 위해 복사본을 만들어 처리
	# 물 포인트들의 새로운 y좌표를 계산할 복사본 생성
	for i in range(1, POINT_COUNT - 1):
	# 각 물 포인트의 양 옆 포인트들과의 높이 차이를 이용하여 물결이 퍼지도록 만듦
	# 양 끝 포인트는 상호작용할 이웃이 없으므로 첫 번째와 마지막 포인트는 제외
		new_positions[i] += \
		(water_points_y_position[i - 1] - water_points_y_position[i]) * SPREAD
		# 왼쪽 포인트와의 차이를 기반으로 물결을 왼쪽으로 퍼지게 함
		new_positions[i] += \
		(water_points_y_position[i + 1] - water_points_y_position[i]) * SPREAD
		# 오른쪽 포인트와의 차이를 기반으로 물결을 왼쪽으로 퍼지게 함
	
	for i in range(1, POINT_COUNT - 1):
		water_points_y_position[i] = new_positions[i]
	# 업데이트된 위치를 실제 물 포인트 배열에 반영
	# 양 끝 포인트를 제외하고 새 위치 값으로 업데이트

##################################################
func draw_water() -> void:
# 물 표면을 그리는 함수
	var points: PackedVector2Array = PackedVector2Array()
	# 물 표면의 각 포인트들을 저장할 배열 생성
	var segment_width: float = SCREEN_SIZE.x / (POINT_COUNT - 1)
	# 화면 너비를 물 표면을 그릴 포인트 개수로 나누어 각 포인트 간의 간격 계산
	
	for i in range(POINT_COUNT):
		points.append(Vector2(i * segment_width, water_points_y_position[i]))
		# 각 물 포인트들의 위치를 포인트 배열에 추가
	
	line_node.points = points
	# 물 표면을 그리기 위한 포인트들 적용
	line_node.width = 4.0
	# 물 표면의 두께 설정
	line_node.default_color = Color(0, 0.5, 1, 1)
	# 물 표면의 색상 설정
	
	points.append(SCREEN_SIZE)
	points.append(Vector2(0.0, SCREEN_SIZE.y))
	# 우하단, 좌하단 포인트를 추가
	# 폴리곤 다각형을 완성하기 위함
	
	polygon_node.polygon = points
	# 물 표면 아래를 그리기 위한 포인트들 적용
	polygon_node.color = Color(0, 1, 1, 0.25)
	# 물 표면 아래의 색상 설정

##################################################
func get_closest_point_index(x_position_value: float) -> int:
# 주어진 x좌표에 대해 가장 가까운 물 포인트의 인덱스를 반환하는 함수
	var segment_width: float = SCREEN_SIZE.x / (POINT_COUNT - 1)
	# 화면의 가로 크기에서 물 표면을 그릴 포인트 개수를 나눠서 각 포인트의 간격을 계산
	return round(x_position_value / segment_width)
	# 주어진 x좌표에 대해 가장 가까운 인덱스를 반환
	# round()는 주어진 숫자를 가장 가까운 정수로 반올림하는 함수

##################################################
func get_point_y_position(index_value: int) -> float:
# 주어진 인덱스에 해당하는 물 포인트의 y좌표를 반환하는 함수
	return water_points_y_position[index_value]
	# 해당 인덱스의 물 포인트 y좌표 반환

##################################################
func splash_point(index_value: int, force_value: float) -> void:
# 특정 위치에 물방울이 떨어질 때 호출되는 함수로 force_value는 물방울의 힘
	force_value = min(force_value, 200)
	# force_value의 최대값을 200으로 제한
	# 너무 큰 값으로 물결이 왜곡되지 않게 함
	
	water_points_velocity[index_value] += force_value
	# 물방울이 떨어지는 지점에 힘을 적용
	
	if index_value > 1:
		water_points_velocity[index_value - 1] += force_value * 0.75
		# 왼쪽 한 칸 거리의 포인트에 75%의 힘을 전달
		water_points_velocity[index_value - 2] += force_value * 0.5
		# 왼쪽 두 칸 거리의 포인트에 50%의 힘을 전달
	if index_value < POINT_COUNT - 2:
		water_points_velocity[index_value + 1] += force_value * 0.75
		# 오른쪽 한 칸 거리의 포인트에 75%의 힘을 전달
		water_points_velocity[index_value + 2] += force_value * 0.5
		# 오른쪽 두 칸 거리의 포인트에 50%의 힘을 전달
	# 물방울의 충격이 그 주위로 퍼지게 하기 위해 주변 포인트들에도 영향을 줌
	
