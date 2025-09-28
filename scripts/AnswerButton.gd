extends Button
class_name AnswerButton

# ========== 常量定义 ==========
const BUTTON_SIZE = Vector2(100, 80)
const FONT_SIZE = 32

# ========== 内部变量 ==========
var number_value = 0

func _ready():
	# 设置按钮基本属性
	custom_minimum_size = BUTTON_SIZE
	
	# 设置按钮样式
	setup_button_style()
	
	# 设置字体大小
	setup_font()
	
	# 连接按钮点击信号（作为备用，主要通过GameManager连接）
	pressed.connect(_on_button_pressed)

func setup_button_style():
	"""设置按钮的视觉样式"""
	# 创建按钮样式
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.7, 0.9, 1.0)  # 浅蓝色
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_left = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color.BLUE
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color.CYAN
	hover_style.corner_radius_top_left = 10
	hover_style.corner_radius_top_right = 10
	hover_style.corner_radius_bottom_left = 10
	hover_style.corner_radius_bottom_right = 10
	hover_style.border_width_left = 3
	hover_style.border_width_right = 3
	hover_style.border_width_top = 3
	hover_style.border_width_bottom = 3
	hover_style.border_color = Color(0.0, 0.0, 0.5)  # 深蓝色
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color.BLUE
	pressed_style.corner_radius_top_left = 10
	pressed_style.corner_radius_top_right = 10
	pressed_style.corner_radius_bottom_left = 10
	pressed_style.corner_radius_bottom_right = 10
	pressed_style.border_width_left = 3
	pressed_style.border_width_right = 3
	pressed_style.border_width_top = 3
	pressed_style.border_width_bottom = 3
	pressed_style.border_color = Color(0.0, 0.0, 0.3)  # 海军蓝
	
	# 应用样式
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", hover_style)

func setup_font():
	"""设置按钮字体"""
	# 设置字体颜色
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.YELLOW)
	
	# 设置字体大小（通过创建 Theme 资源）
	var font = ThemeDB.fallback_font
	add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", FONT_SIZE)

func set_number(value: int):
	"""设置按钮显示的数字"""
	number_value = value
	text = str(value)  # 直接显示数字
	print("AnswerButton: 设置数字为 %d" % value)

func get_number() -> int:
	"""获取按钮的数字值"""
	return number_value

func _on_button_pressed():
	"""按钮被点击时的处理"""
	print("AnswerButton: 按钮 %d 被点击" % number_value)
	
	# 播放点击动画
	play_click_animation()

func play_click_animation():
	"""播放点击动画效果"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放动画
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)
	
	# 颜色动画
	var original_modulate = modulate
	tween.tween_property(self, "modulate", Color.WHITE * 1.2, 0.1)
	tween.tween_property(self, "modulate", original_modulate, 0.1).set_delay(0.1)
