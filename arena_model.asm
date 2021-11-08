# need to access the offset definitions of the arena
.include "arena_struct.asm"
# to minimize typing
.include "macros.asm"

.data
	
	# There are 121 tiles of 5x5 pixels in the arena
	# a 0 represents no wall, a 1 represents an indestructible wall, a 2 represents a destructible wall.
	 tile_loc_array:.word	0,0,0,0,0,0,0,0,0,0,0
				0,1,2,1,2,1,2,1,2,1,0
				0,0,2,0,0,0,0,2,0,2,0
				0,1,2,1,0,1,0,1,0,1,0
				0,0,2,0,2,0,2,0,0,2,0		    
				0,1,2,1,0,1,0,1,0,1,0	    
				0,0,2,0,0,0,0,2,0,2,0  
				0,1,2,1,0,1,0,1,0,1,0		    
				0,0,2,0,0,0,0,0,0,2,0		    
				0,1,2,1,2,1,2,1,2,1,0		    
				0,0,0,0,0,0,0,0,0,0,0
.text

# need to access these functions outside of this file
.globl wall_at
.globl delete_wall_at

#checks if there is a wall at a given pair (x,y)
# args: a0<-x coordinate, a1<- y coordinate
# return: v0<-1 if true, v0<-0 if false
# int wall_at(int x, int y)
#	t0 = &tile_loc_array
#	a0 = a0/5
#	a1 = a1/5
#	t0 = t0 + (a0)*4 + (a1)*11*4
#	return tile_loc_array[t0]
wall_at:
	enter	t0,t1,t2,a0,a1
	la	t0,tile_loc_array
	div	a0,a0,tile_size					# x and y coordinates entered from (0,0) to (55,55)
	div	a1,a1,tile_size					# we divide to get the correct tile. Now: (0,0) to (11,11)
	
	mul	t1,a0,4						# 4 bytes per word
	
	mul	t2,a1,11					# 11 elements per row 
	mul	t2,t2,4						# 4 bytes per word
	
	add	t1,t1,t2					# add row shift and column shift
	add	t0,t0,t1					# add shifts to original address
	lw	t1,0(t0)					# load the value of the array at the address
	beqz	t1,_no_wall					# if the value is zero, there is no wall
	move	v0,t1						# else there is a wall and we return the value in the array
	j	_wall_exit
_no_wall:
	li	v0,0					# return 0 if there is no wall
_wall_exit:
	leave	t0,t1,t2,a0,a1
	
# resets a tile (deletes a wall) at a given pair (x,y)
# args: a0<- x coordinate a1<- y coordinate
# void delete_wall_at(int x, int y)
#	t0 = &tile_loc_array
#	t0 = t0 + (a0)/5*4 + (a1)/5*11*4
#	tile_loc_array[t0] = 0				# we use [t0] as if we were indexing the array using memory addresses
#	return (exit)
delete_wall_at:
	enter t0,t1,t2,a0,a1
	la	t0,tile_loc_array			# t0 contains address of the array 
	div	a0,a0,tile_size				# need to divide x and y coordinates by 5 to macth tile coordinates
	div	a1,a1,tile_size
	
	mul	t1,a0,4					# 4 bytes per word
	
	mul	t2,a1,11				# 11 elements per row
	mul	t2,t2,4					# 4 bytes per word
	
	add	t1,t1,t2
	add	t0,t0,t1				# t0 contains address of element at (x,y) of tile array
	li	t3,0					
	sw	t3,0(t0)				# we make the wall at the memory address a zero
	leave	t0,t1,t2,a0,a1
