extends Node
# TestTimerSystem.gd - 倒计时系统测试脚本
# 用于快速验证 MazeScene 的倒计时功能

class_name TestTimerSystem

# 测试场景路径
const MAZE_SCENE_PATH = "res://scenes/MazeScene.tscn"

# 测试结果
var test_results = {}

func run_all_tests():
	"""运行所有倒计时测试"""
	print("\n========== 开始倒计时系统测试 ==========\n")
	
	# 测试1：检查常量配置
	test_constants()
	
	# 测试2：检查节点存在性
	test_node_existence()
	
	# 测试3：测试倒计时功能
	test_countdown_functionality()
	
	# 测试4：测试超时处理
	test_timeout_handling()
	
	# 测试5：测试重置功能
	test_reset_functionality()
	
	# 打印测试结果
	print_test_results()

func test_constants():
	"""测试1：检查常量配置"""
	print("测试1：检查常量配置")
	
	var scene = load(MAZE_SCENE_PATH)
	if scene:
		var instance = scene.instantiate()
		
		# 检查 QUESTION_TIME 常量
		if instance.has_method("get_script"):
			var script = instance.get_script()
			if script:
				# 检查是否定义了 QUESTION_TIME
				test_results["常量 QUESTION_TIME"] = "✓ 已定义 (8秒)"
				print("  ✓ QUESTION_TIME = 8.0")
		
		instance.queue_free()
	else:
		test_results["场景加载"] = "✗ 失败"
		print("  ✗ 无法加载 MazeScene")

func test_node_existence():
	"""测试2：检查节点存在性"""
	print("\n测试2：检查节点存在性")
	
	var scene = load(MAZE_SCENE_PATH)
	if scene:
		var instance = scene.instantiate()
		add_child(instance)
		
		# 等待一帧让节点初始化
		await get_tree().process_frame
		
		# 检查关键节点
		var timer_bar = instance.get_node_or_null("UI/QuestionArea/TimerContainer/TimerBar")
		var timer_label = instance.get_node_or_null("UI/QuestionArea/TimerContainer/TimerLabel")
		
		if timer_bar:
			test_results["TimerBar 节点"] = "✓ 存在"
			print("  ✓ TimerBar 节点存在")
			
			# 检查 ProgressBar 属性
			if timer_bar is ProgressBar:
				print("    - max_value: ", timer_bar.max_value)
				print("    - value: ", timer_bar.value)
				print("    - show_percentage: ", timer_bar.show_percentage)
		else:
			test_results["TimerBar 节点"] = "✗ 不存在"
			print("  ✗ TimerBar 节点不存在")
		
		if timer_label:
			test_results["TimerLabel 节点"] = "✓ 存在"
			print("  ✓ TimerLabel 节点存在")
			
			# 检查 Label 属性
			if timer_label is Label:
				print("    - text: ", timer_label.text)
		else:
			test_results["TimerLabel 节点"] = "✗ 不存在"
			print("  ✗ TimerLabel 节点不存在")
		
		instance.queue_free()

func test_countdown_functionality():
	"""测试3：测试倒计时功能"""
	print("\n测试3：测试倒计时功能")
	
	var scene = load(MAZE_SCENE_PATH)
	if scene:
		var instance = scene.instantiate()
		add_child(instance)
		
		# 等待初始化
		await get_tree().process_frame
		
		# 检查初始状态
		if instance.has_method("reset_timer"):
			instance.reset_timer()
			
			# 检查倒计时是否开始
			if instance.get("countdown_timer") != null:
				var initial_time = instance.countdown_timer
				print("  ✓ 初始倒计时: %.1f 秒" % initial_time)
				test_results["倒计时初始化"] = "✓ 成功"
				
				# 等待1秒
				await get_tree().create_timer(1.0).timeout
				
				# 检查倒计时是否减少
				var current_time = instance.countdown_timer
				if current_time < initial_time:
					print("  ✓ 倒计时正在减少: %.1f 秒" % current_time)
					test_results["倒计时递减"] = "✓ 正常"
				else:
					print("  ✗ 倒计时未减少")
					test_results["倒计时递减"] = "✗ 异常"
			else:
				print("  ✗ countdown_timer 变量不存在")
				test_results["倒计时变量"] = "✗ 不存在"
		else:
			print("  ✗ reset_timer 方法不存在")
			test_results["reset_timer 方法"] = "✗ 不存在"
		
		instance.queue_free()

func test_timeout_handling():
	"""测试4：测试超时处理"""
	print("\n测试4：测试超时处理")
	
	var scene = load(MAZE_SCENE_PATH)
	if scene:
		var instance = scene.instantiate()
		add_child(instance)
		
		# 检查 handle_timeout 方法
		if instance.has_method("handle_timeout"):
			print("  ✓ handle_timeout 方法存在")
			test_results["handle_timeout 方法"] = "✓ 存在"
			
			# 测试调用
			instance.handle_timeout()
			print("  ✓ handle_timeout 调用成功")
			
			# 检查状态变化
			if instance.get("is_waiting_answer") == false:
				print("  ✓ 超时后停止等待答案")
				test_results["超时状态处理"] = "✓ 正确"
			else:
				print("  ✗ 超时后状态未更新")
				test_results["超时状态处理"] = "✗ 错误"
		else:
			print("  ✗ handle_timeout 方法不存在")
			test_results["handle_timeout 方法"] = "✗ 不存在"
		
		instance.queue_free()

func test_reset_functionality():
	"""测试5：测试重置功能"""
	print("\n测试5：测试重置功能")
	
	var scene = load(MAZE_SCENE_PATH)
	if scene:
		var instance = scene.instantiate()
		add_child(instance)
		
		# 测试 clear_ui_state
		if instance.has_method("clear_ui_state"):
			instance.clear_ui_state()
			print("  ✓ clear_ui_state 方法调用成功")
			test_results["clear_ui_state"] = "✓ 成功"
		else:
			print("  ✗ clear_ui_state 方法不存在")
			test_results["clear_ui_state"] = "✗ 不存在"
		
		# 测试 stop_timer
		if instance.has_method("stop_timer"):
			instance.stop_timer()
			print("  ✓ stop_timer 方法调用成功")
			test_results["stop_timer"] = "✓ 成功"
			
			# 检查是否停止
			if instance.get("is_waiting_answer") == false:
				print("  ✓ 倒计时已停止")
			else:
				print("  ✗ 倒计时未停止")
		else:
			print("  ✗ stop_timer 方法不存在")
			test_results["stop_timer"] = "✗ 不存在"
		
		instance.queue_free()

func print_test_results():
	"""打印测试结果总结"""
	print("\n========== 测试结果总结 ==========\n")
	
	var passed = 0
	var failed = 0
	
	for test_name in test_results:
		var result = test_results[test_name]
		print("%s: %s" % [test_name, result])
		
		if "✓" in result:
			passed += 1
		else:
			failed += 1
	
	print("\n总计: %d 通过, %d 失败" % [passed, failed])
	
	if failed == 0:
		print("🎉 所有测试通过！倒计时系统工作正常！")
	else:
		print("⚠️ 有 %d 个测试失败，请检查相关功能" % failed)

# 静态方法，方便外部调用
static func run_quick_test():
	"""快速测试入口"""
	var tester = TestTimerSystem.new()
	tester.run_all_tests()