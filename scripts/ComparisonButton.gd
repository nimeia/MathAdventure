extends Button
class_name ComparisonButton

# ========== 符号按钮组件 ==========
# 用于选择比较符号（>、<、=）

# ========== 常量定义 ==========
const BUTTON_SIZE = Vector2(80, 80)
const FONT_SIZE = 36

enum ComparisonType {
	GREATER,    # >
	LESS,       # <
	EQUAL       # =
}

# ========== 内部变量 ==========
var comparison_type: ComparisonType
var symbol_text: String

func _ready():
	# 设置按钮基本属性
	custom_minimum_size = BUTTON_SIZE
	
	# 设置按钮样式
	setup_button_style()
	
	# 设置字体
	setup_font()

func setup_button_style():
	"""设置按钮样式"""
	# 创建按钮样式
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.6, 0.8, 1.0)  # 蓝色
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_left = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.border_width_left = 3
	normal_style.border_width_right = 3
	normal_style.border_width_top = 3
	normal_style.border_width_bottom = 3
	normal_style.border_color = Color(0.1, 0.3, 0.4, 1.0)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.7, 0.9, 1.0)  # 亮蓝色
	hover_style.corner_radius_top_left = 12
	hover_style.corner_radius_top_right = 12
	hover_style.corner_radius_bottom_left = 12
	hover_style.corner_radius_bottom_right = 12
	hover_style.border_width_left = 4
	hover_style.border_width_right = 4
	hover_style.border_width_top = 4
	hover_style.border_width_bottom = 4
	hover_style.border_color = Color(0.0, 0.2, 0.3, 1.0)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.1, 0.4, 0.6, 1.0)  # 深蓝色
	pressed_style.corner_radius_top_left = 12
	pressed_style.corner_radius_top_right = 12
	pressed_style.corner_radius_bottom_left = 12
	pressed_style.corner_radius_bottom_right = 12
	pressed_style.border_width_left = 4
	pressed_style.border_width_right = 4
	pressed_style.border_width_top = 4
	pressed_style.border_width_bottom = 4
	pressed_style.border_color = Color(0.0, 0.1, 0.2, 1.0)
	
	# 应用样式
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", hover_style)

func setup_font():
	"""设置字体样式"""
	# 设置字体颜色
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.YELLOW)
	
	# 设置字体大小
	add_theme_font_size_override("font_size", FONT_SIZE)

func set_comparison_type(type: ComparisonType):
	"""设置比较类型和显示符号"""
	comparison_type = type
	
	match type:
		ComparisonType.GREATER:
			symbol_text = ">"
			text = ">"
		ComparisonType.LESS:
			symbol_text = "<"
			text = "<"
		ComparisonType.EQUAL:
			symbol_text = "="
			text = "="
	
	print("ComparisonButton: 设置符号为 %s" % symbol_text)

func get_comparison_type() -> ComparisonType:
	"""获取比较类型"""
	return comparison_type

func get_symbol_text() -> String:
	"""获取符号文本"""
	return symbol_text

func play_click_animation():
	"""播放点击动画"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放动画
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)
	
	# 颜色闪烁
	var original_modulate = modulate
	tween.tween_property(self, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(self, "modulate", original_modulate, 0.1).set_delay(0.1)

func play_correct_animation():
	"""播放正确答案动画"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 绿色闪烁
	tween.tween_property(self, "modulate", Color.GREEN, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).set_delay(0.3)
	
	# 缩放效果
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.2)

func play_wrong_animation():
	"""播放错误答案动画"""
	var tween = create_tween()
	tween.set_loops(2)
	
	# 红色闪烁
	tween.tween_property(self, "modulate", Color.RED, 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)

func set_enabled(enabled: bool):
	"""设置按钮启用状态"""
	disabled = not enabled
	
	if enabled:
		modulate = Color.WHITE
	else:
		modulate = Color(0.5, 0.5, 0.5, 1.0)  # 变灰