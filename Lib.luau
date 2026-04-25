--!strict
-- ═══════════════════════════════════════════
--   MonochromeLib — Roblox UI Library
--   Black & White Design System · Full-Featured
--   Version 1.0.0
-- ═══════════════════════════════════════════

local MonochromeLib = {}
MonochromeLib.__index = MonochromeLib

-- ── Services ────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ── Theme / Color Palette ───────────────────
local Theme = {
    Background  = Color3.fromRGB(10,  10,  10),   -- #0A0A0A
    Surface     = Color3.fromRGB(20,  20,  20),   -- #141414
    Surface2    = Color3.fromRGB(30,  30,  30),   -- #1E1E1E
    Border      = Color3.fromRGB(42,  42,  42),   -- #2A2A2A
    TextPrimary = Color3.fromRGB(245, 245, 245),  -- #F5F5F5
    TextMuted   = Color3.fromRGB(136, 136, 136),  -- #888888
    Accent      = Color3.fromRGB(255, 255, 255),  -- #FFFFFF
    Accent2     = Color3.fromRGB(17,  17,  17),   -- #111111
    Hover       = Color3.fromRGB(42,  42,  42),   -- #2A2A2A
    Press       = Color3.fromRGB(51,  51,  51),   -- #333333
    Error       = Color3.fromRGB(220, 220, 220),
    Warning     = Color3.fromRGB(180, 180, 180),
    Success     = Color3.fromRGB(255, 255, 255),
    Info        = Color3.fromRGB(200, 200, 200),
}

-- ── Config ──────────────────────────────────
local Config = {
    Scale        = 1,
    Transparency = 0,
    Font         = Enum.Font.GothamMedium,
    FontFallback = Enum.Font.Gotham,
    CornerWindow = 10,
    CornerElem   = 6,
    CornerSmall  = 4,
    TweenFast    = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenNormal  = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- ── ZIndex Manager ──────────────────────────
local ZIndexCounter = 100
local function NextZIndex(): number
    ZIndexCounter += 1
    return ZIndexCounter
end

-- ── ScreenGui ───────────────────────────────
local ScreenGui: ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "MonochromeLib"
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999
ScreenGui.Parent          = PlayerGui

-- Notification container
local NotifContainer: Frame = Instance.new("Frame")
NotifContainer.Name              = "NotifContainer"
NotifContainer.Size              = UDim2.new(0, 320, 1, 0)
NotifContainer.Position          = UDim2.new(1, -330, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.AnchorPoint       = Vector2.new(0, 0)
NotifContainer.ZIndex            = 9000
NotifContainer.Parent            = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder            = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment    = Enum.VerticalAlignment.Bottom
NotifLayout.Padding              = UDim.new(0, 8)
NotifLayout.Parent               = NotifContainer

local NotifPadding = Instance.new("UIPadding")
NotifPadding.PaddingBottom = UDim.new(0, 12)
NotifPadding.PaddingRight  = UDim.new(0, 0)
NotifPadding.Parent        = NotifContainer

-- ── Utility: Tween ──────────────────────────
function MonochromeLib.Tween(
    instance: Instance,
    props: {[string]: any},
    duration: number?,
    style: Enum.EasingStyle?
): Tween
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

-- ── Utility: Make corner ────────────────────
local function MakeCorner(radius: number, parent: Instance): UICorner
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent       = parent
    return c
end

-- ── Utility: Make stroke ────────────────────
local function MakeStroke(color: Color3, thickness: number, parent: Instance): UIStroke
    local s = Instance.new("UIStroke")
    s.Color     = color
    s.Thickness = thickness
    s.Parent    = parent
    return s
end

-- ── Utility: Ripple ─────────────────────────
function MonochromeLib.Ripple(parent: Frame, x: number, y: number)
    local ripple = Instance.new("Frame")
    ripple.Name                  = "Ripple"
    ripple.Size                  = UDim2.new(0, 0, 0, 0)
    ripple.Position              = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint           = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.ZIndex                = parent.ZIndex + 10
    ripple.ClipsDescendants      = false
    MakeCorner(999, ripple)
    ripple.Parent = parent

    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    MonochromeLib.Tween(ripple, {
        Size                  = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
    }, 0.5, Enum.EasingStyle.Quart)

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- ── Utility: Debounce ───────────────────────
function MonochromeLib.Debounce(fn: (...any) -> (), wait: number): (...any) -> ()
    local timer: thread? = nil
    return function(...)
        local args = {...}
        if timer then task.cancel(timer) end
        timer = task.delay(wait, function()
            fn(table.unpack(args))
            timer = nil
        end)
    end
end

-- ── Utility: Theme override ──────────────────
function MonochromeLib.Theme(overrides: {[string]: Color3})
    for k, v in pairs(overrides) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

-- ── Config setter ────────────────────────────
function MonochromeLib.Config(opts: {[string]: any})
    for k, v in pairs(opts) do
        if Config[k] ~= nil then
            Config[k] = v
        end
    end
end

-- ── Event Mixin ─────────────────────────────
-- Adds :On(event, cb) and :Fire(event, ...) to any object table
local function ApplyEventMixin(obj: {[string]: any})
    obj._listeners = {}

    function obj:On(event: string, callback: (...any) -> ()): () -> ()
        if not self._listeners[event] then
            self._listeners[event] = {}
        end
        local id = HttpService:GenerateGUID(false)
        self._listeners[event][id] = callback
        -- returns disconnect fn
        return function()
            if self._listeners[event] then
                self._listeners[event][id] = nil
            end
        end
    end

    function obj:Fire(event: string, ...: any)
        if self._listeners[event] then
            local args = {...}
            for _, cb in pairs(self._listeners[event]) do
                task.spawn(cb, table.unpack(args))
            end
        end
    end
end

-- ── Base Component ───────────────────────────
-- All components inherit these base methods
local function BaseComponent(frame: Frame)
    local comp: {[string]: any} = {}
    comp._instance    = frame
    comp._connections = {} :: {RBXScriptConnection}
    ApplyEventMixin(comp)

    function comp:GetInstance(): Frame
        return self._instance
    end

    function comp:SetVisible(visible: boolean): typeof(comp)
        self._instance.Visible = visible
        return self
    end

    function comp:Destroy()
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        self._connections = {}
        self._listeners   = {}
        self._instance:Destroy()
    end

    function comp:_connect(conn: RBXScriptConnection)
        table.insert(self._connections, conn)
    end

    return comp
end

-- ══════════════════════════════════════════════
--  1. WINDOW
-- ══════════════════════════════════════════════
function MonochromeLib.Window(opts: {
    Title:    string?,
    Size:     UDim2?,
    Position: UDim2?,
    MinSize:  Vector2?,
}): {[string]: any}

    opts = opts or {}
    local title    = opts.Title    or "Window"
    local size     = opts.Size     or UDim2.new(0, 520, 0, 400)
    local position = opts.Position or UDim2.new(0.5, -260, 0.5, -200)
    local minSize  = opts.MinSize  or Vector2.new(300, 200)

    -- ── Root Frame ──
    local root = Instance.new("Frame")
    root.Name                 = "MonoWindow_" .. title
    root.Size                 = size
    root.Position             = position
    root.BackgroundColor3     = Theme.Background
    root.BorderSizePixel      = 0
    root.ClipsDescendants     = false
    root.ZIndex               = NextZIndex()
    root.Parent               = ScreenGui
    MakeCorner(Config.CornerWindow, root)
    MakeStroke(Theme.Border, 1, root)

    -- ── Title Bar ──
    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Theme.Surface
    titleBar.BorderSizePixel  = 0
    titleBar.ZIndex           = root.ZIndex + 1
    titleBar.Parent           = root
    MakeCorner(Config.CornerWindow, titleBar)

    -- Cover bottom corners of title bar
    local titleBarFix = Instance.new("Frame")
    titleBarFix.Size              = UDim2.new(1, 0, 0, 10)
    titleBarFix.Position          = UDim2.new(0, 0, 1, -10)
    titleBarFix.BackgroundColor3  = Theme.Surface
    titleBarFix.BorderSizePixel   = 0
    titleBarFix.ZIndex            = root.ZIndex + 1
    titleBarFix.Parent            = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name              = "Title"
    titleLabel.Size              = UDim2.new(1, -90, 1, 0)
    titleLabel.Position          = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text              = title
    titleLabel.TextColor3        = Theme.TextPrimary
    titleLabel.Font              = Config.Font
    titleLabel.TextSize          = 14
    titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
    titleLabel.ZIndex            = root.ZIndex + 2
    titleLabel.Parent            = titleBar

    -- ── Control Buttons ──
    local function MakeCtrlBtn(symbol: string, idx: number): TextButton
        local btn = Instance.new("TextButton")
        btn.Size                  = UDim2.new(0, 24, 0, 24)
        btn.Position              = UDim2.new(1, -10 - (28 * idx), 0.5, -12)
        btn.BackgroundColor3      = Theme.Surface2
        btn.Text                  = symbol
        btn.TextColor3            = Theme.TextMuted
        btn.Font                  = Config.Font
        btn.TextSize              = 12
        btn.BorderSizePixel       = 0
        btn.ZIndex                = root.ZIndex + 3
        btn.AutoButtonColor       = false
        btn.Parent                = titleBar
        MakeCorner(Config.CornerSmall, btn)
        btn.MouseEnter:Connect(function()
            MonochromeLib.Tween(btn, {BackgroundColor3 = Theme.Border}, 0.15)
            MonochromeLib.Tween(btn, {TextColor3 = Theme.Accent}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            MonochromeLib.Tween(btn, {BackgroundColor3 = Theme.Surface2}, 0.15)
            MonochromeLib.Tween(btn, {TextColor3 = Theme.TextMuted}, 0.15)
        end)
        return btn
    end

    local closeBtn    = MakeCtrlBtn("✕", 1)
    local minimizeBtn = MakeCtrlBtn("−", 2)

    -- ── Content Area ──
    local content = Instance.new("Frame")
    content.Name             = "Content"
    content.Size             = UDim2.new(1, 0, 1, -38)
    content.Position         = UDim2.new(0, 0, 0, 38)
    content.BackgroundColor3 = Theme.Background
    content.BorderSizePixel  = 0
    content.ClipsDescendants = true
    content.ZIndex           = root.ZIndex + 1
    content.Parent           = root

    -- ── Tab Bar ──
    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, 34)
    tabBar.BackgroundColor3 = Theme.Surface
    tabBar.BorderSizePixel  = 0
    tabBar.ZIndex           = root.ZIndex + 2
    tabBar.Parent           = content

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection        = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder            = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding              = UDim.new(0, 2)
    tabBarLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
    tabBarLayout.Parent               = tabBar

    local tabBarPad = Instance.new("UIPadding")
    tabBarPad.PaddingLeft = UDim.new(0, 8)
    tabBarPad.Parent      = tabBar

    -- Separator under tab bar
    local tabSep = Instance.new("Frame")
    tabSep.Size             = UDim2.new(1, 0, 0, 1)
    tabSep.Position         = UDim2.new(0, 0, 0, 34)
    tabSep.BackgroundColor3 = Theme.Border
    tabSep.BorderSizePixel  = 0
    tabSep.ZIndex           = root.ZIndex + 2
    tabSep.Parent           = content

    -- Tab content holder
    local tabContent = Instance.new("Frame")
    tabContent.Name             = "TabContent"
    tabContent.Size             = UDim2.new(1, 0, 1, -35)
    tabContent.Position         = UDim2.new(0, 0, 0, 35)
    tabContent.BackgroundTransparency = 1
    tabContent.ClipsDescendants = true
    tabContent.ZIndex           = root.ZIndex + 1
    tabContent.Parent           = content

    -- ── Resize Handle ──
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name                  = "Resize"
    resizeHandle.Size                  = UDim2.new(0, 16, 0, 16)
    resizeHandle.Position              = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3      = Theme.Border
    resizeHandle.Text                  = ""
    resizeHandle.ZIndex                = root.ZIndex + 10
    resizeHandle.AutoButtonColor       = false
    resizeHandle.Parent                = root
    MakeCorner(3, resizeHandle)

    -- ── Window Object ──
    local win: {[string]: any} = {}
    win._instance    = root
    win._connections = {}
    win._tabs        = {}
    win._activeTab   = nil
    win._minimized   = false
    win._fullHeight  = size.Y.Offset
    ApplyEventMixin(win)

    function win:_connect(conn: RBXScriptConnection)
        table.insert(self._connections, conn)
    end

    function win:GetInstance(): Frame return root end

    function win:SetTitle(str: string): typeof(win)
        titleLabel.Text = str
        return self
    end

    function win:SetSize(s: UDim2): typeof(win)
        root.Size = s
        self._fullHeight = s.Y.Offset
        return self
    end

    function win:SetPosition(pos: UDim2): typeof(win)
        root.Position = pos
        return self
    end

    function win:SetVisible(v: boolean): typeof(win)
        root.Visible = v
        return self
    end

    function win:Focus()
        root.ZIndex = NextZIndex()
    end

    function win:Toggle(): typeof(win)
        root.Visible = not root.Visible
        return self
    end

    -- ── Minimize ──
    local function DoMinimize()
        win._minimized = not win._minimized
        if win._minimized then
            MonochromeLib.Tween(root, {Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset, 0, 38)}, 0.2)
            content.Visible = false
        else
            content.Visible = true
            MonochromeLib.Tween(root, {Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset, 0, win._fullHeight)}, 0.2)
        end
    end

    -- ── Close ──
    local function DoClose()
        MonochromeLib.Tween(root, {BackgroundTransparency = 1}, 0.15)
        task.delay(0.15, function()
            root.Visible = false
            root.BackgroundTransparency = 0
            win:Fire("Close")
        end)
    end

    table.insert(win._connections, minimizeBtn.MouseButton1Click:Connect(DoMinimize))
    table.insert(win._connections, closeBtn.MouseButton1Click:Connect(DoClose))

    -- ── Dragging ──
    local dragging    = false
    local dragStart   = Vector2.zero
    local startPos    = Vector2.zero

    local function UpdateDrag(input: InputObject)
        local delta = input.Position - Vector3.new(dragStart.X, dragStart.Y, 0)
        local newX  = startPos.X + delta.X
        local newY  = startPos.Y + delta.Y
        -- Clamp to screen
        local screenSize = ScreenGui.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - root.AbsoluteSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - root.AbsoluteSize.Y)
        root.Position = UDim2.new(0, newX, 0, newY)
    end

    table.insert(win._connections, titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos  = Vector2.new(root.AbsolutePosition.X, root.AbsolutePosition.Y)
            win:Focus()
        end
    end))

    table.insert(win._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateDrag(input)
        end
    end))

    table.insert(win._connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    -- ── Resize ──
    local resizing     = false
    local resizeStart  = Vector2.zero
    local startSize    = Vector2.zero

    table.insert(win._connections, resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            resizing    = true
            resizeStart = Vector2.new(input.Position.X, input.Position.Y)
            startSize   = Vector2.new(root.AbsoluteSize.X, root.AbsoluteSize.Y)
        end
    end))

    table.insert(win._connections, UserInputService.InputChanged:Connect(function(input)
        if resizing and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - Vector3.new(resizeStart.X, resizeStart.Y, 0)
            local newW  = math.max(minSize.X, startSize.X + delta.X)
            local newH  = math.max(minSize.Y, startSize.Y + delta.Y)
            root.Size        = UDim2.new(0, newW, 0, newH)
            win._fullHeight  = newH
        end
    end))

    table.insert(win._connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end))

    -- ── Tab System ──
    function win:AddTab(name: string): {[string]: any}
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name                = "Tab_" .. name
        tabBtn.Size                = UDim2.new(0, 0, 1, -6)
        tabBtn.AutomaticSize       = Enum.AutomaticSize.X
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text                = name
        tabBtn.TextColor3          = Theme.TextMuted
        tabBtn.Font                = Config.Font
        tabBtn.TextSize            = 13
        tabBtn.BorderSizePixel     = 0
        tabBtn.ZIndex              = root.ZIndex + 3
        tabBtn.AutoButtonColor     = false
        tabBtn.Parent              = tabBar

        local tabPad = Instance.new("UIPadding")
        tabPad.PaddingLeft  = UDim.new(0, 10)
        tabPad.PaddingRight = UDim.new(0, 10)
        tabPad.Parent       = tabBtn

        -- Active indicator line
        local indicator = Instance.new("Frame")
        indicator.Name             = "Indicator"
        indicator.Size             = UDim2.new(1, -8, 0, 2)
        indicator.Position         = UDim2.new(0, 4, 1, -1)
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BorderSizePixel  = 0
        indicator.BackgroundTransparency = 1
        indicator.ZIndex           = root.ZIndex + 4
        indicator.Parent           = tabBtn
        MakeCorner(2, indicator)

        -- Scroll frame for tab content
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name                  = "TabFrame_" .. name
        tabFrame.Size                  = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel       = 0
        tabFrame.ScrollBarThickness    = 4
        tabFrame.ScrollBarImageColor3  = Theme.Border
        tabFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
        tabFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        tabFrame.Visible               = false
        tabFrame.ZIndex                = root.ZIndex + 2
        tabFrame.Parent                = tabContent

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        listLayout.Padding    = UDim.new(0, 8)
        listLayout.Parent     = tabFrame

        local framePad = Instance.new("UIPadding")
        framePad.PaddingLeft   = UDim.new(0, 12)
        framePad.PaddingRight  = UDim.new(0, 12)
        framePad.PaddingTop    = UDim.new(0, 12)
        framePad.PaddingBottom = UDim.new(0, 12)
        framePad.Parent        = tabFrame

        local tabObj: {[string]: any} = {}
        tabObj._btn      = tabBtn
        tabObj._frame    = tabFrame
        tabObj._indicator = indicator
        tabObj._name     = name

        function tabObj:Select()
            -- Deselect all
            for _, t in ipairs(win._tabs) do
                MonochromeLib.Tween(t._btn, {TextColor3 = Theme.TextMuted}, 0.15)
                MonochromeLib.Tween(t._indicator, {BackgroundTransparency = 1}, 0.15)
                t._frame.Visible = false
            end
            -- Select this
            MonochromeLib.Tween(tabBtn, {TextColor3 = Theme.TextPrimary}, 0.15)
            MonochromeLib.Tween(indicator, {BackgroundTransparency = 0}, 0.15)
            tabFrame.Visible = true
            win._activeTab   = tabObj
        end

        -- Add a section container to this tab
        function tabObj:AddSection(sectionTitle: string): Frame
            local section = Instance.new("Frame")
            section.Name             = "Section_" .. sectionTitle
            section.Size             = UDim2.new(1, 0, 0, 0)
            section.AutomaticSize    = Enum.AutomaticSize.Y
            section.BackgroundColor3 = Theme.Surface
            section.BorderSizePixel  = 0
            section.ZIndex           = root.ZIndex + 3
            section.Parent           = tabFrame
            MakeCorner(Config.CornerElem, section)
            MakeStroke(Theme.Border, 1, section)

            local sLabel = Instance.new("TextLabel")
            sLabel.Size                = UDim2.new(1, 0, 0, 30)
            sLabel.BackgroundTransparency = 1
            sLabel.Text               = sectionTitle
            sLabel.TextColor3         = Theme.TextMuted
            sLabel.Font               = Config.Font
            sLabel.TextSize           = 11
            sLabel.TextXAlignment     = Enum.TextXAlignment.Left
            sLabel.ZIndex             = root.ZIndex + 4
            sLabel.Parent             = section

            local sPad = Instance.new("UIPadding")
            sPad.PaddingLeft = UDim.new(0, 12)
            sPad.Parent      = sLabel

            local sContent = Instance.new("Frame")
            sContent.Name             = "SContent"
            sContent.Size             = UDim2.new(1, 0, 0, 0)
            sContent.Position         = UDim2.new(0, 0, 0, 30)
            sContent.AutomaticSize    = Enum.AutomaticSize.Y
            sContent.BackgroundTransparency = 1
            sContent.ZIndex           = root.ZIndex + 4
            sContent.Parent           = section

            local sLayout = Instance.new("UIListLayout")
            sLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sLayout.Padding   = UDim.new(0, 6)
            sLayout.Parent    = sContent

            local sPad2 = Instance.new("UIPadding")
            sPad2.PaddingLeft   = UDim.new(0, 12)
            sPad2.PaddingRight  = UDim.new(0, 12)
            sPad2.PaddingBottom = UDim.new(0, 12)
            sPad2.Parent        = sContent

            return sContent
        end

        tabBtn.MouseButton1Click:Connect(function()
            tabObj:Select()
        end)

        table.insert(win._tabs, tabObj)

        -- Select first tab automatically
        if #win._tabs == 1 then
            tabObj:Select()
        end

        return tabObj
    end

    function win:Destroy()
        for _, conn in ipairs(self._connections) do conn:Disconnect() end
        self._connections = {}
        self._listeners   = {}
        root:Destroy()
    end

    return win
end

-- ══════════════════════════════════════════════
--  2. BUTTON
-- ══════════════════════════════════════════════
type ButtonVariant = "Primary" | "Ghost" | "Danger" | "Default"

function MonochromeLib.Button(parent: Instance, opts: {
    Text:    string?,
    Icon:    string?,
    Variant: ButtonVariant?,
    Size:    UDim2?,
}): {[string]: any}

    opts = opts or {}
    local variant = opts.Variant or "Default"

    local bgColor: Color3
    local textColor: Color3
    local borderColor: Color3

    if variant == "Primary" then
        bgColor    = Theme.Accent
        textColor  = Theme.Accent2
        borderColor = Theme.Accent
    elseif variant == "Ghost" then
        bgColor    = Color3.fromRGB(0, 0, 0)
        textColor  = Theme.TextPrimary
        borderColor = Theme.Border
    elseif variant == "Danger" then
        bgColor    = Theme.Surface2
        textColor  = Color3.fromRGB(255, 100, 100)
        borderColor = Color3.fromRGB(80, 30, 30)
    else
        bgColor    = Theme.Surface2
        textColor  = Theme.TextPrimary
        borderColor = Theme.Border
    end

    local frame = Instance.new("Frame")
    frame.Name             = "MonoButton"
    frame.Size             = opts.Size or UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel  = 0
    frame.ClipsDescendants = true
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)
    MakeStroke(borderColor, 1, frame)

    local btn = Instance.new("TextButton")
    btn.Name                  = "Btn"
    btn.Size                  = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                  = ""
    btn.ZIndex                = frame.ZIndex + 1
    btn.AutoButtonColor       = false
    btn.Parent                = frame

    -- Icon
    local iconImg: ImageLabel? = nil
    if opts.Icon then
        iconImg = Instance.new("ImageLabel")
        iconImg.Size               = UDim2.new(0, 16, 0, 16)
        iconImg.Position           = UDim2.new(0, 10, 0.5, -8)
        iconImg.BackgroundTransparency = 1
        iconImg.Image              = opts.Icon
        iconImg.ZIndex             = frame.ZIndex + 2
        iconImg.Parent             = frame
    end

    local label = Instance.new("TextLabel")
    label.Name               = "Label"
    label.Size               = UDim2.new(1, iconImg and -26 or 0, 1, 0)
    label.Position           = UDim2.new(0, iconImg and 32 or 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text               = opts.Text or "Button"
    label.TextColor3         = textColor
    label.Font               = Config.Font
    label.TextSize           = 13
    label.ZIndex             = frame.ZIndex + 2
    label.Parent             = frame

    local comp = BaseComponent(frame)
    comp._enabled = true

    function comp:SetText(str: string): typeof(comp)
        label.Text = str
        return self
    end

    function comp:SetIcon(assetId: string): typeof(comp)
        if iconImg then iconImg.Image = assetId end
        return self
    end

    function comp:SetEnabled(enabled: boolean): typeof(comp)
        self._enabled = enabled
        frame.BackgroundTransparency = enabled and 0 or 0.5
        label.TextColor3 = enabled and textColor or Theme.TextMuted
        return self
    end

    function comp:OnClick(callback: () -> ()): typeof(comp)
        self:On("Click", callback)
        return self
    end

    -- Hover/press animations
    comp:_connect(btn.MouseEnter:Connect(function()
        if not comp._enabled then return end
        if variant == "Primary" then
            MonochromeLib.Tween(frame, {BackgroundColor3 = Color3.fromRGB(220,220,220)}, 0.15)
        else
            MonochromeLib.Tween(frame, {BackgroundColor3 = Theme.Hover}, 0.15)
        end
    end))

    comp:_connect(btn.MouseLeave:Connect(function()
        MonochromeLib.Tween(frame, {BackgroundColor3 = bgColor}, 0.15)
    end))

    comp:_connect(btn.MouseButton1Down:Connect(function()
        if not comp._enabled then return end
        MonochromeLib.Tween(frame, {BackgroundColor3 = Theme.Press}, 0.1)
        MonochromeLib.Tween(frame, {Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset - 4,
            frame.Size.Y.Scale, frame.Size.Y.Offset - 2
        )}, 0.1)
    end))

    comp:_connect(btn.MouseButton1Up:Connect(function()
        if not comp._enabled then return end
        MonochromeLib.Tween(frame, {BackgroundColor3 = bgColor}, 0.15)
        MonochromeLib.Tween(frame, {Size = opts.Size or UDim2.new(1, 0, 0, 36)}, 0.15)
    end))

    comp:_connect(btn.MouseButton1Click:Connect(function()
        if not comp._enabled then return end
        -- Ripple at center
        local cx = frame.AbsoluteSize.X / 2
        local cy = frame.AbsoluteSize.Y / 2
        MonochromeLib.Ripple(frame, cx, cy)
        comp:Fire("Click")
    end))

    -- Touch support
    comp:_connect(btn.TouchTap:Connect(function(touches)
        if not comp._enabled then return end
        if #touches > 0 then
            local t = touches[1]
            local lx = t.Position.X - frame.AbsolutePosition.X
            local ly = t.Position.Y - frame.AbsolutePosition.Y
            MonochromeLib.Ripple(frame, lx, ly)
        end
        comp:Fire("Click")
    end))

    return comp
end

-- ══════════════════════════════════════════════
--  3. TOGGLE / SWITCH
-- ══════════════════════════════════════════════
function MonochromeLib.Toggle(parent: Instance, opts: {
    Label:   string?,
    Default: boolean?,
}): {[string]: any}

    opts = opts or {}
    local value = opts.Default or false

    local frame = Instance.new("Frame")
    frame.Name             = "MonoToggle"
    frame.Size             = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -60, 1, 0)
    lbl.Position          = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = opts.Label or "Toggle"
    lbl.TextColor3        = Theme.TextPrimary
    lbl.Font              = Config.Font
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = frame.ZIndex + 1
    lbl.Parent            = frame

    -- Track (pill)
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 44, 0, 24)
    track.Position         = UDim2.new(1, -54, 0.5, -12)
    track.BackgroundColor3 = value and Theme.Border or Color3.fromRGB(45,45,45)
    track.BorderSizePixel  = 0
    track.ZIndex           = frame.ZIndex + 1
    track.Parent           = frame
    MakeCorner(12, track)
    MakeStroke(Theme.Border, 1, track)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.Position         = value
        and UDim2.new(0, 23, 0.5, -9)
        or  UDim2.new(0, 3,  0.5, -9)
    knob.BackgroundColor3 = value and Theme.Accent or Theme.TextMuted
    knob.BorderSizePixel  = 0
    knob.ZIndex           = frame.ZIndex + 2
    knob.Parent           = track
    MakeCorner(9, knob)

    local btn = Instance.new("TextButton")
    btn.Size                 = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                 = ""
    btn.ZIndex               = frame.ZIndex + 3
    btn.AutoButtonColor      = false
    btn.Parent               = frame

    local comp = BaseComponent(frame)
    comp._value = value

    local function UpdateVisuals(v: boolean)
        MonochromeLib.Tween(knob, {
            Position         = v and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = v and Theme.Accent or Theme.TextMuted,
        }, 0.2)
        MonochromeLib.Tween(track, {
            BackgroundColor3 = v and Theme.Border or Color3.fromRGB(45,45,45),
        }, 0.2)
    end

    function comp:SetValue(v: boolean): typeof(comp)
        self._value = v
        UpdateVisuals(v)
        return self
    end

    function comp:GetValue(): boolean
        return self._value
    end

    function comp:OnChange(callback: (boolean) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    comp:_connect(btn.MouseButton1Click:Connect(function()
        comp._value = not comp._value
        UpdateVisuals(comp._value)
        comp:Fire("Change", comp._value)
    end))

    comp:_connect(btn.TouchTap:Connect(function()
        comp._value = not comp._value
        UpdateVisuals(comp._value)
        comp:Fire("Change", comp._value)
    end))

    return comp
end

-- ══════════════════════════════════════════════
--  4. SLIDER
-- ══════════════════════════════════════════════
function MonochromeLib.Slider(parent: Instance, opts: {
    Label:   string?,
    Min:     number?,
    Max:     number?,
    Step:    number?,
    Default: number?,
}): {[string]: any}

    opts = opts or {}
    local min     = opts.Min     or 0
    local max     = opts.Max     or 100
    local step    = opts.Step    or 1
    local current = opts.Default or min

    local function Snap(v: number): number
        local snapped = math.round((v - min) / step) * step + min
        return math.clamp(snapped, min, max)
    end

    local frame = Instance.new("Frame")
    frame.Name             = "MonoSlider"
    frame.Size             = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)

    local topRow = Instance.new("Frame")
    topRow.Size             = UDim2.new(1, 0, 0, 24)
    topRow.BackgroundTransparency = 1
    topRow.ZIndex           = frame.ZIndex + 1
    topRow.Parent           = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0.7, 0, 1, 0)
    lbl.Position          = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = opts.Label or "Slider"
    lbl.TextColor3        = Theme.TextPrimary
    lbl.Font              = Config.Font
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = frame.ZIndex + 1
    lbl.Parent            = topRow

    local valLabel = Instance.new("TextLabel")
    valLabel.Size              = UDim2.new(0.3, -12, 1, 0)
    valLabel.Position          = UDim2.new(0.7, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text              = tostring(current)
    valLabel.TextColor3        = Theme.TextMuted
    valLabel.Font              = Config.Font
    valLabel.TextSize          = 13
    valLabel.TextXAlignment    = Enum.TextXAlignment.Right
    valLabel.ZIndex            = frame.ZIndex + 1
    valLabel.Parent            = topRow

    -- Track
    local track = Instance.new("Frame")
    track.Name             = "Track"
    track.Size             = UDim2.new(1, -24, 0, 4)
    track.Position         = UDim2.new(0, 12, 0, 38)
    track.BackgroundColor3 = Theme.Border
    track.BorderSizePixel  = 0
    track.ZIndex           = frame.ZIndex + 1
    track.Parent           = frame
    MakeCorner(2, track)

    -- Fill
    local fill = Instance.new("Frame")
    fill.Name             = "Fill"
    fill.Size             = UDim2.new((current - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = frame.ZIndex + 2
    fill.Parent           = track
    MakeCorner(2, fill)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Name             = "Knob"
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new((current - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Theme.Accent
    knob.BorderSizePixel  = 0
    knob.ZIndex           = frame.ZIndex + 3
    knob.Parent           = track
    MakeCorner(7, knob)
    MakeStroke(Theme.Surface, 2, knob)

    local dragBtn = Instance.new("TextButton")
    dragBtn.Size                = UDim2.new(1, 0, 0, 40)
    dragBtn.Position            = UDim2.new(0, 0, 0, 20)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text                = ""
    dragBtn.ZIndex              = frame.ZIndex + 4
    dragBtn.AutoButtonColor     = false
    dragBtn.Parent              = frame

    local comp = BaseComponent(frame)
    comp._value = current

    local function SetVisuals(v: number)
        local pct = (v - min) / (max - min)
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        valLabel.Text = tostring(v)
    end

    local function SetFromX(absX: number)
        local trackAbsX = track.AbsolutePosition.X
        local trackW    = track.AbsoluteSize.X
        local pct       = math.clamp((absX - trackAbsX) / trackW, 0, 1)
        local raw       = pct * (max - min) + min
        local snapped   = Snap(raw)
        if snapped ~= comp._value then
            comp._value = snapped
            SetVisuals(snapped)
            comp:Fire("Change", snapped)
        end
    end

    function comp:SetValue(v: number): typeof(comp)
        self._value = Snap(v)
        SetVisuals(self._value)
        return self
    end

    function comp:GetValue(): number
        return self._value
    end

    function comp:SetRange(mn: number, mx: number): typeof(comp)
        min = mn; max = mx
        self._value = Snap(self._value)
        SetVisuals(self._value)
        return self
    end

    function comp:SetStep(s: number): typeof(comp)
        step = s
        return self
    end

    function comp:OnChange(callback: (number) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    local dragging = false

    comp:_connect(dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(input.Position.X)
        end
    end))

    comp:_connect(UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            SetFromX(input.Position.X)
        end
    end))

    comp:_connect(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    return comp
end

-- ══════════════════════════════════════════════
--  5. DROPDOWN
-- ══════════════════════════════════════════════
function MonochromeLib.Dropdown(parent: Instance, opts: {
    Label:       string?,
    Options:     {string}?,
    Placeholder: string?,
    MultiSelect: boolean?,
}): {[string]: any}

    opts = opts or {}
    local options     = opts.Options     or {}
    local multiSelect = opts.MultiSelect or false
    local placeholder = opts.Placeholder or "Select..."
    local selected: {string} = {}
    local isOpen = false

    local frame = Instance.new("Frame")
    frame.Name             = "MonoDropdown"
    frame.Size             = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.Surface2
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.ClipsDescendants = false
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)
    MakeStroke(Theme.Border, 1, frame)

    if opts.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(1, 0, 0, 18)
        lbl.Position          = UDim2.new(0, 0, -0.6, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = opts.Label
        lbl.TextColor3        = Theme.TextMuted
        lbl.Font              = Config.Font
        lbl.TextSize          = 11
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = frame.ZIndex + 1
        lbl.Parent            = frame
    end

    local displayText = Instance.new("TextLabel")
    displayText.Size              = UDim2.new(1, -36, 1, 0)
    displayText.Position          = UDim2.new(0, 12, 0, 0)
    displayText.BackgroundTransparency = 1
    displayText.Text              = placeholder
    displayText.TextColor3        = Theme.TextMuted
    displayText.Font              = Config.Font
    displayText.TextSize          = 13
    displayText.TextXAlignment    = Enum.TextXAlignment.Left
    displayText.TextTruncate      = Enum.TextTruncate.AtEnd
    displayText.ZIndex            = frame.ZIndex + 1
    displayText.Parent            = frame

    local arrow = Instance.new("TextLabel")
    arrow.Size              = UDim2.new(0, 24, 1, 0)
    arrow.Position          = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text              = "▾"
    arrow.TextColor3        = Theme.TextMuted
    arrow.Font              = Config.Font
    arrow.TextSize          = 14
    arrow.ZIndex            = frame.ZIndex + 1
    arrow.Parent            = frame

    local triggerBtn = Instance.new("TextButton")
    triggerBtn.Size              = UDim2.new(1, 0, 1, 0)
    triggerBtn.BackgroundTransparency = 1
    triggerBtn.Text              = ""
    triggerBtn.ZIndex            = frame.ZIndex + 2
    triggerBtn.AutoButtonColor   = false
    triggerBtn.Parent            = frame

    -- Dropdown panel
    local panel = Instance.new("Frame")
    panel.Name             = "Panel"
    panel.Size             = UDim2.new(1, 0, 0, 0)
    panel.Position         = UDim2.new(0, 0, 1, 4)
    panel.BackgroundColor3 = Theme.Surface
    panel.BorderSizePixel  = 0
    panel.ClipsDescendants = true
    panel.Visible          = false
    panel.ZIndex           = frame.ZIndex + 10
    panel.Parent           = frame
    MakeCorner(Config.CornerElem, panel)
    MakeStroke(Theme.Border, 1, panel)

    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.Size             = UDim2.new(1, -16, 0, 28)
    searchBox.Position         = UDim2.new(0, 8, 0, 6)
    searchBox.BackgroundColor3 = Theme.Surface2
    searchBox.Text             = ""
    searchBox.PlaceholderText  = "Search..."
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.TextColor3       = Theme.TextPrimary
    searchBox.Font             = Config.Font
    searchBox.TextSize         = 12
    searchBox.BorderSizePixel  = 0
    searchBox.ZIndex           = frame.ZIndex + 11
    searchBox.Parent           = panel
    MakeCorner(Config.CornerSmall, searchBox)

    local searchPad = Instance.new("UIPadding")
    searchPad.PaddingLeft = UDim.new(0, 8)
    searchPad.Parent      = searchBox

    -- List
    local list = Instance.new("ScrollingFrame")
    list.Size                  = UDim2.new(1, -8, 1, -44)
    list.Position              = UDim2.new(0, 4, 0, 40)
    list.BackgroundTransparency = 1
    list.BorderSizePixel       = 0
    list.ScrollBarThickness    = 3
    list.ScrollBarImageColor3  = Theme.Border
    list.CanvasSize            = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    list.ZIndex                = frame.ZIndex + 11
    list.Parent                = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, 2)
    listLayout.Parent    = list

    local comp = BaseComponent(frame)
    comp._options  = options
    comp._selected = selected

    local function UpdateDisplay()
        if #selected == 0 then
            displayText.Text       = placeholder
            displayText.TextColor3 = Theme.TextMuted
        elseif multiSelect then
            displayText.Text       = table.concat(selected, ", ")
            displayText.TextColor3 = Theme.TextPrimary
        else
            displayText.Text       = selected[1] or placeholder
            displayText.TextColor3 = Theme.TextPrimary
        end
    end

    local function IsSelected(opt: string): boolean
        for _, s in ipairs(selected) do
            if s == opt then return true end
        end
        return false
    end

    local itemFrames: {Frame} = {}

    local function BuildItems(filter: string)
        for _, f in ipairs(itemFrames) do f:Destroy() end
        itemFrames = {}

        for _, opt in ipairs(options) do
            if filter ~= "" and not string.lower(opt):find(string.lower(filter), 1, true) then
                continue
            end

            local itemFrame = Instance.new("Frame")
            itemFrame.Size             = UDim2.new(1, 0, 0, 30)
            itemFrame.BackgroundColor3 = IsSelected(opt) and Theme.Surface2 or Theme.Surface
            itemFrame.BorderSizePixel  = 0
            itemFrame.ZIndex           = frame.ZIndex + 12
            itemFrame.Parent           = list
            MakeCorner(Config.CornerSmall, itemFrame)

            local check = Instance.new("TextLabel")
            check.Size              = UDim2.new(0, 20, 1, 0)
            check.Position          = UDim2.new(0, 6, 0, 0)
            check.BackgroundTransparency = 1
            check.Text              = IsSelected(opt) and "✓" or ""
            check.TextColor3        = Theme.Accent
            check.Font              = Config.Font
            check.TextSize          = 12
            check.ZIndex            = frame.ZIndex + 13
            check.Parent            = itemFrame

            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size              = UDim2.new(1, -30, 1, 0)
            itemLabel.Position          = UDim2.new(0, 26, 0, 0)
            itemLabel.BackgroundTransparency = 1
            itemLabel.Text              = opt
            itemLabel.TextColor3        = Theme.TextPrimary
            itemLabel.Font              = Config.Font
            itemLabel.TextSize          = 13
            itemLabel.TextXAlignment    = Enum.TextXAlignment.Left
            itemLabel.ZIndex            = frame.ZIndex + 13
            itemLabel.Parent            = itemFrame

            local itemBtn = Instance.new("TextButton")
            itemBtn.Size              = UDim2.new(1, 0, 1, 0)
            itemBtn.BackgroundTransparency = 1
            itemBtn.Text              = ""
            itemBtn.ZIndex            = frame.ZIndex + 14
            itemBtn.AutoButtonColor   = false
            itemBtn.Parent            = itemFrame

            itemBtn.MouseEnter:Connect(function()
                MonochromeLib.Tween(itemFrame, {BackgroundColor3 = Theme.Surface2}, 0.1)
            end)
            itemBtn.MouseLeave:Connect(function()
                MonochromeLib.Tween(itemFrame, {
                    BackgroundColor3 = IsSelected(opt) and Theme.Surface2 or Theme.Surface
                }, 0.1)
            end)

            itemBtn.MouseButton1Click:Connect(function()
                if multiSelect then
                    if IsSelected(opt) then
                        for i, s in ipairs(selected) do
                            if s == opt then table.remove(selected, i) break end
                        end
                    else
                        table.insert(selected, opt)
                    end
                else
                    selected = {opt}
                    -- Close
                    isOpen = false
                    MonochromeLib.Tween(panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    task.delay(0.15, function() panel.Visible = false end)
                    MonochromeLib.Tween(arrow, {Rotation = 0}, 0.15)
                end
                UpdateDisplay()
                BuildItems(searchBox.Text)
                comp:Fire("Change", multiSelect and selected or selected[1])
            end)

            table.insert(itemFrames, itemFrame)
        end
    end

    local function OpenPanel()
        local panelH = math.min(#options * 32 + 50, 200)
        panel.Visible = true
        MonochromeLib.Tween(panel, {Size = UDim2.new(1, 0, 0, panelH)}, 0.2)
        MonochromeLib.Tween(arrow, {Rotation = 180}, 0.2)
        BuildItems("")
        searchBox.Text = ""
    end

    local function ClosePanel()
        MonochromeLib.Tween(panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
        MonochromeLib.Tween(arrow, {Rotation = 0}, 0.15)
        task.delay(0.15, function() panel.Visible = false end)
    end

    comp:_connect(triggerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then OpenPanel() else ClosePanel() end
    end))

    comp:_connect(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        BuildItems(searchBox.Text)
    end))

    -- Close on outside click
    comp:_connect(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOpen then
                -- Check if click is inside panel
                local mp = UserInputService:GetMouseLocation()
                local pa = panel.AbsolutePosition
                local ps = panel.AbsoluteSize
                if mp.X < pa.X or mp.X > pa.X + ps.X or mp.Y < pa.Y or mp.Y > pa.Y + ps.Y then
                    local fa = frame.AbsolutePosition
                    local fs = frame.AbsoluteSize
                    if mp.X < fa.X or mp.X > fa.X + fs.X or mp.Y < fa.Y or mp.Y > fa.Y + fs.Y then
                        isOpen = false
                        ClosePanel()
                    end
                end
            end
        end
    end))

    function comp:SetOptions(opts_: {string}): typeof(comp)
        options = opts_
        selected = {}
        UpdateDisplay()
        if isOpen then BuildItems(searchBox.Text) end
        return self
    end

    function comp:GetSelected(): string | {string}
        return multiSelect and selected or (selected[1] or "")
    end

    function comp:SetPlaceholder(str: string): typeof(comp)
        placeholder = str
        UpdateDisplay()
        return self
    end

    function comp:OnChange(callback: (string | {string}) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    BuildItems("")
    return comp
end

-- ══════════════════════════════════════════════
--  6. TEXT INPUT
-- ══════════════════════════════════════════════
function MonochromeLib.TextInput(parent: Instance, opts: {
    Label:       string?,
    Placeholder: string?,
    MaxLength:   number?,
    Password:    boolean?,
    Prefix:      string?,
    Suffix:      string?,
}): {[string]: any}

    opts = opts or {}
    local maxLen  = opts.MaxLength or 0
    local pwMode  = opts.Password  or false

    local wrapper = Instance.new("Frame")
    wrapper.Name             = "MonoTextInput"
    wrapper.Size             = UDim2.new(1, 0, 0, opts.Label and 58 or 36)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel  = 0
    wrapper.ZIndex           = NextZIndex()
    wrapper.Parent           = parent

    if opts.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text              = opts.Label
        lbl.TextColor3        = Theme.TextMuted
        lbl.Font              = Config.Font
        lbl.TextSize          = 11
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = wrapper.ZIndex + 1
        lbl.Parent            = wrapper
    end

    local frame = Instance.new("Frame")
    frame.Name             = "InputFrame"
    frame.Size             = UDim2.new(1, 0, 0, 36)
    frame.Position         = UDim2.new(0, 0, 0, opts.Label and 20 or 0)
    frame.BackgroundColor3 = Theme.Surface2
    frame.BorderSizePixel  = 0
    frame.ZIndex           = wrapper.ZIndex + 1
    frame.ClipsDescendants = true
    frame.Parent           = wrapper
    MakeCorner(Config.CornerElem, frame)
    local stroke = MakeStroke(Theme.Border, 1, frame)

    local offsetLeft  = opts.Prefix and 32 or 8
    local offsetRight = 8

    if opts.Prefix then
        local pfx = Instance.new("TextLabel")
        pfx.Size              = UDim2.new(0, 28, 1, 0)
        pfx.BackgroundTransparency = 1
        pfx.Text              = opts.Prefix
        pfx.TextColor3        = Theme.TextMuted
        pfx.Font              = Config.Font
        pfx.TextSize          = 13
        pfx.ZIndex            = frame.ZIndex + 1
        pfx.Parent            = frame
    end

    if opts.Suffix then
        local sfx = Instance.new("TextLabel")
        sfx.Size              = UDim2.new(0, 28, 1, 0)
        sfx.Position          = UDim2.new(1, -28, 0, 0)
        sfx.BackgroundTransparency = 1
        sfx.Text              = opts.Suffix
        sfx.TextColor3        = Theme.TextMuted
        sfx.Font              = Config.Font
        sfx.TextSize          = 13
        sfx.ZIndex            = frame.ZIndex + 1
        sfx.Parent            = frame
        offsetRight = 32
    end

    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size              = UDim2.new(0, 24, 0, 24)
    clearBtn.Position          = UDim2.new(1, -28, 0.5, -12)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text              = "✕"
    clearBtn.TextColor3        = Theme.TextMuted
    clearBtn.Font              = Config.Font
    clearBtn.TextSize          = 10
    clearBtn.Visible           = false
    clearBtn.ZIndex            = frame.ZIndex + 3
    clearBtn.AutoButtonColor   = false
    clearBtn.Parent            = frame

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(1, -(offsetLeft + offsetRight + 28), 1, 0)
    box.Position         = UDim2.new(0, offsetLeft, 0, 0)
    box.BackgroundTransparency = 1
    box.Text             = ""
    box.PlaceholderText  = opts.Placeholder or ""
    box.PlaceholderColor3 = Theme.TextMuted
    box.TextColor3       = Theme.TextPrimary
    box.Font             = Config.Font
    box.TextSize         = 13
    box.TextXAlignment   = Enum.TextXAlignment.Left
    box.BorderSizePixel  = 0
    box.ClearTextOnFocus = false
    box.ZIndex           = frame.ZIndex + 2
    box.Parent           = frame

    -- Counter
    local counter: TextLabel? = nil
    if maxLen > 0 then
        counter = Instance.new("TextLabel")
        counter.Size              = UDim2.new(0, 50, 0, 14)
        counter.Position          = UDim2.new(1, -54, 1, 2)
        counter.BackgroundTransparency = 1
        counter.Text              = "0/" .. tostring(maxLen)
        counter.TextColor3        = Theme.TextMuted
        counter.Font              = Config.Font
        counter.TextSize          = 10
        counter.TextXAlignment    = Enum.TextXAlignment.Right
        counter.ZIndex            = wrapper.ZIndex + 2
        counter.Parent            = wrapper
    end

    -- Error label
    local errLabel = Instance.new("TextLabel")
    errLabel.Size              = UDim2.new(1, 0, 0, 14)
    errLabel.Position          = UDim2.new(0, 0, 1, 2)
    errLabel.BackgroundTransparency = 1
    errLabel.Text              = ""
    errLabel.TextColor3        = Color3.fromRGB(255, 120, 120)
    errLabel.Font              = Config.Font
    errLabel.TextSize          = 10
    errLabel.TextXAlignment    = Enum.TextXAlignment.Left
    errLabel.ZIndex            = wrapper.ZIndex + 2
    errLabel.Visible           = false
    errLabel.Parent            = frame

    local comp = BaseComponent(wrapper)
    comp._box = box

    comp:_connect(box.Focused:Connect(function()
        MonochromeLib.Tween(stroke, {Color = Theme.Accent}, 0.15)
    end))

    comp:_connect(box.FocusLost:Connect(function(enterPressed)
        MonochromeLib.Tween(stroke, {Color = Theme.Border}, 0.15)
        if enterPressed then
            comp:Fire("Submit", box.Text)
        end
    end))

    comp:_connect(box:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = box.Text
        -- Enforce max length
        if maxLen > 0 and #txt > maxLen then
            box.Text = string.sub(txt, 1, maxLen)
            txt = box.Text
        end
        -- Password masking display
        if pwMode then
            -- Roblox handles masking via TextBox.TextEditable but we simulate with dots
            -- In Roblox, use a hidden TextBox + display label trick
        end
        if counter then
            counter.Text = tostring(#txt) .. "/" .. tostring(maxLen)
        end
        clearBtn.Visible = #txt > 0
        comp:Fire("Change", txt)
    end))

    comp:_connect(clearBtn.MouseButton1Click:Connect(function()
        box.Text = ""
        comp:Fire("Change", "")
    end))

    function comp:GetValue(): string
        return box.Text
    end

    function comp:SetValue(str: string): typeof(comp)
        box.Text = str
        return self
    end

    function comp:OnChange(callback: (string) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    function comp:OnSubmit(callback: (string) -> ()): typeof(comp)
        self:On("Submit", callback)
        return self
    end

    function comp:SetError(msg: string): typeof(comp)
        errLabel.Text    = msg
        errLabel.Visible = true
        MonochromeLib.Tween(stroke, {Color = Color3.fromRGB(180, 60, 60)}, 0.15)
        return self
    end

    function comp:ClearError(): typeof(comp)
        errLabel.Text    = ""
        errLabel.Visible = false
        MonochromeLib.Tween(stroke, {Color = Theme.Border}, 0.15)
        return self
    end

    return comp
end

-- ══════════════════════════════════════════════
--  7. NOTIFICATION / TOAST
-- ══════════════════════════════════════════════
local notifIdCounter = 0
local activeNotifs: {[string]: Frame} = {}

local NOTIF_ICONS = {
    Info    = "ℹ",
    Success = "✓",
    Warning = "⚠",
    Error   = "✕",
}

function MonochromeLib.Notification(): {[string]: any}
    local notif: {[string]: any} = {}

    function notif:Show(title: string, message: string, ntype: string, duration: number?): string
        notifIdCounter += 1
        local id = "notif_" .. tostring(notifIdCounter)
        duration = duration or 4

        local card = Instance.new("Frame")
        card.Name             = id
        card.Size             = UDim2.new(1, 0, 0, 70)
        card.Position         = UDim2.new(1, 10, 0, 0) -- start off screen
        card.BackgroundColor3 = Theme.Surface
        card.BorderSizePixel  = 0
        card.ZIndex           = 9001
        card.LayoutOrder      = notifIdCounter
        card.Parent           = NotifContainer
        MakeCorner(Config.CornerElem, card)
        MakeStroke(Theme.Border, 1, card)

        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size              = UDim2.new(0, 28, 0, 28)
        iconLbl.Position          = UDim2.new(0, 10, 0.5, -14)
        iconLbl.BackgroundColor3  = Theme.Surface2
        iconLbl.Text              = NOTIF_ICONS[ntype] or "ℹ"
        iconLbl.TextColor3        = Theme.TextPrimary
        iconLbl.Font              = Config.Font
        iconLbl.TextSize          = 14
        iconLbl.BorderSizePixel   = 0
        iconLbl.ZIndex            = 9002
        iconLbl.Parent            = card
        MakeCorner(Config.CornerSmall, iconLbl)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size              = UDim2.new(1, -60, 0, 20)
        titleLbl.Position          = UDim2.new(0, 46, 0, 10)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text              = title
        titleLbl.TextColor3        = Theme.TextPrimary
        titleLbl.Font              = Config.Font
        titleLbl.TextSize          = 13
        titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
        titleLbl.ZIndex            = 9002
        titleLbl.Parent            = card

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size              = UDim2.new(1, -60, 0, 20)
        msgLbl.Position          = UDim2.new(0, 46, 0, 30)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text              = message
        msgLbl.TextColor3        = Theme.TextMuted
        msgLbl.Font              = Config.Font
        msgLbl.TextSize          = 11
        msgLbl.TextXAlignment    = Enum.TextXAlignment.Left
        msgLbl.TextTruncate      = Enum.TextTruncate.AtEnd
        msgLbl.ZIndex            = 9002
        msgLbl.Parent            = card

        -- Progress bar
        local progBg = Instance.new("Frame")
        progBg.Size             = UDim2.new(1, 0, 0, 3)
        progBg.Position         = UDim2.new(0, 0, 1, -3)
        progBg.BackgroundColor3 = Theme.Border
        progBg.BorderSizePixel  = 0
        progBg.ZIndex           = 9002
        progBg.Parent           = card

        local progFill = Instance.new("Frame")
        progFill.Size             = UDim2.new(1, 0, 1, 0)
        progFill.BackgroundColor3 = Theme.TextMuted
        progFill.BorderSizePixel  = 0
        progFill.ZIndex           = 9003
        progFill.Parent           = progBg

        activeNotifs[id] = card

        -- Slide in
        MonochromeLib.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

        -- Animate progress bar
        MonochromeLib.Tween(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration :: number)

        -- Auto dismiss
        task.delay(duration :: number, function()
            if activeNotifs[id] then
                self:Dismiss(id)
            end
        end)

        -- Click to dismiss
        local dismissBtn = Instance.new("TextButton")
        dismissBtn.Size              = UDim2.new(1, 0, 1, 0)
        dismissBtn.BackgroundTransparency = 1
        dismissBtn.Text              = ""
        dismissBtn.ZIndex            = 9004
        dismissBtn.AutoButtonColor   = false
        dismissBtn.Parent            = card
        dismissBtn.MouseButton1Click:Connect(function()
            self:Dismiss(id)
        end)

        return id
    end

    function notif:Dismiss(id: string)
        local card = activeNotifs[id]
        if not card then return end
        activeNotifs[id] = nil
        MonochromeLib.Tween(card, {Position = UDim2.new(1, 10, 0, 0)}, 0.25)
        task.delay(0.25, function()
            card:Destroy()
        end)
    end

    return notif
end

-- ══════════════════════════════════════════════
--  8. MODAL / DIALOG
-- ══════════════════════════════════════════════
function MonochromeLib.Modal(opts: {
    Title:   string?,
    Body:    string?,
    Confirm: string?,
    Cancel:  string?,
}): {[string]: any}

    opts = opts or {}

    -- Backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Name             = "Backdrop"
    backdrop.Size             = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 1
    backdrop.ZIndex           = 8000
    backdrop.Visible          = false
    backdrop.Parent           = ScreenGui

    local modalFrame = Instance.new("Frame")
    modalFrame.Name             = "MonoModal"
    modalFrame.Size             = UDim2.new(0, 420, 0, 220)
    modalFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
    modalFrame.Position         = UDim2.new(0.5, 0, 0.5, 0)
    modalFrame.BackgroundColor3 = Theme.Surface
    modalFrame.BorderSizePixel  = 0
    modalFrame.ZIndex           = 8001
    modalFrame.Parent           = backdrop
    MakeCorner(Config.CornerWindow, modalFrame)
    MakeStroke(Theme.Border, 1, modalFrame)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size              = UDim2.new(1, -32, 0, 44)
    titleLbl.Position          = UDim2.new(0, 20, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text              = opts.Title or "Dialog"
    titleLbl.TextColor3        = Theme.TextPrimary
    titleLbl.Font              = Config.Font
    titleLbl.TextSize          = 16
    titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
    titleLbl.ZIndex            = 8002
    titleLbl.Parent            = modalFrame

    local sep = Instance.new("Frame")
    sep.Size             = UDim2.new(1, 0, 0, 1)
    sep.Position         = UDim2.new(0, 0, 0, 44)
    sep.BackgroundColor3 = Theme.Border
    sep.BorderSizePixel  = 0
    sep.ZIndex           = 8002
    sep.Parent           = modalFrame

    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Size              = UDim2.new(1, -40, 0, 90)
    bodyLbl.Position          = UDim2.new(0, 20, 0, 54)
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Text              = opts.Body or ""
    bodyLbl.TextColor3        = Theme.TextMuted
    bodyLbl.Font              = Config.Font
    bodyLbl.TextSize          = 13
    bodyLbl.TextXAlignment    = Enum.TextXAlignment.Left
    bodyLbl.TextYAlignment    = Enum.TextYAlignment.Top
    bodyLbl.TextWrapped       = true
    bodyLbl.ZIndex            = 8002
    bodyLbl.Parent            = modalFrame

    -- Custom content holder
    local customHolder = Instance.new("Frame")
    customHolder.Name             = "CustomContent"
    customHolder.Size             = UDim2.new(1, -40, 0, 0)
    customHolder.Position         = UDim2.new(0, 20, 0, 54)
    customHolder.BackgroundTransparency = 1
    customHolder.ZIndex           = 8002
    customHolder.Visible          = false
    customHolder.Parent           = modalFrame

    -- Buttons
    local btnRow = Instance.new("Frame")
    btnRow.Size             = UDim2.new(1, -40, 0, 36)
    btnRow.Position         = UDim2.new(0, 20, 1, -52)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex           = 8002
    btnRow.Parent           = modalFrame

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size             = UDim2.new(0.48, 0, 1, 0)
    cancelBtn.BackgroundColor3 = Theme.Surface2
    cancelBtn.Text             = opts.Cancel or "Cancel"
    cancelBtn.TextColor3       = Theme.TextMuted
    cancelBtn.Font             = Config.Font
    cancelBtn.TextSize         = 13
    cancelBtn.BorderSizePixel  = 0
    cancelBtn.ZIndex           = 8003
    cancelBtn.AutoButtonColor  = false
    cancelBtn.Parent           = btnRow
    MakeCorner(Config.CornerElem, cancelBtn)
    MakeStroke(Theme.Border, 1, cancelBtn)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size             = UDim2.new(0.48, 0, 1, 0)
    confirmBtn.Position         = UDim2.new(0.52, 0, 0, 0)
    confirmBtn.BackgroundColor3 = Theme.Accent
    confirmBtn.Text             = opts.Confirm or "Confirm"
    confirmBtn.TextColor3       = Theme.Accent2
    confirmBtn.Font             = Config.Font
    confirmBtn.TextSize         = 13
    confirmBtn.BorderSizePixel  = 0
    confirmBtn.ZIndex           = 8003
    confirmBtn.AutoButtonColor  = false
    confirmBtn.Parent           = btnRow
    MakeCorner(Config.CornerElem, confirmBtn)

    local comp: {[string]: any} = {}
    comp._instance    = backdrop
    comp._connections = {}
    ApplyEventMixin(comp)

    function comp:_connect(conn: RBXScriptConnection)
        table.insert(self._connections, conn)
    end

    function comp:Open(): typeof(comp)
        backdrop.Visible                    = true
        backdrop.BackgroundTransparency     = 1
        modalFrame.Size                     = UDim2.new(0, 420, 0, 0)
        MonochromeLib.Tween(backdrop, {BackgroundTransparency = 0.4}, 0.2)
        MonochromeLib.Tween(modalFrame, {Size = UDim2.new(0, 420, 0, 220)}, 0.25)
        return self
    end

    function comp:Close(): typeof(comp)
        MonochromeLib.Tween(backdrop, {BackgroundTransparency = 1}, 0.2)
        MonochromeLib.Tween(modalFrame, {Size = UDim2.new(0, 420, 0, 0)}, 0.2)
        task.delay(0.2, function() backdrop.Visible = false end)
        return self
    end

    function comp:OnConfirm(callback: () -> ()): typeof(comp)
        self:On("Confirm", callback)
        return self
    end

    function comp:OnCancel(callback: () -> ()): typeof(comp)
        self:On("Cancel", callback)
        return self
    end

    function comp:SetContent(instance: Instance): typeof(comp)
        instance.Parent     = customHolder
        customHolder.Visible = true
        bodyLbl.Visible     = false
        return self
    end

    function comp:Destroy()
        for _, conn in ipairs(self._connections) do conn:Disconnect() end
        backdrop:Destroy()
    end

    comp:_connect(confirmBtn.MouseButton1Click:Connect(function()
        comp:Fire("Confirm")
        comp:Close()
    end))

    comp:_connect(cancelBtn.MouseButton1Click:Connect(function()
        comp:Fire("Cancel")
        comp:Close()
    end))

    -- Hover effects
    comp:_connect(confirmBtn.MouseEnter:Connect(function()
        MonochromeLib.Tween(confirmBtn, {BackgroundColor3 = Color3.fromRGB(220,220,220)}, 0.1)
    end))
    comp:_connect(confirmBtn.MouseLeave:Connect(function()
        MonochromeLib.Tween(confirmBtn, {BackgroundColor3 = Theme.Accent}, 0.1)
    end))
    comp:_connect(cancelBtn.MouseEnter:Connect(function()
        MonochromeLib.Tween(cancelBtn, {BackgroundColor3 = Theme.Border}, 0.1)
    end))
    comp:_connect(cancelBtn.MouseLeave:Connect(function()
        MonochromeLib.Tween(cancelBtn, {BackgroundColor3 = Theme.Surface2}, 0.1)
    end))

    return comp
end

-- ══════════════════════════════════════════════
--  9. KEYBIND PICKER
-- ══════════════════════════════════════════════
function MonochromeLib.KeybindPicker(parent: Instance, opts: {
    Label:   string?,
    Default: Enum.KeyCode?,
}): {[string]: any}

    opts = opts or {}
    local currentKey: Enum.KeyCode? = opts.Default
    local listening = false

    local frame = Instance.new("Frame")
    frame.Name             = "MonoKeybind"
    frame.Size             = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -120, 1, 0)
    lbl.Position          = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = opts.Label or "Keybind"
    lbl.TextColor3        = Theme.TextPrimary
    lbl.Font              = Config.Font
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = frame.ZIndex + 1
    lbl.Parent            = frame

    local badge = Instance.new("Frame")
    badge.Size             = UDim2.new(0, 100, 0, 24)
    badge.Position         = UDim2.new(1, -108, 0.5, -12)
    badge.BackgroundColor3 = Theme.Surface2
    badge.BorderSizePixel  = 0
    badge.ZIndex           = frame.ZIndex + 1
    badge.Parent           = frame
    MakeCorner(Config.CornerSmall, badge)
    MakeStroke(Theme.Border, 1, badge)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size              = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text              = currentKey and currentKey.Name or "None"
    badgeText.TextColor3        = Theme.TextMuted
    badgeText.Font              = Config.Font
    badgeText.TextSize          = 11
    badgeText.ZIndex            = frame.ZIndex + 2
    badgeText.Parent            = badge

    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.ZIndex            = frame.ZIndex + 3
    btn.AutoButtonColor   = false
    btn.Parent            = frame

    local comp = BaseComponent(frame)

    local function StartListening()
        listening = true
        badgeText.Text       = "..."
        badgeText.TextColor3 = Theme.TextPrimary
        MonochromeLib.Tween(badge, {BackgroundColor3 = Theme.Surface2}, 0.1)
    end

    comp:_connect(btn.MouseButton1Click:Connect(function()
        if not listening then StartListening() end
    end))

    comp:_connect(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            -- Build display (check modifiers)
            local parts = {}
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                table.insert(parts, "Ctrl")
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                table.insert(parts, "Shift")
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
                table.insert(parts, "Alt")
            end
            -- Don't capture pure modifier
            if input.KeyCode ~= Enum.KeyCode.LeftControl
                and input.KeyCode ~= Enum.KeyCode.RightControl
                and input.KeyCode ~= Enum.KeyCode.LeftShift
                and input.KeyCode ~= Enum.KeyCode.RightShift
                and input.KeyCode ~= Enum.KeyCode.LeftAlt
                and input.KeyCode ~= Enum.KeyCode.RightAlt then
                table.insert(parts, input.KeyCode.Name)
                currentKey = input.KeyCode
                badgeText.Text       = table.concat(parts, "+")
                badgeText.TextColor3 = Theme.TextPrimary
                listening = false
                comp:Fire("Change", currentKey)
            end
        end
    end))

    function comp:GetKeybind(): Enum.KeyCode?
        return currentKey
    end

    function comp:OnChange(callback: (Enum.KeyCode) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    return comp
end

-- ══════════════════════════════════════════════
--  10. COLOR PICKER (MONOCHROME / GRAYSCALE)
-- ══════════════════════════════════════════════
function MonochromeLib.ColorPicker(parent: Instance, opts: {
    Label:   string?,
    Default: Color3?,
}): {[string]: any}

    opts = opts or {}
    local currentColor = opts.Default or Color3.fromRGB(128, 128, 128)
    -- Extract brightness (0..1) from grayscale color
    local brightness = currentColor.R

    local frame = Instance.new("Frame")
    frame.Name             = "MonoColorPicker"
    frame.Size             = UDim2.new(1, 0, 0, 80)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)

    if opts.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(1, 0, 0, 18)
        lbl.Position          = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text              = opts.Label
        lbl.TextColor3        = Theme.TextMuted
        lbl.Font              = Config.Font
        lbl.TextSize          = 11
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = frame.ZIndex + 1
        lbl.Parent            = frame
    end

    -- Gradient bar (black → white)
    local gradBar = Instance.new("Frame")
    gradBar.Size             = UDim2.new(1, -100, 0, 28)
    gradBar.Position         = UDim2.new(0, 12, 0, opts.Label and 26 or 10)
    gradBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    gradBar.BorderSizePixel  = 0
    gradBar.ClipsDescendants = true
    gradBar.ZIndex           = frame.ZIndex + 1
    gradBar.Parent           = frame
    MakeCorner(Config.CornerSmall, gradBar)

    local gradInst = Instance.new("UIGradient")
    gradInst.Color     = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    gradInst.Rotation  = 90 -- top = black, bottom = white... actually horizontal
    gradInst.Parent    = gradBar

    -- Knob on gradient
    local gradKnob = Instance.new("Frame")
    gradKnob.Size             = UDim2.new(0, 10, 1, 4)
    gradKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
    gradKnob.Position         = UDim2.new(brightness, 0, 0.5, 0)
    gradKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    gradKnob.BorderSizePixel  = 0
    gradKnob.ZIndex           = frame.ZIndex + 2
    gradKnob.Parent           = gradBar
    MakeCorner(3, gradKnob)
    MakeStroke(Theme.Border, 1, gradKnob)

    -- Preview swatch
    local swatch = Instance.new("Frame")
    swatch.Size             = UDim2.new(0, 36, 0, 36)
    swatch.Position         = UDim2.new(1, -50, 0, opts.Label and 20 or 6)
    swatch.BackgroundColor3 = currentColor
    swatch.BorderSizePixel  = 0
    swatch.ZIndex           = frame.ZIndex + 1
    swatch.Parent           = frame
    MakeCorner(Config.CornerSmall, swatch)
    MakeStroke(Theme.Border, 1, swatch)

    -- Hex input
    local hexBox = Instance.new("TextBox")
    hexBox.Size             = UDim2.new(1, -100, 0, 22)
    hexBox.Position         = UDim2.new(0, 12, 1, -30)
    hexBox.BackgroundColor3 = Theme.Surface2
    hexBox.Text             = string.format("#%02X%02X%02X",
        math.round(currentColor.R*255),
        math.round(currentColor.G*255),
        math.round(currentColor.B*255))
    hexBox.TextColor3       = Theme.TextPrimary
    hexBox.Font             = Config.Font
    hexBox.TextSize         = 11
    hexBox.BorderSizePixel  = 0
    hexBox.ClearTextOnFocus = false
    hexBox.ZIndex           = frame.ZIndex + 2
    hexBox.Parent           = frame
    MakeCorner(Config.CornerSmall, hexBox)

    local hexPad = Instance.new("UIPadding")
    hexPad.PaddingLeft = UDim.new(0, 6)
    hexPad.Parent      = hexBox

    local comp = BaseComponent(frame)
    comp._value = currentColor

    local function SetColor(c: Color3)
        currentColor   = c
        comp._value    = c
        brightness     = c.R
        swatch.BackgroundColor3 = c
        gradKnob.Position = UDim2.new(brightness, 0, 0.5, 0)
        hexBox.Text = string.format("#%02X%02X%02X",
            math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
        comp:Fire("Change", c)
    end

    -- Drag on gradient bar
    local dragging = false
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size              = UDim2.new(1, 0, 1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text              = ""
    dragBtn.ZIndex            = frame.ZIndex + 3
    dragBtn.AutoButtonColor   = false
    dragBtn.Parent            = gradBar

    local function SetFromX(absX: number)
        local gx = gradBar.AbsolutePosition.X
        local gw = gradBar.AbsoluteSize.X
        local pct = math.clamp((absX - gx) / gw, 0, 1)
        local v = math.round(pct * 255)
        SetColor(Color3.fromRGB(v, v, v))
    end

    comp:_connect(dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(input.Position.X)
        end
    end))

    comp:_connect(UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            SetFromX(input.Position.X)
        end
    end))

    comp:_connect(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    comp:_connect(hexBox.FocusLost:Connect(function()
        local hex = hexBox.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 0
            local g = tonumber(hex:sub(3,4), 16) or 0
            local b = tonumber(hex:sub(5,6), 16) or 0
            -- Force grayscale: average
            local avg = math.floor((r + g + b) / 3)
            SetColor(Color3.fromRGB(avg, avg, avg))
        end
    end))

    function comp:GetValue(): Color3
        return self._value
    end

    function comp:SetValue(c: Color3): typeof(comp)
        SetColor(c)
        return self
    end

    function comp:OnChange(callback: (Color3) -> ()): typeof(comp)
        self:On("Change", callback)
        return self
    end

    return comp
end

-- ══════════════════════════════════════════════
--  11. LABEL & PARAGRAPH
-- ══════════════════════════════════════════════
function MonochromeLib.Label(parent: Instance, opts: {
    Text:     string?,
    Size:     number?,
    Color:    Color3?,
    Muted:    boolean?,
    Truncate: boolean?,
}): {[string]: any}

    opts = opts or {}
    local frame = Instance.new("Frame")
    frame.Name             = "MonoLabel"
    frame.Size             = UDim2.new(1, 0, 0, opts.Size and opts.Size + 4 or 22)
    frame.BackgroundTransparency = 1
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = opts.Text or ""
    lbl.TextColor3        = opts.Color or (opts.Muted and Theme.TextMuted or Theme.TextPrimary)
    lbl.Font              = Config.Font
    lbl.TextSize          = opts.Size or 14
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.RichText          = true
    lbl.ZIndex            = frame.ZIndex + 1
    lbl.TextTruncate      = opts.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
    lbl.Parent            = frame

    local comp = BaseComponent(frame)
    comp._label = lbl

    function comp:SetText(str: string): typeof(comp)
        lbl.Text = str
        return self
    end

    function comp:SetSize(s: number): typeof(comp)
        lbl.TextSize = s
        return self
    end

    function comp:SetColor(c: Color3): typeof(comp)
        lbl.TextColor3 = c
        return self
    end

    -- Tooltip for truncated text
    if opts.Truncate then
        local tooltip: Frame? = nil
        comp:_connect(lbl.MouseEnter:Connect(function()
            -- Show full text tooltip
            if tooltip then tooltip:Destroy() end
            tooltip = Instance.new("Frame")
            tooltip.Size             = UDim2.new(0, 0, 0, 24)
            tooltip.AutomaticSize    = Enum.AutomaticSize.X
            tooltip.Position         = UDim2.new(0, 0, 1, 4)
            tooltip.BackgroundColor3 = Theme.Surface2
            tooltip.BorderSizePixel  = 0
            tooltip.ZIndex           = 9999
            tooltip.Parent           = frame
            MakeCorner(Config.CornerSmall, tooltip)
            MakeStroke(Theme.Border, 1, tooltip)

            local ttLbl = Instance.new("TextLabel")
            ttLbl.Size              = UDim2.new(0, 0, 1, 0)
            ttLbl.AutomaticSize     = Enum.AutomaticSize.X
            ttLbl.BackgroundTransparency = 1
            ttLbl.Text              = opts.Text or ""
            ttLbl.TextColor3        = Theme.TextPrimary
            ttLbl.Font              = Config.Font
            ttLbl.TextSize          = 12
            ttLbl.ZIndex            = 10000
            ttLbl.Parent            = tooltip

            local ttPad = Instance.new("UIPadding")
            ttPad.PaddingLeft  = UDim.new(0, 8)
            ttPad.PaddingRight = UDim.new(0, 8)
            ttPad.Parent       = ttLbl
        end))

        comp:_connect(lbl.MouseLeave:Connect(function()
            if tooltip then
                tooltip:Destroy()
                tooltip = nil
            end
        end))
    end

    return comp
end

-- Paragraph (multiline)
function MonochromeLib.Paragraph(parent: Instance, opts: {
    Text:  string?,
    Size:  number?,
    Color: Color3?,
}): {[string]: any}
    opts = opts or {}
    local frame = Instance.new("Frame")
    frame.Name             = "MonoParagraph"
    frame.Size             = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize    = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize     = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Text              = opts.Text or ""
    lbl.TextColor3        = opts.Color or Theme.TextMuted
    lbl.Font              = Config.Font
    lbl.TextSize          = opts.Size or 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.TextWrapped       = true
    lbl.RichText          = true
    lbl.ZIndex            = frame.ZIndex + 1
    lbl.Parent            = frame

    local comp = BaseComponent(frame)
    comp._label = lbl

    function comp:SetText(str: string): typeof(comp)
        lbl.Text = str
        return self
    end

    function comp:SetSize(s: number): typeof(comp)
        lbl.TextSize = s
        return self
    end

    function comp:SetColor(c: Color3): typeof(comp)
        lbl.TextColor3 = c
        return self
    end

    return comp
end

-- ══════════════════════════════════════════════
--  12. SEPARATOR
-- ══════════════════════════════════════════════
function MonochromeLib.Separator(parent: Instance, opts: {
    Label: string?,
}): {[string]: any}

    opts = opts or {}
    local frame = Instance.new("Frame")
    frame.Name             = "MonoSeparator"
    frame.Size             = UDim2.new(1, 0, 0, 20)
    frame.BackgroundTransparency = 1
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent

    if opts.Label and opts.Label ~= "" then
        local leftLine = Instance.new("Frame")
        leftLine.Size             = UDim2.new(0.3, -8, 0, 1)
        leftLine.Position         = UDim2.new(0, 0, 0.5, 0)
        leftLine.BackgroundColor3 = Theme.Border
        leftLine.BorderSizePixel  = 0
        leftLine.ZIndex           = frame.ZIndex + 1
        leftLine.Parent           = frame

        local centerLbl = Instance.new("TextLabel")
        centerLbl.Size              = UDim2.new(0.4, 0, 1, 0)
        centerLbl.Position          = UDim2.new(0.3, 0, 0, 0)
        centerLbl.BackgroundTransparency = 1
        centerLbl.Text              = opts.Label
        centerLbl.TextColor3        = Theme.TextMuted
        centerLbl.Font              = Config.Font
        centerLbl.TextSize          = 11
        centerLbl.ZIndex            = frame.ZIndex + 1
        centerLbl.Parent            = frame

        local rightLine = Instance.new("Frame")
        rightLine.Size             = UDim2.new(0.3, -8, 0, 1)
        rightLine.Position         = UDim2.new(0.7, 8, 0.5, 0)
        rightLine.BackgroundColor3 = Theme.Border
        rightLine.BorderSizePixel  = 0
        rightLine.ZIndex           = frame.ZIndex + 1
        rightLine.Parent           = frame
    else
        local line = Instance.new("Frame")
        line.Size             = UDim2.new(1, 0, 0, 1)
        line.Position         = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = Theme.Border
        line.BorderSizePixel  = 0
        line.ZIndex           = frame.ZIndex + 1
        line.Parent           = frame
    end

    local comp = BaseComponent(frame)

    function comp:SetLabel(str: string): typeof(comp)
        -- Rebuild would be complex; simplest solution: find centerLbl
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextLabel") then
                (child :: TextLabel).Text = str
            end
        end
        return self
    end

    return comp
end

-- ══════════════════════════════════════════════
--  13. PROGRESS BAR
-- ══════════════════════════════════════════════
function MonochromeLib.ProgressBar(parent: Instance, opts: {
    Label:         string?,
    Indeterminate: boolean?,
}): {[string]: any}

    opts = opts or {}
    local indeterminate = opts.Indeterminate or false
    local currentValue  = 0

    local frame = Instance.new("Frame")
    frame.Name             = "MonoProgressBar"
    frame.Size             = UDim2.new(1, 0, 0, opts.Label and 40 or 18)
    frame.BackgroundTransparency = 1
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent

    if opts.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text              = opts.Label
        lbl.TextColor3        = Theme.TextMuted
        lbl.Font              = Config.Font
        lbl.TextSize          = 11
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = frame.ZIndex + 1
        lbl.Parent            = frame
    end

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, 0, 0, 6)
    track.Position         = UDim2.new(0, 0, 0, opts.Label and 22 or 6)
    track.BackgroundColor3 = Theme.Border
    track.BorderSizePixel  = 0
    track.ClipsDescendants = true
    track.ZIndex           = frame.ZIndex + 1
    track.Parent           = frame
    MakeCorner(3, track)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = frame.ZIndex + 2
    fill.Parent           = track
    MakeCorner(3, fill)

    local comp = BaseComponent(frame)
    comp._indeterminate = indeterminate
    comp._shimmerConn   = nil :: RBXScriptConnection?

    -- Shimmer for indeterminate
    local shimmer = Instance.new("Frame")
    shimmer.Size             = UDim2.new(0.35, 0, 1, 0)
    shimmer.Position         = UDim2.new(-0.35, 0, 0, 0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shimmer.BackgroundTransparency = 0.6
    shimmer.BorderSizePixel  = 0
    shimmer.ZIndex           = frame.ZIndex + 3
    shimmer.Visible          = false
    shimmer.Parent           = track

    local shimGrad = Instance.new("UIGradient")
    shimGrad.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
    })
    shimGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    shimGrad.Parent = shimmer

    local function StartShimmer()
        shimmer.Visible  = true
        fill.Size        = UDim2.new(0, 0, 1, 0)
        shimmer.Position = UDim2.new(-0.35, 0, 0, 0)

        local function Loop()
            MonochromeLib.Tween(shimmer, {Position = UDim2.new(1, 0, 0, 0)}, 1.2, Enum.EasingStyle.Sine)
            task.delay(1.2, function()
                shimmer.Position = UDim2.new(-0.35, 0, 0, 0)
                if comp._indeterminate then Loop() end
            end)
        end
        Loop()
    end

    local function StopShimmer()
        shimmer.Visible = false
    end

    function comp:SetValue(v: number): typeof(comp)
        currentValue = math.clamp(v, 0, 1)
        if not self._indeterminate then
            MonochromeLib.Tween(fill, {Size = UDim2.new(currentValue, 0, 1, 0)}, 0.3)
        end
        return self
    end

    function comp:SetIndeterminate(v: boolean): typeof(comp)
        self._indeterminate = v
        if v then
            StartShimmer()
        else
            StopShimmer()
            MonochromeLib.Tween(fill, {Size = UDim2.new(currentValue, 0, 1, 0)}, 0.3)
        end
        return self
    end

    if indeterminate then
        StartShimmer()
    end

    return comp
end

-- ══════════════════════════════════════════════
--  14. TABLE / LIST
-- ══════════════════════════════════════════════
function MonochromeLib.Table(parent: Instance, opts: {
    Columns: {{Name: string, Key: string}}?,
    Size:    UDim2?,
}): {[string]: any}

    opts = opts or {}
    local columns = opts.Columns or {}
    local data: {{[string]: any}} = {}
    local sortKey: string?   = nil
    local sortAsc            = true

    local frame = Instance.new("Frame")
    frame.Name             = "MonoTable"
    frame.Size             = opts.Size or UDim2.new(1, 0, 0, 200)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = NextZIndex()
    frame.Parent           = parent
    MakeCorner(Config.CornerElem, frame)
    MakeStroke(Theme.Border, 1, frame)

    -- Header
    local header = Instance.new("Frame")
    header.Size             = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Theme.Surface2
    header.BorderSizePixel  = 0
    header.ZIndex           = frame.ZIndex + 1
    header.Parent           = frame
    MakeCorner(Config.CornerElem, header)

    -- Header cols
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection     = Enum.FillDirection.Horizontal
    headerLayout.SortOrder         = Enum.SortOrder.LayoutOrder
    headerLayout.Parent            = header

    local headerBtns: {TextButton} = {}

    -- Row scroll
    local rowScroll = Instance.new("ScrollingFrame")
    rowScroll.Size                  = UDim2.new(1, 0, 1, -30)
    rowScroll.Position              = UDim2.new(0, 0, 0, 30)
    rowScroll.BackgroundTransparency = 1
    rowScroll.BorderSizePixel       = 0
    rowScroll.ScrollBarThickness    = 4
    rowScroll.ScrollBarImageColor3  = Theme.Border
    rowScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    rowScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    rowScroll.ZIndex                = frame.ZIndex + 1
    rowScroll.Parent                = frame

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent    = rowScroll

    local comp = BaseComponent(frame)
    comp._columns = columns
    comp._data    = data

    local function BuildHeader()
        for _, b in ipairs(headerBtns) do b:Destroy() end
        headerBtns = {}

        for i, col in ipairs(columns) do
            local colW = 1 / #columns
            local colBtn = Instance.new("TextButton")
            colBtn.Size              = UDim2.new(colW, 0, 1, 0)
            colBtn.BackgroundTransparency = 1
            colBtn.Text              = col.Name .. (sortKey == col.Key and (sortAsc and " ↑" or " ↓") or "")
            colBtn.TextColor3        = Theme.TextMuted
            colBtn.Font              = Config.Font
            colBtn.TextSize          = 11
            colBtn.BorderSizePixel   = 0
            colBtn.LayoutOrder       = i
            colBtn.AutoButtonColor   = false
            colBtn.ZIndex            = frame.ZIndex + 2
            colBtn.Parent            = header
            table.insert(headerBtns, colBtn)

            colBtn.MouseButton1Click:Connect(function()
                if sortKey == col.Key then
                    sortAsc = not sortAsc
                else
                    sortKey = col.Key
                    sortAsc = true
                end
                comp:SetData(data) -- re-render
            end)
        end
    end

    local function BuildRows()
        for _, child in ipairs(rowScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local sorted = table.clone(data)
        if sortKey then
            table.sort(sorted, function(a, b)
                local av = tostring(a[sortKey] or "")
                local bv = tostring(b[sortKey] or "")
                return sortAsc and av < bv or av > bv
            end)
        end

        for rowIdx, row in ipairs(sorted) do
            local rowFrame = Instance.new("Frame")
            rowFrame.Size             = UDim2.new(1, 0, 0, 28)
            rowFrame.BackgroundColor3 = rowIdx % 2 == 0
                and Color3.fromRGB(26,26,26)
                or  Color3.fromRGB(20,20,20)
            rowFrame.BorderSizePixel  = 0
            rowFrame.ZIndex           = frame.ZIndex + 2
            rowFrame.LayoutOrder      = rowIdx
            rowFrame.Parent           = rowScroll

            local rowBtnOverlay = Instance.new("TextButton")
            rowBtnOverlay.Size              = UDim2.new(1, 0, 1, 0)
            rowBtnOverlay.BackgroundTransparency = 1
            rowBtnOverlay.Text              = ""
            rowBtnOverlay.ZIndex            = frame.ZIndex + 5
            rowBtnOverlay.AutoButtonColor   = false
            rowBtnOverlay.Parent            = rowFrame

            local capturedRow = row
            rowBtnOverlay.MouseEnter:Connect(function()
                MonochromeLib.Tween(rowFrame, {BackgroundColor3 = Theme.Surface2}, 0.1)
            end)
            rowBtnOverlay.MouseLeave:Connect(function()
                MonochromeLib.Tween(rowFrame, {
                    BackgroundColor3 = rowIdx % 2 == 0
                        and Color3.fromRGB(26,26,26)
                        or  Color3.fromRGB(20,20,20)
                }, 0.1)
            end)
            rowBtnOverlay.MouseButton1Click:Connect(function()
                comp:Fire("RowClick", capturedRow, rowIdx)
            end)

            local rowColLayout = Instance.new("UIListLayout")
            rowColLayout.FillDirection = Enum.FillDirection.Horizontal
            rowColLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            rowColLayout.Parent        = rowFrame

            for i, col in ipairs(columns) do
                local cell = Instance.new("TextLabel")
                cell.Size              = UDim2.new(1 / #columns, 0, 1, 0)
                cell.BackgroundTransparency = 1
                cell.Text              = tostring(row[col.Key] or "")
                cell.TextColor3        = Theme.TextPrimary
                cell.Font              = Config.Font
                cell.TextSize          = 12
                cell.TextXAlignment    = Enum.TextXAlignment.Left
                cell.TextTruncate      = Enum.TextTruncate.AtEnd
                cell.LayoutOrder       = i
                cell.ZIndex            = frame.ZIndex + 3
                cell.Parent            = rowFrame

                local cellPad = Instance.new("UIPadding")
                cellPad.PaddingLeft = UDim.new(0, 8)
                cellPad.Parent      = cell
            end
        end
    end

    function comp:SetColumns(cols: {{Name: string, Key: string}}): typeof(comp)
        columns = cols
        BuildHeader()
        BuildRows()
        return self
    end

    function comp:SetData(d: {{[string]: any}}): typeof(comp)
        data = d
        BuildHeader()
        BuildRows()
        return self
    end

    function comp:OnRowClick(callback: ({[string]: any}, number) -> ()): typeof(comp)
        self:On("RowClick", callback)
        return self
    end

    BuildHeader()
    return comp
end

-- ══════════════════════════════════════════════
--  15. TOOLTIP
-- ══════════════════════════════════════════════
function MonochromeLib.Tooltip(): {[string]: any}
    local tooltipFrame: Frame? = nil
    local hoverTimer: thread?  = nil

    local tooltip: {[string]: any} = {}

    function tooltip:Attach(instance: GuiObject, text: string)
        instance.MouseEnter:Connect(function()
            hoverTimer = task.delay(0.4, function()
                if tooltipFrame then tooltipFrame:Destroy() end

                tooltipFrame = Instance.new("Frame")
                tooltipFrame.Size             = UDim2.new(0, 0, 0, 26)
                tooltipFrame.AutomaticSize    = Enum.AutomaticSize.X
                tooltipFrame.BackgroundColor3 = Theme.Surface2
                tooltipFrame.BorderSizePixel  = 0
                tooltipFrame.ZIndex           = 9999
                tooltipFrame.Parent           = ScreenGui
                MakeCorner(Config.CornerSmall, tooltipFrame)
                MakeStroke(Theme.Border, 1, tooltipFrame)

                local ttLbl = Instance.new("TextLabel")
                ttLbl.Size              = UDim2.new(0, 0, 1, 0)
                ttLbl.AutomaticSize     = Enum.AutomaticSize.X
                ttLbl.BackgroundTransparency = 1
                ttLbl.Text              = text
                ttLbl.TextColor3        = Theme.TextPrimary
                ttLbl.Font              = Config.Font
                ttLbl.TextSize          = 12
                ttLbl.ZIndex            = 10000
                ttLbl.Parent            = tooltipFrame

                local ttPad = Instance.new("UIPadding")
                ttPad.PaddingLeft  = UDim.new(0, 10)
                ttPad.PaddingRight = UDim.new(0, 10)
                ttPad.Parent       = ttLbl

                -- Position near cursor
                local function UpdatePos()
                    local mp = UserInputService:GetMouseLocation()
                    local screenSize = ScreenGui.AbsoluteSize
                    local ttSize = tooltipFrame.AbsoluteSize
                    local x = mp.X + 12
                    local y = mp.Y - 30
                    -- Flip if near edges
                    if x + ttSize.X > screenSize.X then x = mp.X - ttSize.X - 12 end
                    if y < 0 then y = mp.Y + 12 end
                    tooltipFrame.Position = UDim2.new(0, x, 0, y)
                end

                UpdatePos()
                -- Track mouse movement
                local moveConn: RBXScriptConnection
                moveConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if tooltipFrame then UpdatePos() end
                    end
                end)

                -- Store conn for cleanup
                if tooltipFrame then
                    tooltipFrame.Destroying:Connect(function()
                        moveConn:Disconnect()
                    end)
                end
            end)
        end)

        instance.MouseLeave:Connect(function()
            if hoverTimer then
                task.cancel(hoverTimer)
                hoverTimer = nil
            end
            if tooltipFrame then
                tooltipFrame:Destroy()
                tooltipFrame = nil
            end
        end)
    end

    return tooltip
end

-- ══════════════════════════════════════════════
--  GLOBAL DESTROY
-- ══════════════════════════════════════════════
function MonochromeLib.Destroy()
    ScreenGui:Destroy()
end

-- ══════════════════════════════════════════════
--  ZIndex utility (exposed)
-- ══════════════════════════════════════════════
MonochromeLib.ZIndex = NextZIndex

return MonochromeLib