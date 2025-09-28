extends Control
class_name NumberStone

# ========== 石头组件脚本 ==========
# 用于显示数字和播放动画效果（碎裂、闪烁、掉落）

# ========== 节点引用 ==========
@onready var background = $Background
@onready var number_label = $NumberLabel

# ========== 状态变量 ==========
var displayed_number: int = 0
var is_animating: bool = false

# ========== 动画相关 ==========
var original_position: Vector2
var original_color: Color

func _ready():
	# 保存原始状态
	original_position = position
	if background:
		# Panel没有color属性，使用modulate代替
		original_color = background.modulate
	
	# 设置默认样式
	setup_stone_appearance()

func setup_stone_appearance():
	"""设置石头外观样式"""
	if background:
		# Panel使用StyleBox控制外观，不能直接设置color
		# background.color = Color(0.4, 0.35, 0.3, 1.0)  # 删除这行
		
		# 创建石头样式
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.4, 0.35, 0.3, 1.0)
		style_box.corner_radius_top_left = 8
		style_box.corner_radius_top_right = 8
		style_box.corner_radius_bottom_left = 8
		style_box.corner_radius_bottom_right = 8
		style_box.border_width_left = 3
		style_box.border_width_right = 3
		style_box.border_width_top = 3
		style_box.border_width_bottom = 3
		style_box.border_color = Color(0.2, 0.15, 0.1, 1.0)  # 深色边框
		
		background.add_theme_stylebox_override("panel", style_box)
	
	if number_label:
		# 设置数字标签样式
		number_label.add_theme_font_size_override("font_size", 32)
		number_label.add_theme_color_override("font_color", Color.WHITE)
		number_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		number_label.add_theme_constant_override("shadow_offset_x", 2)
		number_label.add_theme_constant_override("shadow_offset_y", 2)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func set_number(number: int):
	"""设置显示的数字"""
	displayed_number = number
	if number_label:
		number_label.text = str(number)
	print("NumberStone: 设置数字为 %d" % number)

func get_number() -> int:
	"""获取当前显示的数字"""
	return displayed_number

# ========== 动画效果 ==========
func play_shatter_animation():
	"""播放碎裂动画（答对时）"""
	if is_animating:
		return
	
	is_animating = true
	print("NumberStone: 播放碎裂动画")
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放动画
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.4).set_delay(0.2)
	
	# 旋转动画
	tween.tween_property(self, "rotation", randf_range(-0.3, 0.3), 0.3)
	
	# 透明度动画
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.2)
	
	# 动画完成后隐藏
	tween.finished.connect(func():
		visible = false
		is_animating = false
	)

func play_blink_animation():
	"""播放闪烁动画（答错时）"""
	if is_animating:
		return
	
	is_animating = true
	print("NumberStone: 播放闪烁动画")
	
	var tween = create_tween()
	tween.set_loops(3)  # 闪烁3次
	
	# 颜色闪烁
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# 动画完成后重置状态
	tween.finished.connect(func():
		modulate = Color.WHITE
		is_animating = false
	)

func play_fall_animation():
	"""播放掉落动画（超时时）"""
	if is_animating:
		return
	
	is_animating = true
	print("NumberStone: 播放掉落动画")
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 下落动画
	var fall_distance = 500  # 掉落距离
	tween.tween_property(self, "position:y", position.y + fall_distance, 1.0)
	tween.tween_property(self, "position:x", position.x + randf_range(-50, 50), 1.0)
	
	# 旋转动画
	tween.tween_property(self, "rotation", randf_range(-2.0, 2.0), 1.0)
	
	# 透明度动画
	tween.tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.2)
	
	# 动画完成后重置位置
	tween.finished.connect(func():
		reset_to_original_state()
		is_animating = false
	)

func play_appear_animation():
	"""播放出现动画（新题目时）"""
	print("NumberStone: 播放出现动画")
	
	# 重置状态
	reset_to_original_state()
	
	# 从小到大的出现动画
	scale = Vector2.ZERO
	modulate.a = 0.0
	visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	
	# 轻微弹跳效果
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_delay(0.4)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.5)

func reset_to_original_state():
	"""重置到原始状态"""
	position = original_position
	rotation = 0
	scale = Vector2(1.0, 1.0)
	modulate = Color.WHITE
	visible = true
	is_animating = false

# ========== 特殊效果 ==========
func add_glow_effect():
	"""添加发光效果（连击奖励时）"""
	var tween = create_tween()
	tween.set_loops(5)
	
	tween.tween_property(self, "modulate", Color.YELLOW, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func set_special_color(color: Color):
	"""设置特殊颜色（用于特殊题目）"""
	if background:
		background.modulate = color
