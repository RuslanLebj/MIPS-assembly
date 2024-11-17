# -----------------------------------------------------------------------------
# Реализация функции F в зависимости от заданных условий:
#
# 1. Если x < 0.6 и b + c ≠ 0:
#    F = a * x^3 + b^2 + c
#
# 2. Если x > 0.6 и b + c = 0:
#    F = (x - a) / (x - c)
#
# 3. Во всех остальных случаях:
#    F = x / c + x / a
#
# Необходимо обработать возможные ошибки:
# - Деление на 0 (если c = 0 или a = 0 при вычислении F = x / c + x / a, или если 
#   x - c = 0 при вычислении F = (x - a) / (x - c)).
# - Если недопустимые условия, выводится сообщение об ошибке.
#
# Для каждой ветви задачи написана отдельная функция:
# - calc_case1: Вычисляет F = a * x^3 + b^2 + c
# - calc_case2: Вычисляет F = (x - a) / (x - c)
# - calc_case3: Вычисляет F = x / c + x / a
#
# Условие задачи проверяется при помощи сравнений и ветвлений:
# - Проверка x < 0.6, x > 0.6, b + c == 0, c == 0, a == 0, x - c == 0.
#
# Программа запрашивает входные значения (a, b, c, x), вычисляет F в зависимости
# от условий, выводит результат или сообщение об ошибке.
# -----------------------------------------------------------------------------


.data
prompt_a: .asciiz "Enter a = "
prompt_b: .asciiz "Enter b = "
prompt_c: .asciiz "Enter c = "
prompt_x: .asciiz "Enter x = "
result: .asciiz "F(x) = "
err_msg: .asciiz "Error: division by zero!"
newline: .asciiz "\n"
const_0_6: .double 0.6  # Константа 0.6

.text
.globl main

main:
    # Ввод a
    li $v0, 4
    la $a0, prompt_a
    syscall
    li $v0, 7
    syscall
    mov.d $f2, $f0   # Сохраняем a в $f2
    
    # Ввод b
    li $v0, 4
    la $a0, prompt_b
    syscall
    li $v0, 7
    syscall
    mov.d $f4, $f0   # Сохраняем b в $f4
    
    # Ввод c
    li $v0, 4
    la $a0, prompt_c
    syscall
    li $v0, 7
    syscall
    mov.d $f6, $f0   # Сохраняем c в $f6
    
    # Ввод x
    li $v0, 4
    la $a0, prompt_x
    syscall
    li $v0, 7
    syscall
    mov.d $f8, $f0   # Сохраняем x в $f8
    
    # Проверка условий
    l.d $f10, const_0_6  # Загружаем 0.6 в $f10
    c.lt.d $f8, $f10     # Если x < 0.6
    bc1t case_x_lt_0_6   # Переход в ветку x < 0.6

    # Проверяем x > 0.6
    c.le.d $f10, $f8     # Если x >= 0.6
    bc1t case_x_gt_0_6

    # Остальные случаи
    j case_other

# Ветка 1: x < 0.6 и b + c != 0
case_x_lt_0_6:
    add.d $f10, $f4, $f6  # b + c
    c.eq.d $f10, $f30     # b + c == 0?
    bc1t error            # Если b + c == 0, ошибка
    
    jal calc_case1        # Вызываем расчет F = ax^3 + b^2 + c
    j print_result

# Ветка 2: x > 0.6 и b + c == 0
case_x_gt_0_6:
    add.d $f10, $f4, $f6  # b + c
    c.eq.d $f10, $f30     # b + c == 0?
    bc1f case_other        # Если b + c != 0, переходим в "остальные случаи"
    
    jal calc_case2        # Вызываем расчет F = (x - a) / (x - c)
    j print_result

# Ветка 3: Остальные случаи
case_other:
    c.eq.d $f6, $f30      # Проверяем c == 0
    bc1t error            # Ошибка, если c == 0
    c.eq.d $f2, $f30      # Проверяем a == 0
    bc1t error            # Ошибка, если a == 0
    
    jal calc_case3        # Вызываем расчет F = x / c + x / a
    j print_result

# Реализация calc_case1: F = ax^3 + b^2 + c
calc_case1:
    mul.d $f10, $f8, $f8  # x^2
    mul.d $f10, $f10, $f8 # x^3
    mul.d $f12, $f10, $f2 # ax^3
    mul.d $f14, $f4, $f4  # b^2
    add.d $f12, $f12, $f14 # ax^3 + b^2
    add.d $f12, $f12, $f6  # F = ax^3 + b^2 + c
    jr $ra

# Реализация calc_case2: F = (x - a) / (x - c)
calc_case2:
    sub.d $f10, $f8, $f2  # x - a
    sub.d $f12, $f8, $f6  # x - c
    c.eq.d $f12, $f30     # Проверяем (x - c) == 0
    bc1t error            # Ошибка, если (x - c) == 0
    div.d $f12, $f10, $f12 # F = (x - a) / (x - c)
    jr $ra

# Реализация calc_case3: F = x / c + x / a
calc_case3:
    div.d $f10, $f8, $f6  # x / c
    div.d $f12, $f8, $f2  # x / a
    add.d $f12, $f10, $f12 # F = x / c + x / a
    jr $ra

# Печать результата
print_result:
    li $v0, 4
    la $a0, result
    syscall
    li $v0, 3
    mov.d $f0, $f12
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    j exit

# Обработка ошибок
error:
    li $v0, 4
    la $a0, err_msg
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    j exit

# Выход
exit:
    li $v0, 10
    syscall
