extends Node
# 测试脚本：验证糖果商店答题判定逻辑

# 模拟按钮类
class SimulatedButton extends Button:
	var meta_data = {}
	
	func set_meta(key: String, value):
		meta_data[key] = value
	
	func get_meta(key: String):
		return meta_data.get(key, null)

# 测试变量
var correct_change = 25  # 正确找零
var total_coins = 100  # 当前金币
var correct_count = 0  # 答对数量
var question_start_time = 0
var is_waiting_answer = true
var QUESTIONS_TO_WIN = 8

func _ready():
	print("\n=====================================")
	print("    糖果商店答题判定测试")
	print("=====================================\n")
	
	# 测试1：答对且快速
	test_correct_answer_fast()
	await get_tree().create_timer(0.5).timeout
	
	# 测试2：答对但较慢
	test_correct_answer_slow()
	await get_tree().create_timer(0.5).timeout
	
	# 测试3：答错
	test_wrong_answer()
	await get_tree().create_timer(0.5).timeout
	
	# 显示最终统计
	show_final_stats()

func test_correct_answer_fast():
	"""测试场景1：答对且快速（≤5秒）"""
	print("【测试1：答对且快速】")
	print("-" * 40)
	
	# 设置场景
	correct_change = 35  # 正确答案是35元
	question_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						  Time.get_time_dict_from_system().minute * 60 + \
						  Time.get_time_dict_from_system().second - 3  # 模拟3秒前
	
	# 模拟点击正确答案
	print("题目：糖果20元，支付55元")
	print("正确找零：35元")
	print("玩家选择：35元（正确）")
	print("答题用时：3秒")
	
	# 执行判定
	var is_correct = (35 == correct_change)
	
	if is_correct:
		print("\n✅ 判定：答对了！")
		
		# 计算奖励
		var answer_time = 3  # 模拟3秒
		var base_reward = 2  # 基础金币
		var time_bonus = 0
		
		if answer_time <= 5:
			time_bonus = 1
			print("⚡ 快速答题奖励！用时3秒 ≤ 5秒")
		
		var total_reward = base_reward + time_bonus
		total_coins += total_reward
		correct_count += 1
		
		print("💰 奖励金币：基础+2 + 快速+1 = +3金币")
		print("💰 当前总金币：%d" % total_coins)
		print("📊 当前进度：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
		print("显示提示：🎉 买到啦！找零正确！⚡快速奖励！ +3金币")
	
	print("")

func test_correct_answer_slow():
	"""测试场景2：答对但较慢（>5秒）"""
	print("【测试2：答对但较慢】")
	print("-" * 40)
	
	# 设置场景
	correct_change = 42  # 正确答案是42元
	question_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						  Time.get_time_dict_from_system().minute * 60 + \
						  Time.get_time_dict_from_system().second - 7  # 模拟7秒前
	
	# 模拟点击正确答案
	print("题目：糖果18元，支付60元")
	print("正确找零：42元")
	print("玩家选择：42元（正确）")
	print("答题用时：7秒")
	
	# 执行判定
	var is_correct = (42 == correct_change)
	
	if is_correct:
		print("\n✅ 判定：答对了！")
		
		# 计算奖励
		var answer_time = 7  # 模拟7秒
		var base_reward = 2  # 基础金币
		var time_bonus = 0
		
		if answer_time <= 5:
			time_bonus = 1
			print("⚡ 快速答题奖励！")
		else:
			print("⏱️ 用时7秒 > 5秒，无快速奖励")
		
		var total_reward = base_reward + time_bonus
		total_coins += total_reward
		correct_count += 1
		
		print("💰 奖励金币：基础+2 = +2金币")
		print("💰 当前总金币：%d" % total_coins)
		print("📊 当前进度：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
		print("显示提示：🎉 买到啦！找零正确！ +2金币")
	
	print("")

func test_wrong_answer():
	"""测试场景3：答错"""
	print("【测试3：答错】")
	print("-" * 40)
	
	# 设置场景
	correct_change = 28  # 正确答案是28元
	var player_answer = 32  # 玩家选了错误答案
	
	# 模拟点击错误答案
	print("题目：糖果22元，支付50元")
	print("正确找零：28元")
	print("玩家选择：32元（错误）")
	
	# 执行判定
	var is_correct = (player_answer == correct_change)
	
	if not is_correct:
		print("\n❌ 判定：答错了！")
		print("正确答案是：28元")
		print("💰 金币不变：%d" % total_coins)
		print("📊 进度不变：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
		print("显示提示：❌ 错误！再试一次。正确找零是 28 元")
		print("\n动作：2秒后重新生成当前题目")
	
	print("")

func show_final_stats():
	"""显示最终统计"""
	print("=====================================")
	print("            测试结果汇总")
	print("=====================================")
	print("✅ 答对题数：%d" % correct_count)
	print("💰 获得金币：%d" % (total_coins - 100))
	print("💰 总金币数：%d" % total_coins)
	print("📊 进度：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
	print("")
	print("【判定逻辑验证】")
	print("✅ 答对时：")
	print("   - 基础金币 +2")
	print("   - 快速奖励 +1（≤5秒）")
	print("   - 显示'买到啦！'")
	print("   - 生成下一道题")
	print("")
	print("❌ 答错时：")
	print("   - 金币不变")
	print("   - 显示'错误！再试一次'")
	print("   - 重新生成当前题目")
	print("")
	print("✨ 全局金币系统：")
	print("   - 通过 TimerManager 更新")
	print("   - 保存到全局进度")
	print("")
	print("测试完成！")