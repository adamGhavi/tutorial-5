extends KinematicBody2D

# basic movement
export var grav = 500
export var max_hspd = 15000
export var acc = 4000

enum HAXIS {RIGHT = 1, STILL = 0, LEFT = -1}
enum VAXIS {DOWN = 1, STILL = 0, UP = -1}

var spd = Vector2.ZERO
var axis = Vector2.ZERO
var axis_previous = axis

# slide mechanic
export var slide_spd = 50000

# double jump mechanic
export var jump_height = -24000
export var jumps_max = 2
var jumps = jumps_max

# state machine
enum PLAYER_STATE {IDLE, JUMPING, SLIDING}
var state = PLAYER_STATE.IDLE

# get nodes
onready var animated_sprite = get_node("AnimatedSprite")
onready var slide_dust = get_node("SlideDust")

func _process(delta):
	# squash & stretch effects
	animated_sprite.scale = lerp(animated_sprite.scale, Vector2(1, 1), .1)

	# get axes
	axis_previous = axis
	
	var haxis = Input.get_axis("ui_left", "ui_right")
	var vaxis = Input.get_axis("ui_up"  , "ui_down")
	
	axis = Vector2(haxis, vaxis)

func sns(ss):
	animated_sprite.scale += Vector2(ss, -ss)

func horizontal_movement(haxis, haxis_previous):
	#
	var moving = haxis != HAXIS.STILL && !is_on_wall()
	
	# accelerate or decelerate, limit between range
	if moving:
		spd.x += haxis*acc
		
	else:
		spd.x = lerp(spd.x, 0, .4)
	
	spd.x = clamp(spd.x, -max_hspd, max_hspd)
	
	#
	return moving

func vertical_movement(vaxis, vaxis_previous):
	#
	var jumping = vaxis == VAXIS.UP && vaxis_previous != VAXIS.UP && jumps > 0
	
	#
	if jumping:
		# 
		spd.y = jump_height
		jumps -= 1
		
		#
		$JumpSFX.playing = true
		
		#
		sns(-.25)
		
	return jumping

func _physics_process(delta):
	# this movement system is how i normally would code it in gms, translated into godot w/ a betterjump implementation
		
	# normal walking state
	if state == PLAYER_STATE.IDLE:
		if horizontal_movement(axis.x, axis_previous.x):
			#
			animated_sprite.animation = "walk"
			animated_sprite.playing = true
			animated_sprite.flip_h = (axis.x == HAXIS.LEFT)
			
			# slide
			if axis.y == VAXIS.DOWN && axis_previous.x == HAXIS.STILL:
				#
				spd.x = axis.x*slide_spd
				
				# state transition
				animated_sprite.animation = "slide"
				slide_dust.emitting = true
				state = PLAYER_STATE.SLIDING
		
		#
		else:
			# animation transition
			if axis.y == VAXIS.STILL:
				animated_sprite.animation = "idle"
				animated_sprite.playing = false
			
			elif axis.y == VAXIS.DOWN:
				animated_sprite.animation = "duck"
				animated_sprite.playing = false
		
		if vertical_movement(axis.y, axis_previous.y) || !is_on_floor():
			# state transition
			animated_sprite.animation = "jump"
			animated_sprite.playing = false
			state = PLAYER_STATE.JUMPING
	
	elif state == PLAYER_STATE.JUMPING:
		if horizontal_movement(axis.x, axis_previous.x):
			pass
		
		if vertical_movement(axis.y, axis_previous.y):
			pass
			
		# gravity w/ betterjump implementation
		else:
			var r_grav = grav
			
			if axis.y != VAXIS.UP || spd.y > 0:
				r_grav *= 4
			
			spd.y += r_grav
		
		# state transition
		if is_on_floor():
			# s&s
			sns(.25)
			
			# restore jumps
			jumps = jumps_max
			
			# state transition
			animated_sprite.animation = "idle"
			animated_sprite.playing = false
			state = PLAYER_STATE.IDLE
	
	#
	elif state == PLAYER_STATE.SLIDING:
		#
		spd.x = lerp(spd.x, 0, .05)
		
		#
		if !is_on_floor():
			spd.y += grav
			
		# state transition
		if axis.y != VAXIS.DOWN || is_on_wall() || abs(spd.x) < 1000:
			animated_sprite.animation = "duck"
			animated_sprite.playing = false
			slide_dust.emitting = false
			state = PLAYER_STATE.IDLE
	
	# update coordinates
	move_and_slide(spd*delta, Vector2.UP)
