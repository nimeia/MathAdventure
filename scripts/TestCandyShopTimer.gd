extends Node
# 测试脚本：验证糖果商店倒计时系统

# 测试常量
const QUESTION_TIME = 10.0

# 测试变量
var countdown_timer = QUESTION_TIME
var is_waiting_answer = true
var correct_change = 25
var test_timer_bar: ProgressBar
var test_timer_label: Label

func _ready():
	print("\n========================================")
	print("    糖果商店倒计时系统测试")
	print("========================================\n")
	
	# 创建模拟UI元素
	create_test_ui()
	
	# 开始倒计时测试
	start_timer_test()

func create_test_ui():
	"""创建测试用的UI元素"""
	# 创建进度条
	test_timer_bar = ProgressBar.new()
	test_timer_bar.max_value = QUESTION_TIME
	test_timer_bar.value = QUESTION_TIME
	test_timer_bar.size = Vector2(400, 40)
	test_timer_bar.position = Vector2(100, 100)
	add_child(test_timer_bar)
	
	# 创建标签
	test_timer_label = Label.new()
	test_timer_label.text = str(int(QUESTION_TIME))
	test_timer_label.position = Vector2(300, 150)
	test_timer_label.add_theme_font_size_override("font_size", 32)
	add_child(test_timer_label)
	
	print("测试UI创建完成")

func start_timer_test():
	"""开始倒计时测试"""
	print("【倒计时测试开始】")
	print("-" * 40)
	print("初始设置：")
	print("  倒计时总时长：%d 秒" % int(QUESTION_TIME))
	print("  TimerBar 最大值：%d" % int(test_timer_bar.max_value))
	print("  TimerBar 当前值：%d" % int(test_timer_bar.value))
	print("  TimerLabel 显示：%s" % test_timer_label.text)
	print("")
	
	# 重置倒计时
	reset_timer()

func reset_timer():
	"""重置倒计时 - 每道题10秒"""
	print("执行 reset_timer()")
	countdown_timer = QUESTION_TIME
	is_waiting_answer = true
	
	# 重置 TimerBar 显示
	if test_timer_bar:
		test_timer_bar.max_value = QUESTION_TIME
		test_timer_bar.value = QUESTION_TIME
		print("  TimerBar 已重置: %d/%d" % [int(test_timer_bar.value), int(test_timer_bar.max_value)])
	
	# 重置时间标签
	if test_timer_label:
		test_timer_label.text = str(int(QUESTION_TIME))
		test_timer_label.modulate = Color.WHITE
		print("  TimerLabel 已重置: %s 秒" % test_timer_label.text)
	
	print("")

func _process(delta):
	"""每帧更新 - 处理倒计时"""
	if is_waiting_answer and countdown_timer > 0:
		# 倒计时递减
		countdown_timer -= delta
		
		# 更新显示
		update_timer_display()
		
		# 检查是否超时
		if countdown_timer <= 0:
			countdown_timer = 0
			handle_timeout()

func update_timer_display():
	"""更新倒计时显示"""
	# 更新 TimerBar
	if test_timer_bar:
		test_timer_bar.value = countdown_timer
		
		# 时间警告颜色变化
		if countdown_timer <= 3.0:
			test_timer_bar.modulate = Color.RED
		elif countdown_timer <= 5.0:
			test_timer_bar.modulate = Color.YELLOW
		else:
			test_timer_bar.modulate = Color.GREEN
	
	# 更新标签
	if test_timer_label:
		var time_left = max(0, int(ceil(countdown_timer)))
		test_timer_label.text = str(time_left)
		
		# 时间警告效果
		if countdown_timer <= 3.0:
			test_timer_label.modulate = Color.RED
			# 闪烁效果
			if int(countdown_timer * 2) % 2 == 0:
				test_timer_label.scale = Vector2(1.2, 1.2)
			else:
				test_timer_label.scale = Vector2(1.0, 1.0)
		elif countdown_timer <= 5.0:
			test_timer_label.modulate = Color.YELLOW
			test_timer_label.scale = Vector2(1.0, 1.0)
		else:
			test_timer_label.modulate = Color.WHITE
			test_timer_label.scale = Vector2(1.0, 1.0)
	
	# 每秒输出一次
	if int(countdown_timer) != int(countdown_timer + delta):
		print_timer_status()

func print_timer_status():
	"""打印倒计时状态"""
	var time_left = int(countdown_timer)
	var bar_color = "绿色"
	var label_color = "白色"
	
	if countdown_timer <= 3.0:
		bar_color = "红色（闪烁）"
		label_color = "红色（跳动）"
	elif countdown_timer <= 5.0:
		bar_color = "黄色"
		label_color = "黄色"
	
	print("倒计时: %d 秒 | TimerBar: %s | TimerLabel: %s" % [time_left, bar_color, label_color])
	
	# 特殊时间点提示
	if time_left == 5:
		print("  ⚠️ 注意：进入黄色警告阶段")
	elif time_left == 3:
		print("  🚨 警告：进入红色紧急阶段，开始闪烁")

func handle_timeout():
	"""处理超时"""
	print("\n⏰ 时间到！")
	print("-" * 40)
	is_waiting_answer = false
	
	print("超时处理：")
	print("  1. 禁用所有答案按钮")
	print("  2. 显示正确答案（绿色）：%d 元" % correct_change)
	print("  3. 显示提示：'时间到！请再试一次'")
	print("  4. 2秒后生成新题")
	print("")
	
	# 显示超时信息
	test_timer_label.text = "超时!"
	test_timer_label.modulate = Color.ORANGE
	test_timer_bar.value = 0
	test_timer_bar.modulate = Color.ORANGE
	
	# 模拟2秒后重新开始
	await get_tree().create_timer(2.0).timeout
	print("模拟重新生成题目...")
	reset_timer()
	
func _input(event):
	"""处理输入事件"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				print("\n手动重置倒计时")
				reset_timer()
			KEY_SPACE:
				print("\n模拟答题（停止倒计时）")
				is_waiting_answer = false
				print("倒计时已停止在: %d 秒" % int(countdown_timer))
			KEY_ESCAPE:
				print("\n测试结束")
				get_tree().quit()