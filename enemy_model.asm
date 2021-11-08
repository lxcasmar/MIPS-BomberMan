# need to include offset definitions for enemy array
.include "enemy_struct.asm"
.include "macros.asm"
.data
	array_of_enemy_struct:	.word	0,0,0,1,0,0,0,1,0,0,0,1	# 3 enemies * 4 words  = 12
	# in this case we intialize the 4th word of every enemy to 1, this is their status; alive (1) or daed (0)
.text

.globl	enemy_compare_coords
.globl	enemy_get_element
.globl	enemy_get_coordinates
.globl	enemy_all_dead


# args: a0<- index of enemy 
# address enemy_get_element(index)
#	t0 = &array_of_enemy_struct
#	return t0 + index*12
enemy_get_element:
	enter	
	la	t0,array_of_enemy_struct		# get address of the beginning of the array
	mul	t1,a0,enemy_size			# multiply index by 16 (size of enemy struct) to get offset
	add	v0,t0,t1				# add offset to beginning of array
	# v0 contains address of enemy a0 
	leave
#
# args: a0<- index of enemy 	return: v0<- x coordinate v1<- y coordinate
enemy_get_coordinates:
	enter
	jal	enemy_get_element
	move	t0,v0
	lw	v0,enemy_x(t0)
	lw	v1,enemy_y(t0)
	leave

# compares a given set of coordinates to the coordinates of all enemies, if they match to any, it returns the index. Otherwise, return -1
# args: a0<- x coordinate a1<- y coordinate
enemy_compare_coords:
	enter	t2,t3,a0,a1,t1
							# will return -1 if no match
	move	t2,a0					# t2 contains x coordinate to compare
	move	t3,a1					# t3 contains y coordinate to compare
	li	s0,0					# index counter
_loop_top:
	bge	s0,3,_exit
	move	a0,s0
	jal	enemy_get_coordinates
	move	t0,v0					# t0 contains x coordinate of ith enemy
	move	t1,v1					# t1 contains y coordinate of ith enemy
	
	bne	t0,t2,_skip				# we have not found a match if x coords dont match
	bne	t1,t3,_skip				# or if y coords dont match, so we do not save index
	move	v0,s0					# we save index if match
	leave	t2,t3,a0,a1,t1					# we exit function if we have matched a coordinate pair
_skip:
	inc	s0					# else, we increment index, and check again
	j	_loop_top
_exit:
	li	v0,-1					# if we exit this way, it means we did not match
	leave	t2,t3,a0,a1,t1

# returns 1 if all enemies are dead (status of 0), returns zero if at least one enemy is alive
# void enemy_all_dead()
#	for i in enemy_array
#		if enemy_status == 1
#			return 0
#		else
#			return 1
enemy_all_dead:
	enter
	li	a0,0					# index of enemy
	jal	enemy_get_element
	move	t0,v0					# t0 has memory address of enemy
	lw	t0,enemy_status(t0)			# if staus is not zero, we exit
	bnez	t0,_skip
	
	li	a0,1					# index of enemy
	jal	enemy_get_element			
	move	t0,v0					# t0 has ememory address of enemy
	lw	t0,enemy_status(t0)	
	bnez	t0,_skip				# if status is not zero, we exit
	
	li	a0,2					# index of enemy
	jal	enemy_get_element
	move	t0,v0					# t0 has ememory address of enemy
	lw	t0,enemy_status(t0)
	bnez	t0,_skip				# if status is not zero, we exit
	li	v0,1					# otherwise, all enemies are dead, we return one and exit
	leave
_skip:
	li	v0,0
	leave
