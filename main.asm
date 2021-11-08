.include "macros.asm"
# we access offset definitions to establish initial positions of enemy
.include "enemy_struct.asm"
.text
.globl main

# void main()
#	t0 = player_get_element
#	%(t0+player_x) = 50
#	%(t0+player_y) = 0
#		
#	t1 = enemy_get_element[1]
#	%(t1+enemy_x) = 0
#	%(t1+enemy_y) = 0
#
#	t1 = enemy_get_element[2]
#	%(t1+enemy_x) = 30
#	%(t1+enemy_y) = 30
#
#	t1 = enemy_get_element[0]
#	%(t1+enemy_x) = 50
#	%(t1+enemy_y) = 40
#	
#	game()
#	exit
main:
	jal	player_get_element		# Determine player initial position
	move	t0,v0
	li	a1,0
	li	a0,50
	sw	a0,0(t0)
	sw	a1,4(t0)
	
	li	a0,1				# initial position for enemy 1
	jal	enemy_get_element
	move	t0,v0
	li	a0,0
	li	a1,0
	sw	a0,enemy_x(t0)
	sw	a1,enemy_y(t0)
	
	li	a0,2				# initial position for enemy 2
	jal	enemy_get_element
	move	t0,v0
	li	a0,30
	li	a1,30
	sw	a0,enemy_x(t0)
	sw	a1,enemy_y(t0)
	
	li	a0,0				# initial position for enemy 0
	jal	enemy_get_element
	move	t0,v0
	li	a0,50
	li	a1,40
	sw	a0,enemy_x(t0)
	sw	a1,enemy_y(t0)

	jal	game
	

	li	v0, 10
	syscall
