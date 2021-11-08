
# Include the macros file so that we save some typing
.include "macros.asm"
# Include the constants settings file with the board settings
.include "constants.asm"
# We will need to access the arena model, include the structure offset definitions
.include "arena_struct.asm"

.globl	select_screen_update
.data
	current_frame:	.word	0
	last_action_frame:	.word	0
	
.text
# function that checks if the user selected a characater model, or if they pressed left or right to view the next model
# THIS FUNCTION IS NOT USED, WILL BE IMPLEMENTED WHEN THE CHARACTER SELECTION SCREEN IS, IN THE FUTURE
# void select_screen_update(frame_counter, count in s0)
# 	current_frame  = frame_counter
#	if current_frame < last_action_frame + 60
#		return (exit)
#	if c_pressed 
#		player_set_look			(this function is in player_controller.asm)
#	if left_pressed
#		dec count
#	if right_pressed
#		inc count
#	last_action_frame = current_frame
#	exit
select_screen_update:
	enter
	la t0,current_frame
	sw a0,0(t0)				#stores input into current_frame
	
	lw t0,current_frame			# if less than 60 frames have elapsed, exit loop
	lw t1,last_action_frame
	addi t1,t1,60
	blt t0,t1,_exit
	
	lw	t2,c_pressed
	beqz	t2,_skip_select			# if c is not pressed, we do not select the look for the character
	move	a0,s0
	jal	player_set_look			
	j	_exit
_skip_select:

	lw	t3,right_pressed			# check if user pressed right arrow
	beqz	t3,_skip_right
	inc 	s0					# increment counter if they did
_skip_right:
	lw	t4,left_pressed			# check if user pressed left arrow
	beqz	t4,_skip_left
	dec	s0					# decrement counter if they did
_skip_left:
	
	la t2, last_action_frame			# update last_action_frame
	lw t0,current_frame
	sw t0,0(t2)
_exit:
	leave
