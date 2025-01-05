class_name base_unit extends Node

#How much manpower the unit has
var manpower

var morale
#How fast a unit can move
var speed
#The amount of supplies the unit has
var organization

#The morale damage a unit does
var shock 
#The general damage
var firepower

#Morale defense, defense in general
var cohesion
#The disipline and skill of the unit
var experience
#The rate at which a unit gains experience
#level 0 - inexperienced, 0 - 200
#level 1 - trained,       200 - 500
#level 2 - experienced,   500 - 1000
#level 3 - expert,        1000 - 2000
#level 4 - verteran,      2000 - 5000
#level 5 - elite,         5000 - ∞
var experience_gain
#The bonus to experience_gain when in battle
var battle_multiple
#The specification, infantry, cav, ect. the y atlas
#Infantry, Calvary, officer, engineer, artillery, 
var combat_arm
#The actual type line infantry, mechanized infantry, ect. the x atlas
var specific_type
