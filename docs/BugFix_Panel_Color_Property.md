# Panel Color 属性错误修复说明

## 问题描述

在 Level 2 运行时出现错误：
```
Invalid access to property or key 'color' on a base object of type 'Panel'
```

## 问题原因

在 `NumberStone.gd` 脚本中，代码试图直接访问 Panel 节点的 `color` 属性，但 Panel 节点没有 `color` 属性。Panel 使用 StyleBox 来控制外观和颜色。

## 错误位置

### 错误代码位置
1. **第23行** - `original_color = background.color`
2. **第32行** - `background.color = Color(0.4, 0.35, 0.3, 1.0)`

## 修复内容

### 1. 修复 _ready() 方法中的原始颜色保存

**修复前（错误）:**
```gdscript
func _ready():
    # 保存原始状态
    original_position = position
    if background:
        original_color = background.color  # ❌ Panel没有color属性
```

**修复后（正确）:**
```gdscript
func _ready():
    # 保存原始状态
    original_position = position
    if background:
        # Panel没有color属性，使用modulate代替
        original_color = background.modulate  # ✅ 使用modulate属性
```

### 2. 修复 setup_stone_appearance() 方法中的颜色设置

**修复前（错误）:**
```gdscript
func setup_stone_appearance():
    if background:
        # 石头背景色（灰褐色）
        background.color = Color(0.4, 0.35, 0.3, 1.0)  # ❌ Panel没有color属性
```

**修复后（正确）:**
```gdscript
func setup_stone_appearance():
    if background:
        # Panel使用StyleBox控制外观，不能直接设置color
        # background.color = Color(0.4, 0.35, 0.3, 1.0)  # 删除这行
```

## Panel vs ColorRect 的区别

### Panel 节点
- 没有直接的 `color` 属性
- 使用 `StyleBox` 控制外观（背景、边框、圆角等）
- 通过 `add_theme_stylebox_override("panel", style_box)` 设置样式
- 可以使用 `modulate` 属性调整整体色调

### ColorRect 节点
- 有直接的 `color` 属性
- 简单的矩形颜色显示
- 直接设置 `color = Color(r, g, b, a)`

## 正确的 Panel 颜色控制方式

### 1. 使用 StyleBox（推荐）
```gdscript
var style_box = StyleBoxFlat.new()
style_box.bg_color = Color(0.4, 0.35, 0.3, 1.0)
background.add_theme_stylebox_override("panel", style_box)
```

### 2. 使用 modulate（用于色调调整）
```gdscript
background.modulate = Color.RED  # 整体染色
```

## 场景结构确认

Level2.tscn 中的节点结构：
```
LeftStone (Control) - NumberStone脚本
├── Background (Panel) - 背景面板
└── NumberLabel (Label) - 数字标签

RightStone (Control) - NumberStone脚本  
├── Background (Panel) - 背景面板
└── NumberLabel (Label) - 数字标签
```

## 验证修复

修复后应该：

1. ✅ 不再出现 "Invalid access to property 'color'" 错误
2. ✅ NumberStone 可以正常初始化
3. ✅ 石头的外观样式正常显示
4. ✅ 动画效果正常工作
5. ✅ Level 2 可以正常启动和运行

## 其他注意事项

1. **modulate vs color**：
   - `modulate` 影响节点及其子节点的整体颜色
   - `color` 是某些节点（如 ColorRect）的直接颜色属性

2. **StyleBox 的优势**：
   - 可以设置背景色、边框、圆角、阴影等
   - 更适合UI元素的复杂样式需求

3. **性能考虑**：
   - StyleBox 创建是一次性的，在 _ready() 中设置
   - 避免在每帧中重复创建 StyleBox

这个修复确保了 NumberStone 组件可以正确处理 Panel 的外观设置，避免了不存在属性的访问错误。