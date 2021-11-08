# Need to access offset defintions of the player structure
.include	"player_struct.asm"
# save some typing
.include	"macros.asm"

.data
	array_of_player_struct:	.word	0,0,0,0,1	# 1 player * 5 words  = 5
	# we need to set the last word on the array since it tracks whether the player is alive or dead.
.text
# need to access these functions outside of this file
.globl	player_get_element
.globl	player_compare_coords
.globl player_kill

# for now, just returns the address of the array since there is only one player, can be modified for more players
# void player_get_element()
#	reutrn &array_of_player_struct
player_get_element:
	
	la	v0,array_of_player_struct
	jr 	ra

# returns coordinates (x,y) of player
# args: void 	return: v0<- x coordinate v1<- y coordinate
# int array player_get_coordinates()
#	t0 = player_get_element
#	return	array with [%(t0 + player_x),%(t0+player_y)]
player_get_coordinates:
	enter
	jal	player_get_element
	move	t0,v0
	lw	v0,player_x(t0)
	lw	v1,player_y(t0)
	leave
	
# compares a given set of coordinates to the coordinates of the player, if they match, returns 1, otherwise, returns 0
# args: a0<- x coordinate a1<- y coordinate
# int player_compare_coords(int x, int y)
#	a = player_get_coordinates[1]
#	b = player_get_coordinates[2]
#	if(x==a && y==b)
#		return 1
#	else
#		return 0
player_compare_coords:
	enter	t2,t3,a0,a1,t1
							# will return -1 if no match
	move	t2,a0					# t2 contains x coordinate to compare
	move	t3,a1					# t3 contains y coordinate to compare
	
	move	a0,s0
	jal	player_get_coordinates
	move	t0,v0					# t0 contains x coordinate of ith enemy
	move	t1,v1					# t1 contains y coordinate of ith enemy
	
	bne	t0,t2,_skip				# we have not found a match if x coords dont match
	bne	t1,t3,_skip				# or if y coords dont match, so we do not save index
	li	v0,1					# else, we have a match, we return -1
	leave	t2,t3,a0,a1,t1					# we exit function here if we have matched a coordinate pair
_skip:
	li	v0,0					# if we exit this way, it means we did not match
	leave	t2,t3,a0,a1,t1


# function that resets the status of the player. The game will end in the next frame as a result
# args: void	return: void
# void player_kill()
#	t0 = player_get_element
#	%(t0+player_status) = 0
player_kill:
	enter	a0,a1,t0,t1,t2
	jal	player_get_element
	move	t0,v0
	sw	zero,player_status(t0)
	leave	a0,a1,t0,t1,t2
	
