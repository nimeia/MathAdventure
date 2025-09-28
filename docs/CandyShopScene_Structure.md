# CandyShopScene.tscn 场景结构文档

## 场景节点结构

```
CandyShopScene (Node2D)
├── Background (ColorRect)
│   └── [设置背景色为淡紫色 #F0E6FF]
├── UI (Control)
│   ├── TopPanel (Panel)
│   │   ├── TimerBar (ProgressBar)
│   │   ├── TimerLabel (Label)
│   │   ├── CoinLabel (Label)
│   │   ├── ProgressLabel (Label)
│   │   └── BackButton (Button)
│   ├── ShopArea (Control)
│   │   ├── ShopSprite (Sprite2D)
│   │   ├── CandyDisplay (Label)
│   │   ├── PriceLabel (Label)
│   │   ├── PayLabel (Label)
│   │   └── AnswerContainer (HBoxContainer)
│   │       ├── AnswerBtn1 (Button)
│   │       ├── AnswerBtn2 (Button)
│   │       └── AnswerBtn3 (Button)
│   ├── FeedbackLabel (Label)
│   └── CompletePopup (PopupPanel)
│       └── VBoxContainer
│           ├── TitleLabel (Label)
│           ├── StatsLabel (Label)
│           └── ContinueButton (Button)
└── Audio (Node)
    ├── CorrectSound (AudioStreamPlayer)
    ├── WrongSound (AudioStreamPlayer)
    └── CompleteSound (AudioStreamPlayer)
```

## 在 Godot 编辑器中的设置步骤

### 1. 创建根节点
- 创建新场景
- 选择 `Node2D` 作为根节点
- 重命名为 `CandyShopScene`
- 附加脚本 `res://scripts/CandyShopScene.gd`

### 2. 创建背景
```gdscript
Background (ColorRect):
- Position: (0, 0)
- Size: (1280, 720)
- Color: #F0E6FF (淡紫色)
- Mouse Filter: Ignore
```

### 3. 创建 UI 容器
```gdscript
UI (Control):
- Anchor: Full Rect
- Mouse Filter: Pass
```

### 4. 创建顶部面板
```gdscript
TopPanel (Panel):
- Position: (0, 0)
- Size: (1280, 80)
- Custom Style: 使用 StyleBoxFlat
  - Background Color: #4A3C6B (深紫色)
  - Corner Radius: 0, 0, 10, 10
```

#### 4.1 倒计时进度条
```gdscript
TimerBar (ProgressBar):
- Position: (440, 20)
- Size: (400, 40)
- Min Value: 0
- Max Value: 10
- Value: 10
- Show Percentage: false
- Custom Styles:
  - Background: 灰色 #333333
  - Fill: 绿色渐变
```

#### 4.2 倒计时标签
```gdscript
TimerLabel (Label):
- Position: (620, 25)
- Size: (40, 30)
- Text: "10"
- Align: Center
- Font Size: 24
- Font Color: White
```

#### 4.3 金币标签
```gdscript
CoinLabel (Label):
- Position: (900, 25)
- Size: (200, 30)
- Text: "💰 金币: 0"
- Font Size: 20
- Font Color: Gold (#FFD700)
```

#### 4.4 进度标签
```gdscript
ProgressLabel (Label):
- Position: (200, 25)
- Size: (200, 30)
- Text: "进度: 0/8"
- Font Size: 20
- Font Color: White
```

#### 4.5 返回按钮
```gdscript
BackButton (Button):
- Position: (10, 20)
- Size: (100, 40)
- Text: "🏠 返回"
- Font Size: 16
```

### 5. 创建商店区域
```gdscript
ShopArea (Control):
- Position: (0, 100)
- Size: (1280, 520)
```

#### 5.1 商店精灵（可选）
```gdscript
ShopSprite (Sprite2D):
- Position: (640, 150)
- Texture: 商店老板图片（如果有）
- Scale: (0.5, 0.5)
```

#### 5.2 糖果显示
```gdscript
CandyDisplay (Label):
- Position: (590, 120)
- Size: (100, 100)
- Text: "🍬"
- Font Size: 64
- Align: Center
```

#### 5.3 价格标签
```gdscript
PriceLabel (Label):
- Position: (340, 250)
- Size: (600, 60)
- Text: "🍬 糖果价格：25 元"
- Font Size: 32
- Font Color: #8B4513 (棕色)
- Align: Center
```

#### 5.4 支付标签
```gdscript
PayLabel (Label):
- Position: (340, 320)
- Size: (600, 60)
- Text: "💰 小勇士支付：50 元"
- Font Size: 32
- Font Color: #228B22 (绿色)
- Align: Center
```

#### 5.5 答案容器
```gdscript
AnswerContainer (HBoxContainer):
- Position: (290, 420)
- Size: (700, 80)
- Separation: 50
- Alignment: Center
```

##### 答案按钮
```gdscript
AnswerBtn1, AnswerBtn2, AnswerBtn3 (Button):
- Custom Minimum Size: (180, 60)
- Text: "找零 X 元"
- Font Size: 24
- Custom Styles:
  - Normal: 淡蓝色背景 #E6F3FF
  - Hover: 蓝色背景 #CCE5FF
  - Pressed: 深蓝色背景 #99CCFF
  - Disabled: 灰色背景 #CCCCCC
```

### 6. 创建反馈标签
```gdscript
FeedbackLabel (Label):
- Position: (340, 540)
- Size: (600, 60)
- Text: ""
- Font Size: 28
- Align: Center
- Visible: false
```

### 7. 创建通关弹窗
```gdscript
CompletePopup (PopupPanel):
- Position: (340, 200)
- Size: (600, 400)
- Visible: false
```

内部结构：
```gdscript
VBoxContainer:
- Alignment: Center
- Separation: 20

TitleLabel (Label):
- Text: "🎉 恭喜通关！"
- Font Size: 36
- Align: Center

StatsLabel (Label):
- Text: "统计信息"
- Font Size: 20
- Autowrap: true

ContinueButton (Button):
- Text: "继续冒险"
- Custom Minimum Size: (200, 50)
- Font Size: 24
```

### 8. 创建音频节点（可选）
```gdscript
Audio (Node):
- 用于管理音效

CorrectSound (AudioStreamPlayer):
- Stream: 加载正确答案音效

WrongSound (AudioStreamPlayer):
- Stream: 加载错误答案音效

CompleteSound (AudioStreamPlayer):
- Stream: 加载通关音效
```

## 特殊设置说明

### 主题设置
建议为整个场景创建一个统一的主题（Theme）：
1. 创建新的 Theme 资源
2. 设置默认字体、颜色方案
3. 应用到 UI 节点

### 响应式布局
使用锚点和边距设置，确保不同分辨率下的适配：
- TopPanel: 使用 PRESET_TOP_WIDE
- ShopArea: 使用 PRESET_CENTER
- CompletePopup: 使用 PRESET_CENTER

### 动画效果（可选）
可以添加 AnimationPlayer 节点来创建：
- 按钮点击动画
- 糖果掉落动画
- 金币增加动画
- 通关庆祝动画

## 测试检查清单

- [ ] 根节点是 Node2D 类型
- [ ] 已附加 CandyShopScene.gd 脚本
- [ ] PriceLabel 节点路径正确
- [ ] PayLabel 节点路径正确
- [ ] AnswerContainer 包含 3 个按钮
- [ ] TimerBar 已设置正确的最大值
- [ ] CoinLabel 显示正常
- [ ] 所有节点名称与脚本中的 @onready 变量匹配

## 快速创建提示

在 Godot 编辑器中，可以使用以下快捷方式：
1. Ctrl+A: 添加子节点
2. F2: 重命名节点
3. Ctrl+D: 复制节点（用于创建多个答案按钮）
4. 使用场景面板的搜索功能快速找到需要的节点类型

## 运行前检查

1. 保存场景为 `res://scenes/CandyShopScene.tscn`
2. 确认脚本路径 `res://scripts/CandyShopScene.gd` 已正确附加
3. 运行场景测试基本功能
4. 检查控制台是否有节点引用错误