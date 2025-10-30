extends Control
class_name MainMenuManager

# ========== 主菜单管理器 ==========
# 负责关卡选择、解锁状态管理、健康时长检查

# ========== 调试配置 ==========
const DEBUG_AUTO_UNLOCK = false

# ========== 关卡信息定义 ==========
var level_definitions = [
	{
		"number": 1,
		"title": "数数果园",
		"description": "数一数树上的苹果",
		"scene_path": "res://main.tscn",
		"unlock_requirement": 0  # 默认解锁
	},
	{
		"number": 2,
		"title": "比较大小桥",
		"description": "选择正确的符号",
		"scene_path": "res://scenes/Level2.tscn",
		"unlock_requirement": 1  # 需要完成第1关
	},
	{
		"number": 3,
		"title": "加减法迷宫",
		"description": "走出数学迷宫，收集宝藏！",
		"scene_path": "res://scenes/MazeScene.tscn",
		"unlock_requirement": 2  # 需要完成第2关
	},
	{
		"number": 4,
		"title": "糖果商店",
		"description": "计算找零，成为小店长！",
		"scene_path": "res://scenes/CandyShopScene.tscn",
		"unlock_requirement": 3  # 需要完成第3关
	},
	{
		"number": 5,
		"title": "乘法森林",
		"description": "即将开放...",
		"scene_path": "",
		"unlock_requirement": 4  # 需要完成第4关
	}
]

# ========== 节点引用 ==========
@onready var title_label = $UI/TitlePanel/GameTitle
@onready var subtitle_label = $UI/TitlePanel/GameSubtitle
@onready var level_grid = $UI/ScrollContainer/LevelGrid
@onready var player_stats_label = $UI/BottomPanel/PlayerStatsLabel
@onready var settings_button = $UI/BottomPanel/SettingsButton
@onready var exit_button = $UI/BottomPanel/ExitButton
@onready var feedback_label = $UI/FeedbackLabel
@onready var settings_dialog = $SettingsDialog

# ========== 状态变量 ==========
var level_buttons = []
var player_progress = {}  # 存储玩家进度
var total_coins = 0

func _ready():
	print("MainMenu: 主菜单初始化")
	setup_ui()
	setup_health_timer()
	setup_settings_dialog()
	load_player_progress()
	create_level_buttons()
	update_unlock_status()
	check_game_availability()

# ========== UI 初始化 ==========
func setup_ui():
	"""初始化UI元素"""
	if title_label:
		title_label.text = "🎮 数学冒险"
		title_label.add_theme_font_size_override("font_size", 48)
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		title_label.add_theme_constant_override("shadow_offset_x", 3)
		title_label.add_theme_constant_override("shadow_offset_y", 3)
	
	if subtitle_label:
		subtitle_label.text = "选择你想挑战的关卡"
		subtitle_label.add_theme_font_size_override("font_size", 20)
		subtitle_label.modulate.a = 0.9
	
	if feedback_label:
		feedback_label.visible = false
	
	# 设置按钮事件
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	print("MainMenu: UI初始化完成")

func setup_health_timer():
	"""设置健康时长控制"""
	if TimerManager:
		TimerManager.state_changed.connect(_on_timer_state_changed)

func create_level_buttons():
	"""创建关卡选择按钮"""
	if not level_grid:
		print("错误：level_grid 节点不存在")
		return
	
	# 清除现有按钮
	for child in level_grid.get_children():
		child.queue_free()
	
	level_buttons.clear()
	
	# 设置网格列数为2（两列布局）
	level_grid.columns = 3
	
	# 创建关卡按钮
	for level_def in level_definitions:
		var level_button = LevelButton.new()
		level_button.set_level_info(
			level_def.number,
			level_def.title,
			level_def.description
		)
		
		# 连接点击事件（在设置解锁状态前连接）
		level_button.pressed.connect(_on_level_selected.bind(level_def))
		print("MainMenu: 连接关卡 %d 的点击事件" % level_def.number)
		
		# 添加到网格
		level_grid.add_child(level_button)
		level_buttons.append(level_button)
		
		print("MainMenu: 创建关卡按钮 - %d: %s" % [level_def.number, level_def.title])

# ========== 进度管理 ==========
func load_player_progress():
	"""加载玩家进度"""
	if TimerManager:
		var save_data = TimerManager.load_game_progress()
		if not save_data.is_empty():
			total_coins = save_data.get("coins", 0)
			var completed_level = save_data.get("level", 1) - 1  # 减1因为保存的是当前关卡
			
			# 标记已完成的关卡
			for i in range(completed_level):
				player_progress[i + 1] = {
					"completed": true,
					"stars": 3  # 默认结3星，以后可以根据实际表现计算
				}
			
			print("MainMenu: 加载进度 - 金币: %d, 已完成关卡: %d" % [total_coins, completed_level])
	
	if DEBUG_AUTO_UNLOCK:
		# 临时解锁关卡用于测试
		if not player_progress.has(1):
			player_progress[1] = {
				"completed": true,
				"stars": 3
			}
			print("MainMenu: 临时标记第一关为已完成，解锁第二关")

		# 临时解锁第三关用于测试（开发期间）
		if not player_progress.has(2):
			player_progress[2] = {
				"completed": true,
				"stars": 3
			}
			print("MainMenu: 临时标记第二关为已完成，解锁第三关")

		# 临时解锁第四关用于测试（开发期间）
		if not player_progress.has(3):
			player_progress[3] = {
				"completed": true,
				"stars": 3
			}
			print("MainMenu: 临时标记第三关为已完成，解锁第四关")

	update_stats_display()

func setup_settings_dialog():
	"""设置对话框事件"""
	if settings_dialog:
		settings_dialog.confirmed.connect(_on_settings_dialog_confirmed)

func save_player_progress():
	"""保存玩家进度"""
	if TimerManager:
		# 这里可以保存更详细的进度信息
		var highest_level = get_highest_unlocked_level()
		TimerManager.update_game_progress(highest_level, total_coins, 0)

func get_highest_unlocked_level() -> int:
	"""获取最高解锁关卡"""
	var highest = 1
	for level_num in player_progress.keys():
		if player_progress[level_num].get("completed", false):
			highest = max(highest, level_num + 1)
	return highest

func update_unlock_status():
	"""更新关卡解锁状态"""
	for i in range(level_buttons.size()):
		var level_def = level_definitions[i]
		var level_button = level_buttons[i]
		var level_num = level_def.number
		
		# 检查解锁条件
		var is_unlocked = check_level_unlock(level_def)
		level_button.set_unlock_status(is_unlocked)
		
		# 检查完成状态
		if player_progress.has(level_num):
			var progress = player_progress[level_num]
			level_button.set_completion_status(
				progress.get("completed", false),
				progress.get("stars", 0)
			)

func check_level_unlock(level_def: Dictionary) -> bool:
	"""检查关卡是否解锁"""
	var required_level = level_def.unlock_requirement
	
	# 第一关默认解锁
	if required_level == 0:
		return true
	
	# 检查前置关卡是否完成
	return player_progress.has(required_level) and player_progress[required_level].get("completed", false)

func update_stats_display():
	"""更新玩家统计显示"""
	if player_stats_label:
		var completed_levels = 0
		for progress in player_progress.values():
			if progress.get("completed", false):
				completed_levels += 1
		
		player_stats_label.text = "🪙 金币: %d | 🏆 完成关卡: %d/%d" % [total_coins, completed_levels, level_definitions.size()]

# ========== 游戏状态检查 ==========
func check_game_availability():
	"""检查游戏可用性（健康时长）"""
	if TimerManager and TimerManager.is_in_rest_period():
		print("MainMenu: 检测到正在休息中，跳转到休息界面")
		get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")
		return

func _on_timer_state_changed(new_state):
	"""处理健康时长状态变化"""
	if new_state == TimerManager.GameState.RESTING:
		show_feedback("游戏时间到，请休息一下再来玩吧！", Color.ORANGE)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/RestScreen.tscn")

# ========== 事件处理 ==========
func _on_level_selected(level_def: Dictionary):
	"""关卡被选择"""
	var level_num = level_def.number
	print("MainMenu: 选择关卡 %d - %s" % [level_num, level_def.title])
	print("MainMenu: 关卡信息: %s" % str(level_def))
	print("MainMenu: 当前玩家进度: %s" % str(player_progress))
	
	# 检查关卡是否解锁
	var is_unlocked = check_level_unlock(level_def)
	print("MainMenu: 关卡 %d 解锁状态: %s" % [level_num, is_unlocked])
	
	if not is_unlocked:
		print("MainMenu: 关卡未解锁，显示提示")
		show_feedback("此关卡尚未解锁，请先完成前面的关卡！", Color.RED)
		return
	
	# 检查场景路径是否存在
	if level_def.scene_path == "" or level_def.scene_path == null:
		print("MainMenu: 关卡场景路径为空")
		show_feedback("此关卡正在开发中，敬请期待！", Color.YELLOW)
		return
	
	# 检查健康时长
	if TimerManager and TimerManager.is_in_rest_period():
		print("MainMenu: 在休息期间")
		show_feedback("休息时间未结束，请稍后再试！", Color.ORANGE)
		return
	
	# 保存进度并跳转
	print("MainMenu: 即将进入关卡: %s" % level_def.scene_path)
	save_player_progress()
	show_feedback("正在进入关卡...", Color.GREEN)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(level_def.scene_path)

func _on_settings_pressed():
	"""设置按钮点击"""
	print("MainMenu: 设置按钮点击")
	if settings_dialog:
		settings_dialog.popup_centered()

func _on_settings_dialog_confirmed():
	"""确认清空游戏记录"""
	print("MainMenu: 确认清空游戏记录")
	reset_progress_data()
	if TimerManager:
		TimerManager.clear_all_saved_data()
	show_feedback("已清空游戏记录，从零开始冒险吧！", Color.GREEN)

func reset_progress_data():
	"""重置本地的关卡进度数据"""
	player_progress.clear()
	total_coins = 0
	update_unlock_status()
	update_stats_display()

func _on_exit_pressed():
	"""退出按钮点击"""
	print("MainMenu: 退出游戏")
	show_feedback("感谢游玩数学冒险！", Color.PURPLE)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

# ========== 反馈系统 ==========
func show_feedback(text: String, color: Color):
	"""显示反馈信息"""
	if feedback_label:
		feedback_label.text = text
		feedback_label.modulate = color
		feedback_label.visible = true
		
		# 添加淡入淡出动画
		var tween = create_tween()
		feedback_label.modulate.a = 0
		tween.tween_property(feedback_label, "modulate:a", 1.0, 0.3)
		tween.tween_property(feedback_label, "modulate:a", 0.0, 0.3).set_delay(2.0)
		
		# 隐藏标签
		tween.finished.connect(func(): feedback_label.visible = false)

# ========== 调试功能 ==========
func debug_unlock_all_levels():
	"""调试：解锁所有关卡"""
	for i in range(level_definitions.size()):
		player_progress[i + 1] = {
			"completed": true,
			"stars": 3
		}
	update_unlock_status()
	update_stats_display()
	print("调试：已解锁所有关卡")

func debug_reset_progress():
	"""调试：重置游戏进度"""
	reset_progress_data()

	# 清除保存文件
	if TimerManager:
		TimerManager.clear_all_saved_data()

	print("调试：已重置游戏进度")

# ========== 特殊输入处理 ==========
func _input(event):
	"""处理特殊输入"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				debug_unlock_all_levels()
			KEY_F10:
				debug_reset_progress()
			KEY_ESCAPE:
				_on_exit_pressed()
