local _, Wishlist = ...

Wishlist.Comm = {}

local PREFIX = "HHWISHLIST"
local colorYellow, colorRed, colorBlue, colorPurple = Wishlist.Util.colorYellow,
    Wishlist.Util.colorRed, Wishlist.Util.colorBlue, Wishlist.Util.colorPurple


local function typeString(messages)
    local types
    for i, m in ipairs(messages) do
        if i == 1 then
            types = m.type
        else
            types = types..", "..m.type
        end
    end
    return types
end


function Wishlist:OnCommReceived(prefix, messageRaw, _, sender)
    if prefix ~= PREFIX then return end
    if sender == UnitName("player") then return end

    local success, messageList = Wishlist:Deserialize(messageRaw)

    if success then
        for _, message in ipairs(messageList) do
            if type(Wishlist.Comm[message.type]) == "function" then
                Wishlist:DPrint(
                    colorPurple("Received").." message "..colorYellow(message.type)..
                    " from "..colorYellow(sender)
                )
                Wishlist.Comm[message.type](Wishlist.Comm, message.data, sender)
            else
                Wishlist:DPrint(
                    colorPurple("Received").." unknown message "..colorRed(message.type)..
                    " from "..colorYellow(sender)
                )
            end
        end
    else
        Wishlist:DPrint(colorRed("Error deserializing message from "..sender))
    end
end


function Wishlist.Comm:SendCommMessageGuild(messages)
    Wishlist:DPrint(colorBlue("Send").." GUILD message", colorYellow(typeString(messages)))

    local messageRaw = Wishlist:Serialize(messages)
    -- Wishlist:DPrint(messageRaw)
    Wishlist:SendCommMessage(PREFIX, messageRaw, "GUILD")
end


function Wishlist.Comm:SendCommMessageWhisper(messages, player)
    Wishlist:DPrint(colorBlue("Send").." WHISPER message", colorYellow(typeString(messages)), colorYellow(player))

    local messageRaw = Wishlist:Serialize(messages)
    -- Wishlist:DPrint(message)
    Wishlist:SendCommMessage(PREFIX, messageRaw, "WHISPER", player)
end


function Wishlist.Comm:Initialize()
    Wishlist:RegisterComm(PREFIX)
end