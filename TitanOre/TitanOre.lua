-- **************************************************************************
-- * TitanOre.lua
-- *
-- * By: Siggi
-- **************************************************************************

-- ******************************** Constants *******************************
local _G = getfenv(0);
local TITAN_ORE_ID = "Ore";
local TITAN_BAG_THRESHOLD_TABLE = {
     Values = { 0.5, 0.75 },
     Colors = { GREEN_FONT_COLOR, NORMAL_FONT_COLOR, RED_FONT_COLOR },
}
local updateTable = {TITAN_ORE_ID, TITAN_PANEL_UPDATE_BUTTON} ;
-- ******************************** Variables *******************************
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local AceTimer = LibStub("AceTimer-3.0")
local BagTimer
local counted=0;
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelOreButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelOreButton_OnLoad(self)
	 counted =  getOreCountInBags(); 
	self.registry = {
		id = TITAN_ORE_ID,
		category = "Built-ins",
		version = TITAN_VERSION,
		menuText = "Ghost Iron Ore Counter Menu",
		buttonTextFunction = "TitanPanelOreButton_GetButtonText", 
		tooltipTitle = L["TITAN_ORE_TOOLTIP"],
		tooltipTextFunction = "TitanPanelOreButton_GetTooltipText", 
		icon = "Interface\\Icons\\inv_ore_ghostiron",
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true,
			ShowRegularText = false,
			ShowColoredText = true,
			DisplayOnRightSide = false,
		},

		savedVariables = {
	--		ShowOreCount = 1,
                        ShowFlotatingText = 1,
                        ShowDetailedInfo = 1,
			ShowIcon = 1,
			ShowLabelText = 1,
			ShowColoredText = 1,               
		}
	};     

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- **************************************************************************
-- NAME : TitanPanelOreButton_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- **************************************************************************
function TitanPanelOreButton_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") and (not self:IsEventRegistered("BAG_UPDATE")) then
		self:RegisterEvent("BAG_UPDATE");          
	end

	if event == "BAG_UPDATE" then
		-- Create only when the event is active
		self:SetScript("OnUpdate", TitanPanelOreButton_OnUpdate)
	end
end

function TitanPanelOreButton_OnUpdate(self)
	-- update the button
	TitanPanelPluginHandle_OnUpdate(updateTable)
	-- remove until the next bag event

local bagText = getOreCountInBags();
local oreName,link,_ = GetItemInfo("72092")    
--      end

        if (TitanGetVar(TITAN_ORE_ID, "ShowFloatingText") and counted ~= bagText ) then
	    counted = getOreCountInBags();
            print("Total "..oreName.." pcs gathered: "..bagText)
            UIErrorsFrame:AddMessage("Total "..oreName.." pcs gathered: "..bagText, 1.0, 0.0, 0.0, 53, 2);
        end



	self:SetScript("OnUpdate", nil)
end

-- **************************************************************************
-- NAME : TitanPanelOreButton_OnClick(button)
-- DESC : Opens all bags on a LeftClick
-- VARS : button = value of action
-- **************************************************************************
function TitanPanelOreButton_OnClick(self, button)
	if (button == "LeftButton") then
		ToggleAllBags();
	end
end

-- **************************************************************************
-- NAME : TitanPanelOreButton_GetButtonText(id)
-- DESC : Calculate bag space logic then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelOreButton_GetButtonText(id)
	local button, id = TitanUtils_GetButton(id, true);

	local bagText, bagRichText, color;
--	if (TitanGetVar(TITAN_ORE_ID, "ShowOreCount")) then
	bagText = getOreCountInBags();
--	end

	if ( TitanGetVar(TITAN_ORE_ID, "ShowColoredText") ) then     
		color = TitanUtils_GetThresholdColor(TITAN_BAG_THRESHOLD_TABLE, bagText);
		bagRichText = TitanUtils_GetColoredText(bagText, color);
	else
		bagRichText = TitanUtils_GetHighlightText(bagText);
	end

	return "Ores: ", bagRichText;
end



function TitanPanelOreButton_GetTooltipText(id)
        local button, id = TitanUtils_GetButton(id, true);

        local bagText, bagRichText, color;
              bagText = getOreCountInBags();

        if ( TitanGetVar(TITAN_ORE_ID, "ShowColoredText") ) then
                color = TitanUtils_GetThresholdColor(TITAN_BAG_THRESHOLD_TABLE, bagText);
                bagRichText = TitanUtils_GetColoredText(bagText, color);
        else
                bagRichText = TitanUtils_GetHighlightText(bagText);
        end

        return "Ores: "..bagRichText;
end

function getOreCountInBags()
   local inbags=0;
   for bag = 0, 4 do for slot = 1, GetContainerNumSlots(bag) 
      do local name,_ = GetContainerItemLink(bag,slot)
         if name and string.find(name,"Ghost Iron Ore")
         then 
            local icon,count,_ = GetContainerItemInfo(bag,slot)
            inbags=inbags+count;
         end 
      end 
      
   end
   return inbags;
end



-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareOreMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareOreMenu()
	local info
	-- level 2
	if _G["UIDROPDOWNMENU_MENU_LEVEL"] == 2 then
		if _G["UIDROPDOWNMENU_MENU_VALUE"] == "Options" then

			TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_OPTIONS"], _G["UIDROPDOWNMENU_MENU_LEVEL"])

			info = {};
                        info.text = "Show Floating Text"; 
                        info.func = TitanPanelOreButton_ShowFloatingText;
                        info.checked = TitanGetVar(TITAN_ORE_ID, "ShowFloatingText");
                        UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);

			info = {};
			info.text = L["TITAN_BAG_MENU_SHOW_DETAILED"];
			info.func = TitanPanelOreButton_ShowDetailedInfo;
			info.checked = TitanGetVar(TITAN_ORE_ID, "ShowDetailedInfo");
			UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
		end
		return
	end
	
	-- level 1
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_ORE_ID].menuText);

	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_OPTIONS"];
	info.value = "Options"
	info.hasArrow = 1;
	UIDropDownMenu_AddButton(info);

	TitanPanelRightClickMenu_AddSpacer();     
	TitanPanelRightClickMenu_AddToggleIcon(TITAN_ORE_ID);
	TitanPanelRightClickMenu_AddToggleLabelText(TITAN_ORE_ID);
	TitanPanelRightClickMenu_AddToggleColoredText(TITAN_ORE_ID);
	TitanPanelRightClickMenu_AddSpacer();     
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_ORE_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- NAME : TitanPanelOreButton_ShowUsedSlots()
-- DESC : Set option to show used slots
-- **************************************************************************


function TitanPanelOreButton_ShowFloatingText()
        TitanSetVar(TITAN_ORE_ID, "ShowFloatingText", 1);
        TitanPanelButton_UpdateButton(TITAN_ORE_ID);
end

function TitanPanelOreButton_ShowDetailedInfo()
	TitanSetVar(TITAN_ORE_ID, "ShowDetailedInfo", 1);
        TitanPanelButton_UpdateButton(TITAN_ORE_ID);
end
