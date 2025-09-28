extends Control
class_name MazeScene

# ========== 第三关：加减法迷宫 ==========
# 专注于100以内加减法题目生成和答案验证

# ========== 游戏常量 ==========
const QUESTION_TIME = 8.0  # 每题8秒倒计时
const QUESTIONS_TO_WIN = 5  # 需要答对5题通关
const BASE_COIN_REWARD = 2  # 基础答对奖励
const FAST_BONUS_TIME = 5.0  # 快速答题时间阈值
const FAST_BONUS_COIN = 1  # 快速答题额外奖励
const STREAK_FOR_CHEST = 5  # 连续答对触发宝箱
const CHEST_BONUS = 10  # 宝箱奖励金币

# ========== 题目生成常量 ==========
const MIN_NUMBER = 0  # 最小数字
const MAX_NUMBER = 99  # 最大数字
const MIN_WRONG_DIFF = 1  # 错误答案最小差值
const MAX_WRONG_DIFF = 20  # 错误答案最大差值

# ========== 游戏状态 ==========
var current_question_num = 0  # 当前题目编号
var correct_count = 0  # 答对题目数
var streak_count = 0  # 连击数
var total_coins = 0  # 总金币数（从全局加载）
var current_question = {}  # 当前题目数据
var question_start_time = 0.0  # 题目开始时间
var is_waiting_answer = false  # 是否等待答案
var countdown_timer = 0.0  # 倒计时

# ========== 节点引用 ==========
@onready var question_label = $UI/QuestionArea/QuestionLabel
@onready var answer_buttons = [
	$UI/QuestionArea/AnswerContainer/AnswerBtn1,
	$UI/QuestionArea/AnswerContainer/AnswerBtn2,
	$UI/QuestionArea/AnswerContainer/AnswerBtn3
]
@onready var timer_bar = $UI/QuestionArea/TimerContainer/TimerBar
@onready var timer_label = $UI/QuestionArea/TimerContainer/TimerLabel
@onready var coin_label = $UI/TopPanel/CoinLabel
@onready var game_timer_label = $UI/TopPanel/GameTimerLabel
@onready var back_button = $UI/TopPanel/BackButton  # 返回按钮
@onready var feedback_panel = $UI/FeedbackPanel
@onready var feedback_label = $UI/FeedbackPanel/FeedbackLabel
@onready var level_complete_popup = $UI/LevelCompletePopup
@onready var player_sprite = $UI/MazeArea/PlayerSprite
@onready var path_container = $UI/MazeArea/PathContainer

# 音效节点
@onready var correct_sound = $Audio/CorrectSound
@onready var wrong_sound = $Audio/WrongSound
@onready var timeout_sound = $Audio/TimeoutSound

# ========== 初始化 ==========
func _ready():
	print("第三关：加减法迷宫 开始！")
	setup_ui()
	setup_health_timer()
	setup_back_button()  # 设置返回按钮
	load_global_data()
	check_game_availability()

func setup_ui():
	"""初始化UI界面"""
	# 初始化倒计时条（8秒）
	if timer_bar:
		timer_bar.max_value = QUESTION_TIME
		timer_bar.value = QUESTION_TIME
		timer_bar.show_percentage = false
	
	# 初始化倒计时标签
	if timer_label:
		timer_label.text = str(int(QUESTION_TIME))
	
	# 连接按钮信号
	for i in range(answer_buttons.size()):
		if answer_buttons[i]:
			answer_buttons[i].pressed.connect(_on_answer_button_pressed.bind(i))
	
	# 隐藏弹窗
	if feedback_panel:
		feedback_panel.visible = false
	if level_complete_popup:
		level_complete_popup.visible = false
	
	# 初始化路径显示
	for child in path_container.get_children():
		if child is Label:
			child.text = "🛤️"
	
	print("MazeScene: UI初始化完成（倒计时：%d秒）" % int(QUESTION_TIME))

func setup_health_timer():
	"""连接健康时长系统"""
	if TimerManager:
		TimerManager.game_time_updated.connect(_on_game_time_updated)
		TimerManager.game_time_expired.connect(_on_game_time_expired)
		print("MazeScene: 健康时长系统已连接")

func load_global_data():
	"""加载全局游戏数据"""
	if TimerManager:
		var save_data = TimerManager.load_game_progress()
		if not save_data.is_empty():
			total_coins = save_data.get("coins", 0)
			print("MazeScene: 加载金币数 %d" % total_coins)
			update_coin_display()

func check_game_availability():
	"""检查游戏是否可以开始"""
	if TimerManager and TimerManager.is_in_rest_period():
		print("正在休息期间，跳转到休息界面")
		get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
		return
	
	# 开始游戏
	start_maze_game()
	if TimerManager:
		TimerManager.start_game_timer()

# ========== 游戏流程 ==========
func start_maze_game():
	"""开始迷宫游戏"""
	current_question_num = 0
	correct_count = 0
	streak_count = 0
	generate_new_question()

func generate_new_question():
	"""生成新的加减法题目（100以内）"""
	current_question_num += 1
	print("\n===== 生成第 %d 题 =====" % current_question_num)
	
	# 随机选择加法或减法（50%概率）
	var is_addition = randf() > 0.5
	
	if is_addition:
		# 生成加法题目
		current_question = generate_addition_question()
	else:
		# 生成减法题目
		current_question = generate_subtraction_question()
	
	print("题目类型: %s" % ("加法" if is_addition else "减法"))
	print("算式: %s" % current_question.expression)
	print("正确答案: %d" % current_question.answer)
	
	# 生成答案选项（包含1个正确答案和1-2个错误答案）
	var options = generate_answer_options(current_question.answer)
	
	# 显示题目到 QuestionLabel
	if question_label:
		question_label.text = current_question.expression
	
	# 将答案随机分配到按钮
	assign_answers_to_buttons(options)
	
	# ========== 重置倒计时（8秒） ==========
	reset_timer()
	
	# 记录题目开始时间
	question_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						  Time.get_time_dict_from_system().minute * 60 + \
						  Time.get_time_dict_from_system().second
	
	# 清除反馈
	if feedback_panel:
		feedback_panel.visible = false
	
	# 启用所有答案按钮
	for btn in answer_buttons:
		if btn:
			btn.disabled = false
			btn.modulate = Color.WHITE  # 恢复按钮颜色

# ========== 题目生成辅助函数 ==========
func generate_addition_question() -> Dictionary:
	"""生成加法题目，确保结果 ≤ 99"""
	var a = randi_range(0, MAX_NUMBER)
	var max_b = MAX_NUMBER - a  # 确保 a + b <= 99
	var b = randi_range(0, max_b)
	
	return {
		"a": a,
		"b": b,
		"operator": "+",
		"answer": a + b,
		"expression": "%d + %d = ?" % [a, b]
	}

func generate_subtraction_question() -> Dictionary:
	"""生成减法题目，确保结果 ≥ 0"""
	var a = randi_range(0, MAX_NUMBER)
	var b = randi_range(0, a)  # 确保 a - b >= 0
	
	return {
		"a": a,
		"b": b,
		"operator": "-",
		"answer": a - b,
		"expression": "%d - %d = ?" % [a, b]
	}

func generate_answer_options(correct_answer: int) -> Array:
	"""生成答案选项：1个正确答案 + 1-2个错误答案
	错误答案与正确答案的差值在 1-20 之间
	"""
	var options = []
	options.append(correct_answer)  # 添加正确答案
	
	# 决定生成几个错误答案（1-2个）
	var num_wrong_answers = randi_range(1, 2)
	print("将生成 %d 个错误答案" % num_wrong_answers)
	
	# 生成错误答案
	var wrong_answers = generate_wrong_answers(correct_answer, num_wrong_answers)
	for wrong in wrong_answers:
		options.append(wrong)
	
	# 确保总是有3个选项（如果不够就补充）
	while options.size() < 3:
		var additional_wrong = generate_single_wrong_answer(correct_answer, options)
		if additional_wrong != -1:
			options.append(additional_wrong)
		else:
			break  # 无法生成更多选项
	
	print("生成的选项（打乱前）: %s" % str(options))
	return options

func generate_wrong_answers(correct_answer: int, count: int) -> Array:
	"""生成指定数量的错误答案"""
	var wrong_answers = []
	var max_attempts = 50  # 最大尝试次数，防止死循环
	var attempts = 0
	
	while wrong_answers.size() < count and attempts < max_attempts:
		attempts += 1
		
		# 生成一个差值（1-20之间）
		var diff = randi_range(MIN_WRONG_DIFF, MAX_WRONG_DIFF)
		
		# 随机决定是加还是减
		if randf() < 0.5:
			diff = -diff
		
		var wrong_answer = correct_answer + diff
		
		# 验证错误答案的有效性
		if is_valid_wrong_answer(wrong_answer, correct_answer, wrong_answers):
			wrong_answers.append(wrong_answer)
			print("  生成错误答案: %d (差值: %d)" % [wrong_answer, diff])
	
	# 如果生成数量不足，使用备用方案
	if wrong_answers.size() < count:
		print("警告：无法生成足够的错误答案，使用备用方案")
		wrong_answers = generate_fallback_wrong_answers(correct_answer, count, wrong_answers)
	
	return wrong_answers

func generate_single_wrong_answer(correct_answer: int, existing_options: Array) -> int:
	"""生成单个错误答案，避免与现有选项重复"""
	for i in range(20):
		var diff = randi_range(MIN_WRONG_DIFF, MAX_WRONG_DIFF)
		if randf() < 0.5:
			diff = -diff
		
		var wrong = correct_answer + diff
		if wrong >= MIN_NUMBER and wrong <= MAX_NUMBER and wrong not in existing_options:
			return wrong
	
	return -1  # 生成失败

func is_valid_wrong_answer(answer: int, correct: int, existing_wrong: Array) -> bool:
	"""检查错误答案是否有效"""
	# 必须在0-99范围内
	if answer < MIN_NUMBER or answer > MAX_NUMBER:
		return false
	
	# 不能等于正确答案
	if answer == correct:
		return false
	
	# 不能与已有的错误答案重复
	if answer in existing_wrong:
		return false
	
	# 差值必须在1-20之间
	var diff = abs(answer - correct)
	if diff < MIN_WRONG_DIFF or diff > MAX_WRONG_DIFF:
		return false
	
	return true

func generate_fallback_wrong_answers(correct: int, needed: int, existing: Array) -> Array:
	"""备用方案：生成简单的错误答案"""
	var result = existing.duplicate()
	
	# 尝试添加 +1, -1, +2, -2 等简单差值
	var simple_diffs = [1, -1, 2, -2, 3, -3, 5, -5, 10, -10]
	for diff in simple_diffs:
		if result.size() >= needed:
			break
		
		var wrong = correct + diff
		if wrong >= MIN_NUMBER and wrong <= MAX_NUMBER and wrong != correct and wrong not in result:
			result.append(wrong)
	
	return result

func assign_answers_to_buttons(options: Array):
	"""将答案随机分配到按钮 AnswerBtn1~3"""
	# 打乱选项顺序
	options.shuffle()
	
	# 分配到按钮
	for i in range(min(answer_buttons.size(), options.size())):
		if answer_buttons[i]:
			answer_buttons[i].text = str(options[i])
			print("  按钮%d: %s" % [i+1, options[i]])
	
	print("答案已随机分配到按钮")

# ========== 答案处理 ==========
func _on_answer_button_pressed(button_index: int):
	"""处理答案按钮点击 - 检测答案是否正确"""
	if not is_waiting_answer:
		return
	
	# 停止倒计时
	stop_timer()
	
	var selected_answer = int(answer_buttons[button_index].text)
	
	# 计算答题时间
	var current_time = Time.get_time_dict_from_system().hour * 3600 + \
					   Time.get_time_dict_from_system().minute * 60 + \
					   Time.get_time_dict_from_system().second
	var answer_time = current_time - question_start_time
	
	print("\n===== 答题判定 =====")
	print("选择的答案: %d" % selected_answer)
	print("正确答案: %d" % current_question.answer)
	print("答题用时: %.1f 秒" % answer_time)
	
	# 禁用所有按钮，防止重复点击
	for btn in answer_buttons:
		btn.disabled = true
	
	# 判断答案是否正确
	if selected_answer == current_question.answer:
		print("✅ 答案正确！")
		handle_correct_answer(answer_time, button_index)
	else:
		print("❌ 答案错误！")
		handle_wrong_answer(button_index)

func handle_correct_answer(answer_time: float, button_index: int):
	"""处理正确答案"""
	correct_count += 1
	streak_count += 1
	
	# ========== 金币奖励计算 ==========
	var base_reward = BASE_COIN_REWARD  # 基础奖励 2 金币
	var total_reward = base_reward
	var bonus_text = ""
	
	# 快速答题奖励判定（≤5秒额外+1金币）
	if answer_time <= FAST_BONUS_TIME:
		var fast_bonus = FAST_BONUS_COIN  # 额外 1 金币
		total_reward += fast_bonus
		bonus_text = "\n⚡ 快速答题奖励 +%d 金币！" % fast_bonus
		print("快速答题！额外奖励 %d 金币" % fast_bonus)
	
	# 更新全局金币系统
	total_coins += total_reward
	update_coin_display()
	print("获得金币: %d (总金币: %d)" % [total_reward, total_coins])
	
	# 保存进度到 TimerManager
	if TimerManager:
		TimerManager.update_game_progress(3, total_coins, correct_count)
	
	# ========== 视觉反馈 ==========
	# 让选中的按钮闪烁绿色
	if button_index < answer_buttons.size() and answer_buttons[button_index]:
		animate_button_correct(answer_buttons[button_index])
	
	# 路径变绿动画
	animate_paths_correct()
	
	# 播放音效
	if correct_sound:
		correct_sound.play()
	
	# 显示反馈信息
	var feedback_text = "✅ 回答正确！+%d 金币" % total_reward + bonus_text
	show_feedback(feedback_text, Color.GREEN)
	
	# 玩家前进动画
	move_player_forward()
	
	# 检查连击奖励
	if streak_count % STREAK_FOR_CHEST == 0:
		trigger_chest_reward()
	
	# 等待动画完成后生成下一题
	await get_tree().create_timer(2.0).timeout
	
	# 清除反馈
	if feedback_panel:
		feedback_panel.visible = false
	
	# 检查进度或生成下一题
	check_progress()

func handle_wrong_answer(button_index: int):
	"""处理错误答案"""
	streak_count = 0  # 重置连击
	
	# ========== 视觉反馈 ==========
	# 让选中的按钮闪烁红色
	if button_index < answer_buttons.size() and answer_buttons[button_index]:
		animate_button_wrong(answer_buttons[button_index])
	
	# 路径变红动画
	animate_paths_wrong()
	
	# 播放音效
	if wrong_sound:
		wrong_sound.play()
	
	# 显示"再试一次"提示
	var feedback_text = "❌ 答错了！再试一次\n正确答案是 %d" % current_question.answer
	show_feedback(feedback_text, Color.RED)
	print("答错了！正确答案是 %d，请再试一次" % current_question.answer)
	
	# 玩家后退动画
	move_player_back()
	
	# 等待一段时间后重新启用答题
	await get_tree().create_timer(1.5).timeout
	
	# 重新开始当前题目的倒计时（重置为8秒）
	reset_timer()
	
	# 重新启用所有按钮
	for btn in answer_buttons:
		if btn:
			btn.disabled = false
			# 恢复按钮原始颜色
			btn.modulate = Color.WHITE
	
	# 清除反馈信息
	await get_tree().create_timer(0.5).timeout
	if feedback_panel:
		feedback_panel.visible = false

func handle_timeout():
	"""处理超时 - 时间到自动判定为错误"""
	print("\n⏰ 答题超时！")
	is_waiting_answer = false
	streak_count = 0  # 重置连击
	
	# 禁用所有按钮
	for btn in answer_buttons:
		if btn:
			btn.disabled = true
	
	# 播放超时音效
	if timeout_sound:
		timeout_sound.play()
	
	# 显示超时反馈
	var feedback_text = "⏰ 时间到！\n正确答案是 %d" % current_question.answer
	show_feedback(feedback_text, Color.ORANGE)
	
	# 路径变黄动画
	animate_paths_timeout()
	
	# 等待动画完成后生成新题目
	await get_tree().create_timer(2.0).timeout
	
	# 清空UI状态并生成下一题
	clear_ui_state()
	generate_new_question()

func trigger_chest_reward():
	"""触发宝箱奖励"""
	total_coins += CHEST_BONUS
	update_coin_display()
	
	# 保存进度
	if TimerManager:
		TimerManager.update_game_progress(3, total_coins, correct_count)
	
	# 显示宝箱动画
	show_feedback("🎁 宝箱奖励！+%d 金币 + 装备！" % CHEST_BONUS, Color.GOLD)
	print("触发宝箱奖励！连续答对 %d 题" % streak_count)

# ========== 进度检查 ==========
func check_progress():
	"""检查游戏进度 - 判断是否通关"""
	print("\n当前进度: %d/%d 题" % [correct_count, QUESTIONS_TO_WIN])
	
	# 检查是否达到通关条件（答对5道题）
	if correct_count >= QUESTIONS_TO_WIN:
		print("🎉 已完成所有题目！准备通关...")
		complete_level()
	else:
		print("生成下一题...")
		generate_new_question()

func complete_level():
	"""完成关卡 - 通关处理"""
	print("\n========== 🎆 通关！ 🎆 ==========")
	print("第三关：加减法迷宫 通关！")
	print("答对题目：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
	print("当前金币：%d" % total_coins)
	
	# 停止所有游戏逻辑
	stop_timer()
	is_waiting_answer = false
	
	# 禁用所有按钮
	for btn in answer_buttons:
		if btn:
			btn.disabled = true
	
	# 给予通关奖励
	award_completion_rewards()
	
	# 显示通关动画和弹窗
	show_completion_effects()
	
	# 保存进度
	save_progress()
	
	# 等待后跳转到下一关
	await get_tree().create_timer(3.0).timeout
	go_to_next_level()

# ========== 通关奖励系统 ==========
func award_completion_rewards():
	"""给予通关奖励"""
	print("\n发放通关奖励...")
	
	# 宝箱奖励：+10金币
	var chest_bonus = 10
	total_coins += chest_bonus
	update_coin_display()
	print("🎁 宝箱奖励：+%d 金币" % chest_bonus)
	
	# 发放道具：盾牌
	var item_reward = "🛡️ 盾牌"
	print("🎆 获得道具：%s" % item_reward)
	
	# 地图碎片
	print("🗺️ 获得地图碎片 x1")
	
	# 更新 TimerManager
	if TimerManager:
		TimerManager.update_game_progress(4, total_coins, correct_count)
		print("进度已保存，解锁第4关")

func show_completion_effects():
	"""显示通关特效和提示"""
	# 显示通关提示
	var completion_text = "🎆 恭喜！小勇士走出了加减法迷宫！ 🎆"
	show_feedback(completion_text, Color.GOLD)
	
	# 路径彩虹动画
	animate_paths_completion()
	
	# 玩家胜利动画
	if player_sprite:
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(player_sprite, "scale", Vector2(1.5, 1.5), 0.3)
		tween.tween_property(player_sprite, "scale", Vector2(1.0, 1.0), 0.3)
		tween.tween_property(player_sprite, "rotation", 0.5, 0.3)
		tween.tween_property(player_sprite, "rotation", 0.0, 0.3)
	
	# 显示通关弹窗
	if level_complete_popup:
		# 等待动画完成后显示
		await get_tree().create_timer(1.5).timeout
		show_complete_popup()

func show_complete_popup():
	"""显示通关弹窗 - 详细奖励信息"""
	if not level_complete_popup:
		return
	
	level_complete_popup.visible = true
	
	var title_label = level_complete_popup.get_node("VBoxContainer/TitleLabel")
	var stats_label = level_complete_popup.get_node("VBoxContainer/StatsLabel")
	var continue_btn = level_complete_popup.get_node("VBoxContainer/ContinueButton")
	
	if title_label:
		title_label.text = "🎉 恭喜通关！"
	
	if stats_label:
		var stats_text = "🎆 小勇士走出了加减法迷宫！\n\n"
		stats_text += "🎁 通关奖励：\n"
		stats_text += "  💰 金币 +10\n"
		stats_text += "  🛡️ 盾牌 x1\n"
		stats_text += "  🗺️ 地图碎片 x1\n\n"
		stats_text += "📊 游戏统计：\n"
		stats_text += "  答对：%d 题\n" % correct_count
		stats_text += "  金币：%d 枚\n" % total_coins
		stats_text += "  连击：%d 次" % streak_count
		stats_label.text = stats_text
	
	if continue_btn:
		continue_btn.text = "前往下一关"
		if not continue_btn.is_connected("pressed", _on_continue_pressed):
			continue_btn.pressed.connect(_on_continue_pressed)

func save_progress():
	"""保存游戏进度"""
	if TimerManager:
		# 保存到第4关（下一关）
		TimerManager.update_game_progress(4, total_coins, correct_count)
		print("游戏进度已保存")

func go_to_next_level():
	"""跳转到下一关"""
	print("\n跳转到下一关...")
	
	# 检查下一关场景是否存在
	var next_level_path = "res://scenes/NextLevel.tscn"
	
	if ResourceLoader.exists(next_level_path):
		print("加载下一关：%s" % next_level_path)
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("下一关场景不存在，返回主菜单")
		# 如果下一关不存在，返回主菜单
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_continue_pressed():
	"""继续按钮被点击 - 跳转到下一关"""
	print("用户点击继续按钮")
	level_complete_popup.visible = false
	go_to_next_level()

# ========== UI更新 ==========
func update_coin_display():
	"""更新金币显示"""
	coin_label.text = "💰 金币: %d" % total_coins

func show_feedback(text: String, color: Color):
	"""显示反馈信息"""
	if feedback_panel:
		feedback_panel.visible = true
		if feedback_label:
			feedback_label.text = text
			feedback_label.modulate = color

# ========== 动画效果函数 ==========
func animate_button_correct(button: Button):
	"""按钮正确答案动画 - 闪烁绿色"""
	var tween = create_tween()
	tween.set_loops(2)  # 闪烁2次
	tween.tween_property(button, "modulate", Color.GREEN, 0.2)
	tween.tween_property(button, "modulate", Color(0.5, 1.0, 0.5), 0.2)
	tween.finished.connect(func(): button.modulate = Color.WHITE)

func animate_button_wrong(button: Button):
	"""按钮错误答案动画 - 闪烁红色"""
	var tween = create_tween()
	tween.set_loops(2)  # 闪烁2次
	tween.tween_property(button, "modulate", Color.RED, 0.2)
	tween.tween_property(button, "modulate", Color(1.0, 0.5, 0.5), 0.2)
	tween.finished.connect(func(): button.modulate = Color.WHITE)

func animate_paths_correct():
	"""路径正确动画 - 变绿"""
	for child in path_container.get_children():
		if child is Label:
			var tween = create_tween()
			child.text = "🟢"
			child.modulate = Color.GREEN
			tween.tween_property(child, "scale", Vector2(1.2, 1.2), 0.3)
			tween.tween_property(child, "scale", Vector2(1.0, 1.0), 0.3)
			tween.tween_callback(func(): 
				child.text = "🛤️"
				child.modulate = Color.WHITE
			)

func animate_paths_wrong():
	"""路径错误动画 - 变红"""
	for child in path_container.get_children():
		if child is Label:
			var tween = create_tween()
			child.text = "🔴"
			child.modulate = Color.RED
			tween.tween_property(child, "modulate", Color(1.0, 0.5, 0.5), 0.3)
			tween.tween_property(child, "modulate", Color.RED, 0.3)
			tween.tween_callback(func(): 
				child.text = "🛤️"
				child.modulate = Color.WHITE
			)

func animate_paths(symbol: String):
	"""通用路径动画效果"""
	for child in path_container.get_children():
		if child is Label:
			child.text = symbol
			var tween = create_tween()
			tween.tween_property(child, "modulate", Color.WHITE, 0.5)
			tween.tween_callback(func(): child.text = "🛤️")

func animate_paths_timeout():
	"""路径超时动画 - 变黄"""
	for child in path_container.get_children():
		if child is Label:
			var tween = create_tween()
			child.text = "🟡"
			child.modulate = Color.YELLOW
			tween.tween_property(child, "modulate", Color(1.0, 1.0, 0.5), 0.3)
			tween.tween_property(child, "modulate", Color.YELLOW, 0.3)
			tween.tween_callback(func(): 
				child.text = "🛤️"
				child.modulate = Color.WHITE
			)

func animate_paths_completion():
	"""路径通关动画 - 彩虹效果"""
	for i in range(path_container.get_child_count()):
		var child = path_container.get_child(i)
		if child is Label:
			var tween = create_tween()
			tween.set_loops(5)
			
			# 彩虹颜色循环
			var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.CYAN, Color.BLUE, Color.MAGENTA]
			var symbols = ["🌈", "⭐", "✨", "🎆", "🎉"]
			
			for j in range(colors.size()):
				var color = colors[j]
				var symbol = symbols[j % symbols.size()]
				tween.tween_callback(func(): 
					child.text = symbol
					child.modulate = color
				)
				tween.tween_interval(0.2)

# ========== 倒计时管理函数 ==========
func reset_timer():
	"""重置倒计时到8秒"""
	countdown_timer = QUESTION_TIME
	is_waiting_answer = true
	
	# 重置倒计时条
	if timer_bar:
		timer_bar.value = QUESTION_TIME
		timer_bar.modulate = Color(0.5, 1.0, 0.5)  # 绿色
	
	# 重置倒计时标签
	if timer_label:
		timer_label.text = str(int(QUESTION_TIME))
		timer_label.modulate = Color.WHITE
		timer_label.scale = Vector2(1.0, 1.0)
	
	print("倒计时已重置：%d秒" % int(QUESTION_TIME))

func stop_timer():
	"""停止倒计时"""
	is_waiting_answer = false
	print("倒计时已停止")

func clear_ui_state():
	"""清空UI状态 - 在生成新题目前调用"""
	# 清除反馈信息
	if feedback_panel:
		feedback_panel.visible = false
	
	# 重置所有按钮状态
	for btn in answer_buttons:
		if btn:
			btn.modulate = Color.WHITE
			btn.disabled = false
	
	# 重置路径显示
	for child in path_container.get_children():
		if child is Label:
			child.text = "🛤️"
			child.modulate = Color.WHITE
	
	print("UI状态已清空")

func move_player_forward():
	"""玩家前进动画"""
	var tween = create_tween()
	tween.tween_property(player_sprite, "position:y", player_sprite.position.y - 50, 0.5)
	tween.tween_property(player_sprite, "position:y", player_sprite.position.y, 0.5)

func move_player_back():
	"""玩家后退动画"""
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate", Color.RED, 0.25)
	tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.25)

# ========== 时间系统 ==========
func _process(delta):
	"""每帧更新 - 处理倒计时"""
	if is_waiting_answer and countdown_timer > 0:
		countdown_timer -= delta
		update_timer_display()
		
		# 检查是否超时
		if countdown_timer <= 0:
			countdown_timer = 0  # 确保不会变成负数
			handle_timeout()

func update_timer_display():
	"""更新倒计时显示 - ProgressBar 和 Label"""
	# 更新 ProgressBar（TimerBar）
	if timer_bar:
		timer_bar.value = countdown_timer
		
		# 时间警告颜色变化
		if countdown_timer <= 3.0:
			# 最后3秒变红
			timer_bar.modulate = Color(1.0, 0.3, 0.3)
		elif countdown_timer <= 5.0:
			# 最后5秒变黄
			timer_bar.modulate = Color(1.0, 1.0, 0.5)
		else:
			# 正常时间显示绿色
			timer_bar.modulate = Color(0.5, 1.0, 0.5)
	
	# 更新时间标签
	if timer_label:
		var time_left = max(0, int(ceil(countdown_timer)))
		timer_label.text = str(time_left)
		
		# 时间警告效果
		if countdown_timer <= 3.0:
			# 最后3秒闪烁效果
			timer_label.modulate = Color.RED
			if int(countdown_timer * 2) % 2 == 0:
				timer_label.scale = Vector2(1.2, 1.2)
			else:
				timer_label.scale = Vector2(1.0, 1.0)
		elif countdown_timer <= 5.0:
			timer_label.modulate = Color.YELLOW
			timer_label.scale = Vector2(1.0, 1.0)
		else:
			timer_label.modulate = Color.WHITE
			timer_label.scale = Vector2(1.0, 1.0)

func _on_game_time_updated(time_remaining: float):
	"""更新游戏总时间"""
	if game_timer_label:
		var time_str = TimerManager.get_game_time_string()
		game_timer_label.text = "🕰️ 游戏时间: " + time_str
		
		# 时间警告
		if time_remaining <= 60:
			game_timer_label.modulate = Color.RED
		elif time_remaining <= 180:
			game_timer_label.modulate = Color.YELLOW
		else:
			game_timer_label.modulate = Color.WHITE

func _on_game_time_expired():
	"""游戏时间耗尽"""
	print("游戏时间到！")
	
	# 保存进度
	if TimerManager:
		TimerManager.update_game_progress(3, total_coins, correct_count)
	
	# 停止游戏
	is_waiting_answer = false
	for btn in answer_buttons:
		btn.disabled = true
	
	# 显示提示
	show_feedback("时间到啦！请休息10分钟后再继续冒险。", Color.ORANGE)
	
	# 跳转到休息界面
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")

# ========== 键盘输入支持 ==========
func _input(event):
	"""处理键盘输入"""
	if not is_waiting_answer:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_answer_button_pressed(0)
			KEY_2:
				_on_answer_button_pressed(1)
			KEY_3:
				_on_answer_button_pressed(2)

# ========== 返回按钮设置 ==========
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
		print("MazeScene: 返回按钮设置完成")
	else:
		# 如果没有预设的返回按钮，动态创建一个
		print("MazeScene: 动态创建返回按钮")
		create_back_button()

func create_back_button():
	"""动态创建返回按钮"""
	var new_back_button = Button.new()
	new_back_button.name = "BackButton"
	new_back_button.text = "🏠 返回"
	new_back_button.tooltip_text = "返回主菜单"
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
	print("MazeScene: 返回按钮动态创建完成")

func _on_back_button_pressed():
	"""返回按钮被点击"""
	print("MazeScene: 返回按钮被点击")
	
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
		print("MazeScene: 用户确认返回")
		return_to_main_menu()
	)
	
	# 弹窗关闭后自动销毁
	confirm_dialog.visibility_changed.connect(func():
		if not confirm_dialog.visible:
			confirm_dialog.queue_free()
	)

func return_to_main_menu():
	"""返回主菜单"""
	print("MazeScene: 正在返回主菍单...")
	
	# 保存进度
	if TimerManager:
		TimerManager.update_game_progress(3, total_coins, correct_count)
		print("MazeScene: 进度已保存")
	
	# 显示反馈
	show_feedback("正在返回主菜单...", Color.GREEN)
	
	# 延迟后切换场景
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ========== 主菜单集成 ==========
func get_level_number() -> int:
	"""获取关卡编号 - 用于保存进度"""
	return 3

func get_coins() -> int:
	"""获取金币数量"""
	return total_coins

func get_health_time() -> int:
	"""获取健康时长"""
	if TimerManager:
		return TimerManager.get_remaining_game_time()
	return 0
