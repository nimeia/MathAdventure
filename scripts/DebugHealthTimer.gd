extends Control
# 调试健康时长控制功能的测试界面

@onready var status_label = Label.new()
@onready var debug_buttons_container = VBoxContainer.new()

func _ready():
	# 创建调试UI
	setup_debug_ui()
	
	# 连接TimerManager信号用于调试
	if TimerManager:
		TimerManager.state_changed.connect(_on_timer_state_changed)
		TimerManager.game_time_updated.connect(_on_game_time_updated)
		TimerManager.rest_time_updated.connect(_on_rest_time_updated)

func setup_debug_ui():
	"""设置调试界面"""
	# 创建主容器
	var main_container = VBoxContainer.new()
	add_child(main_container)
	
	# 状态显示标签
	status_label.text = "健康时长控制调试面板"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(status_label)
	
	# 调试按钮容器
	main_container.add_child(debug_buttons_container)
	
	# 创建调试按钮
	create_debug_buttons()
	
	# 设置整体布局
	main_container.position = Vector2(10, 10)
	main_container.size = Vector2(300, 400)

func create_debug_buttons():
	"""创建调试按钮"""
	# 设置游戏时间为30秒（测试用）
	var btn_set_game_time = Button.new()
	btn_set_game_time.text = "设置游戏时间为30秒"
	btn_set_game_time.pressed.connect(func(): TimerManager.debug_set_game_time(30.0))
	debug_buttons_container.add_child(btn_set_game_time)
	
	# 设置休息时间为30秒（测试用）
	var btn_set_rest_time = Button.new()
	btn_set_rest_time.text = "设置休息时间为30秒"
	btn_set_rest_time.pressed.connect(func(): TimerManager.debug_set_rest_time(30.0))
	debug_buttons_container.add_child(btn_set_rest_time)
	
	# 强制触发休息
	var btn_trigger_rest = Button.new()
	btn_trigger_rest.text = "强制触发休息"
	btn_trigger_rest.pressed.connect(func(): TimerManager.trigger_rest_period())
	debug_buttons_container.add_child(btn_trigger_rest)
	
	# 完成休息
	var btn_complete_rest = Button.new()
	btn_complete_rest.text = "完成休息"
	btn_complete_rest.pressed.connect(func(): TimerManager.complete_rest_period())
	debug_buttons_container.add_child(btn_complete_rest)
	
	# 重置计时器
	var btn_reset_timer = Button.new()
	btn_reset_timer.text = "重置计时器"
	btn_reset_timer.pressed.connect(func(): TimerManager.reset_for_new_game())
	debug_buttons_container.add_child(btn_reset_timer)
	
	# 打印状态
	var btn_print_status = Button.new()
	btn_print_status.text = "打印当前状态"
	btn_print_status.pressed.connect(func(): TimerManager.debug_print_status())
	debug_buttons_container.add_child(btn_print_status)
	
	# 跳转到休息界面
	var btn_goto_rest = Button.new()
	btn_goto_rest.text = "跳转到休息界面"
	btn_goto_rest.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/RestScreen.tscn"))
	debug_buttons_container.add_child(btn_goto_rest)
	
	# 跳转到主游戏
	var btn_goto_game = Button.new()
	btn_goto_game.text = "跳转到主游戏"
	btn_goto_game.pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
	debug_buttons_container.add_child(btn_goto_game)

func _on_timer_state_changed(new_state):
	"""更新状态显示"""
	var state_names = ["PLAYING", "TIME_UP", "RESTING", "REST_COMPLETE"]
	var state_name = state_names[new_state] if new_state < state_names.size() else "UNKNOWN"
	update_status("状态: " + state_name)

func _on_game_time_updated(time_remaining: float):
	"""游戏时间更新"""
	update_status("游戏时间: " + TimerManager.get_game_time_string())

func _on_rest_time_updated(time_remaining: float):
	"""休息时间更新"""
	update_status("休息时间: " + TimerManager.get_rest_time_string())

func update_status(text: String):
	"""更新状态文本"""
	status_label.text = "健康时长控制调试面板\n" + text

# 快捷键调试
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				TimerManager.debug_set_game_time(30.0)
				print("调试: 设置游戏时间为30秒")
			KEY_F2:
				TimerManager.debug_set_rest_time(30.0)
				print("调试: 设置休息时间为30秒")
			KEY_F3:
				TimerManager.trigger_rest_period()
				print("调试: 触发休息")
			KEY_F4:
				TimerManager.complete_rest_period()
				print("调试: 完成休息")
			KEY_F5:
				TimerManager.reset_for_new_game()
				print("调试: 重置计时器")
			KEY_F12:
				TimerManager.debug_print_status()