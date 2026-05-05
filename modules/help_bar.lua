---@class HelpBarModule : ModuleBase
local HelpBarModule = ModuleBase:extend('help_bar')

local WIN_HELP_BAR = 21001
local WINDOW_WIDTH = 90
local WINDOW_TOP = 80
local WINDOW_RIGHT = 20
local BUTTON_WIDTH = 80
local BUTTON_HEIGHT = 32
local BUTTON_PADDING_X = 5
local BUTTON_PADDING_Y = 4
local BUTTON_PITCH = 36

local BACKGROUND = {
    image = 'images/help_bar_bg.png',
    width = 90,
    sourceHeight = 124,
    topHeight = 15,
    bottomHeight = 15,
}

local DEFAULT_BUTTON_IMAGES = {
    normal = 'images/help_bar_button.png',
    hover = 'images/help_bar_button_hover.png',
    press = 'images/help_bar_button_press.png',
}

local BUTTONS = {
    {
        text = '按钮1',
        color = 0,
        packetData = 'AAA',
        images = nil,
    },
    {
        text = '按钮2',
        color = 0,
        packetData = 'AAA',
        images = nil,
    },
    {
        text = '按钮3',
        color = 0,
        packetData = 'AAA',
        images = nil,
    },
    {
        text = '按钮4',
        color = 0,
        packetData = 'AAA',
        images = nil,
    },
}

local function button_images(button)
    local images = button.images or DEFAULT_BUTTON_IMAGES
    return images.normal or DEFAULT_BUTTON_IMAGES.normal,
        images.hover or images.normal or DEFAULT_BUTTON_IMAGES.hover,
        images.press or images.normal or DEFAULT_BUTTON_IMAGES.press
end

local function packet_data(button)
    if type(button.packetData) == 'string' then
        return button.packetData
    end
    return ''
end

function HelpBarModule:_addBackground(win, windowHeight)
    local topHeight = BACKGROUND.topHeight
    local bottomHeight = BACKGROUND.bottomHeight
    local middleSourceHeight = BACKGROUND.sourceHeight - topHeight - bottomHeight
    local middleHeight = windowHeight - topHeight - bottomHeight

    win:AddPngImage({
        name = 'helpBarBgTop',
        x = 0,
        y = 0,
        width = BACKGROUND.width,
        height = topHeight,
        image = BACKGROUND.image,
        imageRect = { x = 0, y = 0, width = BACKGROUND.width, height = topHeight },
        visible = true,
        hitable = false,
    })

    if middleHeight > 0 and middleSourceHeight > 0 then
        win:AddPngImage({
            name = 'helpBarBgMiddle',
            x = 0,
            y = topHeight,
            width = BACKGROUND.width,
            height = middleHeight,
            image = BACKGROUND.image,
            imageRect = { x = 0, y = topHeight, width = BACKGROUND.width, height = middleSourceHeight },
            visible = true,
            hitable = false,
        })
    end

    win:AddPngImage({
        name = 'helpBarBgBottom',
        x = 0,
        y = windowHeight - bottomHeight,
        width = BACKGROUND.width,
        height = bottomHeight,
        image = BACKGROUND.image,
        imageRect = { x = 0, y = BACKGROUND.sourceHeight - bottomHeight, width = BACKGROUND.width, height = bottomHeight },
        visible = true,
        hitable = false,
    })
end

function HelpBarModule:_addButton(win, button, index)
    local y = BUTTON_PADDING_Y / 2 + (index - 1) * BUTTON_PITCH + 15
    local image, imageHover, imagePress = button_images(button)

    win:AddPngImage({
        name = 'helpBarButton' .. tostring(index),
        x = BUTTON_PADDING_X,
        y = y,
        width = BUTTON_WIDTH,
        height = BUTTON_HEIGHT,
        image = image,
        imageHover = imageHover,
        imagePress = imagePress,
        visible = true,
        onClick = function()
            self:sendPacket('HBar ' .. packet_data(button))
            return true
        end,
    })

    win:AddText({
        name = 'helpBarButtonText' .. tostring(index),
        x = BUTTON_PADDING_X + 8,
        y = y + 8,
        width = BUTTON_WIDTH,
        height = BUTTON_HEIGHT,
        text = button.text or '',
        font = 0,
        color = button.color or 0,
        hitable = false,
        visible = true,
    })
end

function HelpBarModule:onLoad()
    self:onSceneStateChanged(function(sceneType, sceneState)
        if sceneType ~= 9 then
            if self.win && self.win.valid then
                self.win:Close();
            end
            return;
        end
        local windowHeight = #BUTTONS * (BUTTON_HEIGHT + 4) + 30
        local x = CONST.Screen.Width - WINDOW_RIGHT - WINDOW_WIDTH

        local status, win = self:newWindow({
            id = WIN_HELP_BAR,
            x = x,
            y = WINDOW_TOP,
            width = WINDOW_WIDTH,
            height = windowHeight,
            layer = 4,
        })

        self.status = status
        self.win = win

        if not win then
            return
        end

        self:_addBackground(win, windowHeight)

        for i = 1, #BUTTONS do
            self:_addButton(win, BUTTONS[i], i)
        end
    end)
end

function HelpBarModule:onUnload()
    self.status = nil
    self.win = nil
end

return HelpBarModule
