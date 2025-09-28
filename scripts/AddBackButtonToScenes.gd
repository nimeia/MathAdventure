@tool
extends EditorScript
# 工具脚本：在编辑器中为场景添加返回按钮

# 运行此脚本将为选定的场景添加返回按钮
# 使用方法：
# 1. 在 Godot 编辑器中打开场景
# 2. 运行此脚本 (File -> Run)
# 3. 按钮将被添加到场景中

func _run():
	print("\n========== 添加返回按钮到场景 ==========")
	
	var edited_scene = get_scene()
	if not edited_scene:
		print("错误：没有打开的场景")
		return
	
	print("当前场景: %s" % edited_scene.name)
	
	# 查找 UI 节点
	var ui_node = edited_scene.get_node_or_null("UI")
	if not ui_node:
		print("错误：场景中没有 UI 节点")
		return
	
	# 查找或创建 TopPanel
	var top_panel = ui_node.get_node_or_null("TopPanel")
	if not top_panel:
		print("创建 TopPanel 节点...")
		top_panel = Control.new()
		top_panel.name = "TopPanel"
		top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		top_panel.size = Vector2(1280, 60)
		ui_node.add_child(top_panel)
		top_panel.owner = edited_scene
	
	# 检查是否已有返回按钮
	var existing_back_button = top_panel.get_node_or_null("BackButton")
	if existing_back_button:
		print("场景中已有返回按钮，更新属性...")
		update_back_button(existing_back_button)
	else:
		print("创建新的返回按钮...")
		create_new_back_button(top_panel, edited_scene)
	
	print("========== 完成 ==========")
	print("提示：")
	print("1. 保存场景 (Ctrl+S)")
	print("2. 返回按钮已添加到 UI/TopPanel/BackButton")
	print("3. 脚本会自动处理返回功能")

func create_new_back_button(parent: Node, scene_root: Node):
	"""创建新的返回按钮"""
	var back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "🏠 返回"
	back_button.tooltip_text = "返回主菜单"
	
	# 设置位置和大小
	back_button.position = Vector2(10, 10)
	back_button.size = Vector2(100, 40)
	
	# 设置样式
	back_button.add_theme_font_size_override("font_size", 16)
	
	# 添加到父节点
	parent.add_child(back_button)
	back_button.owner = scene_root
	
	print("✅ 返回按钮创建成功")

func update_back_button(button: Button):
	"""更新现有返回按钮的属性"""
	button.text = "🏠 返回"
	button.tooltip_text = "返回主菜单"
	button.position = Vector2(10, 10)
	button.size = Vector2(100, 40)
	print("✅ 返回按钮属性已更新")