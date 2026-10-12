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
function visitAction(actionStack, enode) -- 930
	local createAction = actionMap[enode.type] -- 931
	if createAction ~= nil then -- 931
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 933
		return -- 934
	end -- 934
	repeat -- 934
		local ____switch196 = enode.type -- 934
		local ____cond196 = ____switch196 == "delay" -- 934
		if ____cond196 then -- 934
			do -- 934
				local item = enode.props -- 938
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 939
				break -- 940
			end -- 940
		end -- 940
		____cond196 = ____cond196 or ____switch196 == "event" -- 940
		if ____cond196 then -- 940
			do -- 940
				local item = enode.props -- 943
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 944
				break -- 945
			end -- 945
		end -- 945
		____cond196 = ____cond196 or ____switch196 == "hide" -- 945
		if ____cond196 then -- 945
			do -- 945
				actionStack[#actionStack + 1] = Dora.Hide() -- 948
				break -- 949
			end -- 949
		end -- 949
		____cond196 = ____cond196 or ____switch196 == "show" -- 949
		if ____cond196 then -- 949
			do -- 949
				actionStack[#actionStack + 1] = Dora.Show() -- 952
				break -- 953
			end -- 953
		end -- 953
		____cond196 = ____cond196 or ____switch196 == "move" -- 953
		if ____cond196 then -- 953
			do -- 953
				local item = enode.props -- 956
				actionStack[#actionStack + 1] = Dora.Move( -- 957
					item.time, -- 957
					Dora.Vec2(item.startX, item.startY), -- 957
					Dora.Vec2(item.stopX, item.stopY), -- 957
					item.easing -- 957
				) -- 957
				break -- 958
			end -- 958
		end -- 958
		____cond196 = ____cond196 or ____switch196 == "frame" -- 958
		if ____cond196 then -- 958
			do -- 958
				local item = enode.props -- 961
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 962
				break -- 963
			end -- 963
		end -- 963
		____cond196 = ____cond196 or ____switch196 == "spawn" -- 963
		if ____cond196 then -- 963
			do -- 963
				local spawnStack = {} -- 966
				for i = 1, #enode.children do -- 966
					visitAction(spawnStack, enode.children[i]) -- 968
				end -- 968
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 970
				break -- 971
			end -- 971
		end -- 971
		____cond196 = ____cond196 or ____switch196 == "sequence" -- 971
		if ____cond196 then -- 971
			do -- 971
				local sequenceStack = {} -- 974
				for i = 1, #enode.children do -- 974
					visitAction(sequenceStack, enode.children[i]) -- 976
				end -- 976
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 978
				break -- 979
			end -- 979
		end -- 979
		do -- 979
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 982
			break -- 983
		end -- 983
	until true -- 983
end -- 983
function visitNode(nodeStack, node, parent) -- 1531
	if type(node) ~= "table" then -- 1531
		return -- 1533
	end -- 1533
	local enode = node -- 1535
	if enode.type == nil then -- 1535
		local list = node -- 1537
		if #list > 0 then -- 1537
			for i = 1, #list do -- 1537
				local stack = {} -- 1540
				visitNode(stack, list[i], parent) -- 1541
				for i = 1, #stack do -- 1541
					nodeStack[#nodeStack + 1] = stack[i] -- 1543
				end -- 1543
			end -- 1543
		end -- 1543
	else -- 1543
		local handler = elementMap[enode.type] -- 1548
		if handler ~= nil then -- 1548
			handler(nodeStack, enode, parent) -- 1550
		else -- 1550
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1552
		end -- 1552
	end -- 1552
end -- 1552
function ____exports.toNode(enode) -- 1557
	local nodeStack = {} -- 1558
	visitNode(nodeStack, enode) -- 1559
	if #nodeStack == 1 then -- 1559
		return nodeStack[1] -- 1561
	elseif #nodeStack > 1 then -- 1561
		local node = Dora.Node() -- 1563
		for i = 1, #nodeStack do -- 1563
			node:addChild(nodeStack[i]) -- 1565
		end -- 1565
		return node -- 1567
	end -- 1567
	return nil -- 1569
end -- 1557
function getElementKey(element) -- 1592
	local props = element.props -- 1593
	local ____props_63 -- 1594
	if props then -- 1594
		____props_63 = props.key -- 1594
	else -- 1594
		____props_63 = nil -- 1594
	end -- 1594
	return ____props_63 -- 1594
end -- 1594
function getElementTypeName(element) -- 1597
	local elementType = element.type -- 1598
	if type(elementType) == "string" then -- 1598
		return elementType -- 1599
	end -- 1599
	return tostring(elementType) -- 1600
end -- 1600
function warnUnkeyedDynamicChildren(oldChildren, newElements) -- 1603
	if #oldChildren == #newElements then -- 1603
		return -- 1604
	end -- 1604
	local oldTypes = {} -- 1605
	for i = 1, #oldChildren do -- 1605
		local oldElement = oldChildren[i].element -- 1607
		if getElementKey(oldElement) == nil then -- 1607
			oldTypes[getElementTypeName(oldElement)] = true -- 1609
		end -- 1609
	end -- 1609
	for i = 1, #newElements do -- 1609
		do -- 1609
			local newElement = newElements[i] -- 1613
			if getElementKey(newElement) ~= nil then -- 1613
				goto __continue345 -- 1614
			end -- 1614
			local typeName = getElementTypeName(newElement) -- 1615
			if oldTypes[typeName] == true and not warnedUnkeyedChildTypes[typeName] then -- 1615
				warnedUnkeyedChildTypes[typeName] = true -- 1617
				Warn(("dynamic children include unkeyed <" .. typeName) .. "> siblings while child count changed; add stable key props to conditional, inserted, removed or reordered siblings to avoid index-based reuse") -- 1618
			end -- 1618
		end -- 1618
		::__continue345:: -- 1618
	end -- 1618
end -- 1618
function getPrimitiveLabelText(enode) -- 1630
	local label = enode.props -- 1631
	local text = label.text or "" -- 1632
	for i = 1, #enode.children do -- 1632
		local child = enode.children[i] -- 1634
		if type(child) ~= "table" then -- 1634
			text = text .. tostring(child) -- 1636
		end -- 1636
	end -- 1636
	return text -- 1639
end -- 1639
function isDrawShapeElement(element) -- 1642
	repeat -- 1642
		local ____switch354 = element.type -- 1642
		local ____cond354 = ____switch354 == "dot-shape" or ____switch354 == "circle-shape" or ____switch354 == "ellipse-shape" or ____switch354 == "rounded-rect-shape" or ____switch354 == "ring-shape" or ____switch354 == "sector-shape" or ____switch354 == "polyline-shape" or ____switch354 == "arc-shape" or ____switch354 == "quadratic-bezier-shape" or ____switch354 == "cubic-bezier-shape" or ____switch354 == "segment-shape" or ____switch354 == "rect-shape" or ____switch354 == "polygon-shape" or ____switch354 == "verts-shape" -- 1642
		if ____cond354 then -- 1642
			return true -- 1658
		end -- 1658
	until true -- 1658
	return false -- 1660
end -- 1660
function isBodyFixtureElement(element) -- 1663
	repeat -- 1663
		local ____switch356 = element.type -- 1663
		local ____cond356 = ____switch356 == "rect-fixture" or ____switch356 == "polygon-fixture" or ____switch356 == "multi-fixture" or ____switch356 == "disk-fixture" or ____switch356 == "chain-fixture" -- 1663
		if ____cond356 then -- 1663
			return true -- 1670
		end -- 1670
	until true -- 1670
	return false -- 1672
end -- 1672
function isPhysicsWorldInputElement(element) -- 1675
	return element.type == "contact" -- 1676
end -- 1676
function isRunnableActionElement(element) -- 1679
	if element.type == "loop" then -- 1679
		return true -- 1680
	end -- 1680
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1681
end -- 1681
function shallowPropsEqual(oldProps, newProps) -- 1692
	for k, v in pairs(oldProps) do -- 1693
		if k ~= "ref" and newProps[k] ~= v then -- 1693
			return false -- 1694
		end -- 1694
	end -- 1694
	for k, v in pairs(newProps) do -- 1696
		if k ~= "ref" and oldProps[k] ~= v then -- 1696
			return false -- 1697
		end -- 1697
	end -- 1697
	return true -- 1699
end -- 1699
function collectRunnableActionElements(element) -- 1702
	local actions = {} -- 1703
	for i = 1, #element.children do -- 1703
		local child = element.children[i] -- 1705
		if type(child) == "table" and isRunnableActionElement(child) then -- 1705
			actions[#actions + 1] = child -- 1707
		end -- 1707
	end -- 1707
	return actions -- 1710
end -- 1710
function collectContactElements(element) -- 1713
	local contacts = {} -- 1714
	for i = 1, #element.children do -- 1714
		local child = element.children[i] -- 1716
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1716
			contacts[#contacts + 1] = child -- 1718
		end -- 1718
	end -- 1718
	return contacts -- 1721
end -- 1721
function getContactKey(contact) -- 1724
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1725
end -- 1725
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1728
	local oldContacts = collectContactElements(oldElement) -- 1729
	local newContacts = collectContactElements(newElement) -- 1730
	local oldByKey = {} -- 1731
	local newByKey = {} -- 1732
	for i = 1, #oldContacts do -- 1732
		local contact = oldContacts[i].props -- 1734
		oldByKey[getContactKey(contact)] = contact -- 1735
	end -- 1735
	for i = 1, #newContacts do -- 1735
		local contact = newContacts[i].props -- 1738
		newByKey[getContactKey(contact)] = contact -- 1739
	end -- 1739
	for i = 1, #oldContacts do -- 1739
		local oldContact = oldContacts[i].props -- 1742
		local key = getContactKey(oldContact) -- 1743
		local newContact = newByKey[key] -- 1744
		if newContact == nil then -- 1744
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1746
		elseif oldContact.enabled ~= newContact.enabled then -- 1746
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1748
		end -- 1748
	end -- 1748
	for i = 1, #newContacts do -- 1748
		local newContact = newContacts[i].props -- 1752
		if oldByKey[getContactKey(newContact)] == nil then -- 1752
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1754
		end -- 1754
	end -- 1754
end -- 1754
function actionElementEqual(oldElement, newElement) -- 1759
	if oldElement.type ~= newElement.type then -- 1759
		return false -- 1760
	end -- 1760
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1760
		return false -- 1761
	end -- 1761
	if #oldElement.children ~= #newElement.children then -- 1761
		return false -- 1762
	end -- 1762
	for i = 1, #oldElement.children do -- 1762
		local oldChild = oldElement.children[i] -- 1764
		local newChild = newElement.children[i] -- 1765
		if type(oldChild) ~= type(newChild) then -- 1765
			return false -- 1766
		end -- 1766
		if type(oldChild) == "table" then -- 1766
			if not actionElementEqual(oldChild, newChild) then -- 1766
				return false -- 1768
			end -- 1768
		elseif oldChild ~= newChild then -- 1768
			return false -- 1770
		end -- 1770
	end -- 1770
	return true -- 1773
end -- 1773
function actionChildrenEqual(oldElement, newElement) -- 1776
	local oldActions = collectRunnableActionElements(oldElement) -- 1777
	local newActions = collectRunnableActionElements(newElement) -- 1778
	if #oldActions ~= #newActions then -- 1778
		return false -- 1779
	end -- 1779
	for i = 1, #oldActions do -- 1779
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1779
			return false -- 1781
		end -- 1781
	end -- 1781
	return true -- 1783
end -- 1783
function createActionDef(actionElement) -- 1786
	if actionElement.type == "loop" then -- 1786
		local actionStack = {} -- 1788
		for i = 1, #actionElement.children do -- 1788
			visitAction(actionStack, actionElement.children[i]) -- 1790
		end -- 1790
		if #actionStack == 1 then -- 1790
			return actionStack[1], true -- 1793
		elseif #actionStack > 1 then -- 1793
			local loop = actionElement.props -- 1795
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1796
		end -- 1796
		return nil, true -- 1798
	end -- 1798
	local actionStack = {} -- 1800
	visitAction(actionStack, actionElement) -- 1801
	return #actionStack == 1 and actionStack[1] or nil, false -- 1802
end -- 1802
function structuralChildrenEqual(oldElement, newElement, check) -- 1805
	local oldChildren = {} -- 1811
	local newChildren = {} -- 1812
	for i = 1, #oldElement.children do -- 1812
		local child = oldElement.children[i] -- 1814
		if type(child) == "table" and check(child) then -- 1814
			oldChildren[#oldChildren + 1] = child -- 1816
		end -- 1816
	end -- 1816
	for i = 1, #newElement.children do -- 1816
		local child = newElement.children[i] -- 1820
		if type(child) == "table" and check(child) then -- 1820
			newChildren[#newChildren + 1] = child -- 1822
		end -- 1822
	end -- 1822
	if #oldChildren ~= #newChildren then -- 1822
		return false -- 1825
	end -- 1825
	for i = 1, #oldChildren do -- 1825
		local oldChild = oldChildren[i] -- 1827
		local newChild = newChildren[i] -- 1828
		if oldChild.type ~= newChild.type then -- 1828
			return false -- 1829
		end -- 1829
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1829
			return false -- 1830
		end -- 1830
	end -- 1830
	return true -- 1832
end -- 1832
function runActionChildren(node, element) -- 1835
	local actionChildren = collectRunnableActionElements(element) -- 1836
	local exclusiveActions = {} -- 1837
	local exclusiveLoop -- 1838
	local warnedExclusiveConflict = false -- 1839
	for i = 1, #actionChildren do -- 1839
		do -- 1839
			local actionElement = actionChildren[i] -- 1841
			local action, loop = createActionDef(actionElement) -- 1842
			if action == nil then -- 1842
				goto __continue408 -- 1843
			end -- 1843
			if actionElement.props.exclusive == true then -- 1843
				if exclusiveLoop == nil then -- 1843
					exclusiveLoop = loop -- 1846
				end -- 1846
				if exclusiveLoop == loop then -- 1846
					exclusiveActions[#exclusiveActions + 1] = action -- 1849
				elseif not warnedExclusiveConflict then -- 1849
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1851
					warnedExclusiveConflict = true -- 1852
				end -- 1852
			end -- 1852
		end -- 1852
		::__continue408:: -- 1852
	end -- 1852
	if #exclusiveActions == 1 then -- 1852
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1857
	elseif #exclusiveActions > 1 then -- 1857
		node:perform( -- 1859
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1859
			exclusiveLoop == true -- 1859
		) -- 1859
	end -- 1859
	for i = 1, #actionChildren do -- 1859
		do -- 1859
			local actionElement = actionChildren[i] -- 1862
			if actionElement.props.exclusive == true then -- 1862
				goto __continue416 -- 1863
			end -- 1863
			local action, loop = createActionDef(actionElement) -- 1864
			if action ~= nil then -- 1864
				node:runAction(action, loop) -- 1866
			end -- 1866
		end -- 1866
		::__continue416:: -- 1866
	end -- 1866
end -- 1866
function patchActionChildren(node, oldElement, newElement) -- 1871
	if not actionChildrenEqual(oldElement, newElement) then -- 1871
		runActionChildren(node, newElement) -- 1873
	end -- 1873
end -- 1873
function toHostElement(enode, parent) -- 1886
	local hostChildren = {} -- 1887
	local props = {} -- 1888
	if enode.props ~= nil then -- 1888
		for k, v in pairs(enode.props) do -- 1890
			props[k] = v -- 1891
		end -- 1891
	end -- 1891
	if enode.type == "label" then -- 1891
		for i = 1, #enode.children do -- 1891
			local child = enode.children[i] -- 1896
			if type(child) ~= "table" then -- 1896
				hostChildren[#hostChildren + 1] = child -- 1898
			end -- 1898
		end -- 1898
	elseif enode.type == "draw-node" then -- 1898
		for i = 1, #enode.children do -- 1898
			local child = enode.children[i] -- 1903
			if type(child) == "table" and isDrawShapeElement(child) then -- 1903
				hostChildren[#hostChildren + 1] = child -- 1905
			end -- 1905
		end -- 1905
	elseif enode.type == "body" then -- 1905
		for i = 1, #enode.children do -- 1905
			local child = enode.children[i] -- 1910
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1910
				hostChildren[#hostChildren + 1] = child -- 1912
			end -- 1912
		end -- 1912
	elseif enode.type == "physics-world" then -- 1912
		for i = 1, #enode.children do -- 1912
			local child = enode.children[i] -- 1917
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1917
				hostChildren[#hostChildren + 1] = child -- 1919
			end -- 1919
		end -- 1919
	end -- 1919
	if enode.type == "body" and props.world == nil then -- 1919
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1924
		if world ~= nil then -- 1924
			props.world = world -- 1926
		end -- 1926
	end -- 1926
	return {type = enode.type, props = props, children = hostChildren} -- 1929
end -- 1929
function createHostNode(enode, parent) -- 1936
	local nodeStack = {} -- 1937
	visitNode( -- 1938
		nodeStack, -- 1938
		toHostElement(enode, parent) -- 1938
	) -- 1938
	if #nodeStack == 1 then -- 1938
		return nodeStack[1] -- 1940
	elseif #nodeStack > 1 then -- 1940
		local node = Dora.Node() -- 1942
		for i = 1, #nodeStack do -- 1942
			node:addChild(nodeStack[i]) -- 1944
		end -- 1944
		return node -- 1946
	end -- 1946
	return nil -- 1948
end -- 1948
function getElementChildren(enode) -- 1951
	local children = {} -- 1952
	if enode.type == "draw-node" or enode.type == "body" then -- 1952
		return children -- 1953
	end -- 1953
	for i = 1, #enode.children do -- 1953
		local child = enode.children[i] -- 1955
		if type(child) == "table" then -- 1955
			local childElement = child -- 1957
			if childElement.type ~= nil then -- 1957
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1957
					children[#children + 1] = childElement -- 1963
				end -- 1963
			else -- 1963
				local list = child -- 1966
				for j = 1, #list do -- 1966
					local item = list[j] -- 1968
					if type(item) == "table" and item.type ~= nil then -- 1968
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1968
							children[#children + 1] = item -- 1974
						end -- 1974
					end -- 1974
				end -- 1974
			end -- 1974
		end -- 1974
	end -- 1974
	return children -- 1981
end -- 1981
function getRecreateMode(oldElement, newElement) -- 1986
	if oldElement.type ~= newElement.type then -- 1986
		return "subtree" -- 1987
	end -- 1987
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1987
		return "subtree" -- 1988
	end -- 1988
	local oldProps = oldElement.props -- 1989
	local newProps = newElement.props -- 1990
	if newElement.type == "draw-node" then -- 1990
		return "host" -- 1991
	end -- 1991
	for k, v in pairs(oldProps) do -- 1992
		if k == "onMount" and newProps[k] ~= v then -- 1992
			return "host" -- 1994
		end -- 1994
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1994
			return "host" -- 1997
		end -- 1997
	end -- 1997
	for k, v in pairs(newProps) do -- 2000
		if k == "onMount" and oldProps[k] ~= v then -- 2000
			return "host" -- 2002
		end -- 2002
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 2002
			return "host" -- 2005
		end -- 2005
	end -- 2005
	repeat -- 2005
		local ____switch465 = newElement.type -- 2005
		local ____cond465 = ____switch465 == "grid" -- 2005
		if ____cond465 then -- 2005
			return (oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY) and "host" or nil -- 2010
		end -- 2010
		____cond465 = ____cond465 or (____switch465 == "sprite" or ____switch465 == "video-node" or ____switch465 == "tic80-node" or ____switch465 == "audio-source" or ____switch465 == "particle" or ____switch465 == "tile-node" or ____switch465 == "playable" or ____switch465 == "dragon-bone" or ____switch465 == "spine" or ____switch465 == "model") -- 2010
		if ____cond465 then -- 2010
			return oldProps.file ~= newProps.file and "host" or nil -- 2021
		end -- 2021
		____cond465 = ____cond465 or ____switch465 == "label" -- 2021
		if ____cond465 then -- 2021
			return (oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf) and "host" or nil -- 2023
		end -- 2023
		____cond465 = ____cond465 or ____switch465 == "align-node" -- 2023
		if ____cond465 then -- 2023
			return oldProps.windowRoot ~= newProps.windowRoot and "host" or nil -- 2025
		end -- 2025
		____cond465 = ____cond465 or ____switch465 == "custom-node" -- 2025
		if ____cond465 then -- 2025
			return oldProps.onCreate ~= newProps.onCreate and "host" or nil -- 2027
		end -- 2027
		____cond465 = ____cond465 or ____switch465 == "body" -- 2027
		if ____cond465 then -- 2027
			return (oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement)) and "host" or nil -- 2029
		end -- 2029
	until true -- 2029
	return nil -- 2036
end -- 2036
function isEventProp(key) -- 2039
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 2040
end -- 2040
function getEventSlot(key) -- 2043
	repeat -- 2043
		local ____switch468 = key -- 2043
		local ____cond468 = ____switch468 == "onActionEnd" -- 2043
		if ____cond468 then -- 2043
			return "ActionEnd" -- 2045
		end -- 2045
		____cond468 = ____cond468 or ____switch468 == "onTapFilter" -- 2045
		if ____cond468 then -- 2045
			return "TapFilter" -- 2046
		end -- 2046
		____cond468 = ____cond468 or ____switch468 == "onTapBegan" -- 2046
		if ____cond468 then -- 2046
			return "TapBegan" -- 2047
		end -- 2047
		____cond468 = ____cond468 or ____switch468 == "onTapEnded" -- 2047
		if ____cond468 then -- 2047
			return "TapEnded" -- 2048
		end -- 2048
		____cond468 = ____cond468 or ____switch468 == "onTapped" -- 2048
		if ____cond468 then -- 2048
			return "Tapped" -- 2049
		end -- 2049
		____cond468 = ____cond468 or ____switch468 == "onTapMoved" -- 2049
		if ____cond468 then -- 2049
			return "TapMoved" -- 2050
		end -- 2050
		____cond468 = ____cond468 or ____switch468 == "onMouseMove" -- 2050
		if ____cond468 then -- 2050
			return "MouseMove" -- 2051
		end -- 2051
		____cond468 = ____cond468 or ____switch468 == "onMouseWheel" -- 2051
		if ____cond468 then -- 2051
			return "MouseWheel" -- 2052
		end -- 2052
		____cond468 = ____cond468 or ____switch468 == "onGesture" -- 2052
		if ____cond468 then -- 2052
			return "Gesture" -- 2053
		end -- 2053
		____cond468 = ____cond468 or ____switch468 == "onEnter" -- 2053
		if ____cond468 then -- 2053
			return "Enter" -- 2054
		end -- 2054
		____cond468 = ____cond468 or ____switch468 == "onExit" -- 2054
		if ____cond468 then -- 2054
			return "Exit" -- 2055
		end -- 2055
		____cond468 = ____cond468 or ____switch468 == "onCleanup" -- 2055
		if ____cond468 then -- 2055
			return "Cleanup" -- 2056
		end -- 2056
		____cond468 = ____cond468 or ____switch468 == "onKeyDown" -- 2056
		if ____cond468 then -- 2056
			return "KeyDown" -- 2057
		end -- 2057
		____cond468 = ____cond468 or ____switch468 == "onKeyUp" -- 2057
		if ____cond468 then -- 2057
			return "KeyUp" -- 2058
		end -- 2058
		____cond468 = ____cond468 or ____switch468 == "onKeyPressed" -- 2058
		if ____cond468 then -- 2058
			return "KeyPressed" -- 2059
		end -- 2059
		____cond468 = ____cond468 or ____switch468 == "onAttachIME" -- 2059
		if ____cond468 then -- 2059
			return "AttachIME" -- 2060
		end -- 2060
		____cond468 = ____cond468 or ____switch468 == "onDetachIME" -- 2060
		if ____cond468 then -- 2060
			return "DetachIME" -- 2061
		end -- 2061
		____cond468 = ____cond468 or ____switch468 == "onTextInput" -- 2061
		if ____cond468 then -- 2061
			return "TextInput" -- 2062
		end -- 2062
		____cond468 = ____cond468 or ____switch468 == "onTextEditing" -- 2062
		if ____cond468 then -- 2062
			return "TextEditing" -- 2063
		end -- 2063
		____cond468 = ____cond468 or ____switch468 == "onButtonDown" -- 2063
		if ____cond468 then -- 2063
			return "ButtonDown" -- 2064
		end -- 2064
		____cond468 = ____cond468 or ____switch468 == "onButtonUp" -- 2064
		if ____cond468 then -- 2064
			return "ButtonUp" -- 2065
		end -- 2065
		____cond468 = ____cond468 or ____switch468 == "onAxis" -- 2065
		if ____cond468 then -- 2065
			return "Axis" -- 2066
		end -- 2066
		____cond468 = ____cond468 or ____switch468 == "onAnimationEnd" -- 2066
		if ____cond468 then -- 2066
			return "AnimationEnd" -- 2067
		end -- 2067
		____cond468 = ____cond468 or ____switch468 == "onFinished" -- 2067
		if ____cond468 then -- 2067
			return "Finished" -- 2068
		end -- 2068
		____cond468 = ____cond468 or ____switch468 == "onLayout" -- 2068
		if ____cond468 then -- 2068
			return "AlignLayout" -- 2069
		end -- 2069
		____cond468 = ____cond468 or ____switch468 == "onBodyEnter" -- 2069
		if ____cond468 then -- 2069
			return "BodyEnter" -- 2070
		end -- 2070
		____cond468 = ____cond468 or ____switch468 == "onBodyLeave" -- 2070
		if ____cond468 then -- 2070
			return "BodyLeave" -- 2071
		end -- 2071
		____cond468 = ____cond468 or ____switch468 == "onContactStart" -- 2071
		if ____cond468 then -- 2071
			return "ContactStart" -- 2072
		end -- 2072
		____cond468 = ____cond468 or ____switch468 == "onContactEnd" -- 2072
		if ____cond468 then -- 2072
			return "ContactEnd" -- 2073
		end -- 2073
	until true -- 2073
	return nil -- 2075
end -- 2075
function isPatchableEventProp(key) -- 2078
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 2079
end -- 2079
function patchEventProp(node, key, value) -- 2082
	local slotName = getEventSlot(key) -- 2083
	if slotName == nil then -- 2083
		return -- 2084
	end -- 2084
	node:slot(slotName):clear() -- 2085
	if value ~= nil then -- 2085
		if key == "onLayout" then -- 2085
			node:onAlignLayout(value) -- 2088
		else -- 2088
			node:slot(slotName, value) -- 2090
		end -- 2090
	end -- 2090
end -- 2090
function patchContactFilterProp(node, value) -- 2095
	local body = Dora.tolua.cast(node, "Body") -- 2096
	if body == nil then -- 2096
		return -- 2097
	end -- 2097
	if value == nil then -- 2097
		body:onContactFilter(function() return true end) -- 2099
	else -- 2099
		body:onContactFilter(value) -- 2101
	end -- 2101
end -- 2101
function patchUpdateProp(node, value) -- 2105
	if value == nil then -- 2105
		node:unschedule() -- 2107
	elseif type(value) == "thread" then -- 2107
		node:schedule(value) -- 2109
	else -- 2109
		node:schedule(value) -- 2111
	end -- 2111
end -- 2111
function patchRenderProp(node, value) -- 2115
	local clearRender = node.clearRender -- 2116
	if type(clearRender) == "function" then -- 2116
		clearRender(node) -- 2118
	end -- 2118
	if value == nil then -- 2118
		return -- 2121
	end -- 2121
	node:onRender(value) -- 2123
end -- 2123
function clearRemovedProp(node, key) -- 2126
	repeat -- 2126
		local ____switch488 = key -- 2126
		local ____cond488 = ____switch488 == "transformTarget" or ____switch488 == "stencil" -- 2126
		if ____cond488 then -- 2126
			node[key] = nil -- 2130
			return true -- 2131
		end -- 2131
	until true -- 2131
	return false -- 2133
end -- 2133
function getAlignStyleText(style) -- 2136
	local items = {} -- 2137
	for k, v in pairs(style) do -- 2138
		local name = string.gsub(k, "%u", "-%1") -- 2139
		name = string.lower(name) -- 2140
		repeat -- 2140
			local ____switch491 = k -- 2140
			local ____cond491 = ____switch491 == "margin" or ____switch491 == "padding" or ____switch491 == "border" or ____switch491 == "gap" -- 2140
			if ____cond491 then -- 2140
				do -- 2140
					if type(v) == "table" then -- 2140
						local valueStr = table.concat( -- 2145
							__TS__ArrayMap( -- 2145
								v, -- 2145
								function(____, item) return tostring(item) end -- 2145
							), -- 2145
							"," -- 2145
						) -- 2145
						items[#items + 1] = (name .. ":") .. valueStr -- 2146
					else -- 2146
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2148
					end -- 2148
					break -- 2150
				end -- 2150
			end -- 2150
			do -- 2150
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2153
				break -- 2154
			end -- 2154
		until true -- 2154
	end -- 2154
	return table.concat(items, ";") -- 2157
end -- 2157
function patchPlayableProps(node, oldProps, newProps) -- 2160
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2160
		node:play(newProps.play, newProps.loop == true) -- 2162
	end -- 2162
end -- 2162
function patchAudioSourceProps(node, oldProps, newProps) -- 2166
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2166
		local audio = node -- 2168
		repeat -- 2168
			local ____switch500 = newProps.playMode -- 2168
			local ____cond500 = ____switch500 == "normal" -- 2168
			if ____cond500 then -- 2168
				local ____audio_play_65 = audio.play -- 2170
				local ____newProps_delayTime_64 = newProps.delayTime -- 2170
				if ____newProps_delayTime_64 == nil then -- 2170
					____newProps_delayTime_64 = 0 -- 2170
				end -- 2170
				____audio_play_65(audio, ____newProps_delayTime_64) -- 2170
				break -- 2170
			end -- 2170
			____cond500 = ____cond500 or ____switch500 == "background" -- 2170
			if ____cond500 then -- 2170
				audio:playBackground() -- 2171
				break -- 2171
			end -- 2171
			____cond500 = ____cond500 or ____switch500 == "3D" -- 2171
			if ____cond500 then -- 2171
				local ____audio_play3D_67 = audio.play3D -- 2172
				local ____newProps_delayTime_66 = newProps.delayTime -- 2172
				if ____newProps_delayTime_66 == nil then -- 2172
					____newProps_delayTime_66 = 0 -- 2172
				end -- 2172
				____audio_play3D_67(audio, ____newProps_delayTime_66) -- 2172
				break -- 2172
			end -- 2172
		until true -- 2172
	end -- 2172
end -- 2172
function patchParticleProps(node, oldProps, newProps) -- 2177
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2177
		local particle = node -- 2179
		if newProps.emit then -- 2179
			particle:start() -- 2181
		else -- 2181
			particle:stop() -- 2183
		end -- 2183
	end -- 2183
end -- 2183
function patchAlignNodeProps(node, oldProps, newProps) -- 2188
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2188
		node:css(getAlignStyleText(newProps.style)) -- 2190
	end -- 2190
end -- 2190
function patchLineProps(node, oldProps, newProps) -- 2194
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2194
		local ____self_71 = node -- 2194
		local ____self_71_set_72 = ____self_71.set -- 2194
		local ____newProps_verts_70 = newProps.verts -- 2196
		local ____Dora_Color_69 = Dora.Color -- 2196
		local ____newProps_lineColor_68 = newProps.lineColor -- 2196
		if ____newProps_lineColor_68 == nil then -- 2196
			____newProps_lineColor_68 = 4294967295 -- 2196
		end -- 2196
		____self_71_set_72( -- 2196
			____self_71, -- 2196
			____newProps_verts_70, -- 2196
			____Dora_Color_69(____newProps_lineColor_68) -- 2196
		) -- 2196
	end -- 2196
end -- 2196
function clearRef(props, node) -- 2200
	local ref = props.ref -- 2201
	if ref ~= nil and (node == nil or ref.current == node) then -- 2201
		ref.current = nil -- 2203
	end -- 2203
end -- 2203
function patchRef(node, oldProps, newProps) -- 2207
	if oldProps.ref ~= newProps.ref then -- 2207
		clearRef(oldProps, node) -- 2209
		local ref = newProps.ref -- 2210
		if ref ~= nil then -- 2210
			ref.current = node -- 2212
		end -- 2212
	end -- 2212
end -- 2212
function applyProp(node, enode, key, value) -- 2217
	local name = key -- 2218
	repeat -- 2218
		local ____switch515 = name -- 2218
		local ____cond515 = ____switch515 == "key" or ____switch515 == "children" or ____switch515 == "onMount" or ____switch515 == "onUnmount" -- 2218
		if ____cond515 then -- 2218
			return -- 2224
		end -- 2224
		____cond515 = ____cond515 or ____switch515 == "ref" -- 2224
		if ____cond515 then -- 2224
			value.current = node -- 2226
			return -- 2227
		end -- 2227
		____cond515 = ____cond515 or ____switch515 == "anchorX" -- 2227
		if ____cond515 then -- 2227
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2229
			return -- 2230
		end -- 2230
		____cond515 = ____cond515 or ____switch515 == "anchorY" -- 2230
		if ____cond515 then -- 2230
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2232
			return -- 2233
		end -- 2233
		____cond515 = ____cond515 or ____switch515 == "color3" -- 2233
		if ____cond515 then -- 2233
			node.color3 = Dora.Color3(value) -- 2235
			return -- 2236
		end -- 2236
		____cond515 = ____cond515 or ____switch515 == "transformTarget" -- 2236
		if ____cond515 then -- 2236
			node.transformTarget = value.current -- 2238
			return -- 2239
		end -- 2239
		____cond515 = ____cond515 or ____switch515 == "outlineColor" -- 2239
		if ____cond515 then -- 2239
			node[name] = Dora.Color(value) -- 2241
			return -- 2242
		end -- 2242
		____cond515 = ____cond515 or ____switch515 == "smoothLower" -- 2242
		if ____cond515 then -- 2242
			do -- 2242
				local smooth = node.smooth -- 2244
				node.smooth = Dora.Vec2(value, smooth.y) -- 2245
				return -- 2246
			end -- 2246
		end -- 2246
		____cond515 = ____cond515 or ____switch515 == "smoothUpper" -- 2246
		if ____cond515 then -- 2246
			do -- 2246
				local smooth = node.smooth -- 2249
				node.smooth = Dora.Vec2(smooth.x, value) -- 2250
				return -- 2251
			end -- 2251
		end -- 2251
	until true -- 2251
	if isEventProp(key) then -- 2251
		if key == "onUpdate" then -- 2251
			patchUpdateProp(node, value) -- 2256
		elseif key == "onRender" then -- 2256
			patchRenderProp(node, value) -- 2258
		elseif key == "onContactFilter" then -- 2258
			patchContactFilterProp(node, value) -- 2260
		elseif isPatchableEventProp(key) then -- 2260
			patchEventProp(node, key, value) -- 2262
		end -- 2262
		return -- 2264
	end -- 2264
	node[name] = value -- 2266
end -- 2266
function patchProps(node, oldElement, newElement) -- 2269
	local oldProps = oldElement.props -- 2270
	local newProps = newElement.props -- 2271
	for k in pairs(oldProps) do -- 2272
		if k == "onUpdate" and newProps[k] == nil then -- 2272
			patchUpdateProp(node, nil) -- 2274
		elseif k == "onRender" and newProps[k] == nil then -- 2274
			patchRenderProp(node, nil) -- 2276
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2276
			patchContactFilterProp(node, nil) -- 2278
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2278
			patchEventProp(node, k, nil) -- 2280
		elseif newProps[k] == nil then -- 2280
			clearRemovedProp(node, k) -- 2282
		end -- 2282
	end -- 2282
	patchRef(node, oldProps, newProps) -- 2285
	for k, v in pairs(newProps) do -- 2286
		if k ~= "ref" and oldProps[k] ~= v then -- 2286
			applyProp(node, newElement, k, v) -- 2288
		end -- 2288
	end -- 2288
	if newElement.type == "label" then -- 2288
		node.text = getPrimitiveLabelText(newElement) -- 2292
	elseif newElement.type == "physics-world" then -- 2292
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2294
		if world ~= nil then -- 2294
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2296
		end -- 2296
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2296
		patchPlayableProps(node, oldProps, newProps) -- 2304
	elseif newElement.type == "audio-source" then -- 2304
		patchAudioSourceProps(node, oldProps, newProps) -- 2306
	elseif newElement.type == "particle" then -- 2306
		patchParticleProps(node, oldProps, newProps) -- 2308
	elseif newElement.type == "align-node" then -- 2308
		patchAlignNodeProps(node, oldProps, newProps) -- 2310
	elseif newElement.type == "line" then -- 2310
		patchLineProps(node, oldProps, newProps) -- 2312
	end -- 2312
	applyAutoEnableProps(node, newProps) -- 2314
end -- 2314
function addChildToParent(parent, node, props) -- 2317
	if props.tag ~= nil then -- 2317
		parent:addChild(node, props.order or 0, props.tag) -- 2319
	elseif props.order ~= nil then -- 2319
		parent:addChild(node, props.order) -- 2321
	else -- 2321
		parent:addChild(node) -- 2323
	end -- 2323
end -- 2323
function mountElement(parent, enode) -- 2327
	local node = createHostNode(enode, parent) -- 2328
	if node == nil then -- 2328
		return nil -- 2330
	end -- 2330
	if isDrawShapeElement(enode) then -- 2330
		return nil -- 2333
	end -- 2333
	local props = enode.props -- 2335
	addChildToParent(parent, node, props) -- 2336
	local mounted = {element = enode, node = node, children = {}} -- 2337
	runActionChildren(node, enode) -- 2338
	mounted.children = reconcileChildren( -- 2339
		node, -- 2339
		{}, -- 2339
		getElementChildren(enode) -- 2339
	) -- 2339
	return mounted -- 2340
end -- 2340
function unmountHostElement(mounted) -- 2343
	local props = mounted.element.props -- 2344
	if props.onUnmount ~= nil then -- 2344
		props.onUnmount(mounted.node) -- 2346
	end -- 2346
	clearRef(mounted.element.props, mounted.node) -- 2348
	mounted.node:removeFromParent(true) -- 2349
end -- 2349
function unmountElement(mounted) -- 2352
	for i = 1, #mounted.children do -- 2352
		unmountElement(mounted.children[i]) -- 2354
	end -- 2354
	unmountHostElement(mounted) -- 2356
end -- 2356
function reconcileElement(parent, oldMounted, newElement) -- 2359
	if oldMounted == nil then -- 2359
		return mountElement(parent, newElement) -- 2361
	end -- 2361
	local recreateMode = getRecreateMode(oldMounted.element, newElement) -- 2363
	if recreateMode == "subtree" then -- 2363
		local oldNode = oldMounted.node -- 2365
		local oldOrder = oldNode.order -- 2366
		local oldTag = oldNode.tag -- 2367
		unmountElement(oldMounted) -- 2368
		local mounted = mountElement(parent, newElement) -- 2369
		if mounted ~= nil then -- 2369
			mounted.node.order = newElement.props.order or oldOrder -- 2371
			mounted.node.tag = newElement.props.tag or oldTag -- 2372
		end -- 2372
		return mounted -- 2374
	end -- 2374
	if recreateMode == "host" then -- 2374
		local oldNode = oldMounted.node -- 2377
		local oldOrder = oldNode.order -- 2378
		local oldTag = oldNode.tag -- 2379
		local node = createHostNode(newElement, parent) -- 2380
		if node == nil then -- 2380
			unmountElement(oldMounted) -- 2382
			return nil -- 2383
		end -- 2383
		addChildToParent(parent, node, newElement.props) -- 2385
		node.order = newElement.props.order or oldOrder -- 2386
		node.tag = newElement.props.tag or oldTag -- 2387
		runActionChildren(node, newElement) -- 2388
		for i = 1, #oldMounted.children do -- 2388
			oldMounted.children[i].node:moveToParent(node) -- 2390
		end -- 2390
		unmountHostElement(oldMounted) -- 2392
		oldMounted.node = node -- 2393
		oldMounted.children = reconcileChildren( -- 2394
			node, -- 2394
			oldMounted.children, -- 2394
			getElementChildren(newElement) -- 2394
		) -- 2394
		oldMounted.element = newElement -- 2395
		return oldMounted -- 2396
	end -- 2396
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2398
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2399
	oldMounted.children = reconcileChildren( -- 2400
		oldMounted.node, -- 2400
		oldMounted.children, -- 2400
		getElementChildren(newElement) -- 2400
	) -- 2400
	oldMounted.element = newElement -- 2401
	return oldMounted -- 2402
end -- 2402
function reconcileChildren(parent, oldChildren, newElements) -- 2405
	warnUnkeyedDynamicChildren(oldChildren, newElements) -- 2406
	local oldByKey = {} -- 2407
	local usedOld = {} -- 2408
	for i = 1, #oldChildren do -- 2408
		local oldChild = oldChildren[i] -- 2410
		local key = getElementKey(oldChild.element) -- 2411
		if key ~= nil then -- 2411
			oldByKey[key] = oldChild -- 2413
		end -- 2413
	end -- 2413
	local nextChildren = {} -- 2416
	for i = 1, #newElements do -- 2416
		local newElement = newElements[i] -- 2418
		local key = getElementKey(newElement) -- 2419
		local oldChild -- 2420
		if key ~= nil then -- 2420
			oldChild = oldByKey[key] -- 2422
		else -- 2422
			oldChild = oldChildren[i] -- 2424
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2424
				oldChild = nil -- 2426
			end -- 2426
		end -- 2426
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2429
		if mounted ~= nil then -- 2429
			usedOld[mounted] = true -- 2431
			nextChildren[#nextChildren + 1] = mounted -- 2432
			local props = newElement.props -- 2433
			mounted.node.order = props.order or i -- 2434
			if props.tag ~= nil then -- 2434
				mounted.node.tag = props.tag -- 2435
			end -- 2435
		end -- 2435
	end -- 2435
	for i = 1, #oldChildren do -- 2435
		local oldChild = oldChildren[i] -- 2439
		if not usedOld[oldChild] then -- 2439
			unmountElement(oldChild) -- 2441
		end -- 2441
	end -- 2441
	return nextChildren -- 2444
end -- 2444
____exports.React = {} -- 2444
local React = ____exports.React -- 2444
do -- 2444
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
	getVideoNode = function(enode) -- 515
		local vn = enode.props -- 516
		local ____Dora_VideoNode_13 = Dora.VideoNode -- 517
		local ____vn_file_12 = vn.file -- 517
		local ____vn_looped_11 = vn.looped -- 517
		if ____vn_looped_11 == nil then -- 517
			____vn_looped_11 = false -- 517
		end -- 517
		local node = ____Dora_VideoNode_13(____vn_file_12, ____vn_looped_11) -- 517
		if node ~= nil then -- 517
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 519
			return cnode -- 520
		end -- 520
		return nil -- 522
	end -- 515
	getTIC80Node = function(enode) -- 524
		local tic = enode.props -- 525
		local node = Dora.TIC80Node(tic.file) -- 526
		if node ~= nil then -- 526
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 528
			return cnode -- 529
		end -- 529
		return nil -- 531
	end -- 524
end -- 524
local getAudioSource -- 535
do -- 535
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 537
		repeat -- 537
			local ____switch111 = k -- 537
			local ____cond111 = ____switch111 == "file" -- 537
			if ____cond111 then -- 537
				return true -- 539
			end -- 539
			____cond111 = ____cond111 or ____switch111 == "autoRemove" -- 539
			if ____cond111 then -- 539
				return true -- 540
			end -- 540
			____cond111 = ____cond111 or ____switch111 == "bus" -- 540
			if ____cond111 then -- 540
				return true -- 541
			end -- 541
			____cond111 = ____cond111 or ____switch111 == "volume" -- 541
			if ____cond111 then -- 541
				cnode.volume = v -- 542
				return true -- 542
			end -- 542
			____cond111 = ____cond111 or ____switch111 == "pan" -- 542
			if ____cond111 then -- 542
				cnode.pan = v -- 543
				return true -- 543
			end -- 543
			____cond111 = ____cond111 or ____switch111 == "looping" -- 543
			if ____cond111 then -- 543
				cnode.looping = v -- 544
				return true -- 544
			end -- 544
			____cond111 = ____cond111 or ____switch111 == "playMode" -- 544
			if ____cond111 then -- 544
				do -- 544
					local aus = enode.props -- 546
					repeat -- 546
						local ____switch113 = v -- 546
						local ____cond113 = ____switch113 == "normal" -- 546
						if ____cond113 then -- 546
							cnode:play(aus.delayTime or 0) -- 548
							break -- 548
						end -- 548
						____cond113 = ____cond113 or ____switch113 == "background" -- 548
						if ____cond113 then -- 548
							cnode:playBackground() -- 549
							break -- 549
						end -- 549
						____cond113 = ____cond113 or ____switch113 == "3D" -- 549
						if ____cond113 then -- 549
							cnode:play3D(aus.delayTime or 0) -- 550
							break -- 550
						end -- 550
					until true -- 550
					return true -- 552
				end -- 552
			end -- 552
			____cond111 = ____cond111 or ____switch111 == "delayTime" -- 552
			if ____cond111 then -- 552
				return true -- 554
			end -- 554
			____cond111 = ____cond111 or ____switch111 == "protected" -- 554
			if ____cond111 then -- 554
				cnode:setProtected(v) -- 555
				return true -- 555
			end -- 555
			____cond111 = ____cond111 or ____switch111 == "loopPoint" -- 555
			if ____cond111 then -- 555
				cnode:setLoopPoint(v) -- 556
				return true -- 556
			end -- 556
			____cond111 = ____cond111 or ____switch111 == "velocity" -- 556
			if ____cond111 then -- 556
				do -- 556
					local vx, vy, vz = table.unpack(v, 1, 3) -- 558
					cnode:setVelocity(vx, vy, vz) -- 559
					return true -- 560
				end -- 560
			end -- 560
			____cond111 = ____cond111 or ____switch111 == "minMaxDistance" -- 560
			if ____cond111 then -- 560
				do -- 560
					local min, max = table.unpack(v, 1, 2) -- 563
					cnode:setMinMaxDistance(min, max) -- 564
					return true -- 565
				end -- 565
			end -- 565
			____cond111 = ____cond111 or ____switch111 == "attenuation" -- 565
			if ____cond111 then -- 565
				do -- 565
					local model, factor = table.unpack(v, 1, 2) -- 568
					cnode:setAttenuation(model, factor) -- 569
					return true -- 570
				end -- 570
			end -- 570
			____cond111 = ____cond111 or ____switch111 == "dopplerFactor" -- 570
			if ____cond111 then -- 570
				cnode:setDopplerFactor(v) -- 572
				return true -- 572
			end -- 572
		until true -- 572
		return false -- 574
	end -- 537
	getAudioSource = function(enode) -- 576
		local aus = enode.props -- 577
		local ____aus_autoRemove_14 = aus.autoRemove -- 578
		if ____aus_autoRemove_14 == nil then -- 578
			____aus_autoRemove_14 = true -- 578
		end -- 578
		local autoRemove = ____aus_autoRemove_14 -- 578
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 579
		if node ~= nil then -- 579
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 581
			return cnode -- 582
		end -- 582
		return nil -- 584
	end -- 576
end -- 576
local getLabel -- 588
do -- 588
	local function handleLabelAttribute(cnode, _enode, k, v) -- 590
		repeat -- 590
			local ____switch121 = k -- 590
			local ____cond121 = ____switch121 == "fontName" or ____switch121 == "fontSize" or ____switch121 == "text" or ____switch121 == "smoothLower" or ____switch121 == "smoothUpper" -- 590
			if ____cond121 then -- 590
				return true -- 592
			end -- 592
			____cond121 = ____cond121 or ____switch121 == "alphaRef" -- 592
			if ____cond121 then -- 592
				cnode.alphaRef = v -- 593
				return true -- 593
			end -- 593
			____cond121 = ____cond121 or ____switch121 == "textWidth" -- 593
			if ____cond121 then -- 593
				cnode.textWidth = v -- 594
				return true -- 594
			end -- 594
			____cond121 = ____cond121 or ____switch121 == "lineGap" -- 594
			if ____cond121 then -- 594
				cnode.lineGap = v -- 595
				return true -- 595
			end -- 595
			____cond121 = ____cond121 or ____switch121 == "spacing" -- 595
			if ____cond121 then -- 595
				cnode.spacing = v -- 596
				return true -- 596
			end -- 596
			____cond121 = ____cond121 or ____switch121 == "outlineColor" -- 596
			if ____cond121 then -- 596
				cnode.outlineColor = Dora.Color(v) -- 597
				return true -- 597
			end -- 597
			____cond121 = ____cond121 or ____switch121 == "outlineWidth" -- 597
			if ____cond121 then -- 597
				cnode.outlineWidth = v -- 598
				return true -- 598
			end -- 598
			____cond121 = ____cond121 or ____switch121 == "blendFunc" -- 598
			if ____cond121 then -- 598
				cnode.blendFunc = v -- 599
				return true -- 599
			end -- 599
			____cond121 = ____cond121 or ____switch121 == "depthWrite" -- 599
			if ____cond121 then -- 599
				cnode.depthWrite = v -- 600
				return true -- 600
			end -- 600
			____cond121 = ____cond121 or ____switch121 == "batched" -- 600
			if ____cond121 then -- 600
				cnode.batched = v -- 601
				return true -- 601
			end -- 601
			____cond121 = ____cond121 or ____switch121 == "effect" -- 601
			if ____cond121 then -- 601
				cnode.effect = v -- 602
				return true -- 602
			end -- 602
			____cond121 = ____cond121 or ____switch121 == "alignment" -- 602
			if ____cond121 then -- 602
				cnode.alignment = v -- 603
				return true -- 603
			end -- 603
		until true -- 603
		return false -- 605
	end -- 590
	getLabel = function(enode) -- 607
		local label = enode.props -- 608
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf ~= false) -- 609
		if node ~= nil then -- 609
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 609
				local ____node_smooth_15 = node.smooth -- 612
				local x = ____node_smooth_15.x -- 612
				local y = ____node_smooth_15.y -- 612
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 613
			end -- 613
			local cnode = getNode(enode, node, handleLabelAttribute) -- 615
			local ____enode_16 = enode -- 616
			local children = ____enode_16.children -- 616
			local text = label.text or "" -- 617
			for i = 1, #children do -- 617
				local child = children[i] -- 619
				if type(child) ~= "table" then -- 619
					text = text .. tostring(child) -- 621
				end -- 621
			end -- 621
			node.text = text -- 624
			return cnode -- 625
		end -- 625
		return nil -- 627
	end -- 607
end -- 607
local getLine -- 631
do -- 631
	local function handleLineAttribute(cnode, enode, k, v) -- 633
		local line = enode.props -- 634
		repeat -- 634
			local ____switch129 = k -- 634
			local ____cond129 = ____switch129 == "verts" -- 634
			if ____cond129 then -- 634
				cnode:set( -- 636
					v, -- 636
					Dora.Color(line.lineColor or 4294967295) -- 636
				) -- 636
				return true -- 636
			end -- 636
			____cond129 = ____cond129 or ____switch129 == "depthWrite" -- 636
			if ____cond129 then -- 636
				cnode.depthWrite = v -- 637
				return true -- 637
			end -- 637
			____cond129 = ____cond129 or ____switch129 == "blendFunc" -- 637
			if ____cond129 then -- 637
				cnode.blendFunc = v -- 638
				return true -- 638
			end -- 638
		until true -- 638
		return false -- 640
	end -- 633
	getLine = function(enode) -- 642
		local node = Dora.Line() -- 643
		local cnode = getNode(enode, node, handleLineAttribute) -- 644
		return cnode -- 645
	end -- 642
end -- 642
local getParticle -- 649
do -- 649
	local function handleParticleAttribute(cnode, _enode, k, v) -- 651
		repeat -- 651
			local ____switch133 = k -- 651
			local ____cond133 = ____switch133 == "file" -- 651
			if ____cond133 then -- 651
				return true -- 653
			end -- 653
			____cond133 = ____cond133 or ____switch133 == "emit" -- 653
			if ____cond133 then -- 653
				if v then -- 653
					cnode:start() -- 654
				end -- 654
				return true -- 654
			end -- 654
			____cond133 = ____cond133 or ____switch133 == "onFinished" -- 654
			if ____cond133 then -- 654
				cnode:slot("Finished", v) -- 655
				return true -- 655
			end -- 655
		until true -- 655
		return false -- 657
	end -- 651
	getParticle = function(enode) -- 659
		local particle = enode.props -- 660
		local node = Dora.Particle(particle.file) -- 661
		if node ~= nil then -- 661
			local cnode = getNode(enode, node, handleParticleAttribute) -- 663
			return cnode -- 664
		end -- 664
		return nil -- 666
	end -- 659
end -- 659
local getMenu -- 670
do -- 670
	local function handleMenuAttribute(cnode, _enode, k, v) -- 672
		repeat -- 672
			local ____switch139 = k -- 672
			local ____cond139 = ____switch139 == "enabled" -- 672
			if ____cond139 then -- 672
				cnode.enabled = v -- 674
				return true -- 674
			end -- 674
		until true -- 674
		return false -- 676
	end -- 672
	getMenu = function(enode) -- 678
		local node = Dora.Menu() -- 679
		local cnode = getNode(enode, node, handleMenuAttribute) -- 680
		return cnode -- 681
	end -- 678
end -- 678
local function getPhysicsWorld(enode) -- 685
	local node = Dora.PhysicsWorld() -- 686
	local cnode = getNode(enode, node) -- 687
	return cnode -- 688
end -- 685
local getBody -- 691
do -- 691
	local function handleBodyAttribute(cnode, _enode, k, v) -- 693
		repeat -- 693
			local ____switch144 = k -- 693
			local ____cond144 = ____switch144 == "type" or ____switch144 == "linearAcceleration" or ____switch144 == "fixedRotation" or ____switch144 == "bullet" or ____switch144 == "world" -- 693
			if ____cond144 then -- 693
				return true -- 700
			end -- 700
			____cond144 = ____cond144 or ____switch144 == "velocityX" -- 700
			if ____cond144 then -- 700
				cnode.velocityX = v -- 701
				return true -- 701
			end -- 701
			____cond144 = ____cond144 or ____switch144 == "velocityY" -- 701
			if ____cond144 then -- 701
				cnode.velocityY = v -- 702
				return true -- 702
			end -- 702
			____cond144 = ____cond144 or ____switch144 == "angularRate" -- 702
			if ____cond144 then -- 702
				cnode.angularRate = v -- 703
				return true -- 703
			end -- 703
			____cond144 = ____cond144 or ____switch144 == "group" -- 703
			if ____cond144 then -- 703
				cnode.group = v -- 704
				return true -- 704
			end -- 704
			____cond144 = ____cond144 or ____switch144 == "linearDamping" -- 704
			if ____cond144 then -- 704
				cnode.linearDamping = v -- 705
				return true -- 705
			end -- 705
			____cond144 = ____cond144 or ____switch144 == "angularDamping" -- 705
			if ____cond144 then -- 705
				cnode.angularDamping = v -- 706
				return true -- 706
			end -- 706
			____cond144 = ____cond144 or ____switch144 == "owner" -- 706
			if ____cond144 then -- 706
				cnode.owner = v -- 707
				return true -- 707
			end -- 707
			____cond144 = ____cond144 or ____switch144 == "receivingContact" -- 707
			if ____cond144 then -- 707
				cnode.receivingContact = v -- 708
				return true -- 708
			end -- 708
			____cond144 = ____cond144 or ____switch144 == "onBodyEnter" -- 708
			if ____cond144 then -- 708
				cnode:slot("BodyEnter", v) -- 709
				return true -- 709
			end -- 709
			____cond144 = ____cond144 or ____switch144 == "onBodyLeave" -- 709
			if ____cond144 then -- 709
				cnode:slot("BodyLeave", v) -- 710
				return true -- 710
			end -- 710
			____cond144 = ____cond144 or ____switch144 == "onContactStart" -- 710
			if ____cond144 then -- 710
				cnode:slot("ContactStart", v) -- 711
				return true -- 711
			end -- 711
			____cond144 = ____cond144 or ____switch144 == "onContactEnd" -- 711
			if ____cond144 then -- 711
				cnode:slot("ContactEnd", v) -- 712
				return true -- 712
			end -- 712
			____cond144 = ____cond144 or ____switch144 == "onContactFilter" -- 712
			if ____cond144 then -- 712
				cnode:onContactFilter(v) -- 713
				return true -- 713
			end -- 713
		until true -- 713
		return false -- 715
	end -- 693
	getBody = function(enode, world) -- 717
		local def = enode.props -- 718
		local bodyDef = Dora.BodyDef() -- 719
		bodyDef.type = def.type -- 720
		if def.angle ~= nil then -- 720
			bodyDef.angle = def.angle -- 721
		end -- 721
		if def.angularDamping ~= nil then -- 721
			bodyDef.angularDamping = def.angularDamping -- 722
		end -- 722
		if def.bullet ~= nil then -- 722
			bodyDef.bullet = def.bullet -- 723
		end -- 723
		if def.fixedRotation ~= nil then -- 723
			bodyDef.fixedRotation = def.fixedRotation -- 724
		end -- 724
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 725
		if def.linearDamping ~= nil then -- 725
			bodyDef.linearDamping = def.linearDamping -- 726
		end -- 726
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 727
		local extraSensors -- 728
		for i = 1, #enode.children do -- 728
			do -- 728
				local child = enode.children[i] -- 730
				if type(child) ~= "table" then -- 730
					goto __continue151 -- 732
				end -- 732
				repeat -- 732
					local ____switch153 = child.type -- 732
					local ____cond153 = ____switch153 == "rect-fixture" -- 732
					if ____cond153 then -- 732
						do -- 732
							local shape = child.props -- 736
							if shape.sensorTag ~= nil then -- 736
								bodyDef:attachPolygonSensor( -- 738
									shape.sensorTag, -- 739
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 740
									shape.width, -- 741
									shape.height, -- 741
									shape.angle or 0 -- 742
								) -- 742
							else -- 742
								bodyDef:attachPolygon( -- 745
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 746
									shape.width, -- 747
									shape.height, -- 747
									shape.angle or 0, -- 748
									shape.density or 1, -- 749
									shape.friction or 0.4, -- 750
									shape.restitution or 0 -- 751
								) -- 751
							end -- 751
							break -- 754
						end -- 754
					end -- 754
					____cond153 = ____cond153 or ____switch153 == "polygon-fixture" -- 754
					if ____cond153 then -- 754
						do -- 754
							local shape = child.props -- 757
							if shape.sensorTag ~= nil then -- 757
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 759
							else -- 759
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 764
							end -- 764
							break -- 771
						end -- 771
					end -- 771
					____cond153 = ____cond153 or ____switch153 == "multi-fixture" -- 771
					if ____cond153 then -- 771
						do -- 771
							local shape = child.props -- 774
							if shape.sensorTag ~= nil then -- 774
								if extraSensors == nil then -- 774
									extraSensors = {} -- 776
								end -- 776
								extraSensors[#extraSensors + 1] = { -- 777
									shape.sensorTag, -- 777
									Dora.BodyDef:multi(shape.verts) -- 777
								} -- 777
							else -- 777
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 779
							end -- 779
							break -- 786
						end -- 786
					end -- 786
					____cond153 = ____cond153 or ____switch153 == "disk-fixture" -- 786
					if ____cond153 then -- 786
						do -- 786
							local shape = child.props -- 789
							if shape.sensorTag ~= nil then -- 789
								bodyDef:attachDiskSensor( -- 791
									shape.sensorTag, -- 792
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 793
									shape.radius -- 794
								) -- 794
							else -- 794
								bodyDef:attachDisk( -- 797
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 798
									shape.radius, -- 799
									shape.density or 1, -- 800
									shape.friction or 0.4, -- 801
									shape.restitution or 0 -- 802
								) -- 802
							end -- 802
							break -- 805
						end -- 805
					end -- 805
					____cond153 = ____cond153 or ____switch153 == "chain-fixture" -- 805
					if ____cond153 then -- 805
						do -- 805
							local shape = child.props -- 808
							if shape.sensorTag ~= nil then -- 808
								if extraSensors == nil then -- 808
									extraSensors = {} -- 810
								end -- 810
								extraSensors[#extraSensors + 1] = { -- 811
									shape.sensorTag, -- 811
									Dora.BodyDef:chain(shape.verts) -- 811
								} -- 811
							else -- 811
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 813
							end -- 813
							break -- 819
						end -- 819
					end -- 819
				until true -- 819
			end -- 819
			::__continue151:: -- 819
		end -- 819
		local body = Dora.Body(bodyDef, world) -- 823
		if extraSensors ~= nil then -- 823
			for i = 1, #extraSensors do -- 823
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 826
				body:attachSensor(tag, def) -- 827
			end -- 827
		end -- 827
		local cnode = getNode(enode, body, handleBodyAttribute) -- 830
		return cnode -- 831
	end -- 717
end -- 717
local getCustomNode -- 835
do -- 835
	local function handleCustomNode(_cnode, _enode, k, _v) -- 837
		repeat -- 837
			local ____switch173 = k -- 837
			local ____cond173 = ____switch173 == "onCreate" -- 837
			if ____cond173 then -- 837
				return true -- 839
			end -- 839
		until true -- 839
		return false -- 841
	end -- 837
	getCustomNode = function(enode) -- 843
		local custom = enode.props -- 844
		local node = custom.onCreate() -- 845
		if node then -- 845
			local cnode = getNode(enode, node, handleCustomNode) -- 847
			return cnode -- 848
		end -- 848
		return nil -- 850
	end -- 843
end -- 843
local getAlignNode -- 854
do -- 854
	local function handleAlignNode(_cnode, _enode, k, _v) -- 856
		repeat -- 856
			local ____switch178 = k -- 856
			local ____cond178 = ____switch178 == "windowRoot" -- 856
			if ____cond178 then -- 856
				return true -- 858
			end -- 858
			____cond178 = ____cond178 or ____switch178 == "style" -- 858
			if ____cond178 then -- 858
				return true -- 859
			end -- 859
			____cond178 = ____cond178 or ____switch178 == "onLayout" -- 859
			if ____cond178 then -- 859
				return true -- 860
			end -- 860
		until true -- 860
		return false -- 862
	end -- 856
	getAlignNode = function(enode) -- 864
		local alignNode = enode.props -- 865
		local node = Dora.AlignNode(alignNode.windowRoot) -- 866
		if alignNode.style then -- 866
			node:css(getAlignStyleText(alignNode.style)) -- 868
		end -- 868
		if alignNode.onLayout then -- 868
			node:onAlignLayout(alignNode.onLayout) -- 871
		end -- 871
		local cnode = getNode(enode, node, handleAlignNode) -- 873
		return cnode -- 874
	end -- 864
end -- 864
local function getEffekNode(enode) -- 878
	return getNode( -- 879
		enode, -- 879
		Dora.EffekNode() -- 879
	) -- 879
end -- 878
local getTileNode -- 882
do -- 882
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 884
		repeat -- 884
			local ____switch185 = k -- 884
			local ____cond185 = ____switch185 == "file" or ____switch185 == "layers" -- 884
			if ____cond185 then -- 884
				return true -- 886
			end -- 886
			____cond185 = ____cond185 or ____switch185 == "depthWrite" -- 886
			if ____cond185 then -- 886
				cnode.depthWrite = v -- 887
				return true -- 887
			end -- 887
			____cond185 = ____cond185 or ____switch185 == "blendFunc" -- 887
			if ____cond185 then -- 887
				cnode.blendFunc = v -- 888
				return true -- 888
			end -- 888
			____cond185 = ____cond185 or ____switch185 == "effect" -- 888
			if ____cond185 then -- 888
				cnode.effect = v -- 889
				return true -- 889
			end -- 889
			____cond185 = ____cond185 or ____switch185 == "filter" -- 889
			if ____cond185 then -- 889
				cnode.filter = v -- 890
				return true -- 890
			end -- 890
		until true -- 890
		return false -- 892
	end -- 884
	getTileNode = function(enode) -- 894
		local tn = enode.props -- 895
		local ____tn_layers_17 -- 896
		if tn.layers then -- 896
			____tn_layers_17 = Dora.TileNode(tn.file, tn.layers) -- 896
		else -- 896
			____tn_layers_17 = Dora.TileNode(tn.file) -- 896
		end -- 896
		local node = ____tn_layers_17 -- 896
		if node ~= nil then -- 896
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 898
			return cnode -- 899
		end -- 899
		return nil -- 901
	end -- 894
end -- 894
local function addChild(nodeStack, cnode, enode) -- 905
	if #nodeStack > 0 then -- 905
		local last = nodeStack[#nodeStack] -- 907
		last:addChild(cnode) -- 908
	end -- 908
	nodeStack[#nodeStack + 1] = cnode -- 910
	local ____enode_18 = enode -- 911
	local children = ____enode_18.children -- 911
	for i = 1, #children do -- 911
		visitNode(nodeStack, children[i], enode) -- 913
	end -- 913
	if #nodeStack > 1 then -- 913
		table.remove(nodeStack) -- 916
	end -- 916
end -- 905
local function drawNodeCheck(_nodeStack, enode, parent) -- 924
	if parent == nil or parent.type ~= "draw-node" then -- 924
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 926
	end -- 926
end -- 924
local function actionCheck(nodeStack, enode, parent) -- 987
	local unsupported = false -- 988
	if parent == nil then -- 988
		unsupported = true -- 990
	else -- 990
		repeat -- 990
			local ____switch210 = parent.type -- 990
			local ____cond210 = ____switch210 == "action" or ____switch210 == "spawn" or ____switch210 == "sequence" -- 990
			if ____cond210 then -- 990
				break -- 993
			end -- 993
			do -- 993
				unsupported = true -- 994
				break -- 994
			end -- 994
		until true -- 994
	end -- 994
	if unsupported then -- 994
		if #nodeStack > 0 then -- 994
			local node = nodeStack[#nodeStack] -- 999
			local actionStack = {} -- 1000
			visitAction(actionStack, enode) -- 1001
			if #actionStack == 1 then -- 1001
				node:runAction(actionStack[1]) -- 1003
			end -- 1003
		else -- 1003
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 1006
		end -- 1006
	end -- 1006
end -- 987
local function bodyCheck(_nodeStack, enode, parent) -- 1011
	if parent == nil or parent.type ~= "body" then -- 1011
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 1013
	end -- 1013
end -- 1011
actionMap = { -- 1017
	["anchor-x"] = Dora.AnchorX, -- 1020
	["anchor-y"] = Dora.AnchorY, -- 1021
	angle = Dora.Angle, -- 1022
	["angle-x"] = Dora.AngleX, -- 1023
	["angle-y"] = Dora.AngleY, -- 1024
	width = Dora.Width, -- 1025
	height = Dora.Height, -- 1026
	opacity = Dora.Opacity, -- 1027
	roll = Dora.Roll, -- 1028
	scale = Dora.Scale, -- 1029
	["scale-x"] = Dora.ScaleX, -- 1030
	["scale-y"] = Dora.ScaleY, -- 1031
	["skew-x"] = Dora.SkewX, -- 1032
	["skew-y"] = Dora.SkewY, -- 1033
	["move-x"] = Dora.X, -- 1034
	["move-y"] = Dora.Y, -- 1035
	["move-z"] = Dora.Z -- 1036
} -- 1036
elementMap = { -- 1039
	node = function(nodeStack, enode, parent) -- 1040
		addChild( -- 1041
			nodeStack, -- 1041
			getNode(enode), -- 1041
			enode -- 1041
		) -- 1041
	end, -- 1040
	["clip-node"] = function(nodeStack, enode, parent) -- 1043
		addChild( -- 1044
			nodeStack, -- 1044
			getClipNode(enode), -- 1044
			enode -- 1044
		) -- 1044
	end, -- 1043
	playable = function(nodeStack, enode, parent) -- 1046
		local cnode = getPlayable(enode) -- 1047
		if cnode ~= nil then -- 1047
			addChild(nodeStack, cnode, enode) -- 1049
		end -- 1049
	end, -- 1046
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1052
		local cnode = getDragonBone(enode) -- 1053
		if cnode ~= nil then -- 1053
			addChild(nodeStack, cnode, enode) -- 1055
		end -- 1055
	end, -- 1052
	spine = function(nodeStack, enode, parent) -- 1058
		local cnode = getSpine(enode) -- 1059
		if cnode ~= nil then -- 1059
			addChild(nodeStack, cnode, enode) -- 1061
		end -- 1061
	end, -- 1058
	model = function(nodeStack, enode, parent) -- 1064
		local cnode = getModel(enode) -- 1065
		if cnode ~= nil then -- 1065
			addChild(nodeStack, cnode, enode) -- 1067
		end -- 1067
	end, -- 1064
	["draw-node"] = function(nodeStack, enode, parent) -- 1070
		addChild( -- 1071
			nodeStack, -- 1071
			getDrawNode(enode), -- 1071
			enode -- 1071
		) -- 1071
	end, -- 1070
	["dot-shape"] = drawNodeCheck, -- 1073
	["circle-shape"] = drawNodeCheck, -- 1074
	["ellipse-shape"] = drawNodeCheck, -- 1075
	["rounded-rect-shape"] = drawNodeCheck, -- 1076
	["ring-shape"] = drawNodeCheck, -- 1077
	["sector-shape"] = drawNodeCheck, -- 1078
	["polyline-shape"] = drawNodeCheck, -- 1079
	["arc-shape"] = drawNodeCheck, -- 1080
	["quadratic-bezier-shape"] = drawNodeCheck, -- 1081
	["cubic-bezier-shape"] = drawNodeCheck, -- 1082
	["segment-shape"] = drawNodeCheck, -- 1083
	["rect-shape"] = drawNodeCheck, -- 1084
	["polygon-shape"] = drawNodeCheck, -- 1085
	["verts-shape"] = drawNodeCheck, -- 1086
	grid = function(nodeStack, enode, parent) -- 1087
		addChild( -- 1088
			nodeStack, -- 1088
			getGrid(enode), -- 1088
			enode -- 1088
		) -- 1088
	end, -- 1087
	sprite = function(nodeStack, enode, parent) -- 1090
		local cnode = getSprite(enode) -- 1091
		if cnode ~= nil then -- 1091
			addChild(nodeStack, cnode, enode) -- 1093
		end -- 1093
	end, -- 1090
	["audio-source"] = function(nodeStack, enode, parent) -- 1096
		local cnode = getAudioSource(enode) -- 1097
		if cnode ~= nil then -- 1097
			addChild(nodeStack, cnode, enode) -- 1099
		end -- 1099
	end, -- 1096
	["video-node"] = function(nodeStack, enode, parent) -- 1102
		local cnode = getVideoNode(enode) -- 1103
		if cnode ~= nil then -- 1103
			addChild(nodeStack, cnode, enode) -- 1105
		end -- 1105
	end, -- 1102
	["tic80-node"] = function(nodeStack, enode, parent) -- 1108
		local cnode = getTIC80Node(enode) -- 1109
		if cnode ~= nil then -- 1109
			addChild(nodeStack, cnode, enode) -- 1111
		end -- 1111
	end, -- 1108
	label = function(nodeStack, enode, parent) -- 1114
		local cnode = getLabel(enode) -- 1115
		if cnode ~= nil then -- 1115
			addChild(nodeStack, cnode, enode) -- 1117
		end -- 1117
	end, -- 1114
	line = function(nodeStack, enode, parent) -- 1120
		addChild( -- 1121
			nodeStack, -- 1121
			getLine(enode), -- 1121
			enode -- 1121
		) -- 1121
	end, -- 1120
	particle = function(nodeStack, enode, parent) -- 1123
		local cnode = getParticle(enode) -- 1124
		if cnode ~= nil then -- 1124
			addChild(nodeStack, cnode, enode) -- 1126
		end -- 1126
	end, -- 1123
	menu = function(nodeStack, enode, parent) -- 1129
		addChild( -- 1130
			nodeStack, -- 1130
			getMenu(enode), -- 1130
			enode -- 1130
		) -- 1130
	end, -- 1129
	action = function(_nodeStack, enode, parent) -- 1132
		if #enode.children == 0 then -- 1132
			Warn("<action> tag has no children") -- 1134
			return -- 1135
		end -- 1135
		local action = enode.props -- 1137
		if action.ref == nil then -- 1137
			Warn("<action> tag has no ref") -- 1139
			return -- 1140
		end -- 1140
		local actionStack = {} -- 1142
		for i = 1, #enode.children do -- 1142
			visitAction(actionStack, enode.children[i]) -- 1144
		end -- 1144
		if #actionStack == 1 then -- 1144
			action.ref.current = actionStack[1] -- 1147
		elseif #actionStack > 1 then -- 1147
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1149
		end -- 1149
	end, -- 1132
	["anchor-x"] = actionCheck, -- 1152
	["anchor-y"] = actionCheck, -- 1153
	angle = actionCheck, -- 1154
	["angle-x"] = actionCheck, -- 1155
	["angle-y"] = actionCheck, -- 1156
	delay = actionCheck, -- 1157
	event = actionCheck, -- 1158
	width = actionCheck, -- 1159
	height = actionCheck, -- 1160
	hide = actionCheck, -- 1161
	show = actionCheck, -- 1162
	move = actionCheck, -- 1163
	opacity = actionCheck, -- 1164
	roll = actionCheck, -- 1165
	scale = actionCheck, -- 1166
	["scale-x"] = actionCheck, -- 1167
	["scale-y"] = actionCheck, -- 1168
	["skew-x"] = actionCheck, -- 1169
	["skew-y"] = actionCheck, -- 1170
	["move-x"] = actionCheck, -- 1171
	["move-y"] = actionCheck, -- 1172
	["move-z"] = actionCheck, -- 1173
	frame = actionCheck, -- 1174
	spawn = actionCheck, -- 1175
	sequence = actionCheck, -- 1176
	loop = function(nodeStack, enode, _parent) -- 1177
		if #nodeStack > 0 then -- 1177
			local node = nodeStack[#nodeStack] -- 1179
			local actionStack = {} -- 1180
			for i = 1, #enode.children do -- 1180
				visitAction(actionStack, enode.children[i]) -- 1182
			end -- 1182
			if #actionStack == 1 then -- 1182
				node:runAction(actionStack[1], true) -- 1185
			else -- 1185
				local loop = enode.props -- 1187
				if loop.spawn then -- 1187
					node:runAction( -- 1189
						Dora.Spawn(table.unpack(actionStack)), -- 1189
						true -- 1189
					) -- 1189
				else -- 1189
					node:runAction( -- 1191
						Dora.Sequence(table.unpack(actionStack)), -- 1191
						true -- 1191
					) -- 1191
				end -- 1191
			end -- 1191
		else -- 1191
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1195
		end -- 1195
	end, -- 1177
	["physics-world"] = function(nodeStack, enode, _parent) -- 1198
		addChild( -- 1199
			nodeStack, -- 1199
			getPhysicsWorld(enode), -- 1199
			enode -- 1199
		) -- 1199
	end, -- 1198
	contact = function(nodeStack, enode, _parent) -- 1201
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1202
		if world ~= nil then -- 1202
			local contact = enode.props -- 1204
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1205
		else -- 1205
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1207
		end -- 1207
	end, -- 1201
	body = function(nodeStack, enode, _parent) -- 1210
		local def = enode.props -- 1211
		if def.world then -- 1211
			addChild( -- 1213
				nodeStack, -- 1213
				getBody(enode, def.world), -- 1213
				enode -- 1213
			) -- 1213
			return -- 1214
		end -- 1214
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1216
		if world ~= nil then -- 1216
			addChild( -- 1218
				nodeStack, -- 1218
				getBody(enode, world), -- 1218
				enode -- 1218
			) -- 1218
		else -- 1218
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1220
		end -- 1220
	end, -- 1210
	["rect-fixture"] = bodyCheck, -- 1223
	["polygon-fixture"] = bodyCheck, -- 1224
	["multi-fixture"] = bodyCheck, -- 1225
	["disk-fixture"] = bodyCheck, -- 1226
	["chain-fixture"] = bodyCheck, -- 1227
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1228
		local joint = enode.props -- 1229
		if joint.ref == nil then -- 1229
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1231
			return -- 1232
		end -- 1232
		if joint.bodyA.current == nil then -- 1232
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1235
			return -- 1236
		end -- 1236
		if joint.bodyB.current == nil then -- 1236
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1239
			return -- 1240
		end -- 1240
		local ____joint_ref_22 = joint.ref -- 1242
		local ____self_20 = Dora.Joint -- 1242
		local ____self_20_distance_21 = ____self_20.distance -- 1242
		local ____joint_canCollide_19 = joint.canCollide -- 1243
		if ____joint_canCollide_19 == nil then -- 1243
			____joint_canCollide_19 = false -- 1243
		end -- 1243
		____joint_ref_22.current = ____self_20_distance_21( -- 1242
			____self_20, -- 1242
			____joint_canCollide_19, -- 1243
			joint.bodyA.current, -- 1244
			joint.bodyB.current, -- 1245
			joint.anchorA or Dora.Vec2.zero, -- 1246
			joint.anchorB or Dora.Vec2.zero, -- 1247
			joint.frequency or 0, -- 1248
			joint.damping or 0 -- 1249
		) -- 1249
	end, -- 1228
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1251
		local joint = enode.props -- 1252
		if joint.ref == nil then -- 1252
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1254
			return -- 1255
		end -- 1255
		if joint.bodyA.current == nil then -- 1255
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1258
			return -- 1259
		end -- 1259
		if joint.bodyB.current == nil then -- 1259
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1262
			return -- 1263
		end -- 1263
		local ____joint_ref_26 = joint.ref -- 1265
		local ____self_24 = Dora.Joint -- 1265
		local ____self_24_friction_25 = ____self_24.friction -- 1265
		local ____joint_canCollide_23 = joint.canCollide -- 1266
		if ____joint_canCollide_23 == nil then -- 1266
			____joint_canCollide_23 = false -- 1266
		end -- 1266
		____joint_ref_26.current = ____self_24_friction_25( -- 1265
			____self_24, -- 1265
			____joint_canCollide_23, -- 1266
			joint.bodyA.current, -- 1267
			joint.bodyB.current, -- 1268
			joint.worldPos, -- 1269
			joint.maxForce, -- 1270
			joint.maxTorque -- 1271
		) -- 1271
	end, -- 1251
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1274
		local joint = enode.props -- 1275
		if joint.ref == nil then -- 1275
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1277
			return -- 1278
		end -- 1278
		if joint.jointA.current == nil then -- 1278
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1281
			return -- 1282
		end -- 1282
		if joint.jointB.current == nil then -- 1282
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1285
			return -- 1286
		end -- 1286
		local ____joint_ref_30 = joint.ref -- 1288
		local ____self_28 = Dora.Joint -- 1288
		local ____self_28_gear_29 = ____self_28.gear -- 1288
		local ____joint_canCollide_27 = joint.canCollide -- 1289
		if ____joint_canCollide_27 == nil then -- 1289
			____joint_canCollide_27 = false -- 1289
		end -- 1289
		____joint_ref_30.current = ____self_28_gear_29( -- 1288
			____self_28, -- 1288
			____joint_canCollide_27, -- 1289
			joint.jointA.current, -- 1290
			joint.jointB.current, -- 1291
			joint.ratio or 1 -- 1292
		) -- 1292
	end, -- 1274
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1295
		local joint = enode.props -- 1296
		if joint.ref == nil then -- 1296
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1298
			return -- 1299
		end -- 1299
		if joint.bodyA.current == nil then -- 1299
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1302
			return -- 1303
		end -- 1303
		if joint.bodyB.current == nil then -- 1303
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1306
			return -- 1307
		end -- 1307
		local ____joint_ref_34 = joint.ref -- 1309
		local ____self_32 = Dora.Joint -- 1309
		local ____self_32_spring_33 = ____self_32.spring -- 1309
		local ____joint_canCollide_31 = joint.canCollide -- 1310
		if ____joint_canCollide_31 == nil then -- 1310
			____joint_canCollide_31 = false -- 1310
		end -- 1310
		____joint_ref_34.current = ____self_32_spring_33( -- 1309
			____self_32, -- 1309
			____joint_canCollide_31, -- 1310
			joint.bodyA.current, -- 1311
			joint.bodyB.current, -- 1312
			joint.linearOffset, -- 1313
			joint.angularOffset, -- 1314
			joint.maxForce, -- 1315
			joint.maxTorque, -- 1316
			joint.correctionFactor or 1 -- 1317
		) -- 1317
	end, -- 1295
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1320
		local joint = enode.props -- 1321
		if joint.ref == nil then -- 1321
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1323
			return -- 1324
		end -- 1324
		if joint.body.current == nil then -- 1324
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1327
			return -- 1328
		end -- 1328
		local ____joint_ref_38 = joint.ref -- 1330
		local ____self_36 = Dora.Joint -- 1330
		local ____self_36_move_37 = ____self_36.move -- 1330
		local ____joint_canCollide_35 = joint.canCollide -- 1331
		if ____joint_canCollide_35 == nil then -- 1331
			____joint_canCollide_35 = false -- 1331
		end -- 1331
		____joint_ref_38.current = ____self_36_move_37( -- 1330
			____self_36, -- 1330
			____joint_canCollide_35, -- 1331
			joint.body.current, -- 1332
			joint.targetPos, -- 1333
			joint.maxForce, -- 1334
			joint.frequency, -- 1335
			joint.damping or 0.7 -- 1336
		) -- 1336
	end, -- 1320
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1339
		local joint = enode.props -- 1340
		if joint.ref == nil then -- 1340
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1342
			return -- 1343
		end -- 1343
		if joint.bodyA.current == nil then -- 1343
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1346
			return -- 1347
		end -- 1347
		if joint.bodyB.current == nil then -- 1347
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1350
			return -- 1351
		end -- 1351
		local ____joint_ref_42 = joint.ref -- 1353
		local ____self_40 = Dora.Joint -- 1353
		local ____self_40_prismatic_41 = ____self_40.prismatic -- 1353
		local ____joint_canCollide_39 = joint.canCollide -- 1354
		if ____joint_canCollide_39 == nil then -- 1354
			____joint_canCollide_39 = false -- 1354
		end -- 1354
		____joint_ref_42.current = ____self_40_prismatic_41( -- 1353
			____self_40, -- 1353
			____joint_canCollide_39, -- 1354
			joint.bodyA.current, -- 1355
			joint.bodyB.current, -- 1356
			joint.worldPos, -- 1357
			joint.axisAngle, -- 1358
			joint.lowerTranslation or 0, -- 1359
			joint.upperTranslation or 0, -- 1360
			joint.maxMotorForce or 0, -- 1361
			joint.motorSpeed or 0 -- 1362
		) -- 1362
	end, -- 1339
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1365
		local joint = enode.props -- 1366
		if joint.ref == nil then -- 1366
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1368
			return -- 1369
		end -- 1369
		if joint.bodyA.current == nil then -- 1369
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1372
			return -- 1373
		end -- 1373
		if joint.bodyB.current == nil then -- 1373
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1376
			return -- 1377
		end -- 1377
		local ____joint_ref_46 = joint.ref -- 1379
		local ____self_44 = Dora.Joint -- 1379
		local ____self_44_pulley_45 = ____self_44.pulley -- 1379
		local ____joint_canCollide_43 = joint.canCollide -- 1380
		if ____joint_canCollide_43 == nil then -- 1380
			____joint_canCollide_43 = false -- 1380
		end -- 1380
		____joint_ref_46.current = ____self_44_pulley_45( -- 1379
			____self_44, -- 1379
			____joint_canCollide_43, -- 1380
			joint.bodyA.current, -- 1381
			joint.bodyB.current, -- 1382
			joint.anchorA or Dora.Vec2.zero, -- 1383
			joint.anchorB or Dora.Vec2.zero, -- 1384
			joint.groundAnchorA, -- 1385
			joint.groundAnchorB, -- 1386
			joint.ratio or 1 -- 1387
		) -- 1387
	end, -- 1365
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1390
		local joint = enode.props -- 1391
		if joint.ref == nil then -- 1391
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1393
			return -- 1394
		end -- 1394
		if joint.bodyA.current == nil then -- 1394
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1397
			return -- 1398
		end -- 1398
		if joint.bodyB.current == nil then -- 1398
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1401
			return -- 1402
		end -- 1402
		local ____joint_ref_50 = joint.ref -- 1404
		local ____self_48 = Dora.Joint -- 1404
		local ____self_48_revolute_49 = ____self_48.revolute -- 1404
		local ____joint_canCollide_47 = joint.canCollide -- 1405
		if ____joint_canCollide_47 == nil then -- 1405
			____joint_canCollide_47 = false -- 1405
		end -- 1405
		____joint_ref_50.current = ____self_48_revolute_49( -- 1404
			____self_48, -- 1404
			____joint_canCollide_47, -- 1405
			joint.bodyA.current, -- 1406
			joint.bodyB.current, -- 1407
			joint.worldPos, -- 1408
			joint.lowerAngle or 0, -- 1409
			joint.upperAngle or 0, -- 1410
			joint.maxMotorTorque or 0, -- 1411
			joint.motorSpeed or 0 -- 1412
		) -- 1412
	end, -- 1390
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1415
		local joint = enode.props -- 1416
		if joint.ref == nil then -- 1416
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1418
			return -- 1419
		end -- 1419
		if joint.bodyA.current == nil then -- 1419
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1422
			return -- 1423
		end -- 1423
		if joint.bodyB.current == nil then -- 1423
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1426
			return -- 1427
		end -- 1427
		local ____joint_ref_54 = joint.ref -- 1429
		local ____self_52 = Dora.Joint -- 1429
		local ____self_52_rope_53 = ____self_52.rope -- 1429
		local ____joint_canCollide_51 = joint.canCollide -- 1430
		if ____joint_canCollide_51 == nil then -- 1430
			____joint_canCollide_51 = false -- 1430
		end -- 1430
		____joint_ref_54.current = ____self_52_rope_53( -- 1429
			____self_52, -- 1429
			____joint_canCollide_51, -- 1430
			joint.bodyA.current, -- 1431
			joint.bodyB.current, -- 1432
			joint.anchorA or Dora.Vec2.zero, -- 1433
			joint.anchorB or Dora.Vec2.zero, -- 1434
			joint.maxLength or 0 -- 1435
		) -- 1435
	end, -- 1415
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1438
		local joint = enode.props -- 1439
		if joint.ref == nil then -- 1439
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1441
			return -- 1442
		end -- 1442
		if joint.bodyA.current == nil then -- 1442
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1445
			return -- 1446
		end -- 1446
		if joint.bodyB.current == nil then -- 1446
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1449
			return -- 1450
		end -- 1450
		local ____joint_ref_58 = joint.ref -- 1452
		local ____self_56 = Dora.Joint -- 1452
		local ____self_56_weld_57 = ____self_56.weld -- 1452
		local ____joint_canCollide_55 = joint.canCollide -- 1453
		if ____joint_canCollide_55 == nil then -- 1453
			____joint_canCollide_55 = false -- 1453
		end -- 1453
		____joint_ref_58.current = ____self_56_weld_57( -- 1452
			____self_56, -- 1452
			____joint_canCollide_55, -- 1453
			joint.bodyA.current, -- 1454
			joint.bodyB.current, -- 1455
			joint.worldPos, -- 1456
			joint.frequency or 0, -- 1457
			joint.damping or 0 -- 1458
		) -- 1458
	end, -- 1438
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1461
		local joint = enode.props -- 1462
		if joint.ref == nil then -- 1462
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1464
			return -- 1465
		end -- 1465
		if joint.bodyA.current == nil then -- 1465
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1468
			return -- 1469
		end -- 1469
		if joint.bodyB.current == nil then -- 1469
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1472
			return -- 1473
		end -- 1473
		local ____joint_ref_62 = joint.ref -- 1475
		local ____self_60 = Dora.Joint -- 1475
		local ____self_60_wheel_61 = ____self_60.wheel -- 1475
		local ____joint_canCollide_59 = joint.canCollide -- 1476
		if ____joint_canCollide_59 == nil then -- 1476
			____joint_canCollide_59 = false -- 1476
		end -- 1476
		____joint_ref_62.current = ____self_60_wheel_61( -- 1475
			____self_60, -- 1475
			____joint_canCollide_59, -- 1476
			joint.bodyA.current, -- 1477
			joint.bodyB.current, -- 1478
			joint.worldPos, -- 1479
			joint.axisAngle, -- 1480
			joint.maxMotorTorque or 0, -- 1481
			joint.motorSpeed or 0, -- 1482
			joint.frequency or 0, -- 1483
			joint.damping or 0.7 -- 1484
		) -- 1484
	end, -- 1461
	["custom-node"] = function(nodeStack, enode, _parent) -- 1487
		local node = getCustomNode(enode) -- 1488
		if node ~= nil then -- 1488
			addChild(nodeStack, node, enode) -- 1490
		end -- 1490
	end, -- 1487
	["custom-element"] = function() -- 1493
	end, -- 1493
	["align-node"] = function(nodeStack, enode, _parent) -- 1494
		addChild( -- 1495
			nodeStack, -- 1495
			getAlignNode(enode), -- 1495
			enode -- 1495
		) -- 1495
	end, -- 1494
	["effek-node"] = function(nodeStack, enode, _parent) -- 1497
		addChild( -- 1498
			nodeStack, -- 1498
			getEffekNode(enode), -- 1498
			enode -- 1498
		) -- 1498
	end, -- 1497
	effek = function(nodeStack, enode, parent) -- 1500
		if #nodeStack > 0 then -- 1500
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1502
			if node then -- 1502
				local effek = enode.props -- 1504
				local handle = node:play( -- 1505
					effek.file, -- 1505
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1505
					effek.z or 0 -- 1505
				) -- 1505
				if handle >= 0 then -- 1505
					if effek.ref then -- 1505
						effek.ref.current = handle -- 1508
					end -- 1508
					if effek.onEnd then -- 1508
						local onEnd = effek.onEnd -- 1508
						node:slot( -- 1512
							"EffekEnd", -- 1512
							function(h) -- 1512
								if handle == h then -- 1512
									onEnd(nil) -- 1514
								end -- 1514
							end -- 1512
						) -- 1512
					end -- 1512
				end -- 1512
			else -- 1512
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1520
			end -- 1520
		end -- 1520
	end, -- 1500
	["tile-node"] = function(nodeStack, enode, parent) -- 1524
		local cnode = getTileNode(enode) -- 1525
		if cnode ~= nil then -- 1525
			addChild(nodeStack, cnode, enode) -- 1527
		end -- 1527
	end -- 1524
} -- 1524
local roots = {} -- 1580
warnedUnkeyedChildTypes = {} -- 1581
local renderQueued = false -- 1582
local queuedRoots = {} -- 1583
local trackingRoot -- 1584
local function isElementList(node) -- 1588
	return node.type == nil -- 1589
end -- 1588
local function getRenderableElement(renderable) -- 1623
	if type(renderable) == "function" then -- 1623
		return renderable() -- 1625
	end -- 1625
	return renderable -- 1627
end -- 1623
local function removeRoot(root) -- 1877
	for i = 1, #roots do -- 1877
		if roots[i] == root then -- 1877
			table.remove(roots, i) -- 1880
			break -- 1881
		end -- 1881
	end -- 1881
end -- 1877
local function toElementList(node) -- 2447
	if isElementList(node) then -- 2447
		return node -- 2449
	end -- 2449
	return {node} -- 2451
end -- 2447
local function scheduleRootRender(root) -- 2454
	if not root.active then -- 2454
		return -- 2455
	end -- 2455
	for i = 1, #queuedRoots do -- 2455
		if queuedRoots[i] == root then -- 2455
			return -- 2457
		end -- 2457
	end -- 2457
	queuedRoots[#queuedRoots + 1] = root -- 2459
	if renderQueued then -- 2459
		return -- 2460
	end -- 2460
	renderQueued = true -- 2461
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2462
		renderQueued = false -- 2463
		local updatingRoots = queuedRoots -- 2464
		queuedRoots = {} -- 2465
		for i = 1, #updatingRoots do -- 2465
			updatingRoots[i]:update() -- 2467
		end -- 2467
	end)) -- 2462
end -- 2454
____exports.Root = __TS__Class() -- 2472
local Root = ____exports.Root -- 2472
Root.name = "Root" -- 2472
function Root.prototype.____constructor(self, parent) -- 2486
	self.parent = parent -- 2486
	self.mounted = {} -- 2473
	self.signals = {} -- 2475
	self.hookFrames = {} -- 2476
	self.keyedHookFrames = {} -- 2477
	self.nextKeyedHookFrames = {} -- 2478
	self.usedHookFrames = {} -- 2479
	self.previousHookFrames = {} -- 2480
	self.pendingEffects = {} -- 2481
	self.pendingCleanups = {} -- 2482
	self.hookFrameIndex = 0 -- 2483
	self.active = true -- 2484
end -- 2486
function Root.prototype.render(self, enode) -- 2488
	if not self.active then -- 2488
		roots[#roots + 1] = self -- 2490
		self.active = true -- 2491
	end -- 2491
	self.renderable = enode -- 2493
	self:update() -- 2494
end -- 2488
function Root.prototype.update(self) -- 2497
	if not self.active or self.renderable == nil then -- 2497
		return -- 2498
	end -- 2498
	self:unsubscribeSignals() -- 2499
	local lastTrackingRoot = trackingRoot -- 2500
	local lastRenderingHookRoot = renderingHookRoot -- 2501
	trackingRoot = self -- 2502
	renderingHookRoot = self -- 2503
	local elements -- 2504
	do -- 2504
		local ____try, ____error = pcall(function() -- 2504
			self:beginHookRender() -- 2506
			elements = getRenderableElement(self.renderable) -- 2507
		end) -- 2507
		do -- 2507
			self:finishHookRender() -- 2509
			trackingRoot = lastTrackingRoot -- 2510
			renderingHookRoot = lastRenderingHookRoot -- 2511
		end -- 2511
		if not ____try then -- 2511
			error(____error, 0) -- 2511
		end -- 2511
	end -- 2511
	self.mounted = reconcileChildren( -- 2513
		self.parent, -- 2513
		self.mounted, -- 2513
		toElementList(elements) -- 2513
	) -- 2513
	self:flushEffects() -- 2514
end -- 2497
function Root.prototype.unmount(self) -- 2517
	for i = 1, #self.mounted do -- 2517
		unmountElement(self.mounted[i]) -- 2519
	end -- 2519
	for i = 1, #self.hookFrames do -- 2519
		self:queueFrameCleanup(self.hookFrames[i]) -- 2522
	end -- 2522
	self.pendingEffects = {} -- 2524
	self:flushEffects() -- 2525
	self.mounted = {} -- 2526
	self.renderable = nil -- 2527
	self.hookFrames = {} -- 2528
	self.keyedHookFrames = {} -- 2529
	self.nextKeyedHookFrames = {} -- 2530
	self.usedHookFrames = {} -- 2531
	self.previousHookFrames = {} -- 2532
	self.hookFrameIndex = 0 -- 2533
	self:unsubscribeSignals() -- 2534
	if self.active then -- 2534
		removeRoot(self) -- 2536
		self.active = false -- 2537
	end -- 2537
end -- 2517
function Root.prototype.trackSignal(self, signal) -- 2541
	for i = 1, #self.signals do -- 2541
		if self.signals[i] == signal then -- 2541
			return -- 2543
		end -- 2543
	end -- 2543
	local ____self_signals_73 = self.signals -- 2543
	____self_signals_73[#____self_signals_73 + 1] = signal -- 2545
	signal:addRoot(self) -- 2546
end -- 2541
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2549
	local index = self.hookFrameIndex -- 2550
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2551
	local frame -- 2552
	if key ~= nil then -- 2552
		local framesByKey = self.keyedHookFrames[____type] -- 2554
		if framesByKey ~= nil then -- 2554
			frame = framesByKey[key] -- 2556
			if frame ~= nil and self.usedHookFrames[frame] == true then -- 2556
				frame = nil -- 2558
			end -- 2558
		end -- 2558
		if frame == nil then -- 2558
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2562
		end -- 2562
		local nextFramesByKey = self.nextKeyedHookFrames[____type] -- 2564
		if nextFramesByKey == nil then -- 2564
			nextFramesByKey = {} -- 2566
			self.nextKeyedHookFrames[____type] = nextFramesByKey -- 2567
		end -- 2567
		nextFramesByKey[key] = frame -- 2569
		self.hookFrames[index + 1] = frame -- 2570
	else -- 2570
		frame = self.hookFrames[index + 1] -- 2572
		if frame == nil or self.usedHookFrames[frame] == true or frame.type ~= ____type or frame.key ~= nil then -- 2572
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2579
			self.hookFrames[index + 1] = frame -- 2580
		end -- 2580
	end -- 2580
	frame.hookIndex = 0 -- 2583
	self.usedHookFrames[frame] = true -- 2584
	return frame -- 2585
end -- 2549
function Root.prototype.queueEffect(self, hook, effect) -- 2588
	if hook.cleanup ~= nil then -- 2588
		local ____self_pendingCleanups_74 = self.pendingCleanups -- 2588
		____self_pendingCleanups_74[#____self_pendingCleanups_74 + 1] = hook.cleanup -- 2590
		hook.cleanup = nil -- 2591
	end -- 2591
	local ____self_pendingEffects_75 = self.pendingEffects -- 2591
	____self_pendingEffects_75[#____self_pendingEffects_75 + 1] = {hook = hook, effect = effect} -- 2593
end -- 2588
function Root.prototype.beginHookRender(self) -- 2596
	self.previousHookFrames = {table.unpack(self.hookFrames)} -- 2597
	self.hookFrameIndex = 0 -- 2598
	self.usedHookFrames = {} -- 2599
	self.nextKeyedHookFrames = {} -- 2600
end -- 2596
function Root.prototype.finishHookRender(self) -- 2603
	for i = 1, #self.previousHookFrames do -- 2603
		local frame = self.previousHookFrames[i] -- 2605
		if self.usedHookFrames[frame] ~= true then -- 2605
			self:queueFrameCleanup(frame) -- 2607
		end -- 2607
	end -- 2607
	while #self.hookFrames > self.hookFrameIndex do -- 2607
		table.remove(self.hookFrames) -- 2611
	end -- 2611
	self.keyedHookFrames = self.nextKeyedHookFrames -- 2613
	self.previousHookFrames = {} -- 2614
end -- 2603
function Root.prototype.unsubscribeSignals(self) -- 2617
	for i = 1, #self.signals do -- 2617
		self.signals[i]:removeRoot(self) -- 2619
	end -- 2619
	self.signals = {} -- 2621
end -- 2617
function Root.prototype.queueFrameCleanup(self, frame) -- 2624
	for i = 1, #frame.hooks do -- 2624
		local hook = frame.hooks[i] -- 2626
		if hook.cleanup ~= nil then -- 2626
			local ____self_pendingCleanups_76 = self.pendingCleanups -- 2626
			____self_pendingCleanups_76[#____self_pendingCleanups_76 + 1] = hook.cleanup -- 2628
			hook.cleanup = nil -- 2629
		end -- 2629
	end -- 2629
end -- 2624
function Root.prototype.flushEffects(self) -- 2634
	local cleanups = self.pendingCleanups -- 2635
	self.pendingCleanups = {} -- 2636
	for i = 1, #cleanups do -- 2636
		cleanups[i]() -- 2638
	end -- 2638
	local effects = self.pendingEffects -- 2640
	self.pendingEffects = {} -- 2641
	for i = 1, #effects do -- 2641
		local task = effects[i] -- 2643
		local cleanup = task.effect() -- 2644
		if type(cleanup) == "function" then -- 2644
			task.hook.cleanup = cleanup -- 2646
		end -- 2646
	end -- 2646
end -- 2634
function ____exports.createRoot(parent) -- 2652
	local root = __TS__New(____exports.Root, parent) -- 2653
	roots[#roots + 1] = root -- 2654
	return root -- 2655
end -- 2652
____exports.Signal = __TS__Class() -- 2658
local Signal = ____exports.Signal -- 2658
Signal.name = "Signal" -- 2658
function Signal.prototype.____constructor(self, item) -- 2661
	self.item = item -- 2661
	self.roots = {} -- 2659
end -- 2661
function Signal.prototype.addRoot(self, root) -- 2678
	for i = 1, #self.roots do -- 2678
		if self.roots[i] == root then -- 2678
			return -- 2680
		end -- 2680
	end -- 2680
	local ____self_roots_77 = self.roots -- 2680
	____self_roots_77[#____self_roots_77 + 1] = root -- 2682
end -- 2678
function Signal.prototype.removeRoot(self, root) -- 2685
	for i = 1, #self.roots do -- 2685
		if self.roots[i] == root then -- 2685
			table.remove(self.roots, i) -- 2688
			break -- 2689
		end -- 2689
	end -- 2689
end -- 2685
__TS__SetDescriptor( -- 2685
	Signal.prototype, -- 2685
	"value", -- 2685
	{ -- 2685
		get = function(self) -- 2685
			if trackingRoot ~= nil then -- 2685
				trackingRoot:trackSignal(self) -- 2665
			end -- 2665
			return self.item -- 2667
		end, -- 2667
		set = function(self, value) -- 2667
			if self.item == value then -- 2667
				return -- 2671
			end -- 2671
			self.item = value -- 2672
			for i = 1, #self.roots do -- 2672
				scheduleRootRender(self.roots[i]) -- 2674
			end -- 2674
		end -- 2674
	}, -- 2674
	true -- 2674
) -- 2674
function ____exports.signal(value) -- 2695
	return __TS__New(____exports.Signal, value) -- 2696
end -- 2695
function ____exports.reference(item) -- 2699
	local ____item_78 = item -- 2700
	if ____item_78 == nil then -- 2700
		____item_78 = nil -- 2700
	end -- 2700
	return {current = ____item_78} -- 2700
end -- 2699
local function hookDepsEqual(oldDeps, newDeps) -- 2703
	if oldDeps == nil or newDeps == nil then -- 2703
		return false -- 2704
	end -- 2704
	if #oldDeps ~= #newDeps then -- 2704
		return false -- 2705
	end -- 2705
	for i = 1, #oldDeps do -- 2705
		if oldDeps[i] ~= newDeps[i] then -- 2705
			return false -- 2707
		end -- 2707
	end -- 2707
	return true -- 2709
end -- 2703
local function copyDeps(deps) -- 2712
	if deps == nil then -- 2712
		return nil -- 2713
	end -- 2713
	local copied = {} -- 2714
	for i = 1, #deps do -- 2714
		copied[#copied + 1] = deps[i] -- 2716
	end -- 2716
	return copied -- 2718
end -- 2712
function ____exports.useMemo(factory, deps) -- 2721
	local frame = currentHookFrame -- 2722
	if frame == nil then -- 2722
		error("useMemo() can only be called inside a function component") -- 2724
	end -- 2724
	local index = frame.hookIndex -- 2726
	frame.hookIndex = frame.hookIndex + 1 -- 2727
	local hook = frame.hooks[index + 1] -- 2728
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2728
		hook = { -- 2730
			value = factory(), -- 2730
			deps = copyDeps(deps) -- 2730
		} -- 2730
		frame.hooks[index + 1] = hook -- 2731
	end -- 2731
	return hook.value -- 2733
end -- 2721
function ____exports.useCallback(callback, deps) -- 2736
	local frame = currentHookFrame -- 2737
	if frame == nil then -- 2737
		error("useCallback() can only be called inside a function component") -- 2739
	end -- 2739
	local actualDeps = deps or ({}) -- 2741
	local index = frame.hookIndex -- 2742
	frame.hookIndex = frame.hookIndex + 1 -- 2743
	local hook = frame.hooks[index + 1] -- 2744
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2744
		hook = { -- 2746
			value = callback, -- 2746
			deps = copyDeps(actualDeps) -- 2746
		} -- 2746
		frame.hooks[index + 1] = hook -- 2747
	end -- 2747
	return hook.value -- 2749
end -- 2736
function ____exports.useEffect(effect, deps) -- 2752
	local frame = currentHookFrame -- 2753
	if frame == nil or renderingHookRoot == nil then -- 2753
		error("useEffect() can only be called inside a function component") -- 2755
	end -- 2755
	local index = frame.hookIndex -- 2757
	frame.hookIndex = frame.hookIndex + 1 -- 2758
	local hook = frame.hooks[index + 1] -- 2759
	if hook == nil then -- 2759
		hook = {value = nil} -- 2761
		frame.hooks[index + 1] = hook -- 2762
	end -- 2762
	if not hookDepsEqual(hook.deps, deps) then -- 2762
		hook.deps = copyDeps(deps) -- 2765
		renderingHookRoot:queueEffect(hook, effect) -- 2766
	end -- 2766
end -- 2752
function ____exports.useRef(item) -- 2770
	local frame = currentHookFrame -- 2771
	if frame == nil then -- 2771
		Warn("useRef() called outside a function component; falling back to reference()") -- 2773
		return ____exports.reference(item) -- 2774
	end -- 2774
	local index = frame.hookIndex -- 2776
	frame.hookIndex = frame.hookIndex + 1 -- 2777
	local hook = frame.hooks[index + 1] -- 2778
	if hook == nil then -- 2778
		hook = {value = ____exports.reference(item)} -- 2780
		frame.hooks[index + 1] = hook -- 2781
	end -- 2781
	return hook.value -- 2783
end -- 2770
function ____exports.useSignal(value) -- 2786
	local frame = currentHookFrame -- 2787
	if frame == nil then -- 2787
		error("useSignal() can only be called inside a function component") -- 2789
	end -- 2789
	local index = frame.hookIndex -- 2791
	frame.hookIndex = frame.hookIndex + 1 -- 2792
	local hook = frame.hooks[index + 1] -- 2793
	if hook == nil then -- 2793
		hook = {value = ____exports.signal(value)} -- 2795
		frame.hooks[index + 1] = hook -- 2796
	end -- 2796
	return hook.value -- 2798
end -- 2786
local function getPreload(preloadList, node) -- 2801
	if type(node) ~= "table" then -- 2801
		return -- 2803
	end -- 2803
	local enode = node -- 2805
	if enode.type == nil then -- 2805
		local list = node -- 2807
		if #list > 0 then -- 2807
			for i = 1, #list do -- 2807
				getPreload(preloadList, list[i]) -- 2810
			end -- 2810
		end -- 2810
	else -- 2810
		repeat -- 2810
			local ____switch661 = enode.type -- 2810
			local sprite, playable, frame, model, spine, dragonBone, label -- 2810
			local ____cond661 = ____switch661 == "sprite" -- 2810
			if ____cond661 then -- 2810
				sprite = enode.props -- 2816
				if sprite.file then -- 2816
					preloadList[#preloadList + 1] = sprite.file -- 2818
				end -- 2818
				break -- 2820
			end -- 2820
			____cond661 = ____cond661 or ____switch661 == "playable" -- 2820
			if ____cond661 then -- 2820
				playable = enode.props -- 2822
				preloadList[#preloadList + 1] = playable.file -- 2823
				break -- 2824
			end -- 2824
			____cond661 = ____cond661 or ____switch661 == "frame" -- 2824
			if ____cond661 then -- 2824
				frame = enode.props -- 2826
				preloadList[#preloadList + 1] = frame.file -- 2827
				break -- 2828
			end -- 2828
			____cond661 = ____cond661 or ____switch661 == "model" -- 2828
			if ____cond661 then -- 2828
				model = enode.props -- 2830
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2831
				break -- 2832
			end -- 2832
			____cond661 = ____cond661 or ____switch661 == "spine" -- 2832
			if ____cond661 then -- 2832
				spine = enode.props -- 2834
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2835
				break -- 2836
			end -- 2836
			____cond661 = ____cond661 or ____switch661 == "dragon-bone" -- 2836
			if ____cond661 then -- 2836
				dragonBone = enode.props -- 2838
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2839
				break -- 2840
			end -- 2840
			____cond661 = ____cond661 or ____switch661 == "label" -- 2840
			if ____cond661 then -- 2840
				label = enode.props -- 2842
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2843
				break -- 2844
			end -- 2844
		until true -- 2844
	end -- 2844
	getPreload(preloadList, enode.children) -- 2847
end -- 2801
function ____exports.preloadAsync(enode, handler) -- 2850
	local preloadList = {} -- 2851
	getPreload(preloadList, enode) -- 2852
	Dora.Cache:loadAsync(preloadList, handler) -- 2853
end -- 2850
function ____exports.toAction(enode) -- 2856
	local actionDef = ____exports.reference() -- 2857
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2858
	if not actionDef.current then -- 2858
		error("failed to create action") -- 2859
	end -- 2859
	return actionDef.current -- 2860
end -- 2856
return ____exports -- 2856
