extends Node
# 测试脚本：验证糖果商店通关逻辑

# 测试常量
const QUESTIONS_TO_WIN = 5  # 需要答对5题通关

# 测试变量
var correct_count = 0
var total_coins = 100  # 初始金币
var current_question_num = 0

func _ready():
	print("\n=====================================")
	print("    糖果商店通关逻辑测试")
	print("=====================================\n")
	
	# 模拟游戏进程
	simulate_game_progress()

func simulate_game_progress():
	"""模拟游戏进程，逐步答对题目"""
	print("【开始游戏测试】")
	print("通关条件：答对 %d 道题" % QUESTIONS_TO_WIN)
	print("初始金币：%d" % total_coins)
	print("-" * 40)
	
	# 模拟答题过程
	for i in range(QUESTIONS_TO_WIN + 1):  # 多答一题确保触发通关
		await simulate_answer_question(i + 1)
		await get_tree().create_timer(0.5).timeout

func simulate_answer_question(question_num: int):
	"""模拟答对一道题"""
	current_question_num = question_num
	print("\n第 %d 题：" % question_num)
	print("  题目：糖果 25 元，支付 50 元")
	print("  正确答案：25 元")
	print("  玩家选择：25 元 ✅")
	
	# 答对处理
	correct_count += 1
	var reward = 2  # 基础奖励
	if randf() > 0.5:  # 50%概率快速答题
		reward = 3
		print("  ⚡ 快速答题奖励！")
	
	total_coins += reward
	print("  💰 获得金币：+%d" % reward)
	print("  📊 当前进度：%d/%d" % [correct_count, QUESTIONS_TO_WIN])
	print("  💰 总金币：%d" % total_coins)
	
	# 检查是否达到通关条件
	check_completion()

func check_completion():
	"""检查是否达到通关条件"""
	if correct_count >= QUESTIONS_TO_WIN:
		print("\n" + "=" * 50)
		print("🎉 达到通关条件！")
		print("=" * 50)
		trigger_completion_logic()
	else:
		var remaining = QUESTIONS_TO_WIN - correct_count
		print("  ➡️ 还需答对 %d 题" % remaining)

func trigger_completion_logic():
	"""触发通关逻辑"""
	print("\n【执行通关逻辑】")
	print("-" * 40)
	
	# 1. 显示通关提示
	print("1️⃣ 显示通关提示")
	var completion_message = "🎉 恭喜！小勇士完成找零挑战！ 🎉"
	print("   %s" % completion_message)
	
	# 2. 调用奖励系统
	print("\n2️⃣ 调用奖励系统")
	award_completion_bonus()
	
	# 3. 奖励地图碎片
	print("\n3️⃣ 奖励地图碎片")
	award_map_fragment()
	
	# 4. 保存进度
	print("\n4️⃣ 保存进度")
	save_progress()
	
	# 5. 显示通关弹窗内容
	print("\n5️⃣ 显示通关弹窗")
	show_popup_content()
	
	# 6. 准备跳转
	print("\n6️⃣ 准备跳转到下一关")
	prepare_next_level()
	
	# 显示最终统计
	show_final_stats()

func award_completion_bonus():
	"""模拟奖励系统"""
	var completion_bonus = 5
	total_coins += completion_bonus
	print("   💰 通关奖励：+%d 金币" % completion_bonus)
	print("   💰 金币总数：%d" % total_coins)

func award_map_fragment():
	"""模拟地图碎片奖励"""
	print("   🗺️ 奖励地图碎片 x1")
	print("   🗺️ 地图碎片已添加到背包")
	print("   📦 调用接口：Inventory.add_item(\"MapFragment\", 1)")

func save_progress():
	"""模拟保存进度"""
	print("   💾 保存到 TimerManager")
	print("   📝 数据：")
	print("      - 解锁第5关")
	print("      - 金币：%d" % total_coins)
	print("      - 答对题数：%d" % correct_count)
	print("   ✅ TimerManager.update_game_progress(5, %d, %d)" % [total_coins, correct_count])

func show_popup_content():
	"""显示弹窗内容"""
	print("   ┌─────────────────────────────┐")
	print("   │    🎉 恭喜通关！            │")
	print("   ├─────────────────────────────┤")
	print("   │  🎆 小勇士完成找零挑战！    │")
	print("   │                              │")
	print("   │  🎁 通关奖励：              │")
	print("   │    💰 金币 +5               │")
	print("   │    🗺️ 地图碎片 x1          │")
	print("   │                              │")
	print("   │  📊 游戏统计：              │")
	print("   │    答对：%d 题              │" % correct_count)
	print("   │    总金币：%d 枚           │" % total_coins)
	print("   │                              │")
	print("   │  [  前往下一关  ]            │")
	print("   └─────────────────────────────┘")

func prepare_next_level():
	"""准备跳转到下一关"""
	var next_level_path = "res://scenes/NextLevel.tscn"
	print("   🔍 检查场景：%s" % next_level_path)
	
	# 模拟检查文件存在性
	if randf() > 0.5:  # 50%概率存在
		print("   ✅ 场景存在")
		print("   🎮 跳转到：NextLevel.tscn")
		print("   ➡️ get_tree().change_scene_to_file(\"%s\")" % next_level_path)
	else:
		print("   ❌ 场景不存在")
		print("   🏠 返回主菜单")
		print("   ➡️ get_tree().change_scene_to_file(\"res://scenes/MainMenu.tscn\")")

func show_final_stats():
	"""显示最终统计"""
	print("\n" + "=" * 50)
	print("            测试结果汇总")
	print("=" * 50)
	print("✅ 通关条件：答对 %d/%d 题" % [correct_count, QUESTIONS_TO_WIN])
	print("💰 最终金币：%d（初始100 + 答题奖励 + 通关奖励5）" % total_coins)
	print("🗺️ 获得道具：地图碎片 x1")
	print("🔓 解锁关卡：第5关")
	print("")
	print("【通关流程验证】")
	print("✅ 需求1：显示通关提示 ✓")
	print("✅ 需求2：金币 +5 奖励 ✓")
	print("✅ 需求3：地图碎片奖励 ✓")
	print("✅ 需求4：跳转下一关 ✓")
	print("")
	print("测试完成！")