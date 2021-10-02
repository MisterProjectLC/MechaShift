extends RigidBody2D


func shoot(shoot_vector):
	rotation = atan2(shoot_vector.y, shoot_vector.x)
	linear_velocity = shoot_vector
