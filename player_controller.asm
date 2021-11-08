## This file implements the functions that control the player based on the keyboard input

# Include the macros file 
.include "macros.asm"
# Include the constants settings file with the board settings
.include "constants.asm"
# Need to access character structure for the offset definitions in the structure array
.include "player_struct.asm"
.include "arena_struct.asm"
.include "enemy_struct.asm"

# need to access these functions outside of this file
.globl	player_check_collision
.globl	player_update
.globl	player_set_look
.data
	current_frame:		.word	0		# variables used in the frame limitter (we dont want our player to move at 1000 mph)
	last_action_frame:	.word	0
.text

# void player_update(int frame_counter)
#	current_frame = frame_counter
#	if current_frame < last_action_frame+60		return
#	t0 = player_get_element
#	if up_pressed
#		if player_y <=0	|| wall_at(x,y-5) == 1 or 2
#			last_action_frame = current_frame
#			return (exit)
#		else	player_y = player_y - 5
#	if down_pressed
#		if player_y >=50 || wall_at(x,y+5) == 1 or 2
#			last_action_frame = current_frame
#			return (exit)
#		else	player_y = player_y 5 5
#	if left_pressed
#		if player_x <=0	&|| wall_at(x-5,y) == 1 or 2
#			last_action_frame = current_frame
#			return (exit)
#		else	player_x = player_x - 5
#	if right_pressed
#		if player_x >=50 || wall_at(x+5,y) == 1 or 2
#			last_action_frame = current_frame
#			return (exit)
#		else	player_x = player_x + 5
player_update:
	enter
	# frame limiter top
	la	t5,current_frame
	sw	a0,0(t5)		# store frame_counter into current_frame
	lw	t5,current_frame
	lw	t6,last_action_frame
	addi	t6,t6,10			# frame limit
	blt	t5,t6,_exit		# we exit function if less than our frame limit has elapsed
	
	jal	player_get_element
	move	t0,v0				# t0 contains address of player variable array
	# get the state of input keys
	lw	t1,up_pressed
	lw 	t2,down_pressed
	lw	t3,right_pressed
	lw 	t4,left_pressed
	lw	s0,player_moves(t0)

	bnez 	t1,_move_up			# if up arrow is pressed, move up
	bnez 	t2,_move_down			# else if down arrow is pressed, move down
_check_side:
	bnez 	t3,_move_right			# also, if right arrow is pressed, move right
	bnez 	t4,_move_left			# else, if left arrow is pressed, move left.
	j	_exit			
_move_up:
	lw	t2,player_y(t0)			# t2 contains y coordinate of player tile (top left)
	blt	t2,5,_skip_up			# do not update y coordinate if we are at boundary
	# getting wall_at parameters
	move	a1,t2				# a1 contains y coordinate
	dec	a1				# want to check above
	lw	a0,player_x(t0)			# a0 contains x coordinate
	jal	wall_at			
	move 	t7,v0				# v0 contains 0 or 1		
	beq	t7,1,_skip_up			# if there is a wall above the left corner of character, we do not update y coordinate
	beq	t7,2,_skip_up
	inc	s0				# increment the number of moves
	subi	t2,t2,5				# dec y coordinate; moves blit to tile above
_skip_up:
	sw	s0,player_moves(t0)		# store the (possibly) edited number of moves
	sw	t2,player_y(t0)			# store the (possibly) edited y coordinate back to the player var array
	j	_update_frame
	#j	_check_side			# now check if there was movement to the sides during the same frame
_move_down:
	lw	t2,player_y(t0)			# t2 contains y coordinate of player tile (top left)
	li	t5,ARENA_H			# eqv 55
	subi	t5,t5,tile_size			# eqv 5
	beq	t2,t5,_skip_down		# do not update y coordinate if we are at lower boundary
	# getting wall_at parameters
	move 	a1,t2				# a1 contains y coordinate
	addi	a1,a1,tile_size			# want to check below (add 5 to get to the next tile)
	lw	a0,player_x(t0)			# a0<- x coordinate
	jal	wall_at
	move	t7,v0
	bnez	t7,_skip_down			# do not update y coordinate if there is a wall below the lower left corner of player tile
	inc	s0
	addi	t2,t2,5				# inc y coordinate
_skip_down:
	sw	t2,player_y(t0)			# store the (possibly) edited y coordinate back to player var array
	sw	s0,player_moves(t0)		# store the (possibly) edited number of moves
	j	_update_frame
	#j	_check_side			# now check if there was movement to the sides during the same frame
_move_right:
	lw	t2,player_x(t0)			# t2 contains x coordinate of player tile (top left)
	li	t5,ARENA_W			# eqv 55
	subi	t5,t5,tile_size			# eqv 5
	beq	t2,t5,_skip_right		# do not upate x coordinate if we are at right boundary of arena
	# getting wall_at parameters
	move	a0,t2				# a0<- x coordinate
	addi	a0,a0,tile_size			# add 5 to x coord to check next tile to the right
	lw	a1,player_y(t0)			# a1<- y coordinate
	jal	wall_at			
	move	t7,v0	
	bnez	t7,_skip_right			# we do not update x coordinate if there is a wall to the right of upper right pixel
	inc	s0
	addi	t2,t2,5				# inc x coordinate 
_skip_right:
	sw	t2,player_x(t0)			# store the (possibly) update x coordinate back to player var array
	sw	s0,player_moves(t0)		# store the (possibly) edited number of moves
	j	_update_frame				# we skip checking for left movements if we right move
_move_left:
	lw	t2,player_x(t0)			# t2 contains x coordinate of player tile (top left)
	blez	t2,_skip_left			# do not update x coordinate if we are at left-most boundary of arena
	# args for wall_at function
	move	a0,t2				# a0 <- x coordinate
	dec	a0				# need to check location to the left
	lw	a1,player_y(t0)			# get y coordinate
	jal	wall_at				
	move	t7,v0				# v0 contains 0,1,or 2
	bnez	t7,_skip_left			# do not dec x coord if there is a wall at loc
	inc	s0				# incremenet the number of moves
	subi	t2,t2,5				# else dec x coordinate
_skip_left:
	sw	s0,player_moves(t0)		# store the (possibly) edited number of moves
	sw	t2,player_x(t0)			# store the (possibly) edited x coordinate back to player var array
_update_frame:

	#frame limiter bot
	la t2, last_action_frame
	lw t0,current_frame
	sw t0,0(t2)
_exit:
	leave

# returns 1 if the player is at the same (x,y) location as any enemy. Returns 0 otherwise
# args: void	return: v0<- 1 or 0
# void player_check_collision
#	t0 = player_get_element
#	t1 = %(t0 + player_x)
#	t2 = %(t0 + player_y)
#	for i = 0 to 3
#		t3 = enemy_get_element[i]
#		t4 = %(t3 + enemy_x)
#		t5 = %(t3 + enemy_y)
#		if t1==t4 = t2 == t5
#			return 1
#	return 0
player_check_collision:
	enter
	# Lose if player and enemy are in the same tile.
	jal	player_get_element
	move	t0,v0						# t0 contains memory address of player
	lw	s1,player_x(t0)					# player x
	lw	s2,player_y(t0)					# player y
	
	li	s0,0						# counter
_loop_top:	
	move	a0,s0						# index of enemy
	bge	s0,3,_loop_bot					# exit if we have compared player x and y to all enemies' x and y coords
	jal	enemy_get_element
	move	t0,v0
	lw	s3,enemy_x(t0)					# enemy x
	lw	s4,enemy_y(t0)					# enemy y
	bne	s1,s3,_skip					# we have not lost game if player x != enemy x
	bne	s2,s4,_skip						# or 	   	   player y != enemy y
	li	v0,1						# we lose the game, return 1
	leave							# and we exit
_skip:							# current enemy did not match, increment index, and loop
	inc	s0
	j	_loop_top
_loop_bot:
	# if we exit this way, it means player (x,y) did not match with any enemy (x,y)
	li	v0,0						# return 0
	leave
	
# ----------------------------------------------------------------------------------------------------------------------------------------
# the following functions were not implemented and not used
# ----------------------------------------------------------------------------------------------------------------------------------------

# args: a0<- index of character pattern
player_set_look:
	enter
	jal	player_get_element
	move	t0,v0
	beq	a0,0,_case_0
	beq	a0,1,_case_1
	beq	a0,2,_case_2
	beq	a0,3,_case_3
_exit:
	leave
_case_0:
	la	t1,master_chief_pattern
	sw	t1,player_look(t0)
	leave
_case_1:
	la	t1,pacman_pattern
	sw	t1,player_look(t0)
	leave
_case_2:
	la	t1,kirby_pattern
	sw	t1,player_look(t0)
	leave
_case_3:
	leave
