------------------------------------------------------------------------------
-- SORTABLE GROUPS
------------------------------------------------------------------------------
local setSort, sort

------------------------------------------------------------------------------
-- ADDED CONSTRUCTION FUNCTION
------------------------------------------------------------------------------

-- Create the new group type
if display.newSortableGroup == nil then
	function display.newSortableGroup( params )

		local self = display.newGroup()

		-- Add in the extra function
		self.sort    = sort
		self.setSort = setSort

		--set the sorting function as per the parameter passed
		if(params)then
			self:setSort(params)
		else 
        	self:setSort( { property = "zIndex" } )
        end

		-- Return the group
		return self

	end
end

------------------------------------------------------------------------------
-- SORTABLE GROUPS
------------------------------------------------------------------------------
--set the type of sorting function
function setSort( self, params )
	local property=params.property

	if(property=="zIndex")then
		self.sortFunction = function( a, b ) 
								return a[ property ] < b[ property ] 
							end
	else
		--create functions for other types of parameters
	end
end

-----------------------------------------------------------
function sort( self, params )

	--create a duplicate table consisting of all the child display objects in the ascending order of their z-indices 
	local sortedTable = {}
	local totalObjects = self.numChildren
	for i = 1, totalObjects do
		sortedTable[ i ] = self[ i ]
	end
	-- Sort them
	table.sort( sortedTable, self.sortFunction )
	-- Re-arrange the display objects as per the z-indices 
	for i = 1, #sortedTable do
		sortedTable[i]:toFront()
	end

end
-----------------------------------------------------------