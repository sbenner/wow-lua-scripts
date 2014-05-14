local frame = CreateFrame("Frame")
local counted=0;


local function getOreCountInBags()
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



frame:SetScript("OnEvent", function(self, event, ...)
      
      local inbags=getOreCountInBags();
      local oreName,link,_ = GetItemInfo("72092")  
      if(counted ~= inbags) then 
         counted = inbags;
         print("Total "..oreName.." pcs gathered: "..inbags)
         UIErrorsFrame:AddMessage("Total "..oreName.." pcs gathered: "..inbags, 1.0, 0.0, 0.0, 53, 2);
      end
      
end) 




frame:RegisterEvent("BAG_UPDATE")

