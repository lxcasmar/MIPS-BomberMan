## This file implements the functions that control the bomb based on the keyboard input

# Include the macros file 
.include "macros.asm"
# Include the constants settings file with the board settings
.include "constants.asm"
# Need to access bomb structure for the offset definitions in the structure array
.include "bomb_struct.asm"
# Need to access arena structure for the offset definitions
.include "arena_struct.asm"
# Need to access player structure for the offset defintions
.include "player_struct.asm"

# Need to access these functions outside of this file
.globl	bomb_update
.globl	exploding_down
.globl	exploding_up
.globl	exploding_right
.globl	exploding_left
.data
	current_frame:		.word	0				# variable used to check for user input every x frames
	last_action_frame:	.word	0				# variable used to check for user input every x frames
	frame_timer:		.word	0				# timer used for countdown to explode bomb
	# booleans that let us know if we are exploding in each direction
	exploding_down:		.word	0				
	exploding_up:		.word	0
	exploding_right:	.word	0
	exploding_left:		.word	0
.text

# checks for user input, if there is, places a bomb and begins countdown, then it makes the bomb explode.
# void bomb_update(frame_counter)
#	if exploding_down	explode_down			// functions in bomb_view.asm
#	if exploding_up		explode_up			
#	if exploding_left	explode_left			
#	if exploding_right	explode_right	
#	current_frame = frame_counter
#	if current_frame < last_action_frame + 60
#		t0 = &bomb
#		if %(t0+bomb_status) == 0	return (exit)
#		else
#			if frame_timer < 60
#				frame_timer ++
#				return (exit)
#			else
#				frame_timer = 0
#				exploding_up = exploding_down = exploding_left = exploding_right = 1
#				%(t0+bob_status) == 0
#				return (exit)
#	else
#		if b_pressed
#				%(t0 + bomb_status) =1
#				%(t0 + bomb_x) = player_x
#				%(t0 + bomb_y) = player_y
#				t0 = &bomb
#		if %(t0+bomb_status) == 0	return (exit)
#		else
#			if frame_timer < 60
#				frame_timer ++
#				return (exit)
#			else
#				frame_timer = 0
#				exploding_up = exploding_down = exploding_left = exploding_right = 1
#				%(t0+bob_status) == 0
#				return (exit)
bomb_update:			
	enter
	# we check our booleans, if we have not finished exploding, we will not be able to drop another bomb
	lw	t0,exploding_down
	bnez	t0,_explode_d			# explode down	
_check_up:
	lw	t0,exploding_up
	bnez	t0,_explode_u			# explode up
_check_left:
	lw	t0,exploding_left
	bnez	t0,_explode_l			# explode left
_check_right:
	lw	t0,exploding_right
	bnez	t0,_explode_r			# explode right
	
	la	t5,current_frame
	sw	a0,0(t5)		# store frame_counter into current_frame
	lw	t5,current_frame
	lw	t6,last_action_frame
	addi	t6,t6,60			# frame limit
	blt	t5,t6,_check_status		# we do not check if "B" is pressed if less than 60 frames have elapsed
	
	lw	t1,b_pressed			# check if "B" is pressed after 60 frames
	beqz	t1,_exit			# exit the function if "b" was not pressed
	# else, "B" was pressed at the current frame
	jal	bomb_get_element
	move	t0,v0				# t0 contains address of bomb struct array
	li	t1,1
	sw	t1,bomb_status(t0)		# set the bomb status to 1 (active)
	jal	player_get_element
	# now we make the bomb spawn at the location of the player
	move	t2,v0
	lw	t3,player_x(t2)			# t3 contains the x coordinate of player
	lw	t4,player_y(t2)			# t4 contains the y coordinate of player
	sw	t3,bomb_x(t0)			# store player x coord into bomb x coord
	sw	t4,bomb_y(t0)			# store player y coord into bomb y coord
	
# check if the bomb is active, then, begin a timer, after which the bomb explodes.
_check_status:
	jal	bomb_get_element
	move	t0,v0				# t0 contains address of bomb struct array
	lw	t1,bomb_status(t0)		#
	beqz	t1,_exit			# we exit if the bomb is not active
	#frame limiter bot (this is done at the 60th frame (and multiples of 60)
	la t2, last_action_frame		
	lw t3,current_frame
	sw t3,0(t2)				# we make last action frame equal to current frame (this is for checking "B" input
		
	lw	t3,frame_timer			# value of frame timer
	blt	t3,60,_update_timer		# if frame timer is less than 60, bomb does not explode
	
	# explode bomb				
	li	t7,1
	sw	t7,exploding_down			# we set 4 different booleans so that each explosion is independent 
	sw	t7,exploding_up					# and they dont all stop at the same time always.
	sw	t7,exploding_left
	sw	t7,exploding_right
	
	sw	zero,bomb_status(t0)		# dissapear bomb
	
	sw	zero,frame_timer		# reset countdown for the next bomb
	j	_exit
_update_timer:
	inc	t3
	sw	t3,frame_timer			# increment our countdown timer
_exit:
	leave
	# Here we call functions in bomb_view.asm, they take care of the visual stuff for the explosion
_explode_d:
	li	a0,60
	jal	explode_down
	j	_check_up
_explode_u:
	li	a0,60
	jal	explode_up
	j	_check_left
_explode_l:
	li	a0,60
	jal	explode_left
	j	_check_right
_explode_r:
	li	a0,60
	jal	explode_right
	leave
