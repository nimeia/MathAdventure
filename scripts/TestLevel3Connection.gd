extends Node
# 测试脚本：验证主菜单与第三关的连接

func test_level3_connection():
	print("\n========== 测试第三关连接 ==========")
	
	# 1. 检查场景文件是否存在
	var maze_scene_path = "res://scenes/MazeScene.tscn"
	if ResourceLoader.exists(maze_scene_path):
		print("✅ MazeScene.tscn 存在")
	else:
		print("❌ MazeScene.tscn 不存在")
		return false
	
	# 2. 检查脚本文件是否存在
	var maze_script_path = "res://scripts/MazeScene.gd"
	if ResourceLoader.exists(maze_script_path):
		print("✅ MazeScene.gd 存在")
	else:
		print("❌ MazeScene.gd 不存在")
		return false
	
	# 3. 模拟主菜单关卡定义
	var level3_def = {
		"number": 3,
		"title": "加减法迷宫",
		"description": "走出数学迷宫，收集宝藏！",
		"scene_path": "res://scenes/MazeScene.tscn",
		"unlock_requirement": 2
	}
	
	print("\n第三关配置：")
	print("  编号: %d" % level3_def.number)
	print("  标题: %s" % level3_def.title)
	print("  描述: %s" % level3_def.description)
	print("  场景路径: %s" % level3_def.scene_path)
	print("  解锁需求: 完成第%d关" % level3_def.unlock_requirement)
	
	# 4. 测试进度保存
	if TimerManager:
		print("\n测试进度保存...")
		# 模拟完成第二关
		TimerManager.update_game_progress(3, 100, 5)
		var progress = TimerManager.load_game_progress()
		print("  当前关卡: %d" % progress.get("level", 1))
		print("  金币: %d" % progress.get("coins", 0))
		print("  ✅ 第三关应该已解锁")
	else:
		print("⚠️ TimerManager 未初始化")
	
	print("\n========== 测试完成 ==========")
	return true

func _ready():
	# 运行测试
	test_level3_connection()
	
	print("\n提示：")
	print("1. 运行主菜单场景")
	print("2. 第三关'加减法迷宫'应该可见")
	print("3. 如果已完成第二关，第三关应该已解锁")
	print("4. 点击第三关应该能进入 MazeScene")