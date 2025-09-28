@tool
extends EditorScript
# 工具脚本：创建 CandyShopScene.tscn 场景文件

func _run():
	print("\n========================================")
	print("    创建 CandyShopScene 场景文件")
	print("========================================\n")
	
	create_candy_shop_scene()

func create_candy_shop_scene():
	"""创建糖果商店场景"""
	
	# 创建根节点 Node2D
	var root = Node2D.new()
	root.name = "CandyShopScene"
	
	# 附加脚本
	var script_path = "res://scripts/CandyShopScene.gd"
	if ResourceLoader.exists(script_path):
		var script = load(script_path)
		root.set_script(script)
		print("✅ 已附加脚本: CandyShopScene.gd")
	else:
		print("❌ 脚本不存在: CandyShopScene.gd")
	
	# 创建背景 ColorRect
	var background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.94, 0.9, 1.0, 1.0)  # 淡紫色
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.size = Vector2(1280, 720)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background, true)
	
	# 创建 UI 容器
	var ui = Control.new()
	ui.name = "UI"
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(ui, true)
	
	# 创建顶部面板
	var top_panel = Panel.new()
	top_panel.name = "TopPanel"
	top_panel.position = Vector2(0, 0)
	top_panel.size = Vector2(1280, 80)
	ui.add_child(top_panel, true)
	
	# TimerBar
	var timer_bar = ProgressBar.new()
	timer_bar.name = "TimerBar"
	timer_bar.position = Vector2(440, 20)
	timer_bar.size = Vector2(400, 40)
	timer_bar.min_value = 0
	timer_bar.max_value = 10
	timer_bar.value = 10
	timer_bar.show_percentage = false
	top_panel.add_child(timer_bar, true)
	
	# TimerLabel
	var timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(620, 25)
	timer_label.size = Vector2(40, 30)
	timer_label.text = "10"
	timer_label.add_theme_font_size_override("font_size", 24)
	top_panel.add_child(timer_label, true)
	
	# CoinLabel
	var coin_label = Label.new()
	coin_label.name = "CoinLabel"
	coin_label.position = Vector2(900, 25)
	coin_label.size = Vector2(200, 30)
	coin_label.text = "💰 金币: 0"
	coin_label.add_theme_font_size_override("font_size", 20)
	top_panel.add_child(coin_label, true)
	
	# ProgressLabel
	var progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.position = Vector2(200, 25)
	progress_label.size = Vector2(200, 30)
	progress_label.text = "进度: 0/5"
	progress_label.add_theme_font_size_override("font_size", 20)
	top_panel.add_child(progress_label, true)
	
	# BackButton
	var back_button = Button.new()
	back_button.name = "BackButton"
	back_button.position = Vector2(10, 20)
	back_button.size = Vector2(100, 40)
	back_button.text = "🏠 返回"
	back_button.add_theme_font_size_override("font_size", 16)
	top_panel.add_child(back_button, true)
	
	# 创建商店区域
	var shop_area = Control.new()
	shop_area.name = "ShopArea"
	shop_area.position = Vector2(0, 100)
	shop_area.size = Vector2(1280, 520)
	ui.add_child(shop_area, true)
	
	# ShopSprite (占位符)
	var shop_sprite = Sprite2D.new()
	shop_sprite.name = "ShopSprite"
	shop_sprite.position = Vector2(640, 150)
	shop_area.add_child(shop_sprite, true)
	
	# CandyDisplay
	var candy_display = Label.new()
	candy_display.name = "CandyDisplay"
	candy_display.position = Vector2(590, 120)
	candy_display.size = Vector2(100, 100)
	candy_display.text = "🍬"
	candy_display.add_theme_font_size_override("font_size", 64)
	candy_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_area.add_child(candy_display, true)
	
	# PriceLabel
	var price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.position = Vector2(340, 250)
	price_label.size = Vector2(600, 60)
	price_label.text = "🍬 糖果价格：25 元"
	price_label.add_theme_font_size_override("font_size", 32)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_area.add_child(price_label, true)
	
	# PayLabel
	var pay_label = Label.new()
	pay_label.name = "PayLabel"
	pay_label.position = Vector2(340, 320)
	pay_label.size = Vector2(600, 60)
	pay_label.text = "💰 小勇士支付：50 元"
	pay_label.add_theme_font_size_override("font_size", 32)
	pay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_area.add_child(pay_label, true)
	
	# AnswerContainer
	var answer_container = HBoxContainer.new()
	answer_container.name = "AnswerContainer"
	answer_container.position = Vector2(290, 420)
	answer_container.size = Vector2(700, 80)
	answer_container.add_theme_constant_override("separation", 50)
	answer_container.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_area.add_child(answer_container, true)
	
	# 创建答案按钮
	for i in range(3):
		var btn = Button.new()
		btn.name = "AnswerBtn%d" % (i + 1)
		btn.text = "找零 %d 元" % (10 + i * 5)
		btn.custom_minimum_size = Vector2(180, 60)
		btn.add_theme_font_size_override("font_size", 24)
		answer_container.add_child(btn, true)
	
	# FeedbackLabel
	var feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.position = Vector2(340, 540)
	feedback_label.size = Vector2(600, 60)
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 28)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.visible = false
	ui.add_child(feedback_label, true)
	
	# CompletePopup
	var complete_popup = PopupPanel.new()
	complete_popup.name = "CompletePopup"
	complete_popup.position = Vector2(340, 200)
	complete_popup.size = Vector2(600, 400)
	complete_popup.visible = false
	ui.add_child(complete_popup, true)
	
	# CompletePopup 内容
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	complete_popup.add_child(vbox, true)
	
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "🎉 恭喜通关！"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label, true)
	
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = "统计信息"
	stats_label.add_theme_font_size_override("font_size", 20)
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(stats_label, true)
	
	var continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "继续冒险"
	continue_button.custom_minimum_size = Vector2(200, 50)
	continue_button.add_theme_font_size_override("font_size", 24)
	vbox.add_child(continue_button, true)
	
	# 创建音频节点
	var audio = Node.new()
	audio.name = "Audio"
	root.add_child(audio, true)
	
	var correct_sound = AudioStreamPlayer.new()
	correct_sound.name = "CorrectSound"
	audio.add_child(correct_sound, true)
	
	var wrong_sound = AudioStreamPlayer.new()
	wrong_sound.name = "WrongSound"
	audio.add_child(wrong_sound, true)
	
	var timeout_sound = AudioStreamPlayer.new()
	timeout_sound.name = "TimeoutSound"
	audio.add_child(timeout_sound, true)
	
	# 保存场景
	var scene = PackedScene.new()
	scene.pack(root)
	
	var save_path = "res://scenes/CandyShopScene.tscn"
	var result = ResourceSaver.save(scene, save_path)
	
	if result == OK:
		print("✅ 场景创建成功: %s" % save_path)
		print("")
		print("场景结构：")
		print_tree(root, 0)
		print("")
		print("提示：")
		print("1. 场景已保存到 res://scenes/CandyShopScene.tscn")
		print("2. 可以在编辑器中打开并调整")
		print("3. 主菜单第4关现在应该可以正常点击了")
	else:
		print("❌ 场景保存失败")
		print("请在 Godot 编辑器中手动创建场景")
	
	# 清理
	root.queue_free()

func print_tree(node: Node, depth: int):
	"""打印节点树结构"""
	var indent = "  ".repeat(depth)
	print("%s└─ %s (%s)" % [indent, node.name, node.get_class()])
	for child in node.get_children():
		print_tree(child, depth + 1)