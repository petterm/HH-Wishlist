local _, Wishlist = ...

Wishlist.Comm = {}

local PREFIX = "HHWISHLIST"
local colorYellow, colorRed, colorBlue, colorPurple = Wishlist.Util.colorYellow,
    Wishlist.Util.colorRed, Wishlist.Util.colorBlue, Wishlist.Util.colorPurple


--[[========================================================
                        SETUP
========================================================]]--


function Wishlist:OnCommReceived(prefix, messageRaw, _, sender)
    if prefix ~= PREFIX then return end
    if sender == UnitName("player") then return end

    local success, messageType, data = Wishlist:Deserialize(messageRaw)

    if success then
        if type(Wishlist.Comm[messageType]) == "function" then
            Wishlist:DPrint(
                colorPurple("Received").." message "..colorYellow(messageType).." from "..colorYellow(sender)
            )
            Wishlist.Comm[messageType](Wishlist.Comm, data, sender)
        else
            Wishlist:DPrint(
                colorPurple("Received").." unknown message "..colorRed(messageType).." from "..colorYellow(sender)
            )
        end
    else
        Wishlist:DPrint(colorRed("Error deserializing message from "..sender))
    end
end


function Wishlist.Comm:Initialize()
    Wishlist:RegisterComm(PREFIX)
end


--[[========================================================
                        UTIL
========================================================]]--


function Wishlist.Comm:SendCommMessageGuild(type, data)
    Wishlist:DPrint(colorBlue("Send").." GUILD message", colorYellow(type))

    local messageRaw = Wishlist:Serialize(type, data)
    -- Wishlist:DPrint(messageRaw)
    Wishlist:SendCommMessage(PREFIX, messageRaw, "GUILD")
end


function Wishlist.Comm:SendCommMessageWhisper(type, data, player)
    Wishlist:DPrint(colorBlue("Send").." WHISPER message", colorYellow(type), colorYellow(player))

    local messageRaw = Wishlist:Serialize(type, data)
    -- Wishlist:DPrint(message)
    Wishlist:SendCommMessage(PREFIX, messageRaw, "WHISPER", player)
end


--[[========================================================
                    MESSAGE HANDLERS
========================================================]]--


-- Announcement of available data in another players database
function Wishlist.Comm:HAVE(theirPlayers, sender)
    local ourPlayers = Wishlist:GetPlayersData()
    local have = {}
    local want = {}

    -- for each player in data
    for playerName, _ in pairs(theirPlayers) do
        local ourPlayer = ourPlayers[playerName]
        -- if theirs is newer
        if theirPlayers[playerName] > (ourPlayer.requestedVersion or ourPlayer.version) then
            -- Add to WANT list
            want[playerName] = theirPlayers[playerName]

            -- Mark as wanted with requestedVersion
            ourPlayer.requestedVersion = theirPlayers[playerName]

        -- if ours is newer
        elseif theirPlayers[playerName] < ourPlayer.version then
            -- Add to HAVE list
            have[playerName] = ourPlayer.version
        end
    end

    -- for each player in local db
    for playerName, ourPlayer in pairs(ourPlayers) do
        if not theirPlayers[playerName] and not ourPlayer.requestedVersion then
            have[playerName] = ourPlayer.version
        end
    end

    if #have > 0 then
        self:SendHave(have, sender)
    end
    if #want > 0 then
        self:SendWant(want, sender)
    end
end


-- Handle request for new data from another player
function Wishlist.Comm:WANT(theirPlayers, sender)
    local update = {}
    local ourPlayers = Wishlist:GetPlayersData()

    for playerName, _ in pairs(theirPlayers) do
        update[playerName] = ourPlayers[playerName]
    end

    self:SendUpdate(update, sender)
end


-- Receive newer data to replace our own
function Wishlist.Comm:UPDATE(theirPlayers)
    local ourPlayers = Wishlist:GetPlayersData()

    for playerName, theirPlayer in pairs(theirPlayers) do
        local ourPlayer = ourPlayers[playerName]

        if (ourPlayer.requestedVersion and ourPlayer.requestedVersion <= theirPlayer.version) or
            (ourPlayers.version < theirPlayer.version) then
            Wishlist:UpdatePlayerData(playerName, theirPlayer)
        end
    end
    Wishlist:UpdateUI()
end


function Wishlist.Comm:SendHave(players, receiver)
    if receiver then
        self:SendCommMessageWhisper("HAVE", players, receiver)
    else
        self:SendCommMessageGuild("HAVE", players)
    end
end


function Wishlist.Comm:SendWant(players, receiver)
    self:SendCommMessageWhisper("WANT", players, receiver)
end


function Wishlist.Comm:SendUpdate(data, receiver)
    if receiver then
        self:SendCommMessageWhisper("UPDATE", data, receiver)
    else
        self:SendCommMessageGuild("UPDATE", data)
    end
end
