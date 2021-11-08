.include "macros.asm"
.include "constants.asm"
.include "bomb_struct.asm"
.include "arena_struct.asm"

# need the functions to be visible everywhere
.globl bomb_draw
.globl	explode_down
.globl explode_up
.globl	explode_left
.globl	explode_right
.data
	bomb_down:	.word	0			#  each is a timer for the explosion in the corresponding direction
	bomb_up:	.word	0
	bomb_left:	.word	0
	bomb_right:	.word	0

.text	
# void bomb_draw()
# 	if bomb is active
#		draw bomb
bomb_draw:
	enter	
	jal	bomb_get_element
	move	t0,v0				# t0 contains memory address of bomb struct array
	lw	t1,bomb_status(t0)
	beq	t1,zero,_exit			# we do not draw the bomb if it is not active
	lw	a0,bomb_x(t0)			# gets x coordinate of bomb
	lw	a1,bomb_y(t0)			# gets y coordinate of bomb
	la	a2,bomb_pattern			# loads bomb bit pattern
	jal	display_blit_5x5_trans		# draws bomb
_exit:	
	leave

# void explode_up()
#	if ( ! wall above && ! at boundary)
#		draw block above for 60 frames
#		check if block is in contact with enemy
#		check if block is in contact with player
#		if block is destructible, break it
#	after 20 frames
#		if ( ! wall above && ! at boundary)
#			draw block 2nd above for 40 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#		if block is destructible, break it
#	after 40 frames
#		if ( ! wall above && ! at boundary)
#			draw block 2nd above for 20 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#		if block is destructible, break it
explode_up:
	enter
	move	s6,a0
	jal	bomb_get_element
	move	t0,v0
	#frame counter for upward explosion
	lw	t2,bomb_up
	bgt	t2,60,_special_exit_up			# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	la	a2,bomb_pattern
	jal	display_blit_5x5_trans			# draws block where the bomb used to be
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_zero
	jal	player_kill
_check_enemy_zero:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_zero				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_zero:	
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	subi	a1,a1,5					# need to get tile above bomb placement
	jal	wall_at
	beq	v0,1,_special_exit_up			# there is an indestructible block under bomb
	beq	v0,2,_exit_with_delete_up_first		# there is a destructible block under bomb
	
	blt	a1,0,_special_exit_up			# we do not draw block if coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw first block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy
	jal	player_kill
_check_enemy:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip:	
	lw	t2,bomb_up
	blt	t2,20,_update_timer_up			# if we havent reached 20 frames (1/3 of total frames), we do not draw
	bgt	t2,60,_special_exit_up			# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0	
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	subi	a1,a1,10				# need to get 2nd block above bomb placement
	jal	wall_at					# check if there is a wall 2 tiles above the bomb
	beq	v0,1,_special_exit_up			# there is an indestructible block 2 tiles above bomb
	beq	v0,2,_exit_with_delete_up_second		# there is a destructible block 2 blocks above the bomb placement

	blt	a1,0,_special_exit_up		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw second block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_second
	jal	player_kill
_check_enemy_second:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_second				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_second:	
	
	lw	t2,bomb_up
	blt	t2,40,_update_timer_up			# if we havent reached 40 frames (2/3 of total frames), we do not draw
	bgt	t2,60,_special_exit_up			# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0	
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	subi	a1,a1,15				# need to get 2nd block above bomb placement
	jal	wall_at					# check if there is a wall 2 tiles above the bomb
	beq	v0,1,_special_exit_up			# there is an indestructible block 2 tiles above bomb
	beq	v0,2,_exit_with_delete_up_third		# there is a destructible block 2 blocks above the bomb placement

	blt	a1,0,_special_exit_up		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw third block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_third
	jal	player_kill
_check_enemy_third:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_third				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_third:	
_update_timer_up:
	lw	t2,bomb_up				
	inc	t2					# we increment the frame timer for explosion
	sw	t2,bomb_up				# store back into memory
	leave						# regular exit, a condition to draw a block failed (did not meet frame requirements)
_special_exit_up:
# We leave the function, at this point, we have traversed the duration of the explosion (60 frames).
	sw	zero,bomb_up				# reset frame counter for explosion (for next bomb)
	sw	zero,exploding_up			# we reset the status of bomb_update function in bomb_controller.asm
	leave
_exit_with_delete_up_first:
# CASE: we want to exit function, but also delete the tile above the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at				# block above bomb placement is deleted
	j	_special_exit_up			# now we can exit function
_exit_with_delete_up_second:
	jal	delete_wall_at
	j	_special_exit_up
_exit_with_delete_up_third:
	jal	delete_wall_at
	j	_special_exit_up

# void explode_down()
#	if (! de wall below && ! at boundary)
#		draw block below for 60 frames
#		check if block is in contact with enemy
#		check if block is in contact with player
#		if block is destructible, break it
#	after 20 frames
#		if ( ! wall below && ! at boundary)
#			draw block 2nd below for 40 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it
#	after 40 frames
#		if ( ! wall above && ! at boundary)
#			draw block 3rd below for 20 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it		
explode_down:
	enter
	move	s6,a0				# s0 has number of frames
	jal	bomb_get_element
	move	t0,v0				# t0 contains address of bomb struct array
	# frame counter for donward explosion
	lw	t2,bomb_down
	bgt	t2,s6,_special_exit_down		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	la	a2,bomb_pattern
	jal	display_blit_5x5_trans			# draws block where the bomb used to be
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_zero
	jal	player_kill
_check_enemy_zero:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_zero				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_zero:	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	addi	a1,a1,5					# need to check tile under bomb placement
	jal	wall_at					# determines if there is a wall underneath, and which type
	beq	v0,1,_special_exit_down			# there is an indestructible block under bomb
	beq	v0,2,_exit_with_delete_down_first	# there is a destructible block under bomb
	
	bge	a1,ARENA_H,_special_exit_down		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern	
	jal	display_blit_5x5_trans			# draw first block
		# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy
	jal	player_kill
_check_enemy:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip:	
	lw	t2,bomb_down
	blt	t2,20,_update_timer_down			# if we havent reached 20 frames (1/3 of total frames), we do not draw
	bgt	t2,60,_special_exit_down		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0	
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	addi	a1,a1,10				# need to get 2nd block under bomb placement
	jal	wall_at					# check if there is a wall 2 tiles under the bomb
	beq	v0,1,_special_exit_down			# there is an indestructible block 2 tiles under bomb
	beq	v0,2,_exit_with_delete_down_second		# there is a destructible block 2 blocks under the bomb placement

	bge	a1,ARENA_H,_special_exit_down		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw second block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_second
	jal	player_kill
_check_enemy_second:	
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_second				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_second:	
	lw	t2,bomb_down
	blt	t2,40,_update_timer_down			# If we haven't reached 40 frames (2/3 of the total frames), we do not draw
	bgt	t2,60,_special_exit_down		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	addi	a1,a1,15				# need to get 3rd block under bomb placement
	jal	wall_at					# check if there is a wall 3 tiles under the bomb
	beq	v0,1,_special_exit_down			# there is an indestructible block 3 tiles under bomb
	beq	v0,2,_exit_with_delete_down_third		# there is a destructible block 3 blocks under the bomb placement
	
	bge	a1,ARENA_H,_special_exit_down		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw the third block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_third
	jal	player_kill
_check_enemy_third:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_third				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_third:	
_update_timer_down:			
	lw	t2,bomb_down				
	inc	t2					# we increment the frame timer for explosion
	sw	t2,bomb_down				# store back into memory
	leave						# regular exit, a condition to draw a block failed (did not meet frame requirements)
_special_exit_down:
# We leave the function, at this point, we have traversed the duration of the explosion (60 frames).
	sw	zero,exploding_down				# we reset the status of bomb_update function in bomb_controller.asm
	sw	zero,bomb_down				# reset frame counter for explosion (for next bomb)
	leave
_exit_with_delete_down_first:
# CASE: we want to exit function, but also delete the tile under the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at				# block under bomb placement is deleted
	j	_special_exit_down
_exit_with_delete_down_second:
# CASE: we want to exit functon, but also delete the 2nd tile under the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at				# 2nd block under bomb placement is deleted
	j	_special_exit_down			# we exit function
_exit_with_delete_down_third:
# CASE: we want to exit function, but also delete the 3rd tile under the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at				# 3rd block under bomb placement is deleted
	j	_special_exit_down			# we exit

# void explode_left()
#	if ( ! wall left && ! at boundary)
#		draw block above for 60 frames
#		check if block is in contact with enemy
#		check if block is in contact with player
#		if block is destructible, break it
#	after 20 frames
#		if ( ! wall left && ! at boundary)
#			draw block 2nd left for 40 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it
#	after 40 frames
#		if ( ! wall left && ! at boundary)
#			draw block 3rd left for 20 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it
explode_left:
	enter
	move	s6,a0				# s0 has number of frames
	jal	bomb_get_element
	move	t0,v0				# t0 contains address of bomb struct array
	# frame counter for donward explosion
	lw	t2,bomb_left
	bgt	t2,s6,_special_exit_left		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	la	a2,bomb_pattern
	jal	display_blit_5x5_trans			# draws block where the bomb used to be
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_zero
	jal	player_kill
_check_enemy_zero:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_zero				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_zero:	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	subi	a0,a0,5					# need to check tile left of bomb placement
	jal	wall_at					# determines if there is a wall to the left, and which type
	beq	v0,1,_special_exit_left			# there is an indestructible block to the left of the bomb
	beq	v0,2,_exit_with_delete_left_first	# there is a destructible block to the left of the bomb
	
	blt	a0,0,_special_exit_left		 # we do not draw block if the x coordinate is out of bounds
	la	a2,explosion_pattern	
	jal	display_blit_5x5_trans			# draw first block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy
	jal	player_kill
_check_enemy:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip:	
	lw	t2,bomb_left
	blt	t2,20,_update_timer_left			# if we havent reached 20 frames (1/3 of total frames), we do not draw
	bgt	t2,60,_special_exit_left		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0	
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	subi	a0,a0,10				# need to get 2nd block left of bomb placement
	jal	wall_at					# check if there is a wall 2 tiles left of the bomb
	beq	v0,1,_special_exit_left			# there is an indestructible block 2 tiles left of bomb
	beq	v0,2,_exit_with_delete_left_second		# there is a destructible block 2 blocks left of the bomb placement

	blt	a0,0,_special_exit_left		# we do not draw block if the x coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw second block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_second
	jal	player_kill
_check_enemy_second:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_second				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_second:	
	lw	t2,bomb_left
	blt	t2,40,_update_timer_left			# If we haven't reached 40 frames (2/3 of the total frames), we do not draw
	bgt	t2,60,_special_exit_left		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	subi	a0,a0,15				# need to get 3rd block left of bomb placement
	jal	wall_at					# check if there is a wall 3 tiles under the bomb
	beq	v0,1,_special_exit_left			# there is an indestructible block 3 tiles left of bomb
	beq	v0,2,_exit_with_delete_left_third		# there is a destructible block 3 blocks left of the bomb placement
	
	blt	a0,0,_special_exit_left		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw the third block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_third
	jal	player_kill
_check_enemy_third:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_third				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_third:	
_update_timer_left:
	lw	t2,bomb_left				
	inc	t2					# we increment the frame timer for explosion
	sw	t2,bomb_left				# store back into memory
	leave						# regular exit, a condition to draw a block failed (did not meet frame requirements)
_special_exit_left:
	# We leave the function, at this point, we have traversed the duration of the explosion (60 frames).
	sw	zero,exploding_left				# we reset the status of bomb_update function in bomb_controller.asm
	sw	zero,bomb_left				# reset frame counter for explosion (for next bomb)
	leave
_exit_with_delete_left_first:
# CASE: we want to exit function, but also delete the 1st tile to the left of the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_left
_exit_with_delete_left_second:
# CASE: we want to exit function, but also delete the 2nd tile to the left of the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_left
_exit_with_delete_left_third:
# CASE: we want to exit function, but also delete the 3rd tile to the left of the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_left
	
# void explode_right()
#	if ( ! wall right && ! at boundary)
#		draw block right for 60 frames
#		check if block is in contact with enemy
#		check if block is in contact with player
#		if block is destructible, break it
#	after 20 frames
#		if ( ! wall right && ! at boundary)
#			draw block 2nd right for 40 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it
#	after 40 frames
#		if ( ! wall left && ! at boundary)
#			draw block 3rd right for 20 frames
#			check if block is in contact with enemy
#			check if block is in contact with player
#			if block is destructible, break it	
explode_right:
	enter
	move	s6,a0				# s0 has number of frames
	jal	bomb_get_element
	move	t0,v0				# t0 contains address of bomb struct array
	# frame counter for donward explosion
	lw	t2,bomb_right
	bgt	t2,s6,_special_exit_right		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x cooordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	la	a2,bomb_pattern
	jal	display_blit_5x5_trans			# draws block where the bomb used to be
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_zero
	jal	player_kill
_check_enemy_zero:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_zero				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_zero:	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)				# gets x coordinate
	lw	a1,bomb_y(t0)				# gets y coordinate
	addi	a0,a0,5					# need to check tile right of bomb placement
	jal	wall_at					# determines if there is a wall to the right, and which type
	beq	v0,1,_special_exit_right			# there is an indestructible block to the right of the bomb
	beq	v0,2,_exit_with_delete_right_first	# there is a destructible block to the right of the bomb
	
	bge	a0,ARENA_W,_special_exit_right		 # we do not draw block if the x coordinate is out of bounds
	la	a2,explosion_pattern	
	jal	display_blit_5x5_trans			# draw first block
		# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy
	jal	player_kill
_check_enemy:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip:	
	lw	t2,bomb_right
	blt	t2,20,_update_timer_right			# if we havent reached 20 frames (1/3 of total frames), we do not draw
	bgt	t2,60,_special_exit_right		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0	
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	addi	a0,a0,10				# need to get 2nd block right of bomb placement
	jal	wall_at					# check if there is a wall 2 tiles right of the bomb
	beq	v0,1,_special_exit_right			# there is an indestructible block 2 tiles right of bomb
	beq	v0,2,_exit_with_delete_right_second		# there is a destructible block 2 blocks right of the bomb placement

	bge	a0,ARENA_W,_special_exit_right		# we do not draw block if the x coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw second block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_second
	jal	player_kill
_check_enemy_second:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_second				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_second:	
	lw	t2,bomb_right
	blt	t2,40,_update_timer_right			# If we haven't reached 40 frames (2/3 of the total frames), we do not draw
	bgt	t2,60,_special_exit_right		# stop drawing after 60 frames
	
	jal	bomb_get_element
	move	t0,v0
	lw	a0,bomb_x(t0)
	lw	a1,bomb_y(t0)
	addi	a0,a0,15				# need to get 3rd block right of bomb placement
	jal	wall_at					# check if there is a wall 3 tiles right the bomb
	beq	v0,1,_special_exit_right			# there is an indestructible block 3 tiles right of bomb
	beq	v0,2,_exit_with_delete_right_third		# there is a destructible block 3 blocks right of the bomb placement
	
	bge	a0,ARENA_W,_special_exit_right		# we do not draw block if the y coordinate is out of bounds
	la	a2,explosion_pattern
	jal	display_blit_5x5_trans			# draw the third block
	# We now compare coordinates of block we just drew to coordinates of enemy, if they are the same, we kill enemy
	# we also compare them to player coordinates, if they are the same, player loses the game
	jal	player_compare_coords
	beqz	v0,_check_enemy_third
	jal	player_kill
_check_enemy_third:
	jal	enemy_compare_coords
	move	t0,v0					# t0 contains index of enemy @ same location as explosive block, or -1 if no enemy
	beq	t0,-1,_skip_third				# we do not kill anyone 
	move	a0,t0					
	jal	enemy_get_element			# we get memory address of the enemy to kill
	move	a0,v0					# a0 now contains memory address of enemy to kill
	jal	enemy_dead
_skip_third:	
_update_timer_right:
	lw	t2,bomb_right				
	inc	t2					# we increment the frame timer for explosion
	sw	t2,bomb_right				# store back into memory
	leave						# regular exit, a condition to draw a block failed (did not meet frame requirements)
_special_exit_right:
	# We leave the function, at this point, we have traversed the duration of the explosion (60 frames).
	sw	zero,exploding_right				# we reset the status of bomb_update function in bomb_controller.asm
	sw	zero,bomb_right				# reset frame counter for explosion (for next bomb)
	leave
_special_exit_right2:
_exit_with_delete_right_first:
# CASE: we want to exit function, but also delete the 1st tile to the right of the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_right
_exit_with_delete_right_second:
# CASE: we want to exit function, but also delete the 2nd tile to the right of the bomb placement (a destructible block)
	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_right
_exit_with_delete_right_third:
# CASE: we want to exit function, but also delete the 3rd tile to the right of the bomb placement (a destructible block)


	# we get args for delete_wall_at when we call it above
	jal	delete_wall_at
	j	_special_exit_right
