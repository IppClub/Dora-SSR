-- [ts]: DoraX.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Spread = ____lualib.__TS__Spread -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local Warn, renderFunctionComponent, applyAutoEnableProps, visitAction, visitNode, getElementKey, getElementTypeName, warnUnkeyedDynamicChildren, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, isRunnableActionElement, shallowPropsEqual, collectRunnableActionElements, collectContactElements, getContactKey, patchPhysicsWorldInputs, actionElementEqual, actionChildrenEqual, createActionDef, structuralChildrenEqual, runActionChildren, patchActionChildren, toHostElement, createHostNode, getElementChildren, getRecreateMode, isEventProp, getEventSlot, isPatchableEventProp, patchEventProp, patchContactFilterProp, patchUpdateProp, patchRenderProp, clearRemovedProp, getAlignStyleText, patchPlayableProps, patchAudioSourceProps, patchParticleProps, patchAlignNodeProps, patchLineProps, clearRef, patchRef, applyProp, patchProps, addChildToParent, mountElement, unmountHostElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap, warnedUnkeyedChildTypes, renderingHookRoot, currentHookFrame -- 1
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
	Dora.Log("Warn", "[Dora Warning] " .. msg) -- 14
end -- 14
function renderFunctionComponent(component, props) -- 147
	local frame = renderingHookRoot and renderingHookRoot:beginComponentHooks(component, props.key) -- 148
	if frame == nil then -- 148
		return component(props) -- 150
	end -- 150
	local lastHookFrame = currentHookFrame -- 152
	currentHookFrame = frame -- 153
	do -- 153
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 153
			return true, component(props) -- 155
		end) -- 155
		do -- 155
			currentHookFrame = lastHookFrame -- 157
		end -- 157
		if not ____try then -- 157
			error(____hasReturned, 0) -- 157
		end -- 157
		if ____try and ____hasReturned then -- 157
			return ____returnValue -- 154
		end -- 154
	end -- 154
end -- 154
function applyAutoEnableProps(node, props) -- 163
	local jnode = props -- 164
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseMove or jnode.onMouseWheel or jnode.onGesture) then -- 164
		node.touchEnabled = true -- 175
	end -- 175
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 175
		node.keyboardEnabled = true -- 182
	end -- 182
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 182
		node.controllerEnabled = true -- 189
	end -- 189
	local body = Dora.tolua.cast(node, "Body") -- 191
	if body ~= nil then -- 191
		local bodyProps = props -- 193
		if bodyProps.receivingContact ~= false and (bodyProps.onContactStart or bodyProps.onContactEnd) then -- 193
			body.receivingContact = true -- 198
		end -- 198
	end -- 198
end -- 198
function visitAction(actionStack, enode) -- 937
	local createAction = actionMap[enode.type] -- 938
	if createAction ~= nil then -- 938
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 940
		return -- 941
	end -- 941
	repeat -- 941
		local ____switch198 = enode.type -- 941
		local ____cond198 = ____switch198 == "delay" -- 941
		if ____cond198 then -- 941
			do -- 941
				local item = enode.props -- 945
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 946
				break -- 947
			end -- 947
		end -- 947
		____cond198 = ____cond198 or ____switch198 == "event" -- 947
		if ____cond198 then -- 947
			do -- 947
				local item = enode.props -- 950
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 951
				break -- 952
			end -- 952
		end -- 952
		____cond198 = ____cond198 or ____switch198 == "hide" -- 952
		if ____cond198 then -- 952
			do -- 952
				actionStack[#actionStack + 1] = Dora.Hide() -- 955
				break -- 956
			end -- 956
		end -- 956
		____cond198 = ____cond198 or ____switch198 == "show" -- 956
		if ____cond198 then -- 956
			do -- 956
				actionStack[#actionStack + 1] = Dora.Show() -- 959
				break -- 960
			end -- 960
		end -- 960
		____cond198 = ____cond198 or ____switch198 == "move" -- 960
		if ____cond198 then -- 960
			do -- 960
				local item = enode.props -- 963
				actionStack[#actionStack + 1] = Dora.Move( -- 964
					item.time, -- 964
					Dora.Vec2(item.startX, item.startY), -- 964
					Dora.Vec2(item.stopX, item.stopY), -- 964
					item.easing -- 964
				) -- 964
				break -- 965
			end -- 965
		end -- 965
		____cond198 = ____cond198 or ____switch198 == "frame" -- 965
		if ____cond198 then -- 965
			do -- 965
				local item = enode.props -- 968
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 969
				break -- 970
			end -- 970
		end -- 970
		____cond198 = ____cond198 or ____switch198 == "spawn" -- 970
		if ____cond198 then -- 970
			do -- 970
				local spawnStack = {} -- 973
				for i = 1, #enode.children do -- 973
					visitAction(spawnStack, enode.children[i]) -- 975
				end -- 975
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 977
				break -- 978
			end -- 978
		end -- 978
		____cond198 = ____cond198 or ____switch198 == "sequence" -- 978
		if ____cond198 then -- 978
			do -- 978
				local sequenceStack = {} -- 981
				for i = 1, #enode.children do -- 981
					visitAction(sequenceStack, enode.children[i]) -- 983
				end -- 983
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 985
				break -- 986
			end -- 986
		end -- 986
		do -- 986
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 989
			break -- 990
		end -- 990
	until true -- 990
end -- 990
function visitNode(nodeStack, node, parent) -- 1538
	if type(node) ~= "table" then -- 1538
		return -- 1540
	end -- 1540
	local enode = node -- 1542
	if enode.type == nil then -- 1542
		local list = node -- 1544
		if #list > 0 then -- 1544
			for i = 1, #list do -- 1544
				local stack = {} -- 1547
				visitNode(stack, list[i], parent) -- 1548
				for i = 1, #stack do -- 1548
					nodeStack[#nodeStack + 1] = stack[i] -- 1550
				end -- 1550
			end -- 1550
		end -- 1550
	else -- 1550
		local handler = elementMap[enode.type] -- 1555
		if handler ~= nil then -- 1555
			handler(nodeStack, enode, parent) -- 1557
		else -- 1557
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1559
		end -- 1559
	end -- 1559
end -- 1559
function ____exports.toNode(enode) -- 1564
	local nodeStack = {} -- 1565
	visitNode(nodeStack, enode) -- 1566
	if #nodeStack == 1 then -- 1566
		return nodeStack[1] -- 1568
	elseif #nodeStack > 1 then -- 1568
		local node = Dora.Node() -- 1570
		for i = 1, #nodeStack do -- 1570
			node:addChild(nodeStack[i]) -- 1572
		end -- 1572
		return node -- 1574
	end -- 1574
	return nil -- 1576
end -- 1564
function getElementKey(element) -- 1599
	local props = element.props -- 1600
	local ____props_63 -- 1601
	if props then -- 1601
		____props_63 = props.key -- 1601
	else -- 1601
		____props_63 = nil -- 1601
	end -- 1601
	return ____props_63 -- 1601
end -- 1601
function getElementTypeName(element) -- 1604
	local elementType = element.type -- 1605
	if type(elementType) == "string" then -- 1605
		return elementType -- 1606
	end -- 1606
	return tostring(elementType) -- 1607
end -- 1607
function warnUnkeyedDynamicChildren(oldChildren, newElements) -- 1610
	if #oldChildren == #newElements then -- 1610
		return -- 1611
	end -- 1611
	local oldTypes = {} -- 1612
	for i = 1, #oldChildren do -- 1612
		local oldElement = oldChildren[i].element -- 1614
		if getElementKey(oldElement) == nil then -- 1614
			oldTypes[getElementTypeName(oldElement)] = true -- 1616
		end -- 1616
	end -- 1616
	for i = 1, #newElements do -- 1616
		do -- 1616
			local newElement = newElements[i] -- 1620
			if getElementKey(newElement) ~= nil then -- 1620
				goto __continue347 -- 1621
			end -- 1621
			local typeName = getElementTypeName(newElement) -- 1622
			if oldTypes[typeName] == true and not warnedUnkeyedChildTypes[typeName] then -- 1622
				warnedUnkeyedChildTypes[typeName] = true -- 1624
				Warn(("dynamic children include unkeyed <" .. typeName) .. "> siblings while child count changed; add stable key props to conditional, inserted, removed or reordered siblings to avoid index-based reuse") -- 1625
			end -- 1625
		end -- 1625
		::__continue347:: -- 1625
	end -- 1625
end -- 1625
function getPrimitiveLabelText(enode) -- 1637
	local label = enode.props -- 1638
	local text = label.text or "" -- 1639
	for i = 1, #enode.children do -- 1639
		local child = enode.children[i] -- 1641
		if type(child) ~= "table" then -- 1641
			text = text .. tostring(child) -- 1643
		end -- 1643
	end -- 1643
	return text -- 1646
end -- 1646
function isDrawShapeElement(element) -- 1649
	repeat -- 1649
		local ____switch356 = element.type -- 1649
		local ____cond356 = ____switch356 == "dot-shape" or ____switch356 == "circle-shape" or ____switch356 == "ellipse-shape" or ____switch356 == "rounded-rect-shape" or ____switch356 == "ring-shape" or ____switch356 == "sector-shape" or ____switch356 == "polyline-shape" or ____switch356 == "arc-shape" or ____switch356 == "quadratic-bezier-shape" or ____switch356 == "cubic-bezier-shape" or ____switch356 == "segment-shape" or ____switch356 == "rect-shape" or ____switch356 == "polygon-shape" or ____switch356 == "verts-shape" -- 1649
		if ____cond356 then -- 1649
			return true -- 1665
		end -- 1665
	until true -- 1665
	return false -- 1667
end -- 1667
function isBodyFixtureElement(element) -- 1670
	repeat -- 1670
		local ____switch358 = element.type -- 1670
		local ____cond358 = ____switch358 == "rect-fixture" or ____switch358 == "polygon-fixture" or ____switch358 == "multi-fixture" or ____switch358 == "disk-fixture" or ____switch358 == "chain-fixture" -- 1670
		if ____cond358 then -- 1670
			return true -- 1677
		end -- 1677
	until true -- 1677
	return false -- 1679
end -- 1679
function isPhysicsWorldInputElement(element) -- 1682
	return element.type == "contact" -- 1683
end -- 1683
function isRunnableActionElement(element) -- 1686
	if element.type == "loop" then -- 1686
		return true -- 1687
	end -- 1687
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1688
end -- 1688
function shallowPropsEqual(oldProps, newProps) -- 1699
	for k, v in pairs(oldProps) do -- 1700
		if k ~= "ref" and newProps[k] ~= v then -- 1700
			return false -- 1701
		end -- 1701
	end -- 1701
	for k, v in pairs(newProps) do -- 1703
		if k ~= "ref" and oldProps[k] ~= v then -- 1703
			return false -- 1704
		end -- 1704
	end -- 1704
	return true -- 1706
end -- 1706
function collectRunnableActionElements(element) -- 1709
	local actions = {} -- 1710
	for i = 1, #element.children do -- 1710
		local child = element.children[i] -- 1712
		if type(child) == "table" and isRunnableActionElement(child) then -- 1712
			actions[#actions + 1] = child -- 1714
		end -- 1714
	end -- 1714
	return actions -- 1717
end -- 1717
function collectContactElements(element) -- 1720
	local contacts = {} -- 1721
	for i = 1, #element.children do -- 1721
		local child = element.children[i] -- 1723
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1723
			contacts[#contacts + 1] = child -- 1725
		end -- 1725
	end -- 1725
	return contacts -- 1728
end -- 1728
function getContactKey(contact) -- 1731
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1732
end -- 1732
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1735
	local oldContacts = collectContactElements(oldElement) -- 1736
	local newContacts = collectContactElements(newElement) -- 1737
	local oldByKey = {} -- 1738
	local newByKey = {} -- 1739
	for i = 1, #oldContacts do -- 1739
		local contact = oldContacts[i].props -- 1741
		oldByKey[getContactKey(contact)] = contact -- 1742
	end -- 1742
	for i = 1, #newContacts do -- 1742
		local contact = newContacts[i].props -- 1745
		newByKey[getContactKey(contact)] = contact -- 1746
	end -- 1746
	for i = 1, #oldContacts do -- 1746
		local oldContact = oldContacts[i].props -- 1749
		local key = getContactKey(oldContact) -- 1750
		local newContact = newByKey[key] -- 1751
		if newContact == nil then -- 1751
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1753
		elseif oldContact.enabled ~= newContact.enabled then -- 1753
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1755
		end -- 1755
	end -- 1755
	for i = 1, #newContacts do -- 1755
		local newContact = newContacts[i].props -- 1759
		if oldByKey[getContactKey(newContact)] == nil then -- 1759
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1761
		end -- 1761
	end -- 1761
end -- 1761
function actionElementEqual(oldElement, newElement) -- 1766
	if oldElement.type ~= newElement.type then -- 1766
		return false -- 1767
	end -- 1767
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1767
		return false -- 1768
	end -- 1768
	if #oldElement.children ~= #newElement.children then -- 1768
		return false -- 1769
	end -- 1769
	for i = 1, #oldElement.children do -- 1769
		local oldChild = oldElement.children[i] -- 1771
		local newChild = newElement.children[i] -- 1772
		if type(oldChild) ~= type(newChild) then -- 1772
			return false -- 1773
		end -- 1773
		if type(oldChild) == "table" then -- 1773
			if not actionElementEqual(oldChild, newChild) then -- 1773
				return false -- 1775
			end -- 1775
		elseif oldChild ~= newChild then -- 1775
			return false -- 1777
		end -- 1777
	end -- 1777
	return true -- 1780
end -- 1780
function actionChildrenEqual(oldElement, newElement) -- 1783
	local oldActions = collectRunnableActionElements(oldElement) -- 1784
	local newActions = collectRunnableActionElements(newElement) -- 1785
	if #oldActions ~= #newActions then -- 1785
		return false -- 1786
	end -- 1786
	for i = 1, #oldActions do -- 1786
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1786
			return false -- 1788
		end -- 1788
	end -- 1788
	return true -- 1790
end -- 1790
function createActionDef(actionElement) -- 1793
	if actionElement.type == "loop" then -- 1793
		local actionStack = {} -- 1795
		for i = 1, #actionElement.children do -- 1795
			visitAction(actionStack, actionElement.children[i]) -- 1797
		end -- 1797
		if #actionStack == 1 then -- 1797
			return actionStack[1], true -- 1800
		elseif #actionStack > 1 then -- 1800
			local loop = actionElement.props -- 1802
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1803
		end -- 1803
		return nil, true -- 1805
	end -- 1805
	local actionStack = {} -- 1807
	visitAction(actionStack, actionElement) -- 1808
	return #actionStack == 1 and actionStack[1] or nil, false -- 1809
end -- 1809
function structuralChildrenEqual(oldElement, newElement, check) -- 1812
	local oldChildren = {} -- 1818
	local newChildren = {} -- 1819
	for i = 1, #oldElement.children do -- 1819
		local child = oldElement.children[i] -- 1821
		if type(child) == "table" and check(child) then -- 1821
			oldChildren[#oldChildren + 1] = child -- 1823
		end -- 1823
	end -- 1823
	for i = 1, #newElement.children do -- 1823
		local child = newElement.children[i] -- 1827
		if type(child) == "table" and check(child) then -- 1827
			newChildren[#newChildren + 1] = child -- 1829
		end -- 1829
	end -- 1829
	if #oldChildren ~= #newChildren then -- 1829
		return false -- 1832
	end -- 1832
	for i = 1, #oldChildren do -- 1832
		local oldChild = oldChildren[i] -- 1834
		local newChild = newChildren[i] -- 1835
		if oldChild.type ~= newChild.type then -- 1835
			return false -- 1836
		end -- 1836
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1836
			return false -- 1837
		end -- 1837
	end -- 1837
	return true -- 1839
end -- 1839
function runActionChildren(node, element) -- 1842
	local actionChildren = collectRunnableActionElements(element) -- 1843
	local exclusiveActions = {} -- 1844
	local exclusiveLoop -- 1845
	local warnedExclusiveConflict = false -- 1846
	for i = 1, #actionChildren do -- 1846
		do -- 1846
			local actionElement = actionChildren[i] -- 1848
			local action, loop = createActionDef(actionElement) -- 1849
			if action == nil then -- 1849
				goto __continue410 -- 1850
			end -- 1850
			if actionElement.props.exclusive == true then -- 1850
				if exclusiveLoop == nil then -- 1850
					exclusiveLoop = loop -- 1853
				end -- 1853
				if exclusiveLoop == loop then -- 1853
					exclusiveActions[#exclusiveActions + 1] = action -- 1856
				elseif not warnedExclusiveConflict then -- 1856
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1858
					warnedExclusiveConflict = true -- 1859
				end -- 1859
			end -- 1859
		end -- 1859
		::__continue410:: -- 1859
	end -- 1859
	if #exclusiveActions == 1 then -- 1859
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1864
	elseif #exclusiveActions > 1 then -- 1864
		node:perform( -- 1866
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1866
			exclusiveLoop == true -- 1866
		) -- 1866
	end -- 1866
	for i = 1, #actionChildren do -- 1866
		do -- 1866
			local actionElement = actionChildren[i] -- 1869
			if actionElement.props.exclusive == true then -- 1869
				goto __continue418 -- 1870
			end -- 1870
			local action, loop = createActionDef(actionElement) -- 1871
			if action ~= nil then -- 1871
				node:runAction(action, loop) -- 1873
			end -- 1873
		end -- 1873
		::__continue418:: -- 1873
	end -- 1873
end -- 1873
function patchActionChildren(node, oldElement, newElement) -- 1878
	if not actionChildrenEqual(oldElement, newElement) then -- 1878
		runActionChildren(node, newElement) -- 1880
	end -- 1880
end -- 1880
function toHostElement(enode, parent) -- 1893
	local hostChildren = {} -- 1894
	local props = {} -- 1895
	if enode.props ~= nil then -- 1895
		for k, v in pairs(enode.props) do -- 1897
			props[k] = v -- 1898
		end -- 1898
	end -- 1898
	if enode.type == "label" then -- 1898
		for i = 1, #enode.children do -- 1898
			local child = enode.children[i] -- 1903
			if type(child) ~= "table" then -- 1903
				hostChildren[#hostChildren + 1] = child -- 1905
			end -- 1905
		end -- 1905
	elseif enode.type == "draw-node" then -- 1905
		for i = 1, #enode.children do -- 1905
			local child = enode.children[i] -- 1910
			if type(child) == "table" and isDrawShapeElement(child) then -- 1910
				hostChildren[#hostChildren + 1] = child -- 1912
			end -- 1912
		end -- 1912
	elseif enode.type == "body" then -- 1912
		for i = 1, #enode.children do -- 1912
			local child = enode.children[i] -- 1917
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1917
				hostChildren[#hostChildren + 1] = child -- 1919
			end -- 1919
		end -- 1919
	elseif enode.type == "physics-world" then -- 1919
		for i = 1, #enode.children do -- 1919
			local child = enode.children[i] -- 1924
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1924
				hostChildren[#hostChildren + 1] = child -- 1926
			end -- 1926
		end -- 1926
	end -- 1926
	if enode.type == "body" and props.world == nil then -- 1926
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1931
		if world ~= nil then -- 1931
			props.world = world -- 1933
		end -- 1933
	end -- 1933
	return {type = enode.type, props = props, children = hostChildren} -- 1936
end -- 1936
function createHostNode(enode, parent) -- 1943
	local nodeStack = {} -- 1944
	visitNode( -- 1945
		nodeStack, -- 1945
		toHostElement(enode, parent) -- 1945
	) -- 1945
	if #nodeStack == 1 then -- 1945
		return nodeStack[1] -- 1947
	elseif #nodeStack > 1 then -- 1947
		local node = Dora.Node() -- 1949
		for i = 1, #nodeStack do -- 1949
			node:addChild(nodeStack[i]) -- 1951
		end -- 1951
		return node -- 1953
	end -- 1953
	return nil -- 1955
end -- 1955
function getElementChildren(enode) -- 1958
	local children = {} -- 1959
	if enode.type == "draw-node" or enode.type == "body" then -- 1959
		return children -- 1960
	end -- 1960
	for i = 1, #enode.children do -- 1960
		local child = enode.children[i] -- 1962
		if type(child) == "table" then -- 1962
			local childElement = child -- 1964
			if childElement.type ~= nil then -- 1964
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1964
					children[#children + 1] = childElement -- 1970
				end -- 1970
			else -- 1970
				local list = child -- 1973
				for j = 1, #list do -- 1973
					local item = list[j] -- 1975
					if type(item) == "table" and item.type ~= nil then -- 1975
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1975
							children[#children + 1] = item -- 1981
						end -- 1981
					end -- 1981
				end -- 1981
			end -- 1981
		end -- 1981
	end -- 1981
	return children -- 1988
end -- 1988
function getRecreateMode(oldElement, newElement) -- 1993
	if oldElement.type ~= newElement.type then -- 1993
		return "subtree" -- 1994
	end -- 1994
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1994
		return "subtree" -- 1995
	end -- 1995
	local oldProps = oldElement.props -- 1996
	local newProps = newElement.props -- 1997
	if newElement.type == "draw-node" then -- 1997
		return "host" -- 1998
	end -- 1998
	for k, v in pairs(oldProps) do -- 1999
		if k == "onMount" and newProps[k] ~= v then -- 1999
			return "host" -- 2001
		end -- 2001
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 2001
			return "host" -- 2004
		end -- 2004
	end -- 2004
	for k, v in pairs(newProps) do -- 2007
		if k == "onMount" and oldProps[k] ~= v then -- 2007
			return "host" -- 2009
		end -- 2009
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 2009
			return "host" -- 2012
		end -- 2012
	end -- 2012
	repeat -- 2012
		local ____switch467 = newElement.type -- 2012
		local ____cond467 = ____switch467 == "grid" -- 2012
		if ____cond467 then -- 2012
			return (oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY) and "host" or nil -- 2017
		end -- 2017
		____cond467 = ____cond467 or (____switch467 == "sprite" or ____switch467 == "video-node" or ____switch467 == "tic80-node" or ____switch467 == "audio-source" or ____switch467 == "particle" or ____switch467 == "tile-node" or ____switch467 == "playable" or ____switch467 == "dragon-bone" or ____switch467 == "spine" or ____switch467 == "model") -- 2017
		if ____cond467 then -- 2017
			return oldProps.file ~= newProps.file and "host" or nil -- 2028
		end -- 2028
		____cond467 = ____cond467 or ____switch467 == "label" -- 2028
		if ____cond467 then -- 2028
			return (oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf) and "host" or nil -- 2030
		end -- 2030
		____cond467 = ____cond467 or ____switch467 == "align-node" -- 2030
		if ____cond467 then -- 2030
			return oldProps.windowRoot ~= newProps.windowRoot and "host" or nil -- 2032
		end -- 2032
		____cond467 = ____cond467 or ____switch467 == "custom-node" -- 2032
		if ____cond467 then -- 2032
			return oldProps.onCreate ~= newProps.onCreate and "host" or nil -- 2034
		end -- 2034
		____cond467 = ____cond467 or ____switch467 == "body" -- 2034
		if ____cond467 then -- 2034
			return (oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement)) and "host" or nil -- 2036
		end -- 2036
	until true -- 2036
	return nil -- 2043
end -- 2043
function isEventProp(key) -- 2046
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 2047
end -- 2047
function getEventSlot(key) -- 2050
	repeat -- 2050
		local ____switch470 = key -- 2050
		local ____cond470 = ____switch470 == "onActionEnd" -- 2050
		if ____cond470 then -- 2050
			return "ActionEnd" -- 2052
		end -- 2052
		____cond470 = ____cond470 or ____switch470 == "onTapFilter" -- 2052
		if ____cond470 then -- 2052
			return "TapFilter" -- 2053
		end -- 2053
		____cond470 = ____cond470 or ____switch470 == "onTapBegan" -- 2053
		if ____cond470 then -- 2053
			return "TapBegan" -- 2054
		end -- 2054
		____cond470 = ____cond470 or ____switch470 == "onTapEnded" -- 2054
		if ____cond470 then -- 2054
			return "TapEnded" -- 2055
		end -- 2055
		____cond470 = ____cond470 or ____switch470 == "onTapped" -- 2055
		if ____cond470 then -- 2055
			return "Tapped" -- 2056
		end -- 2056
		____cond470 = ____cond470 or ____switch470 == "onTapMoved" -- 2056
		if ____cond470 then -- 2056
			return "TapMoved" -- 2057
		end -- 2057
		____cond470 = ____cond470 or ____switch470 == "onMouseMove" -- 2057
		if ____cond470 then -- 2057
			return "MouseMove" -- 2058
		end -- 2058
		____cond470 = ____cond470 or ____switch470 == "onMouseWheel" -- 2058
		if ____cond470 then -- 2058
			return "MouseWheel" -- 2059
		end -- 2059
		____cond470 = ____cond470 or ____switch470 == "onGesture" -- 2059
		if ____cond470 then -- 2059
			return "Gesture" -- 2060
		end -- 2060
		____cond470 = ____cond470 or ____switch470 == "onEnter" -- 2060
		if ____cond470 then -- 2060
			return "Enter" -- 2061
		end -- 2061
		____cond470 = ____cond470 or ____switch470 == "onExit" -- 2061
		if ____cond470 then -- 2061
			return "Exit" -- 2062
		end -- 2062
		____cond470 = ____cond470 or ____switch470 == "onCleanup" -- 2062
		if ____cond470 then -- 2062
			return "Cleanup" -- 2063
		end -- 2063
		____cond470 = ____cond470 or ____switch470 == "onKeyDown" -- 2063
		if ____cond470 then -- 2063
			return "KeyDown" -- 2064
		end -- 2064
		____cond470 = ____cond470 or ____switch470 == "onKeyUp" -- 2064
		if ____cond470 then -- 2064
			return "KeyUp" -- 2065
		end -- 2065
		____cond470 = ____cond470 or ____switch470 == "onKeyPressed" -- 2065
		if ____cond470 then -- 2065
			return "KeyPressed" -- 2066
		end -- 2066
		____cond470 = ____cond470 or ____switch470 == "onAttachIME" -- 2066
		if ____cond470 then -- 2066
			return "AttachIME" -- 2067
		end -- 2067
		____cond470 = ____cond470 or ____switch470 == "onDetachIME" -- 2067
		if ____cond470 then -- 2067
			return "DetachIME" -- 2068
		end -- 2068
		____cond470 = ____cond470 or ____switch470 == "onTextInput" -- 2068
		if ____cond470 then -- 2068
			return "TextInput" -- 2069
		end -- 2069
		____cond470 = ____cond470 or ____switch470 == "onTextEditing" -- 2069
		if ____cond470 then -- 2069
			return "TextEditing" -- 2070
		end -- 2070
		____cond470 = ____cond470 or ____switch470 == "onButtonDown" -- 2070
		if ____cond470 then -- 2070
			return "ButtonDown" -- 2071
		end -- 2071
		____cond470 = ____cond470 or ____switch470 == "onButtonUp" -- 2071
		if ____cond470 then -- 2071
			return "ButtonUp" -- 2072
		end -- 2072
		____cond470 = ____cond470 or ____switch470 == "onAxis" -- 2072
		if ____cond470 then -- 2072
			return "Axis" -- 2073
		end -- 2073
		____cond470 = ____cond470 or ____switch470 == "onAnimationEnd" -- 2073
		if ____cond470 then -- 2073
			return "AnimationEnd" -- 2074
		end -- 2074
		____cond470 = ____cond470 or ____switch470 == "onVideoEnd" -- 2074
		if ____cond470 then -- 2074
			return "VideoEnd" -- 2075
		end -- 2075
		____cond470 = ____cond470 or ____switch470 == "onFinished" -- 2075
		if ____cond470 then -- 2075
			return "Finished" -- 2076
		end -- 2076
		____cond470 = ____cond470 or ____switch470 == "onLayout" -- 2076
		if ____cond470 then -- 2076
			return "AlignLayout" -- 2077
		end -- 2077
		____cond470 = ____cond470 or ____switch470 == "onBodyEnter" -- 2077
		if ____cond470 then -- 2077
			return "BodyEnter" -- 2078
		end -- 2078
		____cond470 = ____cond470 or ____switch470 == "onBodyLeave" -- 2078
		if ____cond470 then -- 2078
			return "BodyLeave" -- 2079
		end -- 2079
		____cond470 = ____cond470 or ____switch470 == "onContactStart" -- 2079
		if ____cond470 then -- 2079
			return "ContactStart" -- 2080
		end -- 2080
		____cond470 = ____cond470 or ____switch470 == "onContactEnd" -- 2080
		if ____cond470 then -- 2080
			return "ContactEnd" -- 2081
		end -- 2081
	until true -- 2081
	return nil -- 2083
end -- 2083
function isPatchableEventProp(key) -- 2086
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 2087
end -- 2087
function patchEventProp(node, key, value) -- 2090
	local slotName = getEventSlot(key) -- 2091
	if slotName == nil then -- 2091
		return -- 2092
	end -- 2092
	node:slot(slotName):clear() -- 2093
	if value ~= nil then -- 2093
		if key == "onLayout" then -- 2093
			node:onAlignLayout(value) -- 2096
		else -- 2096
			node:slot(slotName, value) -- 2098
		end -- 2098
	end -- 2098
end -- 2098
function patchContactFilterProp(node, value) -- 2103
	local body = Dora.tolua.cast(node, "Body") -- 2104
	if body == nil then -- 2104
		return -- 2105
	end -- 2105
	if value == nil then -- 2105
		body:onContactFilter(function() return true end) -- 2107
	else -- 2107
		body:onContactFilter(value) -- 2109
	end -- 2109
end -- 2109
function patchUpdateProp(node, value) -- 2113
	if value == nil then -- 2113
		node:unschedule() -- 2115
	elseif type(value) == "thread" then -- 2115
		node:schedule(value) -- 2117
	else -- 2117
		node:schedule(value) -- 2119
	end -- 2119
end -- 2119
function patchRenderProp(node, value) -- 2123
	local clearRender = node.clearRender -- 2124
	if type(clearRender) == "function" then -- 2124
		clearRender(node) -- 2126
	end -- 2126
	if value == nil then -- 2126
		return -- 2129
	end -- 2129
	node:onRender(value) -- 2131
end -- 2131
function clearRemovedProp(node, key) -- 2134
	repeat -- 2134
		local ____switch490 = key -- 2134
		local ____cond490 = ____switch490 == "transformTarget" or ____switch490 == "stencil" -- 2134
		if ____cond490 then -- 2134
			node[key] = nil -- 2138
			return true -- 2139
		end -- 2139
	until true -- 2139
	return false -- 2141
end -- 2141
function getAlignStyleText(style) -- 2144
	local items = {} -- 2145
	for k, v in pairs(style) do -- 2146
		local name = string.gsub(k, "%u", "-%1") -- 2147
		name = string.lower(name) -- 2148
		repeat -- 2148
			local ____switch493 = k -- 2148
			local ____cond493 = ____switch493 == "margin" or ____switch493 == "padding" or ____switch493 == "border" or ____switch493 == "gap" -- 2148
			if ____cond493 then -- 2148
				do -- 2148
					if type(v) == "table" then -- 2148
						local valueStr = table.concat( -- 2153
							__TS__ArrayMap( -- 2153
								v, -- 2153
								function(____, item) return tostring(item) end -- 2153
							), -- 2153
							"," -- 2153
						) -- 2153
						items[#items + 1] = (name .. ":") .. valueStr -- 2154
					else -- 2154
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2156
					end -- 2156
					break -- 2158
				end -- 2158
			end -- 2158
			do -- 2158
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2161
				break -- 2162
			end -- 2162
		until true -- 2162
	end -- 2162
	return table.concat(items, ";") -- 2165
end -- 2165
function patchPlayableProps(node, oldProps, newProps) -- 2168
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2168
		node:play(newProps.play, newProps.loop == true) -- 2170
	end -- 2170
end -- 2170
function patchAudioSourceProps(node, oldProps, newProps) -- 2174
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2174
		local audio = node -- 2176
		repeat -- 2176
			local ____switch502 = newProps.playMode -- 2176
			local ____cond502 = ____switch502 == "normal" -- 2176
			if ____cond502 then -- 2176
				local ____audio_play_65 = audio.play -- 2178
				local ____newProps_delayTime_64 = newProps.delayTime -- 2178
				if ____newProps_delayTime_64 == nil then -- 2178
					____newProps_delayTime_64 = 0 -- 2178
				end -- 2178
				____audio_play_65(audio, ____newProps_delayTime_64) -- 2178
				break -- 2178
			end -- 2178
			____cond502 = ____cond502 or ____switch502 == "background" -- 2178
			if ____cond502 then -- 2178
				audio:playBackground() -- 2179
				break -- 2179
			end -- 2179
			____cond502 = ____cond502 or ____switch502 == "3D" -- 2179
			if ____cond502 then -- 2179
				local ____audio_play3D_67 = audio.play3D -- 2180
				local ____newProps_delayTime_66 = newProps.delayTime -- 2180
				if ____newProps_delayTime_66 == nil then -- 2180
					____newProps_delayTime_66 = 0 -- 2180
				end -- 2180
				____audio_play3D_67(audio, ____newProps_delayTime_66) -- 2180
				break -- 2180
			end -- 2180
		until true -- 2180
	end -- 2180
end -- 2180
function patchParticleProps(node, oldProps, newProps) -- 2185
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2185
		local particle = node -- 2187
		if newProps.emit then -- 2187
			particle:start() -- 2189
		else -- 2189
			particle:stop() -- 2191
		end -- 2191
	end -- 2191
end -- 2191
function patchAlignNodeProps(node, oldProps, newProps) -- 2196
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2196
		node:css(getAlignStyleText(newProps.style)) -- 2198
	end -- 2198
end -- 2198
function patchLineProps(node, oldProps, newProps) -- 2202
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2202
		local ____self_71 = node -- 2202
		local ____self_71_set_72 = ____self_71.set -- 2202
		local ____newProps_verts_70 = newProps.verts -- 2204
		local ____Dora_Color_69 = Dora.Color -- 2204
		local ____newProps_lineColor_68 = newProps.lineColor -- 2204
		if ____newProps_lineColor_68 == nil then -- 2204
			____newProps_lineColor_68 = 4294967295 -- 2204
		end -- 2204
		____self_71_set_72( -- 2204
			____self_71, -- 2204
			____newProps_verts_70, -- 2204
			____Dora_Color_69(____newProps_lineColor_68) -- 2204
		) -- 2204
	end -- 2204
end -- 2204
function clearRef(props, node) -- 2208
	local ref = props.ref -- 2209
	if ref ~= nil and (node == nil or ref.current == node) then -- 2209
		ref.current = nil -- 2211
	end -- 2211
end -- 2211
function patchRef(node, oldProps, newProps) -- 2215
	if oldProps.ref ~= newProps.ref then -- 2215
		clearRef(oldProps, node) -- 2217
		local ref = newProps.ref -- 2218
		if ref ~= nil then -- 2218
			ref.current = node -- 2220
		end -- 2220
	end -- 2220
end -- 2220
function applyProp(node, enode, key, value) -- 2225
	local name = key -- 2226
	repeat -- 2226
		local ____switch517 = name -- 2226
		local ____cond517 = ____switch517 == "key" or ____switch517 == "children" or ____switch517 == "onMount" or ____switch517 == "onUnmount" -- 2226
		if ____cond517 then -- 2226
			return -- 2232
		end -- 2232
		____cond517 = ____cond517 or ____switch517 == "ref" -- 2232
		if ____cond517 then -- 2232
			value.current = node -- 2234
			return -- 2235
		end -- 2235
		____cond517 = ____cond517 or ____switch517 == "anchorX" -- 2235
		if ____cond517 then -- 2235
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2237
			return -- 2238
		end -- 2238
		____cond517 = ____cond517 or ____switch517 == "anchorY" -- 2238
		if ____cond517 then -- 2238
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2240
			return -- 2241
		end -- 2241
		____cond517 = ____cond517 or ____switch517 == "color3" -- 2241
		if ____cond517 then -- 2241
			node.color3 = Dora.Color3(value) -- 2243
			return -- 2244
		end -- 2244
		____cond517 = ____cond517 or ____switch517 == "transformTarget" -- 2244
		if ____cond517 then -- 2244
			node.transformTarget = value.current -- 2246
			return -- 2247
		end -- 2247
		____cond517 = ____cond517 or ____switch517 == "outlineColor" -- 2247
		if ____cond517 then -- 2247
			node[name] = Dora.Color(value) -- 2249
			return -- 2250
		end -- 2250
		____cond517 = ____cond517 or ____switch517 == "smoothLower" -- 2250
		if ____cond517 then -- 2250
			do -- 2250
				local smooth = node.smooth -- 2252
				node.smooth = Dora.Vec2(value, smooth.y) -- 2253
				return -- 2254
			end -- 2254
		end -- 2254
		____cond517 = ____cond517 or ____switch517 == "smoothUpper" -- 2254
		if ____cond517 then -- 2254
			do -- 2254
				local smooth = node.smooth -- 2257
				node.smooth = Dora.Vec2(smooth.x, value) -- 2258
				return -- 2259
			end -- 2259
		end -- 2259
	until true -- 2259
	if isEventProp(key) then -- 2259
		if key == "onUpdate" then -- 2259
			patchUpdateProp(node, value) -- 2264
		elseif key == "onRender" then -- 2264
			patchRenderProp(node, value) -- 2266
		elseif key == "onContactFilter" then -- 2266
			patchContactFilterProp(node, value) -- 2268
		elseif isPatchableEventProp(key) then -- 2268
			patchEventProp(node, key, value) -- 2270
		end -- 2270
		return -- 2272
	end -- 2272
	node[name] = value -- 2274
end -- 2274
function patchProps(node, oldElement, newElement) -- 2277
	local oldProps = oldElement.props -- 2278
	local newProps = newElement.props -- 2279
	for k in pairs(oldProps) do -- 2280
		if k == "onUpdate" and newProps[k] == nil then -- 2280
			patchUpdateProp(node, nil) -- 2282
		elseif k == "onRender" and newProps[k] == nil then -- 2282
			patchRenderProp(node, nil) -- 2284
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2284
			patchContactFilterProp(node, nil) -- 2286
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2286
			patchEventProp(node, k, nil) -- 2288
		elseif newProps[k] == nil then -- 2288
			clearRemovedProp(node, k) -- 2290
		end -- 2290
	end -- 2290
	patchRef(node, oldProps, newProps) -- 2293
	for k, v in pairs(newProps) do -- 2294
		if k ~= "ref" and oldProps[k] ~= v then -- 2294
			applyProp(node, newElement, k, v) -- 2296
		end -- 2296
	end -- 2296
	if newElement.type == "label" then -- 2296
		node.text = getPrimitiveLabelText(newElement) -- 2300
	elseif newElement.type == "physics-world" then -- 2300
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2302
		if world ~= nil then -- 2302
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2304
		end -- 2304
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2304
		patchPlayableProps(node, oldProps, newProps) -- 2312
	elseif newElement.type == "audio-source" then -- 2312
		patchAudioSourceProps(node, oldProps, newProps) -- 2314
	elseif newElement.type == "particle" then -- 2314
		patchParticleProps(node, oldProps, newProps) -- 2316
	elseif newElement.type == "align-node" then -- 2316
		patchAlignNodeProps(node, oldProps, newProps) -- 2318
	elseif newElement.type == "line" then -- 2318
		patchLineProps(node, oldProps, newProps) -- 2320
	end -- 2320
	applyAutoEnableProps(node, newProps) -- 2322
end -- 2322
function addChildToParent(parent, node, props) -- 2325
	if props.tag ~= nil then -- 2325
		parent:addChild(node, props.order or 0, props.tag) -- 2327
	elseif props.order ~= nil then -- 2327
		parent:addChild(node, props.order) -- 2329
	else -- 2329
		parent:addChild(node) -- 2331
	end -- 2331
end -- 2331
function mountElement(parent, enode) -- 2335
	local node = createHostNode(enode, parent) -- 2336
	if node == nil then -- 2336
		return nil -- 2338
	end -- 2338
	if isDrawShapeElement(enode) then -- 2338
		return nil -- 2341
	end -- 2341
	local props = enode.props -- 2343
	addChildToParent(parent, node, props) -- 2344
	local mounted = {element = enode, node = node, children = {}} -- 2345
	runActionChildren(node, enode) -- 2346
	mounted.children = reconcileChildren( -- 2347
		node, -- 2347
		{}, -- 2347
		getElementChildren(enode) -- 2347
	) -- 2347
	return mounted -- 2348
end -- 2348
function unmountHostElement(mounted) -- 2351
	local props = mounted.element.props -- 2352
	if props.onUnmount ~= nil then -- 2352
		props.onUnmount(mounted.node) -- 2354
	end -- 2354
	clearRef(mounted.element.props, mounted.node) -- 2356
	mounted.node:removeFromParent(true) -- 2357
end -- 2357
function unmountElement(mounted) -- 2360
	for i = 1, #mounted.children do -- 2360
		unmountElement(mounted.children[i]) -- 2362
	end -- 2362
	unmountHostElement(mounted) -- 2364
end -- 2364
function reconcileElement(parent, oldMounted, newElement) -- 2367
	if oldMounted == nil then -- 2367
		return mountElement(parent, newElement) -- 2369
	end -- 2369
	local recreateMode = getRecreateMode(oldMounted.element, newElement) -- 2371
	if recreateMode == "subtree" then -- 2371
		local oldNode = oldMounted.node -- 2373
		local oldOrder = oldNode.order -- 2374
		local oldTag = oldNode.tag -- 2375
		unmountElement(oldMounted) -- 2376
		local mounted = mountElement(parent, newElement) -- 2377
		if mounted ~= nil then -- 2377
			mounted.node.order = newElement.props.order or oldOrder -- 2379
			mounted.node.tag = newElement.props.tag or oldTag -- 2380
		end -- 2380
		return mounted -- 2382
	end -- 2382
	if recreateMode == "host" then -- 2382
		local oldNode = oldMounted.node -- 2385
		local oldOrder = oldNode.order -- 2386
		local oldTag = oldNode.tag -- 2387
		local node = createHostNode(newElement, parent) -- 2388
		if node == nil then -- 2388
			unmountElement(oldMounted) -- 2390
			return nil -- 2391
		end -- 2391
		addChildToParent(parent, node, newElement.props) -- 2393
		node.order = newElement.props.order or oldOrder -- 2394
		node.tag = newElement.props.tag or oldTag -- 2395
		runActionChildren(node, newElement) -- 2396
		for i = 1, #oldMounted.children do -- 2396
			oldMounted.children[i].node:moveToParent(node) -- 2398
		end -- 2398
		unmountHostElement(oldMounted) -- 2400
		oldMounted.node = node -- 2401
		oldMounted.children = reconcileChildren( -- 2402
			node, -- 2402
			oldMounted.children, -- 2402
			getElementChildren(newElement) -- 2402
		) -- 2402
		oldMounted.element = newElement -- 2403
		return oldMounted -- 2404
	end -- 2404
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2406
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2407
	oldMounted.children = reconcileChildren( -- 2408
		oldMounted.node, -- 2408
		oldMounted.children, -- 2408
		getElementChildren(newElement) -- 2408
	) -- 2408
	oldMounted.element = newElement -- 2409
	return oldMounted -- 2410
end -- 2410
function reconcileChildren(parent, oldChildren, newElements) -- 2413
	warnUnkeyedDynamicChildren(oldChildren, newElements) -- 2414
	local oldByKey = {} -- 2415
	local usedOld = {} -- 2416
	for i = 1, #oldChildren do -- 2416
		local oldChild = oldChildren[i] -- 2418
		local key = getElementKey(oldChild.element) -- 2419
		if key ~= nil then -- 2419
			oldByKey[key] = oldChild -- 2421
		end -- 2421
	end -- 2421
	local nextChildren = {} -- 2424
	for i = 1, #newElements do -- 2424
		local newElement = newElements[i] -- 2426
		local key = getElementKey(newElement) -- 2427
		local oldChild -- 2428
		if key ~= nil then -- 2428
			oldChild = oldByKey[key] -- 2430
		else -- 2430
			oldChild = oldChildren[i] -- 2432
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2432
				oldChild = nil -- 2434
			end -- 2434
		end -- 2434
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2437
		if mounted ~= nil then -- 2437
			usedOld[mounted] = true -- 2439
			nextChildren[#nextChildren + 1] = mounted -- 2440
			local props = newElement.props -- 2441
			mounted.node.order = props.order or i -- 2442
			if props.tag ~= nil then -- 2442
				mounted.node.tag = props.tag -- 2443
			end -- 2443
		end -- 2443
	end -- 2443
	for i = 1, #oldChildren do -- 2443
		local oldChild = oldChildren[i] -- 2447
		if not usedOld[oldChild] then -- 2447
			unmountElement(oldChild) -- 2449
		end -- 2449
	end -- 2449
	return nextChildren -- 2452
end -- 2452
____exports.React = {} -- 2452
local React = ____exports.React -- 2452
do -- 2452
	React.Component = __TS__Class() -- 17
	local Component = React.Component -- 17
	Component.name = "Component" -- 19
	function Component.prototype.____constructor(self, props) -- 20
		self.props = props -- 21
	end -- 20
	Component.isComponent = true -- 20
	React.Fragment = nil -- 17
	local function flattenChild(ch) -- 30
		if type(ch) ~= "table" then -- 30
			return ch, true -- 32
		end -- 32
		local child = ch -- 34
		if child.type ~= nil then -- 34
			return child, true -- 36
		elseif child.children then -- 36
			child = child.children -- 38
		end -- 38
		local list = child -- 40
		local flatChildren = {} -- 41
		for i = 1, #list do -- 41
			local child, flat = flattenChild(list[i]) -- 43
			if flat then -- 43
				flatChildren[#flatChildren + 1] = child -- 45
			else -- 45
				local listChild = child -- 47
				for i = 1, #listChild do -- 47
					flatChildren[#flatChildren + 1] = listChild[i] -- 49
				end -- 49
			end -- 49
		end -- 49
		return flatChildren, false -- 53
	end -- 30
	function React.createElement(typeName, props, ...) -- 62
		local children = {...} -- 62
		local items = {} -- 67
		for ____, v in pairs(children) do -- 68
			items[#items + 1] = v -- 69
		end -- 69
		children = items -- 71
		repeat -- 71
			local ____switch15 = type(typeName) -- 71
			local ____cond15 = ____switch15 == "function" -- 71
			if ____cond15 then -- 71
				do -- 71
					if props == nil then -- 71
						props = {} -- 74
					end -- 74
					if props.children then -- 74
						local ____props_1 = props -- 76
						local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 76
						__TS__SparseArrayPush( -- 76
							____array_0, -- 76
							table.unpack(children) -- 76
						) -- 76
						____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 76
					else -- 76
						props.children = children -- 78
					end -- 78
					return renderFunctionComponent(typeName, props) -- 80
				end -- 80
			end -- 80
			____cond15 = ____cond15 or ____switch15 == "table" -- 80
			if ____cond15 then -- 80
				do -- 80
					if not typeName.isComponent then -- 80
						Warn("unsupported class object in element creation") -- 84
						return {} -- 85
					end -- 85
					if props == nil then -- 85
						props = {} -- 87
					end -- 87
					if props.children then -- 87
						local ____props_3 = props -- 89
						local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 89
						__TS__SparseArrayPush( -- 89
							____array_2, -- 89
							table.unpack(children) -- 89
						) -- 89
						____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 89
					else -- 89
						props.children = children -- 91
					end -- 91
					local inst = __TS__New(typeName, props) -- 93
					return inst:render() -- 94
				end -- 94
			end -- 94
			do -- 94
				do -- 94
					if props and props.children then -- 94
						local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 94
						__TS__SparseArrayPush( -- 94
							____array_4, -- 94
							table.unpack(children) -- 98
						) -- 98
						children = {__TS__SparseArraySpread(____array_4)} -- 98
						props.children = nil -- 99
					end -- 99
					local flatChildren = {} -- 101
					for i = 1, #children do -- 101
						local child, flat = flattenChild(children[i]) -- 103
						if flat then -- 103
							flatChildren[#flatChildren + 1] = child -- 105
						else -- 105
							for i = 1, #child do -- 105
								flatChildren[#flatChildren + 1] = child[i] -- 108
							end -- 108
						end -- 108
					end -- 108
					children = flatChildren -- 112
				end -- 112
			end -- 112
		until true -- 112
		if typeName == nil then -- 112
			return children -- 116
		end -- 116
		return {type = typeName, props = props or ({}), children = children} -- 118
	end -- 62
end -- 62
local function getNode(enode, cnode, attribHandler) -- 203
	cnode = cnode or Dora.Node() -- 204
	local jnode = enode.props -- 205
	local anchor -- 206
	local color3 -- 207
	for k, v in pairs(enode.props) do -- 208
		repeat -- 208
			local ____switch42 = k -- 208
			local ____cond42 = ____switch42 == "ref" -- 208
			if ____cond42 then -- 208
				v.current = cnode -- 210
				break -- 210
			end -- 210
			____cond42 = ____cond42 or ____switch42 == "anchorX" -- 210
			if ____cond42 then -- 210
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 211
				break -- 211
			end -- 211
			____cond42 = ____cond42 or ____switch42 == "anchorY" -- 211
			if ____cond42 then -- 211
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 212
				break -- 212
			end -- 212
			____cond42 = ____cond42 or ____switch42 == "color3" -- 212
			if ____cond42 then -- 212
				color3 = Dora.Color3(v) -- 213
				break -- 213
			end -- 213
			____cond42 = ____cond42 or ____switch42 == "transformTarget" -- 213
			if ____cond42 then -- 213
				cnode.transformTarget = v.current -- 214
				break -- 214
			end -- 214
			____cond42 = ____cond42 or ____switch42 == "onUpdate" -- 214
			if ____cond42 then -- 214
				cnode:schedule(v) -- 215
				break -- 215
			end -- 215
			____cond42 = ____cond42 or ____switch42 == "onRender" -- 215
			if ____cond42 then -- 215
				patchRenderProp(cnode, v) -- 216
				break -- 216
			end -- 216
			____cond42 = ____cond42 or ____switch42 == "onActionEnd" -- 216
			if ____cond42 then -- 216
				cnode:slot("ActionEnd", v) -- 217
				break -- 217
			end -- 217
			____cond42 = ____cond42 or ____switch42 == "onTapFilter" -- 217
			if ____cond42 then -- 217
				cnode:slot("TapFilter", v) -- 218
				break -- 218
			end -- 218
			____cond42 = ____cond42 or ____switch42 == "onTapBegan" -- 218
			if ____cond42 then -- 218
				cnode:slot("TapBegan", v) -- 219
				break -- 219
			end -- 219
			____cond42 = ____cond42 or ____switch42 == "onTapEnded" -- 219
			if ____cond42 then -- 219
				cnode:slot("TapEnded", v) -- 220
				break -- 220
			end -- 220
			____cond42 = ____cond42 or ____switch42 == "onTapped" -- 220
			if ____cond42 then -- 220
				cnode:slot("Tapped", v) -- 221
				break -- 221
			end -- 221
			____cond42 = ____cond42 or ____switch42 == "onTapMoved" -- 221
			if ____cond42 then -- 221
				cnode:slot("TapMoved", v) -- 222
				break -- 222
			end -- 222
			____cond42 = ____cond42 or ____switch42 == "onMouseMove" -- 222
			if ____cond42 then -- 222
				cnode:slot("MouseMove", v) -- 223
				break -- 223
			end -- 223
			____cond42 = ____cond42 or ____switch42 == "onMouseWheel" -- 223
			if ____cond42 then -- 223
				cnode:slot("MouseWheel", v) -- 224
				break -- 224
			end -- 224
			____cond42 = ____cond42 or ____switch42 == "onGesture" -- 224
			if ____cond42 then -- 224
				cnode:slot("Gesture", v) -- 225
				break -- 225
			end -- 225
			____cond42 = ____cond42 or ____switch42 == "onEnter" -- 225
			if ____cond42 then -- 225
				cnode:slot("Enter", v) -- 226
				break -- 226
			end -- 226
			____cond42 = ____cond42 or ____switch42 == "onExit" -- 226
			if ____cond42 then -- 226
				cnode:slot("Exit", v) -- 227
				break -- 227
			end -- 227
			____cond42 = ____cond42 or ____switch42 == "onCleanup" -- 227
			if ____cond42 then -- 227
				cnode:slot("Cleanup", v) -- 228
				break -- 228
			end -- 228
			____cond42 = ____cond42 or ____switch42 == "onUnmount" -- 228
			if ____cond42 then -- 228
				break -- 229
			end -- 229
			____cond42 = ____cond42 or ____switch42 == "onKeyDown" -- 229
			if ____cond42 then -- 229
				cnode:slot("KeyDown", v) -- 230
				break -- 230
			end -- 230
			____cond42 = ____cond42 or ____switch42 == "onKeyUp" -- 230
			if ____cond42 then -- 230
				cnode:slot("KeyUp", v) -- 231
				break -- 231
			end -- 231
			____cond42 = ____cond42 or ____switch42 == "onKeyPressed" -- 231
			if ____cond42 then -- 231
				cnode:slot("KeyPressed", v) -- 232
				break -- 232
			end -- 232
			____cond42 = ____cond42 or ____switch42 == "onAttachIME" -- 232
			if ____cond42 then -- 232
				cnode:slot("AttachIME", v) -- 233
				break -- 233
			end -- 233
			____cond42 = ____cond42 or ____switch42 == "onDetachIME" -- 233
			if ____cond42 then -- 233
				cnode:slot("DetachIME", v) -- 234
				break -- 234
			end -- 234
			____cond42 = ____cond42 or ____switch42 == "onTextInput" -- 234
			if ____cond42 then -- 234
				cnode:slot("TextInput", v) -- 235
				break -- 235
			end -- 235
			____cond42 = ____cond42 or ____switch42 == "onTextEditing" -- 235
			if ____cond42 then -- 235
				cnode:slot("TextEditing", v) -- 236
				break -- 236
			end -- 236
			____cond42 = ____cond42 or ____switch42 == "onButtonDown" -- 236
			if ____cond42 then -- 236
				cnode:slot("ButtonDown", v) -- 237
				break -- 237
			end -- 237
			____cond42 = ____cond42 or ____switch42 == "onButtonUp" -- 237
			if ____cond42 then -- 237
				cnode:slot("ButtonUp", v) -- 238
				break -- 238
			end -- 238
			____cond42 = ____cond42 or ____switch42 == "onAxis" -- 238
			if ____cond42 then -- 238
				cnode:slot("Axis", v) -- 239
				break -- 239
			end -- 239
			do -- 239
				do -- 239
					if attribHandler then -- 239
						if not attribHandler(cnode, enode, k, v) then -- 239
							cnode[k] = v -- 243
						end -- 243
					else -- 243
						cnode[k] = v -- 246
					end -- 246
					break -- 248
				end -- 248
			end -- 248
		until true -- 248
	end -- 248
	applyAutoEnableProps(cnode, enode.props) -- 252
	if anchor ~= nil then -- 252
		cnode.anchor = anchor -- 253
	end -- 253
	if color3 ~= nil then -- 253
		cnode.color3 = color3 -- 254
	end -- 254
	if jnode.onMount ~= nil then -- 254
		jnode.onMount(cnode) -- 256
	end -- 256
	return cnode -- 258
end -- 203
local getClipNode -- 261
do -- 261
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 263
		repeat -- 263
			local ____switch52 = k -- 263
			local ____cond52 = ____switch52 == "stencil" -- 263
			if ____cond52 then -- 263
				cnode.stencil = ____exports.toNode(v) -- 270
				return true -- 270
			end -- 270
		until true -- 270
		return false -- 272
	end -- 263
	getClipNode = function(enode) -- 274
		return getNode( -- 275
			enode, -- 275
			Dora.ClipNode(), -- 275
			handleClipNodeAttribute -- 275
		) -- 275
	end -- 274
end -- 274
local getPlayable -- 279
local getDragonBone -- 280
local getSpine -- 281
local getModel -- 282
do -- 282
	local function handlePlayableAttribute(cnode, enode, k, v) -- 284
		repeat -- 284
			local ____switch56 = k -- 284
			local ____cond56 = ____switch56 == "file" -- 284
			if ____cond56 then -- 284
				return true -- 286
			end -- 286
			____cond56 = ____cond56 or ____switch56 == "play" -- 286
			if ____cond56 then -- 286
				cnode:play(v, enode.props.loop == true) -- 287
				return true -- 287
			end -- 287
			____cond56 = ____cond56 or ____switch56 == "loop" -- 287
			if ____cond56 then -- 287
				return true -- 288
			end -- 288
			____cond56 = ____cond56 or ____switch56 == "onAnimationEnd" -- 288
			if ____cond56 then -- 288
				cnode:slot("AnimationEnd", v) -- 289
				return true -- 289
			end -- 289
		until true -- 289
		return false -- 291
	end -- 284
	getPlayable = function(enode, cnode, attribHandler) -- 293
		if attribHandler == nil then -- 293
			attribHandler = handlePlayableAttribute -- 294
		end -- 294
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 295
		if cnode ~= nil then -- 295
			return getNode(enode, cnode, attribHandler) -- 297
		end -- 297
		return nil -- 299
	end -- 293
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 302
		repeat -- 302
			local ____switch60 = k -- 302
			local ____cond60 = ____switch60 == "hitTestEnabled" -- 302
			if ____cond60 then -- 302
				cnode.hitTestEnabled = true -- 304
				return true -- 304
			end -- 304
		until true -- 304
		return handlePlayableAttribute(cnode, enode, k, v) -- 306
	end -- 302
	getDragonBone = function(enode) -- 308
		local node = Dora.DragonBone(enode.props.file) -- 309
		if node ~= nil then -- 309
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 311
			return cnode -- 312
		end -- 312
		return nil -- 314
	end -- 308
	local function handleSpineAttribute(cnode, enode, k, v) -- 317
		repeat -- 317
			local ____switch64 = k -- 317
			local ____cond64 = ____switch64 == "hitTestEnabled" -- 317
			if ____cond64 then -- 317
				cnode.hitTestEnabled = true -- 319
				return true -- 319
			end -- 319
		until true -- 319
		return handlePlayableAttribute(cnode, enode, k, v) -- 321
	end -- 317
	getSpine = function(enode) -- 323
		local node = Dora.Spine(enode.props.file) -- 324
		if node ~= nil then -- 324
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 326
			return cnode -- 327
		end -- 327
		return nil -- 329
	end -- 323
	local function handleModelAttribute(cnode, enode, k, v) -- 332
		repeat -- 332
			local ____switch68 = k -- 332
			local ____cond68 = ____switch68 == "reversed" -- 332
			if ____cond68 then -- 332
				cnode.reversed = v -- 334
				return true -- 334
			end -- 334
		until true -- 334
		return handlePlayableAttribute(cnode, enode, k, v) -- 336
	end -- 332
	getModel = function(enode) -- 338
		local node = Dora.Model(enode.props.file) -- 339
		if node ~= nil then -- 339
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 341
			return cnode -- 342
		end -- 342
		return nil -- 344
	end -- 338
end -- 338
local getDrawNode -- 348
do -- 348
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 350
		repeat -- 350
			local ____switch73 = k -- 350
			local ____cond73 = ____switch73 == "depthWrite" -- 350
			if ____cond73 then -- 350
				cnode.depthWrite = v -- 352
				return true -- 352
			end -- 352
			____cond73 = ____cond73 or ____switch73 == "blendFunc" -- 352
			if ____cond73 then -- 352
				cnode.blendFunc = v -- 353
				return true -- 353
			end -- 353
		until true -- 353
		return false -- 355
	end -- 350
	getDrawNode = function(enode) -- 357
		local node = Dora.DrawNode() -- 358
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 359
		local ____enode_7 = enode -- 360
		local children = ____enode_7.children -- 360
		for i = 1, #children do -- 360
			do -- 360
				local child = children[i] -- 362
				if type(child) ~= "table" then -- 362
					goto __continue75 -- 364
				end -- 364
				repeat -- 364
					local ____switch77 = child.type -- 364
					local ____cond77 = ____switch77 == "dot-shape" -- 364
					if ____cond77 then -- 364
						do -- 364
							local dot = child.props -- 368
							node:drawDot( -- 369
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 370
								dot.radius, -- 371
								Dora.Color(dot.color or 4294967295) -- 372
							) -- 372
							break -- 374
						end -- 374
					end -- 374
					____cond77 = ____cond77 or ____switch77 == "segment-shape" -- 374
					if ____cond77 then -- 374
						do -- 374
							local segment = child.props -- 377
							node:drawSegment( -- 378
								Dora.Vec2(segment.startX, segment.startY), -- 379
								Dora.Vec2(segment.stopX, segment.stopY), -- 380
								segment.radius, -- 381
								Dora.Color(segment.color or 4294967295) -- 382
							) -- 382
							break -- 384
						end -- 384
					end -- 384
					____cond77 = ____cond77 or ____switch77 == "circle-shape" -- 384
					if ____cond77 then -- 384
						do -- 384
							local circle = child.props -- 387
							node:drawCircle( -- 388
								Dora.Vec2(circle.centerX or 0, circle.centerY or 0), -- 388
								circle.radius, -- 388
								Dora.Color(circle.color or 4294967295) -- 388
							) -- 388
							break -- 389
						end -- 389
					end -- 389
					____cond77 = ____cond77 or ____switch77 == "ellipse-shape" -- 389
					if ____cond77 then -- 389
						do -- 389
							local ellipse = child.props -- 392
							node:drawEllipse( -- 393
								Dora.Vec2(ellipse.centerX or 0, ellipse.centerY or 0), -- 393
								ellipse.radiusX, -- 393
								ellipse.radiusY, -- 393
								Dora.Color(ellipse.color or 4294967295) -- 393
							) -- 393
							break -- 394
						end -- 394
					end -- 394
					____cond77 = ____cond77 or (____switch77 == "rect-shape" or ____switch77 == "rounded-rect-shape") -- 394
					if ____cond77 then -- 394
						do -- 394
							local rect = child.props -- 398
							local bounds = Dora.Rect((rect.centerX or 0) - rect.width / 2, (rect.centerY or 0) - rect.height / 2, rect.width, rect.height) -- 399
							local fill = Dora.Color(rect.fillColor or 4294967295) -- 400
							local border = Dora.Color(rect.borderColor or 4294967295) -- 401
							if child.type == "rounded-rect-shape" then -- 401
								node:drawRoundedRect( -- 403
									bounds, -- 403
									child.props.cornerRadius, -- 403
									fill, -- 403
									rect.borderWidth or 0, -- 403
									border -- 403
								) -- 403
							else -- 403
								node:drawRect(bounds, fill, rect.borderWidth or 0, border) -- 405
							end -- 405
							break -- 407
						end -- 407
					end -- 407
					____cond77 = ____cond77 or ____switch77 == "ring-shape" -- 407
					if ____cond77 then -- 407
						do -- 407
							local ring = child.props -- 410
							node:drawRing( -- 411
								Dora.Vec2(ring.centerX or 0, ring.centerY or 0), -- 411
								ring.innerRadius, -- 411
								ring.outerRadius, -- 411
								Dora.Color(ring.fillColor or 4294967295), -- 412
								ring.borderWidth or 0, -- 412
								Dora.Color(ring.borderColor or 4294967295) -- 412
							) -- 412
							break -- 413
						end -- 413
					end -- 413
					____cond77 = ____cond77 or ____switch77 == "sector-shape" -- 413
					if ____cond77 then -- 413
						do -- 413
							local sector = child.props -- 416
							node:drawSector( -- 417
								Dora.Vec2(sector.centerX or 0, sector.centerY or 0), -- 417
								sector.radius, -- 417
								sector.startAngle, -- 417
								sector.endAngle, -- 417
								Dora.Color(sector.fillColor or 4294967295), -- 418
								sector.borderWidth or 0, -- 418
								Dora.Color(sector.borderColor or 4294967295) -- 418
							) -- 418
							break -- 419
						end -- 419
					end -- 419
					____cond77 = ____cond77 or ____switch77 == "polyline-shape" -- 419
					if ____cond77 then -- 419
						do -- 419
							local line = child.props -- 422
							local ____node_drawPolyline_10 = node.drawPolyline -- 423
							local ____array_9 = __TS__SparseArrayNew( -- 423
								line.verts, -- 423
								line.radius, -- 423
								Dora.Color(line.color or 4294967295) -- 423
							) -- 423
							local ____line_closed_8 = line.closed -- 423
							if ____line_closed_8 == nil then -- 423
								____line_closed_8 = false -- 423
							end -- 423
							__TS__SparseArrayPush(____array_9, ____line_closed_8) -- 423
							____node_drawPolyline_10( -- 423
								node, -- 423
								__TS__SparseArraySpread(____array_9) -- 423
							) -- 423
							break -- 424
						end -- 424
					end -- 424
					____cond77 = ____cond77 or ____switch77 == "arc-shape" -- 424
					if ____cond77 then -- 424
						do -- 424
							local arc = child.props -- 427
							node:drawArc( -- 428
								Dora.Vec2(arc.centerX or 0, arc.centerY or 0), -- 428
								arc.radius, -- 428
								arc.startAngle, -- 428
								arc.endAngle, -- 428
								arc.lineRadius, -- 428
								Dora.Color(arc.color or 4294967295) -- 428
							) -- 428
							break -- 429
						end -- 429
					end -- 429
					____cond77 = ____cond77 or ____switch77 == "quadratic-bezier-shape" -- 429
					if ____cond77 then -- 429
						do -- 429
							local curve = child.props -- 432
							node:drawQuadraticBezier( -- 433
								Dora.Vec2(curve.startX, curve.startY), -- 433
								Dora.Vec2(curve.controlX, curve.controlY), -- 433
								Dora.Vec2(curve.stopX, curve.stopY), -- 433
								curve.radius, -- 433
								Dora.Color(curve.color or 4294967295) -- 433
							) -- 433
							break -- 434
						end -- 434
					end -- 434
					____cond77 = ____cond77 or ____switch77 == "cubic-bezier-shape" -- 434
					if ____cond77 then -- 434
						do -- 434
							local curve = child.props -- 437
							node:drawCubicBezier( -- 438
								Dora.Vec2(curve.startX, curve.startY), -- 438
								Dora.Vec2(curve.control1X, curve.control1Y), -- 438
								Dora.Vec2(curve.control2X, curve.control2Y), -- 438
								Dora.Vec2(curve.stopX, curve.stopY), -- 438
								curve.radius, -- 438
								Dora.Color(curve.color or 4294967295) -- 438
							) -- 438
							break -- 439
						end -- 439
					end -- 439
					____cond77 = ____cond77 or ____switch77 == "polygon-shape" -- 439
					if ____cond77 then -- 439
						do -- 439
							local poly = child.props -- 442
							node:drawPolygon( -- 443
								poly.verts, -- 444
								Dora.Color(poly.fillColor or 4294967295), -- 445
								poly.borderWidth or 0, -- 446
								Dora.Color(poly.borderColor or 4294967295) -- 447
							) -- 447
							break -- 449
						end -- 449
					end -- 449
					____cond77 = ____cond77 or ____switch77 == "verts-shape" -- 449
					if ____cond77 then -- 449
						do -- 449
							local verts = child.props -- 452
							node:drawVertices(__TS__ArrayMap( -- 453
								verts.verts, -- 453
								function(____, ____bindingPattern0) -- 453
									local color -- 453
									local vert -- 453
									vert = ____bindingPattern0[1] -- 453
									color = ____bindingPattern0[2] -- 453
									return { -- 453
										vert, -- 453
										Dora.Color(color) -- 453
									} -- 453
								end -- 453
							)) -- 453
							break -- 454
						end -- 454
					end -- 454
				until true -- 454
			end -- 454
			::__continue75:: -- 454
		end -- 454
		return cnode -- 458
	end -- 357
end -- 357
local getGrid -- 462
do -- 462
	local function handleGridAttribute(cnode, _enode, k, v) -- 464
		repeat -- 464
			local ____switch96 = k -- 464
			local ____cond96 = ____switch96 == "file" or ____switch96 == "gridX" or ____switch96 == "gridY" -- 464
			if ____cond96 then -- 464
				return true -- 466
			end -- 466
			____cond96 = ____cond96 or ____switch96 == "textureRect" -- 466
			if ____cond96 then -- 466
				cnode.textureRect = v -- 467
				return true -- 467
			end -- 467
			____cond96 = ____cond96 or ____switch96 == "depthWrite" -- 467
			if ____cond96 then -- 467
				cnode.depthWrite = v -- 468
				return true -- 468
			end -- 468
			____cond96 = ____cond96 or ____switch96 == "blendFunc" -- 468
			if ____cond96 then -- 468
				cnode.blendFunc = v -- 469
				return true -- 469
			end -- 469
			____cond96 = ____cond96 or ____switch96 == "effect" -- 469
			if ____cond96 then -- 469
				cnode.effect = v -- 470
				return true -- 470
			end -- 470
		until true -- 470
		return false -- 472
	end -- 464
	getGrid = function(enode) -- 474
		local grid = enode.props -- 475
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 476
		local cnode = getNode(enode, node, handleGridAttribute) -- 477
		return cnode -- 478
	end -- 474
end -- 474
local getSprite -- 482
local getVideoNode -- 483
local getTIC80Node -- 484
do -- 484
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 486
		repeat -- 486
			local ____switch100 = k -- 486
			local ____cond100 = ____switch100 == "file" -- 486
			if ____cond100 then -- 486
				return true -- 488
			end -- 488
			____cond100 = ____cond100 or ____switch100 == "textureRect" -- 488
			if ____cond100 then -- 488
				cnode.textureRect = v -- 489
				return true -- 489
			end -- 489
			____cond100 = ____cond100 or ____switch100 == "depthWrite" -- 489
			if ____cond100 then -- 489
				cnode.depthWrite = v -- 490
				return true -- 490
			end -- 490
			____cond100 = ____cond100 or ____switch100 == "blendFunc" -- 490
			if ____cond100 then -- 490
				cnode.blendFunc = v -- 491
				return true -- 491
			end -- 491
			____cond100 = ____cond100 or ____switch100 == "effect" -- 491
			if ____cond100 then -- 491
				cnode.effect = v -- 492
				return true -- 492
			end -- 492
			____cond100 = ____cond100 or ____switch100 == "alphaRef" -- 492
			if ____cond100 then -- 492
				cnode.alphaRef = v -- 493
				return true -- 493
			end -- 493
			____cond100 = ____cond100 or ____switch100 == "uwrap" -- 493
			if ____cond100 then -- 493
				cnode.uwrap = v -- 494
				return true -- 494
			end -- 494
			____cond100 = ____cond100 or ____switch100 == "vwrap" -- 494
			if ____cond100 then -- 494
				cnode.vwrap = v -- 495
				return true -- 495
			end -- 495
			____cond100 = ____cond100 or ____switch100 == "filter" -- 495
			if ____cond100 then -- 495
				cnode.filter = v -- 496
				return true -- 496
			end -- 496
		until true -- 496
		return false -- 498
	end -- 486
	getSprite = function(enode) -- 500
		local sp = enode.props -- 501
		if sp.file then -- 501
			local node = Dora.Sprite(sp.file) -- 503
			if node ~= nil then -- 503
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 505
				return cnode -- 506
			end -- 506
		else -- 506
			local node = Dora.Sprite() -- 509
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 510
			return cnode -- 511
		end -- 511
		return nil -- 513
	end -- 500
	local function handleVideoAttribute(cnode, enode, k, v) -- 515
		if k == "onVideoEnd" then -- 515
			cnode:onVideoEnd(v) -- 517
			return true -- 518
		end -- 518
		return handleSpriteAttribute(cnode, enode, k, v) -- 520
	end -- 515
	getVideoNode = function(enode) -- 522
		local vn = enode.props -- 523
		local ____Dora_VideoNode_13 = Dora.VideoNode -- 524
		local ____vn_file_12 = vn.file -- 524
		local ____vn_looped_11 = vn.looped -- 524
		if ____vn_looped_11 == nil then -- 524
			____vn_looped_11 = false -- 524
		end -- 524
		local node = ____Dora_VideoNode_13(____vn_file_12, ____vn_looped_11) -- 524
		if node ~= nil then -- 524
			local cnode = getNode(enode, node, handleVideoAttribute) -- 526
			return cnode -- 527
		end -- 527
		return nil -- 529
	end -- 522
	getTIC80Node = function(enode) -- 531
		local tic = enode.props -- 532
		local node = Dora.TIC80Node(tic.file) -- 533
		if node ~= nil then -- 533
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 535
			return cnode -- 536
		end -- 536
		return nil -- 538
	end -- 531
end -- 531
local getAudioSource -- 542
do -- 542
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 544
		repeat -- 544
			local ____switch113 = k -- 544
			local ____cond113 = ____switch113 == "file" -- 544
			if ____cond113 then -- 544
				return true -- 546
			end -- 546
			____cond113 = ____cond113 or ____switch113 == "autoRemove" -- 546
			if ____cond113 then -- 546
				return true -- 547
			end -- 547
			____cond113 = ____cond113 or ____switch113 == "bus" -- 547
			if ____cond113 then -- 547
				return true -- 548
			end -- 548
			____cond113 = ____cond113 or ____switch113 == "volume" -- 548
			if ____cond113 then -- 548
				cnode.volume = v -- 549
				return true -- 549
			end -- 549
			____cond113 = ____cond113 or ____switch113 == "pan" -- 549
			if ____cond113 then -- 549
				cnode.pan = v -- 550
				return true -- 550
			end -- 550
			____cond113 = ____cond113 or ____switch113 == "looping" -- 550
			if ____cond113 then -- 550
				cnode.looping = v -- 551
				return true -- 551
			end -- 551
			____cond113 = ____cond113 or ____switch113 == "playMode" -- 551
			if ____cond113 then -- 551
				do -- 551
					local aus = enode.props -- 553
					repeat -- 553
						local ____switch115 = v -- 553
						local ____cond115 = ____switch115 == "normal" -- 553
						if ____cond115 then -- 553
							cnode:play(aus.delayTime or 0) -- 555
							break -- 555
						end -- 555
						____cond115 = ____cond115 or ____switch115 == "background" -- 555
						if ____cond115 then -- 555
							cnode:playBackground() -- 556
							break -- 556
						end -- 556
						____cond115 = ____cond115 or ____switch115 == "3D" -- 556
						if ____cond115 then -- 556
							cnode:play3D(aus.delayTime or 0) -- 557
							break -- 557
						end -- 557
					until true -- 557
					return true -- 559
				end -- 559
			end -- 559
			____cond113 = ____cond113 or ____switch113 == "delayTime" -- 559
			if ____cond113 then -- 559
				return true -- 561
			end -- 561
			____cond113 = ____cond113 or ____switch113 == "protected" -- 561
			if ____cond113 then -- 561
				cnode:setProtected(v) -- 562
				return true -- 562
			end -- 562
			____cond113 = ____cond113 or ____switch113 == "loopPoint" -- 562
			if ____cond113 then -- 562
				cnode:setLoopPoint(v) -- 563
				return true -- 563
			end -- 563
			____cond113 = ____cond113 or ____switch113 == "velocity" -- 563
			if ____cond113 then -- 563
				do -- 563
					local vx, vy, vz = table.unpack(v, 1, 3) -- 565
					cnode:setVelocity(vx, vy, vz) -- 566
					return true -- 567
				end -- 567
			end -- 567
			____cond113 = ____cond113 or ____switch113 == "minMaxDistance" -- 567
			if ____cond113 then -- 567
				do -- 567
					local min, max = table.unpack(v, 1, 2) -- 570
					cnode:setMinMaxDistance(min, max) -- 571
					return true -- 572
				end -- 572
			end -- 572
			____cond113 = ____cond113 or ____switch113 == "attenuation" -- 572
			if ____cond113 then -- 572
				do -- 572
					local model, factor = table.unpack(v, 1, 2) -- 575
					cnode:setAttenuation(model, factor) -- 576
					return true -- 577
				end -- 577
			end -- 577
			____cond113 = ____cond113 or ____switch113 == "dopplerFactor" -- 577
			if ____cond113 then -- 577
				cnode:setDopplerFactor(v) -- 579
				return true -- 579
			end -- 579
		until true -- 579
		return false -- 581
	end -- 544
	getAudioSource = function(enode) -- 583
		local aus = enode.props -- 584
		local ____aus_autoRemove_14 = aus.autoRemove -- 585
		if ____aus_autoRemove_14 == nil then -- 585
			____aus_autoRemove_14 = true -- 585
		end -- 585
		local autoRemove = ____aus_autoRemove_14 -- 585
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 586
		if node ~= nil then -- 586
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 588
			return cnode -- 589
		end -- 589
		return nil -- 591
	end -- 583
end -- 583
local getLabel -- 595
do -- 595
	local function handleLabelAttribute(cnode, _enode, k, v) -- 597
		repeat -- 597
			local ____switch123 = k -- 597
			local ____cond123 = ____switch123 == "fontName" or ____switch123 == "fontSize" or ____switch123 == "text" or ____switch123 == "smoothLower" or ____switch123 == "smoothUpper" -- 597
			if ____cond123 then -- 597
				return true -- 599
			end -- 599
			____cond123 = ____cond123 or ____switch123 == "alphaRef" -- 599
			if ____cond123 then -- 599
				cnode.alphaRef = v -- 600
				return true -- 600
			end -- 600
			____cond123 = ____cond123 or ____switch123 == "textWidth" -- 600
			if ____cond123 then -- 600
				cnode.textWidth = v -- 601
				return true -- 601
			end -- 601
			____cond123 = ____cond123 or ____switch123 == "lineGap" -- 601
			if ____cond123 then -- 601
				cnode.lineGap = v -- 602
				return true -- 602
			end -- 602
			____cond123 = ____cond123 or ____switch123 == "spacing" -- 602
			if ____cond123 then -- 602
				cnode.spacing = v -- 603
				return true -- 603
			end -- 603
			____cond123 = ____cond123 or ____switch123 == "outlineColor" -- 603
			if ____cond123 then -- 603
				cnode.outlineColor = Dora.Color(v) -- 604
				return true -- 604
			end -- 604
			____cond123 = ____cond123 or ____switch123 == "outlineWidth" -- 604
			if ____cond123 then -- 604
				cnode.outlineWidth = v -- 605
				return true -- 605
			end -- 605
			____cond123 = ____cond123 or ____switch123 == "blendFunc" -- 605
			if ____cond123 then -- 605
				cnode.blendFunc = v -- 606
				return true -- 606
			end -- 606
			____cond123 = ____cond123 or ____switch123 == "depthWrite" -- 606
			if ____cond123 then -- 606
				cnode.depthWrite = v -- 607
				return true -- 607
			end -- 607
			____cond123 = ____cond123 or ____switch123 == "batched" -- 607
			if ____cond123 then -- 607
				cnode.batched = v -- 608
				return true -- 608
			end -- 608
			____cond123 = ____cond123 or ____switch123 == "effect" -- 608
			if ____cond123 then -- 608
				cnode.effect = v -- 609
				return true -- 609
			end -- 609
			____cond123 = ____cond123 or ____switch123 == "alignment" -- 609
			if ____cond123 then -- 609
				cnode.alignment = v -- 610
				return true -- 610
			end -- 610
		until true -- 610
		return false -- 612
	end -- 597
	getLabel = function(enode) -- 614
		local label = enode.props -- 615
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf ~= false) -- 616
		if node ~= nil then -- 616
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 616
				local ____node_smooth_15 = node.smooth -- 619
				local x = ____node_smooth_15.x -- 619
				local y = ____node_smooth_15.y -- 619
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 620
			end -- 620
			local cnode = getNode(enode, node, handleLabelAttribute) -- 622
			local ____enode_16 = enode -- 623
			local children = ____enode_16.children -- 623
			local text = label.text or "" -- 624
			for i = 1, #children do -- 624
				local child = children[i] -- 626
				if type(child) ~= "table" then -- 626
					text = text .. tostring(child) -- 628
				end -- 628
			end -- 628
			node.text = text -- 631
			return cnode -- 632
		end -- 632
		return nil -- 634
	end -- 614
end -- 614
local getLine -- 638
do -- 638
	local function handleLineAttribute(cnode, enode, k, v) -- 640
		local line = enode.props -- 641
		repeat -- 641
			local ____switch131 = k -- 641
			local ____cond131 = ____switch131 == "verts" -- 641
			if ____cond131 then -- 641
				cnode:set( -- 643
					v, -- 643
					Dora.Color(line.lineColor or 4294967295) -- 643
				) -- 643
				return true -- 643
			end -- 643
			____cond131 = ____cond131 or ____switch131 == "depthWrite" -- 643
			if ____cond131 then -- 643
				cnode.depthWrite = v -- 644
				return true -- 644
			end -- 644
			____cond131 = ____cond131 or ____switch131 == "blendFunc" -- 644
			if ____cond131 then -- 644
				cnode.blendFunc = v -- 645
				return true -- 645
			end -- 645
		until true -- 645
		return false -- 647
	end -- 640
	getLine = function(enode) -- 649
		local node = Dora.Line() -- 650
		local cnode = getNode(enode, node, handleLineAttribute) -- 651
		return cnode -- 652
	end -- 649
end -- 649
local getParticle -- 656
do -- 656
	local function handleParticleAttribute(cnode, _enode, k, v) -- 658
		repeat -- 658
			local ____switch135 = k -- 658
			local ____cond135 = ____switch135 == "file" -- 658
			if ____cond135 then -- 658
				return true -- 660
			end -- 660
			____cond135 = ____cond135 or ____switch135 == "emit" -- 660
			if ____cond135 then -- 660
				if v then -- 660
					cnode:start() -- 661
				end -- 661
				return true -- 661
			end -- 661
			____cond135 = ____cond135 or ____switch135 == "onFinished" -- 661
			if ____cond135 then -- 661
				cnode:slot("Finished", v) -- 662
				return true -- 662
			end -- 662
		until true -- 662
		return false -- 664
	end -- 658
	getParticle = function(enode) -- 666
		local particle = enode.props -- 667
		local node = Dora.Particle(particle.file) -- 668
		if node ~= nil then -- 668
			local cnode = getNode(enode, node, handleParticleAttribute) -- 670
			return cnode -- 671
		end -- 671
		return nil -- 673
	end -- 666
end -- 666
local getMenu -- 677
do -- 677
	local function handleMenuAttribute(cnode, _enode, k, v) -- 679
		repeat -- 679
			local ____switch141 = k -- 679
			local ____cond141 = ____switch141 == "enabled" -- 679
			if ____cond141 then -- 679
				cnode.enabled = v -- 681
				return true -- 681
			end -- 681
		until true -- 681
		return false -- 683
	end -- 679
	getMenu = function(enode) -- 685
		local node = Dora.Menu() -- 686
		local cnode = getNode(enode, node, handleMenuAttribute) -- 687
		return cnode -- 688
	end -- 685
end -- 685
local function getPhysicsWorld(enode) -- 692
	local node = Dora.PhysicsWorld() -- 693
	local cnode = getNode(enode, node) -- 694
	return cnode -- 695
end -- 692
local getBody -- 698
do -- 698
	local function handleBodyAttribute(cnode, _enode, k, v) -- 700
		repeat -- 700
			local ____switch146 = k -- 700
			local ____cond146 = ____switch146 == "type" or ____switch146 == "linearAcceleration" or ____switch146 == "fixedRotation" or ____switch146 == "bullet" or ____switch146 == "world" -- 700
			if ____cond146 then -- 700
				return true -- 707
			end -- 707
			____cond146 = ____cond146 or ____switch146 == "velocityX" -- 707
			if ____cond146 then -- 707
				cnode.velocityX = v -- 708
				return true -- 708
			end -- 708
			____cond146 = ____cond146 or ____switch146 == "velocityY" -- 708
			if ____cond146 then -- 708
				cnode.velocityY = v -- 709
				return true -- 709
			end -- 709
			____cond146 = ____cond146 or ____switch146 == "angularRate" -- 709
			if ____cond146 then -- 709
				cnode.angularRate = v -- 710
				return true -- 710
			end -- 710
			____cond146 = ____cond146 or ____switch146 == "group" -- 710
			if ____cond146 then -- 710
				cnode.group = v -- 711
				return true -- 711
			end -- 711
			____cond146 = ____cond146 or ____switch146 == "linearDamping" -- 711
			if ____cond146 then -- 711
				cnode.linearDamping = v -- 712
				return true -- 712
			end -- 712
			____cond146 = ____cond146 or ____switch146 == "angularDamping" -- 712
			if ____cond146 then -- 712
				cnode.angularDamping = v -- 713
				return true -- 713
			end -- 713
			____cond146 = ____cond146 or ____switch146 == "owner" -- 713
			if ____cond146 then -- 713
				cnode.owner = v -- 714
				return true -- 714
			end -- 714
			____cond146 = ____cond146 or ____switch146 == "receivingContact" -- 714
			if ____cond146 then -- 714
				cnode.receivingContact = v -- 715
				return true -- 715
			end -- 715
			____cond146 = ____cond146 or ____switch146 == "onBodyEnter" -- 715
			if ____cond146 then -- 715
				cnode:slot("BodyEnter", v) -- 716
				return true -- 716
			end -- 716
			____cond146 = ____cond146 or ____switch146 == "onBodyLeave" -- 716
			if ____cond146 then -- 716
				cnode:slot("BodyLeave", v) -- 717
				return true -- 717
			end -- 717
			____cond146 = ____cond146 or ____switch146 == "onContactStart" -- 717
			if ____cond146 then -- 717
				cnode:slot("ContactStart", v) -- 718
				return true -- 718
			end -- 718
			____cond146 = ____cond146 or ____switch146 == "onContactEnd" -- 718
			if ____cond146 then -- 718
				cnode:slot("ContactEnd", v) -- 719
				return true -- 719
			end -- 719
			____cond146 = ____cond146 or ____switch146 == "onContactFilter" -- 719
			if ____cond146 then -- 719
				cnode:onContactFilter(v) -- 720
				return true -- 720
			end -- 720
		until true -- 720
		return false -- 722
	end -- 700
	getBody = function(enode, world) -- 724
		local def = enode.props -- 725
		local bodyDef = Dora.BodyDef() -- 726
		bodyDef.type = def.type -- 727
		if def.angle ~= nil then -- 727
			bodyDef.angle = def.angle -- 728
		end -- 728
		if def.angularDamping ~= nil then -- 728
			bodyDef.angularDamping = def.angularDamping -- 729
		end -- 729
		if def.bullet ~= nil then -- 729
			bodyDef.bullet = def.bullet -- 730
		end -- 730
		if def.fixedRotation ~= nil then -- 730
			bodyDef.fixedRotation = def.fixedRotation -- 731
		end -- 731
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 732
		if def.linearDamping ~= nil then -- 732
			bodyDef.linearDamping = def.linearDamping -- 733
		end -- 733
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 734
		local extraSensors -- 735
		for i = 1, #enode.children do -- 735
			do -- 735
				local child = enode.children[i] -- 737
				if type(child) ~= "table" then -- 737
					goto __continue153 -- 739
				end -- 739
				repeat -- 739
					local ____switch155 = child.type -- 739
					local ____cond155 = ____switch155 == "rect-fixture" -- 739
					if ____cond155 then -- 739
						do -- 739
							local shape = child.props -- 743
							if shape.sensorTag ~= nil then -- 743
								bodyDef:attachPolygonSensor( -- 745
									shape.sensorTag, -- 746
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 747
									shape.width, -- 748
									shape.height, -- 748
									shape.angle or 0 -- 749
								) -- 749
							else -- 749
								bodyDef:attachPolygon( -- 752
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 753
									shape.width, -- 754
									shape.height, -- 754
									shape.angle or 0, -- 755
									shape.density or 1, -- 756
									shape.friction or 0.4, -- 757
									shape.restitution or 0 -- 758
								) -- 758
							end -- 758
							break -- 761
						end -- 761
					end -- 761
					____cond155 = ____cond155 or ____switch155 == "polygon-fixture" -- 761
					if ____cond155 then -- 761
						do -- 761
							local shape = child.props -- 764
							if shape.sensorTag ~= nil then -- 764
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 766
							else -- 766
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 771
							end -- 771
							break -- 778
						end -- 778
					end -- 778
					____cond155 = ____cond155 or ____switch155 == "multi-fixture" -- 778
					if ____cond155 then -- 778
						do -- 778
							local shape = child.props -- 781
							if shape.sensorTag ~= nil then -- 781
								if extraSensors == nil then -- 781
									extraSensors = {} -- 783
								end -- 783
								extraSensors[#extraSensors + 1] = { -- 784
									shape.sensorTag, -- 784
									Dora.BodyDef:multi(shape.verts) -- 784
								} -- 784
							else -- 784
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 786
							end -- 786
							break -- 793
						end -- 793
					end -- 793
					____cond155 = ____cond155 or ____switch155 == "disk-fixture" -- 793
					if ____cond155 then -- 793
						do -- 793
							local shape = child.props -- 796
							if shape.sensorTag ~= nil then -- 796
								bodyDef:attachDiskSensor( -- 798
									shape.sensorTag, -- 799
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 800
									shape.radius -- 801
								) -- 801
							else -- 801
								bodyDef:attachDisk( -- 804
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 805
									shape.radius, -- 806
									shape.density or 1, -- 807
									shape.friction or 0.4, -- 808
									shape.restitution or 0 -- 809
								) -- 809
							end -- 809
							break -- 812
						end -- 812
					end -- 812
					____cond155 = ____cond155 or ____switch155 == "chain-fixture" -- 812
					if ____cond155 then -- 812
						do -- 812
							local shape = child.props -- 815
							if shape.sensorTag ~= nil then -- 815
								if extraSensors == nil then -- 815
									extraSensors = {} -- 817
								end -- 817
								extraSensors[#extraSensors + 1] = { -- 818
									shape.sensorTag, -- 818
									Dora.BodyDef:chain(shape.verts) -- 818
								} -- 818
							else -- 818
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 820
							end -- 820
							break -- 826
						end -- 826
					end -- 826
				until true -- 826
			end -- 826
			::__continue153:: -- 826
		end -- 826
		local body = Dora.Body(bodyDef, world) -- 830
		if extraSensors ~= nil then -- 830
			for i = 1, #extraSensors do -- 830
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 833
				body:attachSensor(tag, def) -- 834
			end -- 834
		end -- 834
		local cnode = getNode(enode, body, handleBodyAttribute) -- 837
		return cnode -- 838
	end -- 724
end -- 724
local getCustomNode -- 842
do -- 842
	local function handleCustomNode(_cnode, _enode, k, _v) -- 844
		repeat -- 844
			local ____switch175 = k -- 844
			local ____cond175 = ____switch175 == "onCreate" -- 844
			if ____cond175 then -- 844
				return true -- 846
			end -- 846
		until true -- 846
		return false -- 848
	end -- 844
	getCustomNode = function(enode) -- 850
		local custom = enode.props -- 851
		local node = custom.onCreate() -- 852
		if node then -- 852
			local cnode = getNode(enode, node, handleCustomNode) -- 854
			return cnode -- 855
		end -- 855
		return nil -- 857
	end -- 850
end -- 850
local getAlignNode -- 861
do -- 861
	local function handleAlignNode(_cnode, _enode, k, _v) -- 863
		repeat -- 863
			local ____switch180 = k -- 863
			local ____cond180 = ____switch180 == "windowRoot" -- 863
			if ____cond180 then -- 863
				return true -- 865
			end -- 865
			____cond180 = ____cond180 or ____switch180 == "style" -- 865
			if ____cond180 then -- 865
				return true -- 866
			end -- 866
			____cond180 = ____cond180 or ____switch180 == "onLayout" -- 866
			if ____cond180 then -- 866
				return true -- 867
			end -- 867
		until true -- 867
		return false -- 869
	end -- 863
	getAlignNode = function(enode) -- 871
		local alignNode = enode.props -- 872
		local node = Dora.AlignNode(alignNode.windowRoot) -- 873
		if alignNode.style then -- 873
			node:css(getAlignStyleText(alignNode.style)) -- 875
		end -- 875
		if alignNode.onLayout then -- 875
			node:onAlignLayout(alignNode.onLayout) -- 878
		end -- 878
		local cnode = getNode(enode, node, handleAlignNode) -- 880
		return cnode -- 881
	end -- 871
end -- 871
local function getEffekNode(enode) -- 885
	return getNode( -- 886
		enode, -- 886
		Dora.EffekNode() -- 886
	) -- 886
end -- 885
local getTileNode -- 889
do -- 889
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 891
		repeat -- 891
			local ____switch187 = k -- 891
			local ____cond187 = ____switch187 == "file" or ____switch187 == "layers" -- 891
			if ____cond187 then -- 891
				return true -- 893
			end -- 893
			____cond187 = ____cond187 or ____switch187 == "depthWrite" -- 893
			if ____cond187 then -- 893
				cnode.depthWrite = v -- 894
				return true -- 894
			end -- 894
			____cond187 = ____cond187 or ____switch187 == "blendFunc" -- 894
			if ____cond187 then -- 894
				cnode.blendFunc = v -- 895
				return true -- 895
			end -- 895
			____cond187 = ____cond187 or ____switch187 == "effect" -- 895
			if ____cond187 then -- 895
				cnode.effect = v -- 896
				return true -- 896
			end -- 896
			____cond187 = ____cond187 or ____switch187 == "filter" -- 896
			if ____cond187 then -- 896
				cnode.filter = v -- 897
				return true -- 897
			end -- 897
		until true -- 897
		return false -- 899
	end -- 891
	getTileNode = function(enode) -- 901
		local tn = enode.props -- 902
		local ____tn_layers_17 -- 903
		if tn.layers then -- 903
			____tn_layers_17 = Dora.TileNode(tn.file, tn.layers) -- 903
		else -- 903
			____tn_layers_17 = Dora.TileNode(tn.file) -- 903
		end -- 903
		local node = ____tn_layers_17 -- 903
		if node ~= nil then -- 903
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 905
			return cnode -- 906
		end -- 906
		return nil -- 908
	end -- 901
end -- 901
local function addChild(nodeStack, cnode, enode) -- 912
	if #nodeStack > 0 then -- 912
		local last = nodeStack[#nodeStack] -- 914
		last:addChild(cnode) -- 915
	end -- 915
	nodeStack[#nodeStack + 1] = cnode -- 917
	local ____enode_18 = enode -- 918
	local children = ____enode_18.children -- 918
	for i = 1, #children do -- 918
		visitNode(nodeStack, children[i], enode) -- 920
	end -- 920
	if #nodeStack > 1 then -- 920
		table.remove(nodeStack) -- 923
	end -- 923
end -- 912
local function drawNodeCheck(_nodeStack, enode, parent) -- 931
	if parent == nil or parent.type ~= "draw-node" then -- 931
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 933
	end -- 933
end -- 931
local function actionCheck(nodeStack, enode, parent) -- 994
	local unsupported = false -- 995
	if parent == nil then -- 995
		unsupported = true -- 997
	else -- 997
		repeat -- 997
			local ____switch212 = parent.type -- 997
			local ____cond212 = ____switch212 == "action" or ____switch212 == "spawn" or ____switch212 == "sequence" -- 997
			if ____cond212 then -- 997
				break -- 1000
			end -- 1000
			do -- 1000
				unsupported = true -- 1001
				break -- 1001
			end -- 1001
		until true -- 1001
	end -- 1001
	if unsupported then -- 1001
		if #nodeStack > 0 then -- 1001
			local node = nodeStack[#nodeStack] -- 1006
			local actionStack = {} -- 1007
			visitAction(actionStack, enode) -- 1008
			if #actionStack == 1 then -- 1008
				node:runAction(actionStack[1]) -- 1010
			end -- 1010
		else -- 1010
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 1013
		end -- 1013
	end -- 1013
end -- 994
local function bodyCheck(_nodeStack, enode, parent) -- 1018
	if parent == nil or parent.type ~= "body" then -- 1018
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 1020
	end -- 1020
end -- 1018
actionMap = { -- 1024
	["anchor-x"] = Dora.AnchorX, -- 1027
	["anchor-y"] = Dora.AnchorY, -- 1028
	angle = Dora.Angle, -- 1029
	["angle-x"] = Dora.AngleX, -- 1030
	["angle-y"] = Dora.AngleY, -- 1031
	width = Dora.Width, -- 1032
	height = Dora.Height, -- 1033
	opacity = Dora.Opacity, -- 1034
	roll = Dora.Roll, -- 1035
	scale = Dora.Scale, -- 1036
	["scale-x"] = Dora.ScaleX, -- 1037
	["scale-y"] = Dora.ScaleY, -- 1038
	["skew-x"] = Dora.SkewX, -- 1039
	["skew-y"] = Dora.SkewY, -- 1040
	["move-x"] = Dora.X, -- 1041
	["move-y"] = Dora.Y, -- 1042
	["move-z"] = Dora.Z -- 1043
} -- 1043
elementMap = { -- 1046
	node = function(nodeStack, enode, parent) -- 1047
		addChild( -- 1048
			nodeStack, -- 1048
			getNode(enode), -- 1048
			enode -- 1048
		) -- 1048
	end, -- 1047
	["clip-node"] = function(nodeStack, enode, parent) -- 1050
		addChild( -- 1051
			nodeStack, -- 1051
			getClipNode(enode), -- 1051
			enode -- 1051
		) -- 1051
	end, -- 1050
	playable = function(nodeStack, enode, parent) -- 1053
		local cnode = getPlayable(enode) -- 1054
		if cnode ~= nil then -- 1054
			addChild(nodeStack, cnode, enode) -- 1056
		end -- 1056
	end, -- 1053
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1059
		local cnode = getDragonBone(enode) -- 1060
		if cnode ~= nil then -- 1060
			addChild(nodeStack, cnode, enode) -- 1062
		end -- 1062
	end, -- 1059
	spine = function(nodeStack, enode, parent) -- 1065
		local cnode = getSpine(enode) -- 1066
		if cnode ~= nil then -- 1066
			addChild(nodeStack, cnode, enode) -- 1068
		end -- 1068
	end, -- 1065
	model = function(nodeStack, enode, parent) -- 1071
		local cnode = getModel(enode) -- 1072
		if cnode ~= nil then -- 1072
			addChild(nodeStack, cnode, enode) -- 1074
		end -- 1074
	end, -- 1071
	["draw-node"] = function(nodeStack, enode, parent) -- 1077
		addChild( -- 1078
			nodeStack, -- 1078
			getDrawNode(enode), -- 1078
			enode -- 1078
		) -- 1078
	end, -- 1077
	["dot-shape"] = drawNodeCheck, -- 1080
	["circle-shape"] = drawNodeCheck, -- 1081
	["ellipse-shape"] = drawNodeCheck, -- 1082
	["rounded-rect-shape"] = drawNodeCheck, -- 1083
	["ring-shape"] = drawNodeCheck, -- 1084
	["sector-shape"] = drawNodeCheck, -- 1085
	["polyline-shape"] = drawNodeCheck, -- 1086
	["arc-shape"] = drawNodeCheck, -- 1087
	["quadratic-bezier-shape"] = drawNodeCheck, -- 1088
	["cubic-bezier-shape"] = drawNodeCheck, -- 1089
	["segment-shape"] = drawNodeCheck, -- 1090
	["rect-shape"] = drawNodeCheck, -- 1091
	["polygon-shape"] = drawNodeCheck, -- 1092
	["verts-shape"] = drawNodeCheck, -- 1093
	grid = function(nodeStack, enode, parent) -- 1094
		addChild( -- 1095
			nodeStack, -- 1095
			getGrid(enode), -- 1095
			enode -- 1095
		) -- 1095
	end, -- 1094
	sprite = function(nodeStack, enode, parent) -- 1097
		local cnode = getSprite(enode) -- 1098
		if cnode ~= nil then -- 1098
			addChild(nodeStack, cnode, enode) -- 1100
		end -- 1100
	end, -- 1097
	["audio-source"] = function(nodeStack, enode, parent) -- 1103
		local cnode = getAudioSource(enode) -- 1104
		if cnode ~= nil then -- 1104
			addChild(nodeStack, cnode, enode) -- 1106
		end -- 1106
	end, -- 1103
	["video-node"] = function(nodeStack, enode, parent) -- 1109
		local cnode = getVideoNode(enode) -- 1110
		if cnode ~= nil then -- 1110
			addChild(nodeStack, cnode, enode) -- 1112
		end -- 1112
	end, -- 1109
	["tic80-node"] = function(nodeStack, enode, parent) -- 1115
		local cnode = getTIC80Node(enode) -- 1116
		if cnode ~= nil then -- 1116
			addChild(nodeStack, cnode, enode) -- 1118
		end -- 1118
	end, -- 1115
	label = function(nodeStack, enode, parent) -- 1121
		local cnode = getLabel(enode) -- 1122
		if cnode ~= nil then -- 1122
			addChild(nodeStack, cnode, enode) -- 1124
		end -- 1124
	end, -- 1121
	line = function(nodeStack, enode, parent) -- 1127
		addChild( -- 1128
			nodeStack, -- 1128
			getLine(enode), -- 1128
			enode -- 1128
		) -- 1128
	end, -- 1127
	particle = function(nodeStack, enode, parent) -- 1130
		local cnode = getParticle(enode) -- 1131
		if cnode ~= nil then -- 1131
			addChild(nodeStack, cnode, enode) -- 1133
		end -- 1133
	end, -- 1130
	menu = function(nodeStack, enode, parent) -- 1136
		addChild( -- 1137
			nodeStack, -- 1137
			getMenu(enode), -- 1137
			enode -- 1137
		) -- 1137
	end, -- 1136
	action = function(_nodeStack, enode, parent) -- 1139
		if #enode.children == 0 then -- 1139
			Warn("<action> tag has no children") -- 1141
			return -- 1142
		end -- 1142
		local action = enode.props -- 1144
		if action.ref == nil then -- 1144
			Warn("<action> tag has no ref") -- 1146
			return -- 1147
		end -- 1147
		local actionStack = {} -- 1149
		for i = 1, #enode.children do -- 1149
			visitAction(actionStack, enode.children[i]) -- 1151
		end -- 1151
		if #actionStack == 1 then -- 1151
			action.ref.current = actionStack[1] -- 1154
		elseif #actionStack > 1 then -- 1154
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1156
		end -- 1156
	end, -- 1139
	["anchor-x"] = actionCheck, -- 1159
	["anchor-y"] = actionCheck, -- 1160
	angle = actionCheck, -- 1161
	["angle-x"] = actionCheck, -- 1162
	["angle-y"] = actionCheck, -- 1163
	delay = actionCheck, -- 1164
	event = actionCheck, -- 1165
	width = actionCheck, -- 1166
	height = actionCheck, -- 1167
	hide = actionCheck, -- 1168
	show = actionCheck, -- 1169
	move = actionCheck, -- 1170
	opacity = actionCheck, -- 1171
	roll = actionCheck, -- 1172
	scale = actionCheck, -- 1173
	["scale-x"] = actionCheck, -- 1174
	["scale-y"] = actionCheck, -- 1175
	["skew-x"] = actionCheck, -- 1176
	["skew-y"] = actionCheck, -- 1177
	["move-x"] = actionCheck, -- 1178
	["move-y"] = actionCheck, -- 1179
	["move-z"] = actionCheck, -- 1180
	frame = actionCheck, -- 1181
	spawn = actionCheck, -- 1182
	sequence = actionCheck, -- 1183
	loop = function(nodeStack, enode, _parent) -- 1184
		if #nodeStack > 0 then -- 1184
			local node = nodeStack[#nodeStack] -- 1186
			local actionStack = {} -- 1187
			for i = 1, #enode.children do -- 1187
				visitAction(actionStack, enode.children[i]) -- 1189
			end -- 1189
			if #actionStack == 1 then -- 1189
				node:runAction(actionStack[1], true) -- 1192
			else -- 1192
				local loop = enode.props -- 1194
				if loop.spawn then -- 1194
					node:runAction( -- 1196
						Dora.Spawn(table.unpack(actionStack)), -- 1196
						true -- 1196
					) -- 1196
				else -- 1196
					node:runAction( -- 1198
						Dora.Sequence(table.unpack(actionStack)), -- 1198
						true -- 1198
					) -- 1198
				end -- 1198
			end -- 1198
		else -- 1198
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1202
		end -- 1202
	end, -- 1184
	["physics-world"] = function(nodeStack, enode, _parent) -- 1205
		addChild( -- 1206
			nodeStack, -- 1206
			getPhysicsWorld(enode), -- 1206
			enode -- 1206
		) -- 1206
	end, -- 1205
	contact = function(nodeStack, enode, _parent) -- 1208
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1209
		if world ~= nil then -- 1209
			local contact = enode.props -- 1211
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1212
		else -- 1212
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1214
		end -- 1214
	end, -- 1208
	body = function(nodeStack, enode, _parent) -- 1217
		local def = enode.props -- 1218
		if def.world then -- 1218
			addChild( -- 1220
				nodeStack, -- 1220
				getBody(enode, def.world), -- 1220
				enode -- 1220
			) -- 1220
			return -- 1221
		end -- 1221
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1223
		if world ~= nil then -- 1223
			addChild( -- 1225
				nodeStack, -- 1225
				getBody(enode, world), -- 1225
				enode -- 1225
			) -- 1225
		else -- 1225
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1227
		end -- 1227
	end, -- 1217
	["rect-fixture"] = bodyCheck, -- 1230
	["polygon-fixture"] = bodyCheck, -- 1231
	["multi-fixture"] = bodyCheck, -- 1232
	["disk-fixture"] = bodyCheck, -- 1233
	["chain-fixture"] = bodyCheck, -- 1234
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1235
		local joint = enode.props -- 1236
		if joint.ref == nil then -- 1236
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1238
			return -- 1239
		end -- 1239
		if joint.bodyA.current == nil then -- 1239
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1242
			return -- 1243
		end -- 1243
		if joint.bodyB.current == nil then -- 1243
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1246
			return -- 1247
		end -- 1247
		local ____joint_ref_22 = joint.ref -- 1249
		local ____self_20 = Dora.Joint -- 1249
		local ____self_20_distance_21 = ____self_20.distance -- 1249
		local ____joint_canCollide_19 = joint.canCollide -- 1250
		if ____joint_canCollide_19 == nil then -- 1250
			____joint_canCollide_19 = false -- 1250
		end -- 1250
		____joint_ref_22.current = ____self_20_distance_21( -- 1249
			____self_20, -- 1249
			____joint_canCollide_19, -- 1250
			joint.bodyA.current, -- 1251
			joint.bodyB.current, -- 1252
			joint.anchorA or Dora.Vec2.zero, -- 1253
			joint.anchorB or Dora.Vec2.zero, -- 1254
			joint.frequency or 0, -- 1255
			joint.damping or 0 -- 1256
		) -- 1256
	end, -- 1235
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1258
		local joint = enode.props -- 1259
		if joint.ref == nil then -- 1259
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1261
			return -- 1262
		end -- 1262
		if joint.bodyA.current == nil then -- 1262
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1265
			return -- 1266
		end -- 1266
		if joint.bodyB.current == nil then -- 1266
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1269
			return -- 1270
		end -- 1270
		local ____joint_ref_26 = joint.ref -- 1272
		local ____self_24 = Dora.Joint -- 1272
		local ____self_24_friction_25 = ____self_24.friction -- 1272
		local ____joint_canCollide_23 = joint.canCollide -- 1273
		if ____joint_canCollide_23 == nil then -- 1273
			____joint_canCollide_23 = false -- 1273
		end -- 1273
		____joint_ref_26.current = ____self_24_friction_25( -- 1272
			____self_24, -- 1272
			____joint_canCollide_23, -- 1273
			joint.bodyA.current, -- 1274
			joint.bodyB.current, -- 1275
			joint.worldPos, -- 1276
			joint.maxForce, -- 1277
			joint.maxTorque -- 1278
		) -- 1278
	end, -- 1258
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1281
		local joint = enode.props -- 1282
		if joint.ref == nil then -- 1282
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1284
			return -- 1285
		end -- 1285
		if joint.jointA.current == nil then -- 1285
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1288
			return -- 1289
		end -- 1289
		if joint.jointB.current == nil then -- 1289
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1292
			return -- 1293
		end -- 1293
		local ____joint_ref_30 = joint.ref -- 1295
		local ____self_28 = Dora.Joint -- 1295
		local ____self_28_gear_29 = ____self_28.gear -- 1295
		local ____joint_canCollide_27 = joint.canCollide -- 1296
		if ____joint_canCollide_27 == nil then -- 1296
			____joint_canCollide_27 = false -- 1296
		end -- 1296
		____joint_ref_30.current = ____self_28_gear_29( -- 1295
			____self_28, -- 1295
			____joint_canCollide_27, -- 1296
			joint.jointA.current, -- 1297
			joint.jointB.current, -- 1298
			joint.ratio or 1 -- 1299
		) -- 1299
	end, -- 1281
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1302
		local joint = enode.props -- 1303
		if joint.ref == nil then -- 1303
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1305
			return -- 1306
		end -- 1306
		if joint.bodyA.current == nil then -- 1306
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1309
			return -- 1310
		end -- 1310
		if joint.bodyB.current == nil then -- 1310
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1313
			return -- 1314
		end -- 1314
		local ____joint_ref_34 = joint.ref -- 1316
		local ____self_32 = Dora.Joint -- 1316
		local ____self_32_spring_33 = ____self_32.spring -- 1316
		local ____joint_canCollide_31 = joint.canCollide -- 1317
		if ____joint_canCollide_31 == nil then -- 1317
			____joint_canCollide_31 = false -- 1317
		end -- 1317
		____joint_ref_34.current = ____self_32_spring_33( -- 1316
			____self_32, -- 1316
			____joint_canCollide_31, -- 1317
			joint.bodyA.current, -- 1318
			joint.bodyB.current, -- 1319
			joint.linearOffset, -- 1320
			joint.angularOffset, -- 1321
			joint.maxForce, -- 1322
			joint.maxTorque, -- 1323
			joint.correctionFactor or 1 -- 1324
		) -- 1324
	end, -- 1302
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1327
		local joint = enode.props -- 1328
		if joint.ref == nil then -- 1328
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1330
			return -- 1331
		end -- 1331
		if joint.body.current == nil then -- 1331
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1334
			return -- 1335
		end -- 1335
		local ____joint_ref_38 = joint.ref -- 1337
		local ____self_36 = Dora.Joint -- 1337
		local ____self_36_move_37 = ____self_36.move -- 1337
		local ____joint_canCollide_35 = joint.canCollide -- 1338
		if ____joint_canCollide_35 == nil then -- 1338
			____joint_canCollide_35 = false -- 1338
		end -- 1338
		____joint_ref_38.current = ____self_36_move_37( -- 1337
			____self_36, -- 1337
			____joint_canCollide_35, -- 1338
			joint.body.current, -- 1339
			joint.targetPos, -- 1340
			joint.maxForce, -- 1341
			joint.frequency, -- 1342
			joint.damping or 0.7 -- 1343
		) -- 1343
	end, -- 1327
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1346
		local joint = enode.props -- 1347
		if joint.ref == nil then -- 1347
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1349
			return -- 1350
		end -- 1350
		if joint.bodyA.current == nil then -- 1350
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1353
			return -- 1354
		end -- 1354
		if joint.bodyB.current == nil then -- 1354
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1357
			return -- 1358
		end -- 1358
		local ____joint_ref_42 = joint.ref -- 1360
		local ____self_40 = Dora.Joint -- 1360
		local ____self_40_prismatic_41 = ____self_40.prismatic -- 1360
		local ____joint_canCollide_39 = joint.canCollide -- 1361
		if ____joint_canCollide_39 == nil then -- 1361
			____joint_canCollide_39 = false -- 1361
		end -- 1361
		____joint_ref_42.current = ____self_40_prismatic_41( -- 1360
			____self_40, -- 1360
			____joint_canCollide_39, -- 1361
			joint.bodyA.current, -- 1362
			joint.bodyB.current, -- 1363
			joint.worldPos, -- 1364
			joint.axisAngle, -- 1365
			joint.lowerTranslation or 0, -- 1366
			joint.upperTranslation or 0, -- 1367
			joint.maxMotorForce or 0, -- 1368
			joint.motorSpeed or 0 -- 1369
		) -- 1369
	end, -- 1346
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1372
		local joint = enode.props -- 1373
		if joint.ref == nil then -- 1373
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1375
			return -- 1376
		end -- 1376
		if joint.bodyA.current == nil then -- 1376
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1379
			return -- 1380
		end -- 1380
		if joint.bodyB.current == nil then -- 1380
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1383
			return -- 1384
		end -- 1384
		local ____joint_ref_46 = joint.ref -- 1386
		local ____self_44 = Dora.Joint -- 1386
		local ____self_44_pulley_45 = ____self_44.pulley -- 1386
		local ____joint_canCollide_43 = joint.canCollide -- 1387
		if ____joint_canCollide_43 == nil then -- 1387
			____joint_canCollide_43 = false -- 1387
		end -- 1387
		____joint_ref_46.current = ____self_44_pulley_45( -- 1386
			____self_44, -- 1386
			____joint_canCollide_43, -- 1387
			joint.bodyA.current, -- 1388
			joint.bodyB.current, -- 1389
			joint.anchorA or Dora.Vec2.zero, -- 1390
			joint.anchorB or Dora.Vec2.zero, -- 1391
			joint.groundAnchorA, -- 1392
			joint.groundAnchorB, -- 1393
			joint.ratio or 1 -- 1394
		) -- 1394
	end, -- 1372
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1397
		local joint = enode.props -- 1398
		if joint.ref == nil then -- 1398
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1400
			return -- 1401
		end -- 1401
		if joint.bodyA.current == nil then -- 1401
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1404
			return -- 1405
		end -- 1405
		if joint.bodyB.current == nil then -- 1405
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1408
			return -- 1409
		end -- 1409
		local ____joint_ref_50 = joint.ref -- 1411
		local ____self_48 = Dora.Joint -- 1411
		local ____self_48_revolute_49 = ____self_48.revolute -- 1411
		local ____joint_canCollide_47 = joint.canCollide -- 1412
		if ____joint_canCollide_47 == nil then -- 1412
			____joint_canCollide_47 = false -- 1412
		end -- 1412
		____joint_ref_50.current = ____self_48_revolute_49( -- 1411
			____self_48, -- 1411
			____joint_canCollide_47, -- 1412
			joint.bodyA.current, -- 1413
			joint.bodyB.current, -- 1414
			joint.worldPos, -- 1415
			joint.lowerAngle or 0, -- 1416
			joint.upperAngle or 0, -- 1417
			joint.maxMotorTorque or 0, -- 1418
			joint.motorSpeed or 0 -- 1419
		) -- 1419
	end, -- 1397
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1422
		local joint = enode.props -- 1423
		if joint.ref == nil then -- 1423
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1425
			return -- 1426
		end -- 1426
		if joint.bodyA.current == nil then -- 1426
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1429
			return -- 1430
		end -- 1430
		if joint.bodyB.current == nil then -- 1430
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1433
			return -- 1434
		end -- 1434
		local ____joint_ref_54 = joint.ref -- 1436
		local ____self_52 = Dora.Joint -- 1436
		local ____self_52_rope_53 = ____self_52.rope -- 1436
		local ____joint_canCollide_51 = joint.canCollide -- 1437
		if ____joint_canCollide_51 == nil then -- 1437
			____joint_canCollide_51 = false -- 1437
		end -- 1437
		____joint_ref_54.current = ____self_52_rope_53( -- 1436
			____self_52, -- 1436
			____joint_canCollide_51, -- 1437
			joint.bodyA.current, -- 1438
			joint.bodyB.current, -- 1439
			joint.anchorA or Dora.Vec2.zero, -- 1440
			joint.anchorB or Dora.Vec2.zero, -- 1441
			joint.maxLength or 0 -- 1442
		) -- 1442
	end, -- 1422
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1445
		local joint = enode.props -- 1446
		if joint.ref == nil then -- 1446
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1448
			return -- 1449
		end -- 1449
		if joint.bodyA.current == nil then -- 1449
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1452
			return -- 1453
		end -- 1453
		if joint.bodyB.current == nil then -- 1453
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1456
			return -- 1457
		end -- 1457
		local ____joint_ref_58 = joint.ref -- 1459
		local ____self_56 = Dora.Joint -- 1459
		local ____self_56_weld_57 = ____self_56.weld -- 1459
		local ____joint_canCollide_55 = joint.canCollide -- 1460
		if ____joint_canCollide_55 == nil then -- 1460
			____joint_canCollide_55 = false -- 1460
		end -- 1460
		____joint_ref_58.current = ____self_56_weld_57( -- 1459
			____self_56, -- 1459
			____joint_canCollide_55, -- 1460
			joint.bodyA.current, -- 1461
			joint.bodyB.current, -- 1462
			joint.worldPos, -- 1463
			joint.frequency or 0, -- 1464
			joint.damping or 0 -- 1465
		) -- 1465
	end, -- 1445
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1468
		local joint = enode.props -- 1469
		if joint.ref == nil then -- 1469
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1471
			return -- 1472
		end -- 1472
		if joint.bodyA.current == nil then -- 1472
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1475
			return -- 1476
		end -- 1476
		if joint.bodyB.current == nil then -- 1476
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1479
			return -- 1480
		end -- 1480
		local ____joint_ref_62 = joint.ref -- 1482
		local ____self_60 = Dora.Joint -- 1482
		local ____self_60_wheel_61 = ____self_60.wheel -- 1482
		local ____joint_canCollide_59 = joint.canCollide -- 1483
		if ____joint_canCollide_59 == nil then -- 1483
			____joint_canCollide_59 = false -- 1483
		end -- 1483
		____joint_ref_62.current = ____self_60_wheel_61( -- 1482
			____self_60, -- 1482
			____joint_canCollide_59, -- 1483
			joint.bodyA.current, -- 1484
			joint.bodyB.current, -- 1485
			joint.worldPos, -- 1486
			joint.axisAngle, -- 1487
			joint.maxMotorTorque or 0, -- 1488
			joint.motorSpeed or 0, -- 1489
			joint.frequency or 0, -- 1490
			joint.damping or 0.7 -- 1491
		) -- 1491
	end, -- 1468
	["custom-node"] = function(nodeStack, enode, _parent) -- 1494
		local node = getCustomNode(enode) -- 1495
		if node ~= nil then -- 1495
			addChild(nodeStack, node, enode) -- 1497
		end -- 1497
	end, -- 1494
	["custom-element"] = function() -- 1500
	end, -- 1500
	["align-node"] = function(nodeStack, enode, _parent) -- 1501
		addChild( -- 1502
			nodeStack, -- 1502
			getAlignNode(enode), -- 1502
			enode -- 1502
		) -- 1502
	end, -- 1501
	["effek-node"] = function(nodeStack, enode, _parent) -- 1504
		addChild( -- 1505
			nodeStack, -- 1505
			getEffekNode(enode), -- 1505
			enode -- 1505
		) -- 1505
	end, -- 1504
	effek = function(nodeStack, enode, parent) -- 1507
		if #nodeStack > 0 then -- 1507
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1509
			if node then -- 1509
				local effek = enode.props -- 1511
				local handle = node:play( -- 1512
					effek.file, -- 1512
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1512
					effek.z or 0 -- 1512
				) -- 1512
				if handle >= 0 then -- 1512
					if effek.ref then -- 1512
						effek.ref.current = handle -- 1515
					end -- 1515
					if effek.onEnd then -- 1515
						local onEnd = effek.onEnd -- 1515
						node:slot( -- 1519
							"EffekEnd", -- 1519
							function(h) -- 1519
								if handle == h then -- 1519
									onEnd(nil) -- 1521
								end -- 1521
							end -- 1519
						) -- 1519
					end -- 1519
				end -- 1519
			else -- 1519
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1527
			end -- 1527
		end -- 1527
	end, -- 1507
	["tile-node"] = function(nodeStack, enode, parent) -- 1531
		local cnode = getTileNode(enode) -- 1532
		if cnode ~= nil then -- 1532
			addChild(nodeStack, cnode, enode) -- 1534
		end -- 1534
	end -- 1531
} -- 1531
local roots = {} -- 1587
warnedUnkeyedChildTypes = {} -- 1588
local renderQueued = false -- 1589
local queuedRoots = {} -- 1590
local trackingRoot -- 1591
local function isElementList(node) -- 1595
	return node.type == nil -- 1596
end -- 1595
local function getRenderableElement(renderable) -- 1630
	if type(renderable) == "function" then -- 1630
		return renderable() -- 1632
	end -- 1632
	return renderable -- 1634
end -- 1630
local function removeRoot(root) -- 1884
	for i = 1, #roots do -- 1884
		if roots[i] == root then -- 1884
			table.remove(roots, i) -- 1887
			break -- 1888
		end -- 1888
	end -- 1888
end -- 1884
local function toElementList(node) -- 2455
	if isElementList(node) then -- 2455
		return node -- 2457
	end -- 2457
	return {node} -- 2459
end -- 2455
local function scheduleRootRender(root) -- 2462
	if not root.active then -- 2462
		return -- 2463
	end -- 2463
	for i = 1, #queuedRoots do -- 2463
		if queuedRoots[i] == root then -- 2463
			return -- 2465
		end -- 2465
	end -- 2465
	queuedRoots[#queuedRoots + 1] = root -- 2467
	if renderQueued then -- 2467
		return -- 2468
	end -- 2468
	renderQueued = true -- 2469
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2470
		renderQueued = false -- 2471
		local updatingRoots = queuedRoots -- 2472
		queuedRoots = {} -- 2473
		for i = 1, #updatingRoots do -- 2473
			updatingRoots[i]:update() -- 2475
		end -- 2475
	end)) -- 2470
end -- 2462
____exports.Root = __TS__Class() -- 2480
local Root = ____exports.Root -- 2480
Root.name = "Root" -- 2480
function Root.prototype.____constructor(self, parent) -- 2494
	self.parent = parent -- 2494
	self.mounted = {} -- 2481
	self.signals = {} -- 2483
	self.hookFrames = {} -- 2484
	self.keyedHookFrames = {} -- 2485
	self.nextKeyedHookFrames = {} -- 2486
	self.usedHookFrames = {} -- 2487
	self.previousHookFrames = {} -- 2488
	self.pendingEffects = {} -- 2489
	self.pendingCleanups = {} -- 2490
	self.hookFrameIndex = 0 -- 2491
	self.active = true -- 2492
end -- 2494
function Root.prototype.render(self, enode) -- 2496
	if not self.active then -- 2496
		roots[#roots + 1] = self -- 2498
		self.active = true -- 2499
	end -- 2499
	self.renderable = enode -- 2501
	self:update() -- 2502
end -- 2496
function Root.prototype.update(self) -- 2505
	if not self.active or self.renderable == nil then -- 2505
		return -- 2506
	end -- 2506
	self:unsubscribeSignals() -- 2507
	local lastTrackingRoot = trackingRoot -- 2508
	local lastRenderingHookRoot = renderingHookRoot -- 2509
	trackingRoot = self -- 2510
	renderingHookRoot = self -- 2511
	local elements -- 2512
	do -- 2512
		local ____try, ____error = pcall(function() -- 2512
			self:beginHookRender() -- 2514
			elements = getRenderableElement(self.renderable) -- 2515
		end) -- 2515
		do -- 2515
			self:finishHookRender() -- 2517
			trackingRoot = lastTrackingRoot -- 2518
			renderingHookRoot = lastRenderingHookRoot -- 2519
		end -- 2519
		if not ____try then -- 2519
			error(____error, 0) -- 2519
		end -- 2519
	end -- 2519
	self.mounted = reconcileChildren( -- 2521
		self.parent, -- 2521
		self.mounted, -- 2521
		toElementList(elements) -- 2521
	) -- 2521
	self:flushEffects() -- 2522
end -- 2505
function Root.prototype.unmount(self) -- 2525
	for i = 1, #self.mounted do -- 2525
		unmountElement(self.mounted[i]) -- 2527
	end -- 2527
	for i = 1, #self.hookFrames do -- 2527
		self:queueFrameCleanup(self.hookFrames[i]) -- 2530
	end -- 2530
	self.pendingEffects = {} -- 2532
	self:flushEffects() -- 2533
	self.mounted = {} -- 2534
	self.renderable = nil -- 2535
	self.hookFrames = {} -- 2536
	self.keyedHookFrames = {} -- 2537
	self.nextKeyedHookFrames = {} -- 2538
	self.usedHookFrames = {} -- 2539
	self.previousHookFrames = {} -- 2540
	self.hookFrameIndex = 0 -- 2541
	self:unsubscribeSignals() -- 2542
	if self.active then -- 2542
		removeRoot(self) -- 2544
		self.active = false -- 2545
	end -- 2545
end -- 2525
function Root.prototype.trackSignal(self, signal) -- 2549
	for i = 1, #self.signals do -- 2549
		if self.signals[i] == signal then -- 2549
			return -- 2551
		end -- 2551
	end -- 2551
	local ____self_signals_73 = self.signals -- 2551
	____self_signals_73[#____self_signals_73 + 1] = signal -- 2553
	signal:addRoot(self) -- 2554
end -- 2549
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2557
	local index = self.hookFrameIndex -- 2558
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2559
	local frame -- 2560
	if key ~= nil then -- 2560
		local framesByKey = self.keyedHookFrames[____type] -- 2562
		if framesByKey ~= nil then -- 2562
			frame = framesByKey[key] -- 2564
			if frame ~= nil and self.usedHookFrames[frame] == true then -- 2564
				frame = nil -- 2566
			end -- 2566
		end -- 2566
		if frame == nil then -- 2566
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2570
		end -- 2570
		local nextFramesByKey = self.nextKeyedHookFrames[____type] -- 2572
		if nextFramesByKey == nil then -- 2572
			nextFramesByKey = {} -- 2574
			self.nextKeyedHookFrames[____type] = nextFramesByKey -- 2575
		end -- 2575
		nextFramesByKey[key] = frame -- 2577
		self.hookFrames[index + 1] = frame -- 2578
	else -- 2578
		frame = self.hookFrames[index + 1] -- 2580
		if frame == nil or self.usedHookFrames[frame] == true or frame.type ~= ____type or frame.key ~= nil then -- 2580
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2587
			self.hookFrames[index + 1] = frame -- 2588
		end -- 2588
	end -- 2588
	frame.hookIndex = 0 -- 2591
	self.usedHookFrames[frame] = true -- 2592
	return frame -- 2593
end -- 2557
function Root.prototype.queueEffect(self, hook, effect) -- 2596
	if hook.cleanup ~= nil then -- 2596
		local ____self_pendingCleanups_74 = self.pendingCleanups -- 2596
		____self_pendingCleanups_74[#____self_pendingCleanups_74 + 1] = hook.cleanup -- 2598
		hook.cleanup = nil -- 2599
	end -- 2599
	local ____self_pendingEffects_75 = self.pendingEffects -- 2599
	____self_pendingEffects_75[#____self_pendingEffects_75 + 1] = {hook = hook, effect = effect} -- 2601
end -- 2596
function Root.prototype.beginHookRender(self) -- 2604
	self.previousHookFrames = {table.unpack(self.hookFrames)} -- 2605
	self.hookFrameIndex = 0 -- 2606
	self.usedHookFrames = {} -- 2607
	self.nextKeyedHookFrames = {} -- 2608
end -- 2604
function Root.prototype.finishHookRender(self) -- 2611
	for i = 1, #self.previousHookFrames do -- 2611
		local frame = self.previousHookFrames[i] -- 2613
		if self.usedHookFrames[frame] ~= true then -- 2613
			self:queueFrameCleanup(frame) -- 2615
		end -- 2615
	end -- 2615
	while #self.hookFrames > self.hookFrameIndex do -- 2615
		table.remove(self.hookFrames) -- 2619
	end -- 2619
	self.keyedHookFrames = self.nextKeyedHookFrames -- 2621
	self.previousHookFrames = {} -- 2622
end -- 2611
function Root.prototype.unsubscribeSignals(self) -- 2625
	for i = 1, #self.signals do -- 2625
		self.signals[i]:removeRoot(self) -- 2627
	end -- 2627
	self.signals = {} -- 2629
end -- 2625
function Root.prototype.queueFrameCleanup(self, frame) -- 2632
	for i = 1, #frame.hooks do -- 2632
		local hook = frame.hooks[i] -- 2634
		if hook.cleanup ~= nil then -- 2634
			local ____self_pendingCleanups_76 = self.pendingCleanups -- 2634
			____self_pendingCleanups_76[#____self_pendingCleanups_76 + 1] = hook.cleanup -- 2636
			hook.cleanup = nil -- 2637
		end -- 2637
	end -- 2637
end -- 2632
function Root.prototype.flushEffects(self) -- 2642
	local cleanups = self.pendingCleanups -- 2643
	self.pendingCleanups = {} -- 2644
	for i = 1, #cleanups do -- 2644
		cleanups[i]() -- 2646
	end -- 2646
	local effects = self.pendingEffects -- 2648
	self.pendingEffects = {} -- 2649
	for i = 1, #effects do -- 2649
		local task = effects[i] -- 2651
		local cleanup = task.effect() -- 2652
		if type(cleanup) == "function" then -- 2652
			task.hook.cleanup = cleanup -- 2654
		end -- 2654
	end -- 2654
end -- 2642
function ____exports.createRoot(parent) -- 2660
	local root = __TS__New(____exports.Root, parent) -- 2661
	roots[#roots + 1] = root -- 2662
	return root -- 2663
end -- 2660
____exports.Signal = __TS__Class() -- 2666
local Signal = ____exports.Signal -- 2666
Signal.name = "Signal" -- 2666
function Signal.prototype.____constructor(self, item) -- 2669
	self.item = item -- 2669
	self.roots = {} -- 2667
end -- 2669
function Signal.prototype.addRoot(self, root) -- 2686
	for i = 1, #self.roots do -- 2686
		if self.roots[i] == root then -- 2686
			return -- 2688
		end -- 2688
	end -- 2688
	local ____self_roots_77 = self.roots -- 2688
	____self_roots_77[#____self_roots_77 + 1] = root -- 2690
end -- 2686
function Signal.prototype.removeRoot(self, root) -- 2693
	for i = 1, #self.roots do -- 2693
		if self.roots[i] == root then -- 2693
			table.remove(self.roots, i) -- 2696
			break -- 2697
		end -- 2697
	end -- 2697
end -- 2693
__TS__SetDescriptor( -- 2693
	Signal.prototype, -- 2693
	"value", -- 2693
	{ -- 2693
		get = function(self) -- 2693
			if trackingRoot ~= nil then -- 2693
				trackingRoot:trackSignal(self) -- 2673
			end -- 2673
			return self.item -- 2675
		end, -- 2675
		set = function(self, value) -- 2675
			if self.item == value then -- 2675
				return -- 2679
			end -- 2679
			self.item = value -- 2680
			for i = 1, #self.roots do -- 2680
				scheduleRootRender(self.roots[i]) -- 2682
			end -- 2682
		end -- 2682
	}, -- 2682
	true -- 2682
) -- 2682
function ____exports.signal(value) -- 2703
	return __TS__New(____exports.Signal, value) -- 2704
end -- 2703
function ____exports.reference(item) -- 2707
	local ____item_78 = item -- 2708
	if ____item_78 == nil then -- 2708
		____item_78 = nil -- 2708
	end -- 2708
	return {current = ____item_78} -- 2708
end -- 2707
local function hookDepsEqual(oldDeps, newDeps) -- 2711
	if oldDeps == nil or newDeps == nil then -- 2711
		return false -- 2712
	end -- 2712
	if #oldDeps ~= #newDeps then -- 2712
		return false -- 2713
	end -- 2713
	for i = 1, #oldDeps do -- 2713
		if oldDeps[i] ~= newDeps[i] then -- 2713
			return false -- 2715
		end -- 2715
	end -- 2715
	return true -- 2717
end -- 2711
local function copyDeps(deps) -- 2720
	if deps == nil then -- 2720
		return nil -- 2721
	end -- 2721
	local copied = {} -- 2722
	for i = 1, #deps do -- 2722
		copied[#copied + 1] = deps[i] -- 2724
	end -- 2724
	return copied -- 2726
end -- 2720
function ____exports.useMemo(factory, deps) -- 2729
	local frame = currentHookFrame -- 2730
	if frame == nil then -- 2730
		error("useMemo() can only be called inside a function component") -- 2732
	end -- 2732
	local index = frame.hookIndex -- 2734
	frame.hookIndex = frame.hookIndex + 1 -- 2735
	local hook = frame.hooks[index + 1] -- 2736
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2736
		hook = { -- 2738
			value = factory(), -- 2738
			deps = copyDeps(deps) -- 2738
		} -- 2738
		frame.hooks[index + 1] = hook -- 2739
	end -- 2739
	return hook.value -- 2741
end -- 2729
function ____exports.useCallback(callback, deps) -- 2744
	local frame = currentHookFrame -- 2745
	if frame == nil then -- 2745
		error("useCallback() can only be called inside a function component") -- 2747
	end -- 2747
	local actualDeps = deps or ({}) -- 2749
	local index = frame.hookIndex -- 2750
	frame.hookIndex = frame.hookIndex + 1 -- 2751
	local hook = frame.hooks[index + 1] -- 2752
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2752
		hook = { -- 2754
			value = callback, -- 2754
			deps = copyDeps(actualDeps) -- 2754
		} -- 2754
		frame.hooks[index + 1] = hook -- 2755
	end -- 2755
	return hook.value -- 2757
end -- 2744
function ____exports.useEffect(effect, deps) -- 2760
	local frame = currentHookFrame -- 2761
	if frame == nil or renderingHookRoot == nil then -- 2761
		error("useEffect() can only be called inside a function component") -- 2763
	end -- 2763
	local index = frame.hookIndex -- 2765
	frame.hookIndex = frame.hookIndex + 1 -- 2766
	local hook = frame.hooks[index + 1] -- 2767
	if hook == nil then -- 2767
		hook = {value = nil} -- 2769
		frame.hooks[index + 1] = hook -- 2770
	end -- 2770
	if not hookDepsEqual(hook.deps, deps) then -- 2770
		hook.deps = copyDeps(deps) -- 2773
		renderingHookRoot:queueEffect(hook, effect) -- 2774
	end -- 2774
end -- 2760
function ____exports.useRef(item) -- 2778
	local frame = currentHookFrame -- 2779
	if frame == nil then -- 2779
		Warn("useRef() called outside a function component; falling back to reference()") -- 2781
		return ____exports.reference(item) -- 2782
	end -- 2782
	local index = frame.hookIndex -- 2784
	frame.hookIndex = frame.hookIndex + 1 -- 2785
	local hook = frame.hooks[index + 1] -- 2786
	if hook == nil then -- 2786
		hook = {value = ____exports.reference(item)} -- 2788
		frame.hooks[index + 1] = hook -- 2789
	end -- 2789
	return hook.value -- 2791
end -- 2778
function ____exports.useSignal(value) -- 2794
	local frame = currentHookFrame -- 2795
	if frame == nil then -- 2795
		error("useSignal() can only be called inside a function component") -- 2797
	end -- 2797
	local index = frame.hookIndex -- 2799
	frame.hookIndex = frame.hookIndex + 1 -- 2800
	local hook = frame.hooks[index + 1] -- 2801
	if hook == nil then -- 2801
		hook = {value = ____exports.signal(value)} -- 2803
		frame.hooks[index + 1] = hook -- 2804
	end -- 2804
	return hook.value -- 2806
end -- 2794
local function getPreload(preloadList, node) -- 2809
	if type(node) ~= "table" then -- 2809
		return -- 2811
	end -- 2811
	local enode = node -- 2813
	if enode.type == nil then -- 2813
		local list = node -- 2815
		if #list > 0 then -- 2815
			for i = 1, #list do -- 2815
				getPreload(preloadList, list[i]) -- 2818
			end -- 2818
		end -- 2818
	else -- 2818
		repeat -- 2818
			local ____switch663 = enode.type -- 2818
			local sprite, playable, frame, model, spine, dragonBone, label -- 2818
			local ____cond663 = ____switch663 == "sprite" -- 2818
			if ____cond663 then -- 2818
				sprite = enode.props -- 2824
				if sprite.file then -- 2824
					preloadList[#preloadList + 1] = sprite.file -- 2826
				end -- 2826
				break -- 2828
			end -- 2828
			____cond663 = ____cond663 or ____switch663 == "playable" -- 2828
			if ____cond663 then -- 2828
				playable = enode.props -- 2830
				preloadList[#preloadList + 1] = playable.file -- 2831
				break -- 2832
			end -- 2832
			____cond663 = ____cond663 or ____switch663 == "frame" -- 2832
			if ____cond663 then -- 2832
				frame = enode.props -- 2834
				preloadList[#preloadList + 1] = frame.file -- 2835
				break -- 2836
			end -- 2836
			____cond663 = ____cond663 or ____switch663 == "model" -- 2836
			if ____cond663 then -- 2836
				model = enode.props -- 2838
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2839
				break -- 2840
			end -- 2840
			____cond663 = ____cond663 or ____switch663 == "spine" -- 2840
			if ____cond663 then -- 2840
				spine = enode.props -- 2842
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2843
				break -- 2844
			end -- 2844
			____cond663 = ____cond663 or ____switch663 == "dragon-bone" -- 2844
			if ____cond663 then -- 2844
				dragonBone = enode.props -- 2846
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2847
				break -- 2848
			end -- 2848
			____cond663 = ____cond663 or ____switch663 == "label" -- 2848
			if ____cond663 then -- 2848
				label = enode.props -- 2850
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2851
				break -- 2852
			end -- 2852
		until true -- 2852
	end -- 2852
	getPreload(preloadList, enode.children) -- 2855
end -- 2809
function ____exports.preloadAsync(enode, handler) -- 2858
	local preloadList = {} -- 2859
	getPreload(preloadList, enode) -- 2860
	Dora.Cache:loadAsync(preloadList, handler) -- 2861
end -- 2858
function ____exports.toAction(enode) -- 2864
	local actionDef = ____exports.reference() -- 2865
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2866
	if not actionDef.current then -- 2866
		error("failed to create action") -- 2867
	end -- 2867
	return actionDef.current -- 2868
end -- 2864
return ____exports -- 2864