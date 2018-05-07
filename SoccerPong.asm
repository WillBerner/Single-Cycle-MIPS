##################################################################################
##################################################################################
################## 	Will Berner	 	`	##########################
################## 	COMP 541 Final Project		##########################
##################	Apr 5, 2018			##########################
###################################################################################
##################################################################################

# This basic MIPS program tests my processor and IO/Display
#
#############################################################################################
#
# 		!!!!!!!!!!!!  FUTSAL: CHELSEA VS MAN U !!!!!!!!!!!
#
#############################################################################################


.data 0x10010000 			# Start of data memory
a_sqr:	.space 4
a:	.word 3

.text 0x00400000			# Start of instruction memory
main:

	lui	$sp, 0x1001		# Initializing stack pointer to the 64th location above start of data
	ori 	$sp, $sp, 0x0100	# top of the stack is the word at address [0x100100fc - 0x100100ff]
	
	############ SAVED REGISTERS #############
	#
	# $s0: which player clicked, 0 = Left, 1 = Right 
	# $s1: Y value of Left Player
	# $s2: Y value of Right Player
	# $s3: X value of Ball
	# $s4: Y value of Ball
	# $s5: Ball Direction, 0 = NE, 1 = SE, 2 = SW, 3 = NW
	#
	##########################################
	
	# Start off by placing the soccer ball and player sprites on the screen
	
Restart:
	## TO MAKE SURE LAST GAME'S CHARS WERE CLEARED ##
	li	$a0, 0
	li	$a1, 0
	move	$a2, $s1
	jal	putChar_atXY
	
	li	$a1, 39
	move	$a2, $s2
	jal	putChar_atXY

	# Soccer ball placement
	li	$s3, 20
	li	$s4, 15
	li	$s5, 1			# initialize ball direction to NW
	li	$a1, 20			# initialize ball to middle screen col (X=20)
	li	$a2, 15			# initialize ball to middle screen row (Y=15)
	li	$a0, 2			# initialize to Soccer ball char
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	# Left player placement
	li	$a0, 3			# draw Chelsea char
	li	$a1, 0 			# initialize left player to to left screen row (X=0)
	li	$s1, 15			# Left Player's Y Position begins at 15
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	# Right player placement
	li	$a0, 1			# draw Man U char
	li	$a1, 39 		# initialize right player to to right screen row (X=39)
	li	$s2, 15			# Right Player's Y Position begins at 15
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y

	li	$a0, 200		# pause at the beginning for one second
	jal	pause

animate_loop:	
	# if statement to decide which player to move
	bne	$s0, $0, moveRightPlayer
	
	# Moving Left Player
	li	$a0, 3			# load in Chelsea char
	li	$a1, 0			# set X value to be 0
	move	$a2, $s1		# set Y value to be Left's Y value
	j 	movePlayer
	
	# Moving Right Player
	moveRightPlayer:
	li	$a0, 1			# load in Man U char
	li	$a1, 39			# set X value to be 39
	move	$a2, $s2		# set Y value to be Right's Y value
	
	# Now that $a1 holds the correct X value, draw the char
	movePlayer:
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	####### Moving Soccer ball ########
	
	# erasing ball
	li	$a0, 0			# load green char
	move	$a1, $s3		# load ball's last X
	move	$a2, $s4		# load ball's last Y
	jal	putChar_atXY
	
	# calculating new ball XY
	beq	$s5, 0, NE
	beq	$s5, 1, SE
	beq	$s5, 2, SW
	
	# NW
	addi	$s3, $s3, -1		# Decrease X by 1
	addi	$s4, $s4, -1		# Decrease Y by 1
	j	CheckX
	
	NE:
	addi	$s3, $s3, 1		# Increase X by 1
	addi	$s4, $s4, -1		# Decrease Y by 1
	j	CheckX
	
	SE:
	addi	$s3, $s3, 1		# Increase X by 1
	addi	$s4, $s4, 1		# Increase Y by 1
	j	CheckX
	
	SW:
	addi	$s3, $s3, -1		# Decrease X by 1
	addi	$s4, $s4, 1		# Increase Y by 1
	j	CheckX
	
	
	###### CHECKING NEW BALL'S XY VALUES ######
	
	CheckX:
	slti 	$t1, $s3, 1		# Make sure ball won't be too far to the left (X<1)
	beq	$t1, 1, setBallXto2	
	slti	$t2, $s3, 39		# Make sure ball won't be too far to the right (X>39)
	beq	$t2, 0, setBallXto37
	
	# Will continue on if X doesn't have to be set
	CheckY:
	slti	$t1, $s4, 0
	beq	$t1, 1, setBallYto1	# Make sure ball won't be too high
	slti	$t2, $s4, 29
	beq 	$t2, 0, setBallYto27	# Make sure ball won't be too low
	
	# If this line is reached, the ball has a good position to be placed.
	j	PlaceBall
	
	
	#### SWITCHING DIRECTIONS AND RESETING XY VALUES OF BALL #####
	
	### HAVING TO SET X IMPLIES A COLLISION W PADDLES: NEED TO CHECK WHETHER TO REBOUND OR NOT ###
	
	### CHECK IF CHELSEA HIT THE BALL
	setBallXto2:			# EITHER GOING SW OR NW
	li	$s3, 2			# Set Ball X to 1
	beq	$s5, 2, switchToSE	# if going SW, switch to SE
	li	$s5, 0			# else switch to NE
	done1:
	bne	$s4, $s1, ChelseaLose
	sll	$a0, $s1, 12 		# Load in sound
	jal	put_sound		# Make a sound whenever ball and paddle collides
	j	CheckX
	
	ChelseaLose:
	sll	$a0, $s1, 5 		# Load in sound
	jal	put_sound		# Make a sound whenever ball and paddle collides
	j	Restart
	
	### CHECK IF MAN U HIT THE BALL
	setBallXto37:			# EITHER GOING SE OR NE
	li	$s3, 37			# Set Ball X to 37
	beq	$s5, 1, switchToSW	# if going SE, switch to SW
	li	$s5, 3			# else switch to NW
	done2:
	bne	$s4, $s2, ManULose
	sll	$a0, $s2, 12 		# Load in sound
	jal	put_sound		# Make a sound whenever ball and paddle collides
	j	CheckX
	
	ManULose:
	sll	$a0, $s1, 5 		# Load in sound
	jal	put_sound		# Make a sound whenever ball and paddle collides
	j	Restart
	
	### HAVING TO SET Y IMPLIES COLLISION W/ WALLS
	
	setBallYto1:			# EITHER GOING NE OR NW
	li	$s4, 1			# Set Ball Y to 1
	beq	$s5, 3, switchToSW2	# if going NW, switch to SW
	li	$s5, 1			# else switch to SE
	done3:
	j	CheckX
	
	setBallYto27:			# EITHER GOING SE OR SW
	li	$s4, 27			# Set Ball Y to 27
	beq	$s5, 1, switchToNE	# if going SE, switch to NE
	li	$s5, 3			# else switch to NW
	done4:
	j	CheckX
	
	#### SWITCHING DIRECTIONS OF BALL #####
	switchToSW2:
	li	$s5, 2			# load SW direction
	j 	done3
	
	switchToSE:
	li	$s5, 1			# load SE direction
	j 	done1
	
	switchToSW:
	li	$s5, 2			# load SW direction
	j 	done2
	
	switchToNE:
	li	$s5, 0			# load NE direction
	j 	done4
	
	
	
	######### BALL HAS A GOOD LOCATION, PLACE BALL AT NEW LOCATION ########
	
	PlaceBall:
	li	$a0, 2
	move	$a1, $s3
	move	$a2, $s4
	jal	putChar_atXY
	
	li	$a0, 25			# pause for 1/4th of a second for players to react
	jal	pause
	
key_loop:	
	jal 	get_key			# get a key (if available)
	beq	$v0, $0, animate_loop	# 0 means no valid key
	
	
# LEFT PLAYER
LDOWN:		#Z
	bne	$v0, 1, LUP
	li	$s0, 0			# 0 = Left Player
	
	li 	$a0, 0			# load green char to replace
	li	$a1, 0			# load X value
	move	$a2, $s1		# move Y value of Left
	
	jal 	putChar_atXY		# before loading in new XY, erase current char
	
	addi	$s1, $s1, -1		# move down by 1
	slt	$1, $s1, $0		# make sure Left's Y >= 0
	beq	$1, $0, animate_loop
	
	li	$s1, 0			# else, set Y to 0
	j	animate_loop

LUP:		#W
	bne	$v0, 2, RDOWN
	li	$s0, 0			# 0 = Left Player
	
	li 	$a0, 0			# load green char to replace
	li	$a1, 0			# load X value
	move	$a2, $s1		# move Y value of Left
	
	jal 	putChar_atXY		# before loading in new XY, erase current char
	
	addi	$s1, $s1, 1		# move up by 1
	slti	$1, $s1, 30		# make sure Left's Y < 30
	bne	$1, $0, animate_loop
	
	li	$s1, 29			# else, set Y to 29
	j	animate_loop


# RIGHT PLAYER
RDOWN:		#PLUS (+)
	bne	$v0, 3, RUP
	li	$s0, 1			# 1 = Right Player
	
	li 	$a0, 0			# load green char to replace
	li	$a1, 39			# load X value
	move	$a2, $s2		# move Y value of Right
	
	jal 	putChar_atXY		# before loading in new XY, erase current char
	
	addi	$s2, $s2, -1		# move down by 1
	slt	$1, $s2, $0		# make sure Right's Y >= 0
	beq	$1, $0, animate_loop
	
	li	$s2, 0			# else, set Y to 0
	j	animate_loop

RUP:		#ENTER
	bne	$v0, 4, key_loop	# read key again
	li	$s0, 1			# 1 = Right Player
	
	li 	$a0, 0			# load green char to replace
	li	$a1, 39			# load X value
	move	$a2, $s2		# move Y value of Left
	
	jal 	putChar_atXY		# before loading in new XY, erase current char
	
	addi	$s2, $s2, 1		# move up by 1
	slti	$1, $s2, 30		# make sure Left's Y < 30
	bne	$1, $0, animate_loop
	
	li	$s2, 29			# else, set Y to 29
	j	animate_loop
		
	###############################
	# END using infinite loop     #
	###############################
	
				# program won't reach here, but for safety (no syscalls)
end:
	j	end

######## END OF MAIN #################################################################################

.include "procs_board.asm" 		# Library MIPS procedures given to us
