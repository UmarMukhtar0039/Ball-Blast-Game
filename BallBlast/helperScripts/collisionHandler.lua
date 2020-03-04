collisionHandler={}

-- local debugStmt=require "scripts.helperScripts.printDebugStmt"
local width=display.contentWidth
local height=display.contentHeight
local myMath={
  atan2=math.atan2,
  abs=math.abs,
  deg=math.deg,
  rad=math.rad,
  cos=math.cos,
  sin=math.sin,
  random=math.random,
  pi=math.pi,
  floor=math.floor,
  pow=math.pow,
  min=math.min,
  max=math.max,
}

--generic collison handler that will detect objects' bounds as circle or box and call necessary collision checker automatically:
function collisionHandler.hasCollided( obj1, obj2 )
    if(obj1.contentBound.r~=nil and obj2.contentBound.xMin~=nil)then--circle-rect
      return collisionHandler.circleRectangleCollision(obj1,obj2)
    elseif(obj2.contentBound.r~=nil and obj1.contentBound.xMin~=nil)then--rect-circle
      return collisionHandler.circleRectangleCollision(obj2,obj1)
    elseif(obj2.contentBound.r~=nil and obj1.contentBound.r~=nil)then--circle-circle
      return collisionHandler.circleCircleCollision(obj1,obj2)  
    elseif(obj2.contentBound.xMin~=nil and obj1.contentBound.xMin~=nil)then--rect-rect
      return collisionHandler.rectangleRectangleCollision(obj1,obj2)
    end   
end

-------------------

-- this function can be called from an external script passing a
-- point is a circle with radius 5
function collisionHandler.rectPoint( rect, point ) -- used ontouch events
    if rect.contentBound.xMin ~= nil and point.x ~=nil then
      if rect.contentBound.xMin > point.x  or rect.contentBound.xMax < point.x or 
         rect.contentBound.yMin > point.y or  rect.contentBound.yMax < point.y then
        return false
      end
        return true
    end
end

-------------------


function collisionHandler.circlePoint(circle, point)
  if circle.contentBound.r ~=nil and point.x ~=nil then
    local xDis =  (circle.contentBound.x - point.x)^2 -- sq. of distance of point from circle center on x-axis
    local yDis = (circle.contentBound.y - point.y)^2 -- sq. of distance of point from circle center on y-axis
    local radiusSq = circle.contentBound.r^2 -- sq. of radius of circle
    
    if radiusSq < xDis + yDis then
       return false
    end
    return true
  end
end

-------------------

-- Rectangle-based collision detection
function collisionHandler.rectangleRectangleCollision( obj1, obj2 )

    if obj1.isSensor or obj2.isSensor then
        return false
    end
    if ( obj1 == nil) then  -- Make sure the first object exists
        return false
    end
    if ( obj2 == nil ) then  -- Make sure the other object exists
        return false
    end
    if(obj1==obj2)then -- do not check collision with self
    	return false
    end
    
    if obj1.contentBound.yMin >= obj2.contentBound.yMax then
        return false
    end
    if obj2.contentBound.yMin >= obj1.contentBound.yMax then
        return false
    end
    if obj1.contentBound.xMin >= obj2.contentBound.xMax then
        return false
    end
    if obj2.contentBound.xMin >= obj1.contentBound.xMax then
        return false
    end

    return true
end

-------------------------------------------------------

-- Rectangle-based collision detection that doesn't account for objects that might be sensors
function collisionHandler.hasCollidedIgnoreSensor( obj1, obj2 )

    if ( obj1 == nil) then  -- Make sure the first object exists
        return false
    end
    if ( obj2 == nil ) then  -- Make sure the other object exists
        return false
    end
    if(obj1==obj2)then -- do not check collision with self
        return false
    end
    
    if obj1.contentBound.yMin >= obj2.contentBound.yMax then
        return false
    end
    if obj2.contentBound.yMin >= obj1.contentBound.yMax then
        return false
    end
    if obj1.contentBound.xMin >= obj2.contentBound.xMax then
        return false
    end
    if obj2.contentBound.xMin >= obj1.contentBound.xMax then
        return false
    end

    return true
end

----------------------------------------------------

function collisionHandler.circleCircleCollision(obj1,obj2)
    if obj1.isSensor or obj2.isSensor then
        return false
    end

    local dist = (obj1.contentBound.x - obj2.contentBound.x)^2 + (obj1.contentBound.y - obj2.contentBound.y)^2
    return dist <= (obj1.contentBound.r + obj2.contentBound.r)^2
end

-------------------------------------------------------
--circle supplied with contentBound Table with x,y,r and rectangle supplied with standard contentBound table with xmin, xmax etc
function collisionHandler.circleRectangleCollision(circle,rectangle)
  if circle.isSensor or rectangle.isSensor then
      return false
  end
  
  local ry=rectangle.contentBound.yMin
  local rh=rectangle.contentBound.yMax-rectangle.contentBound.yMin
  local rx=rectangle.contentBound.xMin
  local rw=rectangle.contentBound.xMax-rectangle.contentBound.xMin

  local cx=circle.contentBound.x
  local cy=circle.contentBound.y
  local cr=circle.contentBound.r

  local DeltaX = cx - myMath.max(rx, myMath.min(cx, rx + rw));
  local DeltaY = cy - myMath.max(ry, myMath.min(cy, ry + rh));
  return (DeltaX * DeltaX + DeltaY * DeltaY) < (cr * cr);
end

-------------------------------------------------------

function collisionHandler.buttonCollision(event,btn)
    if(event.x<btn.contentBounds.xMin)then
        return false
    elseif(event.x>btn.contentBounds.xMax)then
        return false
    elseif(event.y<btn.contentBounds.yMin)then
        return false
    elseif(event.y>btn.contentBounds.yMax)then
        return false
    end
    return true
end

-------------------------------------------------------

function collisionHandler.pointCollision(point,rectangle)
    if(point.x<rectangle.contentBound.xMin or point.x>rectangle.contentBound.xMax or point.y<rectangle.contentBound.yMin or point.y>rectangle.contentBound.yMax)then
      return false
    end
    return true
end

-------------------------------------------------------

return collisionHandler