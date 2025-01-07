extends Node

#Attacker goes first which gives advantage but defender also gets bonuses
func unit_battle(attacker: base_unit, defender: base_unit) -> int:
	if defender.remove_manpower(attacker.get_fire_damage()):
		#kill unit
		return 0
	if defender.remove_morale(attacker.get_shock_damage()):
		#Retreat unit
		return 1
	if attacker.remove_manpower(defender.get_fire_damage()):
		#kill unit
		return 2
	if attacker.remove_morale(defender.get_shock_damage()):
		#Retreat unit
		return 3
	return -1
	
