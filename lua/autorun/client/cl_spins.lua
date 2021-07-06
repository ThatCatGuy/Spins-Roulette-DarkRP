local spinPanels = {}

local speed = 0
local endPoint = 0
local spinning = false
local pnlW, pnlH = 100, 100
local buttonH = 30
local betPanelH = 150
local w, h = 680, pnlH + buttonH + 15 + betPanelH
local rand = 0 
local spinPanel
local winningID 
local spinID 
local currentBet
local players = {}
local playersPanel

local function drawBox(x, y, w, h, col)
    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
end

local function drawOutline(w, h, col)
    surface.SetDrawColor(col)
    surface.DrawOutlinedRect(0, 0, w, h)
end

local function EndSpin()
    if players[LocalPlayer()] then
        chat.AddText(Color(25, 222, 134), "Spins | ", color_white, Spins.Spins[1][winningID].name .. " was rolled!")
        chat.AddText(Color(25, 222, 134), "Spins | ", color_white, winningID == currentBet and "You won!" or "You lost.")
        surface.PlaySound("buttons/lever6.wav")
    end
    speed = 0
    spinning = false
    currentBet = false
    players = {}
    if spinPanel then
        spinPanel:GetParent().text = "Spins | Spinning soon..."
    end
    if playersPanel then
        playersPanel.RemoveChildren(true)
    end
    FrameButton:SetEnabled(true)
end

local function RemoveOldPanels()
    for k, v in pairs(spinPanels) do
        v.panel:Remove()
    end
end

local function CreateFrame()
    if OldFrameCross and IsValid(OldFrameCross) then OldFrameCross:Remove() OldFrameCross = nil end
    local frame = vgui.Create("DFrame")
    OldFrameCross = frame
    frame:SetTitle("Spins")
    frame:SetPos(ScrW() / 2, ScrH() / 2)
    frame:SetSize(w, h + 30)
    frame:ShowCloseButton(false)
	frame:SetTitle("Spins | Spinning soon...")
    frame:Center()
    frame:MakePopup()
    frame.Paint = function()   
        draw.RoundedBox( 8, 0, 0, frame:GetWide(), frame:GetTall(), Color( 40, 40, 40, 255 ) )
    end
    frame.OnClose = function()
        if !spinning then
            RemoveOldPanels()
        end
        if spinning then
            EndSpin()
        end
        RunConsoleCommand("_spins_close_menu")
        currentBet = false
        playersPanel = false
    end

    local frameclose = vgui.Create( "DButton", frame )
    FrameButton = frameclose
    frameclose:SetColor( Color( 255, 255, 255 ) )
    frameclose:SetText( "" )
    frameclose:SetSize( 30, 30 )
    frameclose:SetPos(w - 30, 0 )
    frameclose.DoClick = function()
        frame:Remove()
    end
    frameclose.Paint = function( s, w, h )
        drawBox(0, 0, w, h, Color( 40, 40, 40, 255 ))
        drawBox(0, 0, w, 30, Color( 50, 50, 50, 255 ))

        local buttonW, buttonH = 30, 30
        local buttonX = w - buttonW
        local buttonY = 0

        drawBox(w - buttonW, 0, 29, 29, Color(255, 0, 0, 100))

        local lineSize = 15
        local overAllSize = lineSize
        local lineX = buttonX + ((buttonW / 2) - (overAllSize / 2))
        local lineY = buttonY + ((buttonW / 2) - (overAllSize / 2))
        surface.SetDrawColor(Color(230, 230, 230, 200))
        surface.DrawLine(lineX,
                        lineY,  
                        lineX + lineSize,
                        lineY + lineSize) 

        surface.DrawLine(lineX + lineSize,
                        lineY,  
                        lineX,
                        lineY + lineSize) 

        drawOutline(w, h, Color(0, 0, 0))
        drawOutline(w, 30, Color(0, 0, 0)) 
    end

    return frame
end

local function IsWinningPos(x)
    local x1, x2 = endPoint, endPoint + pnlW
    return x >= x1 and x < x2
end

local function CreateItems(spins, howMany, endPoint)
    for i = 0, howMany do
        local x = (pnlW * i)
        local item = IsWinningPos(x) and spins[winningID] or spins[math.random(1, 5)]
		spinPanels[i] = {}
		spinPanels[i].x = x
		spinPanels[i].name = item.name
		spinPanels[i].panel = vgui.Create("DPanel", spinPanel)
		spinPanels[i].panel:SetPos(x, 5)
		spinPanels[i].panel:SetSize(pnlW, pnlH)
		spinPanels[i].panel.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w, h, item.color)
			draw.SimpleText(item.name, "DermaLarge", 5, 5,Color(255,255,255))
        end
    end

    local line = vgui.Create("DPanel", spinPanel)
    line:SetSize(4, h)
    line:SetPos(w/2 - line:GetWide() / 2, 0)
    line.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30))
    end
end

local function Spin()
    RemoveOldPanels()
    endPoint = ((100 - math.random(10, 25)) * pnlW)
    rand = math.random(5, pnlW - 5)
    CreateItems(Spins.Spins[spinID], 100, endPoint)
    spinning = true
    spinPanel:GetParent():SetTitle("Spins | Spinning!")
end

local function CreateSpinPanel(frame)
    local panel = vgui.Create("DPanel", frame)
	panel:SetPos(frame:GetWide()/2  - (w/2), 30)
	panel:SetSize(w, pnlH)
	panel.Paint = function(self, w ,h)
		draw.RoundedBox(0,0,0,w,h,Color(30,30,30))
    end
    spinPanel = panel
end

local function NewRandomEndPoint(rand)
    endPoint = ((100 - rand) * pnlW)
end

local function CreateSpinButton(frame)
    local spin = vgui.Create("DButton", frame)
    spin:SetPos(5, spinPanel:GetTall() + spinPanel.y + 5)
    spin:SetSize(w / 2 - 7.5, buttonH)
    spin:SetText("Bet")
    spin:SetEnabled(false)
    return spin
end

local function CreateAmountEntry(frame, spin)
    local amount = vgui.Create("DTextEntry", frame)
    amount:SetSize(spin:GetSize())
    amount:SetPos(spin.x + spin:GetWide() + 5, spin.y)
    amount:SetPlaceholderText("Enter Bet Amount")
    amount:AllowInput(true)
    amount:SetUpdateOnType(true)
    amount:SetNumeric(true)
    return amount
end

local function CreateBetOptions(bets, betScroll)
    local height = betScroll:GetTall() / 2
    local betW = (betScroll:GetWide() / 2)
    for i=0, table.Count(Spins.Spins[1]) - 1 do
        local item = Spins.Spins[1][i + 1]
        if item.payout == 0 then continue end
        local pnl = bets:Add("DPanel")
        pnl:SetSize(betW, height)
        pnl.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, (!currentBet or currentBet == i + 1) and item.color or Color(60, 60, 60))
        end
        pnl:SetCursor("hand")

        local info = vgui.Create("DLabel", pnl)
        info:SetFont("DermaLarge")
        info:SetText(item.payout .. "x")
        info:SizeToContents()
        info:Center()
        info:SetColor(color_white)
        pnl.OnMousePressed = function()
            if !players[LocalPlayer()] then
                currentBet = i + 1
            end
        end
    end
end

local function CreateBetOptionsPanel(frame, spin)
    local betScroll = vgui.Create("DScrollPanel", frame)
    betScroll:SetSize(w / 2 - 5, betPanelH)
    betScroll:SetPos(5, spin.y + spin:GetTall() + 5)

    local bets = vgui.Create("DIconLayout", betScroll)
    bets:Dock(FILL)
    return betScroll, bets
end

local function CreatePlayerPanel(playersPanel, vbar, k, v)
    local pnl = vgui.Create("DPanel", playersPanel)
    pnl:SetTall(30)
    pnl:Dock(TOP)
    pnl:DockMargin(0, -1, 0, 0)
    pnl:SetBackgroundColor(Color(50, 50, 50, 255))
    local avatar = vgui.Create("avatarImage", pnl)
    avatar:SetSize(20, 20)
    avatar:SetPos(5, 5)
    avatar:SetPlayer(k, 64)
    local name = vgui.Create("DLabel", pnl)
    name:SetFont("DebugFixedSmall")
    name:SetText(k:Nick())
    name:SizeToContents()
    name:SetPos(avatar.x + avatar:GetWide() + 10, pnl:GetTall() / 2 - name:GetTall() / 2)
    local bet = vgui.Create("DLabel", pnl)
    bet:SetFont("DebugFixedSmall")
    bet:SetText(DarkRP.formatMoney(v.amount) .. " | " .. Spins.Spins[1][v.betID].name)
    bet:SizeToContents()
    bet:SetPos(playersPanel:GetWide() - bet:GetWide() - (vbar and vbar + 5 or 5), pnl:GetTall() / 2 - bet:GetTall() / 2)
    table.insert(playersPanel.Players, pnl)
end

local function CreatePlayersPanel(frame, betScroll)
    playersPanel = vgui.Create("DScrollPanel", frame)
    playersPanel:SetSize(w / 2 - 10, betPanelH)
    playersPanel:SetPos(betScroll.x + betScroll:GetWide() + 5, betScroll.y)
    playersPanel.Players = {}
    playersPanel.RemoveChildren = function(s, fade)
        for k, v in pairs(playersPanel.Players) do
            if IsValid(v) then
                if fade then
                    v:AlphaTo(0, 1, 0, function()
                        v:Remove()
                    end)
                else
                    v:Remove()
                end
            end
        end
    end
    playersPanel.UpdatePlayers = function()
        playersPanel.RemoveChildren()
        local vbar = false
        if table.Count(players) * 30 >= playersPanel:GetTall() then
            vbar = playersPanel:GetVBar():GetWide() 
        end
        for k, v in SortedPairsByMemberValue(players, "amount", true) do
            if !IsValid(k) then return end
            CreatePlayerPanel(playersPanel, vbar, k, v)
        end
    end
    playersPanel.UpdatePlayers()
end

local function OpenMenu()
    players = net.ReadTable()
    local frame = CreateFrame()
    CreateSpinPanel(frame)
    NewRandomEndPoint(net.ReadUInt(6))
    CreateItems(Spins.Spins[1], 100, 1, 3) // fake just for show
    local spin = CreateSpinButton(frame)
    local amount = CreateAmountEntry(frame, spin)
    local betScroll, bets = CreateBetOptionsPanel(frame, spin)
    CreateBetOptions(bets, betScroll)

    local value = nil
    amount.OnValueChange = function(s, v)
        if v == "" or tonumber(v) == nil then 
            spin:SetEnabled(false)
            return 
        end
        local val = tonumber(v)
        if val >= 100 then
            value = val 
            spin:SetEnabled(true)
        else
            spin:SetEnabled(false)
        end
    end
    spin.DoClick = function()
        if !spinning then 
            RunConsoleCommand("_start_spin", 1, value, currentBet)
            FrameButton:SetEnabled(false)
        end
    end
    CreatePlayersPanel(frame, betScroll)
end

net.Receive("Spins.Menu", OpenMenu)

hook.Add("Think", "Spins", function()
    if !spinning then return end
    speed = Lerp(0.25*FrameTime(), speed, endPoint)
    if speed >= (endPoint - w/2) + rand then
        EndSpin()
        return
    end
    for k ,v in pairs(spinPanels) do
		v.panel:SetPos(v.x - speed, 10)
    end
end)

net.Receive("Spins.NewPlayer", function()
    players[net.ReadEntity()] = {amount = net.ReadUInt(32), betID = net.ReadUInt(4)}
    if playersPanel and playersPanel.UpdatePlayers then
        playersPanel.UpdatePlayers()
    end
end)

net.Receive("Spins.Result", function()
    winningID = net.ReadUInt(4)
    spinID = net.ReadUInt(4)

    if spinPanel then
        spinPanel:GetParent().text = "Spins | Spinning..."
        Spin()
    end
end)