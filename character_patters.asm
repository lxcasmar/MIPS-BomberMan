# this file defines the byte patterns for drawing tiles in display, can always add more
# we need them to be visible to other files
.data
.globl	ryu_pattern
.globl	master_chief_pattern
.globl	pacman_pattern
.globl 	kirby_pattern
.globl	bomb_pattern
.globl	explosion_pattern

	ryu_pattern:		.byte	10,10,10,10,10
					1,1,1,1,1
					2,0,2,0,2
					2,2,2,2,2
					7,7,2,2,0
	
	master_chief_pattern: 	.byte	0,4,12,4,0
					4,4,12,4,4
					11,11,11,11,11
					4,11,11,11,4
					4,4,12,4,4
					
	pacman_pattern:		.byte	3,3,3,3,3
					3,3,3,3,3
					3,3,0,0,0
					3,3,3,3,3
					3,3,3,3,3
					
	kirby_pattern: 		.byte	0,6,6,6,0
					6,5,6,5,6
					6,0,6,0,6
					0,6,6,6,0
					1,1,0,1,1

	bomb_pattern:		.byte	-1,-1,1,-1,-1
					-1,1,1,1,-1
					1,2,3,2,1
					1,2,2,2,1
					1,1,1,1,1

	explosion_pattern:	.byte	9,9,9,9,9
					9,9,9,9,9
					9,9,9,9,9
					9,9,9,9,9
					9,9,9,9,9
