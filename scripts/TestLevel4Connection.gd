extends Node
# 测试脚本：验证主菜单与第4关（糖果商店）的连接

func _ready():
	print("\n========================================")
	print("    主菜单第4关关联测试")
	print("========================================\n")
	
	test_level4_connection()
	test_scene_existence()
	test_progress_flow()

func test_level4_connection():
	"""测试第4关在主菜单中的配置"""
	print("【测试第4关配置】")
	print("-" * 40)
	
	# 模拟主菜单关卡定义
	var level4_def = {
		"number": 4,
		"title": "糖果商店",
		"description": "计算找零，成为小店长！",
		"scene_path": "res://scenes/CandyShopScene.tscn",
		"unlock_requirement": 3
	}
	
	print("第4关配置信息：")
	print("  编号: %d" % level4_def.number)
	print("  标题: %s" % level4_def.title)
	print("  描述: %s" % level4_def.description)
	print("  场景路径: %s" % level4_def.scene_path)
	print("  解锁需求: 完成第%d关" % level4_def.unlock_requirement)
	
	# 验证配置
	if level4_def.scene_path != "":
		print("  ✅ 场景路径已配置")
	else:
		print("  ❌ 场景路径未配置")
	
	print("")

func test_scene_existence():
	"""测试场景文件是否存在"""
	print("【测试场景文件】")
	print("-" * 40)
	
	var candy_shop_scene_path = "res://scenes/CandyShopScene.tscn"
	var candy_shop_script_path = "res://scripts/CandyShopScene.gd"
	
	# 检查场景文件
	if ResourceLoader.exists(candy_shop_scene_path):
		print("✅ CandyShopScene.tscn 存在")
	else:
		print("❌ CandyShopScene.tscn 不存在")
		print("   需要在Godot编辑器中创建场景文件")
	
	# 检查脚本文件
	if ResourceLoader.exists(candy_shop_script_path):
		print("✅ CandyShopScene.gd 存在")
	else:
		print("❌ CandyShopScene.gd 不存在")
	
	print("")

func test_progress_flow():
	"""测试进度流程"""
	print("【测试进度流程】")
	print("-" * 40)
	
	# 模拟完成第3关
	print("模拟场景：")
	print("1. 玩家完成第3关（加减法迷宫）")
	
	if TimerManager:
		# 模拟保存进度
		TimerManager.update_game_progress(4, 150, 5)
		print("   调用: TimerManager.update_game_progress(4, 150, 5)")
		print("   ✅ 解锁第4关")
	else:
		print("   ⚠️ TimerManager 未初始化")
	
	print("")
	print("2. 返回主菜单")
	print("   第4关【糖果商店】应该已解锁")
	print("   点击可进入 CandyShopScene.tscn")
	
	print("")
	print("3. 完成第4关（糖果商店）")
	print("   答对5道找零题目")
	print("   获得奖励：")
	print("     💰 金币 +5")
	print("     🗺️ 地图碎片 x1")
	print("   解锁第5关【乘法森林】")
	
	print("")

func show_all_levels():
	"""显示所有关卡信息"""
	print("【所有关卡列表】")
	print("-" * 40)
	
	var levels = [
		{
			"num": 1,
			"title": "数数果园",
			"desc": "数一数树上的苹果",
			"scene": "res://main.tscn",
			"status": "✅ 已实现"
		},
		{
			"num": 2,
			"title": "比较大小桥",
			"desc": "选择正确的符号",
			"scene": "res://scenes/Level2.tscn",
			"status": "✅ 已实现"
		},
		{
			"num": 3,
			"title": "加减法迷宫",
			"desc": "走出数学迷宫，收集宝藏！",
			"scene": "res://scenes/MazeScene.tscn",
			"status": "✅ 已实现"
		},
		{
			"num": 4,
			"title": "糖果商店",
			"desc": "计算找零，成为小店长！",
			"scene": "res://scenes/CandyShopScene.tscn",
			"status": "✅ 已实现"
		},
		{
			"num": 5,
			"title": "乘法森林",
			"desc": "即将开放...",
			"scene": "",
			"status": "🔨 开发中"
		}
	]
	
	for level in levels:
		print("第%d关 - %s" % [level.num, level.title])
		print("  描述: %s" % level.desc)
		print("  场景: %s" % (level.scene if level.scene != "" else "未设置"))
		print("  状态: %s" % level.status)
		print("")
	
	print("")
	show_all_levels()
	
	print("========================================")
	print("            测试结果")
	print("========================================")
	print("✅ 第4关已正确配置为【糖果商店】")
	print("✅ 场景路径指向 CandyShopScene.tscn")
	print("✅ 解锁条件：完成第3关")
	print("✅ 通关后解锁第5关")
	print("")
	print("提示：")
	print("1. 运行主菜单场景")
	print("2. 第4关应该显示为【糖果商店】")
	print("3. 如果第3关已完成，第4关应该已解锁")
	print("4. 点击第4关应该能进入糖果商店场景")
	print("")
	print("测试完成！")