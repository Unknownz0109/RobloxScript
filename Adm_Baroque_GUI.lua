
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local BACKGROUNDS = {
    Mid = "rbxassetid://96820178950061",
    Left = "rbxassetid://124944322744246",
    Top = "rbxassetid://130847345134447",
}

local CONFIG = {
    Name = "BaroqueRoyaleV2",
    DefaultSize = Vector2.new(560, 445),
    MinimumSize = Vector2.new(440, 445),
    MaximumSize = Vector2.new(760, 534),
    ResizeMargin = 24,
    SidebarWidth = 118,
    HeaderHeight = 80,
    AnimationSpeed = 0.20,
}

local ASSETS = {
    HeaderLogo = "rbxassetid://103666538934385",
    TabIcons = {
        Main    = "rbxassetid://139070138678091",
        Players = "rbxassetid://95477407309927",
        Chat    = "rbxassetid://78971625353549",
        Settings = "rbxassetid://117588610282699",
        Pets    = "rbxassetid://134726271242439",
        Spawner = "rbxassetid://134488633019348",
    },
}

local ASSET_STYLE = {
    HeaderIconSize = 25,
    HeaderIconLeft = 12,
    TabIconSize = 18,
    TabIconLeft = 12,
    TabTextIndent = 5,
    IconTransparency = 0,
}

local C = {
    Background = Color3.fromRGB(17, 12, 20),
    Window = Color3.fromRGB(25, 17, 29),
    Sidebar = Color3.fromRGB(21, 14, 24),
    Surface = Color3.fromRGB(33, 23, 36),
    SurfaceHover = Color3.fromRGB(48, 33, 48),
    SurfacePressed = Color3.fromRGB(62, 43, 54),
    Gold = Color3.fromRGB(211, 170, 91),
    GoldBright = Color3.fromRGB(255, 218, 143),
    GoldDark = Color3.fromRGB(117, 79, 40),
    Ivory = Color3.fromRGB(245, 231, 210),
    Muted = Color3.fromRGB(166, 148, 158),
    Green = Color3.fromRGB(116, 190, 133),
    Red = Color3.fromRGB(212, 112, 112),
    Border = Color3.fromRGB(92, 65, 72),
}

local existing = playerGui:FindFirstChild(CONFIG.Name)
if existing then
    existing:Destroy()
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = CONFIG.Name
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local alive = true
local minimized = false
local activeTab = nil
local tabButtons = {}
local tabPages = {}
local connections = {}
local function track(connection)
    table.insert(connections, connection)
    return connection
end

local function tween(object, duration, properties, style, direction)
    if not alive or not object or not object.Parent then
        return nil
    end
    local info = TweenInfo.new(
        duration or CONFIG.AnimationSpeed,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local function corner(object, radius)
    local ui = Instance.new("UICorner")
    ui.CornerRadius = UDim.new(0, radius or 8)
    ui.Parent = object
    return ui
end

local function stroke(object, color, thickness, transparency)
    local ui = Instance.new("UIStroke")
    ui.Color = color or C.Border
    ui.Thickness = thickness or 1
    ui.Transparency = transparency or 0
    ui.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ui.Parent = object
    return ui
end

-- BORDER GLOW
local RunService = game:GetService("RunService")
local function addChasingGlow(object, speed)
    local glow = Instance.new("UIStroke")
    glow.Name = "RoyalChasingGlow"
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Thickness = 2
    glow.Transparency = 0.18
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = object

    local gradient = Instance.new("UIGradient")
    gradient.Name = "RoyalGlowGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.GoldDark),
        ColorSequenceKeypoint.new(0.30, C.Gold),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.70, C.GoldBright),
        ColorSequenceKeypoint.new(1, C.GoldDark),
    })

    gradient.Rotation = 0
    gradient.Parent = glow
    local connection
    local rotation = 0
    local degreesPerSecond = 360 / (speed or 2.4)

    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not alive or not object.Parent or not glow.Parent then
            if connection then
                connection:Disconnect()
            end
            return
        end
        rotation = (rotation + degreesPerSecond * deltaTime) % 360
        gradient.Rotation = rotation
    end)
    track(connection)
    return glow
end

local function padding(object, left, right, top, bottom)
    local ui = Instance.new("UIPadding")
    ui.PaddingLeft = UDim.new(0, left or 0)
    ui.PaddingRight = UDim.new(0, right or 0)
    ui.PaddingTop = UDim.new(0, top or 0)
    ui.PaddingBottom = UDim.new(0, bottom or 0)
    ui.Parent = object
    return ui
end

local function label(parent, text, size, color, font)
    local object = Instance.new("TextLabel")
    object.BackgroundTransparency = 1
    object.Text = text or ""
    object.TextColor3 = color or C.Ivory
    object.TextSize = size or 12
    object.Font = font or Enum.Font.Gotham
    object.TextXAlignment = Enum.TextXAlignment.Left
    object.TextYAlignment = Enum.TextYAlignment.Center
    object.TextTruncate = Enum.TextTruncate.AtEnd
    object.Parent = parent
    return object
end

local function addBackground(parent, imageId, objectName, transparency)
    local background = Instance.new("ImageLabel")
    background.Name = objectName
    background.BackgroundTransparency = 1
    background.BorderSizePixel = 0
    background.Image = imageId
    background.ImageTransparency = transparency or 0
    background.ScaleType = Enum.ScaleType.Crop
    background.AnchorPoint = Vector2.zero
    background.Position = UDim2.fromScale(0, 0)
    background.Size = UDim2.fromScale(1, 1)
    background.ZIndex = 1
    background.Active = false
    background.Selectable = false
    background.Parent = parent
    return background
end

-- WINDOW
local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 13)
window.Size = UDim2.fromOffset(
    CONFIG.DefaultSize.X,
    CONFIG.DefaultSize.Y
)
window.BackgroundColor3 = C.Window
window.BorderSizePixel = 0
window.ClipsDescendants = false
window.Parent = screenGui

local midBackground = addBackground(
    window,
    BACKGROUNDS.Mid,
    "BackgroundMid",
    0.12
)
corner(window, 12)
stroke(window, C.GoldDark, 1.4)

local windowScale = Instance.new("UIScale")
windowScale.Scale = 0.94
windowScale.Parent = window
local windowGradient = Instance.new("UIGradient")
windowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 21, 35)),
    ColorSequenceKeypoint.new(0.5, C.Window),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 13, 23)),
})
windowGradient.Rotation = 35
windowGradient.Parent = window

local innerBorder = Instance.new("Frame")
innerBorder.Name = "InnerGoldBorder"
innerBorder.Position = UDim2.fromOffset(5, 5)
innerBorder.Size = UDim2.new(1, -10, 1, -10)
innerBorder.BackgroundTransparency = 1
innerBorder.BorderSizePixel = 0
innerBorder.Parent = window
corner(innerBorder, 9)
stroke(innerBorder, C.Gold, 0.6, 0.72)

-- TOP BAR IMAGE
local topBarImage = Instance.new("ImageLabel")
topBarImage.Name = "TopBarImage"
topBarImage.BackgroundTransparency = 1
topBarImage.BorderSizePixel = 0
topBarImage.Image = "rbxassetid://114297105533620"
topBarImage.ImageTransparency = 0
topBarImage.ScaleType = Enum.ScaleType.Stretch
topBarImage.AnchorPoint = Vector2.new(0, 0)
topBarImage.Position = UDim2.fromOffset(-15, -26)
topBarImage.Size = UDim2.new(1, 30, 0, CONFIG.HeaderHeight)
topBarImage.ZIndex = 5
topBarImage.Active = true
topBarImage.Selectable = false
topBarImage.Parent = window

-- REGAL CURTAIN TOP BAR
local regalCurtain = Instance.new("ImageLabel")
regalCurtain.Name = "RegalCurtain"
regalCurtain.BackgroundTransparency = 1
regalCurtain.BorderSizePixel = 0
regalCurtain.Image = "rbxassetid://131286102253153"
regalCurtain.ScaleType = Enum.ScaleType.Stretch
regalCurtain.Position = UDim2.fromOffset(CONFIG.SidebarWidth, 35)
regalCurtain.Size = UDim2.new(1, -CONFIG.SidebarWidth + 15, 0, 120)
regalCurtain.ZIndex = 10
regalCurtain.Active = false
regalCurtain.Selectable = false
regalCurtain.Parent = window

-- BODY, SIDEBAR, CONTENT
local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.fromOffset(0, CONFIG.HeaderHeight - 26)
body.Size = UDim2.new(1, 0, 1, -(CONFIG.HeaderHeight - 26))
body.BackgroundTransparency = 1
body.Parent = window

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, CONFIG.SidebarWidth, 1, 0)
sidebar.BackgroundColor3 = C.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = body

local leftBackground = addBackground(
    sidebar,
    BACKGROUNDS.Left,
    "BackgroundLeft",
    0.08
)

local sidebarDivider = Instance.new("Frame")
sidebarDivider.AnchorPoint = Vector2.new(1, 0)
sidebarDivider.Position = UDim2.new(1, 0, 0, 0)
sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
sidebarDivider.BackgroundColor3 = C.GoldDark
sidebarDivider.BackgroundTransparency = 0.35
sidebarDivider.BorderSizePixel = 0
sidebarDivider.Parent = sidebar

local menuCaption = label(
    sidebar,
    "COLLECTION",
    8,
    C.Gold,
    Enum.Font.GothamBold
)
menuCaption.Position = UDim2.fromOffset(13, 13)
menuCaption.Size = UDim2.new(1, -22, 0, 16)

local tabHolder = Instance.new("Frame")
tabHolder.Name = "TabHolder"
tabHolder.Position = UDim2.fromOffset(7, 38)
tabHolder.Size = UDim2.new(1, -14, 1, -132)
tabHolder.BackgroundTransparency = 1
tabHolder.ClipsDescendants = true
tabHolder.Parent = sidebar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 3)
tabPadding.PaddingRight = UDim.new(0, 3)
tabPadding.Parent = tabHolder

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabHolder

-- CROWN ASSET AND FOOTER
local crownImage = Instance.new("ImageLabel")
crownImage.Name = "RoyalCrown"
crownImage.Parent = sidebar
crownImage.BackgroundTransparency = 1
crownImage.BorderSizePixel = 0
crownImage.Image = "rbxassetid://116143036814069"
crownImage.ImageTransparency = 0
crownImage.ScaleType = Enum.ScaleType.Fit
crownImage.AnchorPoint = Vector2.new(0.5, 0.5)
crownImage.Size = UDim2.fromOffset(76, 76)
crownImage.Position = UDim2.new(0.5, 0, 1, -66)
crownImage.ZIndex = 5

local sidebarFooter = label(
    sidebar,
    "Dusty Gramophone",
    9,
    Color3.fromRGB(212, 175, 55),
    Enum.Font.GothamBold
)

sidebarFooter.Name = "RoyalFooter"
sidebarFooter.Position = UDim2.new(0, 5, 1, -25)
sidebarFooter.Size = UDim2.new(1, -10, 0, 16)
sidebarFooter.TextXAlignment = Enum.TextXAlignment.Center
sidebarFooter.TextColor3 = Color3.fromRGB(212, 175, 55)
sidebarFooter.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
sidebarFooter.TextStrokeTransparency = 0
sidebarFooter.ZIndex = 6
crownImage.Visible = true
sidebarFooter.Visible = true

local footerReserve = Instance.new("Frame")
footerReserve.Name = "FooterReserve"
footerReserve.BackgroundTransparency = 1
footerReserve.BorderSizePixel = 0
footerReserve.Position = UDim2.new(0, 0, 1, -132)
footerReserve.Size = UDim2.new(1, 0, 0, 132)
footerReserve.ZIndex = 4
footerReserve.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.new(0, CONFIG.SidebarWidth, 0, 0)
content.Size = UDim2.new(1, -CONFIG.SidebarWidth, 1, 0)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.Parent = body
local pageNames = {
    "Main",
    "Players",
    "Chat",
    "Settings",
    "Pets",
    "Spawner",
}
local pageDescriptions = {
    Main = "Your royal control center.",
    Players = "Browse the local demo player list.",
    Chat = "Preview chat controls and message presets.",
    Settings = "Customize your interface experience.",
    Pets = "Manage your local demo pet collection.",
    Spawner = "Preview pet spawner controls.",
}

-- NOTIFICATION
local notice = Instance.new("Frame")
notice.Name = "Notification"
notice.AnchorPoint = Vector2.new(1, 1)
notice.Position = UDim2.new(1, -12, 1, -12)
notice.Size = UDim2.fromOffset(215, 43)
notice.BackgroundColor3 = C.Surface
notice.BackgroundTransparency = 1
notice.Visible = false
notice.ZIndex = 20
notice.Parent = window
corner(notice, 8)
local noticeStroke = stroke(notice, C.Gold, 1, 0.2)
local noticeText = label(notice, "", 10, C.Ivory)
noticeText.Position = UDim2.fromOffset(12, 0)
noticeText.Size = UDim2.new(1, -22, 1, 0)
noticeText.ZIndex = 21
local noticeToken = 0
local function notify(message, isError)
    if not alive then return end
    noticeToken += 1
    local token = noticeToken
    notice.Visible = true
    noticeText.Text = tostring(message)
    noticeStroke.Color = isError and C.Red or C.Gold
    notice.BackgroundTransparency = 1
    notice.Position = UDim2.new(1, 15, 1, -12)

    tween(notice, 0.18, {
        BackgroundTransparency = 0.03,
        Position = UDim2.new(1, -12, 1, -12),
    })

    task.delay(2.2, function()
        if not alive or token ~= noticeToken then return end
        tween(notice, 0.16, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 15, 1, -12),
        })
        task.delay(0.18, function()
            if alive and token == noticeToken then
                notice.Visible = false
            end
        end)
    end)
end

-- BUTTON, TEXTBOX, TOGGLE
local function makeAction(parent, text, callback, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Name = options.Name or "Action"
    button.Text = ""
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.BackgroundColor3 = options.Accent and
        Color3.fromRGB(57, 39, 43) or C.Surface
    button.ClipsDescendants = true
    button.Parent = parent

    corner(button, 8)
    local outline = stroke(
        button,
        options.Accent and C.Gold or C.Border,
        1,
        options.Accent and 0.15 or 0.42
    )
    local chasingGlow = addChasingGlow(
        button,
        options.Accent and 1.6 or 2.4
    )
    local buttonTitle = label(
        button,
        text,
        10,
        C.Ivory,
        Enum.Font.GothamSemibold
    )
    buttonTitle.Position = UDim2.fromOffset(11, 5)
    buttonTitle.Size = UDim2.new(1, -19, 1, -10)
    buttonTitle.TextWrapped = true

    local enabled = false

    track(button.MouseEnter:Connect(function()
        if not alive then return end
        tween(button, 0.12, { BackgroundColor3 = C.SurfaceHover })
        tween(outline, 0.12, { Color = C.Gold, Transparency = 0.05 })
    end))

    track(button.MouseLeave:Connect(function()
        if not alive then return end
        tween(button, 0.15, {
            BackgroundColor3 = options.Accent
                and Color3.fromRGB(57, 39, 43)
                or C.Surface
        })
        tween(outline, 0.15, {
            Color = options.Accent and C.Gold or C.Border,
            Transparency = options.Accent and 0.15 or 0.42,
        })
    end))

    track(button.MouseButton1Down:Connect(function()
        if alive then
            tween(button, 0.06, {
                BackgroundColor3 = C.SurfacePressed
            })
        end
    end))

    track(button.Activated:Connect(function()
        if not alive then return end
        tween(button, 0.10, {
            BackgroundColor3 = C.SurfaceHover
        })

        local flash = Instance.new("Frame")
        flash.AnchorPoint = Vector2.new(0.5, 0.5)
        flash.Position = UDim2.fromScale(0.5, 0.5)
        flash.Size = UDim2.fromOffset(0, 0)
        flash.BackgroundColor3 = C.GoldBright
        flash.BackgroundTransparency = 0.72
        flash.BorderSizePixel = 0
        flash.ZIndex = button.ZIndex + 2
        flash.Parent = button
        corner(flash, 100)
        tween(flash, 0.24, {
            Size = UDim2.new(1.5, 0, 2, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.26, function()
            if flash.Parent then flash:Destroy() end
        end)
        if callback then
            local ok, err = pcall(callback, button)
            if not ok then
                warn("[BaroqueRoyale] Button callback error:", err)
                notify("An action encountered an error.", true)
            end
        end
    end))
    return button
end

local function makeToggle(parent, text, defaultValue, callback)
    local holder = Instance.new("Frame")
    holder.Name = "Toggle"
    holder.BackgroundColor3 = C.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder, 8)
    stroke(holder, C.Border, 1, 0.45)

    local chasingGlow = addChasingGlow(holder, 2.8)
    local toggleLabel = label(
        holder,
        text,
        10,
        C.Ivory,
        Enum.Font.GothamMedium
    )
    toggleLabel.Position = UDim2.fromOffset(10, 0)
    toggleLabel.Size = UDim2.new(1, -57, 1, 0)

    local trackFrame = Instance.new("Frame")
    trackFrame.AnchorPoint = Vector2.new(1, 0.5)
    trackFrame.Position = UDim2.new(1, -9, 0.5, 0)
    trackFrame.Size = UDim2.fromOffset(31, 17)
    trackFrame.BackgroundColor3 = C.Background
    trackFrame.BorderSizePixel = 0
    trackFrame.Parent = holder
    corner(trackFrame, 10)
    stroke(trackFrame, C.Border, 0.8, 0.2)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(11, 11)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = C.Muted
    knob.BorderSizePixel = 0
    knob.Parent = trackFrame
    corner(knob, 10)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.fromScale(1, 1)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = holder
    local state = defaultValue == true
    local function render()
        tween(trackFrame, 0.16, {
            BackgroundColor3 = state and C.GoldDark or C.Background
        })
        tween(knob, 0.16, {
            Position = state
                and UDim2.new(1, -14, 0, 3)
                or UDim2.fromOffset(3, 3),
            BackgroundColor3 = state and C.GoldBright or C.Muted,
        })
    end
    render()
    track(hitbox.MouseEnter:Connect(function()
        if alive then
            tween(holder, 0.12, { BackgroundColor3 = C.SurfaceHover })
        end
    end))
    track(hitbox.MouseLeave:Connect(function()
        if alive then
            tween(holder, 0.12, { BackgroundColor3 = C.Surface })
        end
    end))
    track(hitbox.Activated:Connect(function()
        state = not state
        render()

        if callback then
            callback(state)
        end
    end))
    return holder, function()
        return state
    end
end

local function makeInput(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Name = "Input"
    box.ClearTextOnFocus = false
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextSize = 10
    box.Font = Enum.Font.Gotham
    box.TextColor3 = C.Ivory
    box.PlaceholderColor3 = C.Muted
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.BackgroundColor3 = C.Background
    box.BorderSizePixel = 0
    box.Parent = parent

    corner(box, 7)
    local outline = stroke(box, C.Border, 1, 0.3)
    padding(box, 10, 8, 0, 0)

    track(box.Focused:Connect(function()
        if alive then
            tween(outline, 0.12, {
                Color = C.Gold,
                Transparency = 0,
            })
        end
    end))

    track(box.FocusLost:Connect(function(enterPressed)
        if alive then
            tween(outline, 0.12, {
                Color = C.Border,
                Transparency = 0.3,
            })
        end
        if callback then
            callback(box.Text, enterPressed)
        end
    end))
    return box
end

-- PAGES AND GRID
local function createPage(name, order)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Position = UDim2.fromOffset(0, 0)
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.GoldDark
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Visible = false
    page.ClipsDescendants = true
    page.LayoutOrder = order
    page.Parent = content

    padding(page, 13, 13, 12, 15)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    local curtainSlot = Instance.new("Frame")
    curtainSlot.Name = "RegalCurtainSlot"
    curtainSlot.BackgroundTransparency = 1
    curtainSlot.BorderSizePixel = 0
    curtainSlot.Size = UDim2.new(1, 0, 0, 100)
    curtainSlot.LayoutOrder = 0
    curtainSlot.Parent = page

    local gridContainer = Instance.new("Frame")
    gridContainer.Name = "Controls"
    gridContainer.Size = UDim2.new(1, 0, 0, 10)
    gridContainer.AutomaticSize = Enum.AutomaticSize.Y
    gridContainer.BackgroundTransparency = 1
    gridContainer.LayoutOrder = 1
    gridContainer.Parent = page

    local grid = Instance.new("UIGridLayout")
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.FillDirectionMaxCells = 2
    grid.CellPadding = UDim2.fromOffset(8, 8)
    grid.CellSize = UDim2.new(0.5, -4, 0, 48)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = gridContainer

    tabPages[name] = {
        Page = page,
        Grid = gridContainer,
        Layout = grid,
    }
    return tabPages[name]
end

for index, name in ipairs(pageNames) do
    createPage(name, index)
end

local function addAction(tabName, text, callback, options)
    local page = tabPages[tabName]
    if not page then return end
    local button = makeAction(
        page.Grid,
        text,
        callback,
        options
    )
    button.LayoutOrder = #page.Grid:GetChildren()
    return button
end

local function addInput(tabName, placeholder, onSubmit)
    local page = tabPages[tabName]
    if not page then return end
    local box = makeInput(page.Grid, placeholder, onSubmit)
    box.Size = UDim2.new(1, 0, 0, 48)
    box.LayoutOrder = #page.Grid:GetChildren()
    return box
end

local function addToggle(tabName, text, defaultValue, callback)
    local page = tabPages[tabName]
    if not page then return end
    local holder, getState = makeToggle(
        page.Grid,
        text,
        defaultValue,
        callback
    )
    holder.Size = UDim2.new(1, 0, 0, 48)
    holder.LayoutOrder = #page.Grid:GetChildren()
    return holder, getState
end

-- TAB NAVIGATION
local function addTabIcon(button, tabName)
    local imageId = ASSETS.TabIcons[tabName]
    if not imageId then
        return nil
    end
    local icon = Instance.new("ImageLabel")
    icon.Name = "TabIcon"
    icon.BackgroundTransparency = 1
    icon.Image = imageId
    icon.ImageTransparency = ASSET_STYLE.IconTransparency
    icon.Size = UDim2.fromOffset(
        ASSET_STYLE.TabIconSize,
        ASSET_STYLE.TabIconSize
    )
    icon.Position = UDim2.new(
        0,
        ASSET_STYLE.TabIconLeft,
        0.5,
        0
    )
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = button.ZIndex + 1
    icon.Parent = button
    return icon
end

local function selectTab(name)
    if not alive or activeTab == name then return end
    activeTab = name
    for tabName, pageData in pairs(tabPages) do
        local page = pageData.Page
        local buttonData = tabButtons[tabName]

        if tabName == name then
            page.Visible = true
            page.Position = UDim2.fromOffset(12, 0)
            page.BackgroundTransparency = 1
            tween(page, 0.19, {
                Position = UDim2.fromOffset(0, 0),
            }, Enum.EasingStyle.Quint)
            if buttonData then
                tween(buttonData.Button, 0.16, {
                    BackgroundColor3 = Color3.fromRGB(56, 39, 45),
                })
                tween(buttonData.Label, 0.16, {
                    TextColor3 = C.GoldBright,
                })
                tween(buttonData.Icon, 0.16, {
                    ImageColor3 = C.GoldBright,
                })
            end
        else

            page.Visible = false
            if buttonData then
                tween(buttonData.Button, 0.14, {
                    BackgroundColor3 = C.Sidebar,
                })
                tween(buttonData.Label, 0.14, {
                    TextColor3 = C.Muted,
                })
                tween(buttonData.Icon, 0.14, {
                    ImageColor3 = C.Muted,
                })
            end
        end
    end
end

for index, name in ipairs(pageNames) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = C.Sidebar
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = index
    button.Parent = tabHolder
    corner(button, 7)
    local chasingGlow = addChasingGlow(button, 2.8)
    local icon = addTabIcon(button, name)
    local tabLabel = label(
        button,
        name,
        10,
        C.Muted,
        Enum.Font.GothamMedium
    )

    tabLabel.Position = UDim2.fromOffset(39, 0)
    tabLabel.Size = UDim2.new(1, -45, 1, 0)
    tabButtons[name] = {
        Button = button,
        Label = tabLabel,
        Icon = icon,
    }

    track(button.MouseEnter:Connect(function()
        if alive and activeTab ~= name then
            tween(button, 0.12, {
                BackgroundColor3 = C.SurfaceHover
            })
            tween(icon, 0.12, { ImageColor3 = C.Ivory })
            tween(tabLabel, 0.12, { TextColor3 = C.Ivory })
        end
    end))

    track(button.MouseLeave:Connect(function()
        if alive and activeTab ~= name then
            tween(button, 0.12, {
                BackgroundColor3 = C.Sidebar
            })
            tween(icon, 0.12, { ImageColor3 = C.Muted })
            tween(tabLabel, 0.12, { TextColor3 = C.Muted })
        end
    end))

    track(button.Activated:Connect(function()
        selectTab(name)
    end))
end

-- MAIN TAB
addInput("Main", "Partner username...", function(value)
    if value ~= "" then
        notify("Partner saved locally: " .. value)
    end
end)

addInput("Main", "Accept delay (seconds)...", function(value)
    local number = tonumber(value)
    if number then
        notify(("Accept delay: %.2fs"):format(
            math.clamp(number, 0, 999)
        ))
    else
        notify("Enter a valid number.", true)
    end
end)

addInput("Main", "Confirm delay (seconds)...", function(value)
    local number = tonumber(value)
    if number then
        notify(("Confirm delay: %.2fs"):format(
            math.clamp(number, 0, 999)
        ))
    else
        notify("Enter a valid number.", true)
    end
end)

addToggle("Main", "Auto Spectate", false, function(state)
    notify("Auto Spectate demo: " .. (state and "ON" or "OFF"))
end)
addToggle("Main", "Remove Partner Pets", false, function(state)
    notify("Local demo toggle: " .. (state and "ON" or "OFF"))
end)
addToggle("Main", "Partner Emoji", false, function(state)
    notify("Partner Emoji demo: " .. (state and "ON" or "OFF"))
end)

addAction("Main", "Start Trade", function()
    notify("Trade action is a UI demo only.")
end, { Accent = true })

addAction("Main", "Clear Trade", function()
    notify("Demo trade panel cleared.")
end)
addAction("Main", "Add Random Item", function()
    notify("Random item demo selected.")
end)
addAction("Main", "Block Player", function()
    notify("No player was blocked. UI demo only.")
end)
addAction("Main", "Make Partner Accept", function()
    notify("Demo action only; no request was sent.")
end)
addAction("Main", "Make Partner Unaccept", function()
    notify("Demo action only; no request was sent.")
end)
addAction("Main", "Toggle Noclip", function()
    notify("Noclip is not implemented in this prototype.")
end)
addAction("Main", "Add Random Emoji", function()
    notify("Random emoji demo.")
end)
addAction("Main", "Delete Fake Players", function()
    notify("No real players affected.")
end)
addAction("Main", "Change Username", function()
    notify("Username change is a UI demo.")
end)

-- PLAYERS TAB
local selectedPlayerName = nil

local playerSearch = addInput("Players", "Search player...", function(value)
    notify(value == "" and "Showing all demo players." or "Search: " .. value)
end)

addAction("Players", "Select Player", function()
    if selectedPlayerName then
        notify("Selected: " .. selectedPlayerName)
    else
        notify("Choose a player from the demo list first.", true)
    end
end, { Accent = true })
addAction("Players", "Block Player (Demo)", function()
    if selectedPlayerName then
        notify("Demo only: " .. selectedPlayerName .. " was not blocked.")
    else
        notify("Select a demo player first.", true)
    end
end)

for _, demoName in ipairs({
    "RoyalGuest",
    "VelvetKnight",
    "GoldenRose",
    "MoonlitDuke",
    "CrimsonMuse",
    "IvoryPhantom",
}) do
    addAction("Players", "♙  " .. demoName, function()
        selectedPlayerName = demoName
        notify("Selected demo player: " .. demoName)
    end)
end

-- CHAT TAB
addInput("Chat", "Search player...", function(value)
    if value ~= "" then
        notify("Chat recipient search: " .. value)
    end
end)

local customMessage = addInput("Chat", "Type a demo message...", function(value)
    if value ~= "" then
        notify("Message draft saved locally.")
    end
end)

addAction("Chat", "Send Chat (Demo)", function()
    if customMessage and customMessage.Text ~= "" then
        notify("Message preview: " .. customMessage.Text)
    else
        notify("Write a message first.", true)
    end
end, { Accent = true })
for _, preset in ipairs({
    "Hello there!",
    "Nice collection!",
    "Good game!",
    "Thank you!",
}) do
    addAction("Chat", preset, function()
        if customMessage then
            customMessage.Text = preset
        end
        notify("Preset loaded into message box.")
    end)
end

-- SETTINGS TAB
local keybinds = {
    selectPartner = Enum.KeyCode.P,
    addRandomItem = Enum.KeyCode.R,
    startTrade = Enum.KeyCode.T,
    blockPlayer = Enum.KeyCode.B,
}
local function keybindAction(titleText, keyName)
    addAction("Settings", titleText .. " : " .. keybinds[keyName].Name, function()
        notify("Current key: " .. keybinds[keyName].Name)
    end)
end

keybindAction("Select Partner", "selectPartner")
keybindAction("Add Random Item", "addRandomItem")
keybindAction("Start Trade", "startTrade")
keybindAction("Block Player", "blockPlayer")

addToggle("Settings", "Header Gold Line", false, function(state)
    notify("Header gold line is not used with the TopBar image.")
end)
addToggle("Settings", "Compact Mode", true, function(state)
    notify("Compact mode is already the default layout.")
end)
addAction("Settings", "Server Info", function()
    notify("Players in server: " .. #Players:GetPlayers())
end)
addAction("Settings", "Reset UI Position", function()
    window.Position = UDim2.new(0.5, 0, 0.5, 13)
    notify("Window centered.")
end)

-- PETS TAB
local customPetName = addInput("Pets", "Custom pet name...", function(value)
    if value ~= "" then
        notify("Pet name saved locally: " .. value)
    end
end)
addInput("Pets", "Add pet delay (seconds)...", function(value)
    local number = tonumber(value)
    if number then
        notify(("Demo delay: %.2fs"):format(math.clamp(number, 0, 999)))
    else
        notify("Enter a valid number.", true)
    end
end)
for _, age in ipairs({ "M", "N", "F", "R" }) do
    addAction("Pets", "Age / Variant: " .. age, function()
        notify("Selected demo variant: " .. age)
    end)
end
addAction("Pets", "Add Pet", function()
    if customPetName and customPetName.Text ~= "" then
        notify("Demo pet added: " .. customPetName.Text)
    else
        notify("Enter a pet name first.", true)
    end
end, { Accent = true })
addAction("Pets", "Remove Latest Pet", function()
    notify("No game inventory changed.")
end)
addAction("Pets", "Add Random High Value", function()
    notify("High-value pet picker demo.")
end)

for _, pet in ipairs({
    "Royal Griffin",
    "Golden Phoenix",
    "Moon Deer",
    "Velvet Dragon",
}) do
    addAction("Pets", "✧  " .. pet, function()
        if customPetName then
            customPetName.Text = pet
        end
        notify("Selected demo pet: " .. pet)
    end)
end

-- SPAWNER TAB
local spawnPetName = addInput("Spawner", "Pet name to preview...", function(value)
    if value ~= "" then
        notify("Spawner preview: " .. value)
    end
end)
addAction("Spawner", "GUI Spawn", function()
    notify("Spawn is a UI demo; no game object created.")
end, { Accent = true })
addAction("Spawner", "Spawn High Tier Pets", function()
    notify("No pets spawned. Demo button only.")
end)
addAction("Spawner", "Clear All Pets", function()
    notify("No pets cleared. Demo button only.")
end)
addAction("Spawner", "Rename Pet", function()
    if spawnPetName and spawnPetName.Text ~= "" then
        notify("Rename preview: " .. spawnPetName.Text)
    else
        notify("Enter a pet name first.", true)
    end
end)
addAction("Spawner", "Preview Pet", function()
    if spawnPetName and spawnPetName.Text ~= "" then
        notify("Previewing: " .. spawnPetName.Text)
    else
        notify("Enter a pet name first.", true)
    end
end)

-- DRAG WINDOW
local dragging = false
local dragStart = nil
local startPosition = nil
track(topBarImage.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = window.Position
    end
end))

track(UserInputService.InputChanged:Connect(function(input)
    if not dragging or not alive then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
            or Vector2.new(1280, 720)
        local halfWidth = window.AbsoluteSize.X / 2
        local halfHeight = window.AbsoluteSize.Y / 2
        local margin = CONFIG.ResizeMargin or 24
        local newX = startPosition.X.Scale * viewport.X
            + startPosition.X.Offset + delta.X
        local newY = startPosition.Y.Scale * viewport.Y
            + startPosition.Y.Offset + delta.Y

        newX = math.clamp(
            newX,
            halfWidth + margin,
            viewport.X - halfWidth - margin
        )
        newY = math.clamp(
            newY,
            halfHeight + margin,
            viewport.Y - halfHeight - margin
        )
        window.Position = UDim2.fromOffset(newX, newY)
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

-- RESIZE
local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.AnchorPoint = Vector2.new(1, 1)
resizeHandle.Position = UDim2.new(1, -3, 1, -3)
resizeHandle.Size = UDim2.fromOffset(18, 18)
resizeHandle.BackgroundColor3 = C.Surface
resizeHandle.BackgroundTransparency = 0.1
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = "."
resizeHandle.TextSize = 10
resizeHandle.TextColor3 = C.Gold
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 15
resizeHandle.Parent = window

corner(resizeHandle, 3)
addChasingGlow(resizeHandle, 2.0)

local resizing = false
local resizeStart = nil
local sizeStart = nil

local function getResizeLimits()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
        or Vector2.new(1280, 720)
    local margin = CONFIG.ResizeMargin or 24
    local maxX = math.min(
        CONFIG.MaximumSize.X,
        viewport.X - margin * 2
    )
    local maxY = math.min(
        CONFIG.MaximumSize.Y,
        viewport.Y - margin * 2
    )
    local minX = math.min(CONFIG.MinimumSize.X, maxX)
    local minY = math.min(CONFIG.MinimumSize.Y, maxY)
    return minX, minY, maxX, maxY
end

track(resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        sizeStart = Vector2.new(
            window.Size.X.Offset,
            window.Size.Y.Offset
        )
    end
end))

track(UserInputService.InputChanged:Connect(function(input)
    if not resizing or not alive then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - resizeStart
        local minX, minY, maxX, maxY = getResizeLimits()
        local newWidth = math.clamp(
            sizeStart.X + delta.X,
            minX,
            maxX
        )
        local newHeight = math.clamp(
            sizeStart.Y + delta.Y,
            minY,
            maxY
        )
        window.Size = UDim2.fromOffset(
            newWidth,
            newHeight
        )
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        resizing = false
    end
end))

-- CLOSE GUI FUNCTION
local function closeGui()
    if not alive then return end
    tween(windowScale, 0.16, {
        Scale = 0.88
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(window, 0.16, {
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(midBackground, 0.16, {
        ImageTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(topBarImage, 0.16, {
        ImageTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(regalCurtain, 0.16, {
        ImageTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(leftBackground, 0.16, {
        ImageTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    alive = false
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    task.delay(0.19, function()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end)
end

-- WINDOW CONTROL
local function createWindowButton(name, text, xOffset)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromOffset(30, 28)
    button.Position = UDim2.new(1, xOffset, 0, 12)
    button.BackgroundColor3 = C.Surface
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = C.GoldBright
    button.TextSize = 17
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 20
    button.Parent = window

    corner(button, 7)
    local outline = stroke(button, C.Border, 1, 0.42)
    addChasingGlow(button, 2.4)

    track(button.MouseEnter:Connect(function()
        if not alive then return end
        tween(button, 0.12, {
            BackgroundColor3 = C.SurfaceHover
        })
        tween(outline, 0.12, {
            Color = C.Gold,
            Transparency = 0.05
        })
        tween(button, 0.12, {
            TextColor3 = C.GoldBright
        })
    end))

    track(button.MouseLeave:Connect(function()
        if not alive then return end
        tween(button, 0.15, {
            BackgroundColor3 = C.Surface
        })
        tween(outline, 0.15, {
            Color = C.Border,
            Transparency = 0.42
        })
        tween(button, 0.15, {
            TextColor3 = C.GoldBright
        })
    end))

    track(button.MouseButton1Down:Connect(function()
        if alive then
            tween(button, 0.06, {
                BackgroundColor3 = C.SurfacePressed
            })
        end
    end))
    return button
end

local minimizeButton = createWindowButton(
    "MinimizeButton",
    "—",
    -118
)
local closeButton = createWindowButton(
    "CloseButton",
    "×",
    -80
)
track(closeButton.Activated:Connect(function()
    closeGui()
end))

local minimized = false
local savedVisibility = {}

local function setMinimized(state)
    if not alive or minimized == state then
        return
    end
    minimized = state
    if minimized then
        for _, child in ipairs(window:GetChildren()) do
            if child:IsA("GuiObject")
                and child ~= topBarImage
                and child ~= regalCurtain
                and child ~= closeButton
                and child ~= minimizeButton then
                savedVisibility[child] = child.Visible
                child.Visible = false
            end
        end
        minimizeButton.Text = "+"
    else
        for child, wasVisible in pairs(savedVisibility) do
            if child and child.Parent == window then
                child.Visible = wasVisible
            end
        end
        table.clear(savedVisibility)
        minimizeButton.Text = "—"
    end
end

track(minimizeButton.Activated:Connect(function()
    setMinimized(not minimized)
end))

-- RESPONSIVE STARTUP
local function fitToViewport()
    if not alive then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local width = math.min(CONFIG.DefaultSize.X, viewport.X - 24)
    local height = math.min(CONFIG.DefaultSize.Y, viewport.Y - 24)

    width = math.max(
        math.min(CONFIG.MinimumSize.X, viewport.X - 24),
        width
    )
    height = math.max(
        math.min(CONFIG.MinimumSize.Y, viewport.Y - 24),
        height
    )
    window.Size = UDim2.fromOffset(width, height)
    window.Position = UDim2.new(0.5, 0, 0.5, 13)
end

fitToViewport()

if workspace.CurrentCamera then
    track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if not alive then return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local current = window.AbsoluteSize
        if current.X > viewport.X - 24 or current.Y > viewport.Y - 24 then
            window.Size = UDim2.fromOffset(
                math.min(current.X, viewport.X - 24),
                math.min(current.Y, viewport.Y - 24)
            )
        end
    end))
end

selectTab("Main")
tween(windowScale, 0.28, {
    Scale = 1
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
notify("Welcome to Baroque Royale.")