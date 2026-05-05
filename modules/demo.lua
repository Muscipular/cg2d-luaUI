---@class DemoModule : ModuleBase
local DemoModule = ModuleBase:extend('demo')

local WIN_DEMO = 101

function DemoModule:_sceneStateChanged(scene, state)
    print('WinMgr.OnSceneStateChanged')
    print(string.format('scene %d state %d', scene, state))
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

function DemoModule:_openWindow()
    if self.win ~= nil and self.win.valid then
        return
    end

    local status, win = self:newWindow({
        id = WIN_DEMO,
        x = 0,
        y = 50,
        width = 220,
        height = 120,
        layer = 4,
        update = function(window)
            if not window.valid then
                return false
            end
            if self.win and self.win:CheckKeyState(0x4E, {0x11, 0x10}, 255) then
                print('CTRL + SHIFT + N')
            end
            return false
        end,
        draw = function(window)
            if not window.valid then
                return false
            end
            window:DrawRect({x = 0, y = 0, width = window.width, height = window.height, color = 0x7fff0000})
            return false
        end,
    })

    self.status = status
    self.win = win

    if not win then
        return
    end

    win:ClearChildren()

    local label
    local icon = win:AddImage({
        name = 'demoIcon',
        x = 12,
        y = 12,
        width = 32,
        height = 32,
        image = 12345,
        imageHover = 12346,
        imagePress = 12347,
        color = -1,
        visible = true,
        onClick = function(control, flags)
            self.clickCount = self.clickCount + 1
            if label and label.valid then
                label:Set({ text = '点击次数: ' .. self.clickCount })
            end
            if win.valid then
                win:ShowTips('Lua UI 点击: ' .. self.clickCount)
            end
            return true
        end,
        onHover = function(control, flags)
            if win.valid then
                win:ShowTips('Lua UI demoIcon:onHover')
            end
            return true
        end,
    })

    label = win:AddText({
        name = 'demoText',
        x = 52,
        y = 18,
        width = 150,
        height = 18,
        text = '点击图标',
        font = 0,
        color = 0,
        hitable = true,
        visible = true,
        onClick = function(control, flags)
            control:Set({ text = '文字也可点击' })
            return true
        end,
    })

    self.staleControl = icon
    win:ClearChildren()

    if self.staleControl and not self.staleControl:Set({ x = 16 }) then
        print('旧控件引用已安全失效')
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
            WinMgr.CliSendMsg(nameInput.text, 1, 1, '系统提示')
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
        {0x11, 0x10},
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