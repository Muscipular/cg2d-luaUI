-- 当前客户端 Lua UI 声明，2026-10-20；仅供说明和补全，不作为运行入口。
-- LuaWindow/LuaControl 均为按 ID 临时解析的引用，GC 不关闭窗口或删除元素。
-- 同窗口 ID 重开、同元素 ID 重建后，旧引用会重新命中新对象。
-- 未知扩展属性仅支持 string / int32；不支持 nil、boolean、table、function 或 userdata。
-- 内置回调接受 function / nil；用对象.onXXX = nil 清除，Set({onXXX=nil}) 无法传递该字段。

---@alias LuaElementIdParam integer|string|nil @整数范围 0..4294967295；字符串只允许空字符串
---@alias LuaElementType integer @原生 WindowElementType 编号，见 README.md；不同于 CONST.UIControl.TYPE

---@class LuaElementCollection
---@field [integer] LuaControl|nil @按 elementId 查找，不是连续数组；缺失返回 nil
-- #window.elements 与 window.count 均为全部有效元素数，包含容器子孙；不支持 pairs/ipairs 枚举。

---@class LuaWindow
---@field valid boolean @窗口引用是否仍有效
---@field id integer @窗口 ID
---@field winId integer @窗口 ID，同 id
---@field state integer @窗口状态
---@field visible boolean @窗口是否可见
---@field count integer @只读；全部有效元素数量，包含容器子孙
---@field elements LuaElementCollection @只读集合引用；通过 elements[elementId] 访问控件
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field layer integer
---@field dragMove integer @扩展窗口设置为 1 时允许空白区域左键拖动；原生窗口不启用此拖动机制
---@field onUpdate LuaWindowCallback|nil
---@field onDraw LuaWindowCallback|nil
---@field onEvent LuaWindowEvent|nil
---@field update LuaWindowCallback|nil @onUpdate 别名
---@field draw LuaWindowCallback|nil @onDraw 别名

---@class LuaControl
---@field valid boolean @控件引用是否仍有效
---@field elementId integer|nil @只读；稳定元素 ID，失效时返回 nil
---@field id integer|nil @只读；elementId 别名，不是数组下标或图号
---@field controlId integer|nil @只读；elementId 别名
---@field seqNo integer @排序主键；小值先处理，同值按 elementId；赋值自动通知重排
---@field name string|nil @动态组件名称
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field visible boolean
---@field type LuaElementType @只读；原生元素类型编号
---@field mouseState integer|nil @动态组件只读鼠标状态，见 CONST.UIControl.MOUSE_STATE
---@field hitable boolean|nil @动态组件是否响应命中
---@field parentId integer|nil @动态组件只读父 ScrollView 的 elementId；0 表示直属窗口
---@field image integer|string|nil @图片控件返回图号，PNG 图片控件返回路径
---@field imageHover integer|string|nil @动态图片组件为图号，PNG 图片为路径
---@field imagePress integer|string|nil @动态图片组件为图号，PNG 图片为路径
---@field imageRect LuaPngRect|nil @仅 PNG 图片控件
---@field imageHoverRect LuaPngRect|nil @仅 PNG 图片控件
---@field imagePressRect LuaPngRect|nil @仅 PNG 图片控件
---@field color integer|nil @图形/PNG 为 ARGB；文本/输入框为调色板颜色，取低 8 位
---@field font integer|nil @文本/输入框字体 ID；找不到时使用 0 号字体
---@field fontType integer|nil @font 别名
---@field text string|nil @文本或输入框控件
---@field maxLength integer|nil @仅输入框控件
---@field animeNo integer|nil @仅动画控件
---@field action integer|nil @仅动画控件
---@field dir integer|nil @仅动画控件
---@field revertPlay integer|nil @仅动画控件
---@field scrollY integer|nil @仅 ScrollView；当前垂直滚动偏移
---@field contentHeight integer|nil @仅 ScrollView；内容高度
---@field maxScrollY integer|nil @仅 ScrollView；最大垂直滚动偏移
---@field barWidth integer|nil @仅 ScrollView；滚动条宽度
---@field scrollStep integer|nil @仅 ScrollView；最小滚动单位
---@field mapX integer|nil @仅地图控件；中心地图 X
---@field mapY integer|nil @仅地图控件；中心地图 Y
---@field mapId integer|nil @仅地图控件；地图 ID
---@field floor integer|nil @仅地图控件；楼层
---@field mapWidth integer|nil @仅地图控件；已加载地图宽度
---@field mapHeight integer|nil @仅地图控件；已加载地图高度
---@field mouseX integer|nil @仅地图控件；当前鼠标所在地图 X
---@field mouseY integer|nil @仅地图控件；当前鼠标所在地图 Y
---@field clickX integer|nil @仅地图控件；最近一次点击地图 X
---@field clickY integer|nil @仅地图控件；最近一次点击地图 Y
---@field lastClickX integer|nil @clickX 别名
---@field lastClickY integer|nil @clickY 别名
---@field onUpdate LuaControlCallback|nil
---@field onDraw LuaControlCallback|nil
---@field onEvent LuaUIEvent|nil
---@field onClick LuaUIEvent|nil @左键按下时触发，不是松开时触发
---@field onPress LuaUIEvent|nil
---@field onHover LuaUIEvent|nil
---@field onLeave LuaUIEvent|nil
---@field onDrag LuaUIEvent|nil @拖动移动期间触发，位置从 CONST.Mouse 读取
---@field onDrop LuaUIEvent|nil @拖动结束时触发
---@field onChange LuaUITextEvent|nil @输入框文本变化
---@field onEnter LuaUITextEvent|nil @输入框回车

---@class LuaEventHandle
---@field valid boolean @事件是否仍有效；false 表示已反注册
---@field active boolean @事件是否仍有效，同 valid

---@return boolean success @成功反注册返回 true；重复反注册返回 false
function LuaEventHandle:Unregister() end


---@alias LuaUIEvent fun(control: LuaControl, flags: integer): boolean|nil @flags 为 CONST.MouseFlags 位组合；true 消费事件
---@alias LuaUITextEvent fun(control: LuaControl, text: string): boolean|nil
---@alias LuaControlCallback fun(control: LuaControl) @帧回调，返回值忽略
---@alias LuaWindowCallback fun(window: LuaWindow) @帧回调，返回值忽略
---@alias LuaWindowEvent fun(window: LuaWindow, elementId: integer, flags: integer): boolean|nil
---@alias LuaWindowOpenCallback fun(winId: integer)
---@alias LuaPacketRecvCallback fun(packetHeader: string, params: string[])
---@alias LuaPacketSendCallback fun(packetHeader: string, data: string, len: integer)
---@alias LuaPacketData string|integer
---@alias LuaKeyPressCallback fun()
---@alias LuaSceneStateChangedCallback fun(sceneType: integer, sceneState: integer)

---@alias LuaVkList integer|integer[]

---@class LuaWindowParam
---@field id integer @必须大于 100
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field layer integer|nil @新建默认 4；复用窗口时可更新
---@field visible boolean|nil @默认 true；false 时创建隐藏窗口
---@field dragMove integer|nil @默认 0；1 时允许窗口空白区域左键拖动
---@field update LuaWindowCallback|nil
---@field draw LuaWindowCallback|nil
---@field onUpdate LuaWindowCallback|nil @与 update 相同，不要同时指定两个别名
---@field onDraw LuaWindowCallback|nil @与 draw 相同，不要同时指定两个别名
---@field onEvent LuaWindowEvent|nil

---@class LuaControlBaseParam
---@field elementId LuaElementIdParam @不填/nil/0/空字符串自动从全局 10000 起分配；正整数显式指定，重复报错
---@field seqNo integer|nil @int32 排序主键；不填使用组件默认值；元素遍历中写入会报错
---@field name string|nil
---@field x integer|nil @默认 0
---@field y integer|nil @默认 0
---@field width integer|nil @默认 0
---@field height integer|nil @默认 0
---@field visible boolean|nil @默认 true；false 时不绘制、不响应 process
---@field hitable boolean|nil @图片/PNG/动画/输入框/滚动容器/地图默认 true，文本/画布默认 false
---@field parent LuaControl|nil @父 ScrollView；未填则直属窗口
---@field parentId integer|nil @父 ScrollView 控件 ID；parent 优先
---@field onUpdate LuaControlCallback|nil
---@field onDraw LuaControlCallback|nil
---@field onEvent LuaUIEvent|nil
---@field onClick LuaUIEvent|nil
---@field onPress LuaUIEvent|nil
---@field onHover LuaUIEvent|nil
---@field onLeave LuaUIEvent|nil
---@field onDrag LuaUIEvent|nil
---@field onDrop LuaUIEvent|nil

---@class LuaImageParam: LuaControlBaseParam
---@field image integer|nil @图号；未填时读 id，默认 -1
---@field id integer|nil @仅创建图片时作为 image 兼容别名；元素身份请用 elementId
---@field imageHover integer|nil @默认 image
---@field imagePress integer|nil @默认 image
---@field color integer|nil @默认 0xffffffff

---@class LuaPngRect
---@field x integer
---@field y integer
---@field width integer|nil @未填时读 w
---@field height integer|nil @未填时读 h
---@field w integer|nil @width 别名，仅参数可用
---@field h integer|nil @height 别名，仅参数可用

---@class LuaPngImageParam: LuaControlBaseParam
---@field image string|nil
---@field imageRect LuaPngRect|nil
---@field imageHover string|nil
---@field imageHoverRect LuaPngRect|nil
---@field imagePress string|nil
---@field imagePressRect LuaPngRect|nil
---@field color integer|nil @默认 0xffffffff

---@class LuaCanvasShape
---@field type string @line/rect/rectBorder/circle/circleBorder/path/pathBorder
---@field color integer|nil @ARGB，默认 0xffffffff
---@field thickness integer|nil @默认 1，最小 1
---@field segments integer|nil @曲线分段，默认 16，范围 1..128
---@field x integer|nil @矩形起点或圆心 X，默认 0
---@field y integer|nil @矩形起点或圆心 Y，默认 0
---@field width integer|nil @矩形宽度；w 别名
---@field height integer|nil @矩形高度；h 别名
---@field w integer|nil
---@field h integer|nil
---@field x1 integer|nil @线段起点 X
---@field y1 integer|nil @线段起点 Y
---@field x2 integer|nil @线段终点 X
---@field y2 integer|nil @线段终点 Y
---@field radius integer|nil @圆半径；r 别名
---@field r integer|nil
---@field d string|nil @路径命令字符串，供 path/pathBorder 使用

---@class LuaCanvasParam: LuaControlBaseParam
---@field w integer|nil @width 未填时使用
---@field h integer|nil @height 未填时使用
---@field shapes LuaCanvasShape[]|nil @按数组顺序绘制；形状坐标相对画布，受画布范围裁剪

---@class LuaAnimeParam: LuaControlBaseParam
---@field animeNo integer|nil @动画编号
---@field action integer|nil @动画动作
---@field dir integer|nil @动画方向
---@field revert integer|nil @倒序播放：1，正序播放：0

---@class LuaTextParam: LuaControlBaseParam
---@field text string|nil @默认空字符串
---@field font integer|nil @默认 0；使用 font.yml 字体 ID，找不到时回退 0
---@field fontType integer|nil @font 未填时使用
---@field color integer|nil @默认 0，仅低 8 位生效

---@class LuaTextInputParam: LuaControlBaseParam
---@field text string|nil @默认空字符串
---@field font integer|nil @默认 0；使用 font.yml 字体 ID，找不到时回退 0
---@field fontType integer|nil @font 未填时使用
---@field color integer|nil @默认 0，仅低 8 位生效
---@field maxLength integer|nil @GBK 字节上限，默认 287；<=0 或 >287 时重置为 287，不拆汉字
---@field onChange LuaUITextEvent|nil
---@field onEnter LuaUITextEvent|nil

---@class LuaScrollViewParam: LuaControlBaseParam
---@field contentHeight integer|nil @默认 height；小于 height 时不显示滚动条
---@field scrollY integer|nil @默认 0；自动限制到 0..maxScrollY，并按 scrollStep 对齐
---@field barWidth integer|nil @默认 8；仅垂直滚动条
---@field scrollStep integer|nil @默认 1；<=0 时重置为 1

---@class LuaMapParam: LuaControlBaseParam
---@field w integer|nil @width 未填时使用
---@field h integer|nil @height 未填时使用
---@field mapX integer|nil @中心地图 X；未填或 -1 时使用角色当前地图 X
---@field mapY integer|nil @中心地图 Y；未填或 -1 时使用角色当前地图 Y
---@field mapId integer|nil @未填或 -1 时使用当前地图 ID
---@field floor integer|nil @未填或 -1 时使用当前楼层

---@class LuaMapPointParam
---@field mapX integer @地图 X
---@field mapY integer @地图 Y
---@field type integer @0 圆点，1 方形，2 三角形，3 倒三角
---@field size integer|nil @默认 2，范围 1..16
---@field color integer[]|nil @ARGB 颜色数组；渲染时按帧循环，默认 {0xffffffff}

---@class LuaMapPoint: LuaMapPointParam

---@class LuaAutoCopliotRoutePoint
---@field x integer @地图 X
---@field y integer @地图 Y

---@class LuaControlSetParam
---@field seqNo integer|nil @写入自动重排；元素遍历期间写 m_log 并报错，恢复原 seqNo
---@field name string|nil
---@field x integer|nil
---@field y integer|nil
---@field width integer|nil
---@field height integer|nil
---@field visible boolean|nil @false 时不绘制、不响应 process，并清理鼠标/输入状态
---@field hitable boolean|nil
---@field image integer|string|nil @图片控件为图号，PNG 图片控件为路径
---@field imageHover integer|string|nil
---@field imageHoverRect LuaPngRect|nil
---@field imagePress integer|string|nil
---@field imagePressRect LuaPngRect|nil
---@field imageRect LuaPngRect|nil
---@field color integer|nil
---@field text string|nil
---@field font integer|nil
---@field fontType integer|nil @font 未填时使用
---@field maxLength integer|nil @仅输入框控件
---@field animeNo integer|nil @仅动画控件；只接受数值型
---@field action integer|nil @仅动画控件；只接受数值型，对应 YobiAction.actionState
---@field dir integer|nil @仅动画控件；只接受数值型，对应 YobiAction.dir
---@field revertPlay integer|nil @仅动画控件；非 0 时传给 UIElementData_2.revertPlay
---@field revert integer|nil @revertPlay 别名，仅参数可用
---@field scrollY integer|nil @仅 ScrollView；自动限制到 0..maxScrollY，并按 scrollStep 对齐
---@field contentHeight integer|nil @仅 ScrollView
---@field barWidth integer|nil @仅 ScrollView；<=0 时重置为 8
---@field scrollStep integer|nil @仅 ScrollView；<=0 时重置为 1
---@field mapX integer|nil @仅地图控件；未填保持原值；-1 时使用角色当前地图 X
---@field mapY integer|nil @仅地图控件；未填保持原值；-1 时使用角色当前地图 Y
---@field mapId integer|nil @仅地图控件；未填保持原值；-1 时使用当前地图 ID
---@field floor integer|nil @仅地图控件；未填保持原值；-1 时使用当前楼层
---@field shapes LuaCanvasShape[]|nil @仅画布；整体替换形状列表，空表清空；不提供 shapes 读取接口
---@field onUpdate LuaControlCallback|nil
---@field onDraw LuaControlCallback|nil
---@field onEvent LuaUIEvent|nil
---@field onClick LuaUIEvent|nil
---@field onPress LuaUIEvent|nil
---@field onHover LuaUIEvent|nil
---@field onLeave LuaUIEvent|nil
---@field onDrag LuaUIEvent|nil
---@field onDrop LuaUIEvent|nil
---@field onChange LuaUITextEvent|nil
---@field onEnter LuaUITextEvent|nil

---@class LuaWindowSetParam
---@field x integer|nil
---@field y integer|nil
---@field width integer|nil
---@field height integer|nil
---@field layer integer|nil
---@field visible boolean|nil @false 时隐藏窗口并清理控件鼠标状态、拖动状态和输入框焦点
---@field dragMove integer|nil @未填保持原值；1 时允许窗口空白区域左键拖动
---@field update LuaWindowCallback|nil
---@field draw LuaWindowCallback|nil
---@field onUpdate LuaWindowCallback|nil @update 别名
---@field onDraw LuaWindowCallback|nil @draw 别名
---@field onEvent LuaWindowEvent|nil

---@class LuaDrawRectParam
---@field x integer|nil @默认 0
---@field y integer|nil @默认 0
---@field width integer|nil @未填时读 w
---@field height integer|nil @未填时读 h
---@field w integer|nil @width 别名
---@field h integer|nil @height 别名
---@field color integer|nil @默认 0

---@param param LuaImageParam
---@return LuaControl|nil control
function LuaWindow:AddImage(param) end

---@param param LuaAnimeParam
---@return LuaControl|nil control
function LuaWindow:AddAnime(param) end

---@param param LuaPngImageParam
---@return LuaControl|nil control
function LuaWindow:AddPngImage(param) end

---@param param LuaCanvasParam
---@return LuaControl|nil control
function LuaWindow:AddCanvas(param) end

---@param param LuaTextParam
---@return LuaControl|nil control
function LuaWindow:AddText(param) end

---@param param LuaTextInputParam
---@return LuaControl|nil control
function LuaWindow:AddTextInput(param) end

---@param param LuaScrollViewParam
---@return LuaControl|nil control
function LuaWindow:AddScrollView(param) end

---@param param LuaMapParam
---@return LuaControl|nil control
function LuaWindow:AddMap(param) end

---按稳定 ID 查找，窗口失效/元素缺失返回 nil；不创建元素或 Lua 绑定。
---@param elementId LuaElementIdParam @0/nil/空字符串返回 nil，不自动分配；非法 ID 报错
---@return LuaControl|nil element
function LuaWindow:FindElementById(elementId) end

---删除元素及容器子孙；原生和扩展窗口统一支持。
---@param elementId LuaElementIdParam @0/nil/空字符串返回 false；非法 ID 报错
---@return boolean removed @窗口失效或元素不存在返回 false
function LuaWindow:RemoveElement(elementId) end

---@param param LuaWindowSetParam
---@return boolean success
function LuaWindow:Set(param) end

---@return boolean success
function LuaWindow:Close() end

---@param vkMain integer @0..255
---@param stateMask integer @1..255，见 CONST.KeyStateFlag
---@return boolean pressed
function LuaWindow:CheckKeyState(vkMain, stateMask) end

---@param vkMain integer @0..255
---@param vkList LuaVkList @附加按住键；可为单个 VK 或数组
---@param stateMask integer @1..255，见 CONST.KeyStateFlag
---@return boolean pressed
function LuaWindow:CheckKeyState(vkMain, vkList, stateMask) end

---清空窗口全部元素，保留窗口属性及窗口回调；空集合重复清空成功。
---@return boolean success @窗口失效返回 false
function LuaWindow:ClearChildren() end

---@param text string|nil @nil 时按空字符串处理
---@return boolean success
function LuaWindow:ShowTips(text) end

---@param param LuaDrawRectParam
---@return boolean success @窗口隐藏时返回 false
---@return integer|nil index
function LuaWindow:DrawRect(param) end

---只更新所传字段；id/controlId/elementId 只读，包含它们会报错。
---@param param LuaControlSetParam
---@return boolean success @元素失效或参数不是 table 返回 false；直接给失效对象赋值则报错
function LuaControl:Set(param) end

---@param param LuaMapPointParam
---@return boolean success @仅地图控件成功
---@return integer|nil index @新增点序号
function LuaControl:AddPoint(param) end

---@param mapX integer @地图 X
---@param mapY integer @地图 Y
---@return integer removed @删除的点数量；非地图控件或参数非法返回 0
function LuaControl:RemovePoints(mapX, mapY) end

---@return LuaMapPoint[] points @仅地图控件返回点列表拷贝，其他控件返回空表
function LuaControl:GetPoints() end

---@class WinMgrModule
WinMgr = WinMgr or {}

---@param param LuaWindowParam
---@return integer status @0 新建窗口，1 复用已有扩展窗口并更新所传属性
---@return LuaWindow window
function WinMgr.NewWindow(param) end

---@param id integer
---@return LuaWindow|nil window @原生、Lua创建及无绑定扩展窗口统一引用；不存在或关闭中返回 nil
function WinMgr.FindWindow(id) end

---@param id integer
---@return integer success @1 成功，0 失败
function WinMgr.Focus(id) end

---@param id integer
function WinMgr.Close(id) end

---开始自动导航到地图坐标；会持续分段移动直到到达或调用 StopCopilot
---@param x integer @目标地图 X
---@param y integer @目标地图 Y
function WinMgr.AutoCopilot(x, y) end

---停止当前自动导航
function WinMgr.StopCopilot() end
---获取当前自动导航状态
---@return integer state @1 导航中，0 未导航
function WinMgr.GetAutoCopliotState() end

---获取最近一次自动导航计算出的路线
---@return LuaAutoCopliotRoutePoint[] route @未导航、目标越界或无法计算路线时返回空表
function WinMgr.GetAutoCopliotRoute() end

---@param callback LuaSceneStateChangedCallback
---@return LuaEventHandle handle @调用 handle:Unregister() 反注册
function WinMgr.OnSceneStateChanged(callback) end

---@param callback fun(focusWinId: integer, blurWinId: integer) @-1 表示无焦点窗口
---@return LuaEventHandle handle @调用 handle:Unregister() 反注册
function WinMgr.OnWindowFocusChanged(callback) end

---订阅全部原生/扩展窗口的新建事件，下一次 UI 更新派发；复用、置前、重新显示不触发。
---回调前窗口已关闭或被替换则跳过；回调可用 FindWindow 查询。返回值忽略。
---@param callback LuaWindowOpenCallback
---@return LuaEventHandle handle @调用 handle:Unregister() 注销；模块内优先 self:onWindowOpen
function WinMgr.OnWindowOpen(callback) end

---@param callback fun(winId: integer)
---@return LuaEventHandle handle @调用 handle:Unregister() 反注册
function WinMgr.OnWindowClose(callback) end

---@param callback LuaChatMessageCallback
---@return LuaEventHandle handle @callback 返回 1 时拦截发送事件
function WinMgr.OnChatMessage(callback) end

---@param header string
---@param callback LuaPacketRecvCallback
---@return LuaEventHandle handle
function WinMgr.OnPacketRecv(header, callback) end

---@param header string
---@param callback LuaPacketSendCallback
---@return LuaEventHandle handle
function WinMgr.OnPacketSend(header, callback) end

---@param vkMain integer @0..255
---@param stateMask integer @1..255，见 CONST.KeyStateFlag
---@param callback LuaKeyPressCallback
---@return LuaEventHandle handle
function WinMgr.OnKeyPress(vkMain, stateMask, callback) end

---@param vkMain integer @0..255
---@param vkList LuaVkList @附加按住键；可为单个 VK 或数组
---@param stateMask integer @1..255，见 CONST.KeyStateFlag
---@param callback LuaKeyPressCallback
---@return LuaEventHandle handle
function WinMgr.OnKeyPress(vkMain, vkList, stateMask, callback) end

---@param fullPacket string @完整封包；未以 \n 结尾时自动补齐
---@return integer result
function WinMgr.SendPacket(fullPacket) end

---@param head string @协议头
---@param ... LuaPacketData @按空格拼接；integer 使用 62 进制编码，string 使用 nrproto 字符串转义；末尾自动补 \n
---@return integer result
function WinMgr.SendPacket(head, ...) end

---@param seNo integer @0..500
---@param panX integer @默认 320
---@return integer result @0 成功，-1 失败
function WinMgr.PlaySe(seNo, panX) end

---@param bgmNo integer @bin\bgm\bgm.cf 第二列 BGM 号
---@return integer result @1 成功，非 1 失败
function WinMgr.LoadAndPlayBGM(bgmNo) end

---@param type integer @固定 BGM 类型：0 或 1
---@param repeats integer @重复次数，传给原客户端
---@return integer result @1 成功，非 1 失败
function WinMgr.PlayFixedBGM(type, repeats) end

---@param msg string
function WinMgr.CliSendMsg(msg) end

---@param msg string
---@param color integer @默认 0
function WinMgr.CliSendMsg(msg, color) end

---@param msg string
---@param color integer @默认 0
---@param font integer @默认 0
function WinMgr.CliSendMsg(msg, color, font) end

---@param msg string
---@param color integer @默认 0
---@param font integer @默认 0
---@param sender string|nil
function WinMgr.CliSendMsg(msg, color, font, sender) end

---@param value integer
---@return string encoded
function WinMgr.NrEncode62(value) end

---@param value string
---@return integer decoded
function WinMgr.NrDecode62(value) end

---@param value integer
---@return string encoded
function WinMgr.NrEncode16(value) end

---@param value string
---@return integer decoded
function WinMgr.NrDecode16(value) end

---@param value string
---@return string encoded
function WinMgr.NrEncodeString(value) end

---@param value string
---@return string decoded
function WinMgr.NrDecodeString(value) end
