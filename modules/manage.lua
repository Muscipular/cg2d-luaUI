---@class ManageModule : ModuleBase
local ManageModule = ModuleBase:extend('manage')

local WIN_MANAGE = 1000
local WINDOW_WIDTH = 240
local WINDOW_HEIGHT = 110
local COMMAND = '/moduleManage'
local MODULE_COMMANDS = {
    ['/load'] = { method = 'loadModule', text = '加载' },
    ['/reload'] = { method = 'reloadModule', text = '重载' },
    ['/unload'] = { method = 'unloadModule', text = '卸载' },
}

local function trim(value)
    value = tostring(value or '')
    return string.gsub(value, '^%s*(.-)%s*$', '%1')
end

function ManageModule:_moduleName()
    if not self.input or not self.input.valid then
        return ''
    end
    return trim(self.input.text)
end

function ManageModule:_run(action)
    local name = self:_moduleName()
    if name == '' then
        return true
    end
    self:_runModuleAction(action, name)
    return true
end

function ManageModule:_runModuleAction(action, name)
    local ok, result, err = pcall(function()
        return self[action.method](self, name)
    end)

    if ok and result then
        self:cliSendMsg(action.text .. '成功: ' .. name)
        return true
    end

    local reason = ok and err or result
    if reason then
        self:cliSendMsg(action.text .. '失败: ' .. name .. '，' .. tostring(reason))
    else
        self:cliSendMsg(action.text .. '失败: ' .. name)
    end
    return false
end

function ManageModule:_runCommand(text)
    local command, name = string.match(trim(text), '^(%S+)%s+(.+)$')
    local action = MODULE_COMMANDS[command]
    if not action then
        return nil
    end

    name = trim(name)
    if name == '' then
        return 1
    end

    self:_runModuleAction(action, name)
    return 1
end

function ManageModule:_addButton(win, name, x, text, onClick)
    win:AddText({
        name = name,
        x = x,
        y = 76,
        width = 40,
        height = 18,
        text = text,
        font = 1,
        color = 4,
        hitable = true,
        visible = true,
        onClick = onClick,
    })
end

function ManageModule:_openWindow()
    if self.win and self.win.valid then
        return
    end

    local x = math.floor((CONST.Screen.Width - WINDOW_WIDTH) / 2)
    local y = math.floor((CONST.Screen.Height - WINDOW_HEIGHT) / 2)
    local status, win = self:newWindow({
        dragMove = 1,
        id = WIN_MANAGE,
        x = x,
        y = y,
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        layer = 4,
        draw = function(window)
            if not window.valid then
                return false
            end
            window:DrawRect({ x = 0, y = 0, width = window.width, height = window.height, color = 0x7f000000 })
            return false
        end,
    })

    self.status = status
    self.win = win

    if not win then
        return
    end

    win:ClearChildren()

    win:AddText({
        name = 'title',
        x = 10,
        y = 10,
        width = 220,
        height = 18,
        text = 'Module管理',
        font = 0,
        color = 1,
        visible = true,
    })

    self.input = win:AddTextInput({
        name = 'moduleName',
        x = 10,
        y = 38,
        width = 220,
        height = 22,
        text = '',
        font = 0,
        color = 2,
        maxLength = 64,
        visible = true,
        hitable = true,
    })

    self:_addButton(win, 'load', 10, '加载', function()
        return self:_run(MODULE_COMMANDS['/load'])
    end)

    self:_addButton(win, 'reload', 60, '重载', function()
        return self:_run(MODULE_COMMANDS['/reload'])
    end)

    self:_addButton(win, 'unload', 110, '卸载', function()
        return self:_run(MODULE_COMMANDS['/unload'])
    end)

    self:_addButton(win, 'close', 160, '关闭窗口', function()
        if self.win and self.win.valid then
            self:releaseWindow(self.win)
        end
        self.win = nil
        self.input = nil
        return true
    end)
end

function ManageModule:onLoad()
    self.status = nil
    self.win = nil
    self.input = nil
    self:onChatMessage(function(text)
        local result = self:_runCommand(text)
        if result then
            return result
        end
        if text ~= COMMAND then
            return nil
        end
        if self.win and self.win.valid then
            return 1
        end
        self:_openWindow()
        return 1
    end)
end

function ManageModule:onUnload()
    self.status = nil
    self.win = nil
    self.input = nil
end

return ManageModule