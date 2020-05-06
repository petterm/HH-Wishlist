local addonName, Wishlist = ...
Wishlist = LibStub("AceAddon-3.0"):NewAddon(
    Wishlist, addonName,
    "AceConsole-3.0",
    "AceEvent-3.0",
    "AceComm-3.0",
    "AceSerializer-3.0"
)
_G.HHWishlist = Wishlist
Wishlist.version = GetAddOnMetadata(addonName, "Version")


local defaults = {
    profile = {
        debugPrint = false,
    },
    realm = {},
}


local optionsTable = {
    type='group',
    name = "Held Hostile Wishlist",
    desc = "Personal loot wishlist to communicate gear planning and coordinate distribution.",
    args = {
        options = {
            type='group',
            name = "Options",
            order = 1,
            args = {
                show = {
                    type = "execute",
                    name = "Show main UI",
                    func = function() Wishlist:Show() end,
                    order = 1,
                    width = "full",
                },
            },
        },
        debug = {
            type='group',
            name = "Debug",
            order = 2,
            args = {
                debugPrint = {
                    type = "toggle",
                    name = "Enable debug messages",
                    desc = "...",
                    get = function() return Wishlist.db.profile.debugPrint end,
                    set = function(_, v) Wishlist.db.profile.debugPrint = v end,
                    order = 1,
                    width = "full",
                },
            },
        },
    }
}


local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfig:RegisterOptionsTable(addonName, optionsTable, { "hhwl" })
local blizzOptionsFrame = AceConfigDialog:AddToBlizOptions(addonName, "HH Wishlist")


--[[========================================================
                        SETUP
========================================================]]--


function Wishlist:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HHWishlistDB", defaults)
    self.Comm.Initialize()
end


function Wishlist:DPrint(...)
    if self.db.profile.debugPrint then
        self:Print(...)
    end
end

function Wishlist:Show()
    self:DPrint("TODO: Show UI")
end
