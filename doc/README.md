# LuaUI 架构文档

接口核对日期：2026-10-20。按当前客户端源码及本目录模块框架说明；此目录用于文档和接口补全，不应通过 dofile 加载。

## 入口

init.lua 是唯一入口，运行期 Lua 基础目录为 luaUI\\，加载顺序固定：

1. `luaUI\\CONST.lua`
2. `luaUI\\ModuleBase.lua`
3. `luaUI\\GlobalEvent.lua`
4. `luaUI\\ModuleSystem.lua`
5. `luaUI\\ModuleConfig.lua`

`ModuleConfig.lua` 决定实际加载清单。需要启用模块时，在该文件中调用；已加载的模块不要重复添加：

```lua
ModuleSystem:loadModule('demo')
```

## 目录

```text
luaUI/
  init.lua
  CONST.lua
  GlobalEvent.lua
  ModuleBase.lua
  ModuleSystem.lua
  ModuleConfig.lua
  modules/
    demo.lua
  doc/
    README.md
    CONST.lua
    WinMgr.lua
    Global.lua
    Bridge.lua
    Module.lua
```

## 模块规范

模块放在 `luaUI\\modules\\<name>.lua`，返回模块类表。

```lua
---@class DemoModule : ModuleBase
local DemoModule = ModuleBase:extend('demo')

function DemoModule:onLoad()
end

function DemoModule:onUnload()
end

return DemoModule
```

`onLoad` 用于注册事件、创建初始状态。`onUnload` 用于模块自定义清理；事件句柄和通过 `newWindow` 持有的窗口会由基类自动释放。

## ModuleSystem

常用接口：

```lua
ModuleSystem:loadModule(name, opt)
ModuleSystem:reloadModule(name, opt)
ModuleSystem:unloadModule(name)
ModuleSystem:getModule(name)
ModuleSystem:listModules()
ModuleSystem:close()
```

模块查找顺序：

1. `luaUI\\modules\\<name>.lua`
2. `luaUI\\modules\\<name>\\init.lua`
3. `luaUI\\<name>.lua`

## ModuleBase

模块内可用接口：

```lua
self:loadModule(name, opt)
self:reloadModule(name, opt)
self:unloadModule(name)
self:getModule(name)
self:listModules()
```

资源管理：

```lua
self:addCleanup(name, fn)
self:defer(fn, name)
self:own(resource, disposer, name)
self:ownEvent(handle)
self:unregisterHandle(handle)
self:ownWindow(window)
self:releaseWindow(window)
```

## WinMgr 代理

`ModuleBase` 封装了 `luaUI\doc\WinMgr.lua` 中列出的全部 `WinMgr` 接口：

```lua
self:newWindow(param)
self:findWindow(id)
self:focus(id)
self:closeWindow(id)
self:autoCopilot(x, y)
self:stopCopilot()
self:getAutoCopliotState()
self:getAutoCopliotRoute()
self:onSceneStateChanged(callback)
self:onWindowFocusChanged(callback)
self:onWindowOpen(callback)
self:onWindowClose(callback)
self:onChatMessage(callback)
self:onPacketRecv(header, callback)
self:onPacketSend(header, callback)
self:onKeyPress(...)
self:onBridge(msgHead, callback)
self:sendBridge(msgHead, ...)
self:sendPacket(...)
self:playSe(...)
self:loadAndPlayBGM(bgmNo)
self:playFixedBGM(type, repeats)
self:cliSendMsg(...)
self:nrEncode62(value)
self:nrDecode62(value)
self:nrEncode16(value)
self:nrDecode16(value)
self:nrEncodeString(value)
self:nrDecodeString(value)
```

同时保留对应的大写方法名，便于按 `WinMgr` 原名调用。

新打开的窗口可通过模块代理订阅，句柄在模块卸载时自动注销：

```lua
function DemoModule:onLoad()
    self:onWindowOpen(function(winId)
        local window = self:findWindow(winId)
        if window then
            print('窗口打开', window.id, window.count)
        end
    end)
end
```

`WinMgr.OnWindowOpen(callback)` 覆盖原生和扩展窗口，在创建后的下一次 UI 更新派发，只传窗口 ID。复用已有窗口、置前、隐藏后重新显示不会触发；派发前已经关闭或被替换的窗口会被跳过。直接注册的句柄用 `handle:Unregister()` 注销。

`self:findWindow(id)` 只查询，不接管窗口；`self:newWindow(param)` 无论新建还是复用，都会接管返回窗口，在卸载时关闭。`ownWindow` 显式接管窗口，`releaseWindow` 解除接管并关闭。按 ID 重开后的窗口也可能被原引用关闭。

`ownEvent` 自动清理的是带 `Unregister` 方法的客户端/Bridge 句柄。`GlobalEvent:add` 返回普通句柄，需要通过 `self:defer(function() event:remove(handle) end)` 注册清理。

## 窗口与元素统一引用

`WinMgr.NewWindow`、`WinMgr.FindWindow` 和所有窗口回调均使用 `LuaWindow`；原生、Lua创建及无 Lua 绑定的扩展窗口不再分成不同返回类型。

- 窗口引用保存窗口 ID，元素引用保存窗口 ID 和 `elementId`，每次访问解析当前对象；GC 不销毁 UI。
- `window.valid`、`element.valid` 用于判断当前是否存在。窗口关闭或元素删除后失效；同 ID 重开或重建后，旧引用会指向新对象。
- 窗口失效后 `id/winId` 仍可读；当前实现中，失效元素的 `id/controlId/elementId` 返回 nil，需预先保存 ID。
- 窗口普通操作失败返回 false，AddXXX 在窗口失效时返回 nil；查找缺失返回 nil。`element:Set(...)` 在元素失效时返回 false，直接属性赋值则报错。
- 所有窗口均可修改、新增、删除和清空元素；原生业务遇到缺失元素会跳过对应操作。

## 元素 ID、数量与排序

创建参数使用 `elementId`，不要把图片的 `image/id` 参数当元素身份：

| 创建时传入 | 处理 |
|---|---|
| 不填、nil、0、空字符串 | 从 10000 开始使用跨窗口共享的全局自增 ID |
| 1..4294967295 的整数 | 原样作为该窗口中的 ID，已占用时报错 |
| 负数、小数、非空字符串、布尔、table 等 | 参数错误 |

自动分配遇到目标窗口中已占用的 ID 会继续递增；显式 ID 不推进自动计数。同一个 ID 可出现在不同窗口，删除后也可重用。元素创建后 `elementId/id/controlId` 为同一身份的只读别名。

```lua
local status, window = self:newWindow({
    id = 10501, x = 100, y = 100, width = 240, height = 120
})
local title = window:FindElementById(1001)
if not title then
    title = window:AddText({
        elementId = 1001, seqNo = 10,
        x = 8, y = 8, text = '示例', font = 0
    })
end
if title then
    title.text = '新的标题'
end
local sameTitle = window.elements[1001]
-- window:RemoveElement(1001) -- 删除该元素；若为容器，同时删除子孙
-- window:ClearChildren()     -- 清空全部元素，保留窗口属性和窗口回调
```

- `window:FindElementById(id)` 与 `window.elements[id]` 均按 ID 查找；不是第几个元素。查询不会自动创建对象或 Lua 绑定。
- `FindElementById(0/nil/空字符串)` 返回 nil；`RemoveElement` 对这些值返回 false，非法 ID 报错。
- `window.count` 和 `#window.elements` 是全部有效元素数量，包含容器子孙。集合不是连续数组，不支持通过 pairs/ipairs 遍历；脚本需要自行保存所用 ID。
- 绘制和鼠标处理按 `seqNo` 从小到大，同值按 `elementId` 排序。默认排序由组件创建逻辑设置；需要固定顺序时显式指定 int32 范围的 seqNo。
- Lua 修改 `seqNo` 自动调用内部重排接口，无需也没有独立的 Lua `notifyUpdate()` 方法。元素遍历中修改会写 m_log 并报错，恢复原 seqNo；不能在元素的绘制、更新或鼠标回调内修改排序。
- 回调中删除立即失效，新增元素下一轮才参与遍历；新增时若还指定 seqNo，同样受遍历中禁止重排的限制。

## 属性与回调

属性可直接赋值，或用 `Set({字段=值})` 更新。位置、大小、可见性和 seqNo 属于元素；文本、字体和图片等属性按具体元素类型提供，动态组件再提供 name、hitable、parentId、地图及滚动属性。

窗口与元素均可保存扩展属性，值仅允许字符串或 int32 整数。例如 `window.pageNo = 2`、`element.tag = '标题'`。不支持存入 table、布尔、函数、userdata 或 nil；内置参数如 shapes、imageRect 和回调按各自接口处理。复杂状态放在模块的 `self.state`，不挂到窗口上。

| 对象 | 回调签名 |
|---|---|
| 窗口 onUpdate/update、onDraw/draw | function(window)，返回值忽略 |
| 窗口 onEvent | function(window, elementId, flags) |
| 元素 onUpdate、onDraw | function(element)，返回值忽略 |
| 元素 onEvent/onClick/onPress/onHover/onLeave/onDrag/onDrop | function(element, flags) |
| 输入框 onChange/onEnter | function(element, text) |

回调引用由 UI 对象持有，关闭/删除及脚本退出时释放。设置回调为函数进行替换，直接写 `element.onClick = nil` 清除；`Set({onClick=nil})` 中该字段实际不存在，不能用来清除。窗口的 update/onUpdate、draw/onDraw 是别名，不要在同一张参数表中同时设置。

`flags` 是 `CONST.MouseFlags` 位组合；鼠标/文本事件用 true 表示消费，false/nil 表示未消费。Lua 数字 0 仍是真值，不要用 0 代替 false。`onClick` 对应左键按下，`onDrag` 对应拖动移动，`onDrop` 对应结束；坐标从 `CONST.Mouse.x/y` 读取，Map 控件另提供地图坐标。纯 LEAVE 事件只调用 onLeave。

## 画布与字体

`window:AddCanvas(param)` 返回普通元素引用，支持 `elementId`、`seqNo`、父容器及回调。默认不响应命中，可设置 hitable=true。

```lua
local canvas = window:AddCanvas({
    elementId = 1002, x = 8, y = 32, width = 120, height = 40,
    shapes = {
        { type = 'rect', x = 0, y = 0, width = 120, height = 40, color = 0xb3000000 },
        { type = 'line', x1 = 4, y1 = 20, x2 = 116, y2 = 20, color = 0xffffffff }
    }
})
-- canvas:Set({shapes = {}}) -- 清空画布，保留元素
```

shapes 支持 line、rect、rectBorder、circle、circleBorder、path、pathBorder，坐标相对画布，颜色为 ARGB；通过 Set 整体替换形状列表，不提供 shapes 读取接口。参数详情见 `WinMgr.lua`。

文本与输入框使用 `font`，兼容别名 `fontType`，对应 font.yml 的字体 ID；找不到时回退 0 号字体。字体与颜色在创建、Set 和直接赋值时均可传递。Lua 文本仍为 GBK 字符串，客户端内部宽字符串转换由接口处理。

## 类型编号

当前 `element.type` 返回原生 WindowElementType。导出的 `CONST.UIControl.TYPE` 仍保存组件类别编号，两者不是同一套枚举，不能直接比较。下面按当前源码列出差异，不改写运行时常量：

| 类型 | element.type | CONST.UIControl.TYPE |
|---|---:|---|
| 事件区域 | 0 | NONE=0 |
| 图形 | 1 | IMAGE=1 |
| 动画 | 2 | ANIME=5 |
| 文本 | 3 | TEXT=2 |
| 鼠标区域 | 4 | 无对应项 |
| 输入框 | 5 | TEXT_INPUT=4 |
| 输入光标 | 6 | 无对应项 |
| 数字图片文本 | 7 | 无对应项 |
| PNG | 8 | PNG_IMAGE=3 |
| 画布 | 9 | CANVAS=8 |
| 地图 | 10 | MAP=7 |
| 滚动容器 | 11 | SCROLL_VIEW=6 |

## 编码

项目所有文件使用 GBK 编码。读写文件必须显式指定 GBK，禁止使用默认编码。

## 示例模块

`luaUI\\modules\\demo.lua` 是旧 `init.lua` demo 迁移结果，是否加载以当前 `ModuleConfig.lua` 为准。配置形式：

```lua
ModuleSystem:loadModule('demo')
```