# -----------------------------------------------------------------------------
# Реализация функции F в зависимости от заданных условий:
#
# 1. Если c < 0 и b ≠ 0:
#    F = a * x^2 + b^2 * x
#
# 2. Если c > 0 и b = 0:
#    F = (x + a) / (x + c)
#
# 3. Во всех остальных случаях:
#    F = x / c
#
# Необходимо обработать возможные ошибки:
# - Деление на 0 (если c = 0 при вычислении F = x / c или F = (x + a) / (x + c)).
# - Если недопустимые условия, выводится сообщение об ошибке.
#
# Для каждой ветви задачи написана отдельная функция:
# - calc_case1: Вычисляет F = a * x^2 + b^2 * x
# - calc_case2: Вычисляет F = (x + a) / (x + c)
# - calc_case3: Вычисляет F = x / c
#
# Условие задачи проверяется при помощи сравнений и ветвлений:
# - Проверка c < 0, c > 0, c == 0, b == 0.
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
    
    # Проверяем условия
    c.eq.d $f6, $f30  # Если c == 0
    bc1t case_c_zero  # Переход для c == 0

    c.lt.d $f6, $f30  # Если c < 0
    bc1t case_c_lt_zero

    # Если c > 0
    j case_c_gt_zero

case_c_zero:
    j error           # Вывод сообщения об ошибке (c == 0)

case_c_lt_zero:
    c.eq.d $f4, $f30  # Проверяем b == 0
    bc1t error        # Ошибка, если b == 0
    
    jal calc_case1    # Вызов: F = a * x^2 + b^2 * x
    j print_result

case_c_gt_zero:
    c.eq.d $f4, $f30  # Проверяем b == 0
    bc1f error        # Ошибка, если b != 0
    
    jal calc_case2    # Вызов: F = (x + a) / (x + c)
    j print_result

case_other:
    jal calc_case3    # Вызов: F = x / c
    j print_result

# Вычисление: F = ax^2 + b^2x
calc_case1:
    mul.d $f10, $f8, $f8  # x^2
    mul.d $f12, $f10, $f2 # a * x^2
    mul.d $f14, $f4, $f4  # b^2
    mul.d $f14, $f14, $f8 # b^2 * x
    add.d $f12, $f12, $f14 # F = a * x^2 + b^2 * x
    jr $ra

# Вычисление: F = (x + a) / (x + c)
calc_case2:
    add.d $f10, $f8, $f6  # x + c
    c.eq.d $f10, $f30     # Проверяем, x + c == 0
    bc1t error            # Если x + c == 0, переходим к обработке ошибки

    add.d $f12, $f8, $f2  # x + a
    div.d $f12, $f12, $f10 # F = (x + a) / (x + c)
    jr $ra

# Вычисление: F = x / c
calc_case3:
    div.d $f12, $f8, $f6  # F = x / c
    jr $ra

# Печать результата
print_result:
    li $v0, 4
    la $a0, result
    syscall
    
    li $v0, 3          # Печать числа с плавающей точкой
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

# Выход из программы
exit:
    li $v0, 10          # Завершение программы
    syscall
