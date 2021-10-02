extends RigidBody2D

signal on_collision

func _integrate_forces(state):
	if (state.get_contact_count() > 0):
	   emit_signal("on_collision", state.get_contact_local_normal(0))
