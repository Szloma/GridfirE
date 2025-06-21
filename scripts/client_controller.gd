extends Node
const DEFAULT_SERVER_IP = "57.128.198.89" 
const PORT = 7001

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	
	#var peer = ENetMultiplayerPeer.new()
	var peer = WebSocketMultiplayerPeer.new()
	#var error = peer.create_client(address, PORT) "localhost"
	var error = peer.create_client("ws://" + DEFAULT_SERVER_IP+ ":" + str(PORT))
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func stop():
	multiplayer.multiplayer_peer=null
