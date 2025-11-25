extends Node
# TimerManager - 健康游戏时长控制单例
# 管理游戏时长、休息时间以及相关状态

# ========== 健康游戏时长常量 ==========
const GAME_TIME_LIMIT = 600.0  # 单次游戏时长上限（10分钟，单位：秒）
const REST_TIME_REQUIRED = 600.0  # 强制休息时长（10分钟，单位：秒）
const SAVE_FILE_PATH = "user://game_progress.save"  # 游戏进度保存路径

# ========== 游戏状态枚举 ==========
enum GameState {
	PLAYING,     # 正常游戏中
	TIME_UP,     # 游戏时间耗尽
	RESTING,     # 休息中
	REST_COMPLETE # 休息完成，可以继续游戏
}

# ========== 状态变量 ==========
var current_state: GameState = GameState.PLAYING
var game_time_remaining: float = GAME_TIME_LIMIT  # 游戏剩余时间
var rest_time_remaining: float = 0.0  # 休息剩余时间
var is_timer_active: bool = false  # 计时器是否激活

# ========== 保存的游戏数据 ==========
var saved_level: int = 1
var saved_coins: int = 0
var saved_correct_answers: int = 0

# ========== 信号定义 ==========
signal game_time_updated(time_remaining: float)  # 游戏时间更新
signal rest_time_updated(time_remaining: float)  # 休息时间更新
signal game_time_expired()  # 游戏时间耗尽
signal rest_time_completed()  # 休息时间完成
signal state_changed(new_state: GameState)  # 状态改变

func _ready():
        print("TimerManager 初始化完成")
        # 启动时检查是否有未完成的休息时间
        load_timer_state()

func _notification(what):
        """在应用退出前保存进度和计时状态，防止数据丢失"""
        match what:
                NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_EXIT, NOTIFICATION_EXIT_TREE:
                        save_game_progress()
                        save_timer_state()

func _process(delta):
	if not is_timer_active:
		return
	
	match current_state:
		GameState.PLAYING:
			update_game_timer(delta)
		GameState.RESTING:
			update_rest_timer(delta)

# ========== 游戏计时管理 ==========
func start_game_timer():
	"""开始游戏计时"""
	if current_state == GameState.RESTING:
		print("当前处于休息状态，无法开始游戏")
		return false
	
	current_state = GameState.PLAYING
	is_timer_active = true
	print("游戏计时器启动，剩余时间: %.0f 秒" % game_time_remaining)
	emit_signal("state_changed", current_state)
	return true

func pause_game_timer():
	"""暂停游戏计时"""
	is_timer_active = false
	print("游戏计时器已暂停")

func resume_game_timer():
	"""恢复游戏计时"""
	if current_state == GameState.PLAYING:
		is_timer_active = true
		print("游戏计时器已恢复")

func update_game_timer(delta: float):
	"""更新游戏计时器"""
	game_time_remaining -= delta
	emit_signal("game_time_updated", game_time_remaining)
	
	if game_time_remaining <= 0:
		game_time_remaining = 0
		trigger_rest_period()

func trigger_rest_period():
	"""触发休息时间"""
	print("游戏时间到！开始休息时间")
	current_state = GameState.TIME_UP
	is_timer_active = false
	
	# 保存当前游戏状态
	save_game_progress()
	
	# 发送游戏时间耗尽信号
	emit_signal("game_time_expired")
	
	# 开始休息倒计时
	start_rest_period()

# ========== 休息计时管理 ==========
func start_rest_period():
	"""开始休息时间"""
	current_state = GameState.RESTING
	rest_time_remaining = REST_TIME_REQUIRED
	is_timer_active = true
	
	print("休息时间开始，需要休息: %.0f 秒" % rest_time_remaining)
	emit_signal("state_changed", current_state)
	save_timer_state()

func update_rest_timer(delta: float):
	"""更新休息计时器"""
	rest_time_remaining -= delta
	emit_signal("rest_time_updated", rest_time_remaining)
	
	if rest_time_remaining <= 0:
		rest_time_remaining = 0
		complete_rest_period()

func complete_rest_period():
	"""完成休息时间"""
	print("休息时间完成！可以继续游戏")
	current_state = GameState.REST_COMPLETE
	is_timer_active = false
	
	# 重置游戏时间
	game_time_remaining = GAME_TIME_LIMIT
	
	emit_signal("rest_time_completed")
	emit_signal("state_changed", current_state)
	save_timer_state()

func reset_for_new_game():
	"""重置为新游戏"""
	current_state = GameState.PLAYING
	game_time_remaining = GAME_TIME_LIMIT
	rest_time_remaining = 0.0
	is_timer_active = false
	
	print("计时器重置为新游戏状态")
	emit_signal("state_changed", current_state)
	save_timer_state()

# ========== 状态查询 ==========
func can_play_game() -> bool:
	"""检查是否可以进行游戏"""
	return current_state == GameState.PLAYING or current_state == GameState.REST_COMPLETE

func is_in_rest_period() -> bool:
	"""检查是否在休息期间"""
	return current_state == GameState.RESTING

func get_game_time_string() -> String:
	"""获取游戏时间的格式化字符串"""
	var minutes = int(game_time_remaining) / 60
	var seconds = int(game_time_remaining) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_rest_time_string() -> String:
	"""获取休息时间的格式化字符串"""
	var minutes = int(rest_time_remaining) / 60
	var seconds = int(rest_time_remaining) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_remaining_game_time() -> int:
	"""获取剩余游戏时间（秒）"""
	return int(game_time_remaining)

# ========== 游戏进度保存与加载 ==========
func save_game_progress():
	"""保存当前游戏进度"""
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("无法保存游戏进度")
		return
	
	var save_data = {
		"level": saved_level,
		"coins": saved_coins,
		"correct_answers": saved_correct_answers,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()
	print("游戏进度已保存: 关卡 %d, 金币 %d" % [saved_level, saved_coins])

func load_game_progress() -> Dictionary:
        """加载游戏进度并同步内部状态"""
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("没有找到游戏进度文件")
		return {}
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		print("无法读取游戏进度文件")
		return {}
	
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("游戏进度文件格式错误")
		return {}
	
        var save_data = json.data

        # 同步内部缓存，避免旧状态覆盖最新进度
        saved_level = int(save_data.get("level", saved_level))
        saved_coins = int(save_data.get("coins", saved_coins))
        saved_correct_answers = int(save_data.get("correct_answers", saved_correct_answers))

        print("游戏进度已加载: 关卡 %d, 金币 %d" % [saved_level, saved_coins])
        return save_data

func update_game_progress(level: int, coins: int, correct_answers: int = 0):
        """更新游戏进度数据"""
        # 防止较低进度覆盖更高进度
        saved_level = max(saved_level, level)
        saved_coins = max(saved_coins, coins)
        saved_correct_answers = max(saved_correct_answers, correct_answers)

        print("更新游戏进度: 关卡 %d, 金币 %d" % [saved_level, saved_coins])
        save_game_progress()

func clear_all_saved_data():
	"""清空所有保存的游戏与计时数据"""
	saved_level = 1
	saved_coins = 0
	saved_correct_answers = 0
	game_time_remaining = GAME_TIME_LIMIT
	rest_time_remaining = 0.0
	current_state = GameState.PLAYING
	is_timer_active = false

	var save_paths = [SAVE_FILE_PATH, "user://timer_state.save"]
	for path in save_paths:
		if FileAccess.file_exists(path):
			var error = DirAccess.remove_absolute(path)
			if error != OK:
				print("无法删除保存文件: %s" % path)

	emit_signal("state_changed", current_state)
	print("所有游戏记录已清除")

func clear_all_saved_data():
	"""清空所有保存的游戏与计时数据"""
	saved_level = 1
	saved_coins = 0
	saved_correct_answers = 0
	game_time_remaining = GAME_TIME_LIMIT
	rest_time_remaining = 0.0
	current_state = GameState.PLAYING
	is_timer_active = false

	var save_paths = [SAVE_FILE_PATH, "user://timer_state.save"]
	for path in save_paths:
		if FileAccess.file_exists(path):
			var error = DirAccess.remove_absolute(path)
			if error != OK:
				print("无法删除保存文件: %s" % path)

	emit_signal("state_changed", current_state)
	print("所有游戏记录已清除")

# ========== 计时器状态持久化 ==========
func save_timer_state():
	"""保存计时器状态到本地"""
	var timer_save_path = "user://timer_state.save"
	var save_file = FileAccess.open(timer_save_path, FileAccess.WRITE)
	if save_file == null:
		return
	
	var timer_data = {
		"state": current_state,
		"game_time_remaining": game_time_remaining,
		"rest_time_remaining": rest_time_remaining,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	save_file.store_string(JSON.stringify(timer_data))
	save_file.close()

func load_timer_state():
	"""加载计时器状态"""
	var timer_save_path = "user://timer_state.save"
	if not FileAccess.file_exists(timer_save_path):
		return
	
	var save_file = FileAccess.open(timer_save_path, FileAccess.READ)
	if save_file == null:
		return
	
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return
	
	var timer_data = json.data
	var saved_timestamp = timer_data.get("timestamp", 0)
	var current_timestamp = Time.get_unix_time_from_system()
	var elapsed_offline_time = current_timestamp - saved_timestamp
	
	# 恢复状态
	current_state = timer_data.get("state", GameState.PLAYING)
	game_time_remaining = timer_data.get("game_time_remaining", GAME_TIME_LIMIT)
	rest_time_remaining = timer_data.get("rest_time_remaining", 0.0)
	
	# 如果在休息状态，减去离线经过的时间
	if current_state == GameState.RESTING:
		rest_time_remaining -= elapsed_offline_time
		if rest_time_remaining <= 0:
			complete_rest_period()
		else:
			is_timer_active = true
			print("恢复休息状态，剩余休息时间: %.0f 秒" % rest_time_remaining)
	
	emit_signal("state_changed", current_state)

# ========== 调试和测试功能 ==========
func debug_set_game_time(seconds: float):
	"""调试功能：设置游戏剩余时间"""
	game_time_remaining = seconds
	print("调试：设置游戏时间为 %.0f 秒" % seconds)

func debug_set_rest_time(seconds: float):
	"""调试功能：设置休息剩余时间"""
	rest_time_remaining = seconds
	current_state = GameState.RESTING
	is_timer_active = true
	print("调试：设置休息时间为 %.0f 秒" % seconds)

func debug_print_status():
	"""调试功能：打印当前状态"""
	print("=== TimerManager 状态 ===")
	print("当前状态: %d" % current_state)
	print("游戏剩余时间: %.1f 秒" % game_time_remaining)
	print("休息剩余时间: %.1f 秒" % rest_time_remaining)
	print("计时器激活: %s" % is_timer_active)
	print("========================")
