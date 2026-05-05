---@meta _


---@class LuaWindow
---@field valid boolean @窗口引用是否仍有效
---@field id integer @窗口 ID
---@field winId integer @窗口 ID，同 id
---@field generation integer @窗口代次
---@field state integer @窗口状态
---@field count integer @子控件数量
---@field x integer
---@field y integer
---@field width integer
---@field height integer

---@class LuaControl
---@field valid boolean @控件引用是否仍有效
---@field id integer @控件 ID
---@field controlId integer @控件 ID，同 id
---@field name string
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field visible boolean
---@field type integer @见 CONST.UIControl.TYPE
---@field mouseState integer @见 CONST.UIControl.MOUSE_STATE
---@field image integer|string|nil @图片控件返回图号，PNG 图片控件返回路径
---@field imageHover string|nil @仅 PNG 图片控件
---@field imagePress string|nil @仅 PNG 图片控件
---@field imageRect LuaPngRect|nil @仅 PNG 图片控件
---@field imageHoverRect LuaPngRect|nil @仅 PNG 图片控件
---@field imagePressRect LuaPngRect|nil @仅 PNG 图片控件
---@field color integer|nil @仅 PNG 图片控件
---@field text string|nil @文本或输入框控件
---@field maxLength integer|nil @仅输入框控件

---@class LuaEventHandle
---@field valid boolean @事件是否仍有效；false 表示已反注册
---@field active boolean @事件是否仍有效，同 valid

---@return boolean success @成功反注册返回 true；重复反注册返回 false
function LuaEventHandle:Unregister() end


---@alias LuaUIEvent fun(control: LuaControl, flags: integer): boolean|nil
---@alias LuaUITextEvent fun(control: LuaControl, text: string): boolean|nil
---@alias LuaWindowCallback fun(window: LuaWindow): boolean|nil
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
---@field layer integer|nil @仅新建窗口时生效，默认 4
---@field update LuaWindowCallback|nil
---@field draw LuaWindowCallback|nil

---@class LuaControlBaseParam
---@field name string|nil
---@field x integer|nil @默认 0
---@field y integer|nil @默认 0
---@field width integer|nil @默认 0
---@field height integer|nil @默认 0
---@field visible boolean|nil @默认 true
---@field hitable boolean|nil @图片/PNG/输入框默认 true，文本默认 false
---@field onEvent LuaUIEvent|nil
---@field onClick LuaUIEvent|nil
---@field onPress LuaUIEvent|nil
---@field onHover LuaUIEvent|nil
---@field onDrag LuaUIEvent|nil
---@field onDrop LuaUIEvent|nil

---@class LuaImageParam: LuaControlBaseParam
---@field image integer|nil @图号；未填时读 id，默认 -1
---@field id integer|nil @image 未填时使用
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

---@class LuaTextParam: LuaControlBaseParam
---@field text string|nil @默认空字符串
---@field font integer|nil @默认 0
---@field fontType integer|nil @font 未填时使用
---@field color integer|nil @默认 0，仅低 8 位生效

---@class LuaTextInputParam: LuaControlBaseParam
---@field text string|nil @默认空字符串
---@field font integer|nil @默认 0
---@field fontType integer|nil @font 未填时使用
---@field color integer|nil @默认 0，仅低 8 位生效
---@field maxLength integer|nil @默认 287；<=0 或 >287 时重置为 287
---@field onChange LuaUITextEvent|nil
---@field onEnter LuaUITextEvent|nil

---@class LuaControlSetParam
---@field name string|nil
---@field x integer|nil
---@field y integer|nil
---@field width integer|nil
---@field height integer|nil
---@field visible boolean|nil
---@field hitable boolean|nil
---@field image integer|string|nil @图片控件为图号，PNG 图片控件为路径
---@field id integer|nil @图片控件 image 未填时使用
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

---@param param LuaPngImageParam
---@return LuaControl|nil control
function LuaWindow:AddPngImage(param) end

---@param param LuaTextParam
---@return LuaControl|nil control
function LuaWindow:AddText(param) end

---@param param LuaTextInputParam
---@return LuaControl|nil control
function LuaWindow:AddTextInput(param) end

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

---@return boolean success
function LuaWindow:ClearChildren() end

---@param text string|nil @nil 时按空字符串处理
---@return boolean success
function LuaWindow:ShowTips(text) end

---@param param LuaDrawRectParam
---@return boolean success
---@return integer|nil index
function LuaWindow:DrawRect(param) end

---@param param LuaControlSetParam
---@return boolean success
function LuaControl:Set(param) end

---@class WinMgrModule
WinMgr = WinMgr or {}

---@param param LuaWindowParam
---@return integer status @0 新建窗口，1 已存在并更新位置/尺寸/回调
---@return LuaWindow window
function WinMgr.NewWindow(param) end

---@param id integer
---@return LuaWindow|nil window
function WinMgr.FindWindow(id) end

---@param id integer
---@return integer success @1 成功，0 失败
function WinMgr.Focus(id) end

---@param id integer
function WinMgr.Close(id) end

---@param callback LuaSceneStateChangedCallback
---@return LuaEventHandle handle @调用 handle:Unregister() 反注册
function WinMgr.OnSceneStateChanged(callback) end

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
