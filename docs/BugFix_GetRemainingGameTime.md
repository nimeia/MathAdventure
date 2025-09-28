# Bug 修复说明：get_remaining_game_time 方法缺失

## 问题描述

在运行 Level 2（比较大小桥）时出现错误：
```
Invalid call. Nonexistent function 'get_remaining_game_time' in base 'Node (TimerManager.gd)'.
```

## 问题原因

在新增的主菜单集成代码中，GameManager.gd 和 Level2Manager.gd 都调用了 `TimerManager.get_remaining_game_time()` 方法，但该方法在 TimerManager.gd 中不存在。

## 解决方案

已在 `TimerManager.gd` 中添加了缺失的方法：

```gdscript
func get_remaining_game_time() -> int:
    """获取剩余游戏时间（秒）"""
    return int(game_time_remaining)
```

## 涉及的文件

### 修改的文件
- `scripts/TimerManager.gd` - 添加了 `get_remaining_game_time()` 方法

### 调用该方法的文件
- `scripts/GameManager.gd` - 第525行，在 `get_health_time()` 方法中
- `scripts/Level2Manager.gd` - 第577行，在 `get_health_time()` 方法中
- `scripts/BackToMenuButton.gd` - 通过关卡脚本的 `get_health_time()` 间接调用

## 测试步骤

1. **启动游戏**
   - 运行游戏，确保不再出现该错误

2. **测试第一关**
   - 进入第一关（数数果园）
   - 验证返回按钮功能正常
   - 完成关卡确认进度保存

3. **测试第二关**
   - 从主菜单进入第二关（比较大小桥）
   - 验证游戏正常运行，无错误信息
   - 测试返回按钮功能
   - 完成关卡确认进度保存

4. **测试主菜单**
   - 验证关卡解锁状态正确
   - 验证金币和进度显示正确

## 验证要点

- ✅ 不再出现 `get_remaining_game_time` 相关错误
- ✅ Level 2 可以正常启动和运行
- ✅ 返回按钮功能正常
- ✅ 进度保存和加载正常
- ✅ 健康时长控制功能正常

## 相关方法说明

### TimerManager.get_remaining_game_time()
- **返回类型**: `int`
- **功能**: 返回剩余游戏时间（秒）
- **用途**: 供关卡脚本获取健康时长信息，用于进度保存

### 关卡脚本.get_health_time()
- **返回类型**: `int`
- **功能**: 关卡脚本接口方法，返回当前健康时长
- **用途**: 供 BackToMenuButton 等组件获取进度信息

## 注意事项

1. 该方法返回的是整数秒数，如果需要浮点精度可以修改返回类型
2. 该方法主要用于进度保存，不影响游戏核心逻辑
3. 如果 TimerManager 不存在，关卡脚本会返回 0 作为默认值

这个修复确保了主菜单系统与现有的健康时长控制系统完全兼容。