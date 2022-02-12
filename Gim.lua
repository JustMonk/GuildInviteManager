-- SAVED SCOPE --
--
-- SAVED SCOPE END --
-- GLOBAL SCOPE
CurrentWhoResults = 0;
TotalWhoResults = 0;
InTableResults = 0;
QueryDelay = 12;
PlayerRows = {};
-- GLOBAL SCOPE END

-- open frame with slash command
SLASH_GIM1 = '/gim';
SlashCmdList["GIM"] = ToggleSetting;

function Addon_OnLoad(self, event, ...)
    self:SetScript("OnEvent", Addon_OnEvent);

    self:RegisterEvent("ADDON_LOADED")

    -- в этот момент доступен UI собственных фреймов
    self:RegisterEvent("PLAYER_LOGIN");

    self:RegisterEvent("WHO_LIST_UPDATE");
    self:RegisterEvent("VARIABLES_LOADED");

    self:RegisterForDrag("LeftButton");

    print('|cffbf6bff Gim |cff37f32b1.0|cffffffff (Guild invite manager) by|cffff7c0a JustMonk|cffffffff: AddOn loaded\n |cffbf6bffOpen settings|cffffffff: /gim');
end

function Addon_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        self:UnregisterEvent("ADDON_LOADED");
        -- elseif event == "ADDON_LOADED" and ... == "FrameTestFrame" then
        -- self:UnregisterEvent("ADDON_LOADED");
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN");

        createPlayerTable();
        createStatistics();
        updateSettingsBlock();
    elseif event == "WHO_LIST_UPDATE" then
        numResults, totalCount = GetNumWhoResults();
        --print("Gim: WHO_LIST_UPDATE EVENT FIRED. numResults: ", numResults, ", totalCount: ", totalCount);
        CurrentWhoResults = numResults;
        TotalWhoResults = totalCount;
        -- update ui state --
        updateTableCounters();
        updateDatagrid();
    elseif event == "VARIABLES_LOADED" then
        -- все сохраненные переменные загружены

        if AcceptedCount == nil then
            AcceptedCount = 0;
        end

        if PlayerBlacklist == nil then
            PlayerBlacklist = {};
        end

        if UseWhisperFlag == nil then
            UseWhisperFlag = false;
        end

        if WhispMessage == nil then
            WhispMessage = "";
        end

        -- test saved variables
        -- drawStatistics();
    end
end

function ToggleSetting()
    if (FrameTestFrame:IsVisible()) then
        HideUIPanel(FrameTestFrame);
    else
        ShowUIPanel(FrameTestFrame)
    end
end

function printSlashCommand()
    -- this execute chat slash command from user character
    DEFAULT_CHAT_FRAME.editBox:SetText("/script print(\"test\")");
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);
end

function ginvite(name)
    local command = "/ginvite " .. name;
    local whisp = "/w " .. name .. " " .. WhispMessage;

    DEFAULT_CHAT_FRAME.editBox:SetText(command);
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);

    if UseWhisperFlag then
        DEFAULT_CHAT_FRAME.editBox:SetText(whisp);
        ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);
    end

    PlayerBlacklist[name] = 1;
end

function updateWho()
    --print('updateWho init');
    SendWho("80-80");
end

-- utils
function filterList(list, predicate)
    -- Create the list y containing the items from the list x that satisfy the predicate p. Respect the original ordering. Don't modify x in-place.
    local filtered = {}
    for _, v in ipairs(list) do
        if predicate(v) then
            filtered[#filtered + 1] = v
        end
    end
end

function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

local waitTable = {};
local waitFrame = nil;
function gim__wait(delay, func, ...)
    if (type(delay) ~= "number" or type(func) ~= "function") then
        return false;
    end
    if (waitFrame == nil) then
        waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate", function(self, elapse)
            local count = #waitTable;
            local i = 1;
            while (i <= count) do
                local waitRecord = tremove(waitTable, i);
                local d = tremove(waitRecord, 1);
                local f = tremove(waitRecord, 1);
                local p = tremove(waitRecord, 1);
                if (d > elapse) then
                    tinsert(waitTable, i, {d - elapse, f, p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(waitTable, {delay, func, {...}});
    return true;
end
-- utils end

-- stats interface
function createStatistics()
    local f = StatsBlock;
    f.blacklist = f:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall");
    f.blacklist:SetText("Blacklist: " .. 0)
    f.blacklist:SetPoint("TOP", f, 0, -30)
    f.blacklist:SetPoint("LEFT", f, 5, 0)

    f.invitesCount = f:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall");
    f.invitesCount:SetText("Invited: " .. 0)
    f.invitesCount:SetPoint("TOP", f, 0, -45)
    f.invitesCount:SetPoint("LEFT", f, 5, 0)

    f.acceptedCount = f:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall");
    f.acceptedCount:SetText("Accepted: " .. 'N/D')
    f.acceptedCount:SetPoint("TOP", f, 0, -60)
    f.acceptedCount:SetPoint("LEFT", f, 5, 0)

    drawStatistics();
end

function drawStatistics()
    local f = StatsBlock;

    local keys = get_keys(PlayerBlacklist);
    local blacklistCount = table.getn(keys);

    -- StatsBlockUsername:SetText('sdakjdsakdasd') //можно еще по имени обращаться
    f.blacklist:SetText("Blacklist: " .. blacklistCount)
    f.invitesCount:SetText("Invited: " .. blacklistCount)
end

-- INIT FUNCTIONs
function createPlayerRow(name, parent, playername)
    local f = CreateFrame("Frame", name, parent);
    f:SetSize(350, 25);
    f:SetPoint("TOP", 0, 0);
    f:SetPoint("LEFT", 0, 0);

    f.invButton = CreateFrame("Button", "$parentButton", f, "UIPanelButtonTemplate");
    f.invButton:SetText("Invite");
    f.invButton:SetSize(45, 20);
    f.invButton:SetPoint("CENTER")
    f.invButton:SetPoint("RIGHT", -10, 0);
    -- b:SetFontObject("GameFontNormalSmall")

    f.username = f:CreateFontString("$parentUsername", "OVERLAY", "GameFontNormalSmall");
    f.username:SetText(playername)
    f.username:SetPoint("CENTER", f)
    f.username:SetPoint("LEFT", f, 5, 0)

    f.level = f:CreateFontString("$parentLevel", "OVERLAY", "GameFontNormalSmall");
    f.level:SetText("80")
    f.level:SetPoint("CENTER", f)
    f.level:SetPoint("LEFT", f, 90, 0)

    f.class = f:CreateFontString("$parentClass", "OVERLAY", "GameFontNormalSmall");
    f.class:SetText("Рыцарь смерти")
    f.class:SetPoint("CENTER", f)
    f.class:SetPoint("LEFT", f, 110, 0)

    f.guild = f:CreateFontString("$parentClass", "OVERLAY", "GameFontNormalSmall");
    f.guild:SetText("Без гильдии ")
    f.guild:SetPoint("CENTER", f)
    f.guild:SetPoint("LEFT", f, 200, 0)

    f.texture = f:CreateTexture();
    f.texture:SetAllPoints(f);
    f.texture:SetTexture(0.5, 0.5, 0.5, 0.3);

    return f;
end

-- вызывается один раз для создания фреймов в таблице
function createPlayerTable()
    ScrollContainer:SetHeight(1250)

    for i = 1, 50 do
        -- +25 y offset
        local row = createPlayerRow('row' .. i, ScrollContainer, 'Restmoon' .. i, i);

        row:SetPoint("TOP", 0, (i - 1) * -25);
        PlayerRows[i] = row;
        row:Hide();
    end

end

function updateDatagrid()
    local filteredList = {};
    local dummy = 0;
    for i = 1, CurrentWhoResults do
        local name, guild, level, race, class, zone, classFileName, sex = GetWhoInfo(i);
        if PlayerBlacklist[name] or guild ~= "" then
            -- print('player ' .. name .. ' in blacklist');
            dummy = 0;
        else
            local rowIndex = table.getn(filteredList) + 1;
            filteredList[rowIndex] = name;
            local currentRow = PlayerRows[rowIndex];
            currentRow:Show();

            currentRow.username:SetText(name);
            currentRow.level:SetText(level);
            currentRow.class:SetText(class);

            -- currentRow.guild:SetText(string.sub(guild, 1, 17));
            currentRow.guild:SetText("<Without guild>");

            currentRow.invButton:SetScript("OnClick", function()
                ginvite(name)
                -- update ui state --
                updateDatagrid();
                drawStatistics();

                disableDatagridButtons();
                updateBlacklist();
            end);
        end
    end

    for i = table.getn(filteredList) + 1, 50 do
        PlayerRows[i]:Hide();
    end

    InTableResults = table.getn(filteredList);
    ScrollContainer:SetHeight(InTableResults * 25);

    updateTableCounters()
end

function blacklistToggle()
    updateBlacklist();

    if (BlacklistFrame:IsVisible()) then
        HideUIPanel(BlacklistFrame);
    else
        ShowUIPanel(BlacklistFrame)
    end
end

function updateBlacklist()
    blacklistString = '';
    local keys = get_keys(PlayerBlacklist);
    for i = 1, table.getn(keys) do
        blacklistString = blacklistString .. keys[i] .. ', ';
    end
    TestEditBox:SetText(blacklistString)
end

function clearBlacklist()
    PlayerBlacklist = {};

    updateBlacklist();
end

-- updates count row under players table
function updateTableCounters()
    TotalCount:SetText(TotalWhoResults);
    NumResultsCount:SetText(CurrentWhoResults);
    InTableCount:SetText(InTableResults);
end

function disableDatagridButtons()
    for i = 1, 50 do
        PlayerRows[i].invButton:Disable();
    end

    gim__wait(QueryDelay, enableDatagridButton);
end

function enableDatagridButton()
    for i = 1, 50 do
        PlayerRows[i].invButton:Enable();
    end
end

function whispSettingsToggle()
    if (WhispSettingsFrame:IsVisible()) then
        HideUIPanel(WhispSettingsFrame);
    else
        ShowUIPanel(WhispSettingsFrame)
    end
end

function saveWhispMessage()
    WhispMessage = WhispEditBox:GetText()
    updateSettingsBlock();
    whispSettingsToggle();
end

function updateSettingsBlock()
    Settings_QueryDelay:SetText(QueryDelay);

    Settings_UseWhisperFlag:SetText(tostring(UseWhisperFlag));
    if (UseWhisperFlag) then
        EnableWhispButton:SetText("|cffff0000 Disable /w")
    else
        EnableWhispButton:SetText("|cff56ff00 Enable /w")
    end

    Settings_WhispMessage:SetText(string.sub(WhispMessage, 1, 14) .. "...");
end

function enableWhisper()
    if (UseWhisperFlag) then
        UseWhisperFlag = false;
    else
        UseWhisperFlag = true;
    end

    updateSettingsBlock();
end
