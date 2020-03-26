printDebugStmt={
}


local msgCounter=0
local displayObjects={}

function printDebugStmt.print(msg)
   --disable the debug statement functionality if the game is running on a device
   -- if(system.getInfo("environment")~="device")then
         print(msg)
         displayObjects[#displayObjects+1]=display.newText(msg,200, 100+msgCounter*20)
         msgCounter=msgCounter+1
         if(msgCounter>60)then
            displayObjects[1]:removeSelf()--remove the first text if limit exceeded
            displayObjects[1]=nil
            table.remove(displayObjects,1)
            --shift all the remaining text objects upwards
            for i=1, #displayObjects do
               displayObjects[i].y=displayObjects[i].y-20
            end
            msgCounter=msgCounter-1--decrement the counter
         end
   -- end
end

return printDebugStmt