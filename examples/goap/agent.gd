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


extends Node2D


enum Location {
	OTHER,
	EAT_AREA,
	SLEEP_AREA,
	PWN_AREA,
}

const DEBUG_TEXT: String = \
"""[b]Plan[/b]: {plan}

[b]World States[/b]:
{world_states}

[b]Goals[/b]:
{goals}"""


@export var eat_area  : Node2D
@export var sleep_area: Node2D
@export var pwn_area  : Node2D

@export var speed: float = 2.0

var tierdness: float = 0.0:
	set(value):
		tierdness = clampf(value, 0.0, 20.0)
var hunger: float = 10.0:
	set(value):
		hunger = clampf(value, 0.0, 20.0)

@onready var planner: GOAPPlanner = $GOAPPlanner


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color.WHITE)


func _process(delta: float) -> void:
	# Update need values
	tierdness += 0.8 * delta
	hunger    += 0.8 * delta


func get_debug_text() -> String:
	var plan_string: String = ""
	for i: int in planner.get_plan_size():
		var action: GOAPAction = planner.get_planned_action(i)
		var current_action: bool = planner.get_current_action_index() == i
		if current_action:
			plan_string += "[color=green][i]"
		plan_string += action.name
		if current_action:
			plan_string += "[/i][/color]"
		if i + 1 != planner.get_plan_size():
			plan_string += " > "
	
	var world_state_string: String = ""
	var world_state: Dictionary = planner.get_local_world_state()
	for i: int in world_state.size():
		var ws: StringName = world_state.keys()[i]
		world_state_string += "%s: %s" % [ws, world_state[ws]]
		if i + 1 != world_state.size():
			world_state_string += "\n"
	
	var goals_string: String = ""
	for i: int in planner.get_goal_count():
		var goal: GOAPGoal = planner.get_goal(i)
		var goal_state: GOAPPlanner.GoalState = planner.get_goal_state(i)
		match goal_state:
			GOAPPlanner.GoalState.NOT_CONSIDERED:
				goals_string += "[color=gray]%s[/color]" % goal.name
			GOAPPlanner.GoalState.INVALID:
				goals_string += "[color=dark_red]%s[/color]: Invalid" % goal.name
			GOAPPlanner.GoalState.MET:
				goals_string += "[color=green]%s[/color]: Met" % goal.name
			GOAPPlanner.GoalState.CURRENT:
				goals_string += "> [color=dark_green][i]%s[/i][/color]: Current" % goal.name
			GOAPPlanner.GoalState.CURRENT_MET:
				goals_string += "> [color=green][i]%s[/i][/color]: Current (met)" % goal.name
		if i + 1 != planner.get_goal_count():
			goals_string += "\n"
	
	return DEBUG_TEXT.format({
		&"plan": plan_string,
		&"world_states": world_state_string,
		&"goals": goals_string,
	})


func is_tierd() -> bool:
	return tierdness > 15.0


func is_hungry() -> bool:
	return hunger > 15.0


func get_location() -> Location:
	if global_position.distance_squared_to(eat_area.global_position) < 25.0:
		return Location.EAT_AREA
	if global_position.distance_squared_to(sleep_area.global_position) < 25.0:
		return Location.SLEEP_AREA
	if global_position.distance_squared_to(pwn_area.global_position) < 25.0:
		return Location.PWN_AREA
	return Location.OTHER
