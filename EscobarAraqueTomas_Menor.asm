    .data
        prompt_num:       .asciiz "¿Cuántos números desea comparar? (mínimo 3, máximo 5): "
        prompt_input:     .asciiz "Ingrese un número: "
        result_msg:       .asciiz "El número menor es: "
        error_msg:        .asciiz "Debe ingresar entre 3 y 5 números.\n"
        newline:          .asciiz "\n"
        numbers:          .word 0, 0, 0, 0, 0  # Espacio para máximo 5 números

    .text
    .globl main

main:
    # Pedir al usuario cuántos números desea comparar
    li $v0, 4                  # syscall para imprimir string
    la $a0, prompt_num
    syscall

    li $v0, 5                  # syscall para leer entero
    syscall
    move $t0, $v0              # Guardar la cantidad de números en $t0

    # Verificar que el número ingresado esté entre 3 y 5
    li $t1, 3
    blt $t0, $t1, error        # Si el número es menor a 3, error
    li $t1, 5
    bgt $t0, $t1, error        # Si el número es mayor a 5, error

    # Ingresar los números
    li $t2, 0                  # Inicializar el contador de números ingresados
input_loop:
    beq $t2, $t0, find_min     # Si ya ingresamos todos los números, ir a buscar el menor

    # Pedir el siguiente número
    li $v0, 4                  # syscall para imprimir string
    la $a0, prompt_input
    syscall

    li $v0, 5                  # syscall para leer número entero
    syscall
    sll $t3, $t2, 2            # Calcular el offset (tamaño palabra es 4 bytes, por eso sll 2 bits)
    sw $v0, numbers($t3)       # Guardar el número ingresado en el array `numbers`

    addi $t2, $t2, 1           # Incrementar el contador
    j input_loop               # Repetir el ciclo

# Encontrar el número menor
find_min:
    lw $t3, numbers            # Cargar el primer número en $t3 (asumido como el menor)
    li $t2, 1                  # Inicializar índice en 1 (empezamos desde el segundo número)

min_loop:
    beq $t2, $t0, print_result # Si ya revisamos todos los números, ir a imprimir el menor

    sll $t4, $t2, 2            # Calcular el offset del siguiente número
    lw $t5, numbers($t4)       # Cargar el siguiente número

    bge $t3, $t5, update_min   # Si el número actual es menor que el guardado, actualizar el mínimo
    j next_num

update_min:
    move $t3, $t5              # Actualizar el valor mínimo a $t3

next_num:
    addi $t2, $t2, 1           # Incrementar el índice
    j min_loop                 # Repetir el ciclo

# Imprimir el resultado
print_result:
    li $v0, 4                  # syscall para imprimir string
    la $a0, result_msg
    syscall

    move $a0, $t3              # Pasar el valor mínimo encontrado
    li $v0, 1                  # syscall para imprimir entero
    syscall

    # Imprimir un salto de línea
    li $v0, 4
    la $a0, newline
    syscall

    j exit

# Manejo de errores
error:
    li $v0, 4                  # syscall para imprimir string
    la $a0, error_msg
    syscall
    j exit

# Finalizar el programa
exit:
    li $v0, 10                 # syscall para salir
    syscall
