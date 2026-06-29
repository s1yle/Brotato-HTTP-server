"""
Brotato Bot v2 - auto-move and auto-aim
"""

import requests
import math
import time

BASE = "http://localhost:8082"

def get(path):
    try:
        r = requests.get(BASE + path, timeout=2)
        return r.json()
    except:
        return None

def post(path, data):
    try:
        r = requests.post(BASE + path, json=data, timeout=2)
        return r.json()
    except:
        return None

def dist(x1, y1, x2, y2):
    return math.sqrt((x1-x2)**2 + (y1-y2)**2)

print("=" * 50)
print("Brotato Bot v2 - Auto Move & Aim")
print("=" * 50)

# Wait for server
print("\nWaiting for server...")
while True:
    r = get("/health")
    if r and r.get("status") == "ok":
        print("[OK] Server connected!")
        break
    time.sleep(1)

# Main loop
print("\nBot running... Ctrl+C to stop\n")

try:
    while True:
        # 1. Get player position
        pos = get("/api/player_pos")
        if not pos or not pos.get("success"):
            time.sleep(0.5)
            continue
        
        px = pos["data"]["x"]
        py = pos["data"]["y"]
        hp = pos["data"]["health"]
        max_hp = pos["data"]["max_health"]
        
        # 2. Get enemies
        enemies = get("/api/enemies")
        if not enemies or not enemies.get("success") or enemies.get("count", 0) == 0:
            # No enemies - stop moving
            post("/api/stop", {})
            if int(time.time()) % 3 == 0:
                print("[SHOP] HP:%d/%d - waiting for next wave..." % (hp, max_hp))
            time.sleep(0.5)
            continue
        
        enemy_list = enemies["enemies"]
        
        # 3. Find nearest enemy
        nearest = None
        min_dist = 999999
        for e in enemy_list:
            d = dist(px, py, e["x"], e["y"])
            if d < min_dist:
                min_dist = d
                nearest = e
        
        if nearest is None:
            time.sleep(0.1)
            continue
        
        # 4. Calculate movement direction
        dx = nearest["x"] - px
        dy = nearest["y"] - py
        d = max(min_dist, 1)
        
        # Kite strategy: stay at safe distance
        SAFE_DIST = 150  # Stay this far from enemies
        
        if min_dist < SAFE_DIST - 30:
            # Too close - move away
            move_x = -dx / d
            move_y = -dy / d
            action = "RETREAT"
        elif min_dist > SAFE_DIST + 50:
            # Too far - move closer
            move_x = dx / d
            move_y = dy / d
            action = "APPROACH"
        else:
            # Good distance - strafe
            move_x = -dy / d
            move_y = dx / d
            action = "STRAFE"
        
        # 5. Send move command
        post("/api/move", {"x": move_x, "y": move_y})
        
        # 6. Send aim command (aim at nearest enemy)
        post("/api/aim", {"x": nearest["x"], "y": nearest["y"]})
        
        # 7. Print status
        print("[BOT] HP:%d/%d | Enemies:%d | %s dist:%d | pos:(%d,%d)" % (
            hp, max_hp, len(enemy_list), action, int(min_dist), int(px), int(py)
        ))
        
        time.sleep(0.001)

except KeyboardInterrupt:
    print("\n\nReleasing bot control...")
    post("/api/release", {})
    print("Bot stopped. Player control restored.")
