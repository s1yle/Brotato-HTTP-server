# Brotato HTTP API Mod

通过 RESTful API 实时控制和获取《土豆兄弟》游戏数据。让 Claude Code、Copilot、Cursor 等生成式 AI 直接操控角色，实现自动走位、自动瞄准、自动刷关。

## 安装

在 Steam 创意工坊订阅本模组，并在游戏内 Mod Loader 中启用。也可手动解压到 Mods 目录。

## 快速开始

启动游戏并进入任意对局，HTTP 服务器即运行在 `http://localhost:8082`。

```bash
curl http://localhost:8082/
# {"status":"ok","service":"brotato-api"}
```

## API 接口

### 查询（GET）

- `/api/stats` — 玩家血量/等级/金币/装备数量
- `/api/enemies` — 敌人位置/血量/伤害/速度
- `/api/player_pos` — 玩家坐标与速度
- `/api/wave` — 当前波次
- `/api/items` — 装备物品列表
- `/api/entities` — 场景实体扫描

### 控制（POST）

- `/api/move` — 移动（`direction` 或 `x,y`）
- `/api/aim` — 瞄准指定坐标（`x,y`）
- `/api/stop` — 停止移动
- `/api/release` — **释放控制权（必须调用）**

> 更详细的接口说明请查阅模组目录内的 API.md 文件  
>（订阅后位于 mods-unpacked/Wecraft-Brotato_HTTP_API/API.md）。  

## 与生成式 AI 协同

将以下信息丢给 Claude Code、Copilot、Cursor 等工具，AI 就能直接操控游戏：

```
你是一个土豆兄弟 AI 玩家。可用接口：
- GET localhost:8082/api/enemies → 敌人列表
- POST localhost:8082/api/move  参数 {"x": float, "y": float}
- POST localhost:8082/api/release
每 100ms 向远离最近敌人的方向移动。
```

模组内 `python_example` 目录提供了可直接运行的 Python 代码，方便交给 AI 修改和扩展。

## Python 示例

```python
import requests
BASE = "http://localhost:8082"

# 获取状态
stats = requests.get(f"{BASE}/api/stats").json()
print(stats)

# 向上移动
requests.post(f"{BASE}/api/move", json={"direction": "up"})

# 必须释放控制权
requests.post(f"{BASE}/api/release")
```

更多完整示例见订阅目录下的 `python_example` 文件夹。

## 注意事项

- 服务器仅监听 127.0.0.1，切勿暴露到公网。
- 移动/瞄准后务必调用 `/api/release`，否则键盘手柄输入失效。
- 请求间隔建议 ≥ 50ms，避免影响游戏流畅度。

## 配置

编辑 `mod_main.gd` 中的 `const PORT = 8082` 可更换端口，修改后重启游戏生效。

## 许可

本项目以 GPLv3 协议开源。

## 链接

- GitHub：https://github.com/s1yle/Brotato-HTTP-server
- Steam 创意工坊：https://steamcommunity.com/sharedfiles/filedetails/?id=3753990805