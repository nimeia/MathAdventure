extends Button
class_name BackToMenuButton

# ========== 返回菜单按钮 ==========
# 提供从关卡返回主菜单的功能，处理进度保存和场景切换

# ========== 配置选项 ==========
@export var show_confirmation: bool = true
@export var save_progress: bool = true
@export var button_text: String = "🏠 返回"
@export var main_menu_scene: String = "res://scenes/MainMenu.tscn"

# ========== 节点引用 ==========
var confirmation_dialog: AcceptDialog

func _ready():
    print("BackToMenu: 返回菜单按钮初始化")
    setup_button()
    connect_signals()

# ========== 按钮设置 ==========
func setup_button():
    """设置按钮外观和属性"""
    if button_text != "":
        text = button_text
    
    # 设置按钮样式
    add_theme_font_size_override("font_size", 16)
    
    # 设置鼠标悬停提示
    tooltip_text = "返回到主菜单选择其他关卡"

func connect_signals():
    """连接信号"""
    pressed.connect(_on_button_pressed)

# ========== 事件处理 ==========
func _on_button_pressed():
    """按钮被点击"""
    print("BackToMenu: 返回按钮被点击")
    
    if show_confirmation:
        show_confirmation_dialog()
    else:
        go_back_to_menu()

func show_confirmation_dialog():
    """显示确认对话框"""
    if not confirmation_dialog:
        create_confirmation_dialog()
    
    confirmation_dialog.popup_centered()

func create_confirmation_dialog():
    """创建确认对话框"""
    confirmation_dialog = AcceptDialog.new()
    confirmation_dialog.dialog_text = "确定要返回主菜单吗？\n当前关卡的进度将会保存。"
    confirmation_dialog.title = "确认返回"
    confirmation_dialog.ok_button_text = "确定返回"
    confirmation_dialog.add_cancel_button("继续游戏")
    
    # 添加到场景树
    get_tree().current_scene.add_child(confirmation_dialog)
    
    # 连接信号
    confirmation_dialog.confirmed.connect(_on_confirmation_confirmed)
    confirmation_dialog.close_requested.connect(_on_confirmation_cancelled)

func _on_confirmation_confirmed():
    """确认返回主菜单"""
    print("BackToMenu: 用户确认返回主菜单")
    go_back_to_menu()

func _on_confirmation_cancelled():
    """取消返回操作"""
    print("BackToMenu: 用户取消返回操作")

# ========== 主菜单跳转 ==========
func go_back_to_menu():
    """返回主菜单"""
    print("BackToMenu: 正在返回主菜单...")
    
    # 保存当前关卡进度
    if save_progress:
        save_current_progress()
    
    # 显示过渡效果
    show_transition_effect()
    
    # 等待过渡效果完成后切换场景
    await get_tree().create_timer(0.5).timeout
    get_tree().change_scene_to_file(main_menu_scene)

func save_current_progress():
    """保存当前关卡进度"""
    if TimerManager:
        # 尝试从当前场景获取进度信息
        var current_scene = get_tree().current_scene
        var level_num = 1  # 默认值
        var coins = 0
        var health_time = 0
        
        # 尝试获取关卡管理器信息
        if current_scene.has_method("get_level_number"):
            level_num = current_scene.get_level_number()
        
        if current_scene.has_method("get_coins"):
            coins = current_scene.get_coins()
        
        if current_scene.has_method("get_health_time"):
            health_time = current_scene.get_health_time()
        
        # 更新进度
        TimerManager.update_game_progress(level_num, coins, health_time)
        print("BackToMenu: 进度已保存 - 关卡: %d, 金币: %d, 健康时长: %d" % [level_num, coins, health_time])

func show_transition_effect():
    """显示过渡效果"""
    # 创建淡出效果
    var fade_overlay = ColorRect.new()
    fade_overlay.color = Color.BLACK
    fade_overlay.color.a = 0.0
    fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    fade_overlay.z_index = 100
    
    # 添加到当前场景的根节点
    get_tree().current_scene.add_child(fade_overlay)
    
    # 淡出动画
    var tween = create_tween()
    tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)

# ========== 键盘快捷键 ==========
func _input(event):
    """处理键盘快捷键"""
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                # ESC 键触发返回菜单
                if visible and not disabled:
                    _on_button_pressed()

# ========== 静态方法 ==========
static func create_back_button(parent_node: Node, position: Vector2 = Vector2(20, 20)) -> BackToMenuButton:
    """静态方法：创建返回按钮并添加到指定父节点"""
    var back_button = BackToMenuButton.new()
    back_button.position = position
    back_button.size = Vector2(80, 30)
    parent_node.add_child(back_button)
    return back_button

static func add_back_functionality_to_button(button: Button, show_confirm: bool = true) -> void:
    """静态方法：为现有按钮添加返回功能"""
    if not button:
        print("错误：无效的按钮节点")
        return
    
    # 创建返回处理器
    var handler = func():
        var back_handler = BackToMenuButton.new()
        back_handler.show_confirmation = show_confirm
        
        # 添加到按钮的父节点（临时）
        button.get_parent().add_child(back_handler)
        
        # 触发返回操作
        back_handler._on_button_pressed()
        
        # 移除临时节点
        back_handler.queue_free()
    
    # 连接按钮信号
    if not button.pressed.is_connected(handler):
        button.pressed.connect(handler)

# ========== 调试功能 ==========
func _notification(what):
    """处理节点通知"""
    match what:
        NOTIFICATION_VISIBILITY_CHANGED:
            if visible:
                print("BackToMenu: 返回按钮可见")
            else:
                print("BackToMenu: 返回按钮隐藏")

func set_enabled(enabled: bool):
    """设置按钮启用状态"""
    disabled = not enabled
    modulate.a = 1.0 if enabled else 0.5

func set_menu_scene_path(path: String):
    """设置主菜单场景路径"""
    main_menu_scene = path
    print("BackToMenu: 主菜单场景路径设置为 %s" % path)
