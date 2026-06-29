---@alias LuaBridgeValue string|number
---@alias LuaBridgeCallback fun(msgHead: string, ...: LuaBridgeValue)

---@class LuaBridgeHandle
---@field valid boolean @事件是否仍有效；false 表示已反注册
---@field active boolean @事件是否仍有效，同 valid

---@return boolean success @成功反注册返回 true；重复反注册返回 false
function LuaBridgeHandle:Unregister() end

---@class BridgeModule
Bridge = Bridge or {}

---注册 Bridge 消息回调，仅支持 luaUI 与自动战斗之间互通
---@param msgHead string @消息头
---@param callback LuaBridgeCallback @回调参数为 msgHead 和 Send 传入的 string/number 参数
---@return LuaBridgeHandle handle @调用 handle:Unregister() 反注册
function Bridge.On(msgHead, callback) end

---发送 Bridge 消息，只投递到另一侧 luaState，不触发本侧回调
---@param msgHead string @消息头
---@param ... LuaBridgeValue @仅支持 string 或 number
function Bridge.Send(msgHead, ...) end
