local addonName, ns = ...

local Link = ns.Link

-- Retail hands addons "secret" values: a real value the client will not let
-- tainted code compare, match, concatenate or use as a table key. A unit token
-- and a player name from a menu can both arrive that way, and everything below
-- does all four to them.
local function usable(value)
  if value == nil then return false end
  if type(canaccessvalue) ~= "function" then return true end
  local ok, allowed = pcall(canaccessvalue, value)
  return ok and allowed == true
end

-- An addon cannot open a browser. The Lua sandbox has no io, no os.execute and no
-- way to launch anything, by design - which is why every addon that offers a link
-- offers it the same way: a box with the text already selected, for one Ctrl+C.
local POPUP = "MYTHICPLUSLOGLINK_COPY"
StaticPopupDialogs[POPUP] = {
  text = "%s\n\nCtrl+C to copy, Escape to close.",
  button1 = CLOSE or "Close",
  hasEditBox = true,
  editBoxWidth = 350,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  OnShow = function(self, data)
    local box = self.editBox or self.EditBox
    if not box then return end
    box:SetText(data.url)
    box:HighlightText()
    box:SetFocus()
    -- Escape closes the dialog rather than only unfocusing the box, and Enter
    -- does the same: the box exists to be copied from, never typed into.
    box:SetScript("OnEscapePressed", function() self:Hide() end)
    box:SetScript("OnEnterPressed", function() self:Hide() end)
    -- A reader who starts typing would otherwise silently replace the link and
    -- copy their own keystrokes.
    box:SetScript("OnTextChanged", function(edit)
      if edit:GetText() ~= data.url then
        edit:SetText(data.url)
        edit:HighlightText()
      end
    end)
  end,
}

---@param name string
---@param realm string|nil
local function show(name, realm)
  if not usable(name) then return end
  if not usable(realm) or realm == "" then realm = GetNormalizedRealmName() end

  local url, problem = Link.For(name, realm, GetCurrentRegion())
  if not url then
    print(string.format("|cff33ff99%s|r: %s", addonName, problem or "no link"))
    return
  end
  StaticPopup_Show(POPUP, url, nil, { url = url })
end
ns.Show = show

-- The name and realm a menu is about. A unit menu carries a token; a chat or
-- friends-list menu carries the name and server as text, and the name it carries
-- may already have the realm attached.
local function targetOf(contextData)
  if not contextData then return nil end

  local unit = contextData.unit
  if usable(unit) and UnitIsPlayer(unit) then
    local name, realm = UnitName(unit)
    if usable(name) then return name, usable(realm) and realm ~= "" and realm or nil end
  end

  local name = contextData.name
  if not usable(name) then return nil end
  local short, realm = string.match(name, "^(.-)%-(.+)$")
  if short then return short, realm end
  return name, usable(contextData.server) and contextData.server or nil
end

-- Every unit menu that can be about another player. Blizzard tags them
-- MENU_UNIT_<TYPE>, one tag per context rather than one for all of them, so the
-- list is written out - a missing tag costs that one menu, never an error.
local MENUS = {
  "MENU_UNIT_PLAYER", "MENU_UNIT_PARTY", "MENU_UNIT_RAID", "MENU_UNIT_RAID_PLAYER",
  "MENU_UNIT_FRIEND", "MENU_UNIT_TARGET", "MENU_UNIT_FOCUS", "MENU_UNIT_ARENAENEMY",
  "MENU_UNIT_ENEMY_PLAYER", "MENU_UNIT_GUILD", "MENU_UNIT_CHAT_ROSTER",
  "MENU_UNIT_COMMUNITIES_GUILD_MEMBER", "MENU_UNIT_COMMUNITIES_WOW_MEMBER",
  "MENU_UNIT_SELF", "MENU_UNIT_BN_FRIEND",
}

local function install()
  if type(Menu) ~= "table" or type(Menu.ModifyMenu) ~= "function" then return end
  for _, tag in ipairs(MENUS) do
    Menu.ModifyMenu(tag, function(_, rootDescription, contextData)
      local name, realm = targetOf(contextData)
      if not name then return end
      rootDescription:CreateDivider()
      rootDescription:CreateTitle("Warcraft Logs")
      rootDescription:CreateButton(Link.ZONE_NAME, function() show(name, realm) end)
    end)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
  install()

  SLASH_MYTHICPLUSLOGLINK1 = "/mpluslog"
  SLASH_MYTHICPLUSLOGLINK2 = "/wcl"
  SlashCmdList["MYTHICPLUSLOGLINK"] = function(input)
    local text = string.match(input or "", "^%s*(.-)%s*$")
    if text == "" then
      -- No argument means the current target, which is the common case: you are
      -- looking at somebody and want their page.
      if UnitExists("target") and UnitIsPlayer("target") then
        local name, realm = UnitName("target")
        return show(name, realm)
      end
      print(string.format("|cff33ff99%s|r: /wcl <name>-<realm>, or target a player first.", addonName))
      return
    end
    -- The first hyphen, not the last: a realm slug routinely contains one and a
    -- character name never can.
    local separator = string.find(text, "-", 1, true)
    if separator then
      show(string.sub(text, 1, separator - 1), string.sub(text, separator + 1))
    else
      show(text, nil)
    end
  end
end)
