extends CharacterBody2D

@export var HP = 100.0
@export var ATK = 0.0
@export var SPEED = 150.0
@export var CRT = 0 #look how to calculate critical chance and critical damage calculation
@export var PICKUP_MULT = 1 #multiplier for pickup hitbox
@export var HASTE = 0
@export var BASE_ATK_TIME = 0.8
@export var ATK_TIME = 0.8
@export var DAMAGE_TIME = 0.5
@export var Bullet: PackedScene
@onready var Camera = get_node("Camera2D")

var timer = 0
var damage_timer = 0

var power = false
var power_timer = 0

@onready var absolute_parent = get_parent()

# controls the player's movement when they die.
var die: bool = false

var direction: Vector2

func _ready():
	# I have no idea why this makes the camera do that thing, but this is cool!
	Camera.set("position", Vector2(100, 0))

func _physics_process(delta):
	timer += delta
	damage_timer += delta
	ATK_TIME = BASE_ATK_TIME/(1+HASTE/100)
	
	# Get the input direction and handle the movement/deceleration.
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	velocity.x = 0
	velocity.y = 0
	
	# Stop doing things if you are dead, Respawn on 
	if die == true:
		if Input.get_action_raw_strength("Respawn"):
			Respawn()
		return
	
	# if the player isn't dead...
	if Input.get_action_raw_strength("Shoot") && timer >= ATK_TIME:
		var temp = Bullet.instantiate()
		add_sibling(temp)
		temp.global_position = get_node("BulletSpawn").get("global_position")
		# this sets the rotation as to where it will fire
		temp.set("area_direction", (get_global_mouse_position() - self.global_position).normalized())
		#set attack 
		temp.set("player_ATK", ATK)
		# These statements below handle camera shake
		Camera.set("offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)))
		timer = 0
	else:
		Camera.set("offset", Vector2(0, 0))
	# movement is handled like this
	if direction.x:
		velocity.x = direction.x * SPEED
	if direction.y:
		velocity.y = direction.y * SPEED
	
	
	# look at mouse
	self.look_at(get_global_mouse_position())
	move_and_slide()

# all the things that it do when you die.
func Die():
	get_node("Explosive").set_emitting(true)
	get_node("Explosive/Sound").play()
	self.get_node("MeshInstance2D").set("visible", false)
	#Stop Camera and set player to death
	Camera.set("position", Vector2(0, 0))
	die = true
	#Wait 1.5 seconds before showing retry screen
	await get_tree().create_timer(1.5).timeout
	#Move Camera to center
	position = Vector2(383,397)
	#Show Retry Background over whole screen
	$"../Retry".show()
	
func Damage(damage):
	#get_node("Explosive").set_emitting(true)
	#get_node("Explosive/Sound").play()
	#self.get_node("MeshInstance2D").set("visible", false)
	if timer >= DAMAGE_TIME:
		timer = 0
		HP = HP - damage 
		if HP <= 0:
			Die()
	
# Reload Scene
func Respawn():
	get_tree().reload_current_scene()
