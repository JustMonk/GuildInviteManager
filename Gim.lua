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

    self:RegisterForDrag("LeftButton");

    print('Gim: AddOn loaded');
    -- createPlayerTable();
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
    elseif event == "WHO_LIST_UPDATE" then
        numResults, totalCount = GetNumWhoResults();
        print("Gim: WHO_LIST_UPDATE EVENT FIRED. numResults: ", numResults, ", totalCount: ", totalCount);
        CurrentWhoResults = numResults;
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
end

function updateWho()
    print('updateWho init');
    SendWho("80-80");
end

-- INIT FUNCTIONs
function createPlayerRow(name, parent, playername)
    print(">>> CREATE PLAYER ROW INIT <<<")

    local f = CreateFrame("Frame", name, parent);
    f:SetSize(350, 25);
    f:SetPoint("TOP", 0, 0);
    f:SetPoint("LEFT", 0, 0);

    print('frame created');

    f.invButton = CreateFrame("Button", "$parentButton", f, "UIPanelButtonTemplate");
    f.invButton:SetText("Invite");
    f.invButton:SetSize(45, 20);
    f.invButton:SetPoint("CENTER")
    f.invButton:SetPoint("RIGHT", -10, 0);
    -- b:SetFontObject("GameFontNormalSmall")
    print('button created');

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
    print('fontString created');

    f.texture = f:CreateTexture();
    f.texture:SetAllPoints(f);
    f.texture:SetTexture(0.5, 0.5, 0.5, 0.3);
    print('texture created');

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
        print(row);

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
    createPlayerRow('test2', ScrollContainer)
    -- HideUIPanel(ScrollContainer);
end

function old_scroll_load_function()
    print('>> ScrollFrame_OnLOad init', ' ', event);
    createPlayerRow('test2', ScrollContainer)
end
