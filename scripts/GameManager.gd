extends Control
class_name GameManager

# ========== 游戏常量定义 ==========
const COUNTDOWN_TIME = 5.0 # 倒计时秒数
const MIN_FRUITS = 3 # 最少果子数量
const MAX_FRUITS = 9 # 最多果子数量
const QUESTIONS_PER_LEVEL = 5 # 每关题目数量
const COIN_REWARD = 1 # 答对奖励金币数

# ========== 游戏状态变量 ==========
var current_level = 1
var current_question = 0
var correct_answers = 0
var coins = 0
var current_fruit_count = 0
var correct_answer = 0
var countdown_timer = 0.0
var is_waiting_for_answer = false
var is_timer_blinking = false # 用于防止重复闪烁动画

# ========== 节点引用 ==========
@onready var fruit_tree = $FruitTree
@onready var answer_buttons = [$UI/AnswerPanel/AnswerButton1, $UI/AnswerPanel/AnswerButton2, $UI/AnswerPanel/AnswerButton3]
@onready var countdown_bar = $UI/TopPanel/CountdownBar
@onready var score_label = $UI/TopPanel/ScoreLabel
@onready var game_timer_label = $UI/TopPanel/GameTimerLabel
@onready var question_timer_overlay = $UI/QuestionTimerOverlay
@onready var instruction_label = $UI/InstructionLabel
@onready var feedback_label = $UI/FeedbackLabel
@onready var level_complete_popup = $UI/LevelCompletePopup

# ========== 音频节点 ==========
@onready var correct_sound = $Audio/CorrectSound
@onready var wrong_sound = $Audio/WrongSound
@onready var timeout_sound = $Audio/TimeoutSound

func _ready():
	print("游戏开始！欢迎来到数学冒险！")
	setup_ui()
	setup_health_timer()
	setup_back_button()
	check_game_availability()

func _process(delta):
	if is_waiting_for_answer:
		countdown_timer -= delta
		update_countdown_bar()
		update_question_timer_overlay()
		
		# 检查超时
		if countdown_timer <= 0:
			handle_timeout()

func _input(event):
	"""处理键盘输入"""
	if not is_waiting_for_answer:
		return
		
	if event is InputEventKey and event.pressed:
		# 检查数字键 1-9
		var key_code = event.keycode
		var input_number = 0
		
		# 支持主键盘数字键
		if key_code >= KEY_1 and key_code <= KEY_9:
			input_number = key_code - KEY_0
		# 支持数字小键盘
		elif key_code >= KEY_KP_1 and key_code <= KEY_KP_9:
			input_number = key_code - KEY_KP_0
		
		if input_number > 0:
			print("键盘输入数字: %d" % input_number)
			handle_keyboard_input(input_number)

# ========== UI 设置 ==========
func setup_ui():
	# 初始化倒计时条
	countdown_bar.max_value = COUNTDOWN_TIME
	countdown_bar.value = COUNTDOWN_TIME
	
	# 设置按钮点击事件
	print("GameManager: 设置答案按钮信号连接")
	for i in range(answer_buttons.size()):
		if answer_buttons[i]:
			answer_buttons[i].pressed.connect(_on_answer_button_pressed.bind(i))
			print("GameManager: 按钮 %d 连接成功" % i)
		else:
			print("GameManager: 警告 - 按钮 %d 为 null" % i)
	
	# 初始化分数显示
	update_score_display()
	
	# 初始化题目倒计时显示
	setup_question_timer_overlay()
	
	# 隐藏反馈标签和完成弹窗
	feedback_label.visible = false
	level_complete_popup.visible = false

# ========== 关卡管理 ==========
func start_new_level():
	print("GameManager: 开始第 %d 关" % current_level)
	current_question = 0
	correct_answers = 0
	generate_new_question()
	print("GameManager: 新关卡启动完成")

func generate_new_question():
	current_question += 1
	print("第 %d 题 / %d" % [current_question, QUESTIONS_PER_LEVEL])
	
	# 随机生成果子数量
	current_fruit_count = randi_range(MIN_FRUITS, MAX_FRUITS)
	correct_answer = current_fruit_count
	
	print("正确答案：%d 个果子" % correct_answer)
	
	# 生成果子
	fruit_tree.generate_fruits(current_fruit_count)
	
	# 生成答案选项
	generate_answer_options()
	
	# 更新提示信息
	if instruction_label:
		instruction_label.text = "🍎 数一数树上有多少个果子？\n点击按钮或按数字键选择答案"
		instruction_label.visible = true
	
	# 重置倒计时
	countdown_timer = COUNTDOWN_TIME
	is_waiting_for_answer = true
	
	# 重置闪烁状态并显示题目倒计时
	is_timer_blinking = false
	show_question_timer_overlay()
	
	# 隐藏反馈
	feedback_label.visible = false

func generate_answer_options():
	# 生成三个选项：正确答案 + 两个干扰项
	var options = []
	options.append(correct_answer) # 正确答案
	
	# 生成干扰项（±1，确保不重复且在合理范围内）
	var distractor1 = correct_answer - 1
	var distractor2 = correct_answer + 1
	
	# 确保干扰项在合理范围内
	if distractor1 < 1:
		distractor1 = correct_answer + 2
	if distractor2 > 15: # 假设最大不超过15
		distractor2 = correct_answer - 2
	
	options.append(distractor1)
	options.append(distractor2)
	
	# 随机打乱顺序
	options.shuffle()
	
	# 设置按钮文本
	for i in range(answer_buttons.size()):
		answer_buttons[i].set_number(options[i])
	
	print("答案选项：%s" % str(options))

# ========== 答案处理 ==========
func _on_answer_button_pressed(button_index: int):
	print("GameManager: 按钮 %d 被点击！" % button_index)
	print("GameManager: 当前状态 - is_waiting_for_answer: %s" % is_waiting_for_answer)
	
	if not is_waiting_for_answer:
		print("GameManager: 不在等待答案状态，忽略点击")
		return
	
	is_waiting_for_answer = false
	var selected_answer = answer_buttons[button_index].get_number()
	
	# 隐藏题目倒计时
	hide_question_timer_overlay()
	
	print("玩家点击选择：%d" % selected_answer)
	print("GameManager: 正确答案: %d" % correct_answer)
	
	if selected_answer == correct_answer:
		handle_correct_answer()
	else:
		handle_wrong_answer()

func handle_keyboard_input(input_number: int):
	"""处理键盘数字输入"""
	if not is_waiting_for_answer:
		return
	
	# 检查输入的数字是否在合理范围内
	if input_number < MIN_FRUITS or input_number > MAX_FRUITS:
		print("键盘输入超出范围: %d (合理范围: %d-%d)" % [input_number, MIN_FRUITS, MAX_FRUITS])
		return
	
	is_waiting_for_answer = false
	
	# 隐藏题目倒计时
	hide_question_timer_overlay()
	
	print("键盘输入选择：%d" % input_number)
	
	# 高亮对应的按钮（如果存在）
	highlight_matching_button(input_number)
	
	if input_number == correct_answer:
		handle_correct_answer()
	else:
		handle_wrong_answer()

func highlight_matching_button(input_number: int):
	"""高亮对应的按钮"""
	for button in answer_buttons:
		if button.get_number() == input_number:
			# 播放按钮点击动画
			button.play_click_animation()
			break

func handle_correct_answer():
	print("回答正确！")
	correct_answers += 1
	coins += COIN_REWARD
	
	# 播放正确音效
	if correct_sound:
		correct_sound.play()
	
	# 果子掉落动画
	fruit_tree.play_fruit_drop_animation()
	
	# 显示正确反馈
	show_feedback("正确！+%d 金币" % COIN_REWARD, Color.GREEN)
	
	# 更新分数显示
	update_score_display()
	
	# 等待动画完成后进入下一题
	await get_tree().create_timer(1.5).timeout
	check_level_completion()

func handle_wrong_answer():
	print("回答错误！")
	
	# 播放错误音效
	if wrong_sound:
		wrong_sound.play()
	
	# 果子闪烁动画
	fruit_tree.play_fruit_blink_animation()
	
	# 显示错误反馈
	show_feedback("错了，再试试！", Color.RED)
	
	# 重新开始倒计时，让玩家重新作答
	countdown_timer = COUNTDOWN_TIME
	is_waiting_for_answer = true
	
	# 重新显示题目倒计时
	show_question_timer_overlay()

func handle_timeout():
	print("超时！")
	is_waiting_for_answer = false
	
	# 隐藏题目倒计时
	hide_question_timer_overlay()
	
	# 播放超时音效
	if timeout_sound:
		timeout_sound.play()
	
	# 显示超时反馈
	show_feedback("再快一点！", Color.ORANGE)
	
	# 等待反馈显示后直接进入下一题
	await get_tree().create_timer(1.0).timeout
	check_level_completion()

func check_level_completion():
	if current_question >= QUESTIONS_PER_LEVEL:
		complete_level()
	else:
		generate_new_question()

func complete_level():
	print("第 %d 关完成！正确答案：%d/%d" % [current_level, correct_answers, QUESTIONS_PER_LEVEL])

	# 完成关卡后立即保存进度，解锁下一关
	if TimerManager:
		TimerManager.update_game_progress(current_level + 1, coins, correct_answers)
		# 显示关卡完成弹窗
		show_level_complete_popup()


func show_level_complete_popup():
	level_complete_popup.visible = true
	var popup_label = level_complete_popup.get_node("Panel/VBoxContainer/Label")
	var stats_label = level_complete_popup.get_node("Panel/VBoxContainer/StatsLabel")
	var continue_button = level_complete_popup.get_node("Panel/VBoxContainer/ContinueButton")
	
	popup_label.text = "第 %d 关完成！" % current_level
	stats_label.text = "正确答案：%d/%d\n获得金币：%d" % [correct_answers, QUESTIONS_PER_LEVEL, coins]
	
	# 设置继续按钮
	continue_button.pressed.connect(_on_continue_button_pressed)

func _on_continue_button_pressed():
	level_complete_popup.visible = false
	
	# 保存进度，标记第一关完成，解锁第二关
	if TimerManager:
		# 保存当前的current_level + 1代表解锁下一关
		TimerManager.update_game_progress(current_level + 1, coins, 0)
	
	show_feedback("返回主菜单选择下一关...", Color.BLUE)
	await get_tree().create_timer(2.0).timeout
	
	# 返回主菜单
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ========== UI 更新函数 ==========
func update_countdown_bar():
	countdown_bar.value = countdown_timer

func update_score_display():
	score_label.text = "金币：%d | 关卡：%d" % [coins, current_level]

func show_feedback(text: String, color: Color):
	feedback_label.text = text
	feedback_label.modulate = color
	feedback_label.visible = true
	
# 自动隐藏反馈
	get_tree().create_timer(2.0).timeout.connect(func(): feedback_label.visible = false)

# ========== 健康时长控制 ==========
func setup_health_timer():
	"""初始化健康时长控制"""
	if not TimerManager:
		print("错误：TimerManager 未初始化")
		return
	
	# 连接TimerManager信号
	TimerManager.game_time_updated.connect(_on_game_time_updated)
	TimerManager.game_time_expired.connect(_on_game_time_expired)
	TimerManager.state_changed.connect(_on_timer_state_changed)
	
	print("健康时长控制初始化完成")

func check_game_availability():
	"""检查是否可以开始游戏"""
	if not TimerManager:
		print("GameManager: TimerManager 不存在，直接开始游戏")
		start_new_level()
		return
	
	if TimerManager.is_in_rest_period():
		# 处于休息期间，跳转到休息界面
		print("检测到正在休息中，跳转到休息界面")
		get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
		return
	
	if TimerManager.can_play_game():
		# 可以正常开始游戏
		load_saved_progress()
		start_new_level()
		TimerManager.start_game_timer()
	else:
		print("未知的计时器状态，重置为新游戏")
		TimerManager.reset_for_new_game()
		start_new_level()
		TimerManager.start_game_timer()

func _on_game_time_updated(time_remaining: float):
	"""游戏时间更新"""
	if game_timer_label:
		var time_str = TimerManager.get_game_time_string()
		game_timer_label.text = "🕰️ 游戏时间：" + time_str
		
		# 最后1分钟时变红提醒
		if time_remaining <= 60:
			game_timer_label.modulate = Color.RED
		elif time_remaining <= 180: # 最后3分钟时变黄
			game_timer_label.modulate = Color.YELLOW
		else:
			game_timer_label.modulate = Color.WHITE

func _on_game_time_expired():
	"""游戏时间耗尽"""
	print("游戏时间耗尽！")
	
	# 更新进度数据
	TimerManager.update_game_progress(current_level, coins, correct_answers)
	
	# 暫停所有游戏操作
	is_waiting_for_answer = false
	
	# 禁用按钮
	disable_game_controls()
	
	# 显示时间到提示
	show_feedback("时间到啦！请休息 10 分钟后再继续冒险。", Color.ORANGE)
	
	# 2秒后跳转到休息界面
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")

func _on_timer_state_changed(new_state):
	"""处理计时器状态改变"""
	print("GameManager: 计时器状态改变为 %d" % new_state)
	
	match new_state:
		TimerManager.GameState.PLAYING:
			enable_game_controls()
		TimerManager.GameState.TIME_UP, TimerManager.GameState.RESTING:
			disable_game_controls()
		TimerManager.GameState.REST_COMPLETE:
			enable_game_controls()

func disable_game_controls():
	"""禁用游戏控制"""
	for button in answer_buttons:
		button.disabled = true
	
	set_process_input(false)
	print("游戏控制已禁用")

func enable_game_controls():
	"""启用游戏控制"""
	for button in answer_buttons:
		button.disabled = false
	
	set_process_input(true)
	print("游戏控制已启用")

func load_saved_progress():
	"""加载保存的游戏进度"""
	var save_data = TimerManager.load_game_progress()
	if save_data.is_empty():
		print("没有保存数据，从第一关开始")
		return
	
	# 恢复游戏状态
	current_level = save_data.get("level", 1)
	coins = save_data.get("coins", 0)
	correct_answers = save_data.get("correct_answers", 0)
	
	print("加载保存进度: 关卡 %d, 金币 %d" % [current_level, coins])
	update_score_display()

# ========== 题目倒计时显示 ==========
func setup_question_timer_overlay():
	"""初始化题目倒计时显示"""
	if not question_timer_overlay:
		return
	
	# 设置字体样式
	question_timer_overlay.add_theme_font_size_override("font_size", 48)
	question_timer_overlay.add_theme_color_override("font_color", Color.WHITE)
	question_timer_overlay.add_theme_color_override("font_shadow_color", Color.BLACK)
	question_timer_overlay.add_theme_constant_override("shadow_offset_x", 2)
	question_timer_overlay.add_theme_constant_override("shadow_offset_y", 2)
	
	# 设置半透明效果
	question_timer_overlay.modulate = Color(1, 1, 1, 0.7)
	
	# 初始状态下隐藏
	question_timer_overlay.visible = false
	
	print("题目倒计时显示初始化完成")

func update_question_timer_overlay():
	"""更新题目倒计时显示"""
	if not question_timer_overlay:
		return
	
	# 显示倒计时数字
	var time_left = int(ceil(countdown_timer))
	question_timer_overlay.text = str(time_left)
	
	# 根据剩余时间调整颜色和透明度
	if time_left <= 1:
		# 最后1秒：红色，不透明，闪烁效果
		question_timer_overlay.modulate = Color.RED
		play_timer_blink_animation()
	elif time_left <= 2:
		# 最后2秒：橙色，较不透明
		question_timer_overlay.modulate = Color.ORANGE
	elif time_left <= 3:
		# 最后3秒：黄色，半透明
		question_timer_overlay.modulate = Color(1, 1, 0, 0.8)
	else:
		# 正常时间：白色，半透明
		question_timer_overlay.modulate = Color(1, 1, 1, 0.7)

func show_question_timer_overlay():
	"""显示题目倒计时显示"""
	if question_timer_overlay:
		question_timer_overlay.visible = true
		update_question_timer_overlay()

func hide_question_timer_overlay():
	"""隐藏题目倒计时显示"""
	if question_timer_overlay:
		question_timer_overlay.visible = false

func play_timer_blink_animation():
	"""播放倒计时闪烁动画（最后1秒）"""
	if not question_timer_overlay:
		return
	
	# 只在最后1秒播放闪烁动画
	if is_timer_blinking:
		return
	
	is_timer_blinking = true
	var tween = create_tween()
	tween.set_loops(3) # 闪烁3次
	tween.tween_property(question_timer_overlay, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(question_timer_overlay, "scale", Vector2(1.0, 1.0), 0.15)
	
	# 动画结束后重置标记
	tween.finished.connect(func(): is_timer_blinking = false)

# ========== 主菜单集成 ==========
func get_level_number() -> int:
	"""获取关卡编号"""
	return current_level

func get_coins() -> int:
	"""获取金币数量"""
	return coins

func get_health_time() -> int:
	"""获取健康时长"""
	if TimerManager:
		return TimerManager.get_remaining_game_time()
	return 0

func setup_back_button():
	"""设置返回按钮"""
	# 在main.tscn场景中动态创建返回按钮
	var back_button = BackToMenuButton.create_back_button(self, Vector2(20, 20))
	back_button.z_index = 100 # 确保在最上层
	print("GameManager: 返回按钮设置完成")
