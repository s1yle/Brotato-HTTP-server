extends Node

const PORT = 8082

var server: = TCP_Server.new()
var clients: Array = []
var enabled: = false

# Bot control state
var _bot_active: = false
var _bot_move_dir: = Vector2.ZERO
var _bot_aim_pos: = Vector2.ZERO

func _ready():
	print("[BrotatoAPI] ================================")
	print("[BrotatoAPI] Brotato API Server v2.0")
	print("[BrotatoAPI] ================================")
	
	var err = server.listen(PORT)
	if err == OK:
		print("[BrotatoAPI] OK - HTTP port: %d" % PORT)
		enabled = true
	else:
		print("[BrotatoAPI] FAIL - port %d" % PORT)
		return
	
	print("[BrotatoAPI] URL: http://localhost:%d" % PORT)
	print("[BrotatoAPI] ================================")

# Updates every frame
func _process(delta):
	if not enabled:
		return
	
	# Apply bot movement every frame
	_apply_bot_control()
	
	# Accept new connections
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append(client)
	
	# Process client requests
	var to_remove = []
	for i in range(clients.size()):
		var client = clients[i]
		
		if not client.is_connected_to_host():
			to_remove.append(i)
			continue
		
		var bytes = client.get_available_bytes()
		if bytes > 0:
			var request = client.get_utf8_string(bytes)
			var body = _handle_request(request)
			_send_json(client, body)
			client.disconnect_from_host()
			to_remove.append(i)
	
	# Cleanup
	for i in range(to_remove.size() - 1, -1, -1):
		clients.remove(i)

# ════════════════════════════════════════
# Bot control - applied every frame
# ════════════════════════════════════════

func _apply_bot_control():
	if not _bot_active:
		return
	
	var player = _get_player()
	if player == null:
		return
	if not player._can_move or player.dead:
		return
	
	# Lock movement to bot control
	player._move_locked = true
	player._current_movement = _bot_move_dir

func _release_bot_control():
	_bot_active = false
	_bot_move_dir = Vector2.ZERO
	var player = _get_player()
	if player != null and is_instance_valid(player):
		player._move_locked = false
		player._current_movement = Vector2.ZERO

# ════════════════════════════════════════
# HTTP request handling
# ════════════════════════════════════════

func _handle_request(request: String) -> String:
	var lines = request.split("\r\n")
	if lines.size() < 1:
		return '{"error":"Bad Request"}'
	
	var parts = lines[0].split(" ")
	if parts.size() < 2:
		return '{"error":"Bad Request"}'
	
	var method = parts[0]
	var path = parts[1]
	
	# Parse POST body
	var post_data = {}
	if method == "POST":
		var body_start = request.find("\r\n\r\n")
		if body_start >= 0:
			var body_str = request.right(body_start + 4)
			if body_str.length() > 0:
				var json_result = JSON.parse(body_str)
				if json_result.error == OK:
					post_data = json_result.result
	
	# GET routes
	if path == "/" or path == "/health":
		return JSON.print({"status": "ok", "service": "brotato-api"})
	
	if path == "/api/stats":
		return _api_stats()
	
	if path == "/api/enemies":
		return _api_enemies()
	
	if path == "/api/entities":
		return _api_entities()
	
	if path == "/api/wave":
		return _api_wave()
	
	if path == "/api/items":
		return _api_items()
	
	if path == "/api/player_pos":
		return _api_player_pos()
	
	# POST routes - bot control
	if path == "/api/move":
		return _api_move(post_data)
	
	if path == "/api/stop":
		return _api_stop()
	
	if path == "/api/aim":
		return _api_aim(post_data)
	
	if path == "/api/release":
		return _api_release()
	
	return JSON.print({"error": "Not found: " + path})

func _send_json(client: StreamPeerTCP, body: String):
	var response = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: application/json\r\n"
	response += "Connection: close\r\n"
	response += "Content-Length: " + str(body.length()) + "\r\n"
	response += "\r\n"
	response += body
	client.put_data(response.to_utf8())

# ════════════════════════════════════════
# Safe game reference helpers
# ════════════════════════════════════════

func _get_run_data():
	var rd = get_node_or_null("/root/RunData")
	if rd != null and is_instance_valid(rd):
		return rd
	return null

func _get_main():
	var m = get_node_or_null("/root/Main")
	if m != null and is_instance_valid(m):
		return m
	return null

func _get_player():
	var ec = _get_entities()
	if ec == null:
		return null
	for child in ec.get_children():
		if is_instance_valid(child) and child is Player and not child.dead:
			return child
	return null

func _get_entities():
	var m = _get_main()
	if m == null:
		return null
	var e = m.get_node_or_null("%Entities")
	if e != null and is_instance_valid(e):
		return e
	return null

# ════════════════════════════════════════
# Query API implementations
# ════════════════════════════════════════

func _api_stats() -> String:
	var rd = _get_run_data()
	if rd == null:
		return JSON.print({"success": false, "error": "RunData not found - start a game first"})
	
	var pd = rd.players_data
	if pd.size() == 0:
		return JSON.print({"success": false, "error": "No player data"})
	
	var p = pd[0]
	if not is_instance_valid(p):
		return JSON.print({"success": false, "error": "Player data invalid"})
	
	var data = {}
	data["health"] = p.current_health
	data["level"] = p.current_level
	data["xp"] = int(p.current_xp)
	data["gold"] = p.gold
	data["weapons_count"] = p.weapons.size()
	data["items_count"] = p.items.size()
	
	return JSON.print({"success": true, "data": data})

func _api_enemies() -> String:
	var ec = _get_entities()
	if ec == null:
		return JSON.print({"success": false, "error": "Entities not found - start a wave first"})
	
	var enemies = []
	for child in ec.get_children():
		if not is_instance_valid(child):
			continue
		if child is Enemy and not child.dead:
			var e = {}
			e["x"] = child.global_position.x
			e["y"] = child.global_position.y
			e["health"] = child.current_stats.health
			e["max_health"] = child.max_stats.health
			e["speed"] = child.current_stats.speed
			e["damage"] = child.current_stats.damage
			e["enemy_id"] = child.enemy_id
			enemies.append(e)
	
	return JSON.print({"success": true, "count": enemies.size(), "enemies": enemies})

func _api_entities() -> String:
	var ec = _get_entities()
	if ec == null:
		return JSON.print({"success": false, "error": "Entities not found"})
	
	var entities = []
	for child in ec.get_children():
		if not is_instance_valid(child):
			continue
		var e = {}
		e["x"] = child.global_position.x
		e["y"] = child.global_position.y
		e["class"] = child.get_class()
		if child is Enemy:
			e["type"] = "enemy"
			e["dead"] = child.dead
		elif child is Player:
			e["type"] = "player"
		else:
			e["type"] = "other"
		entities.append(e)
	
	return JSON.print({"success": true, "count": entities.size(), "entities": entities})

func _api_wave() -> String:
	var m = _get_main()
	if m == null:
		return JSON.print({"success": false, "error": "Main not found"})
	
	var data = {}
	var wm = m.get_node_or_null("%WaveManager")
	if wm != null and is_instance_valid(wm):
		data["current_wave"] = wm.current_wave
	else:
		data["current_wave"] = 0
	data["total_waves"] = 20
	
	return JSON.print({"success": true, "data": data})

func _api_items() -> String:
	var rd = _get_run_data()
	if rd == null:
		return JSON.print({"success": false, "error": "RunData not found"})
	
	var pd = rd.players_data
	if pd.size() == 0:
		return JSON.print({"success": false, "error": "No player data"})
	
	var p = pd[0]
	var items = []
	for item in p.items:
		items.append(str(item))
	for w in p.weapons:
		items.append(str(w))
	
	return JSON.print({"success": true, "count": items.size(), "items": items})

func _api_player_pos() -> String:
	var player = _get_player()
	if player == null:
		return JSON.print({"success": false, "error": "Player not found"})
	
	var data = {}
	data["x"] = player.global_position.x
	data["y"] = player.global_position.y
	data["health"] = player.current_stats.health
	data["max_health"] = player.max_stats.health
	data["speed"] = player.current_stats.speed
	data["dead"] = player.dead
	
	return JSON.print({"success": true, "data": data})

# ════════════════════════════════════════
# Control API implementations
# ════════════════════════════════════════

func _api_move(data: Dictionary) -> String:
	var player = _get_player()
	if player == null:
		return JSON.print({"success": false, "error": "Player not found"})
	
	# Support both direction string and x/y vector
	var dx = 0.0
	var dy = 0.0
	
	if data.has("direction"):
		# Direction string: up/down/left/right + combos
		var dir = str(data["direction"]).to_lower()
		if dir == "up":
			dy = -1.0
		elif dir == "down":
			dy = 1.0
		elif dir == "left":
			dx = -1.0
		elif dir == "right":
			dx = 1.0
		elif dir == "up_left":
			dx = -1.0; dy = -1.0
		elif dir == "up_right":
			dx = 1.0; dy = -1.0
		elif dir == "down_left":
			dx = -1.0; dy = 1.0
		elif dir == "down_right":
			dx = 1.0; dy = 1.0
		elif dir == "stop":
			dx = 0.0; dy = 0.0
		else:
			return JSON.print({"success": false, "error": "Unknown direction: " + dir})
	elif data.has("x") and data.has("y"):
		dx = float(data["x"])
		dy = float(data["y"])
	else:
		return JSON.print({"success": false, "error": "Need 'direction' or 'x'+'y'"})
	
	var move_vec = Vector2(dx, dy).normalized()
	_bot_move_dir = move_vec
	_bot_active = true
	
	return JSON.print({"success": true, "dx": move_vec.x, "dy": move_vec.y})

func _api_stop() -> String:
	_bot_move_dir = Vector2.ZERO
	# Keep bot active but zero movement (player stays still, bot still in control)
	return JSON.print({"success": true, "message": "Movement stopped, bot still in control"})

func _api_release() -> String:
	_release_bot_control()
	return JSON.print({"success": true, "message": "Bot control released, player input restored"})

func _api_aim(data: Dictionary) -> String:
	var player = _get_player()
	if player == null:
		return JSON.print({"success": false, "error": "Player not found"})
	
	# Find nearest enemy to target position
	var target_x = 0.0
	var target_y = 0.0
	if data.has("x") and data.has("y"):
		target_x = float(data["x"])
		target_y = float(data["y"])
	else:
		return JSON.print({"success": false, "error": "Need x and y"})
	
	var target_pos = Vector2(target_x, target_y)
	
	# Find the actual enemy node closest to target position
	var ec = _get_entities()
	var best_enemy = null
	var best_dist = 999999.0
	if ec != null:
		for child in ec.get_children():
			if not is_instance_valid(child):
				continue
			if child is Enemy and not child.dead:
				var d = child.global_position.distance_squared_to(target_pos)
				if d < best_dist:
					best_dist = d
					best_enemy = child
	
	if best_enemy == null:
		return JSON.print({"success": false, "error": "No enemy found near target"})
	
	# Set weapon target as [enemy_node, distance] array
	var weapons = player.current_weapons
	var aimed = 0
	for weapon in weapons:
		if is_instance_valid(weapon):
			var dist_to_enemy = weapon.global_position.distance_to(best_enemy.global_position)
			weapon._current_target = [best_enemy, dist_to_enemy]
			aimed += 1
	
	return JSON.print({"success": true, "aimed_weapons": aimed, "enemy_id": best_enemy.enemy_id})

func _exit_tree():
	_release_bot_control()
	server.stop()
	print("[BrotatoAPI] Server stopped")
