local zone = nil
local TimeSinceLastUpdate = 0
local function UpdateCoordinates(self, elapsed)
    if zone ~= GetRealZoneText() then
        zone = GetRealZoneText()
        SetMapToCurrentZone()
    end
    TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
    if TimeSinceLastUpdate > .5 then
        TimeSinceLastUpdate = 0
        local posX, posY = GetPlayerMapPosition("player");
        local x = math.floor(posX * 10000) / 100
        local y = math.floor(posY * 10000) / 100
        GimFontString:SetText("|c98FB98ff(" .. x .. ", " .. y .. ")")
    end
end

-- ================== CURRENT SETTINGS =======================

-- GLOBAL SCOPE
CurrentWhoResults = 0;
PlayerRows = {};
-- GLOBAL SCOPE END

function Addon_OnLoad(self, event, ...)
    self:SetScript("OnEvent", Addon_OnEvent);

    self:RegisterEvent("ADDON_LOADED")

    -- в этот момент доступен UI собственных фреймов
    self:RegisterEvent("PLAYER_LOGIN");

    self:RegisterEvent("WHO_LIST_UPDATE");
    self:RegisterEvent("VARIABLES_LOADED");

    self:RegisterForDrag("LeftButton");

    print('Gim: AddOn loaded');
end

function Addon_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        print("------LOADED------");
        self:UnregisterEvent("ADDON_LOADED");
        -- elseif event == "ADDON_LOADED" and ... == "FrameTestFrame" then
        -- self:UnregisterEvent("ADDON_LOADED");
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN");
        print('PLAYER_LOGIN EVENT');
        createPlayerTable();
        createStatistics();
    elseif event == "WHO_LIST_UPDATE" then
        numResults, totalCount = GetNumWhoResults();
        print("Gim: WHO_LIST_UPDATE EVENT FIRED. numResults: ", numResults, ", totalCount: ", totalCount);
        CurrentWhoResults = numResults;
    elseif event == "VARIABLES_LOADED" then
        -- все сохраненные переменные загружены
        print('variables has been loaded');
        if HaveWeMetCount == nil then
            HaveWeMetCount = 0;
        else
            HaveWeMetCount = HaveWeMetCount + 1;
        end

        if PlayerBlacklist == nil then
            PlayerBlacklist = {};
        end
        print('HaveWeMetCount = ', HaveWeMetCount);

        -- test saved variables
        -- drawStatistics();
    end
end

function drawWhoTable()
end

function ToggleSetting()
    print('ToggleSetting init', FrameTestFrame:IsVisible());
    if (FrameTestFrame:IsVisible()) then
        HideUIPanel(FrameTestFrame);
    else
        ShowUIPanel(FrameTestFrame)
    end
end

function scrollCreateFromVideo()
    local myScrollFrame = CreateFrame("ScrollFrame", nil, ScrollWrapper, "UIPanelScrollFrameTemplate");
    myScrollFrame:SetPoint("TOPLEFT", ScrollWrapper, "TOPLEFT", 4, -8);
    myScrollFrame:SetPoint("BOTTOMRIGHT", ScrollWrapper, "BOTTOMRIGHT", -3, 4);

    local myChildFrame = CreateFrame("Frame", nil, myScrollFrame);
    myChildFrame:SetSize(100, 600);
    myChildFrame:SetPoint("TOP", myScrollFrame, "TOP", 15, -15);
    myChildFrame:SetBackdropColor(0.1, 0.7, 0.1, 0.6);

    myScrollFrame:SetScrollChild(myChildFrame);

    local b = CreateFrame("Button", "MyButton", myChildFrame, "UIPanelButtonTemplate")
    b:SetSize(80, 22) -- width, height
    b:SetText("Button!")
    b:SetPoint("TOP", myChildFrame, "TOP", 15, -15)

    local b2 = CreateFrame("Button", "MyButton2", myChildFrame, "UIPanelButtonTemplate")
    b:SetSize(80, 22) -- width, height
    b:SetText("Button!")
    b:SetPoint("BOTTOM", 15, 20)
end

function printSlashCommand()
    -- this execute chat slash command from user character
    DEFAULT_CHAT_FRAME.editBox:SetText("/script print(\"test\")");
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);
end

function ginvite(name)
    print('ginvite ', name);
    local command = "/ginvite " .. name;
    DEFAULT_CHAT_FRAME.editBox:SetText(command);
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);

    PlayerBlacklist[name] = 1;
end

function updateWho()
    print('updateWho init');
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
-- utils end

-- stats interface
function createStatistics()
    local f = StatsBlock;
    f.blacklist = f:CreateFontString("$parentUsername", "OVERLAY", "GameFontWhiteSmall");
    f.blacklist:SetText("Blacklist: " .. 0)
    f.blacklist:SetPoint("TOP", f, 0, -30)
    f.blacklist:SetPoint("LEFT", f, 5, 0)

    f.invitesCount = f:CreateFontString("$parentHavemeet", "OVERLAY", "GameFontWhiteSmall");
    f.invitesCount:SetText("Invited: " .. 0)
    f.invitesCount:SetPoint("TOP", f, 0, -45)
    f.invitesCount:SetPoint("LEFT", f, 5, 0)

    print('statistics was created');
    drawStatistics();
end

function drawStatistics()
    local f = StatsBlock;

    local keys = get_keys(PlayerBlacklist);
    local blacklistCount = table.getn(keys);

    --StatsBlockUsername:SetText('sdakjdsakdasd') //можно еще по имени обращаться
    f.blacklist:SetText("Blacklist: " .. blacklistCount)
    f.invitesCount:SetText("Invited: " .. blacklistCount)

    print('drawStatistics ended');
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

    -- рабочий сниппет для FontString
    -- local AddonFS = f:CreateFontString("$parentUsername", "OVERLAY", "GameFontNormalSmall")
    -- AddonFS:SetText("Testtext")
    -- AddonFS:SetPoint("CENTER",f,"LEFT",0,0) --обязательно должен быть родитель и позиция
    -- AddonFS:SetPoint("CENTER", f)
    -- AddonFS:SetPoint("LEFT", f, 0, 0)

    f.texture = f:CreateTexture();
    f.texture:SetAllPoints(f);
    f.texture:SetTexture(0.5, 0.5, 0.5, 0.3);

    return f;

    -- f.mytext = f.CreateFontString();

    -- f.mytext:SetSize(160, 40);
    -- f.mytext:SetPoint("CENTER");
    -- f.mytext:SetPoint("LEFT", "$parent", 0, 0);
    -- f.mytext:SetText('asldaskjfka');
    -- f.mytext:Show();

    -- print('text isShown? ', f.mytext:isShow())
    -- print('text isVisible? ', f.mytext:isVisible())

    -- mytext:SetPoint("CENTER")
    -- mytext:SetPoint("LEFT", 0, 0)
    -- mytext:SetSize(200, 20)
    -- mytext:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    -- mytext:SetText("Avoidance: ")

    -- f.count = f:CreateFontString("somename", "ARTWORK", "GameFontNormalSmall");
    -- f.count:SetPoint("CENTER");
    -- f.count:SetPoint("LEFT", 0, 0);
    -- f.count:SetJustifyH("LEFT");
    -- f.count:SetJustifyV("TOP");
    -- f.count:SetText('sorrowfulpray')
    -- f.count:Show();
    -- f.count:Hide();

    -- f:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
    -- f:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
    -- f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");

    -- f.texture = f:CreateTexture();
    -- f.texture:SetAllPoints(f);
    -- f.texture:SetTexture(0.5, 0.5, 0.5, 0.3);
    -- f:CreateFontString("somestr", "OVERLAY", "GameFontNormalSmall")

end

-- вызывается один раз для создания фреймов в таблице
function createPlayerTable()
    print('CreatePlayerTable')
    ScrollContainer:SetHeight(1250)

    for i = 1, 50 do
        -- +25 y offset
        local row = createPlayerRow('row' .. i, ScrollContainer, 'Restmoon' .. i, i);

        row:SetPoint("TOP", 0, (i - 1) * -25);
        PlayerRows[i] = row;
    end

end

function updateDatagrid()
    print('CurrentWhoResults: ', CurrentWhoResults);
    ScrollContainer:SetHeight(CurrentWhoResults * 25);

    for i = 1, CurrentWhoResults do
        local name, guild, level, race, class, zone, classFileName, sex = GetWhoInfo(i);
        local currentRow = PlayerRows[i];

        currentRow.username:SetText(name);
        currentRow.level:SetText(level);
        currentRow.class:SetText(class);
        currentRow.guild:SetText(string.sub(guild, 1, 17));

        currentRow.invButton:SetScript("OnClick", function()
            ginvite(name)
        end);
    end

    for i = numResults + 1, 50 do
        PlayerRows[i]:Hide();
    end

    print('datagrid update ended');
    -- test

end

function testFrame()
    print('test func init');

    local keys = get_keys(PlayerBlacklist);

    for i = 1, table.getn(keys) do
        print(keys[i]);
    end

    print('PlayerBlacklist: ', keys);
    -- createPlayerRow('test2', ScrollContainer)
    -- HideUIPanel(ScrollContainer);
end

function blacklistToggle()
    blacklistString = '';
    local keys = get_keys(PlayerBlacklist);
    for i = 1, table.getn(keys) do
        blacklistString = blacklistString .. ', ' .. keys[i]
    end
    TestEditBox:SetText(blacklistString)

    if (BlacklistFrame:IsVisible()) then
        HideUIPanel(BlacklistFrame);
    else
        ShowUIPanel(BlacklistFrame)
    end
end

function old_scroll_load_function()
    print('>> ScrollFrame_OnLOad init', ' ', event);
    createPlayerRow('test2', ScrollContainer)
end
