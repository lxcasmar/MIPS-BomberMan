# we need to access color definitions, etc.
.include "constants.asm"
# save some typing
.include "macros.asm"
# need to access the model definitions for the arena
.include "arena_struct.asm"
# need to access the offset defintions for the structure of the player array
.include "player_struct.asm"

.globl arena_draw

.data	
	# counter for player moves
	moves: 		.word 0
	# 5x5 byte pattern for the indestructible blocks
	in_pattern:	.byte 	6,6,14,6,14,
				14,14,6,14,6,
				6,14,14,6,14,	
				14,6,14,14,6,
				6,14,6,6,14
	# # 5x5 byte pattern for the destructible blocks
	de_pattern:	.byte 	2,3,3,2,3,
				3,2,2,3,2,
				2,2,3,2,3,
				2,3,2,2,2,
				3,2,3,2,3,
	
.text 

# void arena_draw()
#	draw_status_bar()
#	draw_walls
arena_draw:
	enter
	jal draw_status_bar		# call functions below
	jal draw_walls
	leave

# void draw_walls()
#	int s2 = 0
#	int s3 = 0
#	for i = 0, i<11, i++
#		for j = 0, j<11, j++
#			ans = wall_at(s2,s3)
#			if ans == 1	display_blit_5x5_trans(s2,s3,in_pattern)
#			if ans == 0     display_blit_5x5_trans(s2,s3,de_pattern)
#			s2 = s2+5
#		s2=0
#		s3 = s3+5
draw_walls:	
	enter
	li	s0,0			# counter for rows
	li	s1,0			# counter for columns
	li	s2,0			# x coordinate
	li	s3,0			# y coordinate
_row_loop:
	bge	s0,11,_exit		# we are done once we draw every row
_col_loop:
	bge	s1,11,_next_row		# we exit inner loop once we draw every column
	# args for wall_at function
	move	a0,s2			# x coordinate
	move	a1,s3			# y coordinate
	jal	wall_at
	beq	v0,1,_draw_in		# we draw indestructible block
	beq	v0,2,_draw_de		# we draw destructible block
_next_col:
	addi	s2,s2,5			# we add 5 to the x coordinate to test next tile in the arena
	inc	s1			# we add 1 to the column counter
	j	_col_loop		# loop around
_next_row:		
	addi	s3,s3,5			# we add 5 to the y coordinate to test the next row in the arena
	li	s2,0			# we reset our x coordinate
	li	s1,0			# we reset our column counter
	inc	s0			# we increment our row counter
	j	_row_loop		# we loop around
_exit:
	leave
_draw_de:
	# draws destructible pattern
	la	a2,de_pattern
	jal	display_blit_5x5_trans
	j	_next_col
_draw_in:
	# draws indestructible pattern
	la	a2,in_pattern
	jal	display_blit_5x5_trans
	j	_next_col
	
	

# Function that draws the border of the display and draws the points/moves status
# void draw_status_bar()
#	display_fill_rect(0,55,64,9,COLOR_BLUE)
#	display_fill_rect(55,0,9,64,COLOR_BLUE)
#	display_draw_text(5,57,"MOVES: )
#	t0 = $player_array
#	t1 = %(t0+player_moves)
#	display_draw_int(39,57,t1)
draw_status_bar:
	enter

	li 	a0,0					# x coordinate
	li 	a1,55					# y coordinate
	li 	a2,64					# length
	li	a3,9					# width
	li	v1,COLOR_BLUE				# color
	jal	display_fill_rect
	
	li	a0,55					# x coordinate
	li	a1,0					# y coordinate
	li	a2,9					# length
	li	a3,64					# width
	li	v1,COLOR_BLUE				# color
	jal	display_fill_rect	
	
	li	a0,5					# x coordinate
	li	a1,57					# y coordinate
	lstr	a2, "MOVES: "				# text to display
	jal	display_draw_text	
	
	li	a0,39					# x coordinate
	li	a1,57					# y coordinate
	jal	player_get_element			
	move	t0,v0
	lw	a2,player_moves(t0)			# get the number of moves the player has made
	jal	display_draw_int			
	leave

#  -----------------------------------------------------------------------------------------------------------------------------------------
# None of the following functions are used, they were just some early ideas
# ------------------------------------------------------------------------------------------------------------------------------------------

# args: a0<- start x, a1<- start y, a2<-5x5 bit color pattern, a3<- size (number of tiles)
# Draws a column of a3 consecutive 5x5 tiles at an indication position, from an indicated bit pattern
draw_tile_col:
	enter
	li 	s0,0
	move 	s1,a1
_loop_top:
	bge	s0,a3,_exit
	move 	a1,s1
	mul	t0,s0,tile_size
	add	a1,a1,t0
	jal	display_blit_5x5_trans
	inc	s0
	j	_loop_top
_exit:
	move 	a1,s1
	leave

#
#
draw_tile_col_skip:
	enter
	li	s0,0
	move	s1,a1
_loop_top:
	bge	s0,a3,_exit
	move	a1,s1
	li	t0,tile_size
	mul	t0,s0,tile_size
	mul	t0,t0,2
	add	a1,t0,a1
	jal 	display_blit_5x5_trans
	inc	s0
	j	_loop_top
_exit:
	move a1,s1
	leave

# args: a0<- start x, a1<-start y, a2<- 5x5 bit color pattern, a3<-size (number of tiles)
# will draw a row of a3 consecutive 5x5 tiles at an indicated position, from an indicated bit pattern	
draw_tile_row:
	enter	
	li 	s0,0					# counter variable
	move	s1,a0
_loop_top:
	bge	s0,a3,_exit				# exit once we have drawn 5 indestructible tiles
	move	a0,s1				
	mul	t0,s0,tile_size				# shift the x coordinate by 5 * s0
	add	a0,t0,a0				# add the shift to the initial x coordinate
	jal	display_blit_5x5_trans
	inc 	s0
	j	_loop_top
_exit:
	move	a0,s1
	leave	

# args: a0<- start x, a1<- start y, a2<- 5x5 bit color pattern, a3<-size (number of tiles)
# draws a row of a3 5x5 tiles, with an empty tile between each one, at an indicated position, from an indicated bit pattern
draw_tile_row_skip:
	enter
	li	s0,0
	move	s1,a0
_loop_top:
	bge	s0,a3,_exit
	move	a0,s1
	li	t0,tile_size
	mul	t0,s0,tile_size
	mul	t0,t0,2
	add	a0,t0,a0
	jal 	display_blit_5x5_trans
	inc	s0
	j	_loop_top
_exit:
	move a0,s1
	leave
