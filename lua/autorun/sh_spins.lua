Spins = Spins or {}

Spins.TotalChance = 135
Spins.Spins = {
    [1] = { //colours
        [1] = {name = "Black", color = Color(0, 0, 0), payout = 2, range = function(num) return num >= 0 and num <= 49 end},
        [2] = {name = "Red", color = Color(180, 10, 10), payout = 2, range = function(num) return num >= 50 and num <= 99 end},
        [3] = {name = "Green", color = Color(10, 180, 10), payout = 14, range = function(num) return num >= 100 and num <= 100 end},
        [4] = {name = "Blue", color = Color(10, 10, 180), payout = 14, range = function(num) return num >= 101 and num <= 101 end},
        [5] = {name = "Nothing", color = Color(80, 80, 80), payout = 0, range = function(num) return num >= 102 and num <= 135 end}
    }
}

function Spins.IsValid(spinID)
    return IsValid(Spins.Spins[spinID])
end