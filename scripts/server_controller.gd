extends Node
const PORT = 7001
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20
var players = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	


func start():
	stop()
	
	#var peer = ENetMultiplayerPeer.new()
	var peer = WebSocketMultiplayerPeer.new()
	var error =  peer.create_server(PORT)
	#var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print("Server started ", DEFAULT_SERVER_IP, ":", PORT)

func disconnect_peer(id):
	if multiplayer.get_peers().has(id):
		multiplayer.multiplayer_peer.disconnect_peer(id)
	
func stop():
	#for peer in multiplayer.get_peers():
		#multiplayer.multiplayer_peer.disconnect_peer(peer)
	multiplayer.multiplayer_peer = null
	print("Server stopped")

@rpc("any_peer","reliable")
func set_host_id():
	Global.set_host_id(multiplayer.get_remote_sender_id())
	print("Peer ", multiplayer.get_unique_id(), " received host id ", Global.host_id)
	pass

func _on_peer_connected(peer):
	if multiplayer.is_server():
		set_host_id.rpc_id(peer)
	print("Peer connected: ", peer)
func _on_peer_disconnected(peer):
	print("Peer disconnected: ", peer)
