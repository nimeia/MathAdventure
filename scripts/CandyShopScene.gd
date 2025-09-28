extends Node2D
class_name CandyShopScene

# ========== 第四关：糖果商店找零 ==========
# 玩家需要计算找零，训练100以内的减法
# 价格范围：10~50元
# 支付范围：价格+10 到 100元

# ========== 游戏常量 ==========
const QUESTION_TIME = 10.0  # 每题10秒倒计时
const QUESTIONS_TO_WIN = 5  # 需要答对5题通关
const BASE_COIN_REWARD = 2  # 基础答对奖励
const FAST_BONUS_TIME = 6.0  # 快速答题时间阈值
const FAST_BONUS_COIN = 1  # 快速答题额外奖励

# ========== 题目生成常量 ==========
const MIN_PRICE = 10  # 糖果最小价格
const MAX_PRICE = 50  # 糖果最大价格
const MIN_PAY_AMOUNT = 10  # 支付金额最少多出
const MAX_PAY_AMOUNT = 100  # 支付金额最大值
const MIN_WRONG_DIFF = 1  # 错误答案最小差值
const MAX_WRONG_DIFF = 10  # 错误答案最大差值

# ========== 游戏状态 ==========
var current_question_num = 0  # 当前题目编号
var correct_count = 0  # 答对题目数
var total_coins = 0  # 总金币数
var current_price = 0  # 当前糖果价格
var current_payment = 0  # 当前支付金额
var correct_change = 0  # 正确的找零
var countdown_timer = 0.0  # 倒计时
var is_waiting_answer = false  # 是否等待答案
var question_start_time = 0.0  # 题目开始时间

# ========== 节点引用 ==========
@onready var price_label = $UI/ShopArea/PriceLabel
@onready var pay_label = $UI/ShopArea/PayLabel
@onready var answer_container = $UI/ShopArea/AnswerContainer
@onready var answer_buttons = [
	$UI/ShopArea/AnswerContainer/AnswerBtn1,
	$UI/ShopArea/AnswerContainer/AnswerBtn2,
	$UI/ShopArea/AnswerContainer/AnswerBtn3
]
@onready var timer_bar = $UI/TopPanel/TimerBar
@onready var timer_label = $UI/TopPanel/TimerLabel
@onready var coin_label = $UI/TopPanel/CoinLabel
@onready var progress_label = $UI/TopPanel/ProgressLabel
@onready var game_timer_label = $UI/TopPanel/GameTimerLabel
@onready var back_button = $UI/TopPanel/BackButton
@onready var feedback_panel = $UI/FeedbackPanel
@onready var feedback_label = $UI/FeedbackPanel/FeedbackLabel
@onready var complete_popup = $UI/CompletePopup
@onready var shop_sprite = $UI/ShopArea/ShopSprite
@onready var candy_display = $UI/ShopArea/CandyDisplay

# ========== 初始化 ==========
func _ready():
	print("第四关：糖果商店 开始！")
	setup_ui()
	setup_health_timer()  # 连接健康时长系统
	setup_back_button()
	load_global_data()
	start_candy_shop_game()

func setup_health_timer():
	"""设置健康时长控制 - 接入 TimerManager"""
	if TimerManager:
		# 连接健康时长信号
		TimerManager.game_time_updated.connect(_on_game_time_updated)
		TimerManager.game_time_expired.connect(_on_game_time_expired)
		
		# 启动游戏计时器
		TimerManager.start_game_timer()
		print("TimerManager 已连接，健康时长系统已启动")
	else:
		print("警告: TimerManager 未找到")

func setup_ui():
	"""初始化UI界面"""
	# 初始化倒计时条（10秒）
	if timer_bar:
		timer_bar.max_value = QUESTION_TIME  # 10秒
		timer_bar.value = QUESTION_TIME
		timer_bar.show_percentage = false
		print("TimerBar 初始化: 最大值=%d秒" % int(QUESTION_TIME))
	else:
		print("警告: TimerBar 节点未找到")
	
	# 初始化倒计时标签
	if timer_label:
		timer_label.text = str(int(QUESTION_TIME))
		print("TimerLabel 初始化: %s 秒" % timer_label.text)
	else:
		print("警告: TimerLabel 节点未找到")
	
	# 连接答案按钮信号
	for i in range(answer_buttons.size()):
		if answer_buttons[i]:
			answer_buttons[i].pressed.connect(_on_answer_button_pressed.bind(i))
	
	# 隐藏反馈和弹窗
	if feedback_panel:
		feedback_panel.visible = false
	if complete_popup:
		complete_popup.visible = false
	
	# 更新进度显示
	update_progress_display()
	
	# 初始化游戏时间显示
	if game_timer_label and TimerManager:
		var time_str = TimerManager.get_game_time_string()
		game_timer_label.text = "🕰️ 游戏时间: " + time_str
	
	print("CandyShop: UI初始化完成")

func setup_back_button():
	"""设置返回按钮"""
	if not back_button:
		back_button = $UI/TopPanel/BackButton
	
	if back_button:
		back_button.text = "🏠 返回"
		back_button.tooltip_text = "返回主菜单"
		
		# 连接信号
		if not back_button.pressed.is_connected(_on_back_button_pressed):
			back_button.pressed.connect(_on_back_button_pressed)
		print("CandyShop: 返回按钮设置完成")
	else:
		print("CandyShop: 动态创建返回按钮")
		create_back_button()

func create_back_button():
	"""动态创建返回按钮"""
	var new_back_button = Button.new()
	new_back_button.name = "BackButton"
	new_back_button.text = "🏠 返回"
	new_back_button.tooltip_text = "返回主菜单"
	new_back_button.size = Vector2(100, 40)
	new_back_button.position = Vector2(10, 10)
	
	var top_panel = $UI/TopPanel
	if top_panel:
		top_panel.add_child(new_back_button)
	else:
		$UI.add_child(new_back_button)
	
	new_back_button.pressed.connect(_on_back_button_pressed)
	back_button = new_back_button

func load_global_data():
	"""加载全局游戏数据"""
	if TimerManager:
		var save_data = TimerManager.load_game_progress()
		if not save_data.is_empty():
			total_coins = save_data.get("coins", 0)
			print("CandyShop: 加载金币数 %d" % total_coins)
			update_coin_display()

# ========== 游戏流程 ==========
func start_candy_shop_game():
	"""开始糖果商店游戏"""
	current_question_num = 0
	correct_count = 0
	generate_new_question()

func generate_new_question():
	"""生成新的找零题目"""
	current_question_num += 1
	print("\n========== 生成第 %d 题 ==========" % current_question_num)
	
	# 步骤1: 随机生成糖果价格（10~50）
	current_price = randi_range(MIN_PRICE, MAX_PRICE)
	print("步骤1 - 糖果价格: %d 元" % current_price)
	
	# 步骤2: 随机生成支付金额（价格+10 到 100）
	var min_payment = current_price + MIN_PAY_AMOUNT
	var max_payment = min(MAX_PAY_AMOUNT, 100)  # 确保不超过100
	current_payment = randi_range(min_payment, max_payment)
	print("步骤2 - 支付金额: %d 元 (范围: %d~%d)" % [current_payment, min_payment, max_payment])
	
	# 步骤3: 计算正确找零金额 = 支付金额 - 价格
	correct_change = current_payment - current_price
	print("步骤3 - 正确找零: %d 元 (%d - %d)" % [correct_change, current_payment, current_price])
	
	# 步骤4: 随机生成2个错误答案（与正确答案差值1~10）
	var wrong_answers = generate_wrong_answers(correct_change)
	print("步骤4 - 错误答案: %s" % str(wrong_answers))
	
	# 步骤5: 将价格显示到 PriceLabel，将支付金额显示到 PayLabel
	display_question()
	
	# 步骤6: 将正确答案和错误答案随机分配到 AnswerBtn1~3
	var all_options = [correct_change] + wrong_answers
	all_options.shuffle()  # 随机打乱顺序
	assign_answers_to_buttons(all_options)
	print("步骤6 - 按钮答案分配: %s" % str(all_options))
	
	# 重置倒计时
	reset_timer()
	
	# 清除反馈
	if feedback_panel:
		feedback_panel.visible = false
	
	# 启用答案按钮
	for btn in answer_buttons:
		if btn:
			btn.disabled = false
			btn.modulate = Color.WHITE
	
	print("========== 题目生成完成 ==========")

func display_question():
	"""步骤5: 将价格显示到 PriceLabel，将支付金额显示到 PayLabel"""
	if price_label:
		price_label.text = "🍬 糖果价格：%d 元" % current_price
		print("显示价格: %s" % price_label.text)
	else:
		print("警告: PriceLabel 节点未找到")
	
	if pay_label:
		pay_label.text = "💰 小勇士支付：%d 元" % current_payment
		print("显示支付: %s" % pay_label.text)
	else:
		print("警告: PayLabel 节点未找到")
	
	# 显示糖果图标（装饰性）
	if candy_display:
		candy_display.text = get_random_candy_emoji()

func get_random_candy_emoji() -> String:
	"""获取随机糖果表情"""
	var candies = ["🍬", "🍭", "🍫", "🧁", "🍩", "🍪", "🍮", "🍰"]
	return candies[randi() % candies.size()]

func generate_wrong_answers(correct_answer: int) -> Array:
	"""步骤4: 随机生成2个错误答案（与正确答案差值1~10）"""
	var wrong_answers = []
	var attempts = 0
	var max_attempts = 20  # 防止无限循环
	
	while wrong_answers.size() < 2 and attempts < max_attempts:
		attempts += 1
		
		# 随机决定是加还是减
		var is_add = randf() > 0.5
		var diff = randi_range(MIN_WRONG_DIFF, MAX_WRONG_DIFF)
		
		var wrong_value: int
		if is_add:
			wrong_value = correct_answer + diff
		else:
			wrong_value = correct_answer - diff
		
		# 确保错误答案合理（非负且不等于正确答案）
		if wrong_value >= 0 and wrong_value != correct_answer and wrong_value not in wrong_answers:
			wrong_answers.append(wrong_value)
			print("  生成错误答案: %d (正确答案%s%d)" % [wrong_value, "+" if wrong_value > correct_answer else "-", abs(diff)])
	
	# 如果没有生成够2个，强制生成
	while wrong_answers.size() < 2:
		if correct_answer > 5:
			wrong_answers.append(correct_answer - randi_range(1, 5))
		else:
			wrong_answers.append(correct_answer + randi_range(1, 5))
	
	return wrong_answers

func assign_answers_to_buttons(options: Array):
	"""步骤6: 将正确答案和错误答案随机分配到 AnswerBtn1~3"""
	for i in range(min(options.size(), answer_buttons.size())):
		if answer_buttons[i]:
			var answer_value = options[i]
			answer_buttons[i].text = "找零 %d 元" % answer_value
			answer_buttons[i].set_meta("answer_value", answer_value)
			
			# 标记哪个按钮是正确答案（用于调试）
			if answer_value == correct_change:
				print("  正确答案在按钮%d: %d 元" % [i+1, answer_value])
			else:
				print("  错误答案在按钮%d: %d 元" % [i+1, answer_value])
		else:
			print("警告: AnswerBtn%d 未找到" % (i+1))

func reset_timer():
	"""重置倒计时 - 每道题10秒"""
	print("重置倒计时：%d秒" % QUESTION_TIME)
	countdown_timer = QUESTION_TIME  # 10秒倒计时
	is_waiting_answer = true
	question_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						  Time.get_time_dict_from_system().minute * 60 + \
						  Time.get_time_dict_from_system().second
	
	# 重置 TimerBar 显示
	if timer_bar:
		timer_bar.max_value = QUESTION_TIME
		timer_bar.value = QUESTION_TIME
		timer_bar.show_percentage = false
		print("TimerBar 已重置: %d/%d" % [int(timer_bar.value), int(timer_bar.max_value)])
	
	# 重置时间标签
	if timer_label:
		timer_label.text = str(int(QUESTION_TIME))
		timer_label.modulate = Color.WHITE

# ========== 答题判定逻辑 ==========
func _on_answer_button_pressed(button_index: int):
	"""答案按钮被点击 - 执行答题判定"""
	if not is_waiting_answer:
		print("不在答题状态，忽略点击")
		return
	
	# 停止等待答案
	is_waiting_answer = false
	
	# 获取选中的按钮和答案
	var selected_btn = answer_buttons[button_index]
	var selected_answer = selected_btn.get_meta("answer_value")
	
	print("\n========== 答题判定 ==========\n玩家选择: %d 元\n正确答案: %d 元" % [selected_answer, correct_change])
	
	# 禁用所有按钮（防止重复点击）
	disable_all_buttons()
	
	# 检查答案是否正确
	if selected_answer == correct_change:
		handle_correct_answer(selected_btn, button_index + 1)
	else:
		handle_wrong_answer(selected_btn, button_index + 1)

func disable_all_buttons():
	"""禁用所有答案按钮"""
	for btn in answer_buttons:
		if btn:
			btn.disabled = true

func enable_all_buttons():
	"""启用所有答案按钮"""
	for btn in answer_buttons:
		if btn:
			btn.disabled = false
			btn.modulate = Color.WHITE  # 恢复颜色

func handle_correct_answer(button: Button, button_num: int):
	"""处理正确答案"""
	print("✅ 答对了！点击的是按钮%d" % button_num)
	
	# 计算答题时间
	var current_time = Time.get_time_dict_from_system().hour * 3600 + \
					   Time.get_time_dict_from_system().minute * 60 + \
					   Time.get_time_dict_from_system().second
	var answer_time = current_time - question_start_time
	print("答题用时: %d 秒" % answer_time)
	
	# 计算奖励金币
	var base_reward = 2  # 基础金币 +2
	var time_bonus = 0
	
	# 如果答题时间 ≤ 5秒，额外金币 +1
	if answer_time <= 5:
		time_bonus = 1
		print("⚡ 快速答题奖励！用时%d秒 ≤ 5秒" % answer_time)
	
	var total_reward = base_reward + time_bonus
	
	# 调用全局金币系统：金币 +2 (+1)
	total_coins += total_reward
	update_coin_display()
	
	# 保存进度到全局系统
	if TimerManager:
		TimerManager.update_game_progress(4, total_coins, correct_count + 1)
		print("金币已更新到全局系统: %d" % total_coins)
	
	# 按钮变绿色显示正确
	button.modulate = Color.GREEN
	
	# 显示提示“买到啦！”
	var success_message = "🎉 买到啦！找零正确！"
	if time_bonus > 0:
		success_message += "⚡快速奖励！"
	success_message += " +%d金币" % total_reward
	
	show_feedback(success_message, Color.GREEN)
	print("显示提示: %s" % success_message)
	
	# 增加正确答题计数
	correct_count += 1
	print("当前进度: %d/%d 题" % [correct_count, QUESTIONS_TO_WIN])
	
	# 延迟 2 秒后生成下一道题
	await get_tree().create_timer(2.0).timeout
	print("准备生成下一道题...")
	generate_next_question()

func handle_wrong_answer(button: Button, button_num: int):
	"""处理错误答案"""
	print("❌ 答错了！点击的是按钮%d" % button_num)
	
	# 按钮变红色显示错误
	button.modulate = Color.RED
	
	# 显示正确答案（绿色）
	for i in range(answer_buttons.size()):
		var btn = answer_buttons[i]
		if btn and btn.get_meta("answer_value") == correct_change:
			btn.modulate = Color.GREEN
			print("正确答案在按钮%d: %d 元" % [i + 1, correct_change])
	
	# 显示提示“错误！再试一次”
	var error_message = "❌ 错误！再试一次。正确找零是 %d 元" % correct_change
	show_feedback(error_message, Color.RED)
	print("显示提示: %s" % error_message)
	
	# 延迟 2 秒后重新生成当前题目
	await get_tree().create_timer(2.0).timeout
	print("重新生成当前题目...")
	regenerate_current_question()

func handle_timeout():
	"""处理超时 - 自动判定为错误"""
	print("\n⏰ 时间到！超时未答题")
	is_waiting_answer = false
	
	# 禁用所有按钮
	disable_all_buttons()
	
	# 显示正确答案（绿色高亮）
	for i in range(answer_buttons.size()):
		var btn = answer_buttons[i]
		if btn and btn.get_meta("answer_value") == correct_change:
			btn.modulate = Color.GREEN
			print("正确答案在按钮%d: %d 元" % [i + 1, correct_change])
	
	# 显示“时间到！请再试一次”
	var timeout_message = "⏰ 时间到！请再试一次。正确找零是 %d 元" % correct_change
	show_feedback(timeout_message, Color.ORANGE)
	print("显示提示: %s" % timeout_message)
	
	# 延迟 2 秒后生成新题
	await get_tree().create_timer(2.0).timeout
	print("超时后重新生成当前题目...")
	regenerate_current_question()

# ========== 题目管理 ==========
func generate_next_question():
	"""生成下一道题目 - 检查是否达到通关条件"""
	update_progress_display()
	
	# 检查是否已经答对5道题通关
	if correct_count >= QUESTIONS_TO_WIN:
		print("🎉 答对了%d道题！达到通关条件！" % correct_count)
		complete_candy_shop_challenge()
		return
	
	# 还未达到通关条件，生成下一道新题目
	print("进度: %d/%d，生成下一道题目..." % [correct_count, QUESTIONS_TO_WIN])
	generate_new_question()

func regenerate_current_question():
	"""重新生成当前题目（答错后使用）"""
	print("重新生成当前题目（第%d题）" % current_question_num)
	
	# 不增加 current_question_num，直接重新生成
	current_question_num -= 1  # 减1因为generate_new_question会加1
	generate_new_question()

func complete_candy_shop_challenge():
	"""完成糖果商店找零挑战 - 通关逻辑"""
	print("\n========== 🎉 通关！ 🎉 ==========")
	print("第四关：糖果商店找零挑战 通关！")
	print("答对题目：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
	print("当前金币：%d" % total_coins)
	
	# 停止所有游戏逻辑
	is_waiting_answer = false
	disable_all_buttons()
	
	# 1. 显示通关提示“恭喜！小勇士完成找零挑战！”
	var completion_message = "🎉 恭喜！小勇士完成找零挑战！ 🎉"
	show_feedback(completion_message, Color.GOLD)
	print("显示通关提示: %s" % completion_message)
	
	# 2. 调用奖励系统，给予额外奖励：金币 +5
	award_completion_bonus()
	
	# 3. 奖励一张地图碎片
	award_map_fragment()
	
	# 保存进度到全局系统
	save_completion_progress()
	
	# 显示通关弹窗
	await get_tree().create_timer(3.0).timeout
	show_completion_popup()
	
	# 4. 通关后跳转到下一个场景（NextLevel.tscn）
	await get_tree().create_timer(3.0).timeout
	go_to_next_level()

# ========== 通关奖励系统 ==========
func award_completion_bonus():
	"""调用奖励系统，给予额外奖励：金币 +5"""
	var completion_bonus = 5  # 通关奖励金币
	total_coins += completion_bonus
	update_coin_display()
	
	print("💰 通关奖励：+%d 金币" % completion_bonus)
	print("💰 总金币：%d" % total_coins)

func award_map_fragment():
	"""奖励一张地图碎片（调用已有的关卡奖励接口）"""
	print("🗺️ 奖励地图碎片 x1")
	print("🗺️ 地图碎片已添加到背包")
	
	# 这里可以调用具体的道具系统接口
	# 例如：Inventory.add_item("MapFragment", 1)
	# 目前以打印代替

func save_completion_progress():
	"""保存通关进度到全局系统"""
	if TimerManager:
		# 保存到第5关（下一关），解锁下一关
		TimerManager.update_game_progress(5, total_coins, correct_count)
		print("💾 进度已保存：解锁第5关，金币%d" % total_coins)
	else:
		print("⚠️ 警告: TimerManager 未找到，无法保存进度")

func show_completion_popup():
	"""显示通关弹窗 - 展示奖励内容"""
	if not complete_popup:
		print("警告: complete_popup 节点未找到，跳过弹窗显示")
		return
	
	complete_popup.visible = true
	print("显示通关弹窗")
	
	# 设置弹窗内容（如果有对应节点）
	var title_label = complete_popup.get_node_or_null("VBoxContainer/TitleLabel")
	if title_label:
		title_label.text = "🎉 恭喜通关！"
	
	var stats_label = complete_popup.get_node_or_null("VBoxContainer/StatsLabel")
	if stats_label:
		var stats_text = "🎆 小勇士完成找零挑战！\n\n"
		stats_text += "🎁 通关奖励：\n"
		stats_text += "💰 金币 +5\n"
		stats_text += "🗺️ 地图碎片 x1\n\n"
		stats_text += "📊 游戏统计：\n"
		stats_text += "答对：%d 题\n" % correct_count
		stats_text += "总金币：%d 枚" % total_coins
		stats_label.text = stats_text
	
	var continue_btn = complete_popup.get_node_or_null("VBoxContainer/ContinueButton")
	if continue_btn:
		continue_btn.text = "前往下一关"
		if not continue_btn.pressed.is_connected(_on_continue_to_next_level):
			continue_btn.pressed.connect(_on_continue_to_next_level)

func go_to_next_level():
	"""通关后跳转到下一个场景（NextLevel.tscn）"""
	print("\n🚀 准备跳转到下一关...")
	
	# 检查下一关场景是否存在
	var next_level_path = "res://scenes/NextLevel.tscn"
	
	if ResourceLoader.exists(next_level_path):
		print("🎮 加载下一关: %s" % next_level_path)
		show_feedback("正在前往下一关...", Color.GREEN)
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("⚠️ 下一关场景不存在：%s" % next_level_path)
		print("🏠 返回主菜单")
		# 如果 NextLevel.tscn 不存在，返回主菜单
		show_feedback("所有关卡已完成！返回主菜单...", Color.GOLD)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_continue_to_next_level():
	"""继续按钮被点击 - 跳转到下一关"""
	print("用户点击继续按钮")
	complete_popup.visible = false
	go_to_next_level()

# ========== 倒计时系统 ==========
func _process(delta: float):
	"""每帧更新 - 处理倒计时"""
	if is_waiting_answer and countdown_timer > 0:
		# 输出调试信息（每秒一次）
		var old_timer = countdown_timer
		
		# 倒计时递减
		countdown_timer -= delta
		
		# 检查是否跨越了整数秒
		if int(old_timer) != int(countdown_timer):
			print("倒计时: %d 秒" % int(countdown_timer))
		
		# 更新TimerBar和显示
		update_timer_display()
		
		# 检查是否超时
		if countdown_timer <= 0:
			countdown_timer = 0
			handle_timeout()  # 时间到后自动判定为错误

func update_timer_display():
	"""更新倒计时显示 - TimerBar 和 TimerLabel"""
	# 更新 TimerBar 显示剩余时间
	if timer_bar:
		timer_bar.value = countdown_timer
		
		# 时间警告颜色变化
		if countdown_timer <= 3.0:
			# 最后3秒变红
			timer_bar.modulate = Color.RED
			if int(countdown_timer * 2) % 2 == 0:  # 闪烁效果
				timer_bar.modulate = Color(1.0, 0.5, 0.5)
		elif countdown_timer <= 5.0:
			# 5秒时变黄
			timer_bar.modulate = Color.YELLOW
		else:
			# 正常时间显示绿色
			timer_bar.modulate = Color.GREEN
	
	# 更新倒计时标签
	if timer_label:
		var time_left = max(0, int(ceil(countdown_timer)))
		timer_label.text = str(time_left)
		
		# 时间警告效果
		if countdown_timer <= 3.0:
			# 最后3秒显示红色并放大
			timer_label.modulate = Color.RED
			if int(countdown_timer * 2) % 2 == 0:
				timer_label.scale = Vector2(1.2, 1.2)  # 跳动效果
			else:
				timer_label.scale = Vector2(1.0, 1.0)
		elif countdown_timer <= 5.0:
			timer_label.modulate = Color.YELLOW
			timer_label.scale = Vector2(1.0, 1.0)
	else:
		timer_label.modulate = Color.WHITE
		timer_label.scale = Vector2(1.0, 1.0)

func update_coin_display():
	"""更新金币显示"""
	if coin_label:
		coin_label.text = "💰 金币: %d" % total_coins

func update_progress_display():
	"""更新进度显示"""
	if progress_label:
		progress_label.text = "进度: %d/%d" % [correct_count, QUESTIONS_TO_WIN]

func show_feedback(text: String, color: Color):
	"""显示反馈信息"""
	if feedback_panel:
		feedback_panel.visible = true
		if feedback_label:
			feedback_label.text = text
			feedback_label.modulate = color

# ========== 返回按钮 ==========
func _on_back_button_pressed():
	"""返回按钮被点击"""
	print("CandyShop: 返回按钮被点击")
	show_return_confirmation()

func show_return_confirmation():
	"""显示返回确认对话框"""
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.dialog_text = "确定要返回主菜单吗？\n当前关卡的进度将会保存。"
	confirm_dialog.title = "确认返回"
	confirm_dialog.ok_button_text = "确定返回"
	confirm_dialog.add_cancel_button("继续游戏")
	
	get_tree().current_scene.add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	confirm_dialog.confirmed.connect(func():
		print("CandyShop: 用户确认返回")
		return_to_main_menu()
	)
	
	confirm_dialog.visibility_changed.connect(func():
		if not confirm_dialog.visible:
			confirm_dialog.queue_free()
	)

func return_to_main_menu():
	"""返回主菜单"""
	print("CandyShop: 正在返回主菜单...")
	
	# 保存进度
	if TimerManager:
		TimerManager.update_game_progress(4, total_coins, correct_count)
	
	show_feedback("正在返回主菜单...", Color.GREEN)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ========== 主菜单集成 ==========
func get_level_number() -> int:
	"""获取关卡编号"""
	return 4

func get_coins() -> int:
	"""获取金币数量"""
	return total_coins

func get_health_time() -> int:
	"""获取健康时长"""
	if TimerManager:
		return TimerManager.get_remaining_game_time()
	return 0

# ========== 健康时长回调 ==========
func _on_game_time_updated(time_remaining: float):
	"""游戏时间更新回调"""
	# 更新总游戏时间显示
	if TimerManager and game_timer_label:
		var time_str = TimerManager.get_game_time_string()
		game_timer_label.text = "🕰️ 游戏时间: " + time_str
		
		# 时间警告颜色变化
		if time_remaining <= 60:
			# 最后1分钟变红
			game_timer_label.modulate = Color.RED
			print("⚠️ 游戏时间剩余: %d 秒" % int(time_remaining))
		elif time_remaining <= 180:
			# 最后3分钟变黄
			game_timer_label.modulate = Color.YELLOW
		else:
			# 正常时间显示白色
			game_timer_label.modulate = Color.WHITE

func _on_game_time_expired():
	"""游戏时间耗尽回调"""
	print("游戏时间到！")
	
	# 保存进度
	if TimerManager:
		TimerManager.update_game_progress(4, total_coins, correct_count)
	
	# 停止答题
	is_waiting_answer = false
	disable_all_buttons()
	
	# 显示提示
	show_feedback("时间到啦！请休息10分钟后再继续冒险。", Color.ORANGE)
	
	# 跳转到休息界面
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
