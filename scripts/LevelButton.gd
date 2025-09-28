extends Button
class_name LevelButton

# ========== 关卡按钮组件 ==========
# 用于关卡选择界面的按钮，支持解锁/锁定状态显示

# ========== 常量定义 ==========
const BUTTON_SIZE = Vector2(200, 190)  # 宽度增加20% (150*1.2=180), 高度为360的一半
const FONT_SIZE_TITLE = 24
const FONT_SIZE_SUBTITLE = 16

# ========== 关卡信息 ==========
var level_number: int = 1
var level_title: String = ""
var level_description: String = ""
var is_unlocked: bool = false
var is_completed: bool = false
var star_count: int = 0  # 星级评价 (0-3)

# ========== 节点引用 ==========
@onready var level_icon = Label.new()
@onready var level_title_label = Label.new()
@onready var level_desc_label = Label.new()
@onready var lock_icon = Label.new()
@onready var stars_container = HBoxContainer.new()

func _ready():
	# 设置按钮基本属性
	custom_minimum_size = BUTTON_SIZE
	
	# 创建UI布局
	setup_button_layout()
	
	# 设置按钮样式
	setup_button_style()
	
	# 连接按钮点击信号（备用）
	pressed.connect(_on_button_pressed)
	
	# 更新显示状态
	update_button_display()

func setup_button_layout():
	"""设置按钮内部布局"""
	# 创建主容器
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 6)  # 调整元素间距适应新高度
	add_child(main_container)
	
	# 添加顶部间距
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size.y = 10  # 减少顶部间距
	main_container.add_child(top_spacer)
	
	# 关卡图标/数字
	level_icon.text = str(level_number)
	level_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_icon.add_theme_font_size_override("font_size", 36)  # 调整图标大小
	main_container.add_child(level_icon)
	
	# 关卡标题
	level_title_label.text = level_title
	level_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_title_label.add_theme_font_size_override("font_size", FONT_SIZE_TITLE)
	level_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_title_label.custom_minimum_size.x = 160  # 设置最小宽度留出边距
	main_container.add_child(level_title_label)
	
	# 关卡描述
	level_desc_label.text = level_description
	level_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_desc_label.add_theme_font_size_override("font_size", FONT_SIZE_SUBTITLE)
	level_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_desc_label.custom_minimum_size.x = 160  # 设置最小宽度留出边距
	level_desc_label.modulate.a = 0.8
	main_container.add_child(level_desc_label)
	
	# 添加小的中间间距
	var middle_spacer = Control.new()
	middle_spacer.custom_minimum_size.y = 5
	main_container.add_child(middle_spacer)
	
	# 星级显示
	stars_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_child(stars_container)
	
	# 锁定图标（位置调整为居中）
	lock_icon.text = "🔒"
	lock_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_icon.add_theme_font_size_override("font_size", 48)  # 调整锁图标大小
	lock_icon.visible = false
	lock_icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(lock_icon)  # 添加到按钮本身而不是容器，以便覆盖
	
	# 添加底部间距
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size.y = 10  # 减少底部间距
	main_container.add_child(bottom_spacer)

func setup_button_style():
	"""设置按钮样式"""
	# 解锁状态样式
	var unlocked_normal = StyleBoxFlat.new()
	unlocked_normal.bg_color = Color(0.3, 0.7, 1.0, 1.0)  # 蓝色
	unlocked_normal.corner_radius_top_left = 15
	unlocked_normal.corner_radius_top_right = 15
	unlocked_normal.corner_radius_bottom_left = 15
	unlocked_normal.corner_radius_bottom_right = 15
	unlocked_normal.border_width_left = 3
	unlocked_normal.border_width_right = 3
	unlocked_normal.border_width_top = 3
	unlocked_normal.border_width_bottom = 3
	unlocked_normal.border_color = Color(0.1, 0.4, 0.6, 1.0)
	
	var unlocked_hover = StyleBoxFlat.new()
	unlocked_hover.bg_color = Color(0.4, 0.8, 1.0, 1.0)  # 亮蓝色
	unlocked_hover.corner_radius_top_left = 15
	unlocked_hover.corner_radius_top_right = 15
	unlocked_hover.corner_radius_bottom_left = 15
	unlocked_hover.corner_radius_bottom_right = 15
	unlocked_hover.border_width_left = 4
	unlocked_hover.border_width_right = 4
	unlocked_hover.border_width_top = 4
	unlocked_hover.border_width_bottom = 4
	unlocked_hover.border_color = Color(0.0, 0.3, 0.5, 1.0)
	
	var completed_normal = StyleBoxFlat.new()
	completed_normal.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # 绿色（已完成）
	completed_normal.corner_radius_top_left = 15
	completed_normal.corner_radius_top_right = 15
	completed_normal.corner_radius_bottom_left = 15
	completed_normal.corner_radius_bottom_right = 15
	completed_normal.border_width_left = 3
	completed_normal.border_width_right = 3
	completed_normal.border_width_top = 3
	completed_normal.border_width_bottom = 3
	completed_normal.border_color = Color(0.1, 0.5, 0.1, 1.0)
	
	var locked_style = StyleBoxFlat.new()
	locked_style.bg_color = Color(0.4, 0.4, 0.4, 1.0)  # 灰色（锁定）
	locked_style.corner_radius_top_left = 15
	locked_style.corner_radius_top_right = 15
	locked_style.corner_radius_bottom_left = 15
	locked_style.corner_radius_bottom_right = 15
	locked_style.border_width_left = 2
	locked_style.border_width_right = 2
	locked_style.border_width_top = 2
	locked_style.border_width_bottom = 2
	locked_style.border_color = Color(0.2, 0.2, 0.2, 1.0)
	
	# 应用样式（初始化时使用锁定样式）
	add_theme_stylebox_override("normal", locked_style)
	add_theme_stylebox_override("hover", locked_style)
	add_theme_stylebox_override("pressed", locked_style)

func set_level_info(number: int, title: String, description: String):
	"""设置关卡基本信息"""
	level_number = number
	level_title = title
	level_description = description
	
	if level_icon:
		level_icon.text = str(level_number)
	if level_title_label:
		level_title_label.text = level_title
	if level_desc_label:
		level_desc_label.text = level_description
	
	print("LevelButton: 设置关卡信息 - %d: %s" % [number, title])

func set_unlock_status(unlocked: bool):
	"""设置解锁状态"""
	is_unlocked = unlocked
	update_button_display()

func set_completion_status(completed: bool, stars: int = 0):
	"""设置完成状态和星级"""
	is_completed = completed
	star_count = clamp(stars, 0, 3)
	update_button_display()

func update_button_display():
	"""更新按钮显示状态"""
	if not is_unlocked:
		# 锁定状态 - 不禁用按钮，但显示为锁定样式
		disabled = false  # 保持可点击，但在点击处理中检查锁定状态
		modulate.a = 0.6
		
		if lock_icon:
			lock_icon.visible = true
		if level_icon:
			level_icon.visible = false
		if level_title_label:
			level_title_label.text = "???"
		if level_desc_label:
			level_desc_label.text = "未解锁"
		
		apply_locked_style()
		
	else:
		# 解锁状态
		disabled = false
		modulate.a = 1.0
		
		if lock_icon:
			lock_icon.visible = false
		if level_icon:
			level_icon.visible = true
		if level_title_label:
			level_title_label.text = level_title
		if level_desc_label:
			level_desc_label.text = level_description
		
		if is_completed:
			apply_completed_style()
			update_stars_display()
		else:
			apply_unlocked_style()

func apply_locked_style():
	"""应用锁定样式"""
	var locked_style = StyleBoxFlat.new()
	locked_style.bg_color = Color(0.4, 0.4, 0.4, 1.0)
	locked_style.corner_radius_top_left = 15
	locked_style.corner_radius_top_right = 15
	locked_style.corner_radius_bottom_left = 15
	locked_style.corner_radius_bottom_right = 15
	locked_style.border_width_left = 2
	locked_style.border_width_right = 2
	locked_style.border_width_top = 2
	locked_style.border_width_bottom = 2
	locked_style.border_color = Color(0.2, 0.2, 0.2, 1.0)
	
	add_theme_stylebox_override("normal", locked_style)
	add_theme_stylebox_override("hover", locked_style)
	add_theme_stylebox_override("pressed", locked_style)

func apply_unlocked_style():
	"""应用解锁样式"""
	var unlocked_normal = StyleBoxFlat.new()
	unlocked_normal.bg_color = Color(0.3, 0.7, 1.0, 1.0)
	unlocked_normal.corner_radius_top_left = 15
	unlocked_normal.corner_radius_top_right = 15
	unlocked_normal.corner_radius_bottom_left = 15
	unlocked_normal.corner_radius_bottom_right = 15
	unlocked_normal.border_width_left = 3
	unlocked_normal.border_width_right = 3
	unlocked_normal.border_width_top = 3
	unlocked_normal.border_width_bottom = 3
	unlocked_normal.border_color = Color(0.1, 0.4, 0.6, 1.0)
	
	var unlocked_hover = StyleBoxFlat.new()
	unlocked_hover.bg_color = Color(0.4, 0.8, 1.0, 1.0)
	unlocked_hover.corner_radius_top_left = 15
	unlocked_hover.corner_radius_top_right = 15
	unlocked_hover.corner_radius_bottom_left = 15
	unlocked_hover.corner_radius_bottom_right = 15
	unlocked_hover.border_width_left = 4
	unlocked_hover.border_width_right = 4
	unlocked_hover.border_width_top = 4
	unlocked_hover.border_width_bottom = 4
	unlocked_hover.border_color = Color(0.0, 0.3, 0.5, 1.0)
	
	add_theme_stylebox_override("normal", unlocked_normal)
	add_theme_stylebox_override("hover", unlocked_hover)
	add_theme_stylebox_override("pressed", unlocked_normal)

func apply_completed_style():
	"""应用已完成样式"""
	var completed_style = StyleBoxFlat.new()
	completed_style.bg_color = Color(0.3, 0.8, 0.3, 1.0)
	completed_style.corner_radius_top_left = 15
	completed_style.corner_radius_top_right = 15
	completed_style.corner_radius_bottom_left = 15
	completed_style.corner_radius_bottom_right = 15
	completed_style.border_width_left = 3
	completed_style.border_width_right = 3
	completed_style.border_width_top = 3
	completed_style.border_width_bottom = 3
	completed_style.border_color = Color(0.1, 0.5, 0.1, 1.0)
	
	var completed_hover = StyleBoxFlat.new()
	completed_hover.bg_color = Color(0.4, 0.9, 0.4, 1.0)
	completed_hover.corner_radius_top_left = 15
	completed_hover.corner_radius_top_right = 15
	completed_hover.corner_radius_bottom_left = 15
	completed_hover.corner_radius_bottom_right = 15
	completed_hover.border_width_left = 4
	completed_hover.border_width_right = 4
	completed_hover.border_width_top = 4
	completed_hover.border_width_bottom = 4
	completed_hover.border_color = Color(0.0, 0.4, 0.0, 1.0)
	
	add_theme_stylebox_override("normal", completed_style)
	add_theme_stylebox_override("hover", completed_hover)
	add_theme_stylebox_override("pressed", completed_style)

func update_stars_display():
	"""更新星级显示"""
	if not stars_container:
		return
	
	# 清除旧的星星
	for child in stars_container.get_children():
		child.queue_free()
	
	# 添加星星
	for i in range(3):
		var star_label = Label.new()
		if i < star_count:
			star_label.text = "⭐"
		else:
			star_label.text = "☆"
		star_label.add_theme_font_size_override("font_size", 14)
		stars_container.add_child(star_label)

func play_click_animation():
	"""播放点击动画"""
	if not is_unlocked:
		# 锁定状态的摇摆动画
		var tween = create_tween()
		tween.tween_property(self, "rotation", 0.1, 0.1)
		tween.tween_property(self, "rotation", -0.1, 0.1)
		tween.tween_property(self, "rotation", 0.05, 0.1)
		tween.tween_property(self, "rotation", 0.0, 0.1)
		return
	
	# 正常点击动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)

func _on_button_pressed():
	"""按钮点击处理"""
	play_click_animation()
	
	if not is_unlocked:
		print("LevelButton: 关卡 %d 尚未解锁" % level_number)
	else:
		print("LevelButton: 选择关卡 %d" % level_number)
