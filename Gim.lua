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
CurrentWhoResults = 0;

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
        print("Gim: WHO_LIST_UPDATE EVENT FIRED");
        numResults, totalCount = GetNumWhoResults();
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

function updateWho()
    print('updateWho init');
    SendWho("80-80");
end

-- INIT FUNCTIONs
function createPlayerRow(name, parent)
    print(">>> CREATE PLAYER ROW INIT <<<")

    local f = CreateFrame("Frame", name, parent);
    f:SetSize(350, 25);
    f:SetPoint("TOP", 0, 0);
    f:SetPoint("LEFT", 0, 0);

    print('frame created');

    local b = CreateFrame("Button", "$parentButton", f, "UIPanelButtonTemplate");
    b:SetText("Invite");
    b:SetSize(45, 20);
    b:SetPoint("CENTER")
    b:SetPoint("RIGHT", -10, 0);
    -- b:SetFontObject("GameFontNormalSmall")
    print('button created');

    -- рабочий сниппет для FontString
    local AddonFS = f:CreateFontString("FontString", "OVERLAY", "GameFontNormalSmall")
    AddonFS:SetText("Testtext")
    -- AddonFS:SetPoint("CENTER",f,"LEFT",0,0) --обязательно должен быть родитель и позиция
    AddonFS:SetPoint("CENTER", f)
    AddonFS:SetPoint("LEFT", f, 0, 0)
    print('fontString created');

    f.texture = f:CreateTexture();
    f.texture:SetAllPoints(f);
    f.texture:SetTexture(0.5, 0.5, 0.5, 0.3);
    print('texture created');

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

function createPlayerTable()
    print('CreatePlayerTable')
    createPlayerRow('test2', ScrollContainer)

    for i = 1, 50 do
        local f1 = CreateFrame("Frame", nil, FrameTestFrame)
        f1:SetWidth(1)
        f1:SetHeight(1)
        f1:SetAlpha(.90);
        f1:SetPoint("CENTER", 1, 1)

        f1.text = f1:CreateFontString(nil, "ARTWORK")
        f1.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")

        f1.text:SetPoint("CENTER")
        f1.text:SetPoint("LEFT", f1, "LEFT", 0 + i, 0)
        f1.text:SetText("SDJAKDJSKAJDKASKD")

        ShowUIPanel(f1)
    end

end

function testFrame()
    createPlayerRow('test2', ScrollContainer)
    -- HideUIPanel(ScrollContainer);
end

function old_scroll_load_function()
    print('>> ScrollFrame_OnLOad init', ' ', event);
    createPlayerRow('test2', ScrollContainer)
end
