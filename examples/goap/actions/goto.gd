# Copyright 2024 Ferdinand Souchet (aka. Khusheete)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the “Software”), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


extends GOAPAction


enum Location {
	MESS_TABLE, BED, COMPUTER,
}


@export var target_location := Location.MESS_TABLE

@onready var agent: Node2D = get_node(^"../../../")


## Function to override
func _start() -> void:
	pass


## Function to override
func _end() -> void:
	pass


func _process(_delta: float) -> void:
	var target_position: Vector2 = get_target_position()
	agent.global_position += (target_position - agent.global_position).normalized() * agent.speed


func get_target_position() -> Vector2:
	match target_location:
		Location.MESS_TABLE:
			return agent.eat_area.global_position
		Location.BED:
			return agent.sleep_area.global_position
		Location.COMPUTER:
			return agent.pwn_area.global_position
	return Vector2.ZERO


## Function to override
func can_execute() -> bool:
	return true # Is the action reasonable to consider


## Function to override
func is_finished() -> bool:
	return get_target_position().distance_squared_to(agent.global_position) < 25.0


func get_cost() -> int:
	return 1
