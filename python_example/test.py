import requests

print("=" * 50)
print("Brotato API Test")
print("=" * 50)

base = "http://localhost:8082"

# 1. Health
print("\n[1] Health check...")
try:
    r = requests.get(base + "/health", timeout=2)
    print("[OK]", r.json())
except Exception as e:
    print("[FAIL]", e)
    print("Make sure game is running with mod loaded!")

# 2. Stats
print("\n[2] Player stats...")
try:
    r = requests.get(base + "/api/stats", timeout=2)
    print("[OK]", r.json())
except Exception as e:
    print("[FAIL]", e)

# 3. Enemies
print("\n[3] Enemies...")
try:
    r = requests.get(base + "/api/enemies", timeout=2)
    print("[OK]", r.json())
except Exception as e:
    print("[FAIL]", e)

# 4. Wave
print("\n[4] Wave info...")
try:
    r = requests.get(base + "/api/wave", timeout=2)
    print("[OK]", r.json())
except Exception as e:
    print("[FAIL]", e)

# 5. Items
print("\n[5] Items...")
try:
    r = requests.get(base + "/api/items", timeout=2)
    print("[OK]", r.json())
except Exception as e:
    print("[FAIL]", e)

# 6. All entities
print("\n[6] All entities...")
try:
    r = requests.get(base + "/api/entities", timeout=2)
    d = r.json()
    print("[OK] count:", d.get("count", 0))
except Exception as e:
    print("[FAIL]", e)

print("\n" + "=" * 50)
print("Done!")
