<div align="center">

# 🥔 Brotato HTTP API Mod

**通过 RESTful API 实时控制和获取土豆兄弟游戏数据**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](https://github.com/your-repo)
[![Platform](https://img.shields.io/badge/Platform-Steam_Workshop-orange.svg)](https://steamcommunity.com/workshop/)
[![Godot](https://img.shields.io/badge/Godot-3.x-blue.svg)](https://godotengine.org/)
[![Python](https://img.shields.io/badge/Python-3.7%2B-yellow.svg)](https://python.org/)

**🎮 让 AI 替你玩游戏 | 📊 实时数据采集 | 🤖 自动化测试工具**

[📖 API 文档](./API.md) | [🎨 Logo 设计指南](./LOGO_DESIGN_GUIDE.md) | [🚀 Steam Workshop](#-安装) | [📺 Bilibili 教程](#-视频教程)

</div>

---

## ✨ 功能特性

### 🌐 **完整的 HTTP 接口**
- ✅ **11 个 RESTful API 端点**
- ✅ JSON 格式数据交互
- ✅ 支持多客户端并发连接
- ✅ 无需认证（本地安全访问）

### 📊 **实时数据查询**
- 👤 玩家状态（血量/等级/金币/装备）
- 👾 敌人信息（位置/血量/伤害/速度）
- 🌊 游戏进度（当前波次）
- 🎒 物品清单查看
- 📍 精确坐标追踪

### 🎮 **远程控制能力**
- 🏃 角色移动控制（8方向 + 向量）
- 🎯 自动瞄准系统
- 🔒 控制权管理（安全释放）
- ⚡ 即时响应（< 16ms 延迟）

### 🛠️ **开发者友好**
- 🐍 Python 示例代码即拿即用
- 📝 完整的 API 文档
- 🧪 AI 自动战斗框架示例
- 🔧 易于扩展和定制

---

## 🎯 应用场景

| 场景 | 说明 |
|------|------|
| 🤖 **AI 自动化** | 让 ChatGPT/Claude/自定义 AI 玩游戏 |
| 📈 **数据分析** | 收集游戏数据训练机器学习模型 |
| 🧪 **模组开发** | 测试和调试其他模组的工具 |
| 🎮 **外挂辅助** | 远程控制和监控游戏状态 |
| 📺 **直播互动** | 观众通过弹幕控制游戏 |
| 🎓 **教学演示** | Godot 模组开发和网络编程教学 |

---

## 🚀 快速开始

### ⚡ 30 秒体验

```bash
# 1. 订阅 Steam Workshop 模组（或手动安装到 Mods 目录）

# 2. 启动土豆兄弟，进入一局游戏

# 3. 测试连接
curl http://localhost:8082/
# 返回: {"status": "ok", "service": "brotato-api"}

# 4. 获取玩家状态
curl http://localhost:8082/api/stats
# 返回: {"success": true, "data": {"health": 100, "level": 1, ...}}
```

### 🐍 Python 快速示例

```python
import requests

BASE = "http://localhost:8082"

# 获取玩家状态
stats = requests.get(f"{BASE}/api/stats").json()
print(f"❤️ 血量: {stats['data']['health']} | 💰 金币: {stats['data']['gold']}")

# 获取敌人列表
enemies = requests.get(f"{BASE}/api/enemies").json()
print(f"👾 当前敌人: {enemies['count']}")

# 控制角色移动（向上）
requests.post(f"{BASE}/api/move", json={"direction": "up"})

# 2秒后释放控制权
import time; time.sleep(2)
requests.post(f"{BASE}/api/release")  # 重要！
```

---

## 📦 安装方法

### 方法 1: Steam Workshop（推荐）⭐

1. 打开土豆兄弟
2. 进入 **Mod Loader** 菜单
3. 点击 **Workshop** 标签页
4. 搜索 `Simple_HTTP_Test` 或 `Brotato HTTP API`
5. 点击 **Subscribe** (订阅)
6. 启动游戏 → 模组自动加载

✅ **优点**: 自动更新，一键安装

---

## 🔧 配置选项

### 修改端口（可选）

编辑 `mod_main.gd` 第 3 行:

```gdscript
const PORT = 8082  # 改为你想要的端口号
```

> ⚠️ **注意**: 修改后需要重启游戏生效

---

## 📡 API 接口总览

> 📖 **详细文档请查看**: [API.md](./API.md)

### 查询接口 (GET)

| 端点 | 说明 | 返回数据 |
|------|------|----------|
| `GET /` | 健康检查 | 服务状态 |
| `GET /api/stats` | 玩家统计 | 血量/等级/金币/装备数 |
| `GET /api/enemies` | 敌人列表 | 位置/血量/伤害/速度 |
| `GET /api/entities` | 所有实体 | 场景扫描结果 |
| `GET /api/wave` | 波次信息 | 当前进度 |
| `GET /api/items` | 物品清单 | 装备列表 |
| `GET /api/player_pos` | 玩家位置 | 坐标/速度/存活状态 |

### 控制接口 (POST)

| 端点 | 参数 | 功能 |
|------|------|------|
| `POST /api/move` | `direction` 或 `x,y` | 移动角色 |
| `POST /api/stop` | 无 | 停止移动 |
| `POST /api/aim` | `x, y` | 自动瞄准 |
| `POST /api/release` | 无 | **释放控制权** ⭐ |

---

## 🖼️ 截图 & Demo

<!-- TODO: 在这里添加截图或 GIF -->

<!-- 
### 控制台输出示例
```
{
  "simple_http_test-Simple_HTTP_Test": "[Resource:1630]"
}
SUCCESS ModLoader:Loader: DONE: Completely finished loading mods
SUCCESS ModLoader:Loader: DONE: Installed all script extensions
local platform initialized
[BrotatoAPI] ================================
[BrotatoAPI] Brotato API Server v2.0
[BrotatoAPI] ================================
[BrotatoAPI] OK - HTTP port: 8082
[BrotatoAPI] URL: http://localhost:8082
[BrotatoAPI] ================================
```

### Python 控制演示
![Demo GIF](screenshots/demo.gif)
-->

> 📸 **欢迎提交你的使用截图！** 可以在 Issues 中分享。

---

## 🎮 使用示例

### 示例 1: 简单的状态监控

```python
import time
import requests

while True:
    stats = requests.get('http://localhost:8082/api/stats').json()
    if stats['success']:
        data = stats['data']
        print(f"\r❤️ {data['health']:5.1f} | Lv.{data['level']:2d} | "
              f"💰{data['gold']:4d} | 🗡️{data['weapons_count']} | "
              f"🎒{data['items_count']}", end="")
    time.sleep(0.5)
```

**输出**:
```
❤️ 85.5 | Lv.7  | 💰 200 | 🗡️4 | 🎒15
```

---

### 示例 2: AI 自动战斗框架

```python
import requests
import time
import math

class SimpleBot:
    def __init__(self):
        self.base = "http://localhost:8082"
    
    def get_enemies(self):
        resp = requests.get(f"{self.base}/api/enemies")
        return resp.json().get('enemies', [])
    
    def move_away_from_nearest(self):
        enemies = self.get_enemies()
        if not enemies:
            requests.post(f"{self.base}/api/stop")
            return
        
        # 找最近的敌人
        nearest = min(enemies, 
                     key=lambda e: math.sqrt(e['x']**2 + e['y']**2))
        
        # 向相反方向逃跑
        dx, dy = -nearest['x'], -nearest['y']
        requests.post(f"{self.base}/api/move", json={"x": dx, "y": dy})
    
    def run(self, duration=30):
        try:
            start = time.time()
            while time.time() - start < duration:
                self.move_away_from_nearest()
                time.sleep(0.05)  # 20 FPS
        finally:
            requests.post(f"{self.base}/api/release")
            print("\n✅ Bot 已停止，控制权已释放")

# 使用
bot = SimpleBot()
print("🤖 AI Bot 启动！运行 30 秒...")
bot.run(30)
```

---

### 示例 3: 数据采集与记录

```python
import requests
import json
from datetime import datetime

def collect_game_data():
    base = "http://localhost:8082"
    data = {
        'timestamp': datetime.now().isoformat(),
        'player': requests.get(f"{base}/api/stats").json(),
        'wave': requests.get(f"{base}/api/wave").json(),
        'enemies': requests.get(f"{base}/api/enemies").json()
    }
    
    # 保存到文件
    filename = f"brotato_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"💾 数据已保存: {filename}")
    return data

# 每 10 秒记录一次
import time
for i in range(6):  # 运行 1 分钟
    collect_game_data()
    time.sleep(10)
```

---

## 📺 视频教程

### 🇨🇳 中文教程（Bilibili）

**标题**: 【土豆兄弟】我做了个模组让AI替我玩游戏！HTTP API完全教程

**内容大纲**:
- 00:00 开场：AI 自动打怪演示
- 01:00 模组功能介绍与安装
- 03:00 API 接口讲解
- 05:00 Python 代码实战
- 07:00 进阶：AI 决策逻辑
- 08:00 总结与开源地址

🔗 **观看链接**: [待添加](https://space.bilibili.com/your-id)

---

### 🌍 English Tutorial (YouTube)

**Title**: Control Brotato with Python - HTTP API Mod Tutorial

🔗 **Watch**: [Coming Soon](https://youtube.com/your-channel)

---

## 🏗️ 技术架构

### 工作原理

```
┌─────────────┐     HTTP/JSON      ┌──────────────────┐
│   Python/    │ ◄──────────────► │                  │
│   Node.js   │                   │  Godot Mod Loader  │
│   cURL 等   │                   │       ↓           │
└─────────────┘                   │  mod_main.gd      │
                                  │  (TCP Server)     │
                                  │       ↓           │
                                  │  Brotato Game     │
                                  │  (Scene Tree)     │
                                  └──────────────────┘
```

### 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| **游戏引擎** | Godot 3.x | 土豆兄弟使用的引擎 |
| **脚本语言** | GDScript | Godot 的 Python 风格语言 |
| **网络层** | TCP_Server | Godot 内置 TCP 服务 |
| **协议** | HTTP/1.1 | RESTful 风格 |
| **数据格式** | JSON | 轻量级数据交换 |

---

## ⚠️ 注意事项 & 安全提示

### ⚠️ **重要提醒**

1. **仅限本地使用**
   - ❌ 不要将此 API 暴露到公网
   - ❌ 无身份验证机制
   - ✅ 仅在 `127.0.0.1` 或 `localhost` 访问

2. **控制权管理**
   - ⚠️ 使用 `/api/move` 后必须调用 `/api/release`
   - ⚠️ 否则玩家无法手动操作
   - ✅ 使用 `try-finally` 确保释放

3. **性能建议**
   - 建议 API 调用间隔 ≥ 50ms
   - 避免高频轮询导致卡顿
   - 多客户端可能产生冲突

4. **游戏版本兼容性**
   - 不同版本的 Brotato 可能内部结构不同
   - 如遇问题请检查 manifest.json 的兼容版本声明

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献？

1. **🐛 报告 Bug**
   - 使用 [Issues](../../issues) 提交
   - 包含复现步骤、日志、截图

2. **💡 功能建议**
   - 先开 Issue 讨论
   - 说明使用场景和预期效果

3. **💻 提交代码**
   ```bash
   # Fork 本仓库
   git clone https://github.com/your-username/Brotato-HTTP-API.git
   git checkout -b feature/your-feature-name
   # 进行修改...
   git commit -m "Add your feature"
   git push origin feature/your-feature-name
   # 创建 Pull Request
   ```

4. **📝 改进文档**
   - 修正错别字
   - 补充示例代码
   - 翻译成其他语言

### 代码规范

- 遵循现有代码风格
- 添加必要的注释
- 确保 API 兼容性

---

## 📜 开源协议

本项目采用 **GNU General Public License v3.0** 协议开源。

[![GPLv3 License](https://www.gnu.org/graphics/gplv3-88x31.png)](https://www.gnu.org/licenses/gpl-3.0)

### 你可以：
- ✅ 商业使用
- ✅ 修改和分发
- ✅ 私人使用
- ✅ 专利使用

### 你必须：
- 📄 保留版权声明和许可声明
- 📄 公开源代码时使用相同协议
- 📄 说明修改内容

详见 [LICENSE](./LICENSE) 文件。

---

## 🙏 致谢

感谢以下项目和社区：

- **[Godot Engine](https://godotengine.org/)** - 强大的开源游戏引擎
- **[Godot Mod Loader](https://github.com/NotASafeModder/GodotModLoader)** - 让模组开发成为可能
- **[Flayra](https://store.steampowered.com/developer/flayra/)** - 土豆兄弟的开发者
- **[Brotato Community](https://discord.gg/brotato)** - 活跃的玩家社区

---

## 📞 联系方式

- 💬 **Issues**: [GitHub Issues](../../issues)
- 📧 **Email**: your-email@example.com
- 🎮 **Discord**: [加入服务器](https://discord.gg/invite-link)
- 📺 **Bilibili**: [@你的ID](https://space.bilibili.com/your-id)
- 🌐 **个人网站**: https://s1yle.github.io/

---

## 📊 项目统计

![GitHub Repo stars](https://img.shields.io/github/stars/your-repo/Brotato-HTTP-API?style=social)
![GitHub forks](https://img.shields.io/github/forks/your-repo/Brotato-HTTP-API?style=social)
![GitHub issues](https://img.shields.io/github/issues/your-repo/Brotato-HTTP-API)

---

## 🗺️ 路线图 (Roadmap)

### v1.1.0 (计划中)
- [ ] WebSocket 支持（实时推送）
- [ ] 简单的身份认证机制
- [ ] 更多游戏数据接口
- [ ] 性能优化和缓存

### v1.2.0 (未来)
- [ ] 可视化 Web 控制面板
- [ ] 录制和回放功能
- [ ] 多语言 SDK (JavaScript/Rust/C#)
- [ ] Docker 一键部署环境

---

<div align="center">

### 🌟 如果这个项目对你有帮助，请给一个 Star！⭐

**Made with ❤️ by [Your Name]**

**Powered by [Godot](https://godotengine.org/) & Open Source Community**

[⬆ 回到顶部](#-brotato-http-api-mod)

</div>

## 📦 文件结构

```
mods-unpacked/simple_http_test/
├── manifest.json    # 模组配置
├── mod_main.gd      # 主脚本
└── README.md        # 本文档
```

## 🚀 使用步骤

### 1. 启动游戏
用 Godot 3.6 打开 Brotato

### 2. 查看控制台
```
[SimpleHTTP] ════════════════════════
[SimpleHTTP] 最小 HTTP 测试模组
[SimpleHTTP] ════════════════════════
[SimpleHTTP] ✓ HTTP 服务器已启动，端口：8082
[SimpleHTTP] 访问：http://localhost:8082
```

### 3. 测试
浏览器访问：http://localhost:8082/

或命令行：
```bash
curl http://localhost:8082/
```

## 📡 功能

- ✅ HTTP 服务器（端口 8082）
- ✅ 返回 HTML 页面
- ✅ 控制台显示请求内容

## 🎯 测试通过标准

1. 看到 `[SimpleHTTP]` 输出
2. 浏览器能访问页面
3. 页面显示"成功！"

就这么简单！🎉
