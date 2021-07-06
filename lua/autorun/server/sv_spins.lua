local currentSpins = currentSpins or {}

for k, v in pairs(Spins.Spins) do
    currentSpins[k] = {
        spinning = false,
        countingDown = false,
        randomNumber = math.random(10, 25),
        watching = {},
        players = {}
    }
end

util.AddNetworkString("Spins.Result")
local function SendResult(winningID, spinID)
    net.Start("Spins.Result")
        net.WriteUInt(winningID, 4)
        net.WriteUInt(spinID, 4)
    net.Send(table.GetKeys(currentSpins[spinID].watching))
end


util.AddNetworkString("Spins.NewPlayer")
local function NewPlayer(ply, amount, betID, spinID)
    net.Start("Spins.NewPlayer")
        net.WriteEntity(ply)
        net.WriteUInt(amount, 32)
        net.WriteUInt(betID, 4)
    net.Send(table.GetKeys(currentSpins[spinID].watching))
end

local function EndSpin(spinID, spinData, winningID)
    timer.Simple(5, function()
        currentSpins[spinID].spinning = false
    end)
    currentSpins[spinID].randomNumber = math.random(10, 25)
    SendResult(winningID, spinID)
    for k, v in pairs(currentSpins[spinID].players) do
        if !IsValid(k) then continue end
        local isWatching = currentSpins[spinID].watching[k]
        if v.betID == winningID then
            local wonAmount = spinData[v.betID].payout * v.amount
            if !isWatching then
                k:ChatPrint("You won " .. DarkRP.formatMoney(wonAmount) .. "!")
            end
            timer.Simple(12, function()
                k:addMoney(wonAmount)
            end)
        else
            if !isWatching then
                k:ChatPrint("You lost your spin.")
            end
        end
    end
    currentSpins[spinID].players = {}
end

local function Spin(spinID)
    currentSpins[spinID].spinning = true
    local spinData = Spins.Spins[spinID]
    math.random(0, 101) // maybe this works lol
    local rand = math.random(0, Spins.TotalChance)
    for k, v in RandomPairs(spinData) do
        if v.range(rand) then
            EndSpin(spinID, spinData, k)
            break
        end
    end
end

local function EnterSpin(ply, amount, betID, spinID)
    ply:addMoney(-amount)
    currentSpins[spinID].players[ply] = {amount = amount, betID = betID}
    NewPlayer(ply, amount, betID, spinID)
    if !currentSpins[spinID].countingDown then
        currentSpins[spinID].countingDown = true
        timer.Simple(10, function()
            Spin(spinID)
            currentSpins[spinID].countingDown = false
        end)
    end
end

concommand.Add("_start_spin", function(ply, cmd, args)
    if !args[1] or !args[2] or !args[3] then return end
    local spinID = tonumber(args[1])
    local betID = tonumber(args[3])
    local amount = tonumber(args[2])
    local currentSpin = currentSpins[spinID]

    if currentSpin and !currentSpin.players[ply] and amount >= 100 and ply:canAfford(amount) then
        if currentSpin.spinning then
            ply:ChatPrint("There is spin already going on.")
        else
            EnterSpin(ply, amount, betID, spinID)
        end
    end
end)

util.AddNetworkString("Spins.Menu")
local function SendMenu(ply)
    local spinID = 1
    currentSpins[spinID].watching[ply] = true
    net.Start("Spins.Menu")
        net.WriteTable(currentSpins[spinID].players)
        net.WriteUInt(currentSpins[spinID].randomNumber, 6)
    net.Send(ply)
end

hook.Add( "PlayerSay", "Spins", function( ply, text )
    if  ( string.lower( text ) == "/spins" or string.lower( text ) == "!spins" ) then
         SendMenu(ply)
        return
    end
end )

concommand.Add("_spins_close_menu", function(ply, cmd, args)
    local spinID = 1
    if currentSpins[spinID].watching[ply] then
        currentSpins[spinID].watching[ply] = nil
    end
end)

hook.Add("PlayerDisconnected", "Spins.Remove", function(ply)
    local spinID = 1
    if currentSpins[spinID].watching[ply] then
        currentSpins[spinID].watching[ply] = nil
    end
    if currentSpins[spinID].players[ply] then
        currentSpins[spinID].players[ply] = nil
    end
end)