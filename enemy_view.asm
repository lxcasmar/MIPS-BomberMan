## file contains function that draws enemies based on enemy model and structure

# include macros, save some typing
.include "macros.asm"
# include constants, colors, board settings, etc.
.include "constants.asm"
# include definitions for offsets
.include "enemy_struct.asm"

# need to access this function outside of this file
.globl	enemy_draw
.data
.text

# void enemy_draw()
# 	for i in enemy_array
#		if( enemy_status ==1)				
#			display_blit_5x5_trans(enemy[i]_x,enemy[i]_y,&ryu_pattern)		
#
enemy_draw:
	enter	
	li	s0,0
_loop_top:
	bge	s0,n_enemies,_loop_exit
	move	a0,s0
	
	jal	enemy_get_element
	move	t0,v0				# t0 contains memory address of ith enemy
	lw	a0,enemy_x(t0)			# gets x coordinate of enemy
	lw	a1,enemy_y(t0)			# gets y coordinate of enemy
	la	a2,ryu_pattern			# loads character bit pattern
	lw	t1,enemy_status(t0)
	beqz	t1,_skip_draw			# we do not draw the enemy if it is dead
	jal	display_blit_5x5_trans		# draws character
_skip_draw:
	inc	s0
	j	_loop_top
_loop_exit:
	leave	
