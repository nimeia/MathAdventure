extends Node2D
class_name FruitTree

# ========== 常量定义 ==========
const FRUIT_SIZE = 35  # 果子大小（适配 emoji 显示）
const TREE_WIDTH = 650  # 树的宽度（进一步增大）
const TREE_HEIGHT = 450  # 树的高度（进一步增大）
const DROP_DISTANCE = 100  # 果子掉落距离

# ========== 果子容器 ==========
var fruits = []  # 存储所有果子节点
var fruit_positions = []  # 预设的果子位置

func _ready():
	# 初始化果子位置（在树冠区域内随机分布）
	generate_fruit_positions()

func generate_fruit_positions():
	"""生成果子的可能位置（网格+随机偏移）"""
	fruit_positions.clear()
	
	# 使用网格布局确保果子分布均匀且不重叠
	var grid_size = 5  # 5x5 网格（适应更大的树）
	var cell_width = TREE_WIDTH * 0.65 / grid_size  # 网格宽度
	var cell_height = TREE_HEIGHT * 0.45 / grid_size  # 网格高度
	
	for row in range(grid_size):
		for col in range(grid_size):
			# 计算网格中心位置
			var base_x = (col - grid_size/2.0 + 0.5) * cell_width
			var base_y = (row - grid_size/2.0 + 0.5) * cell_height - 120  # 向上偏移到更大的树冠区域
			
			# 添加随机偏移，但保持在网格内
			var offset_x = randf_range(-cell_width * 0.3, cell_width * 0.3)
			var offset_y = randf_range(-cell_height * 0.3, cell_height * 0.3)
			
			var pos = Vector2(base_x + offset_x, base_y + offset_y)
			fruit_positions.append(pos)
	
	print("生成了 %d 个果子位置（网格布局）" % fruit_positions.size())

func generate_fruits(count: int):
	"""生成指定数量的果子"""
	print("FruitTree: 生成 %d 个果子" % count)
	
	# 清除旧果子
	clear_fruits()
	
	# 随机选择位置
	var selected_positions = fruit_positions.duplicate()
	selected_positions.shuffle()
	
	# 生成新果子
	for i in range(count):
		if i < selected_positions.size():
			create_fruit(selected_positions[i])
		else:
			# 如果位置不够，随机生成新位置
			var random_pos = Vector2(
				randf_range(-TREE_WIDTH/2, TREE_WIDTH/2),
				randf_range(-TREE_HEIGHT/2, -TREE_HEIGHT/4)
			)
			create_fruit(random_pos)

func create_fruit(pos: Vector2):
	"""在指定位置创建一个果子（使用苹果 emoji）"""
	# 创建果子节点
	var fruit = Node2D.new()
	fruit.position = pos
	add_child(fruit)
	
	# 使用 Label 显示苹果 emoji
	var apple_label = Label.new()
	apple_label.text = "🍎"
	apple_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	apple_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# 设置字体大小
	apple_label.add_theme_font_size_override("font_size", int(FRUIT_SIZE * 1.2))
	
	# 设置位置和大小
	apple_label.size = Vector2(FRUIT_SIZE * 1.5, FRUIT_SIZE * 1.5)
	apple_label.position = Vector2(-FRUIT_SIZE * 0.75, -FRUIT_SIZE * 0.75)
	
	# 添加轻微的阴影效果
	apple_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	apple_label.add_theme_constant_override("shadow_offset_x", 2)
	apple_label.add_theme_constant_override("shadow_offset_y", 2)
	
	fruit.add_child(apple_label)
	
	# 存储果子引用
	fruits.append(fruit)
	
	print("创建苹果 emoji 在位置: %s" % str(pos))

func clear_fruits():
	"""清除所有果子"""
	for fruit in fruits:
		if fruit and is_instance_valid(fruit):
			fruit.queue_free()
	fruits.clear()
	print("清除所有果子")

func play_fruit_drop_animation():
	"""播放果子掉落动画"""
	print("播放果子掉落动画")
	
	for fruit in fruits:
		if fruit and is_instance_valid(fruit):
			# 创建掉落动画
			var tween = create_tween()
			tween.set_parallel(true)
			
			# 下降动画
			var target_pos = fruit.position + Vector2(0, DROP_DISTANCE)
			tween.tween_property(fruit, "position", target_pos, 0.8)
			tween.tween_property(fruit, "rotation", randf_range(-0.5, 0.5), 0.8)
			
			# 淡出效果
			tween.tween_property(fruit, "modulate:a", 0.0, 0.8)

func play_fruit_blink_animation():
	"""播放果子闪烁动画"""
	print("播放果子闪烁动画")
	
	for fruit in fruits:
		if fruit and is_instance_valid(fruit):
			# 创建闪烁动画
			var tween = create_tween()
			tween.set_loops(3)  # 闪烁3次
			
			# 透明度变化
			tween.tween_property(fruit, "modulate:a", 0.3, 0.2)
			tween.tween_property(fruit, "modulate:a", 1.0, 0.2)

func _draw():
	"""绘制树干和树冠"""
	# 绘制更大的树干
	var trunk_rect = Rect2(Vector2(-35, 120), Vector2(70, 180))
	draw_rect(trunk_rect, Color(0.5, 0.3, 0.1))  # 棕色
	
	# 绘制更大的主树冠
	var crown_center = Vector2(0, -80)
	draw_circle(crown_center, 280, Color(0.15, 0.4, 0.15))  # 深绿色背景
	
	# 添加树冠主体
	draw_circle(crown_center, 260, Color(0.2, 0.5, 0.2))  # 森林绿
	
	# 添加更多高光区域增加层次
	draw_circle(crown_center + Vector2(-60, -60), 85, Color(0.3, 0.6, 0.3))
	draw_circle(crown_center + Vector2(50, -30), 65, Color(0.25, 0.55, 0.25))
	draw_circle(crown_center + Vector2(-15, 45), 55, Color(0.28, 0.58, 0.28))
	draw_circle(crown_center + Vector2(30, 60), 45, Color(0.32, 0.62, 0.32))
	draw_circle(crown_center + Vector2(-70, 20), 50, Color(0.26, 0.56, 0.26))
