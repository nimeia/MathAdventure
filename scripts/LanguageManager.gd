extends Node
class_name LanguageManager

signal language_changed

const SAVE_PATH := "user://language_settings.save"

var current_language: String = "en"

var translations := {
        "game_title": {
                "en": "🎮 Math Adventure",
                "zh": "🎮 数学冒险"
        },
        "game_subtitle": {
                "en": "Choose a level to challenge",
                "zh": "选择你想挑战的关卡"
        },
        "player_stats": {
                "en": "🪙 Coins: %d | 🏆 Completed: %d/%d",
                "zh": "🪙 金币: %d | 🏆 完成关卡: %d/%d"
        },
        "settings_button": {
                "en": "⚙️ Settings",
                "zh": "⚙️ 设置"
        },
        "exit_button": {
                "en": "🚪 Exit",
                "zh": "🚪 退出"
        },
        "settings_title": {
                "en": "Game Settings",
                "zh": "游戏设置"
        },
        "settings_confirm": {
                "en": "Clear Progress",
                "zh": "清空记录"
        },
        "settings_cancel": {
                "en": "Cancel",
                "zh": "取消"
        },
        "settings_dialog_text": {
                "en": "Do you want to clear all progress? This cannot be undone.",
                "zh": "确定要清空游戏的记录数据吗？此操作无法撤销。"
        },
        "settings_language_label": {
                "en": "Language",
                "zh": "语言"
        },
        "language_en": {
                "en": "English",
                "zh": "英文"
        },
        "language_zh": {
                "en": "Chinese",
                "zh": "中文"
        },
        "feedback_locked": {
                "en": "This level is locked. Please finish the previous level first!",
                "zh": "此关卡尚未解锁，请先完成前面的关卡！"
        },
        "feedback_in_dev": {
                "en": "This level is under development. Stay tuned!",
                "zh": "此关卡正在开发中，敬请期待！"
        },
        "feedback_rest_time": {
                "en": "Break time is not over yet. Please try again later!",
                "zh": "休息时间未结束，请稍后再试！"
        },
        "feedback_entering": {
                "en": "Entering level...",
                "zh": "正在进入关卡..."
        },
        "feedback_timer_rest": {
                "en": "Play time is over. Please take a break!",
                "zh": "游戏时间到，请休息一下再来玩吧！"
        },
        "feedback_record_cleared": {
                "en": "Progress cleared. Start a new adventure!",
                "zh": "已清空游戏记录，从零开始冒险吧！"
        },
        "feedback_thanks": {
                "en": "Thanks for playing Math Adventure!",
                "zh": "感谢游玩数学冒险！"
        },
        "locked_title": {
                "en": "???",
                "zh": "???"
        },
        "locked_desc": {
                "en": "Locked",
                "zh": "未解锁"
        }
}

func _ready():
        load_language()

func set_language(lang: String) -> void:
        if lang != "en" and lang != "zh":
                return
        if current_language == lang:
                return
        current_language = lang
        save_language()
        language_changed.emit()

func get_language() -> String:
        return current_language

func tr_text(key: String) -> String:
        var lang_map = translations.get(key, {})
        return lang_map.get(current_language, lang_map.get("en", key))

func format_text(key: String, args: Array) -> String:
        return tr_text(key) % args

func save_language() -> void:
        var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
        if file:
                file.store_var({"language": current_language})
                file.close()

func load_language() -> void:
        if FileAccess.file_exists(SAVE_PATH):
                var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
                if file:
                        var data = file.get_var()
                        file.close()
                        current_language = data.get("language", "en")
        else:
                current_language = "en"
