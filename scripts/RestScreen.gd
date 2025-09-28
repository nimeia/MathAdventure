extends Control
class_name RestScreen

# ========== 节点引用 ==========
@onready var rest_time_label = $CenterContainer/VBoxContainer/RestTimeLabel
@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var rest_complete_label = $CenterContainer/VBoxContainer/RestCompleteLabel
@onready var continue_button = $CenterContainer/VBoxContainer/ContinueButton
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel
@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel

# ========== 常量定义 ==========
const REST_TIME_TOTAL = 600.0  # 10分钟总休息时间

func _ready():
	print("RestScreen: 休息界面初始化")
	
	# 连接TimerManager信号
	if TimerManager:
		TimerManager.rest_time_updated.connect(_on_rest_time_updated)
		TimerManager.rest_time_completed.connect(_on_rest_time_completed)
		TimerManager.state_changed.connect(_on_timer_state_changed)
	
	# 连接继续按钮
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	# 初始化界面状态
	update_rest_display()
	
	# 设置进度条最大值
	progress_bar.max_value = REST_TIME_TOTAL

func _on_rest_time_updated(time_remaining: float):
	"""更新休息时间显示"""
	var time_str = TimerManager.get_rest_time_string()
	rest_time_label.text = "剩余休息时间：" + time_str
	
	# 更新进度条
	progress_bar.value = time_remaining
	
	# 根据剩余时间调整消息
	if time_remaining > 300:  # 超过5分钟
		message_label.text = "为了保护您的视力和健康，\n请休息 10 分钟后再继续冒险。"
	elif time_remaining > 60:  # 超过1分钟
		message_label.text = "休息时间即将结束，\n请继续放松一会儿。"
	else:  # 最后1分钟
		message_label.text = "马上就可以继续游戏啦！\n请稍等片刻。"

func _on_rest_time_completed():
	"""休息时间完成"""
	print("RestScreen: 休息时间完成")
	
	# 隐藏休息相关UI
	rest_time_label.visible = false
	progress_bar.visible = false
	message_label.visible = false
	
	# 显示完成UI
	title_label.text = "休息完成！"
	rest_complete_label.visible = true
	continue_button.visible = true
	
	# 播放完成动画（简单的缩放效果）
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(rest_complete_label, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(rest_complete_label, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.5)

func _on_timer_state_changed(new_state):
	"""处理计时器状态改变"""
	match new_state:
		TimerManager.GameState.RESTING:
			print("RestScreen: 进入休息状态")
			update_rest_display()
		TimerManager.GameState.REST_COMPLETE:
			print("RestScreen: 休息完成状态")
			_on_rest_time_completed()

func _on_continue_button_pressed():
	"""点击继续游戏按钮"""
	print("RestScreen: 玩家选择继续游戏")
	
	# 重置计时器为新游戏状态
	TimerManager.reset_for_new_game()
	
	# 切换回主游戏场景
	get_tree().change_scene_to_file("res://main.tscn")

func update_rest_display():
	"""更新休息界面显示"""
	if not TimerManager:
		return
	
	if TimerManager.is_in_rest_period():
		# 正在休息
		rest_time_label.visible = true
		progress_bar.visible = true
		message_label.visible = true
		rest_complete_label.visible = false
		continue_button.visible = false
		title_label.text = "时间到啦！请休息一下吧"
		
		# 更新当前休息时间
		_on_rest_time_updated(TimerManager.rest_time_remaining)
	else:
		# 休息完成
		_on_rest_time_completed()

# ========== 输入处理 ==========
func _input(event):
	"""处理输入事件"""
	if event is InputEventKey and event.pressed:
		# 在休息期间禁用所有游戏相关按键
		if TimerManager.is_in_rest_period():
			# 显示提示信息
			show_rest_reminder()
			get_viewport().set_input_as_handled()

func show_rest_reminder():
	"""显示休息提醒"""
	# 创建临时提示标签
	var reminder = Label.new()
	reminder.text = "请继续休息，不要着急哦！😊"
	reminder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reminder.modulate = Color.YELLOW
	add_child(reminder)
	
	# 设置位置
	reminder.position = Vector2(
		(get_viewport().get_visible_rect().size.x - reminder.size.x) / 2,
		100
	)
	
	# 添加淡入淡出动画
	var tween = create_tween()
	tween.set_parallel(true)
	reminder.modulate.a = 0
	tween.tween_property(reminder, "modulate:a", 1.0, 0.3)
	tween.tween_property(reminder, "modulate:a", 0.0, 0.3).set_delay(2.0)
	
	# 2.5秒后删除
	tween.finished.connect(func(): reminder.queue_free())

# ========== 调试功能 ==========
func debug_skip_rest():
	"""调试功能：跳过休息时间"""
	print("RestScreen: 调试跳过休息时间")
	TimerManager.complete_rest_period()
	_on_rest_time_completed()
