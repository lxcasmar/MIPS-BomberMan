# need to include offset definitions for bomb array
.include "bomb_struct.asm"
.data
	array_of_bomb_struct:	.word	0:4	# 1 bomb * 4 words  = 4
.text

# Need to call this function outside of this file
.globl	bomb_get_element
# args: void (only one bomb at a time in this implementation)
# address enemy_get_element()
#	return &array_of_bomb_struct
bomb_get_element:
	la	v0,array_of_bomb_struct
	jr 	ra
