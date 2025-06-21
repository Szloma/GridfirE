extends Node

signal health_updated(val,max)
signal ammo_count_updated(val,max)
signal died
signal revived
signal start_revive_timer(tm:Timer)
signal leaderboard
signal ingame_menu(val)
signal disconnect
signal close_server
signal coin_updated(val)
signal update_coin(val) #From shop to player
signal shop(val, coins) 
signal buy_weapon(id)
signal buy_hp(amount)
signal buy_ammo(amount)
signal close_shop
signal hud(val)
var host_id :=0

func get_host_id():
	return host_id
func set_host_id(id):
	host_id = id
