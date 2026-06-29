# Brotato HTTP API - 完整文档

<div align="center">

**🥔 Simple_HTTP_Test Mod v1.0.0**

通过 HTTP 接口实时控制和获取土豆兄弟游戏数据

[基础信息](#-基础信息) | [快速开始](#-快速开始) | [API 参考](#api-参考) | [示例代码](#-示例代码) | [常见问题](#-常见问题)

</div>

---

## 📌 基础信息

| 属性 | 值 |
|------|-----|
| **服务地址** | `http://localhost:8082` |
| **协议** | HTTP/1.1 (RESTful) |
| **数据格式** | JSON |
| **认证方式** | 无（仅限本地访问）|
| **默认端口** | 8082 |
| **并发支持** | 多客户端连接 |

### ⚠️ 安全提示
> **重要**: 本 API 仅设计用于本地开发测试，**请勿暴露到公网**。
> 
> - 无身份验证机制
> - 具有完整的游戏控制权限
> - 建议仅在 `127.0.0.1` 或 `localhost` 访问

---

## 🚀 快速开始

### 1. 启动模组
启动游戏后，控制台应显示：
```
[BrotatoAPI] ================================
[BrotatoAPI] Brotato API Server v2.0
[BrotatoAPI] ================================
[BrotatoAPI] OK - HTTP port: 8082
[BrotatoAPI] URL: http://localhost:8082
```

### 2. 测试连接
```bash
# Windows PowerShell
Invoke-RestMethod http://localhost:8082/

# Linux/Mac
curl http://localhost:8082/

# 或浏览器直接访问
# http://localhost:8082/
```

**预期返回:**
```json
{"status": "ok", "service": "brotato-api"}
```

---

## 📡 API 参考

### 概览

所有请求返回统一 JSON 格式：
```json
{
  "success": true/false,
  "data": {...},      // 成功时的数据
  "error": "...",     // 失败时的错误信息
  "count": 10          // 列表数据的项目数（可选）
}
```

#### 状态码说明
| success | 含义 |
|---------|------|
| `true` | 请求成功 |
| `false` | 请求失败，查看 error 字段 |

---

## 🔍 查询接口 (GET)

### 1. 健康检查

**端点**: `GET /` 或 `GET /health`

**用途**: 测试服务是否正常运行

**响应示例**:
```json
{
  "status": "ok",
  "service": "brotato-api"
}
```

---

### 2. 获取玩家统计数据

**端点**: `GET /api/stats`

**用途**: 获取玩家当前的核心属性

**前置条件**: 需要已开始游戏（进入关卡）

**响应字段**:

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `health` | float | 当前血量 | `100.0` |
| `level` | int | 当前等级 | `5` |
| `xp` | int | 当前经验值 | `2500` |
| `gold` | int | 当前金币 | `150` |
| `weapons_count` | int | 已装备武器数量 | `3` |
| `items_count` | int | 已装备物品数量 | `12` |

**成功响应**:
```json
{
  "success": true,
  "data": {
    "health": 85.5,
    "level": 7,
    "xp": 3200,
    "gold": 200,
    "weapons_count": 4,
    "items_count": 15
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "RunData not found - start a game first"
}
```

---

### 3. 获取敌人列表

**端点**: `GET /api/enemies`

**用途**: 获取当前场景中所有存活敌人的详细信息

**前置条件**: 需要在波次进行中（有敌人存在）

**响应字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `x` | float | X 坐标位置 |
| `y` | float | Y 坐标位置 |
| `health` | float | 当前剩余血量 |
| `max_health` | float | 最大血量 |
| `speed` | float | 移动速度 |
| `damage` | float | 攻击伤害值 |
| `enemy_id` | string/int | 敌人类型 ID |

**成功响应**:
```json
{
  "success": true,
  "count": 3,
  "enemies": [
    {
      "x": -150.5,
      "y": 200.3,
      "health": 30.0,
      "max_health": 50.0,
      "speed": 100.0,
      "damage": 10.0,
      "enemy_id": "zombie_basic"
    },
    {
      "x": 300.0,
      "y": -100.0,
      "health": 80.0,
      "max_health": 80.0,
      "speed": 150.0,
      "damage": 20.0,
      "enemy_id": "boss_fast"
    }
  ]
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "Entities not found - start a wave first"
}
```

---

### 4. 获取所有实体

**端点**: `GET /api/entities`

**用途**: 扫描场景中的所有实体（玩家、敌人、其他对象）

**响应字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `x` | float | X 坐标 |
| `y` | float | Y 坐标 |
| `class` | string | Godot 类名 |
| `type` | string | 类型: `player`/`enemy`/`other` |
| `dead` | bool | 是否死亡（仅 enemy 有此字段）|

**成功响应**:
```json
{
  "success": true,
  "count": 5,
  "entities": [
    {
      "x": 0.0,
      "y": 0.0,
      "class": "Player",
      "type": "player"
    },
    {
      "x": -100.0,
      "y": 50.0,
      "class": "Enemy",
      "type": "enemy",
      "dead": false
    }
  ]
}
```

---

### 5. 获取波次信息

**端点**: `GET /api/wave`

**用途**: 当前游戏进度（第几波/总共几波）

**响应字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `current_wave` | int | 当前波次（0 表示未开始）|
| `total_waves` | int | 总波次数（固定为 20）|

**成功响应**:
```json
{
  "success": true,
  "data": {
    "current_wave": 12,
    "total_waves": 20
  }
}
```

---

### 6. 获取物品列表

**端点**: `GET /api/items`

**用途**: 玩家当前装备的所有物品和武器

**响应字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `items` | array | 物品名称字符串数组 |
| `count` | int | 总物品数量 |

**成功响应**:
```json
{
  "success": true,
  "count": 18,
  "items": [
    "[Weapon] Machete",
    "[Item] Speed Boots",
    "[Item] Health Ring",
    "[Weapon] SMG"
  ]
}
```

---

### 7. 获取玩家精确位置

**端点**: `GET /api/player_pos`

**用途**: 获取玩家的精确坐标和状态

**响应字段**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `x` | float | X 坐标 |
| `y` | float | Y 坐标 |
| `health` | float | 当前血量 |
| `max_health` | float | 最大血量 |
| `speed` | float | 当前速度 |
| `dead` | bool | 是否死亡 |

**成功响应**:
```json
{
  "success": true,
  "data": {
    "x": 25.5,
    "y": -10.3,
    "health": 90.0,
    "max_health": 100.0,
    "speed": 120.0,
    "dead": false
  }
}
```

---

## 🎮 控制接口 (POST)

> ⚠️ **注意**: 控制接口会接管玩家的输入！使用后记得调用 `/api/release` 释放控制权。

---

### 8. 控制移动

**端点**: `POST /api/move`

**用途**: 让角色朝指定方向移动

**请求参数** (二选一):

#### 方式 A: 方向字符串
```json
{"direction": "up"}
```

支持的方向值:

| 方向 | 说明 |
|------|------|
| `up` | 上 |
| `down` | 下 |
| `left` | 左 |
| `right` | 右 |
| `up_left` | 左上 |
| `up_right` | 右上 |
| `down_left` | 左下 |
| `down_right` | 右下 |
| `stop` | 停止移动 |

#### 方式 B: 向量坐标
```json
{"x": 1.0, "y": 0.5}
```

- 数值会自动归一化 (normalized)
- `x=1, y=0` = 向右
- `x=-1, y=-1` = 向左上

**成功响应**:
```json
{
  "success": true,
  "dx": 0.0,
  "dy": -1.0
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "Unknown direction: invalid_dir"
}
```

---

### 9. 停止移动

**端点**: `POST /api/stop`

**用途**: 停止角色移动（但保持 Bot 控制状态）

**请求体**: 无需参数

**响应**:
```json
{
  "success": true,
  "message": "Movement stopped, bot still in control"
}
```

**使用场景**: 想让角色静止但继续由 Bot 控制（例如瞄准时）

---

### 10. 控制瞄准

**端点**: `POST /api/aim`

**用途**: 自动瞄准距离目标位置最近的敌人

**请求参数**:
```json
{
  "x": 100.0,
  "y": -50.0
}
```

**工作原理**:
1. 接收目标坐标 `(x, y)`
2. 在所有存活敌人中找到距离该点最近的敌人
3. 让玩家自动瞄准该敌人

**成功响应**:
```json
{
  "success": true,
  "message": "Aiming at nearest enemy to target"
}
```

**使用示例**:
```python
# 瞄准最近的敌人（向右方寻找）
requests.post("http://localhost:8082/api/aim", json={"x": 500, "y": 0})
```

---

### 11. 释放控制权 ⭐ 重要

**端点**: `POST /api/release`

**用途**: **释放所有 Bot 控制，恢复玩家手动输入**

**请求体**: 无需参数

**响应**:
```json
{
  "success": true,
  "message": "Bot control released, player input restored"
}
```

**⚠️ 必须调用**: 使用完控制功能后必须调用此接口，否则玩家无法操作！

---

## 💻 示例代码

### Python 完整示例

```python
import requests
import time
import json

BASE_URL = "http://localhost:8082"

class BrotatoBot:
    def __init__(self):
        self.session = requests.Session()
    
    def health_check(self):
        """检查服务是否在线"""
        resp = self.session.get(f"{BASE_URL}/")
        return resp.json()
    
    def get_stats(self):
        """获取玩家状态"""
        resp = self.session.get(f"{BASE_URL}/api/stats")
        data = resp.json()
        if data["success"]:
            return data["data"]
        return None
    
    def get_enemies(self):
        """获取敌人列表"""
        resp = self.session.get(f"{BASE_URL}/api/enemies")
        data = resp.json()
        if data["success"]:
            return data["enemies"]
        return []
    
    def move(self, direction="up"):
        """移动角色"""
        self.session.post(f"{BASE_URL}/api/move", 
                         json={"direction": direction})
    
    def move_to(self, x, y):
        """按向量移动"""
        self.session.post(f"{BASE_URL}/api/move", 
                         json={"x": x, "y": y})
    
    def stop(self):
        """停止移动"""
        self.session.post(f"{BASE_URL}/api/stop")
    
    def aim_at(self, x, y):
        """瞄准指定区域最近敌人"""
        self.session.post(f"{BASE_URL}/api/aim", 
                         json={"x": x, "y": y})
    
    def release(self):
        """释放控制权（重要！）"""
        self.session.post(f"{BASE_URL}/api/release")


# 使用示例
if __name__ == "__main__":
    bot = BrotatoBot()
    
    # 1. 检查连接
    print("✅ 服务状态:", bot.health_check())
    
    # 2. 获取状态
    stats = bot.get_stats()
    if stats:
        print(f"❤️ 血量: {stats['health']} | 等级: {stats['level']}")
    
    # 3. 获取敌人
    enemies = bot.get_enemies()
    print(f"👾 当前敌人数量: {len(enemies)}")
    
    # 4. 简单 AI 循环（示例）
    try:
        for i in range(10):
            enemies = bot.get_enemies()
            if enemies:
                # 找最近的敌人
                nearest = min(enemies, key=lambda e: e["x"]**2 + e["y"]**2)
                # 远离敌人（简单逃跑逻辑）
                dx = -nearest["x"]
                dy = -nearest["y"]
                bot.move_to(dx, dy)
            else:
                bot.stop()
            
            time.sleep(0.1)
    finally:
        # 5. 必须释放控制！
        bot.release()
        print("✅ 控制权已释放")
```

---

### cURL 快速测试

```bash
# 健康检查
curl http://localhost:8082/

# 获取状态
curl http://localhost:8082/api/stats

# 获取敌人
curl http://localhost:8082/api/enemies

# 移动控制
curl -X POST http://localhost:8082/api/move \
  -H "Content-Type: application/json" \
  -d '{"direction":"up"}'

# 释放控制
curl -X POST http://localhost:8082/api/release
```

---

### JavaScript / Node.js 示例

```javascript
const BASE = 'http://localhost:8082';

async function getStats() {
  const res = await fetch(`${BASE}/api/stats`);
  const data = await res.json();
  console.log('玩家状态:', data);
  return data;
}

async function move(direction) {
  await fetch(`${BASE}/api/move`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({direction})
  });
}

async function release() {
  await fetch(`${BASE}/api/release`, {method: 'POST'});
  console.log('控制权已释放');
}

// 使用
(async () => {
  await getStats();
  await move('right');
  setTimeout(() => release(), 2000);
})();
```

---

## ❓ 常见问题

### Q1: 连接被拒绝 (Connection Refused)
**A**: 
- 确认游戏已启动且模组已加载
- 查看游戏控制台是否有 `[BrotatoAPI] OK` 信息
- 确认端口 8082 未被占用

### Q2: 返回 "RunData not found"
**A**: 
- 需要先开始一局游戏（进入关卡）
- 在主菜单时无法获取游戏数据

### Q3: 角色无法手动控制
**A**: 
- 可能是之前的 Bot 控制未释放
- 调用 `POST /api/release` 即可恢复
- 或重启游戏

### Q4: 如何修改端口？
**A**: 
- 编辑 `mod_main.gd` 文件
- 修改第 3 行: `const PORT = 8082`
- 改为你想要的端口号

### Q5: 可以同时多个客户端连接吗？
**A**: 
- ✅ 可以，服务器支持多客户端
- 但控制指令可能冲突，建议单一客户端控制

### Q6: 数据更新频率？
**A**: 
- 查询接口: 实时（每次请求都返回最新数据）
- 控制接口: 即时生效
- 建议轮询间隔 ≥ 50ms 避免性能问题

---
## 🔧 高级用法

### AI 自动战斗示例框架

```python
import numpy as np

class AIBot:
    def __init__(self, api):
        self.api = api
    
    def decide_action(self, player_pos, enemies):
        """
        简单的决策逻辑:
        - 如果敌人靠近 -> 远离
        - 如果血量低 -> 更加保守
        - 否则 -> 随机移动收集物品
        """
        if not enemies:
            return "stop", None
        
        # 计算威胁
        threats = []
        for e in enemies:
            dist = np.sqrt((e['x'])**2 + (e['y'])**2)
            threats.append((dist, e))
        
        # 最近敌人
        nearest_dist, nearest_enemy = min(threats)
        
        if nearest_dist < 150:  # 危险距离
            # 远离敌人
            dx = -nearest_enemy['x']
            dy = -nearest_enemy['y']
            return "vector", (dx, dy)
        else:
            # 安全，随机探索
            import random
            directions = ['up', 'down', 'left', 'right']
            return "direction", random.choice(directions)
    
    def run_loop(self, duration_seconds=60):
        """运行 AI 循环"""
        import time
        start = time.time()
        try:
            while time.time() - start < duration_seconds:
                stats = self.api.get_stats()
                if stats and stats['health'] > 0:
                    enemies = self.api.get_enemies()
                    action_type, value = self.decide_action(
                        None, enemies
                    )
                    
                    if action_type == "direction":
                        self.api.move(value)
                    elif action_type == "vector":
                        self.api.move_to(value[0], value[1])
                    
                    time.sleep(0.05)  # 20 FPS
                else:
                    break
        finally:
            self.api.release()
```

---

## 📊 性能与限制

| 项目 | 限制 |
|------|------|
| 最大并发连接 | 无硬性限制（取决于系统）|
| 请求频率 | 建议 ≤ 20 requests/sec |
| 数据延迟 | < 1 frame (~16ms @ 60FPS) |
| 控制响应 | 即时（下一帧生效）|
| 带宽占用 | ~1-5 KB per request |

---

## 🛠️ 故障排查

### 日志调试
在游戏中查看控制台输出：
```
[BrotatoAPI] OK - HTTP port: 8082
```

如果看到：
```
[BrotatoAPI] FAIL - port 8082
```
→ 端口被占用，关闭其他程序或修改端口

### 网络工具测试
```bash
# 测试端口是否监听
netstat -an | findstr 8082

# 测试连通性
telnet localhost 8082
```

---

## 📝 更新日志

### v1.0.0 (2026-06-21)
- ✨ 初始版本发布
- ✨ 11 个 API 端点
- ✨ 完整的查询和控制功能
- ✨ 多客户端支持
- 📝 完整 API 文档

---

## 🤝 贡献指南

欢迎提交 Issue 和 PR！

- 发现 Bug → 提 Issue
- 新功能建议 → 讨论 PR
- 文档改进 → 直接 PR

---

## 📄 开源协议

本项目采用 [GPLv3](LICENSE) 协议开源

---

<div align="center">

**Made with ❤️ for the Brotato Community**

如有问题，欢迎提 Issue 或联系作者！

</div>