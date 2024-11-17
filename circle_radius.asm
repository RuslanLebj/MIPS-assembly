# Вычислить радиус окружности, описанной около равностороннего треугольника со стороной а;

.data
    prompt_a: .asciiz "a = "
    result_radius: .asciiz "R = "
    newline: .asciiz "\n"
    point: .asciiz "."

.text
.globl main
main:
    	# Ввод стороны треугольника a (целое число)
    li $v0, 4
    la $a0, prompt_a
    syscall
    li $v0, 5
    syscall
    move $t0, $v0      	# Сторона треугольника a в $t0

    	# Вычисляем радиус R = (a * 10 * sqrt(3) * 1000) / 3 * 1000)
    li $t1, 17320	# Множитель
    mul $t2, $t0, $t1  	# t2 = a * 10000 * 1732, (sqrt(3) * 1000 ≈ 1732)
    li $t3, 3000
    div $t2, $t3       	# Делим 
    mflo $t6           	# Радиус R в $t6

    	# Получаем целую и дробную части без дополнительных делений
    li $t4, 10
    div $t6, $t4       	# Делим $t6 на 10
    mflo $t5           	# Целая часть радиуса в $t5
    mfhi $t7           	# Дробная часть радиуса в $t7

    	# Выводим результат
    li $v0, 4
    la $a0, result_radius
    syscall

    li $v0, 1          	# Вывод целой части
    move $a0, $t5
    syscall

    li $v0, 4          	# Вывод точки
    la $a0, point
    syscall

    li $v0, 1          	# Вывод одной цифры после запятой
    move $a0, $t7
    syscall

    	# Переход на новую строку
    li $v0, 4
    la $a0, newline
    syscall

    	# Завершение программы
    li $v0, 10
    syscall
