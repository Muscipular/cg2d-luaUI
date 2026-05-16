---@class PlayerModule
---@field mapX integer @动态角色地图 X
---@field mapY integer @动态角色地图 Y
---@field floor integer @动态当前楼层
---@field mapId integer @动态当前地图 ID

---@type PlayerModule
Player = Player or {}

---@class GraphicInfo
---@field seqNo integer @图形全局索引
---@field offset integer @图形数据文件偏移
---@field length integer @图形数据长度
---@field x integer @绘制偏移 X
---@field y integer @绘制偏移 Y
---@field w integer @图形宽度
---@field h integer @图形高度
---@field graphicFileIndex integer @图形文件索引
---@field field16 integer @未知字段
---@field sx integer @占地 X
---@field sy integer @占地 Y
---@field blockFlag integer @阻挡标记
---@field mapNo integer @地图图号

---@class GraphicModule
Graphic = Graphic or {}

---@param mapNo integer @地图图号
---@return GraphicInfo|nil info @查不到时返回 nil
function Graphic.GetGrahpicInfo(mapNo) end
