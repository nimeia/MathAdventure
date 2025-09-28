# 关卡选择系统集成指南

## 概述

我已经为您的数学冒险游戏创建了一个完整的关卡选择系统，包括主菜单、进度管理、关卡解锁和返回功能。

## 新增文件列表

### 脚本文件 (scripts/)
1. **MainMenuManager.gd** - 主菜单管理器
2. **LevelButton.gd** - 关卡选择按钮组件
3. **BackToMenuButton.gd** - 返回菜单按钮组件
4. **GameLauncher.gd** - 游戏启动器

### 场景文件 (scenes/)
1. **MainMenu.tscn** - 主菜单场景
2. **GameLauncher.tscn** - 游戏启动场景

## 系统特性

### 主菜单系统
- 🎮 美观的主菜单界面
- 📊 玩家统计显示（金币、完成关卡）
- 🔐 关卡解锁系统
- ⚙️ 设置和退出功能

### 关卡管理
- 📋 关卡信息展示（编号、标题、描述）
- 🌟 完成状态和星级显示
- 🔓 渐进式解锁机制
- 💰 金币和进度跟踪

### 用户体验
- 🎨 统一的视觉设计风格
- ✨ 流畅的场景转换动画
- 💬 用户友好的反馈系统
- ⏰ 健康时长集成

## 使用方法

### 1. 设置游戏启动

将 `GameLauncher.tscn` 设为项目主场景：

```
项目设置 -> 应用程序 -> 运行 -> 主场景: res://scenes/GameLauncher.tscn
```

### 2. 关卡配置

在 `MainMenuManager.gd` 中配置关卡信息：

```gdscript
var level_definitions = [
    {
        "number": 1,
        "title": "数数果园",
        "description": "数一数树上的苹果",
        "scene_path": "res://main.tscn",
        "unlock_requirement": 0  # 默认解锁
    },
    {
        "number": 2,
        "title": "比较大小桥",
        "description": "选择正确的符号",
        "scene_path": "res://scenes/Level2.tscn",
        "unlock_requirement": 1  # 需要完成第1关
    }
    // 添加更多关卡...
]
```

### 3. 关卡集成

在现有关卡脚本中添加以下方法：

```gdscript
func get_level_number() -> int:
    return current_level

func get_coins() -> int:
    return coins

func get_health_time() -> int:
    if TimerManager:
        return TimerManager.get_remaining_game_time()
    return 0
```

### 4. 返回按钮设置

在关卡的 `_ready()` 方法中添加：

```gdscript
func _ready():
    # ... 其他初始化代码
    setup_back_button()

func setup_back_button():
    # 动态创建返回按钮
    var back_button = BackToMenuButton.create_back_button(self, Vector2(20, 20))
    back_button.z_index = 100
```

## 已修改的文件

### GameManager.gd (第一关)
- 添加了主菜单兼容方法
- 修改了关卡完成逻辑，返回主菜单而非直接进入下一关
- 添加了返回按钮支持

### Level2Manager.gd (第二关)
- 添加了主菜单兼容方法
- 修改了关卡完成后的跳转逻辑
- 添加了返回按钮设置

## 调试功能

### 主菜单调试
- **F9** - 解锁所有关卡
- **F10** - 重置游戏进度

### 启动器调试
- **F11** - 跳过启动屏幕，直接进入主菜单
- **F12** - 跳过启动屏幕，直接进入第一关

### 返回功能
- **ESC** - 快速返回主菜单（需确认）

## 数据流程

### 进度保存
1. 完成关卡时自动保存进度
2. 返回主菜单时保存当前状态
3. 进度数据包括：关卡进度、金币、健康时长

### 解锁机制
1. 第一关默认解锁
2. 完成关卡后解锁下一关
3. 未解锁关卡显示为灰色并提示需求

### 场景切换
1. GameLauncher → 首次运行检查 → MainMenu/Tutorial
2. MainMenu → 选择关卡 → 对应关卡场景
3. 关卡完成 → 保存进度 → 返回 MainMenu

## 扩展指南

### 添加新关卡
1. 在 `level_definitions` 中添加关卡配置
2. 创建关卡场景和脚本
3. 在关卡脚本中实现必要的接口方法
4. 设置解锁条件

### 自定义界面
1. 修改 `MainMenu.tscn` 调整界面布局
2. 在 `LevelButton.gd` 中自定义按钮样式
3. 修改 `MainMenuManager.gd` 调整功能逻辑

### 星级系统
1. 在关卡中计算表现分数
2. 在关卡完成时传递星级数据
3. 在主菜单中显示星级状态

## 注意事项

1. **健康时长集成**：确保所有关卡都正确处理 TimerManager 信号
2. **进度保存**：关卡完成后必须调用进度保存方法
3. **场景路径**：确保所有场景路径配置正确
4. **按钮连接**：确保所有按钮事件正确连接
5. **错误处理**：添加适当的错误检查和用户提示

## 测试建议

1. 测试首次启动流程
2. 测试关卡解锁和锁定状态
3. 测试进度保存和加载
4. 测试返回按钮功能
5. 测试健康时长控制
6. 测试所有场景切换

这个系统为您的数学冒险游戏提供了专业的关卡选择和进度管理功能，让玩家可以自由选择想要挑战的关卡，并跟踪他们的游戏进度。