extends CharacterBody2D

@export_group("Stats")
@export var SPEED = 100.0
@export var health: int = 20
@export var damage: int = 20 
# assigned on ready, this stops a flood of errors.
@export_group("Player Things")
@export var player_name = "Character"
var player
# In the main scene, this goes to the very very top node! one node down, there should
# be the character and the spawners
@onready var absolute_parent = get_parent()
# Used to increase the score (Spawners should be the child of a "scene" node)
@export var score_value = 1

var direction: Vector2

func _ready():
	if absolute_parent.get_node_or_null(player_name) != null:
		player = absolute_parent.get_node(player_name)
		

func _process(delta):
	# These 3 little lines of code handle movement! Don't ask me why velocity has to be set this way.
	if player != null:
		self.look_at(player.get("position"))
		self.velocity = Vector2(0, 0)
		direction.x = player.get("position").x - self.position.x
		direction.y = player.get("position").y - self.position.y
		direction = direction.normalized()
		if direction.x:
			self.velocity.x = direction.x * SPEED
		if direction.y:
			self.velocity.y = direction.y * SPEED
		
	move_and_slide()

# Destroy the player
func _on_area_detector_body_entered(body):
	if body.name == player_name && body.get("die") != true:
		body.Damage(damage)

# Get hit, or die.
func hit(damage):
	health -= damage # how do I get the attack damage from the player? I think the bullet gets the attack from the player, multiply by it's damage multiplier and pass this to the enemy
	if health <= 0:
		
		absolute_parent.Score += score_value
		
		get_node("Kill").set_emitting(true)
		get_node("Kill/Sound").play()
		get_node("Kill").reparent(get_parent().get_parent())
		self.queue_free()
		
