extends Node

#Attacker goes first which gives advantage but defender also gets bonuses
func unit_battle(attacker: base_unit, defender: base_unit) -> int:
	var def_fire = defender.get_fire_damage()
	var def_shock = defender.get_shock_damage()
	
	if defender.remove_manpower(attacker.get_fire_damage()):
		#kill unit
		return 0
	if defender.remove_morale(attacker.get_shock_damage()):
		#Retreat unit
		return 1
	if attacker.remove_manpower(def_fire):
		#kill unit
		return 2
	if attacker.remove_morale(def_shock):
		#Retreat unit
		return 3
	return -1
	
