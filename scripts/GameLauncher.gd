extends Control
class_name GameLauncher

# ========== 游戏启动器 ==========
# 负责游戏初始化、场景管理和版本控制

const GAME_VERSION = "1.2.0"
const MAIN_MENU_SCENE = "res://scenes/MainMenu.tscn"
const FIRST_TIME_TUTORIAL = "res://main.tscn"

# ========== 初始化状态 ==========
enum InitState {
	STARTING,
	LOADING_SYSTEMS,
	CHECKING_SAVE,
	READY
}

var current_state = InitState.STARTING
var init_progress = 0.0

# ========== 节点引用 ==========
@onready var splash_screen = $SplashScreen
@onready var loading_bar = $SplashScreen/LoadingPanel/LoadingContainer/LoadingBar
@onready var loading_label = $SplashScreen/LoadingPanel/LoadingContainer/LoadingLabel
@onready var version_label = $SplashScreen/VersionLabel

func _ready():
	print("GameLauncher: 游戏启动器初始化 - 版本 %s" % GAME_VERSION)
	setup_splash_screen()
	start_initialization()

# ========== 启动屏幕设置 ==========
func setup_splash_screen():
	"""设置启动屏幕"""
	if version_label:
		version_label.text = "版本 " + GAME_VERSION
	
	if loading_bar:
		loading_bar.value = 0
	
	if loading_label:
		loading_label.text = "正在启动游戏..."

# ========== 初始化流程 ==========
func start_initialization():
	"""开始初始化流程"""
	var init_steps = [
		{"name": "初始化系统管理器...", "func": init_managers},
		{"name": "加载用户设置...", "func": load_user_settings},
		{"name": "检查存档数据...", "func": check_save_data},
		{"name": "准备游戏资源...", "func": prepare_resources},
		{"name": "完成初始化...", "func": finalize_init}
	]
	
	for i in range(init_steps.size()):
		var step = init_steps[i]
		update_loading_progress(step.name, float(i) / init_steps.size())
		
		# 执行初始化步骤
		var result = await step.func.call()
		if not result:
			print("错误：初始化步骤失败 - " + step.name)
			show_init_error(step.name)
			return
		
		# 添加一点延迟以显示进度
		await get_tree().create_timer(0.2).timeout
	
	# 完成初始化
	complete_initialization()

func update_loading_progress(message: String, progress: float):
	"""更新加载进度"""
	if loading_label:
		loading_label.text = message
	
	if loading_bar:
		var tween = create_tween()
		tween.tween_property(loading_bar, "value", progress * 100, 0.1)
	
	print("GameLauncher: %s (%.1f%%)" % [message, progress * 100])

# ========== 初始化步骤 ==========
func init_managers() -> bool:
	"""初始化系统管理器"""
	# 确保 TimerManager 存在
	if not TimerManager:
		print("警告：TimerManager 未找到，游戏将在无健康时长控制模式下运行")
	else:
		print("GameLauncher: TimerManager 已加载")
	
	# 初始化音频管理器（如果有）
	if has_node("/root/AudioManager"):
		print("GameLauncher: AudioManager 已加载")
	
	return true

func load_user_settings() -> bool:
	"""加载用户设置"""
	# 加载音效设置
	var master_volume = 1.0
	var sfx_volume = 1.0
	var music_volume = 0.7
	
	# 应用音频设置
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	
	print("GameLauncher: 用户设置已加载")
	return true

func check_save_data() -> bool:
	"""检查存档数据"""
	if TimerManager:
		var save_data = TimerManager.load_game_progress()
		if save_data.is_empty():
			print("GameLauncher: 未找到存档，将从第一关开始")
		else:
			var level = save_data.get("level", 1)
			var coins = save_data.get("coins", 0)
			print("GameLauncher: 存档已加载 - 关卡 %d, 金币 %d" % [level, coins])
	
	return true

func prepare_resources() -> bool:
	"""准备游戏资源"""
	# 预加载关键场景（可选）
	# ResourceLoader.load(MAIN_MENU_SCENE)
	
	print("GameLauncher: 游戏资源准备完成")
	return true

func finalize_init() -> bool:
	"""完成初始化"""
	current_state = InitState.READY
	print("GameLauncher: 初始化完成")
	return true

# ========== 完成初始化 ==========
func complete_initialization():
	"""完成初始化流程"""
	update_loading_progress("启动完成！", 1.0)
	
	# 显示完成信息
	await get_tree().create_timer(0.5).timeout
	
	# 检查是否是首次运行
	if is_first_time_run():
		print("GameLauncher: 首次运行，启动教程")
		launch_tutorial()
	else:
		print("GameLauncher: 启动主菜单")
		launch_main_menu()

func is_first_time_run() -> bool:
	"""检查是否是首次运行"""
	if not TimerManager:
		return true
	
	var save_data = TimerManager.load_game_progress()
	return save_data.is_empty()

func launch_tutorial():
	"""启动教程（第一关）"""
	fade_to_scene(FIRST_TIME_TUTORIAL)

func launch_main_menu():
	"""启动主菜单"""
	fade_to_scene(MAIN_MENU_SCENE)

# ========== 场景转换 ==========
func fade_to_scene(scene_path: String):
	"""淡出到指定场景"""
	# 创建淡出效果
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.color.a = 0.0
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.z_index = 100
	add_child(fade_overlay)
	
	# 淡出动画
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)
	await tween.finished
	
	# 切换场景
	get_tree().change_scene_to_file(scene_path)

# ========== 错误处理 ==========
func show_init_error(failed_step: String):
	"""显示初始化错误"""
	if loading_label:
		loading_label.text = "初始化失败: " + failed_step
		loading_label.modulate = Color.RED
	
	# 显示错误信息几秒后重试或退出
	await get_tree().create_timer(3.0).timeout
	
	# 可以选择重试或显示错误对话框
	print("GameLauncher: 由于初始化失败，游戏将退出")
	get_tree().quit()

# ========== 调试功能 ==========
func _input(event):
	"""处理调试输入"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F11:
				# 跳过启动屏幕直接进入主菜单
				if current_state != InitState.READY:
					print("调试：强制跳转到主菜单")
					launch_main_menu()
			KEY_F12:
				# 跳过启动屏幕直接进入第一关
				if current_state != InitState.READY:
					print("调试：强制跳转到第一关")
					launch_tutorial()

func _notification(what):
	"""处理系统通知"""
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("GameLauncher: 应用程序正在关闭")
			get_tree().quit()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			print("GameLauncher: 应用程序失去焦点")
		NOTIFICATION_APPLICATION_FOCUS_IN:
			print("GameLauncher: 应用程序获得焦点")
