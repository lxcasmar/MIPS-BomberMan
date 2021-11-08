## This file implements the functions that control the enemy. Implemented by 

# Include the macros file 
.include "macros.asm"
# Include the constants settings file with the board settings
.include "constants.asm"
# Need to access character structure for the offset definitions in the structure array
.include "enemy_struct.asm"
.include "arena_struct.asm"

.globl	enemy_update
.globl	enemy_dead
.data
	current_frame:		.word	0
	last_action_frame:	.word	0
.text

# void enemy_update(frame currentFrame)
#	every 25 frames
#		get random int from 0 t0 3 (inclusive)
#		call function below for different enemies in array for each case
enemy_update:
	enter
	# frame limiter top
	la	t0,current_frame
	sw	a0,0(t0)		# store frame_counter into current_frame
	lw	t0,current_frame
	lw	t1,last_action_frame
	addi	t1,t1,25			# frame limit
	blt	t0,t1,_exit		# we exit function if less than our frame limit has elapsed
	
	li	a1,4
	syscall_rand_range			# defined in macros.asm			
	move	t0,v0				# t0 contains rand int [0,3]
	beq	t0,0,_case_0			# if 0
	beq	t0,1,_case_1			# if 1
	beq	t0,2,_case_2			# if 2
	beq	t0,3,_case_3			# if 3
	
	
_update_frame_timer:
	#frame limiter bot
	la t2, last_action_frame
	lw t0,current_frame
	sw t0,0(t2)
	
_exit:
	leave
#our 4 cases for random int. Each enemy behaves differently depending on random int (would need a lot of cases to cover every possible combination)
_case_0:
	li	a0,0			# for the 0th enemy, move up
	jal	enemy_update_up
	li	a0,1			# for the 1st enemy, move down
	jal	enemy_update_down
	li	a0,2			# for the second enemy, move right
	jal	enemy_update_right
	j	_update_frame_timer
_case_1:
	li	a0,0			# for the 0th enemy, move down
	jal	enemy_update_down
	li	a0,1			# for the 1st enemy, move left
	jal	enemy_update_left
	li	a0,2			# for the 2nd enemy, move up
	jal	enemy_update_up
	j	_update_frame_timer
_case_2:
	li	a0,0			# for the 0th enemy, move left
	jal	enemy_update_left
	li	a0,1			# for the 1st enemy, move right
	jal	enemy_update_right		
	li	a0,2			# for the 2nd enemy, move down
	jal	enemy_update_down
	j	_update_frame_timer
_case_3:	
	li	a0,0			# for the 0th enemy, move right
	jal	enemy_update_right
	li	a0,1			# for the 1st enemy, move up
	jal	enemy_update_up		
	li	a0,2			# for the 2nd enemy, move left
	jal	enemy_update_left
	j	_update_frame_timer
	
# void enemy_update_left(index)
# args: a0<- index of enemy to move	
# void enemy_update_left
#	if satus == 1 && no wall to left && not at boundary of arena
#		enemy x = enemy x -5
enemy_update_left:
	enter
	jal	enemy_get_element
	move	t0,v0						# t0 contains memory address of ith enemy
	lw	t4,enemy_status(t0)				# t4 contains dead or alive status of enemy
	bnez	t4,_skip_dead					# we only do the following if our enemy is not dead
	# arg for enemy_dead
	move	a0,t0						# a0 has memory address of ith enemy
	jal	enemy_dead
	j	_exit					
_skip_dead:
	lw	t2,enemy_x(t0)					# gets x coordinate
	blez	t2,_skip_left					# we do not update x coordinate if we are at left boundary of arena
	# get args for wall_at function
	move	a0,t2
	dec	a0						# need to check tile to the left
	lw	a1,enemy_y(t0)
	jal	wall_at
	move	t7,v0						# t7 contains 0,1, or 2
	bnez	t7,_skip_left					# we do not update x coordinate if there is a block to the left
	
	subi	t2,t2,5							# else update x coordinate
_skip_left:
	sw	t2,enemy_x(t0)						# store x coordinate back into memory
_exit:
	leave
	
# void enemy_update_right(index)
# args: a0<- index of enemy to move	
# void enemy_update_left
#	if satus == 1 && no wall to right && not at boundary of arena
#		enemy x = enemy x +5
enemy_update_right:
	enter
	jal	enemy_get_element
	move	t0,v0						# t0 conains memory address of ith enemy
	lw	t4,enemy_status(t0)				# t4 contains dead or alive status of enemy
	bnez	t4,_skip_dead					# we only do the following if our enemy is not dead
	# arg for enemy_dead
	move	a0,t0						# a0 has memory address of ith enemy
	jal	enemy_dead
	j	_exit						# we want to exit after keeping our enemy dead
_skip_dead:							# if enemy is alive
	lw	t2,enemy_x(t0)					# gets x coordinate
	li	t3,ARENA_W					# eqv 55
	subi	t3,t3,tile_size
	beq	t2,t3,_skip_right				# Do not update x coordinate if we are at boundary
	# get args for wall_at function
	move	a0,t2					# a0<- x coordinate
	addi	a0,a0,tile_size				# add 5 to x coord to check next tile to the right
	lw	a1,enemy_y(t0)				# a1<- y coordinate
	jal	wall_at				
	move	t7,v0	
	bnez	t7,_skip_right				# we do not update x coordinate if there is a wall to the right of enemy tile
	addi	t2,t2,5						# get x coordinate of tile to the right
_skip_right:
	sw	t2,enemy_x(t0)						# else update x coordinate
_exit:
	leave

# void enemy_update_down(index)
# args: a0<- index of enemy to move
# void enemy_update_down
#	if satus == 1 && no wall underneath && not at boundary of arena
#		enemy y = enemy y +5
enemy_update_down:
	enter
	jal	enemy_get_element
	move	t0,v0						# t0 contains memory address of ith enemy
	lw	t4,enemy_status(t0)				# t4 contains dead or alive status of enemy
	bnez	t4,_skip_dead					# we only do the following if our enemy is not dead
	# arg for enemy_dead
	move	a0,t0						# a0 has memory address of ith enemy
	jal	enemy_dead
	j	_exit						# exit after keeping our enemy dead
_skip_dead:							# if enemy is alive
	lw	t2,enemy_y(t0)					
	li	t3,ARENA_H					# eqv 55
	subi	t3,t3,tile_size
	beq	t2,t3,_skip_down				# we do not update y coordinate if we are at lower boundary
	# get wall_at function parameters
	move	a1,t2
	addi	a1,a1,tile_size					# a1 contains y coordinate under enemy tile
	lw	a0,enemy_x(t0)					# a0 contains x coordinate
	jal	wall_at			
	move	t7,v0						# t7 contains 0,1, or 2
	bnez	t7,_skip_down					# if there is a wall under enemy tile, we do not update y coordinate
	addi	t2,t2,5							# else we update y coordinate
_skip_down:
	sw	t2,enemy_y(t0)						# we store y coordinate
_exit:
	leave
	
# void enemy_update_up(index)
# args: a0<- index of enemy to move
# void enemy_update_up
#	if satus == 1 && no wall above && not at boundary of arena
#		enemy y = enemy y - 5
enemy_update_up:
	enter
	jal	enemy_get_element
	move	t0,v0						# t0 contains memory address of the ith enemy
	lw	t4,enemy_status(t0)				# t4 contains dead or alive status of enemy
	bnez	t4,_skip_dead					# we only do the following if our enemy is not dead
	# arg for enemy_dead
	move	a0,t0						# a0 has memory address of ith enemy
	jal	enemy_dead
	j	_exit						# exit after keeping our enemy dead
_skip_dead:							# if enemy is alive
	lw	t2,enemy_y(t0)					# gets y coordinate
	blt	t2,5,_skip_up					# if our y coordinate is < 5 (0), we do not update y coordinate
	# get wall_at function parameters
	move	a1,t2
	subi	a1,a1,tile_size					# a1 contains y coordinate of tile above eney tile
	lw	a0,enemy_x(t0)					# a0 contains x coordinate of enemy tile
	jal	wall_at	
	move	t7,v0						# t7 contains 0,1, or 2
	bnez	t7,_skip_up					# we do not update y coordinate if there is a wall above enemy tile
	subi	t2,t2,5							# else update y coorindate
_skip_up:
	sw	t2,enemy_y(t0)						# and store back into memory
_exit:
	leave


# kills an enemy by resetting its d/a status and setting its coordinates out of arena 
# args: a0<- memory address of the enemy to delete
# void enemy_dead(address)
#	%(enemy[i]_status) = 0
enemy_dead:
	enter	a0,a1,t0,t1
	
	sw	zero,enemy_status(a0)
	li	t0,60
	li	t1,60
	sw	t0,enemy_x(a0)
	sw	t1,enemy_y(a0)
	leave	a0,a1,t0,t1
