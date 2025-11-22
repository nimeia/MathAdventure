extends Control
class_name Level2Manager

# ========== 第二关：比较大小桥 ==========
# 玩家需要比较两个数字的大小，选择正确的符号才能通过

# ========== 游戏常量定义 ==========
const COUNTDOWN_TIME = 5.0  # 每题倒计时时间
const MIN_NUMBER = 10  # 最小数字
const MAX_NUMBER = 99  # 最大数字
const MIN_DIFFERENCE = 1  # 最小差距
const MAX_DIFFERENCE = 30  # 最大差距
const QUESTIONS_PER_LEVEL = 5  # 每关题目数量
const QUICK_ANSWER_TIME = 3.0  # 快速答题时间阈值
const STREAK_BONUS_THRESHOLD = 3  # 连击奖励阈值

# ========== 游戏状态变量 ==========
var current_level = 2  # 当前关卡（第二关）
var current_question = 0  # 当前题目序号
var correct_answers = 0  # 正确答案数量
var coins = 0  # 金币数量
var answer_streak = 0  # 连续正确答案
var has_pet_reward = false  # 是否已获得小宠物

# ========== 题目相关变量 ==========
var number_a = 0  # 左边数字
var number_b = 0  # 右边数字
var correct_comparison: ComparisonButton.ComparisonType  # 正确的比较符号
var countdown_timer = 0.0  # 倒计时
var is_waiting_for_answer = false  # 是否等待答案
var question_start_time = 0.0  # 题目开始时间

# ========== 节点引用 ==========
@onready var left_stone = $GameArea/LeftStone
@onready var right_stone = $GameArea/RightStone
@onready var symbol_display = $GameArea/SymbolDisplay
@onready var comparison_buttons = [$UI/ButtonPanel/GreaterButton, $UI/ButtonPanel/LessButton, $UI/ButtonPanel/EqualButton]
@onready var countdown_bar = $UI/TopPanel/CountdownBar
@onready var score_label = $UI/TopPanel/ScoreLabel
@onready var game_timer_label = $UI/TopPanel/GameTimerLabel
@onready var back_button = $UI/TopPanel/BackButton  # 返回按钮
@onready var question_timer_overlay = $UI/QuestionTimerOverlay
@onready var instruction_label = $UI/InstructionLabel
@onready var feedback_label = $UI/FeedbackLabel
@onready var level_complete_popup = $UI/LevelCompletePopup
@onready var pet_reward_popup = $UI/PetRewardPopup

# ========== 音频节点 ==========
@onready var correct_sound = $Audio/CorrectSound
@onready var wrong_sound = $Audio/WrongSound
@onready var timeout_sound = $Audio/TimeoutSound
@onready var shatter_sound = $Audio/ShatterSound

func _ready():
	print("第二关：比较大小桥 开始！")
	setup_ui()
	setup_health_timer()
	setup_back_button()
	load_previous_progress()
	check_game_availability()

func _process(delta):
	if is_waiting_for_answer:
		countdown_timer -= delta
		update_countdown_display()
		
		# 检查超时
		if countdown_timer <= 0:
			handle_timeout()

func _input(event):
	"""处理键盘输入"""
	if not is_waiting_for_answer:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_comparison_button_pressed(0)  # >
			KEY_2:
				_on_comparison_button_pressed(1)  # <
			KEY_3:
				_on_comparison_button_pressed(2)  # =

# ========== UI 设置 ==========
func setup_ui():
	"""初始化UI"""
	# 初始化倒计时条
	countdown_bar.max_value = COUNTDOWN_TIME
	countdown_bar.value = COUNTDOWN_TIME
	
	# 设置按钮
	setup_comparison_buttons()
	
	# 初始化分数显示
	update_score_display()
	
	# 设置题目倒计时显示
	setup_question_timer_overlay()
	
	# 隐藏反馈和弹窗
	feedback_label.visible = false
	level_complete_popup.visible = false
	pet_reward_popup.visible = false
	
	print("Level2: UI初始化完成")

func setup_comparison_buttons():
	"""设置比较符号按钮"""
	# 设置按钮类型
	comparison_buttons[0].set_comparison_type(ComparisonButton.ComparisonType.GREATER)  # >
	comparison_buttons[1].set_comparison_type(ComparisonButton.ComparisonType.LESS)     # <
	comparison_buttons[2].set_comparison_type(ComparisonButton.ComparisonType.EQUAL)    # =
	
	# 连接按钮点击事件
	for i in range(comparison_buttons.size()):
		comparison_buttons[i].pressed.connect(_on_comparison_button_pressed.bind(i))

func setup_question_timer_overlay():
	"""初始化题目倒计时显示"""
	if question_timer_overlay:
		question_timer_overlay.add_theme_font_size_override("font_size", 48)
		question_timer_overlay.add_theme_color_override("font_color", Color.WHITE)
		question_timer_overlay.add_theme_color_override("font_shadow_color", Color.BLACK)
		question_timer_overlay.add_theme_constant_override("shadow_offset_x", 2)
		question_timer_overlay.add_theme_constant_override("shadow_offset_y", 2)
		question_timer_overlay.modulate = Color(1, 1, 1, 0.7)
		question_timer_overlay.visible = false

func setup_health_timer():
	"""设置健康时长控制"""
	if TimerManager:
		# 连接健康时长控制信号
		TimerManager.game_time_updated.connect(_on_game_time_updated)
		TimerManager.game_time_expired.connect(_on_game_time_expired)

# ========== 游戏状态检查 ==========
func check_game_availability():
	"""检查是否可以开始游戏"""
	if TimerManager and TimerManager.is_in_rest_period():
		print("检测到正在休息中，跳转到休息界面")
		get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
		return
	
	# 可以开始游戏
	start_new_level()
	if TimerManager:
		TimerManager.start_game_timer()

func load_previous_progress():
	"""加载之前的游戏进度"""
	if TimerManager:
		var save_data = TimerManager.load_game_progress()
		if not save_data.is_empty():
			coins = save_data.get("coins", 0)
			print("Level2: 加载金币数量 %d" % coins)

# ========== 关卡管理 ==========
func start_new_level():
	"""开始新关卡"""
	print("开始第二关：比较大小桥")
	current_question = 0
	correct_answers = 0
	answer_streak = 0
	generate_new_question()

func generate_new_question():
	"""生成新题目"""
	current_question += 1
	print("第 %d 题 / %d" % [current_question, QUESTIONS_PER_LEVEL])
	
	# 生成两个数字
	generate_numbers()
	
	# 确定正确答案
	determine_correct_answer()
	
	# 显示数字
	display_numbers()
	
	# 重置倒计时
	countdown_timer = COUNTDOWN_TIME
	is_waiting_for_answer = true
	question_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						  Time.get_time_dict_from_system().minute * 60 + \
						  Time.get_time_dict_from_system().second
	
	# 显示题目倒计时
	show_question_timer()
	
	# 启用按钮
	enable_buttons()
	
	# 隐藏符号显示
	symbol_display.text = "?"
	
	# 隐藏反馈
	feedback_label.visible = false
	
	print("生成题目: %d vs %d, 正确答案: %s" % [number_a, number_b, get_comparison_symbol_text(correct_comparison)])

func generate_numbers():
	"""生成两个数字"""
	# 决定是否生成相等的数字（20%概率）
	if randf() < 0.2:
		number_a = randi_range(MIN_NUMBER, MAX_NUMBER)
		number_b = number_a  # 相等
	else:
		# 生成不相等的数字
		number_a = randi_range(MIN_NUMBER, MAX_NUMBER)
		
		# 确保差距在合理范围内
		var min_b = max(MIN_NUMBER, number_a - MAX_DIFFERENCE)
		var max_b = min(MAX_NUMBER, number_a + MAX_DIFFERENCE)
		
		# 避免生成相等的数字
		var possible_numbers = []
		for i in range(min_b, max_b + 1):
			if abs(i - number_a) >= MIN_DIFFERENCE:
				possible_numbers.append(i)
		
		if possible_numbers.size() > 0:
			number_b = possible_numbers[randi() % possible_numbers.size()]
		else:
			# 备用方案
			number_b = number_a + (MIN_DIFFERENCE if randf() < 0.5 else -MIN_DIFFERENCE)
			number_b = clamp(number_b, MIN_NUMBER, MAX_NUMBER)

func determine_correct_answer():
	"""确定正确答案"""
	if number_a > number_b:
		correct_comparison = ComparisonButton.ComparisonType.GREATER
	elif number_a < number_b:
		correct_comparison = ComparisonButton.ComparisonType.LESS
	else:
		correct_comparison = ComparisonButton.ComparisonType.EQUAL

func display_numbers():
	"""显示数字到石头上"""
	if left_stone:
		left_stone.set_number(number_a)
		left_stone.play_appear_animation()
	
	if right_stone:
		right_stone.set_number(number_b)
		right_stone.play_appear_animation()

# ========== 答案处理 ==========
func _on_comparison_button_pressed(button_index: int):
	"""处理按钮点击"""
	if not is_waiting_for_answer:
		return
	
	is_waiting_for_answer = false
	var selected_button = comparison_buttons[button_index]
	var selected_type = selected_button.get_comparison_type()
	
	# 隐藏题目倒计时
	hide_question_timer()
	
	# 播放点击动画
	selected_button.play_click_animation()
	
	# 显示选择的符号
	symbol_display.text = selected_button.get_symbol_text()
	
	print("玩家选择: %s" % selected_button.get_symbol_text())
	
	if selected_type == correct_comparison:
		handle_correct_answer(selected_button)
	else:
		handle_wrong_answer(selected_button)

func handle_correct_answer(button: ComparisonButton):
	"""处理正确答案"""
	print("回答正确！")
	correct_answers += 1
	answer_streak += 1
	
	# 计算奖励
	var reward = calculate_reward()
	coins += reward
	
	# 播放正确动画
	button.play_correct_animation()
	
	# 播放音效
	if correct_sound:
		correct_sound.play()
	if shatter_sound:
		shatter_sound.play()
	
	# 石头碎裂动画
	if left_stone and right_stone:
		left_stone.play_shatter_animation()
		right_stone.play_shatter_animation()
	
	# 显示反馈
	var feedback_text = "正确！+%d 金币" % reward
	if answer_streak >= STREAK_BONUS_THRESHOLD:
		feedback_text += " 连击奖励！"
	show_feedback(feedback_text, Color.GREEN)
	
	# 检查连击奖励
	check_streak_bonus()
	
	# 更新分数显示
	update_score_display()
	
	# 保存进度
	save_progress()
	
	# 等待动画完成后进入下一题
	await get_tree().create_timer(2.0).timeout
	check_level_completion()

func handle_wrong_answer(button: ComparisonButton):
	"""处理错误答案"""
	print("回答错误！")
	answer_streak = 0  # 重置连击
	
	# 播放错误动画
	button.play_wrong_animation()
	
	# 播放音效
	if wrong_sound:
		wrong_sound.play()
	
	# 石头闪烁
	if left_stone and right_stone:
		left_stone.play_blink_animation()
		right_stone.play_blink_animation()
	
	# 显示反馈
	show_feedback("答错了！再试一次", Color.RED)
	
	# 重新开始倒计时
	countdown_timer = COUNTDOWN_TIME
	is_waiting_for_answer = true
	show_question_timer()

func handle_timeout():
	"""处理超时"""
	print("超时！")
	is_waiting_for_answer = false
	answer_streak = 0  # 重置连击
	
	# 隐藏题目倒计时
	hide_question_timer()
	
	# 播放超时音效
	if timeout_sound:
		timeout_sound.play()
	
	# 石头掉落动画
	if left_stone and right_stone:
		left_stone.play_fall_animation()
		right_stone.play_fall_animation()
	
	# 显示反馈
	show_feedback("时间到！桥塌了！", Color.ORANGE)
	
	# 显示正确答案
	symbol_display.text = get_comparison_symbol_text(correct_comparison)
	
	# 等待动画后进入下一题
	await get_tree().create_timer(2.5).timeout
	check_level_completion()

# ========== 奖励系统 ==========
func calculate_reward() -> int:
	"""计算奖励金币"""
	var base_reward = 1
	var time_bonus = 0
	
	# 快速答题奖励
	var answer_time = Time.get_time_dict_from_system().hour * 3600 + \
					  Time.get_time_dict_from_system().minute * 60 + \
					  Time.get_time_dict_from_system().second - question_start_time
	
	if answer_time <= QUICK_ANSWER_TIME:
		time_bonus = 1
		print("快速答题奖励！")
	
	return base_reward + time_bonus

func check_streak_bonus():
	"""检查连击奖励"""
	if answer_streak >= STREAK_BONUS_THRESHOLD and not has_pet_reward:
		has_pet_reward = true
		show_pet_reward()

func show_pet_reward():
	"""显示小宠物奖励"""
	print("获得小宠物奖励！")
	
	if pet_reward_popup:
		pet_reward_popup.visible = true
		var pet_label = pet_reward_popup.get_node("Panel/VBoxContainer/PetLabel")
		var message_label = pet_reward_popup.get_node("Panel/VBoxContainer/MessageLabel")
		var close_button = pet_reward_popup.get_node("Panel/VBoxContainer/CloseButton")
		
		pet_label.text = "🐱"  # 小猫咪
		message_label.text = "连续答对3题！\n获得小宠物陪伴！"
		
		close_button.pressed.connect(func(): pet_reward_popup.visible = false)

# ========== 关卡完成 ==========
func check_level_completion():
	"""检查关卡完成条件"""
	if current_question >= QUESTIONS_PER_LEVEL:
		complete_level()
	else:
		generate_new_question()

func complete_level():
	"""完成关卡"""
	print("第二关完成！正确答案：%d/%d" % [correct_answers, QUESTIONS_PER_LEVEL])
	
	# 保存最终进度
	save_progress()
	
	# 显示完成弹窗
	show_level_complete_popup()

func show_level_complete_popup():
	"""显示关卡完成弹窗"""
	if level_complete_popup:
		level_complete_popup.visible = true
		var popup_label = level_complete_popup.get_node("Panel/VBoxContainer/Label")
		var stats_label = level_complete_popup.get_node("Panel/VBoxContainer/StatsLabel")
		var reward_label = level_complete_popup.get_node("Panel/VBoxContainer/RewardLabel")
		var continue_button = level_complete_popup.get_node("Panel/VBoxContainer/ContinueButton")
		
		popup_label.text = "成功通过比较大小桥！"
		stats_label.text = "正确答案：%d/%d\n获得金币：%d" % [correct_answers, QUESTIONS_PER_LEVEL, coins]
		reward_label.text = "🗺️ 获得地图碎片！\n解锁下一关！"
		
		continue_button.pressed.connect(_on_continue_button_pressed)

func _on_continue_button_pressed():
	"""继续按钮点击"""
	level_complete_popup.visible = false
	
	# 保存最终进度
	if TimerManager:
		# 标记第二关完成，解锁第三关
		TimerManager.update_game_progress(current_level + 1, coins, 0)
		
	show_feedback("返回主菜单选择下一关...", Color.BLUE)
	await get_tree().create_timer(2.0).timeout
	
	# 返回主菜单
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ========== UI 更新函数 ==========
func update_countdown_display():
	"""更新倒计时显示"""
	if countdown_bar:
		countdown_bar.value = countdown_timer
	
	if question_timer_overlay and question_timer_overlay.visible:
		var time_left = int(ceil(countdown_timer))
		question_timer_overlay.text = str(time_left)
		
		# 颜色变化
		if time_left <= 1:
			question_timer_overlay.modulate = Color.RED
		elif time_left <= 2:
			question_timer_overlay.modulate = Color.ORANGE
		elif time_left <= 3:
			question_timer_overlay.modulate = Color(1, 1, 0, 0.8)
		else:
			question_timer_overlay.modulate = Color(1, 1, 1, 0.7)

func update_score_display():
	"""更新分数显示"""
	if score_label:
		score_label.text = "金币：%d | 关卡：%d" % [coins, current_level]

func show_feedback(text: String, color: Color):
	"""显示反馈信息"""
	if feedback_label:
		feedback_label.text = text
		feedback_label.modulate = color
		feedback_label.visible = true
		
		# 自动隐藏
		get_tree().create_timer(3.0).timeout.connect(func(): 
			if feedback_label:
				feedback_label.visible = false
		)

func show_question_timer():
	"""显示题目倒计时"""
	if question_timer_overlay:
		question_timer_overlay.visible = true
		update_countdown_display()

func hide_question_timer():
	"""隐藏题目倒计时"""
	if question_timer_overlay:
		question_timer_overlay.visible = false

func enable_buttons():
	"""启用所有按钮"""
	for button in comparison_buttons:
		button.set_enabled(true)

func disable_buttons():
	"""禁用所有按钮"""
	for button in comparison_buttons:
		button.set_enabled(false)

# ========== 健康时长控制 ==========
func _on_game_time_updated(time_remaining: float):
	"""游戏时间更新"""
	if game_timer_label:
		var time_str = TimerManager.get_game_time_string()
		game_timer_label.text = "🕰️ 游戏时间：" + time_str
		
		if time_remaining <= 60:
			game_timer_label.modulate = Color.RED
		elif time_remaining <= 180:
			game_timer_label.modulate = Color.YELLOW
		else:
			game_timer_label.modulate = Color.WHITE

func _on_game_time_expired():
	"""游戏时间耗尽"""
	print("游戏时间耗尽！")
	
	# 保存进度
	save_progress()
	
	# 禁用控制
	disable_buttons()
	is_waiting_for_answer = false
	
	# 显示提示
	show_feedback("时间到啦！请休息 10 分钟后再继续冒险。", Color.ORANGE)
	
	# 跳转到休息界面
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")

# ========== 数据保存 ==========
func save_progress():
        """保存游戏进度"""
        if TimerManager:
                # 使用 current_level + 1 直接解锁下一关，防止未点击按钮时进度丢失
                TimerManager.update_game_progress(current_level + 1, coins, correct_answers)

# ========== 工具函数 ==========
func get_comparison_symbol_text(comparison: ComparisonButton.ComparisonType) -> String:
	"""获取比较符号文本"""
	match comparison:
		ComparisonButton.ComparisonType.GREATER:
			return ">"
		ComparisonButton.ComparisonType.LESS:
			return "<"
		ComparisonButton.ComparisonType.EQUAL:
			return "="
		_:
			return "?"

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
	# 尝试从不同位置找到返回按钮
	if not back_button:
		back_button = $UI/BackButton
	if not back_button:
		back_button = $UI/TopPanel/BackButton
	
	if back_button:
		# 设置按钮文本和样式
		back_button.text = "🏠 返回"
		back_button.tooltip_text = "返回主菜单"
		
		# 直接连接按钮信号
		if not back_button.pressed.is_connected(_on_back_button_pressed):
			back_button.pressed.connect(_on_back_button_pressed)
		print("Level2: 返回按钮设置完成")
	else:
		# 如果没有预设的返回按钮，动态创建一个
		print("Level2: 动态创建返回按钮")
		create_back_button()

func create_back_button():
	"""动态创建返回按钮"""
	var new_back_button = Button.new()
	new_back_button.name = "BackButton"
	new_back_button.text = "🏠 返回"
	new_back_button.tooltip_text = "返回主菍单"
	new_back_button.size = Vector2(100, 40)
	new_back_button.position = Vector2(10, 10)
	
	# 添加到 TopPanel 或 UI 节点
	var top_panel = $UI/TopPanel
	if top_panel:
		top_panel.add_child(new_back_button)
	else:
		$UI.add_child(new_back_button)
	
	# 直接连接信号
	new_back_button.pressed.connect(_on_back_button_pressed)
	back_button = new_back_button
	print("Level2: 返回按钮动态创建完成")

func _on_back_button_pressed():
	"""返回按钮被点击"""
	print("Level2: 返回按钮被点击")
	
	# 显示确认对话框
	show_return_confirmation()

func show_return_confirmation():
	"""显示返回确认对话框"""
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.dialog_text = "确定要返回主菜单吗？\n当前关卡的进度将会保存。"
	confirm_dialog.title = "确认返回"
	confirm_dialog.ok_button_text = "确定返回"
	confirm_dialog.add_cancel_button("继续游戏")
	
	# 添加到场景树
	get_tree().current_scene.add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	# 连接确认信号
	confirm_dialog.confirmed.connect(func():
		print("Level2: 用户确认返回")
		return_to_main_menu()
	)
	
	# 弹窗关闭后自动销毁
	confirm_dialog.visibility_changed.connect(func():
		if not confirm_dialog.visible:
			confirm_dialog.queue_free()
	)

func return_to_main_menu():
	"""返回主菍单"""
	print("Level2: 正在返回主菍单...")
	
	# 保存进度
	save_progress()
	
	# 显示反馈
	show_feedback("正在返回主菜单...", Color.GREEN)
	
	# 延迟后切换场景
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# 修改_ready方法，添加返回按钮设置
# 请参考下一个diff修改
