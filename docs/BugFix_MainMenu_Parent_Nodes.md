# MainMenu 场景父子关系修复说明

## 问题描述

在打开 MainMenu 时出现错误：
```
ERROR: Invalid scene: node Background does not specify its parent node.
```

## 问题原因

Godot 场景文件 (.tscn) 中，除了根节点外的所有节点都必须指定其父节点。原始的 MainMenu.tscn 文件中缺少了 `parent=` 属性定义。

## 修复内容

### 修复的节点层次结构

```
MainMenu (Control) - 根节点
├── Background (TextureRect) - parent="."
├── BackgroundOverlay (ColorRect) - parent="."  
└── UI (Control) - parent="."
    ├── TitlePanel (Panel) - parent="UI"
    │   ├── GameTitle (Label) - parent="UI/TitlePanel"
    │   └── GameSubtitle (Label) - parent="UI/TitlePanel"
    ├── ScrollContainer (ScrollContainer) - parent="UI"
    │   └── LevelGrid (GridContainer) - parent="UI/ScrollContainer"
    ├── BottomPanel (Panel) - parent="UI"
    │   ├── PlayerStatsLabel (Label) - parent="UI/BottomPanel"
    │   ├── SettingsButton (Button) - parent="UI/BottomPanel"
    │   └── ExitButton (Button) - parent="UI/BottomPanel"
    └── FeedbackLabel (Label) - parent="UI"
```

### 修复前后对比

**修复前（错误）:**
```tscn
[node name="Background" type="TextureRect"]
layout_mode = 1
# ... 其他属性
```

**修复后（正确）:**
```tscn
[node name="Background" type="TextureRect" parent="."]
layout_mode = 1
# ... 其他属性
```

## Godot 场景文件规则

### 父节点引用规则
1. **根节点**：不需要 parent 属性
2. **直接子节点**：使用 `parent="."`
3. **嵌套子节点**：使用完整路径，如 `parent="UI/TitlePanel"`

### 常见父节点引用格式
- `parent="."` - 父节点是根节点
- `parent="NodeName"` - 父节点是同级的 NodeName
- `parent="Parent/Child"` - 父节点是 Parent 下的 Child 节点

## 验证修复

修复后的场景应该：

1. ✅ 不再出现 "node does not specify its parent node" 错误
2. ✅ 可以在 Godot 编辑器中正常打开
3. ✅ 所有 UI 元素按正确层次结构显示
4. ✅ 主菜单管理器脚本可以正确引用所有节点

## 预防措施

### 在 Godot 编辑器中创建场景
1. 使用编辑器的场景面板创建节点层次
2. 不要手动编辑 .tscn 文件的节点结构
3. 如果必须手动编辑，确保每个节点都有正确的 parent 属性

### 节点路径检查
在脚本中引用节点时，确保路径与场景结构匹配：

```gdscript
# 正确的节点引用
@onready var title_label = $UI/TitlePanel/GameTitle
@onready var level_grid = $UI/ScrollContainer/LevelGrid
@onready var feedback_label = $UI/FeedbackLabel
```

这个修复确保了 MainMenu.tscn 文件符合 Godot 的场景格式要求，可以正常加载和显示。