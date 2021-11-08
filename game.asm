.include "constants.asm"
.include "macros.asm"
.include "enemy_struct.asm"
.include "player_struct.asm"

# need to call this function outside of this file
.globl game

.text

# void game()
#	while(t0==0 && t1==0)
#		handle_input()
#		display_draw_text(5,5,"Press C")
#		display_draw_text(11,11,"to begin")
#		display_draw_text(5,20,"Press x")
#		display_draw_text(11,26,"to "exit)
#		display_update_and_clear()
#		wait_for_next_frame()
#		t0 = c_pressed
#		t1 = x_pressed
#	if t0 ==1
#		while ( not won and not lost)
#			handle_input()
#			draw enemies, board, bomb, and player
#			update enemies, bomb, and player
#			display_update_and_clear()
#			wait_for_next_frame()
#			if (x_pressed)	clear screen and exit
#			if player_collision == 1
#				draw text "you died\nPress x\n to exit"
#				update and clear display
#			if player status is zero (dead)
#				draw text "you died\nPress x\n to exit"
#				update and clear display
#			if every enemy's satus is zero (dead)
#				draw text "you won!\n press x\n to exit"
#	else if t1 ==1
#		clear display and exit
#			
#
game:
	enter
_start_while:
	jal	handle_input
	
	# display welcome messages, press c to begin, x to exit
	li	a0, 5
	li	a1, 5
	lstr	a2, "Press c"
	jal	display_draw_text
	li	a0, 11
	li	a1, 11
	lstr	a2, "to begin"
	jal	display_draw_text
	
	li	a0, 5
	li	a1, 20
	lstr	a2, "Press x"
	jal	display_draw_text

	li	a0, 11
	li	a1, 26
	lstr	a2, "to exit"			
	jal	display_draw_text
	
	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame
	# start game if c was pressed
	lw	t0, c_pressed
	bnez	t0, _game_while
		
	# Leave if x was pressed
	lw	t0, x_pressed
	bnez	t0, _game_end
	
	j	_start_while
	
	
_game_while:

	jal	handle_input
	# draw all of our objects
	jal	player_draw
	jal	bomb_draw
	jal	arena_draw
	jal	enemy_draw	
	
	#update all our pieces
	lw	a0,frame_counter
	jal	player_update				
	lw	a0,frame_counter
	jal	enemy_update
	lw	a0,frame_counter
	jal	bomb_update
	

	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame


	# Leave if x was pressed
	lw	t0, x_pressed
	bnez	t0, _game_end

	# we check if the player collided with an enemy this frame
	jal	player_check_collision
	beq	v0,1,_game_lose
	
	# we check if the player is alive or dead (because of a bomb)
	jal	player_get_element
	move	t0,v0
	lw	t1,player_status(t0)				# t1 contains status (dead/alive)
	beqz	t1,_game_lose					# we lose if player is dead 
	
	# we check if the player has won by killing all the enemies
	jal	enemy_all_dead
	beq	v0,1,_game_win
	
	j	_game_while
_game_end:
	# ending if just press x
	# Clear the screen
	jal	display_update_and_clear
	jal	wait_for_next_frame
	leave

_game_lose:
	jal	handle_input
	# ending screen if lost the game
	li	a0, 5
	li	a1, 20
	lstr	a2, "You Died"
	jal	display_draw_text
	
	li	a0, 5
	li	a1, 26
	lstr	a2, "Press x"
	jal	display_draw_text
	
	li	a0, 11
	li	a1, 32
	lstr	a2, "to exit"			
	jal	display_draw_text
	
	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame
	
	# Leave if x was pressed
	lw	t0, x_pressed
	beqz	t0, _game_lose
	leave
_game_win:
	jal	handle_input
	li	a0,5
	li	a1,20
	lstr	a2,"You Won!"
	jal	display_draw_text
	
	li	a0, 5
	li	a1, 26
	lstr	a2, "Press x"
	jal	display_draw_text
	
	li	a0, 11
	li	a1, 32
	lstr	a2, "to exit"			
	jal	display_draw_text
	
	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame
	
	# Leave if x was pressed
	lw	t0, x_pressed
	beqz	t0, _game_win
	leave
	
# ------------------------------------------------------------------------------------------------------------------------------------------------	
# character selection screen. THIS IS NOT IMPLEMENTED/FINIHSED. Maybe in the future
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
_char_selection:
	jal	handle_input
	
	li	a0, 5
	li	a1, 5
	lstr	a2, "press c"
	jal	display_draw_text
	
	jal	display_draw_text
	li	a0, 5
	li	a1, 11
	lstr	a2, "to choose"
	jal	display_draw_text
	
	lw	a0,frame_counter
	li	s0,0
	jal	select_screen_update
	

	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame