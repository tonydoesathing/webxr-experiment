extends CSGCombiner

# black material
var black_mat = preload("res://black_material.tres")
var white_mat = preload("res://white_material.tres")

export(bool) var black

var mat

# the speed at which the cylinder will rotate
var rot_speed


func _ready():
	if black:
		mat=black_mat
	else:
		mat=white_mat
	randomize()
	rot_speed = rand_range(0.005,0.1)
	var outside_radius = rand_range(6,8)
	
	var outside = CSGCylinder.new()
	if black:
		outside.radius=8
	else:
		outside.radius=7
	outside.height=rand_range(0.5, 3)
	outside.sides=45
	outside.material=self.mat
	outside.operation=CSGShape.OPERATION_UNION
	self.add_child(outside)
	
	var inside = CSGCylinder.new()
	inside.radius=outside.radius-1
	inside.height=outside.height
	inside.sides=outside.sides
	inside.material=self.mat
	inside.operation=CSGShape.OPERATION_SUBTRACTION
	self.add_child(inside)

	
	var limiter_r = CSGBox.new()
	limiter_r.width=16
	limiter_r.depth=rand_range(1,16)
	limiter_r.height=outside.height+1
	limiter_r.material=self.mat
	limiter_r.operation=CSGShape.OPERATION_SUBTRACTION
	self.add_child(limiter_r)
	
	
	self.rotate_y(randf())



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate_y(rot_speed*delta)
