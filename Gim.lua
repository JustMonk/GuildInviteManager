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

function Gim_OnLoad(self, event, ...)
    self:RegisterEvent("ADDON_LOADED")
end

function Gim_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "Gim" then
        self:UnregisterEvent("ADDON_LOADED")
        Gim:SetSize(100, 50)
        Gim:SetPoint("TOP", "Minimap", "BOTTOM", 5, -5)
        Gim:SetScript("OnUpdate", UpdateCoordinates)
        local coordsFont = Gim:CreateFontString("GimFontString", "ARTWORK", "GameFontNormal")
        coordsFont:SetPoint("CENTER", "Gim", "CENTER", 0, 0)
        coordsFont:Show()
        Gim:Show()

        -- local b = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
        -- b:SetSize(80, 22) -- width, height
        -- b:SetText("Button!")
        -- b:SetPoint("TOP", "Minimap", "BOTTOM", 15, -15)
        -- b:SetScript("OnClick", GimSettings_toggle)
    end
end

-- ================== CURRENT SETTINGS =======================
CurrentWhoResults = 0;

function Addon_OnLoad(self, event, ...)
   self:SetScript("OnEvent", Addon_OnEvent);

   self:RegisterEvent("ADDON_LOADED")
   self:RegisterEvent("WHO_LIST_UPDATE");
   
   self:RegisterForDrag("LeftButton");
end

function Addon_OnEvent(self, event, ...)
   if event == "ADDON_LOADED" and ... == "FrameTestFrame" then
      self:UnregisterEvent("ADDON_LOADED");
      print('Gim: AddOn loaded')
   elseif event == "WHO_LIST_UPDATE" then
      print("Gim: WHO_LIST_UPDATE EVENT FIRED");
      numResults, totalCount = GetNumWhoResults();
      CurrentWhoResults = numResults;
   end;
end;

function drawWhoTable()
end;

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
end;