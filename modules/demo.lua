---@class DemoModule : ModuleBase
local DemoModule = ModuleBase:extend('demo')

local WIN_DEMO = 101

function DemoModule:_sceneStateChanged(scene, state)
    print('WinMgr.OnSceneStateChanged')
    print(string.format('scene %d state %d', scene, state))
    if scene ~= 9 then
        if self.win and self.win.valid then
            self:releaseWindow(self.win)
            self.win = nil
        end
    end
end

function DemoModule:_ensureNHandler()
    if self.nHandler and self.nHandler.valid then
        return
    end
    self.nHandler = self:onKeyPress(
        0x4E,
        CONST.KeyStateFlag.DOWN_EDGE,
        function()
            print('N')
        end
    )
end

function DemoModule:showCombobox(x, y)
    ---@type ComboxModule
    local combox = self:getModule('combox')
    if not combox then
        return
    end
    print("showCombobox", x, y);

    combox:OpenComboBox({
        x = x,
        y = y,
        width = 120,
        maxHeight = 80,
        itemHeight = 20,
        itemList = {
            '选项1',
            '选项2',
            '选项3',
            '选项4',
            '选项5',
            '选项6',
            '选项7',
            '选项8',
        },
        onSelectedCallback = function(item, index)
            if index == -1 then
                print('未选择')
                return
            end

            print('选择:', index, item)
        end,
    })
end

function DemoModule:_openWindow()
    if self.win ~= nil and self.win.valid then
        return
    end

    local status, win = self:newWindow({
        id = WIN_DEMO,
        x = 0,
        y = 50,
        width = 700,
        height = 500,
        layer = 4,
        update = function(window)
            if not window.valid then
                return false
            end
            if self.win and self.win:CheckKeyState(0x4E, { 0x11, 0x10 }, 255) then
                print('CTRL + SHIFT + N')
            end
            if self.map then
                self.map:Set({ mapX = -1, mapY = -1, floor = -1, mapId = -1 });
                -- print(self.map, self.map.GetPoints);
                for index, value in ipairs(self.map:GetPoints()) do
                    self.map:RemovePoints(value.mapX, value.mapY);
                end
                self.map:AddPoint({
                    mapX = Player.mapX,
                    mapY = Player.mapY,
                    type = 1, -- 圆点
                    size = 2,
                    color = { 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff },
                });
                if self:GetAutoCopliotState() == 1 then
                    local route = self:GetAutoCopliotRoute();
                    for key, value in ipairs(route) do
                        if key % 3 == 0 then
                            self.map:AddPoint({
                                mapX = value.x,
                                mapY = value.y,
                                type = 0, -- 圆点
                                size = 2,
                                color = { 0xffff0000, },
                            });
                        end
                    end
                end
            end
            return false
        end,
        draw = function(window)
            if not window.valid then
                return false
            end
            window:DrawRect({ x = 0, y = 0, width = window.width, height = window.height, color = 0x7fff0000 })
            return false
        end,
    })

    self.status = status
    self.win = win

    if not win then
        return
    end

    win:AddPngImage({
        name = 'pngimage',
        x = 5,
        y = 5,
        width = 80,
        height = 60,
        image = 'a.png',
        color = -1,
        visible = true,
        onClick = function(control)
            self:showCombobox(control.x + win.x, control.y + win.y)
            return true;
        end,
        onPress = function(control, flags)
            if win.valid then
                win:ShowTips('Lua UI pngimage:onPress')
            end
            return true
        end,
    })

    local nameInput = win:AddTextInput({
        name = 'nameInput',
        x = 20,
        y = 40,
        width = 180,
        height = 22,
        text = '',
        font = 1,
        color = 2,
        maxLength = 32,
        visible = true,
        hitable = true,
        onChange = function(control, text)
            win:ShowTips('input: ' .. text)
        end,
        onEnter = function(control, text)
            win:ShowTips('enter: ' .. text)
        end,
    })

    win:AddImage({
        name = 'send',
        x = 12,
        y = 60,
        width = 32,
        height = 32,
        image = 12345,
        color = -1,
        visible = true,
        onClick = function(control, flags)
            self:playSe(55, 320);
            self:loadAndPlayBGM(202)
            WinMgr.CliSendMsg(nameInput.text, 1, 1, '系统提示')
        end,
    })

    local n = 0;
    local dir = 0;
    local action = 0;

    win:AddAnime({
        name = 'demoAnime',
        x = 10,
        y = 110,
        width = 48,
        height = 48,
        animeNo = 105000,
        revertPlay = 0,
        dir = 1,
        action = 3,
        visible = true,
        onClick = function(control)
            n = n + 1;
            if n > 1 then
                n = 0
            end
            dir = dir + 1;
            if dir > 7 then
                dir = 0
            end
            action = action + 1;
            if action > 8 then
                action = 0
            end
            control:Set({ dir = dir, action = action, animeNo = 105000 + n });

            self:playFixedBGM(n, 1)
            print(n, dir, action, control.dir);
        end,
        onHover = function(control, flags)
            if win.valid then
                win:ShowTips('Lua UI demoAnime:onHover')
            end
            return false
        end,
    })

    icon = win:AddImage({
        name = 'demoIconLive',
        x = 12,
        y = 12,
        width = 32,
        height = 32,
        image = 243173,
        imageHover = 243174,
        imagePress = 243175,
        color = -1,
        visible = true,
        onClick = function(control, flags)
            self.clickCount = self.clickCount + 1
            if label and label.valid then
                label:Set({ text = '点击次数: ' .. self.clickCount })
            end
            return true
        end,
        onHover = function(control, flags)
            if win.valid then
                win:ShowTips('Lua UI demoIconLive:onHover')
            end
            return true
        end,
    })

    label = win:AddText({
        name = 'demoTextLive',
        x = 52,
        y = 18,
        width = 150,
        height = 18,
        text = status == 0 and '新建Lua窗口' or '复用Lua窗口',
        font = 0,
        color = 0,
        hitable = true,
        visible = true,
        onClick = function(control, flags)
            control:Set({ text = '文字点击生效' })
            return true
        end,
    })

    local view = win:AddScrollView({
        x = 80,
        y = 10,
        width = 120,
        height = 150,
        contentHeight = 800,
        barWidth = 8,
        scrollStep = 40
    })

    for i = 1, 20 do
        win:AddTextInput({
            parent = view,
            x = 0,
            y = (i - 1) * 32,
            width = 80,
            height = 22,
            text = '',
            font = 1,
            color = 2,
            maxLength = 32,
            visible = true,
            hitable = true,
        })
        win:AddImage({
            parent = view,
            x = 20,
            y = (i - 1) * 32 + 5,
            width = 32,
            height = 32,
            image = 243173,
            color = -1,
            visible = true,
        });
        win:AddAnime({
            parent = view,
            x = 60,
            y = (i - 1) * 32 + 5,
            width = 48,
            height = 48,
            animeNo = 105000 + i,
            revertPlay = 0,
            visible = true,
        })

        win:AddPngImage({
            parent = view,
            x = 40,
            y = (i - 1) * 32 + 5,
            width = 16,
            height = 16,
            image = 'a.png',
            color = -1,
            visible = true,
            onPress = function(control, flags)
                if win.valid then
                    win:ShowTips('Lua UI pngimage:onPress')
                end
                return true
            end,
        })
        win:AddText({
            parent = view,
            x = 4,
            y = (i - 1) * 32,
            width = 190,
            height = 18,
            color = 0,
            font = 0,
            text = "第 " .. i .. " 行中文内容",
        })
        self.map = win:AddMap({
            -- mapX = 100,
            -- mapY = 100,
            width = 700,
            height = 500,
            x = 0,
            y = 0,
            onClick = function(c)
                local mx = c.clickX
                local my = c.clickY
                print("map on click", mx, my)
                self:cliSendMsg(string.format("开始导航到 %d %d", mx, my))
                self:AutoCopilot(mx, my);
            end,
        })
        -- self.map:AddPoint({
        --     mapX = 80,
        --     mapY = 200,
        --     type = 0, -- 圆点
        --     size = 10,
        --     color = { 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000,0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff },
        -- });
        -- self.map:AddPoint({
        --     mapX = 110,
        --     mapY = 200,
        --     type = 1, -- 圆点
        --     size = 8,
        --     color = { 0xffff0000, 0xff00ff00, 0xff0000ff,  },
        -- });
        -- self.map:AddPoint({
        --     mapX = 120,
        --     mapY = 200,
        --     type = 2, -- 圆点
        --     size = 2,
        --     color = { 0xffff0000 },
        -- });
        -- self.map:AddPoint({
        --     mapX = 130,
        --     mapY = 200,
        --     type = 3, -- 圆点
        --     size = 2,
        --     color = { 0xffff0000 },
        -- });
        -- self.map:AddPoint({
        --     mapX = 140,
        --     mapY = 200,
        --     type = 4, -- 圆点
        --     size = 2,
        --     color = { 0xffff0000 },
        -- });
        local canvas = win:AddCanvas({
            x = 0,
            y = 0,
            width = 360,
            height = 260,
            hitable = false,

            shapes = {
                -- 场景：分隔线 / 指示线
                { type = "line",         x1 = 20,                                    y1 = 20,            x2 = 160,      y2 = 20,            color = 0xffffffff, thickness = 2 },

                -- 场景：状态条背景 / 色块填充
                { type = "rect",         x = 20,                                     y = 40,             width = 120,   height = 28,        color = 0x8800ff00 },

                -- 场景：选中框 / 提示边框
                { type = "rectBorder",   x = 160,                                    y = 40,             width = 120,   height = 28,        color = 0xffffff00, thickness = 2 },

                -- 场景：地图点位 / 标记点
                { type = "circle",       x = 60,                                     y = 110,            radius = 18,   color = 0x88ff0000, segments = 16 },

                -- 场景：范围圈 / 技能半径提示
                { type = "circleBorder", x = 140,                                    y = 110,            radius = 28,   color = 0xff00ffff, thickness = 2,      segments = 32 },

                -- 场景：简单闭合区域 / 多边形高亮
                { type = "path",         d = "M220 80 L280 100 L250 150 L200 130 Z", color = 0x880000ff, segments = 16 },

                -- 场景：路线 / 曲线路径提示
                { type = "pathBorder",   d = "M30 200 C90 160 150 240 220 200",      color = 0xffff00ff, thickness = 3, segments = 16 },
            }
        })
    end
end

function DemoModule:_toggleWindow()
    print('CTRL + SHIFT + N ')
    if self.win and self.win.valid then
        self:releaseWindow(self.win)
        self.win = nil
        self:unregisterHandle(self.nHandler)
        self.nHandler = nil
    else
        self:_ensureNHandler()
        self:_openWindow()
    end
end

function DemoModule:onLoad()
    self.clickCount = 0
    self.staleControl = nil
    self.status = nil
    self.win = nil
    self.sceneHandler = self:onSceneStateChanged(function(scene, state)
        self:_sceneStateChanged(scene, state)
    end)
    self:_ensureNHandler()
    self.toggleHandler = self:onKeyPress(
        0x4E,
        { 0x11, 0x10 },
        CONST.KeyStateFlag.DOWN_EDGE,
        function()
            self:_toggleWindow()
        end
    )
end

function DemoModule:onUnload()
    self.win = nil
    self.staleControl = nil
    self.nHandler = nil
    self.sceneHandler = nil
    self.toggleHandler = nil
end

return DemoModule
