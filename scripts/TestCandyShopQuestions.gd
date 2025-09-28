extends Node
# 测试脚本：验证糖果商店找零题目生成逻辑

# ========== 题目生成常量（与主脚本保持一致） ==========
const MIN_PRICE = 10  # 糖果最小价格
const MAX_PRICE = 50  # 糖果最大价格
const MIN_PAY_AMOUNT = 10  # 支付金额最少多出
const MAX_PAY_AMOUNT = 100  # 支付金额最大值
const MIN_WRONG_DIFF = 1  # 错误答案最小差值
const MAX_WRONG_DIFF = 10  # 错误答案最大差值

func _ready():
	print("\n========================================")
	print("    糖果商店找零题目生成测试")
	print("========================================\n")
	
	# 测试5道题目
	for i in range(5):
		test_generate_question(i + 1)
		print("")  # 空行分隔

func test_generate_question(question_num: int):
	"""测试生成单个题目"""
	print("【测试题目 %d】" % question_num)
	print("-" * 40)
	
	# 步骤1: 随机生成糖果价格（10~50）
	var candy_price = randi_range(MIN_PRICE, MAX_PRICE)
	print("步骤1 - 糖果价格: %d 元" % candy_price)
	
	# 步骤2: 随机生成支付金额（价格+10 到 100）
	var min_payment = candy_price + MIN_PAY_AMOUNT
	var max_payment = min(MAX_PAY_AMOUNT, 100)
	var payment_amount = randi_range(min_payment, max_payment)
	print("步骤2 - 支付金额: %d 元 (范围:%d~%d)" % [payment_amount, min_payment, max_payment])
	
	# 步骤3: 计算正确找零金额
	var correct_change = payment_amount - candy_price
	print("步骤3 - 正确找零: %d 元 (%d - %d)" % [correct_change, payment_amount, candy_price])
	
	# 步骤4: 生成2个错误答案
	var wrong_answers = generate_wrong_answers(correct_change)
	print("步骤4 - 错误答案: %s" % str(wrong_answers))
	
	# 步骤5: 模拟显示到标签
	print("步骤5 - 显示内容:")
	print("  PriceLabel: \"🍬 糖果价格：%d 元\"" % candy_price)
	print("  PayLabel: \"💰 小勇士支付：%d 元\"" % payment_amount)
	
	# 步骤6: 将答案随机分配到按钮
	var all_options = [correct_change] + wrong_answers
	all_options.shuffle()
	print("步骤6 - 按钮答案分配:")
	for i in range(all_options.size()):
		var is_correct = all_options[i] == correct_change
		print("  AnswerBtn%d: \"找零 %d 元\" %s" % [
			i + 1, 
			all_options[i], 
			"✅ (正确)" if is_correct else "❌ (错误)"
		])
	
	# 验证逻辑
	validate_question(candy_price, payment_amount, correct_change, wrong_answers)

func generate_wrong_answers(correct_answer: int) -> Array:
	"""生成2个错误答案（与正确答案差值1~10）"""
	var wrong_answers = []
	var attempts = 0
	var max_attempts = 20
	
	while wrong_answers.size() < 2 and attempts < max_attempts:
		attempts += 1
		
		# 随机决定是加还是减
		var is_add = randf() > 0.5
		var diff = randi_range(MIN_WRONG_DIFF, MAX_WRONG_DIFF)
		
		var wrong_value: int
		if is_add:
			wrong_value = correct_answer + diff
		else:
			wrong_value = correct_answer - diff
		
		# 确保错误答案合理
		if wrong_value >= 0 and wrong_value != correct_answer and wrong_value not in wrong_answers:
			wrong_answers.append(wrong_value)
	
	# 如果没有生成够2个，强制生成
	while wrong_answers.size() < 2:
		if correct_answer > 5:
			wrong_answers.append(correct_answer - randi_range(1, 5))
		else:
			wrong_answers.append(correct_answer + randi_range(1, 5))
	
	return wrong_answers

func validate_question(price: int, payment: int, correct_change: int, wrong_answers: Array):
	"""验证题目的合理性"""
	print("\n✨ 验证结果:")
	
	# 验证价格范围
	if price >= MIN_PRICE and price <= MAX_PRICE:
		print("  ✅ 价格在合理范围内 (%d~%d)" % [MIN_PRICE, MAX_PRICE])
	else:
		print("  ❌ 价格超出范围！")
	
	# 验证支付金额
	if payment >= price + MIN_PAY_AMOUNT and payment <= MAX_PAY_AMOUNT:
		print("  ✅ 支付金额合理")
	else:
		print("  ❌ 支付金额不合理！")
	
	# 验证找零计算
	if correct_change == payment - price:
		print("  ✅ 找零计算正确")
	else:
		print("  ❌ 找零计算错误！")
	
	# 验证错误答案差值
	var all_valid = true
	for wrong in wrong_answers:
		var diff = abs(wrong - correct_change)
		if diff < MIN_WRONG_DIFF or diff > MAX_WRONG_DIFF:
			all_valid = false
			print("  ❌ 错误答案 %d 的差值 %d 不在范围内！" % [wrong, diff])
	
	if all_valid:
		print("  ✅ 所有错误答案差值在合理范围内 (%d~%d)" % [MIN_WRONG_DIFF, MAX_WRONG_DIFF])
	
	# 验证答案唯一性
	var all_answers = [correct_change] + wrong_answers
	var unique_answers = {}
	for answer in all_answers:
		if unique_answers.has(answer):
			print("  ❌ 发现重复答案: %d" % answer)
		else:
			unique_answers[answer] = true
	
	if unique_answers.size() == 3:
		print("  ✅ 所有答案都是唯一的")