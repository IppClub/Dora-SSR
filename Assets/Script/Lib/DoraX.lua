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
function visitAction(actionStack, enode) -- 894
	local createAction = actionMap[enode.type] -- 895
	if createAction ~= nil then -- 895
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 897
		return -- 898
	end -- 898
	repeat -- 898
		local ____switch186 = enode.type -- 898
		local ____cond186 = ____switch186 == "delay" -- 898
		if ____cond186 then -- 898
			do -- 898
				local item = enode.props -- 902
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 903
				break -- 904
			end -- 904
		end -- 904
		____cond186 = ____cond186 or ____switch186 == "event" -- 904
		if ____cond186 then -- 904
			do -- 904
				local item = enode.props -- 907
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 908
				break -- 909
			end -- 909
		end -- 909
		____cond186 = ____cond186 or ____switch186 == "hide" -- 909
		if ____cond186 then -- 909
			do -- 909
				actionStack[#actionStack + 1] = Dora.Hide() -- 912
				break -- 913
			end -- 913
		end -- 913
		____cond186 = ____cond186 or ____switch186 == "show" -- 913
		if ____cond186 then -- 913
			do -- 913
				actionStack[#actionStack + 1] = Dora.Show() -- 916
				break -- 917
			end -- 917
		end -- 917
		____cond186 = ____cond186 or ____switch186 == "move" -- 917
		if ____cond186 then -- 917
			do -- 917
				local item = enode.props -- 920
				actionStack[#actionStack + 1] = Dora.Move( -- 921
					item.time, -- 921
					Dora.Vec2(item.startX, item.startY), -- 921
					Dora.Vec2(item.stopX, item.stopY), -- 921
					item.easing -- 921
				) -- 921
				break -- 922
			end -- 922
		end -- 922
		____cond186 = ____cond186 or ____switch186 == "frame" -- 922
		if ____cond186 then -- 922
			do -- 922
				local item = enode.props -- 925
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 926
				break -- 927
			end -- 927
		end -- 927
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 927
		if ____cond186 then -- 927
			do -- 927
				local spawnStack = {} -- 930
				for i = 1, #enode.children do -- 930
					visitAction(spawnStack, enode.children[i]) -- 932
				end -- 932
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 934
				break -- 935
			end -- 935
		end -- 935
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 935
		if ____cond186 then -- 935
			do -- 935
				local sequenceStack = {} -- 938
				for i = 1, #enode.children do -- 938
					visitAction(sequenceStack, enode.children[i]) -- 940
				end -- 940
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 942
				break -- 943
			end -- 943
		end -- 943
		do -- 943
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 946
			break -- 947
		end -- 947
	until true -- 947
end -- 947
function visitNode(nodeStack, node, parent) -- 1486
	if type(node) ~= "table" then -- 1486
		return -- 1488
	end -- 1488
	local enode = node -- 1490
	if enode.type == nil then -- 1490
		local list = node -- 1492
		if #list > 0 then -- 1492
			for i = 1, #list do -- 1492
				local stack = {} -- 1495
				visitNode(stack, list[i], parent) -- 1496
				for i = 1, #stack do -- 1496
					nodeStack[#nodeStack + 1] = stack[i] -- 1498
				end -- 1498
			end -- 1498
		end -- 1498
	else -- 1498
		local handler = elementMap[enode.type] -- 1503
		if handler ~= nil then -- 1503
			handler(nodeStack, enode, parent) -- 1505
		else -- 1505
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1507
		end -- 1507
	end -- 1507
end -- 1507
function ____exports.toNode(enode) -- 1512
	local nodeStack = {} -- 1513
	visitNode(nodeStack, enode) -- 1514
	if #nodeStack == 1 then -- 1514
		return nodeStack[1] -- 1516
	elseif #nodeStack > 1 then -- 1516
		local node = Dora.Node() -- 1518
		for i = 1, #nodeStack do -- 1518
			node:addChild(nodeStack[i]) -- 1520
		end -- 1520
		return node -- 1522
	end -- 1522
	return nil -- 1524
end -- 1512
function getElementKey(element) -- 1547
	local props = element.props -- 1548
	local ____props_60 -- 1549
	if props then -- 1549
		____props_60 = props.key -- 1549
	else -- 1549
		____props_60 = nil -- 1549
	end -- 1549
	return ____props_60 -- 1549
end -- 1549
function getElementTypeName(element) -- 1552
	local elementType = element.type -- 1553
	if type(elementType) == "string" then -- 1553
		return elementType -- 1554
	end -- 1554
	return tostring(elementType) -- 1555
end -- 1555
function warnUnkeyedDynamicChildren(oldChildren, newElements) -- 1558
	if #oldChildren == #newElements then -- 1558
		return -- 1559
	end -- 1559
	local oldTypes = {} -- 1560
	for i = 1, #oldChildren do -- 1560
		local oldElement = oldChildren[i].element -- 1562
		if getElementKey(oldElement) == nil then -- 1562
			oldTypes[getElementTypeName(oldElement)] = true -- 1564
		end -- 1564
	end -- 1564
	for i = 1, #newElements do -- 1564
		do -- 1564
			local newElement = newElements[i] -- 1568
			if getElementKey(newElement) ~= nil then -- 1568
				goto __continue335 -- 1569
			end -- 1569
			local typeName = getElementTypeName(newElement) -- 1570
			if oldTypes[typeName] == true and not warnedUnkeyedChildTypes[typeName] then -- 1570
				warnedUnkeyedChildTypes[typeName] = true -- 1572
				Warn(("dynamic children include unkeyed <" .. typeName) .. "> siblings while child count changed; add stable key props to conditional, inserted, removed or reordered siblings to avoid index-based reuse") -- 1573
			end -- 1573
		end -- 1573
		::__continue335:: -- 1573
	end -- 1573
end -- 1573
function getPrimitiveLabelText(enode) -- 1585
	local label = enode.props -- 1586
	local text = label.text or "" -- 1587
	for i = 1, #enode.children do -- 1587
		local child = enode.children[i] -- 1589
		if type(child) ~= "table" then -- 1589
			text = text .. tostring(child) -- 1591
		end -- 1591
	end -- 1591
	return text -- 1594
end -- 1594
function isDrawShapeElement(element) -- 1597
	repeat -- 1597
		local ____switch344 = element.type -- 1597
		local ____cond344 = ____switch344 == "dot-shape" or ____switch344 == "segment-shape" or ____switch344 == "rect-shape" or ____switch344 == "polygon-shape" or ____switch344 == "verts-shape" -- 1597
		if ____cond344 then -- 1597
			return true -- 1604
		end -- 1604
	until true -- 1604
	return false -- 1606
end -- 1606
function isBodyFixtureElement(element) -- 1609
	repeat -- 1609
		local ____switch346 = element.type -- 1609
		local ____cond346 = ____switch346 == "rect-fixture" or ____switch346 == "polygon-fixture" or ____switch346 == "multi-fixture" or ____switch346 == "disk-fixture" or ____switch346 == "chain-fixture" -- 1609
		if ____cond346 then -- 1609
			return true -- 1616
		end -- 1616
	until true -- 1616
	return false -- 1618
end -- 1618
function isPhysicsWorldInputElement(element) -- 1621
	return element.type == "contact" -- 1622
end -- 1622
function isRunnableActionElement(element) -- 1625
	if element.type == "loop" then -- 1625
		return true -- 1626
	end -- 1626
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1627
end -- 1627
function shallowPropsEqual(oldProps, newProps) -- 1638
	for k, v in pairs(oldProps) do -- 1639
		if k ~= "ref" and newProps[k] ~= v then -- 1639
			return false -- 1640
		end -- 1640
	end -- 1640
	for k, v in pairs(newProps) do -- 1642
		if k ~= "ref" and oldProps[k] ~= v then -- 1642
			return false -- 1643
		end -- 1643
	end -- 1643
	return true -- 1645
end -- 1645
function collectRunnableActionElements(element) -- 1648
	local actions = {} -- 1649
	for i = 1, #element.children do -- 1649
		local child = element.children[i] -- 1651
		if type(child) == "table" and isRunnableActionElement(child) then -- 1651
			actions[#actions + 1] = child -- 1653
		end -- 1653
	end -- 1653
	return actions -- 1656
end -- 1656
function collectContactElements(element) -- 1659
	local contacts = {} -- 1660
	for i = 1, #element.children do -- 1660
		local child = element.children[i] -- 1662
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1662
			contacts[#contacts + 1] = child -- 1664
		end -- 1664
	end -- 1664
	return contacts -- 1667
end -- 1667
function getContactKey(contact) -- 1670
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1671
end -- 1671
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1674
	local oldContacts = collectContactElements(oldElement) -- 1675
	local newContacts = collectContactElements(newElement) -- 1676
	local oldByKey = {} -- 1677
	local newByKey = {} -- 1678
	for i = 1, #oldContacts do -- 1678
		local contact = oldContacts[i].props -- 1680
		oldByKey[getContactKey(contact)] = contact -- 1681
	end -- 1681
	for i = 1, #newContacts do -- 1681
		local contact = newContacts[i].props -- 1684
		newByKey[getContactKey(contact)] = contact -- 1685
	end -- 1685
	for i = 1, #oldContacts do -- 1685
		local oldContact = oldContacts[i].props -- 1688
		local key = getContactKey(oldContact) -- 1689
		local newContact = newByKey[key] -- 1690
		if newContact == nil then -- 1690
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1692
		elseif oldContact.enabled ~= newContact.enabled then -- 1692
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1694
		end -- 1694
	end -- 1694
	for i = 1, #newContacts do -- 1694
		local newContact = newContacts[i].props -- 1698
		if oldByKey[getContactKey(newContact)] == nil then -- 1698
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1700
		end -- 1700
	end -- 1700
end -- 1700
function actionElementEqual(oldElement, newElement) -- 1705
	if oldElement.type ~= newElement.type then -- 1705
		return false -- 1706
	end -- 1706
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1706
		return false -- 1707
	end -- 1707
	if #oldElement.children ~= #newElement.children then -- 1707
		return false -- 1708
	end -- 1708
	for i = 1, #oldElement.children do -- 1708
		local oldChild = oldElement.children[i] -- 1710
		local newChild = newElement.children[i] -- 1711
		if type(oldChild) ~= type(newChild) then -- 1711
			return false -- 1712
		end -- 1712
		if type(oldChild) == "table" then -- 1712
			if not actionElementEqual(oldChild, newChild) then -- 1712
				return false -- 1714
			end -- 1714
		elseif oldChild ~= newChild then -- 1714
			return false -- 1716
		end -- 1716
	end -- 1716
	return true -- 1719
end -- 1719
function actionChildrenEqual(oldElement, newElement) -- 1722
	local oldActions = collectRunnableActionElements(oldElement) -- 1723
	local newActions = collectRunnableActionElements(newElement) -- 1724
	if #oldActions ~= #newActions then -- 1724
		return false -- 1725
	end -- 1725
	for i = 1, #oldActions do -- 1725
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1725
			return false -- 1727
		end -- 1727
	end -- 1727
	return true -- 1729
end -- 1729
function createActionDef(actionElement) -- 1732
	if actionElement.type == "loop" then -- 1732
		local actionStack = {} -- 1734
		for i = 1, #actionElement.children do -- 1734
			visitAction(actionStack, actionElement.children[i]) -- 1736
		end -- 1736
		if #actionStack == 1 then -- 1736
			return actionStack[1], true -- 1739
		elseif #actionStack > 1 then -- 1739
			local loop = actionElement.props -- 1741
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1742
		end -- 1742
		return nil, true -- 1744
	end -- 1744
	local actionStack = {} -- 1746
	visitAction(actionStack, actionElement) -- 1747
	return #actionStack == 1 and actionStack[1] or nil, false -- 1748
end -- 1748
function structuralChildrenEqual(oldElement, newElement, check) -- 1751
	local oldChildren = {} -- 1757
	local newChildren = {} -- 1758
	for i = 1, #oldElement.children do -- 1758
		local child = oldElement.children[i] -- 1760
		if type(child) == "table" and check(child) then -- 1760
			oldChildren[#oldChildren + 1] = child -- 1762
		end -- 1762
	end -- 1762
	for i = 1, #newElement.children do -- 1762
		local child = newElement.children[i] -- 1766
		if type(child) == "table" and check(child) then -- 1766
			newChildren[#newChildren + 1] = child -- 1768
		end -- 1768
	end -- 1768
	if #oldChildren ~= #newChildren then -- 1768
		return false -- 1771
	end -- 1771
	for i = 1, #oldChildren do -- 1771
		local oldChild = oldChildren[i] -- 1773
		local newChild = newChildren[i] -- 1774
		if oldChild.type ~= newChild.type then -- 1774
			return false -- 1775
		end -- 1775
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1775
			return false -- 1776
		end -- 1776
	end -- 1776
	return true -- 1778
end -- 1778
function runActionChildren(node, element) -- 1781
	local actionChildren = collectRunnableActionElements(element) -- 1782
	local exclusiveActions = {} -- 1783
	local exclusiveLoop -- 1784
	local warnedExclusiveConflict = false -- 1785
	for i = 1, #actionChildren do -- 1785
		do -- 1785
			local actionElement = actionChildren[i] -- 1787
			local action, loop = createActionDef(actionElement) -- 1788
			if action == nil then -- 1788
				goto __continue398 -- 1789
			end -- 1789
			if actionElement.props.exclusive == true then -- 1789
				if exclusiveLoop == nil then -- 1789
					exclusiveLoop = loop -- 1792
				end -- 1792
				if exclusiveLoop == loop then -- 1792
					exclusiveActions[#exclusiveActions + 1] = action -- 1795
				elseif not warnedExclusiveConflict then -- 1795
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1797
					warnedExclusiveConflict = true -- 1798
				end -- 1798
			end -- 1798
		end -- 1798
		::__continue398:: -- 1798
	end -- 1798
	if #exclusiveActions == 1 then -- 1798
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1803
	elseif #exclusiveActions > 1 then -- 1803
		node:perform( -- 1805
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1805
			exclusiveLoop == true -- 1805
		) -- 1805
	end -- 1805
	for i = 1, #actionChildren do -- 1805
		do -- 1805
			local actionElement = actionChildren[i] -- 1808
			if actionElement.props.exclusive == true then -- 1808
				goto __continue406 -- 1809
			end -- 1809
			local action, loop = createActionDef(actionElement) -- 1810
			if action ~= nil then -- 1810
				node:runAction(action, loop) -- 1812
			end -- 1812
		end -- 1812
		::__continue406:: -- 1812
	end -- 1812
end -- 1812
function patchActionChildren(node, oldElement, newElement) -- 1817
	if not actionChildrenEqual(oldElement, newElement) then -- 1817
		runActionChildren(node, newElement) -- 1819
	end -- 1819
end -- 1819
function toHostElement(enode, parent) -- 1832
	local hostChildren = {} -- 1833
	local props = {} -- 1834
	if enode.props ~= nil then -- 1834
		for k, v in pairs(enode.props) do -- 1836
			props[k] = v -- 1837
		end -- 1837
	end -- 1837
	if enode.type == "label" then -- 1837
		for i = 1, #enode.children do -- 1837
			local child = enode.children[i] -- 1842
			if type(child) ~= "table" then -- 1842
				hostChildren[#hostChildren + 1] = child -- 1844
			end -- 1844
		end -- 1844
	elseif enode.type == "draw-node" then -- 1844
		for i = 1, #enode.children do -- 1844
			local child = enode.children[i] -- 1849
			if type(child) == "table" and isDrawShapeElement(child) then -- 1849
				hostChildren[#hostChildren + 1] = child -- 1851
			end -- 1851
		end -- 1851
	elseif enode.type == "body" then -- 1851
		for i = 1, #enode.children do -- 1851
			local child = enode.children[i] -- 1856
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1856
				hostChildren[#hostChildren + 1] = child -- 1858
			end -- 1858
		end -- 1858
	elseif enode.type == "physics-world" then -- 1858
		for i = 1, #enode.children do -- 1858
			local child = enode.children[i] -- 1863
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1863
				hostChildren[#hostChildren + 1] = child -- 1865
			end -- 1865
		end -- 1865
	end -- 1865
	if enode.type == "body" and props.world == nil then -- 1865
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1870
		if world ~= nil then -- 1870
			props.world = world -- 1872
		end -- 1872
	end -- 1872
	return {type = enode.type, props = props, children = hostChildren} -- 1875
end -- 1875
function createHostNode(enode, parent) -- 1882
	local nodeStack = {} -- 1883
	visitNode( -- 1884
		nodeStack, -- 1884
		toHostElement(enode, parent) -- 1884
	) -- 1884
	if #nodeStack == 1 then -- 1884
		return nodeStack[1] -- 1886
	elseif #nodeStack > 1 then -- 1886
		local node = Dora.Node() -- 1888
		for i = 1, #nodeStack do -- 1888
			node:addChild(nodeStack[i]) -- 1890
		end -- 1890
		return node -- 1892
	end -- 1892
	return nil -- 1894
end -- 1894
function getElementChildren(enode) -- 1897
	local children = {} -- 1898
	if enode.type == "draw-node" or enode.type == "body" then -- 1898
		return children -- 1899
	end -- 1899
	for i = 1, #enode.children do -- 1899
		local child = enode.children[i] -- 1901
		if type(child) == "table" then -- 1901
			local childElement = child -- 1903
			if childElement.type ~= nil then -- 1903
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1903
					children[#children + 1] = childElement -- 1909
				end -- 1909
			else -- 1909
				local list = child -- 1912
				for j = 1, #list do -- 1912
					local item = list[j] -- 1914
					if type(item) == "table" and item.type ~= nil then -- 1914
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1914
							children[#children + 1] = item -- 1920
						end -- 1920
					end -- 1920
				end -- 1920
			end -- 1920
		end -- 1920
	end -- 1920
	return children -- 1927
end -- 1927
function getRecreateMode(oldElement, newElement) -- 1932
	if oldElement.type ~= newElement.type then -- 1932
		return "subtree" -- 1933
	end -- 1933
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1933
		return "subtree" -- 1934
	end -- 1934
	local oldProps = oldElement.props -- 1935
	local newProps = newElement.props -- 1936
	if newElement.type == "draw-node" then -- 1936
		return "host" -- 1937
	end -- 1937
	for k, v in pairs(oldProps) do -- 1938
		if k == "onMount" and newProps[k] ~= v then -- 1938
			return "host" -- 1940
		end -- 1940
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1940
			return "host" -- 1943
		end -- 1943
	end -- 1943
	for k, v in pairs(newProps) do -- 1946
		if k == "onMount" and oldProps[k] ~= v then -- 1946
			return "host" -- 1948
		end -- 1948
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1948
			return "host" -- 1951
		end -- 1951
	end -- 1951
	repeat -- 1951
		local ____switch455 = newElement.type -- 1951
		local ____cond455 = ____switch455 == "grid" -- 1951
		if ____cond455 then -- 1951
			return (oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY) and "host" or nil -- 1956
		end -- 1956
		____cond455 = ____cond455 or (____switch455 == "sprite" or ____switch455 == "video-node" or ____switch455 == "tic80-node" or ____switch455 == "audio-source" or ____switch455 == "particle" or ____switch455 == "tile-node" or ____switch455 == "playable" or ____switch455 == "dragon-bone" or ____switch455 == "spine" or ____switch455 == "model") -- 1956
		if ____cond455 then -- 1956
			return oldProps.file ~= newProps.file and "host" or nil -- 1967
		end -- 1967
		____cond455 = ____cond455 or ____switch455 == "label" -- 1967
		if ____cond455 then -- 1967
			return (oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf) and "host" or nil -- 1969
		end -- 1969
		____cond455 = ____cond455 or ____switch455 == "align-node" -- 1969
		if ____cond455 then -- 1969
			return oldProps.windowRoot ~= newProps.windowRoot and "host" or nil -- 1971
		end -- 1971
		____cond455 = ____cond455 or ____switch455 == "custom-node" -- 1971
		if ____cond455 then -- 1971
			return oldProps.onCreate ~= newProps.onCreate and "host" or nil -- 1973
		end -- 1973
		____cond455 = ____cond455 or ____switch455 == "body" -- 1973
		if ____cond455 then -- 1973
			return (oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement)) and "host" or nil -- 1975
		end -- 1975
	until true -- 1975
	return nil -- 1982
end -- 1982
function isEventProp(key) -- 1985
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1986
end -- 1986
function getEventSlot(key) -- 1989
	repeat -- 1989
		local ____switch458 = key -- 1989
		local ____cond458 = ____switch458 == "onActionEnd" -- 1989
		if ____cond458 then -- 1989
			return "ActionEnd" -- 1991
		end -- 1991
		____cond458 = ____cond458 or ____switch458 == "onTapFilter" -- 1991
		if ____cond458 then -- 1991
			return "TapFilter" -- 1992
		end -- 1992
		____cond458 = ____cond458 or ____switch458 == "onTapBegan" -- 1992
		if ____cond458 then -- 1992
			return "TapBegan" -- 1993
		end -- 1993
		____cond458 = ____cond458 or ____switch458 == "onTapEnded" -- 1993
		if ____cond458 then -- 1993
			return "TapEnded" -- 1994
		end -- 1994
		____cond458 = ____cond458 or ____switch458 == "onTapped" -- 1994
		if ____cond458 then -- 1994
			return "Tapped" -- 1995
		end -- 1995
		____cond458 = ____cond458 or ____switch458 == "onTapMoved" -- 1995
		if ____cond458 then -- 1995
			return "TapMoved" -- 1996
		end -- 1996
		____cond458 = ____cond458 or ____switch458 == "onMouseMove" -- 1996
		if ____cond458 then -- 1996
			return "MouseMove" -- 1997
		end -- 1997
		____cond458 = ____cond458 or ____switch458 == "onMouseWheel" -- 1997
		if ____cond458 then -- 1997
			return "MouseWheel" -- 1998
		end -- 1998
		____cond458 = ____cond458 or ____switch458 == "onGesture" -- 1998
		if ____cond458 then -- 1998
			return "Gesture" -- 1999
		end -- 1999
		____cond458 = ____cond458 or ____switch458 == "onEnter" -- 1999
		if ____cond458 then -- 1999
			return "Enter" -- 2000
		end -- 2000
		____cond458 = ____cond458 or ____switch458 == "onExit" -- 2000
		if ____cond458 then -- 2000
			return "Exit" -- 2001
		end -- 2001
		____cond458 = ____cond458 or ____switch458 == "onCleanup" -- 2001
		if ____cond458 then -- 2001
			return "Cleanup" -- 2002
		end -- 2002
		____cond458 = ____cond458 or ____switch458 == "onKeyDown" -- 2002
		if ____cond458 then -- 2002
			return "KeyDown" -- 2003
		end -- 2003
		____cond458 = ____cond458 or ____switch458 == "onKeyUp" -- 2003
		if ____cond458 then -- 2003
			return "KeyUp" -- 2004
		end -- 2004
		____cond458 = ____cond458 or ____switch458 == "onKeyPressed" -- 2004
		if ____cond458 then -- 2004
			return "KeyPressed" -- 2005
		end -- 2005
		____cond458 = ____cond458 or ____switch458 == "onAttachIME" -- 2005
		if ____cond458 then -- 2005
			return "AttachIME" -- 2006
		end -- 2006
		____cond458 = ____cond458 or ____switch458 == "onDetachIME" -- 2006
		if ____cond458 then -- 2006
			return "DetachIME" -- 2007
		end -- 2007
		____cond458 = ____cond458 or ____switch458 == "onTextInput" -- 2007
		if ____cond458 then -- 2007
			return "TextInput" -- 2008
		end -- 2008
		____cond458 = ____cond458 or ____switch458 == "onTextEditing" -- 2008
		if ____cond458 then -- 2008
			return "TextEditing" -- 2009
		end -- 2009
		____cond458 = ____cond458 or ____switch458 == "onButtonDown" -- 2009
		if ____cond458 then -- 2009
			return "ButtonDown" -- 2010
		end -- 2010
		____cond458 = ____cond458 or ____switch458 == "onButtonUp" -- 2010
		if ____cond458 then -- 2010
			return "ButtonUp" -- 2011
		end -- 2011
		____cond458 = ____cond458 or ____switch458 == "onAxis" -- 2011
		if ____cond458 then -- 2011
			return "Axis" -- 2012
		end -- 2012
		____cond458 = ____cond458 or ____switch458 == "onAnimationEnd" -- 2012
		if ____cond458 then -- 2012
			return "AnimationEnd" -- 2013
		end -- 2013
		____cond458 = ____cond458 or ____switch458 == "onFinished" -- 2013
		if ____cond458 then -- 2013
			return "Finished" -- 2014
		end -- 2014
		____cond458 = ____cond458 or ____switch458 == "onLayout" -- 2014
		if ____cond458 then -- 2014
			return "AlignLayout" -- 2015
		end -- 2015
		____cond458 = ____cond458 or ____switch458 == "onBodyEnter" -- 2015
		if ____cond458 then -- 2015
			return "BodyEnter" -- 2016
		end -- 2016
		____cond458 = ____cond458 or ____switch458 == "onBodyLeave" -- 2016
		if ____cond458 then -- 2016
			return "BodyLeave" -- 2017
		end -- 2017
		____cond458 = ____cond458 or ____switch458 == "onContactStart" -- 2017
		if ____cond458 then -- 2017
			return "ContactStart" -- 2018
		end -- 2018
		____cond458 = ____cond458 or ____switch458 == "onContactEnd" -- 2018
		if ____cond458 then -- 2018
			return "ContactEnd" -- 2019
		end -- 2019
	until true -- 2019
	return nil -- 2021
end -- 2021
function isPatchableEventProp(key) -- 2024
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 2025
end -- 2025
function patchEventProp(node, key, value) -- 2028
	local slotName = getEventSlot(key) -- 2029
	if slotName == nil then -- 2029
		return -- 2030
	end -- 2030
	node:slot(slotName):clear() -- 2031
	if value ~= nil then -- 2031
		if key == "onLayout" then -- 2031
			node:onAlignLayout(value) -- 2034
		else -- 2034
			node:slot(slotName, value) -- 2036
		end -- 2036
	end -- 2036
end -- 2036
function patchContactFilterProp(node, value) -- 2041
	local body = Dora.tolua.cast(node, "Body") -- 2042
	if body == nil then -- 2042
		return -- 2043
	end -- 2043
	if value == nil then -- 2043
		body:onContactFilter(function() return true end) -- 2045
	else -- 2045
		body:onContactFilter(value) -- 2047
	end -- 2047
end -- 2047
function patchUpdateProp(node, value) -- 2051
	if value == nil then -- 2051
		node:unschedule() -- 2053
	elseif type(value) == "thread" then -- 2053
		node:schedule(value) -- 2055
	else -- 2055
		node:schedule(value) -- 2057
	end -- 2057
end -- 2057
function patchRenderProp(node, value) -- 2061
	local clearRender = node.clearRender -- 2062
	if type(clearRender) == "function" then -- 2062
		clearRender(node) -- 2064
	end -- 2064
	if value == nil then -- 2064
		return -- 2067
	end -- 2067
	node:onRender(value) -- 2069
end -- 2069
function clearRemovedProp(node, key) -- 2072
	repeat -- 2072
		local ____switch478 = key -- 2072
		local ____cond478 = ____switch478 == "transformTarget" or ____switch478 == "stencil" -- 2072
		if ____cond478 then -- 2072
			node[key] = nil -- 2076
			return true -- 2077
		end -- 2077
	until true -- 2077
	return false -- 2079
end -- 2079
function getAlignStyleText(style) -- 2082
	local items = {} -- 2083
	for k, v in pairs(style) do -- 2084
		local name = string.gsub(k, "%u", "-%1") -- 2085
		name = string.lower(name) -- 2086
		repeat -- 2086
			local ____switch481 = k -- 2086
			local ____cond481 = ____switch481 == "margin" or ____switch481 == "padding" or ____switch481 == "border" or ____switch481 == "gap" -- 2086
			if ____cond481 then -- 2086
				do -- 2086
					if type(v) == "table" then -- 2086
						local valueStr = table.concat( -- 2091
							__TS__ArrayMap( -- 2091
								v, -- 2091
								function(____, item) return tostring(item) end -- 2091
							), -- 2091
							"," -- 2091
						) -- 2091
						items[#items + 1] = (name .. ":") .. valueStr -- 2092
					else -- 2092
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2094
					end -- 2094
					break -- 2096
				end -- 2096
			end -- 2096
			do -- 2096
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2099
				break -- 2100
			end -- 2100
		until true -- 2100
	end -- 2100
	return table.concat(items, ";") -- 2103
end -- 2103
function patchPlayableProps(node, oldProps, newProps) -- 2106
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2106
		node:play(newProps.play, newProps.loop == true) -- 2108
	end -- 2108
end -- 2108
function patchAudioSourceProps(node, oldProps, newProps) -- 2112
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2112
		local audio = node -- 2114
		repeat -- 2114
			local ____switch490 = newProps.playMode -- 2114
			local ____cond490 = ____switch490 == "normal" -- 2114
			if ____cond490 then -- 2114
				local ____audio_play_62 = audio.play -- 2116
				local ____newProps_delayTime_61 = newProps.delayTime -- 2116
				if ____newProps_delayTime_61 == nil then -- 2116
					____newProps_delayTime_61 = 0 -- 2116
				end -- 2116
				____audio_play_62(audio, ____newProps_delayTime_61) -- 2116
				break -- 2116
			end -- 2116
			____cond490 = ____cond490 or ____switch490 == "background" -- 2116
			if ____cond490 then -- 2116
				audio:playBackground() -- 2117
				break -- 2117
			end -- 2117
			____cond490 = ____cond490 or ____switch490 == "3D" -- 2117
			if ____cond490 then -- 2117
				local ____audio_play3D_64 = audio.play3D -- 2118
				local ____newProps_delayTime_63 = newProps.delayTime -- 2118
				if ____newProps_delayTime_63 == nil then -- 2118
					____newProps_delayTime_63 = 0 -- 2118
				end -- 2118
				____audio_play3D_64(audio, ____newProps_delayTime_63) -- 2118
				break -- 2118
			end -- 2118
		until true -- 2118
	end -- 2118
end -- 2118
function patchParticleProps(node, oldProps, newProps) -- 2123
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2123
		local particle = node -- 2125
		if newProps.emit then -- 2125
			particle:start() -- 2127
		else -- 2127
			particle:stop() -- 2129
		end -- 2129
	end -- 2129
end -- 2129
function patchAlignNodeProps(node, oldProps, newProps) -- 2134
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2134
		node:css(getAlignStyleText(newProps.style)) -- 2136
	end -- 2136
end -- 2136
function patchLineProps(node, oldProps, newProps) -- 2140
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2140
		local ____self_68 = node -- 2140
		local ____self_68_set_69 = ____self_68.set -- 2140
		local ____newProps_verts_67 = newProps.verts -- 2142
		local ____Dora_Color_66 = Dora.Color -- 2142
		local ____newProps_lineColor_65 = newProps.lineColor -- 2142
		if ____newProps_lineColor_65 == nil then -- 2142
			____newProps_lineColor_65 = 4294967295 -- 2142
		end -- 2142
		____self_68_set_69( -- 2142
			____self_68, -- 2142
			____newProps_verts_67, -- 2142
			____Dora_Color_66(____newProps_lineColor_65) -- 2142
		) -- 2142
	end -- 2142
end -- 2142
function clearRef(props, node) -- 2146
	local ref = props.ref -- 2147
	if ref ~= nil and (node == nil or ref.current == node) then -- 2147
		ref.current = nil -- 2149
	end -- 2149
end -- 2149
function patchRef(node, oldProps, newProps) -- 2153
	if oldProps.ref ~= newProps.ref then -- 2153
		clearRef(oldProps, node) -- 2155
		local ref = newProps.ref -- 2156
		if ref ~= nil then -- 2156
			ref.current = node -- 2158
		end -- 2158
	end -- 2158
end -- 2158
function applyProp(node, enode, key, value) -- 2163
	local name = key -- 2164
	repeat -- 2164
		local ____switch505 = name -- 2164
		local ____cond505 = ____switch505 == "key" or ____switch505 == "children" or ____switch505 == "onMount" or ____switch505 == "onUnmount" -- 2164
		if ____cond505 then -- 2164
			return -- 2170
		end -- 2170
		____cond505 = ____cond505 or ____switch505 == "ref" -- 2170
		if ____cond505 then -- 2170
			value.current = node -- 2172
			return -- 2173
		end -- 2173
		____cond505 = ____cond505 or ____switch505 == "anchorX" -- 2173
		if ____cond505 then -- 2173
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2175
			return -- 2176
		end -- 2176
		____cond505 = ____cond505 or ____switch505 == "anchorY" -- 2176
		if ____cond505 then -- 2176
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2178
			return -- 2179
		end -- 2179
		____cond505 = ____cond505 or ____switch505 == "color3" -- 2179
		if ____cond505 then -- 2179
			node.color3 = Dora.Color3(value) -- 2181
			return -- 2182
		end -- 2182
		____cond505 = ____cond505 or ____switch505 == "transformTarget" -- 2182
		if ____cond505 then -- 2182
			node.transformTarget = value.current -- 2184
			return -- 2185
		end -- 2185
		____cond505 = ____cond505 or ____switch505 == "outlineColor" -- 2185
		if ____cond505 then -- 2185
			node[name] = Dora.Color(value) -- 2187
			return -- 2188
		end -- 2188
		____cond505 = ____cond505 or ____switch505 == "smoothLower" -- 2188
		if ____cond505 then -- 2188
			do -- 2188
				local smooth = node.smooth -- 2190
				node.smooth = Dora.Vec2(value, smooth.y) -- 2191
				return -- 2192
			end -- 2192
		end -- 2192
		____cond505 = ____cond505 or ____switch505 == "smoothUpper" -- 2192
		if ____cond505 then -- 2192
			do -- 2192
				local smooth = node.smooth -- 2195
				node.smooth = Dora.Vec2(smooth.x, value) -- 2196
				return -- 2197
			end -- 2197
		end -- 2197
	until true -- 2197
	if isEventProp(key) then -- 2197
		if key == "onUpdate" then -- 2197
			patchUpdateProp(node, value) -- 2202
		elseif key == "onRender" then -- 2202
			patchRenderProp(node, value) -- 2204
		elseif key == "onContactFilter" then -- 2204
			patchContactFilterProp(node, value) -- 2206
		elseif isPatchableEventProp(key) then -- 2206
			patchEventProp(node, key, value) -- 2208
		end -- 2208
		return -- 2210
	end -- 2210
	node[name] = value -- 2212
end -- 2212
function patchProps(node, oldElement, newElement) -- 2215
	local oldProps = oldElement.props -- 2216
	local newProps = newElement.props -- 2217
	for k in pairs(oldProps) do -- 2218
		if k == "onUpdate" and newProps[k] == nil then -- 2218
			patchUpdateProp(node, nil) -- 2220
		elseif k == "onRender" and newProps[k] == nil then -- 2220
			patchRenderProp(node, nil) -- 2222
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2222
			patchContactFilterProp(node, nil) -- 2224
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2224
			patchEventProp(node, k, nil) -- 2226
		elseif newProps[k] == nil then -- 2226
			clearRemovedProp(node, k) -- 2228
		end -- 2228
	end -- 2228
	patchRef(node, oldProps, newProps) -- 2231
	for k, v in pairs(newProps) do -- 2232
		if k ~= "ref" and oldProps[k] ~= v then -- 2232
			applyProp(node, newElement, k, v) -- 2234
		end -- 2234
	end -- 2234
	if newElement.type == "label" then -- 2234
		node.text = getPrimitiveLabelText(newElement) -- 2238
	elseif newElement.type == "physics-world" then -- 2238
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2240
		if world ~= nil then -- 2240
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2242
		end -- 2242
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2242
		patchPlayableProps(node, oldProps, newProps) -- 2250
	elseif newElement.type == "audio-source" then -- 2250
		patchAudioSourceProps(node, oldProps, newProps) -- 2252
	elseif newElement.type == "particle" then -- 2252
		patchParticleProps(node, oldProps, newProps) -- 2254
	elseif newElement.type == "align-node" then -- 2254
		patchAlignNodeProps(node, oldProps, newProps) -- 2256
	elseif newElement.type == "line" then -- 2256
		patchLineProps(node, oldProps, newProps) -- 2258
	end -- 2258
	applyAutoEnableProps(node, newProps) -- 2260
end -- 2260
function addChildToParent(parent, node, props) -- 2263
	if props.tag ~= nil then -- 2263
		parent:addChild(node, props.order or 0, props.tag) -- 2265
	elseif props.order ~= nil then -- 2265
		parent:addChild(node, props.order) -- 2267
	else -- 2267
		parent:addChild(node) -- 2269
	end -- 2269
end -- 2269
function mountElement(parent, enode) -- 2273
	local node = createHostNode(enode, parent) -- 2274
	if node == nil then -- 2274
		return nil -- 2276
	end -- 2276
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2276
		return nil -- 2285
	end -- 2285
	local props = enode.props -- 2287
	addChildToParent(parent, node, props) -- 2288
	local mounted = {element = enode, node = node, children = {}} -- 2289
	runActionChildren(node, enode) -- 2290
	mounted.children = reconcileChildren( -- 2291
		node, -- 2291
		{}, -- 2291
		getElementChildren(enode) -- 2291
	) -- 2291
	return mounted -- 2292
end -- 2292
function unmountHostElement(mounted) -- 2295
	local props = mounted.element.props -- 2296
	if props.onUnmount ~= nil then -- 2296
		props.onUnmount(mounted.node) -- 2298
	end -- 2298
	clearRef(mounted.element.props, mounted.node) -- 2300
	mounted.node:removeFromParent(true) -- 2301
end -- 2301
function unmountElement(mounted) -- 2304
	for i = 1, #mounted.children do -- 2304
		unmountElement(mounted.children[i]) -- 2306
	end -- 2306
	unmountHostElement(mounted) -- 2308
end -- 2308
function reconcileElement(parent, oldMounted, newElement) -- 2311
	if oldMounted == nil then -- 2311
		return mountElement(parent, newElement) -- 2313
	end -- 2313
	local recreateMode = getRecreateMode(oldMounted.element, newElement) -- 2315
	if recreateMode == "subtree" then -- 2315
		local oldNode = oldMounted.node -- 2317
		local oldOrder = oldNode.order -- 2318
		local oldTag = oldNode.tag -- 2319
		unmountElement(oldMounted) -- 2320
		local mounted = mountElement(parent, newElement) -- 2321
		if mounted ~= nil then -- 2321
			mounted.node.order = newElement.props.order or oldOrder -- 2323
			mounted.node.tag = newElement.props.tag or oldTag -- 2324
		end -- 2324
		return mounted -- 2326
	end -- 2326
	if recreateMode == "host" then -- 2326
		local oldNode = oldMounted.node -- 2329
		local oldOrder = oldNode.order -- 2330
		local oldTag = oldNode.tag -- 2331
		local node = createHostNode(newElement, parent) -- 2332
		if node == nil then -- 2332
			unmountElement(oldMounted) -- 2334
			return nil -- 2335
		end -- 2335
		addChildToParent(parent, node, newElement.props) -- 2337
		node.order = newElement.props.order or oldOrder -- 2338
		node.tag = newElement.props.tag or oldTag -- 2339
		runActionChildren(node, newElement) -- 2340
		for i = 1, #oldMounted.children do -- 2340
			oldMounted.children[i].node:moveToParent(node) -- 2342
		end -- 2342
		unmountHostElement(oldMounted) -- 2344
		oldMounted.node = node -- 2345
		oldMounted.children = reconcileChildren( -- 2346
			node, -- 2346
			oldMounted.children, -- 2346
			getElementChildren(newElement) -- 2346
		) -- 2346
		oldMounted.element = newElement -- 2347
		return oldMounted -- 2348
	end -- 2348
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2350
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2351
	oldMounted.children = reconcileChildren( -- 2352
		oldMounted.node, -- 2352
		oldMounted.children, -- 2352
		getElementChildren(newElement) -- 2352
	) -- 2352
	oldMounted.element = newElement -- 2353
	return oldMounted -- 2354
end -- 2354
function reconcileChildren(parent, oldChildren, newElements) -- 2357
	warnUnkeyedDynamicChildren(oldChildren, newElements) -- 2358
	local oldByKey = {} -- 2359
	local usedOld = {} -- 2360
	for i = 1, #oldChildren do -- 2360
		local oldChild = oldChildren[i] -- 2362
		local key = getElementKey(oldChild.element) -- 2363
		if key ~= nil then -- 2363
			oldByKey[key] = oldChild -- 2365
		end -- 2365
	end -- 2365
	local nextChildren = {} -- 2368
	for i = 1, #newElements do -- 2368
		local newElement = newElements[i] -- 2370
		local key = getElementKey(newElement) -- 2371
		local oldChild -- 2372
		if key ~= nil then -- 2372
			oldChild = oldByKey[key] -- 2374
		else -- 2374
			oldChild = oldChildren[i] -- 2376
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2376
				oldChild = nil -- 2378
			end -- 2378
		end -- 2378
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2381
		if mounted ~= nil then -- 2381
			usedOld[mounted] = true -- 2383
			nextChildren[#nextChildren + 1] = mounted -- 2384
			local props = newElement.props -- 2385
			mounted.node.order = props.order or i -- 2386
			if props.tag ~= nil then -- 2386
				mounted.node.tag = props.tag -- 2387
			end -- 2387
		end -- 2387
	end -- 2387
	for i = 1, #oldChildren do -- 2387
		local oldChild = oldChildren[i] -- 2391
		if not usedOld[oldChild] then -- 2391
			unmountElement(oldChild) -- 2393
		end -- 2393
	end -- 2393
	return nextChildren -- 2396
end -- 2396
____exports.React = {} -- 2396
local React = ____exports.React -- 2396
do -- 2396
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
					____cond77 = ____cond77 or ____switch77 == "rect-shape" -- 384
					if ____cond77 then -- 384
						do -- 384
							local rect = child.props -- 387
							local centerX = rect.centerX or 0 -- 388
							local centerY = rect.centerY or 0 -- 389
							local hw = rect.width / 2 -- 390
							local hh = rect.height / 2 -- 391
							node:drawPolygon( -- 392
								{ -- 393
									Dora.Vec2(centerX - hw, centerY + hh), -- 394
									Dora.Vec2(centerX + hw, centerY + hh), -- 395
									Dora.Vec2(centerX + hw, centerY - hh), -- 396
									Dora.Vec2(centerX - hw, centerY - hh) -- 397
								}, -- 397
								Dora.Color(rect.fillColor or 4294967295), -- 399
								rect.borderWidth or 0, -- 400
								Dora.Color(rect.borderColor or 4294967295) -- 401
							) -- 401
							break -- 403
						end -- 403
					end -- 403
					____cond77 = ____cond77 or ____switch77 == "polygon-shape" -- 403
					if ____cond77 then -- 403
						do -- 403
							local poly = child.props -- 406
							node:drawPolygon( -- 407
								poly.verts, -- 408
								Dora.Color(poly.fillColor or 4294967295), -- 409
								poly.borderWidth or 0, -- 410
								Dora.Color(poly.borderColor or 4294967295) -- 411
							) -- 411
							break -- 413
						end -- 413
					end -- 413
					____cond77 = ____cond77 or ____switch77 == "verts-shape" -- 413
					if ____cond77 then -- 413
						do -- 413
							local verts = child.props -- 416
							node:drawVertices(__TS__ArrayMap( -- 417
								verts.verts, -- 417
								function(____, ____bindingPattern0) -- 417
									local color -- 417
									local vert -- 417
									vert = ____bindingPattern0[1] -- 417
									color = ____bindingPattern0[2] -- 417
									return { -- 417
										vert, -- 417
										Dora.Color(color) -- 417
									} -- 417
								end -- 417
							)) -- 417
							break -- 418
						end -- 418
					end -- 418
				until true -- 418
			end -- 418
			::__continue75:: -- 418
		end -- 418
		return cnode -- 422
	end -- 357
end -- 357
local getGrid -- 426
do -- 426
	local function handleGridAttribute(cnode, _enode, k, v) -- 428
		repeat -- 428
			local ____switch86 = k -- 428
			local ____cond86 = ____switch86 == "file" or ____switch86 == "gridX" or ____switch86 == "gridY" -- 428
			if ____cond86 then -- 428
				return true -- 430
			end -- 430
			____cond86 = ____cond86 or ____switch86 == "textureRect" -- 430
			if ____cond86 then -- 430
				cnode.textureRect = v -- 431
				return true -- 431
			end -- 431
			____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 431
			if ____cond86 then -- 431
				cnode.depthWrite = v -- 432
				return true -- 432
			end -- 432
			____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 432
			if ____cond86 then -- 432
				cnode.blendFunc = v -- 433
				return true -- 433
			end -- 433
			____cond86 = ____cond86 or ____switch86 == "effect" -- 433
			if ____cond86 then -- 433
				cnode.effect = v -- 434
				return true -- 434
			end -- 434
		until true -- 434
		return false -- 436
	end -- 428
	getGrid = function(enode) -- 438
		local grid = enode.props -- 439
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 440
		local cnode = getNode(enode, node, handleGridAttribute) -- 441
		return cnode -- 442
	end -- 438
end -- 438
local getSprite -- 446
local getVideoNode -- 447
local getTIC80Node -- 448
do -- 448
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 450
		repeat -- 450
			local ____switch90 = k -- 450
			local ____cond90 = ____switch90 == "file" -- 450
			if ____cond90 then -- 450
				return true -- 452
			end -- 452
			____cond90 = ____cond90 or ____switch90 == "textureRect" -- 452
			if ____cond90 then -- 452
				cnode.textureRect = v -- 453
				return true -- 453
			end -- 453
			____cond90 = ____cond90 or ____switch90 == "depthWrite" -- 453
			if ____cond90 then -- 453
				cnode.depthWrite = v -- 454
				return true -- 454
			end -- 454
			____cond90 = ____cond90 or ____switch90 == "blendFunc" -- 454
			if ____cond90 then -- 454
				cnode.blendFunc = v -- 455
				return true -- 455
			end -- 455
			____cond90 = ____cond90 or ____switch90 == "effect" -- 455
			if ____cond90 then -- 455
				cnode.effect = v -- 456
				return true -- 456
			end -- 456
			____cond90 = ____cond90 or ____switch90 == "alphaRef" -- 456
			if ____cond90 then -- 456
				cnode.alphaRef = v -- 457
				return true -- 457
			end -- 457
			____cond90 = ____cond90 or ____switch90 == "uwrap" -- 457
			if ____cond90 then -- 457
				cnode.uwrap = v -- 458
				return true -- 458
			end -- 458
			____cond90 = ____cond90 or ____switch90 == "vwrap" -- 458
			if ____cond90 then -- 458
				cnode.vwrap = v -- 459
				return true -- 459
			end -- 459
			____cond90 = ____cond90 or ____switch90 == "filter" -- 459
			if ____cond90 then -- 459
				cnode.filter = v -- 460
				return true -- 460
			end -- 460
		until true -- 460
		return false -- 462
	end -- 450
	getSprite = function(enode) -- 464
		local sp = enode.props -- 465
		if sp.file then -- 465
			local node = Dora.Sprite(sp.file) -- 467
			if node ~= nil then -- 467
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 469
				return cnode -- 470
			end -- 470
		else -- 470
			local node = Dora.Sprite() -- 473
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 474
			return cnode -- 475
		end -- 475
		return nil -- 477
	end -- 464
	getVideoNode = function(enode) -- 479
		local vn = enode.props -- 480
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 481
		local ____vn_file_9 = vn.file -- 481
		local ____vn_looped_8 = vn.looped -- 481
		if ____vn_looped_8 == nil then -- 481
			____vn_looped_8 = false -- 481
		end -- 481
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 481
		if node ~= nil then -- 481
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 483
			return cnode -- 484
		end -- 484
		return nil -- 486
	end -- 479
	getTIC80Node = function(enode) -- 488
		local tic = enode.props -- 489
		local node = Dora.TIC80Node(tic.file) -- 490
		if node ~= nil then -- 490
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 492
			return cnode -- 493
		end -- 493
		return nil -- 495
	end -- 488
end -- 488
local getAudioSource -- 499
do -- 499
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 501
		repeat -- 501
			local ____switch101 = k -- 501
			local ____cond101 = ____switch101 == "file" -- 501
			if ____cond101 then -- 501
				return true -- 503
			end -- 503
			____cond101 = ____cond101 or ____switch101 == "autoRemove" -- 503
			if ____cond101 then -- 503
				return true -- 504
			end -- 504
			____cond101 = ____cond101 or ____switch101 == "bus" -- 504
			if ____cond101 then -- 504
				return true -- 505
			end -- 505
			____cond101 = ____cond101 or ____switch101 == "volume" -- 505
			if ____cond101 then -- 505
				cnode.volume = v -- 506
				return true -- 506
			end -- 506
			____cond101 = ____cond101 or ____switch101 == "pan" -- 506
			if ____cond101 then -- 506
				cnode.pan = v -- 507
				return true -- 507
			end -- 507
			____cond101 = ____cond101 or ____switch101 == "looping" -- 507
			if ____cond101 then -- 507
				cnode.looping = v -- 508
				return true -- 508
			end -- 508
			____cond101 = ____cond101 or ____switch101 == "playMode" -- 508
			if ____cond101 then -- 508
				do -- 508
					local aus = enode.props -- 510
					repeat -- 510
						local ____switch103 = v -- 510
						local ____cond103 = ____switch103 == "normal" -- 510
						if ____cond103 then -- 510
							cnode:play(aus.delayTime or 0) -- 512
							break -- 512
						end -- 512
						____cond103 = ____cond103 or ____switch103 == "background" -- 512
						if ____cond103 then -- 512
							cnode:playBackground() -- 513
							break -- 513
						end -- 513
						____cond103 = ____cond103 or ____switch103 == "3D" -- 513
						if ____cond103 then -- 513
							cnode:play3D(aus.delayTime or 0) -- 514
							break -- 514
						end -- 514
					until true -- 514
					return true -- 516
				end -- 516
			end -- 516
			____cond101 = ____cond101 or ____switch101 == "delayTime" -- 516
			if ____cond101 then -- 516
				return true -- 518
			end -- 518
			____cond101 = ____cond101 or ____switch101 == "protected" -- 518
			if ____cond101 then -- 518
				cnode:setProtected(v) -- 519
				return true -- 519
			end -- 519
			____cond101 = ____cond101 or ____switch101 == "loopPoint" -- 519
			if ____cond101 then -- 519
				cnode:setLoopPoint(v) -- 520
				return true -- 520
			end -- 520
			____cond101 = ____cond101 or ____switch101 == "velocity" -- 520
			if ____cond101 then -- 520
				do -- 520
					local vx, vy, vz = table.unpack(v, 1, 3) -- 522
					cnode:setVelocity(vx, vy, vz) -- 523
					return true -- 524
				end -- 524
			end -- 524
			____cond101 = ____cond101 or ____switch101 == "minMaxDistance" -- 524
			if ____cond101 then -- 524
				do -- 524
					local min, max = table.unpack(v, 1, 2) -- 527
					cnode:setMinMaxDistance(min, max) -- 528
					return true -- 529
				end -- 529
			end -- 529
			____cond101 = ____cond101 or ____switch101 == "attenuation" -- 529
			if ____cond101 then -- 529
				do -- 529
					local model, factor = table.unpack(v, 1, 2) -- 532
					cnode:setAttenuation(model, factor) -- 533
					return true -- 534
				end -- 534
			end -- 534
			____cond101 = ____cond101 or ____switch101 == "dopplerFactor" -- 534
			if ____cond101 then -- 534
				cnode:setDopplerFactor(v) -- 536
				return true -- 536
			end -- 536
		until true -- 536
		return false -- 538
	end -- 501
	getAudioSource = function(enode) -- 540
		local aus = enode.props -- 541
		local ____aus_autoRemove_11 = aus.autoRemove -- 542
		if ____aus_autoRemove_11 == nil then -- 542
			____aus_autoRemove_11 = true -- 542
		end -- 542
		local autoRemove = ____aus_autoRemove_11 -- 542
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 543
		if node ~= nil then -- 543
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 545
			return cnode -- 546
		end -- 546
		return nil -- 548
	end -- 540
end -- 540
local getLabel -- 552
do -- 552
	local function handleLabelAttribute(cnode, _enode, k, v) -- 554
		repeat -- 554
			local ____switch111 = k -- 554
			local ____cond111 = ____switch111 == "fontName" or ____switch111 == "fontSize" or ____switch111 == "text" or ____switch111 == "smoothLower" or ____switch111 == "smoothUpper" -- 554
			if ____cond111 then -- 554
				return true -- 556
			end -- 556
			____cond111 = ____cond111 or ____switch111 == "alphaRef" -- 556
			if ____cond111 then -- 556
				cnode.alphaRef = v -- 557
				return true -- 557
			end -- 557
			____cond111 = ____cond111 or ____switch111 == "textWidth" -- 557
			if ____cond111 then -- 557
				cnode.textWidth = v -- 558
				return true -- 558
			end -- 558
			____cond111 = ____cond111 or ____switch111 == "lineGap" -- 558
			if ____cond111 then -- 558
				cnode.lineGap = v -- 559
				return true -- 559
			end -- 559
			____cond111 = ____cond111 or ____switch111 == "spacing" -- 559
			if ____cond111 then -- 559
				cnode.spacing = v -- 560
				return true -- 560
			end -- 560
			____cond111 = ____cond111 or ____switch111 == "outlineColor" -- 560
			if ____cond111 then -- 560
				cnode.outlineColor = Dora.Color(v) -- 561
				return true -- 561
			end -- 561
			____cond111 = ____cond111 or ____switch111 == "outlineWidth" -- 561
			if ____cond111 then -- 561
				cnode.outlineWidth = v -- 562
				return true -- 562
			end -- 562
			____cond111 = ____cond111 or ____switch111 == "blendFunc" -- 562
			if ____cond111 then -- 562
				cnode.blendFunc = v -- 563
				return true -- 563
			end -- 563
			____cond111 = ____cond111 or ____switch111 == "depthWrite" -- 563
			if ____cond111 then -- 563
				cnode.depthWrite = v -- 564
				return true -- 564
			end -- 564
			____cond111 = ____cond111 or ____switch111 == "batched" -- 564
			if ____cond111 then -- 564
				cnode.batched = v -- 565
				return true -- 565
			end -- 565
			____cond111 = ____cond111 or ____switch111 == "effect" -- 565
			if ____cond111 then -- 565
				cnode.effect = v -- 566
				return true -- 566
			end -- 566
			____cond111 = ____cond111 or ____switch111 == "alignment" -- 566
			if ____cond111 then -- 566
				cnode.alignment = v -- 567
				return true -- 567
			end -- 567
		until true -- 567
		return false -- 569
	end -- 554
	getLabel = function(enode) -- 571
		local label = enode.props -- 572
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 573
		if node ~= nil then -- 573
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 573
				local ____node_smooth_12 = node.smooth -- 576
				local x = ____node_smooth_12.x -- 576
				local y = ____node_smooth_12.y -- 576
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 577
			end -- 577
			local cnode = getNode(enode, node, handleLabelAttribute) -- 579
			local ____enode_13 = enode -- 580
			local children = ____enode_13.children -- 580
			local text = label.text or "" -- 581
			for i = 1, #children do -- 581
				local child = children[i] -- 583
				if type(child) ~= "table" then -- 583
					text = text .. tostring(child) -- 585
				end -- 585
			end -- 585
			node.text = text -- 588
			return cnode -- 589
		end -- 589
		return nil -- 591
	end -- 571
end -- 571
local getLine -- 595
do -- 595
	local function handleLineAttribute(cnode, enode, k, v) -- 597
		local line = enode.props -- 598
		repeat -- 598
			local ____switch119 = k -- 598
			local ____cond119 = ____switch119 == "verts" -- 598
			if ____cond119 then -- 598
				cnode:set( -- 600
					v, -- 600
					Dora.Color(line.lineColor or 4294967295) -- 600
				) -- 600
				return true -- 600
			end -- 600
			____cond119 = ____cond119 or ____switch119 == "depthWrite" -- 600
			if ____cond119 then -- 600
				cnode.depthWrite = v -- 601
				return true -- 601
			end -- 601
			____cond119 = ____cond119 or ____switch119 == "blendFunc" -- 601
			if ____cond119 then -- 601
				cnode.blendFunc = v -- 602
				return true -- 602
			end -- 602
		until true -- 602
		return false -- 604
	end -- 597
	getLine = function(enode) -- 606
		local node = Dora.Line() -- 607
		local cnode = getNode(enode, node, handleLineAttribute) -- 608
		return cnode -- 609
	end -- 606
end -- 606
local getParticle -- 613
do -- 613
	local function handleParticleAttribute(cnode, _enode, k, v) -- 615
		repeat -- 615
			local ____switch123 = k -- 615
			local ____cond123 = ____switch123 == "file" -- 615
			if ____cond123 then -- 615
				return true -- 617
			end -- 617
			____cond123 = ____cond123 or ____switch123 == "emit" -- 617
			if ____cond123 then -- 617
				if v then -- 617
					cnode:start() -- 618
				end -- 618
				return true -- 618
			end -- 618
			____cond123 = ____cond123 or ____switch123 == "onFinished" -- 618
			if ____cond123 then -- 618
				cnode:slot("Finished", v) -- 619
				return true -- 619
			end -- 619
		until true -- 619
		return false -- 621
	end -- 615
	getParticle = function(enode) -- 623
		local particle = enode.props -- 624
		local node = Dora.Particle(particle.file) -- 625
		if node ~= nil then -- 625
			local cnode = getNode(enode, node, handleParticleAttribute) -- 627
			return cnode -- 628
		end -- 628
		return nil -- 630
	end -- 623
end -- 623
local getMenu -- 634
do -- 634
	local function handleMenuAttribute(cnode, _enode, k, v) -- 636
		repeat -- 636
			local ____switch129 = k -- 636
			local ____cond129 = ____switch129 == "enabled" -- 636
			if ____cond129 then -- 636
				cnode.enabled = v -- 638
				return true -- 638
			end -- 638
		until true -- 638
		return false -- 640
	end -- 636
	getMenu = function(enode) -- 642
		local node = Dora.Menu() -- 643
		local cnode = getNode(enode, node, handleMenuAttribute) -- 644
		return cnode -- 645
	end -- 642
end -- 642
local function getPhysicsWorld(enode) -- 649
	local node = Dora.PhysicsWorld() -- 650
	local cnode = getNode(enode, node) -- 651
	return cnode -- 652
end -- 649
local getBody -- 655
do -- 655
	local function handleBodyAttribute(cnode, _enode, k, v) -- 657
		repeat -- 657
			local ____switch134 = k -- 657
			local ____cond134 = ____switch134 == "type" or ____switch134 == "linearAcceleration" or ____switch134 == "fixedRotation" or ____switch134 == "bullet" or ____switch134 == "world" -- 657
			if ____cond134 then -- 657
				return true -- 664
			end -- 664
			____cond134 = ____cond134 or ____switch134 == "velocityX" -- 664
			if ____cond134 then -- 664
				cnode.velocityX = v -- 665
				return true -- 665
			end -- 665
			____cond134 = ____cond134 or ____switch134 == "velocityY" -- 665
			if ____cond134 then -- 665
				cnode.velocityY = v -- 666
				return true -- 666
			end -- 666
			____cond134 = ____cond134 or ____switch134 == "angularRate" -- 666
			if ____cond134 then -- 666
				cnode.angularRate = v -- 667
				return true -- 667
			end -- 667
			____cond134 = ____cond134 or ____switch134 == "group" -- 667
			if ____cond134 then -- 667
				cnode.group = v -- 668
				return true -- 668
			end -- 668
			____cond134 = ____cond134 or ____switch134 == "linearDamping" -- 668
			if ____cond134 then -- 668
				cnode.linearDamping = v -- 669
				return true -- 669
			end -- 669
			____cond134 = ____cond134 or ____switch134 == "angularDamping" -- 669
			if ____cond134 then -- 669
				cnode.angularDamping = v -- 670
				return true -- 670
			end -- 670
			____cond134 = ____cond134 or ____switch134 == "owner" -- 670
			if ____cond134 then -- 670
				cnode.owner = v -- 671
				return true -- 671
			end -- 671
			____cond134 = ____cond134 or ____switch134 == "receivingContact" -- 671
			if ____cond134 then -- 671
				cnode.receivingContact = v -- 672
				return true -- 672
			end -- 672
			____cond134 = ____cond134 or ____switch134 == "onBodyEnter" -- 672
			if ____cond134 then -- 672
				cnode:slot("BodyEnter", v) -- 673
				return true -- 673
			end -- 673
			____cond134 = ____cond134 or ____switch134 == "onBodyLeave" -- 673
			if ____cond134 then -- 673
				cnode:slot("BodyLeave", v) -- 674
				return true -- 674
			end -- 674
			____cond134 = ____cond134 or ____switch134 == "onContactStart" -- 674
			if ____cond134 then -- 674
				cnode:slot("ContactStart", v) -- 675
				return true -- 675
			end -- 675
			____cond134 = ____cond134 or ____switch134 == "onContactEnd" -- 675
			if ____cond134 then -- 675
				cnode:slot("ContactEnd", v) -- 676
				return true -- 676
			end -- 676
			____cond134 = ____cond134 or ____switch134 == "onContactFilter" -- 676
			if ____cond134 then -- 676
				cnode:onContactFilter(v) -- 677
				return true -- 677
			end -- 677
		until true -- 677
		return false -- 679
	end -- 657
	getBody = function(enode, world) -- 681
		local def = enode.props -- 682
		local bodyDef = Dora.BodyDef() -- 683
		bodyDef.type = def.type -- 684
		if def.angle ~= nil then -- 684
			bodyDef.angle = def.angle -- 685
		end -- 685
		if def.angularDamping ~= nil then -- 685
			bodyDef.angularDamping = def.angularDamping -- 686
		end -- 686
		if def.bullet ~= nil then -- 686
			bodyDef.bullet = def.bullet -- 687
		end -- 687
		if def.fixedRotation ~= nil then -- 687
			bodyDef.fixedRotation = def.fixedRotation -- 688
		end -- 688
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 689
		if def.linearDamping ~= nil then -- 689
			bodyDef.linearDamping = def.linearDamping -- 690
		end -- 690
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 691
		local extraSensors -- 692
		for i = 1, #enode.children do -- 692
			do -- 692
				local child = enode.children[i] -- 694
				if type(child) ~= "table" then -- 694
					goto __continue141 -- 696
				end -- 696
				repeat -- 696
					local ____switch143 = child.type -- 696
					local ____cond143 = ____switch143 == "rect-fixture" -- 696
					if ____cond143 then -- 696
						do -- 696
							local shape = child.props -- 700
							if shape.sensorTag ~= nil then -- 700
								bodyDef:attachPolygonSensor( -- 702
									shape.sensorTag, -- 703
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 704
									shape.width, -- 705
									shape.height, -- 705
									shape.angle or 0 -- 706
								) -- 706
							else -- 706
								bodyDef:attachPolygon( -- 709
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 710
									shape.width, -- 711
									shape.height, -- 711
									shape.angle or 0, -- 712
									shape.density or 1, -- 713
									shape.friction or 0.4, -- 714
									shape.restitution or 0 -- 715
								) -- 715
							end -- 715
							break -- 718
						end -- 718
					end -- 718
					____cond143 = ____cond143 or ____switch143 == "polygon-fixture" -- 718
					if ____cond143 then -- 718
						do -- 718
							local shape = child.props -- 721
							if shape.sensorTag ~= nil then -- 721
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 723
							else -- 723
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 728
							end -- 728
							break -- 735
						end -- 735
					end -- 735
					____cond143 = ____cond143 or ____switch143 == "multi-fixture" -- 735
					if ____cond143 then -- 735
						do -- 735
							local shape = child.props -- 738
							if shape.sensorTag ~= nil then -- 738
								if extraSensors == nil then -- 738
									extraSensors = {} -- 740
								end -- 740
								extraSensors[#extraSensors + 1] = { -- 741
									shape.sensorTag, -- 741
									Dora.BodyDef:multi(shape.verts) -- 741
								} -- 741
							else -- 741
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 743
							end -- 743
							break -- 750
						end -- 750
					end -- 750
					____cond143 = ____cond143 or ____switch143 == "disk-fixture" -- 750
					if ____cond143 then -- 750
						do -- 750
							local shape = child.props -- 753
							if shape.sensorTag ~= nil then -- 753
								bodyDef:attachDiskSensor( -- 755
									shape.sensorTag, -- 756
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 757
									shape.radius -- 758
								) -- 758
							else -- 758
								bodyDef:attachDisk( -- 761
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 762
									shape.radius, -- 763
									shape.density or 1, -- 764
									shape.friction or 0.4, -- 765
									shape.restitution or 0 -- 766
								) -- 766
							end -- 766
							break -- 769
						end -- 769
					end -- 769
					____cond143 = ____cond143 or ____switch143 == "chain-fixture" -- 769
					if ____cond143 then -- 769
						do -- 769
							local shape = child.props -- 772
							if shape.sensorTag ~= nil then -- 772
								if extraSensors == nil then -- 772
									extraSensors = {} -- 774
								end -- 774
								extraSensors[#extraSensors + 1] = { -- 775
									shape.sensorTag, -- 775
									Dora.BodyDef:chain(shape.verts) -- 775
								} -- 775
							else -- 775
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 777
							end -- 777
							break -- 783
						end -- 783
					end -- 783
				until true -- 783
			end -- 783
			::__continue141:: -- 783
		end -- 783
		local body = Dora.Body(bodyDef, world) -- 787
		if extraSensors ~= nil then -- 787
			for i = 1, #extraSensors do -- 787
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 790
				body:attachSensor(tag, def) -- 791
			end -- 791
		end -- 791
		local cnode = getNode(enode, body, handleBodyAttribute) -- 794
		return cnode -- 795
	end -- 681
end -- 681
local getCustomNode -- 799
do -- 799
	local function handleCustomNode(_cnode, _enode, k, _v) -- 801
		repeat -- 801
			local ____switch163 = k -- 801
			local ____cond163 = ____switch163 == "onCreate" -- 801
			if ____cond163 then -- 801
				return true -- 803
			end -- 803
		until true -- 803
		return false -- 805
	end -- 801
	getCustomNode = function(enode) -- 807
		local custom = enode.props -- 808
		local node = custom.onCreate() -- 809
		if node then -- 809
			local cnode = getNode(enode, node, handleCustomNode) -- 811
			return cnode -- 812
		end -- 812
		return nil -- 814
	end -- 807
end -- 807
local getAlignNode -- 818
do -- 818
	local function handleAlignNode(_cnode, _enode, k, _v) -- 820
		repeat -- 820
			local ____switch168 = k -- 820
			local ____cond168 = ____switch168 == "windowRoot" -- 820
			if ____cond168 then -- 820
				return true -- 822
			end -- 822
			____cond168 = ____cond168 or ____switch168 == "style" -- 822
			if ____cond168 then -- 822
				return true -- 823
			end -- 823
			____cond168 = ____cond168 or ____switch168 == "onLayout" -- 823
			if ____cond168 then -- 823
				return true -- 824
			end -- 824
		until true -- 824
		return false -- 826
	end -- 820
	getAlignNode = function(enode) -- 828
		local alignNode = enode.props -- 829
		local node = Dora.AlignNode(alignNode.windowRoot) -- 830
		if alignNode.style then -- 830
			node:css(getAlignStyleText(alignNode.style)) -- 832
		end -- 832
		if alignNode.onLayout then -- 832
			node:onAlignLayout(alignNode.onLayout) -- 835
		end -- 835
		local cnode = getNode(enode, node, handleAlignNode) -- 837
		return cnode -- 838
	end -- 828
end -- 828
local function getEffekNode(enode) -- 842
	return getNode( -- 843
		enode, -- 843
		Dora.EffekNode() -- 843
	) -- 843
end -- 842
local getTileNode -- 846
do -- 846
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 848
		repeat -- 848
			local ____switch175 = k -- 848
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 848
			if ____cond175 then -- 848
				return true -- 850
			end -- 850
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 850
			if ____cond175 then -- 850
				cnode.depthWrite = v -- 851
				return true -- 851
			end -- 851
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 851
			if ____cond175 then -- 851
				cnode.blendFunc = v -- 852
				return true -- 852
			end -- 852
			____cond175 = ____cond175 or ____switch175 == "effect" -- 852
			if ____cond175 then -- 852
				cnode.effect = v -- 853
				return true -- 853
			end -- 853
			____cond175 = ____cond175 or ____switch175 == "filter" -- 853
			if ____cond175 then -- 853
				cnode.filter = v -- 854
				return true -- 854
			end -- 854
		until true -- 854
		return false -- 856
	end -- 848
	getTileNode = function(enode) -- 858
		local tn = enode.props -- 859
		local ____tn_layers_14 -- 860
		if tn.layers then -- 860
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 860
		else -- 860
			____tn_layers_14 = Dora.TileNode(tn.file) -- 860
		end -- 860
		local node = ____tn_layers_14 -- 860
		if node ~= nil then -- 860
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 862
			return cnode -- 863
		end -- 863
		return nil -- 865
	end -- 858
end -- 858
local function addChild(nodeStack, cnode, enode) -- 869
	if #nodeStack > 0 then -- 869
		local last = nodeStack[#nodeStack] -- 871
		last:addChild(cnode) -- 872
	end -- 872
	nodeStack[#nodeStack + 1] = cnode -- 874
	local ____enode_15 = enode -- 875
	local children = ____enode_15.children -- 875
	for i = 1, #children do -- 875
		visitNode(nodeStack, children[i], enode) -- 877
	end -- 877
	if #nodeStack > 1 then -- 877
		table.remove(nodeStack) -- 880
	end -- 880
end -- 869
local function drawNodeCheck(_nodeStack, enode, parent) -- 888
	if parent == nil or parent.type ~= "draw-node" then -- 888
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 890
	end -- 890
end -- 888
local function actionCheck(nodeStack, enode, parent) -- 951
	local unsupported = false -- 952
	if parent == nil then -- 952
		unsupported = true -- 954
	else -- 954
		repeat -- 954
			local ____switch200 = parent.type -- 954
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 954
			if ____cond200 then -- 954
				break -- 957
			end -- 957
			do -- 957
				unsupported = true -- 958
				break -- 958
			end -- 958
		until true -- 958
	end -- 958
	if unsupported then -- 958
		if #nodeStack > 0 then -- 958
			local node = nodeStack[#nodeStack] -- 963
			local actionStack = {} -- 964
			visitAction(actionStack, enode) -- 965
			if #actionStack == 1 then -- 965
				node:runAction(actionStack[1]) -- 967
			end -- 967
		else -- 967
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 970
		end -- 970
	end -- 970
end -- 951
local function bodyCheck(_nodeStack, enode, parent) -- 975
	if parent == nil or parent.type ~= "body" then -- 975
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 977
	end -- 977
end -- 975
actionMap = { -- 981
	["anchor-x"] = Dora.AnchorX, -- 984
	["anchor-y"] = Dora.AnchorY, -- 985
	angle = Dora.Angle, -- 986
	["angle-x"] = Dora.AngleX, -- 987
	["angle-y"] = Dora.AngleY, -- 988
	width = Dora.Width, -- 989
	height = Dora.Height, -- 990
	opacity = Dora.Opacity, -- 991
	roll = Dora.Roll, -- 992
	scale = Dora.Scale, -- 993
	["scale-x"] = Dora.ScaleX, -- 994
	["scale-y"] = Dora.ScaleY, -- 995
	["skew-x"] = Dora.SkewX, -- 996
	["skew-y"] = Dora.SkewY, -- 997
	["move-x"] = Dora.X, -- 998
	["move-y"] = Dora.Y, -- 999
	["move-z"] = Dora.Z -- 1000
} -- 1000
elementMap = { -- 1003
	node = function(nodeStack, enode, parent) -- 1004
		addChild( -- 1005
			nodeStack, -- 1005
			getNode(enode), -- 1005
			enode -- 1005
		) -- 1005
	end, -- 1004
	["clip-node"] = function(nodeStack, enode, parent) -- 1007
		addChild( -- 1008
			nodeStack, -- 1008
			getClipNode(enode), -- 1008
			enode -- 1008
		) -- 1008
	end, -- 1007
	playable = function(nodeStack, enode, parent) -- 1010
		local cnode = getPlayable(enode) -- 1011
		if cnode ~= nil then -- 1011
			addChild(nodeStack, cnode, enode) -- 1013
		end -- 1013
	end, -- 1010
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1016
		local cnode = getDragonBone(enode) -- 1017
		if cnode ~= nil then -- 1017
			addChild(nodeStack, cnode, enode) -- 1019
		end -- 1019
	end, -- 1016
	spine = function(nodeStack, enode, parent) -- 1022
		local cnode = getSpine(enode) -- 1023
		if cnode ~= nil then -- 1023
			addChild(nodeStack, cnode, enode) -- 1025
		end -- 1025
	end, -- 1022
	model = function(nodeStack, enode, parent) -- 1028
		local cnode = getModel(enode) -- 1029
		if cnode ~= nil then -- 1029
			addChild(nodeStack, cnode, enode) -- 1031
		end -- 1031
	end, -- 1028
	["draw-node"] = function(nodeStack, enode, parent) -- 1034
		addChild( -- 1035
			nodeStack, -- 1035
			getDrawNode(enode), -- 1035
			enode -- 1035
		) -- 1035
	end, -- 1034
	["dot-shape"] = drawNodeCheck, -- 1037
	["segment-shape"] = drawNodeCheck, -- 1038
	["rect-shape"] = drawNodeCheck, -- 1039
	["polygon-shape"] = drawNodeCheck, -- 1040
	["verts-shape"] = drawNodeCheck, -- 1041
	grid = function(nodeStack, enode, parent) -- 1042
		addChild( -- 1043
			nodeStack, -- 1043
			getGrid(enode), -- 1043
			enode -- 1043
		) -- 1043
	end, -- 1042
	sprite = function(nodeStack, enode, parent) -- 1045
		local cnode = getSprite(enode) -- 1046
		if cnode ~= nil then -- 1046
			addChild(nodeStack, cnode, enode) -- 1048
		end -- 1048
	end, -- 1045
	["audio-source"] = function(nodeStack, enode, parent) -- 1051
		local cnode = getAudioSource(enode) -- 1052
		if cnode ~= nil then -- 1052
			addChild(nodeStack, cnode, enode) -- 1054
		end -- 1054
	end, -- 1051
	["video-node"] = function(nodeStack, enode, parent) -- 1057
		local cnode = getVideoNode(enode) -- 1058
		if cnode ~= nil then -- 1058
			addChild(nodeStack, cnode, enode) -- 1060
		end -- 1060
	end, -- 1057
	["tic80-node"] = function(nodeStack, enode, parent) -- 1063
		local cnode = getTIC80Node(enode) -- 1064
		if cnode ~= nil then -- 1064
			addChild(nodeStack, cnode, enode) -- 1066
		end -- 1066
	end, -- 1063
	label = function(nodeStack, enode, parent) -- 1069
		local cnode = getLabel(enode) -- 1070
		if cnode ~= nil then -- 1070
			addChild(nodeStack, cnode, enode) -- 1072
		end -- 1072
	end, -- 1069
	line = function(nodeStack, enode, parent) -- 1075
		addChild( -- 1076
			nodeStack, -- 1076
			getLine(enode), -- 1076
			enode -- 1076
		) -- 1076
	end, -- 1075
	particle = function(nodeStack, enode, parent) -- 1078
		local cnode = getParticle(enode) -- 1079
		if cnode ~= nil then -- 1079
			addChild(nodeStack, cnode, enode) -- 1081
		end -- 1081
	end, -- 1078
	menu = function(nodeStack, enode, parent) -- 1084
		addChild( -- 1085
			nodeStack, -- 1085
			getMenu(enode), -- 1085
			enode -- 1085
		) -- 1085
	end, -- 1084
	action = function(_nodeStack, enode, parent) -- 1087
		if #enode.children == 0 then -- 1087
			Warn("<action> tag has no children") -- 1089
			return -- 1090
		end -- 1090
		local action = enode.props -- 1092
		if action.ref == nil then -- 1092
			Warn("<action> tag has no ref") -- 1094
			return -- 1095
		end -- 1095
		local actionStack = {} -- 1097
		for i = 1, #enode.children do -- 1097
			visitAction(actionStack, enode.children[i]) -- 1099
		end -- 1099
		if #actionStack == 1 then -- 1099
			action.ref.current = actionStack[1] -- 1102
		elseif #actionStack > 1 then -- 1102
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1104
		end -- 1104
	end, -- 1087
	["anchor-x"] = actionCheck, -- 1107
	["anchor-y"] = actionCheck, -- 1108
	angle = actionCheck, -- 1109
	["angle-x"] = actionCheck, -- 1110
	["angle-y"] = actionCheck, -- 1111
	delay = actionCheck, -- 1112
	event = actionCheck, -- 1113
	width = actionCheck, -- 1114
	height = actionCheck, -- 1115
	hide = actionCheck, -- 1116
	show = actionCheck, -- 1117
	move = actionCheck, -- 1118
	opacity = actionCheck, -- 1119
	roll = actionCheck, -- 1120
	scale = actionCheck, -- 1121
	["scale-x"] = actionCheck, -- 1122
	["scale-y"] = actionCheck, -- 1123
	["skew-x"] = actionCheck, -- 1124
	["skew-y"] = actionCheck, -- 1125
	["move-x"] = actionCheck, -- 1126
	["move-y"] = actionCheck, -- 1127
	["move-z"] = actionCheck, -- 1128
	frame = actionCheck, -- 1129
	spawn = actionCheck, -- 1130
	sequence = actionCheck, -- 1131
	loop = function(nodeStack, enode, _parent) -- 1132
		if #nodeStack > 0 then -- 1132
			local node = nodeStack[#nodeStack] -- 1134
			local actionStack = {} -- 1135
			for i = 1, #enode.children do -- 1135
				visitAction(actionStack, enode.children[i]) -- 1137
			end -- 1137
			if #actionStack == 1 then -- 1137
				node:runAction(actionStack[1], true) -- 1140
			else -- 1140
				local loop = enode.props -- 1142
				if loop.spawn then -- 1142
					node:runAction( -- 1144
						Dora.Spawn(table.unpack(actionStack)), -- 1144
						true -- 1144
					) -- 1144
				else -- 1144
					node:runAction( -- 1146
						Dora.Sequence(table.unpack(actionStack)), -- 1146
						true -- 1146
					) -- 1146
				end -- 1146
			end -- 1146
		else -- 1146
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1150
		end -- 1150
	end, -- 1132
	["physics-world"] = function(nodeStack, enode, _parent) -- 1153
		addChild( -- 1154
			nodeStack, -- 1154
			getPhysicsWorld(enode), -- 1154
			enode -- 1154
		) -- 1154
	end, -- 1153
	contact = function(nodeStack, enode, _parent) -- 1156
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1157
		if world ~= nil then -- 1157
			local contact = enode.props -- 1159
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1160
		else -- 1160
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1162
		end -- 1162
	end, -- 1156
	body = function(nodeStack, enode, _parent) -- 1165
		local def = enode.props -- 1166
		if def.world then -- 1166
			addChild( -- 1168
				nodeStack, -- 1168
				getBody(enode, def.world), -- 1168
				enode -- 1168
			) -- 1168
			return -- 1169
		end -- 1169
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1171
		if world ~= nil then -- 1171
			addChild( -- 1173
				nodeStack, -- 1173
				getBody(enode, world), -- 1173
				enode -- 1173
			) -- 1173
		else -- 1173
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1175
		end -- 1175
	end, -- 1165
	["rect-fixture"] = bodyCheck, -- 1178
	["polygon-fixture"] = bodyCheck, -- 1179
	["multi-fixture"] = bodyCheck, -- 1180
	["disk-fixture"] = bodyCheck, -- 1181
	["chain-fixture"] = bodyCheck, -- 1182
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1183
		local joint = enode.props -- 1184
		if joint.ref == nil then -- 1184
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1186
			return -- 1187
		end -- 1187
		if joint.bodyA.current == nil then -- 1187
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1190
			return -- 1191
		end -- 1191
		if joint.bodyB.current == nil then -- 1191
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1194
			return -- 1195
		end -- 1195
		local ____joint_ref_19 = joint.ref -- 1197
		local ____self_17 = Dora.Joint -- 1197
		local ____self_17_distance_18 = ____self_17.distance -- 1197
		local ____joint_canCollide_16 = joint.canCollide -- 1198
		if ____joint_canCollide_16 == nil then -- 1198
			____joint_canCollide_16 = false -- 1198
		end -- 1198
		____joint_ref_19.current = ____self_17_distance_18( -- 1197
			____self_17, -- 1197
			____joint_canCollide_16, -- 1198
			joint.bodyA.current, -- 1199
			joint.bodyB.current, -- 1200
			joint.anchorA or Dora.Vec2.zero, -- 1201
			joint.anchorB or Dora.Vec2.zero, -- 1202
			joint.frequency or 0, -- 1203
			joint.damping or 0 -- 1204
		) -- 1204
	end, -- 1183
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1206
		local joint = enode.props -- 1207
		if joint.ref == nil then -- 1207
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1209
			return -- 1210
		end -- 1210
		if joint.bodyA.current == nil then -- 1210
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1213
			return -- 1214
		end -- 1214
		if joint.bodyB.current == nil then -- 1214
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1217
			return -- 1218
		end -- 1218
		local ____joint_ref_23 = joint.ref -- 1220
		local ____self_21 = Dora.Joint -- 1220
		local ____self_21_friction_22 = ____self_21.friction -- 1220
		local ____joint_canCollide_20 = joint.canCollide -- 1221
		if ____joint_canCollide_20 == nil then -- 1221
			____joint_canCollide_20 = false -- 1221
		end -- 1221
		____joint_ref_23.current = ____self_21_friction_22( -- 1220
			____self_21, -- 1220
			____joint_canCollide_20, -- 1221
			joint.bodyA.current, -- 1222
			joint.bodyB.current, -- 1223
			joint.worldPos, -- 1224
			joint.maxForce, -- 1225
			joint.maxTorque -- 1226
		) -- 1226
	end, -- 1206
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1229
		local joint = enode.props -- 1230
		if joint.ref == nil then -- 1230
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1232
			return -- 1233
		end -- 1233
		if joint.jointA.current == nil then -- 1233
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1236
			return -- 1237
		end -- 1237
		if joint.jointB.current == nil then -- 1237
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1240
			return -- 1241
		end -- 1241
		local ____joint_ref_27 = joint.ref -- 1243
		local ____self_25 = Dora.Joint -- 1243
		local ____self_25_gear_26 = ____self_25.gear -- 1243
		local ____joint_canCollide_24 = joint.canCollide -- 1244
		if ____joint_canCollide_24 == nil then -- 1244
			____joint_canCollide_24 = false -- 1244
		end -- 1244
		____joint_ref_27.current = ____self_25_gear_26( -- 1243
			____self_25, -- 1243
			____joint_canCollide_24, -- 1244
			joint.jointA.current, -- 1245
			joint.jointB.current, -- 1246
			joint.ratio or 1 -- 1247
		) -- 1247
	end, -- 1229
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1250
		local joint = enode.props -- 1251
		if joint.ref == nil then -- 1251
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1253
			return -- 1254
		end -- 1254
		if joint.bodyA.current == nil then -- 1254
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1257
			return -- 1258
		end -- 1258
		if joint.bodyB.current == nil then -- 1258
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1261
			return -- 1262
		end -- 1262
		local ____joint_ref_31 = joint.ref -- 1264
		local ____self_29 = Dora.Joint -- 1264
		local ____self_29_spring_30 = ____self_29.spring -- 1264
		local ____joint_canCollide_28 = joint.canCollide -- 1265
		if ____joint_canCollide_28 == nil then -- 1265
			____joint_canCollide_28 = false -- 1265
		end -- 1265
		____joint_ref_31.current = ____self_29_spring_30( -- 1264
			____self_29, -- 1264
			____joint_canCollide_28, -- 1265
			joint.bodyA.current, -- 1266
			joint.bodyB.current, -- 1267
			joint.linearOffset, -- 1268
			joint.angularOffset, -- 1269
			joint.maxForce, -- 1270
			joint.maxTorque, -- 1271
			joint.correctionFactor or 1 -- 1272
		) -- 1272
	end, -- 1250
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1275
		local joint = enode.props -- 1276
		if joint.ref == nil then -- 1276
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1278
			return -- 1279
		end -- 1279
		if joint.body.current == nil then -- 1279
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1282
			return -- 1283
		end -- 1283
		local ____joint_ref_35 = joint.ref -- 1285
		local ____self_33 = Dora.Joint -- 1285
		local ____self_33_move_34 = ____self_33.move -- 1285
		local ____joint_canCollide_32 = joint.canCollide -- 1286
		if ____joint_canCollide_32 == nil then -- 1286
			____joint_canCollide_32 = false -- 1286
		end -- 1286
		____joint_ref_35.current = ____self_33_move_34( -- 1285
			____self_33, -- 1285
			____joint_canCollide_32, -- 1286
			joint.body.current, -- 1287
			joint.targetPos, -- 1288
			joint.maxForce, -- 1289
			joint.frequency, -- 1290
			joint.damping or 0.7 -- 1291
		) -- 1291
	end, -- 1275
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1294
		local joint = enode.props -- 1295
		if joint.ref == nil then -- 1295
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1297
			return -- 1298
		end -- 1298
		if joint.bodyA.current == nil then -- 1298
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1301
			return -- 1302
		end -- 1302
		if joint.bodyB.current == nil then -- 1302
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1305
			return -- 1306
		end -- 1306
		local ____joint_ref_39 = joint.ref -- 1308
		local ____self_37 = Dora.Joint -- 1308
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1308
		local ____joint_canCollide_36 = joint.canCollide -- 1309
		if ____joint_canCollide_36 == nil then -- 1309
			____joint_canCollide_36 = false -- 1309
		end -- 1309
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1308
			____self_37, -- 1308
			____joint_canCollide_36, -- 1309
			joint.bodyA.current, -- 1310
			joint.bodyB.current, -- 1311
			joint.worldPos, -- 1312
			joint.axisAngle, -- 1313
			joint.lowerTranslation or 0, -- 1314
			joint.upperTranslation or 0, -- 1315
			joint.maxMotorForce or 0, -- 1316
			joint.motorSpeed or 0 -- 1317
		) -- 1317
	end, -- 1294
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1320
		local joint = enode.props -- 1321
		if joint.ref == nil then -- 1321
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1323
			return -- 1324
		end -- 1324
		if joint.bodyA.current == nil then -- 1324
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1327
			return -- 1328
		end -- 1328
		if joint.bodyB.current == nil then -- 1328
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1331
			return -- 1332
		end -- 1332
		local ____joint_ref_43 = joint.ref -- 1334
		local ____self_41 = Dora.Joint -- 1334
		local ____self_41_pulley_42 = ____self_41.pulley -- 1334
		local ____joint_canCollide_40 = joint.canCollide -- 1335
		if ____joint_canCollide_40 == nil then -- 1335
			____joint_canCollide_40 = false -- 1335
		end -- 1335
		____joint_ref_43.current = ____self_41_pulley_42( -- 1334
			____self_41, -- 1334
			____joint_canCollide_40, -- 1335
			joint.bodyA.current, -- 1336
			joint.bodyB.current, -- 1337
			joint.anchorA or Dora.Vec2.zero, -- 1338
			joint.anchorB or Dora.Vec2.zero, -- 1339
			joint.groundAnchorA, -- 1340
			joint.groundAnchorB, -- 1341
			joint.ratio or 1 -- 1342
		) -- 1342
	end, -- 1320
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1345
		local joint = enode.props -- 1346
		if joint.ref == nil then -- 1346
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1348
			return -- 1349
		end -- 1349
		if joint.bodyA.current == nil then -- 1349
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1352
			return -- 1353
		end -- 1353
		if joint.bodyB.current == nil then -- 1353
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1356
			return -- 1357
		end -- 1357
		local ____joint_ref_47 = joint.ref -- 1359
		local ____self_45 = Dora.Joint -- 1359
		local ____self_45_revolute_46 = ____self_45.revolute -- 1359
		local ____joint_canCollide_44 = joint.canCollide -- 1360
		if ____joint_canCollide_44 == nil then -- 1360
			____joint_canCollide_44 = false -- 1360
		end -- 1360
		____joint_ref_47.current = ____self_45_revolute_46( -- 1359
			____self_45, -- 1359
			____joint_canCollide_44, -- 1360
			joint.bodyA.current, -- 1361
			joint.bodyB.current, -- 1362
			joint.worldPos, -- 1363
			joint.lowerAngle or 0, -- 1364
			joint.upperAngle or 0, -- 1365
			joint.maxMotorTorque or 0, -- 1366
			joint.motorSpeed or 0 -- 1367
		) -- 1367
	end, -- 1345
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1370
		local joint = enode.props -- 1371
		if joint.ref == nil then -- 1371
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1373
			return -- 1374
		end -- 1374
		if joint.bodyA.current == nil then -- 1374
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1377
			return -- 1378
		end -- 1378
		if joint.bodyB.current == nil then -- 1378
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1381
			return -- 1382
		end -- 1382
		local ____joint_ref_51 = joint.ref -- 1384
		local ____self_49 = Dora.Joint -- 1384
		local ____self_49_rope_50 = ____self_49.rope -- 1384
		local ____joint_canCollide_48 = joint.canCollide -- 1385
		if ____joint_canCollide_48 == nil then -- 1385
			____joint_canCollide_48 = false -- 1385
		end -- 1385
		____joint_ref_51.current = ____self_49_rope_50( -- 1384
			____self_49, -- 1384
			____joint_canCollide_48, -- 1385
			joint.bodyA.current, -- 1386
			joint.bodyB.current, -- 1387
			joint.anchorA or Dora.Vec2.zero, -- 1388
			joint.anchorB or Dora.Vec2.zero, -- 1389
			joint.maxLength or 0 -- 1390
		) -- 1390
	end, -- 1370
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1393
		local joint = enode.props -- 1394
		if joint.ref == nil then -- 1394
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1396
			return -- 1397
		end -- 1397
		if joint.bodyA.current == nil then -- 1397
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1400
			return -- 1401
		end -- 1401
		if joint.bodyB.current == nil then -- 1401
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1404
			return -- 1405
		end -- 1405
		local ____joint_ref_55 = joint.ref -- 1407
		local ____self_53 = Dora.Joint -- 1407
		local ____self_53_weld_54 = ____self_53.weld -- 1407
		local ____joint_canCollide_52 = joint.canCollide -- 1408
		if ____joint_canCollide_52 == nil then -- 1408
			____joint_canCollide_52 = false -- 1408
		end -- 1408
		____joint_ref_55.current = ____self_53_weld_54( -- 1407
			____self_53, -- 1407
			____joint_canCollide_52, -- 1408
			joint.bodyA.current, -- 1409
			joint.bodyB.current, -- 1410
			joint.worldPos, -- 1411
			joint.frequency or 0, -- 1412
			joint.damping or 0 -- 1413
		) -- 1413
	end, -- 1393
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1416
		local joint = enode.props -- 1417
		if joint.ref == nil then -- 1417
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1419
			return -- 1420
		end -- 1420
		if joint.bodyA.current == nil then -- 1420
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1423
			return -- 1424
		end -- 1424
		if joint.bodyB.current == nil then -- 1424
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1427
			return -- 1428
		end -- 1428
		local ____joint_ref_59 = joint.ref -- 1430
		local ____self_57 = Dora.Joint -- 1430
		local ____self_57_wheel_58 = ____self_57.wheel -- 1430
		local ____joint_canCollide_56 = joint.canCollide -- 1431
		if ____joint_canCollide_56 == nil then -- 1431
			____joint_canCollide_56 = false -- 1431
		end -- 1431
		____joint_ref_59.current = ____self_57_wheel_58( -- 1430
			____self_57, -- 1430
			____joint_canCollide_56, -- 1431
			joint.bodyA.current, -- 1432
			joint.bodyB.current, -- 1433
			joint.worldPos, -- 1434
			joint.axisAngle, -- 1435
			joint.maxMotorTorque or 0, -- 1436
			joint.motorSpeed or 0, -- 1437
			joint.frequency or 0, -- 1438
			joint.damping or 0.7 -- 1439
		) -- 1439
	end, -- 1416
	["custom-node"] = function(nodeStack, enode, _parent) -- 1442
		local node = getCustomNode(enode) -- 1443
		if node ~= nil then -- 1443
			addChild(nodeStack, node, enode) -- 1445
		end -- 1445
	end, -- 1442
	["custom-element"] = function() -- 1448
	end, -- 1448
	["align-node"] = function(nodeStack, enode, _parent) -- 1449
		addChild( -- 1450
			nodeStack, -- 1450
			getAlignNode(enode), -- 1450
			enode -- 1450
		) -- 1450
	end, -- 1449
	["effek-node"] = function(nodeStack, enode, _parent) -- 1452
		addChild( -- 1453
			nodeStack, -- 1453
			getEffekNode(enode), -- 1453
			enode -- 1453
		) -- 1453
	end, -- 1452
	effek = function(nodeStack, enode, parent) -- 1455
		if #nodeStack > 0 then -- 1455
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1457
			if node then -- 1457
				local effek = enode.props -- 1459
				local handle = node:play( -- 1460
					effek.file, -- 1460
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1460
					effek.z or 0 -- 1460
				) -- 1460
				if handle >= 0 then -- 1460
					if effek.ref then -- 1460
						effek.ref.current = handle -- 1463
					end -- 1463
					if effek.onEnd then -- 1463
						local onEnd = effek.onEnd -- 1463
						node:slot( -- 1467
							"EffekEnd", -- 1467
							function(h) -- 1467
								if handle == h then -- 1467
									onEnd(nil) -- 1469
								end -- 1469
							end -- 1467
						) -- 1467
					end -- 1467
				end -- 1467
			else -- 1467
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1475
			end -- 1475
		end -- 1475
	end, -- 1455
	["tile-node"] = function(nodeStack, enode, parent) -- 1479
		local cnode = getTileNode(enode) -- 1480
		if cnode ~= nil then -- 1480
			addChild(nodeStack, cnode, enode) -- 1482
		end -- 1482
	end -- 1479
} -- 1479
local roots = {} -- 1535
warnedUnkeyedChildTypes = {} -- 1536
local renderQueued = false -- 1537
local queuedRoots = {} -- 1538
local trackingRoot -- 1539
local function isElementList(node) -- 1543
	return node.type == nil -- 1544
end -- 1543
local function getRenderableElement(renderable) -- 1578
	if type(renderable) == "function" then -- 1578
		return renderable() -- 1580
	end -- 1580
	return renderable -- 1582
end -- 1578
local function removeRoot(root) -- 1823
	for i = 1, #roots do -- 1823
		if roots[i] == root then -- 1823
			table.remove(roots, i) -- 1826
			break -- 1827
		end -- 1827
	end -- 1827
end -- 1823
local function toElementList(node) -- 2399
	if isElementList(node) then -- 2399
		return node -- 2401
	end -- 2401
	return {node} -- 2403
end -- 2399
local function scheduleRootRender(root) -- 2406
	if not root.active then -- 2406
		return -- 2407
	end -- 2407
	for i = 1, #queuedRoots do -- 2407
		if queuedRoots[i] == root then -- 2407
			return -- 2409
		end -- 2409
	end -- 2409
	queuedRoots[#queuedRoots + 1] = root -- 2411
	if renderQueued then -- 2411
		return -- 2412
	end -- 2412
	renderQueued = true -- 2413
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2414
		renderQueued = false -- 2415
		local updatingRoots = queuedRoots -- 2416
		queuedRoots = {} -- 2417
		for i = 1, #updatingRoots do -- 2417
			updatingRoots[i]:update() -- 2419
		end -- 2419
	end)) -- 2414
end -- 2406
____exports.Root = __TS__Class() -- 2424
local Root = ____exports.Root -- 2424
Root.name = "Root" -- 2424
function Root.prototype.____constructor(self, parent) -- 2438
	self.parent = parent -- 2438
	self.mounted = {} -- 2425
	self.signals = {} -- 2427
	self.hookFrames = {} -- 2428
	self.keyedHookFrames = {} -- 2429
	self.nextKeyedHookFrames = {} -- 2430
	self.usedHookFrames = {} -- 2431
	self.previousHookFrames = {} -- 2432
	self.pendingEffects = {} -- 2433
	self.pendingCleanups = {} -- 2434
	self.hookFrameIndex = 0 -- 2435
	self.active = true -- 2436
end -- 2438
function Root.prototype.render(self, enode) -- 2440
	if not self.active then -- 2440
		roots[#roots + 1] = self -- 2442
		self.active = true -- 2443
	end -- 2443
	self.renderable = enode -- 2445
	self:update() -- 2446
end -- 2440
function Root.prototype.update(self) -- 2449
	if not self.active or self.renderable == nil then -- 2449
		return -- 2450
	end -- 2450
	self:unsubscribeSignals() -- 2451
	local lastTrackingRoot = trackingRoot -- 2452
	local lastRenderingHookRoot = renderingHookRoot -- 2453
	trackingRoot = self -- 2454
	renderingHookRoot = self -- 2455
	local elements -- 2456
	do -- 2456
		local ____try, ____error = pcall(function() -- 2456
			self:beginHookRender() -- 2458
			elements = getRenderableElement(self.renderable) -- 2459
		end) -- 2459
		do -- 2459
			self:finishHookRender() -- 2461
			trackingRoot = lastTrackingRoot -- 2462
			renderingHookRoot = lastRenderingHookRoot -- 2463
		end -- 2463
		if not ____try then -- 2463
			error(____error, 0) -- 2463
		end -- 2463
	end -- 2463
	self.mounted = reconcileChildren( -- 2465
		self.parent, -- 2465
		self.mounted, -- 2465
		toElementList(elements) -- 2465
	) -- 2465
	self:flushEffects() -- 2466
end -- 2449
function Root.prototype.unmount(self) -- 2469
	for i = 1, #self.mounted do -- 2469
		unmountElement(self.mounted[i]) -- 2471
	end -- 2471
	for i = 1, #self.hookFrames do -- 2471
		self:queueFrameCleanup(self.hookFrames[i]) -- 2474
	end -- 2474
	self.pendingEffects = {} -- 2476
	self:flushEffects() -- 2477
	self.mounted = {} -- 2478
	self.renderable = nil -- 2479
	self.hookFrames = {} -- 2480
	self.keyedHookFrames = {} -- 2481
	self.nextKeyedHookFrames = {} -- 2482
	self.usedHookFrames = {} -- 2483
	self.previousHookFrames = {} -- 2484
	self.hookFrameIndex = 0 -- 2485
	self:unsubscribeSignals() -- 2486
	if self.active then -- 2486
		removeRoot(self) -- 2488
		self.active = false -- 2489
	end -- 2489
end -- 2469
function Root.prototype.trackSignal(self, signal) -- 2493
	for i = 1, #self.signals do -- 2493
		if self.signals[i] == signal then -- 2493
			return -- 2495
		end -- 2495
	end -- 2495
	local ____self_signals_70 = self.signals -- 2495
	____self_signals_70[#____self_signals_70 + 1] = signal -- 2497
	signal:addRoot(self) -- 2498
end -- 2493
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2501
	local index = self.hookFrameIndex -- 2502
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2503
	local frame -- 2504
	if key ~= nil then -- 2504
		local framesByKey = self.keyedHookFrames[____type] -- 2506
		if framesByKey ~= nil then -- 2506
			frame = framesByKey[key] -- 2508
			if frame ~= nil and self.usedHookFrames[frame] == true then -- 2508
				frame = nil -- 2510
			end -- 2510
		end -- 2510
		if frame == nil then -- 2510
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2514
		end -- 2514
		local nextFramesByKey = self.nextKeyedHookFrames[____type] -- 2516
		if nextFramesByKey == nil then -- 2516
			nextFramesByKey = {} -- 2518
			self.nextKeyedHookFrames[____type] = nextFramesByKey -- 2519
		end -- 2519
		nextFramesByKey[key] = frame -- 2521
		self.hookFrames[index + 1] = frame -- 2522
	else -- 2522
		frame = self.hookFrames[index + 1] -- 2524
		if frame == nil or self.usedHookFrames[frame] == true or frame.type ~= ____type or frame.key ~= nil then -- 2524
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2531
			self.hookFrames[index + 1] = frame -- 2532
		end -- 2532
	end -- 2532
	frame.hookIndex = 0 -- 2535
	self.usedHookFrames[frame] = true -- 2536
	return frame -- 2537
end -- 2501
function Root.prototype.queueEffect(self, hook, effect) -- 2540
	if hook.cleanup ~= nil then -- 2540
		local ____self_pendingCleanups_71 = self.pendingCleanups -- 2540
		____self_pendingCleanups_71[#____self_pendingCleanups_71 + 1] = hook.cleanup -- 2542
		hook.cleanup = nil -- 2543
	end -- 2543
	local ____self_pendingEffects_72 = self.pendingEffects -- 2543
	____self_pendingEffects_72[#____self_pendingEffects_72 + 1] = {hook = hook, effect = effect} -- 2545
end -- 2540
function Root.prototype.beginHookRender(self) -- 2548
	self.previousHookFrames = {table.unpack(self.hookFrames)} -- 2549
	self.hookFrameIndex = 0 -- 2550
	self.usedHookFrames = {} -- 2551
	self.nextKeyedHookFrames = {} -- 2552
end -- 2548
function Root.prototype.finishHookRender(self) -- 2555
	for i = 1, #self.previousHookFrames do -- 2555
		local frame = self.previousHookFrames[i] -- 2557
		if self.usedHookFrames[frame] ~= true then -- 2557
			self:queueFrameCleanup(frame) -- 2559
		end -- 2559
	end -- 2559
	while #self.hookFrames > self.hookFrameIndex do -- 2559
		table.remove(self.hookFrames) -- 2563
	end -- 2563
	self.keyedHookFrames = self.nextKeyedHookFrames -- 2565
	self.previousHookFrames = {} -- 2566
end -- 2555
function Root.prototype.unsubscribeSignals(self) -- 2569
	for i = 1, #self.signals do -- 2569
		self.signals[i]:removeRoot(self) -- 2571
	end -- 2571
	self.signals = {} -- 2573
end -- 2569
function Root.prototype.queueFrameCleanup(self, frame) -- 2576
	for i = 1, #frame.hooks do -- 2576
		local hook = frame.hooks[i] -- 2578
		if hook.cleanup ~= nil then -- 2578
			local ____self_pendingCleanups_73 = self.pendingCleanups -- 2578
			____self_pendingCleanups_73[#____self_pendingCleanups_73 + 1] = hook.cleanup -- 2580
			hook.cleanup = nil -- 2581
		end -- 2581
	end -- 2581
end -- 2576
function Root.prototype.flushEffects(self) -- 2586
	local cleanups = self.pendingCleanups -- 2587
	self.pendingCleanups = {} -- 2588
	for i = 1, #cleanups do -- 2588
		cleanups[i]() -- 2590
	end -- 2590
	local effects = self.pendingEffects -- 2592
	self.pendingEffects = {} -- 2593
	for i = 1, #effects do -- 2593
		local task = effects[i] -- 2595
		local cleanup = task.effect() -- 2596
		if type(cleanup) == "function" then -- 2596
			task.hook.cleanup = cleanup -- 2598
		end -- 2598
	end -- 2598
end -- 2586
function ____exports.createRoot(parent) -- 2604
	local root = __TS__New(____exports.Root, parent) -- 2605
	roots[#roots + 1] = root -- 2606
	return root -- 2607
end -- 2604
____exports.Signal = __TS__Class() -- 2610
local Signal = ____exports.Signal -- 2610
Signal.name = "Signal" -- 2610
function Signal.prototype.____constructor(self, item) -- 2613
	self.item = item -- 2613
	self.roots = {} -- 2611
end -- 2613
function Signal.prototype.addRoot(self, root) -- 2630
	for i = 1, #self.roots do -- 2630
		if self.roots[i] == root then -- 2630
			return -- 2632
		end -- 2632
	end -- 2632
	local ____self_roots_74 = self.roots -- 2632
	____self_roots_74[#____self_roots_74 + 1] = root -- 2634
end -- 2630
function Signal.prototype.removeRoot(self, root) -- 2637
	for i = 1, #self.roots do -- 2637
		if self.roots[i] == root then -- 2637
			table.remove(self.roots, i) -- 2640
			break -- 2641
		end -- 2641
	end -- 2641
end -- 2637
__TS__SetDescriptor( -- 2637
	Signal.prototype, -- 2637
	"value", -- 2637
	{ -- 2637
		get = function(self) -- 2637
			if trackingRoot ~= nil then -- 2637
				trackingRoot:trackSignal(self) -- 2617
			end -- 2617
			return self.item -- 2619
		end, -- 2619
		set = function(self, value) -- 2619
			if self.item == value then -- 2619
				return -- 2623
			end -- 2623
			self.item = value -- 2624
			for i = 1, #self.roots do -- 2624
				scheduleRootRender(self.roots[i]) -- 2626
			end -- 2626
		end -- 2626
	}, -- 2626
	true -- 2626
) -- 2626
function ____exports.signal(value) -- 2647
	return __TS__New(____exports.Signal, value) -- 2648
end -- 2647
function ____exports.reference(item) -- 2651
	local ____item_75 = item -- 2652
	if ____item_75 == nil then -- 2652
		____item_75 = nil -- 2652
	end -- 2652
	return {current = ____item_75} -- 2652
end -- 2651
local function hookDepsEqual(oldDeps, newDeps) -- 2655
	if oldDeps == nil or newDeps == nil then -- 2655
		return false -- 2656
	end -- 2656
	if #oldDeps ~= #newDeps then -- 2656
		return false -- 2657
	end -- 2657
	for i = 1, #oldDeps do -- 2657
		if oldDeps[i] ~= newDeps[i] then -- 2657
			return false -- 2659
		end -- 2659
	end -- 2659
	return true -- 2661
end -- 2655
local function copyDeps(deps) -- 2664
	if deps == nil then -- 2664
		return nil -- 2665
	end -- 2665
	local copied = {} -- 2666
	for i = 1, #deps do -- 2666
		copied[#copied + 1] = deps[i] -- 2668
	end -- 2668
	return copied -- 2670
end -- 2664
function ____exports.useMemo(factory, deps) -- 2673
	local frame = currentHookFrame -- 2674
	if frame == nil then -- 2674
		error("useMemo() can only be called inside a function component") -- 2676
	end -- 2676
	local index = frame.hookIndex -- 2678
	frame.hookIndex = frame.hookIndex + 1 -- 2679
	local hook = frame.hooks[index + 1] -- 2680
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2680
		hook = { -- 2682
			value = factory(), -- 2682
			deps = copyDeps(deps) -- 2682
		} -- 2682
		frame.hooks[index + 1] = hook -- 2683
	end -- 2683
	return hook.value -- 2685
end -- 2673
function ____exports.useCallback(callback, deps) -- 2688
	local frame = currentHookFrame -- 2689
	if frame == nil then -- 2689
		error("useCallback() can only be called inside a function component") -- 2691
	end -- 2691
	local actualDeps = deps or ({}) -- 2693
	local index = frame.hookIndex -- 2694
	frame.hookIndex = frame.hookIndex + 1 -- 2695
	local hook = frame.hooks[index + 1] -- 2696
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2696
		hook = { -- 2698
			value = callback, -- 2698
			deps = copyDeps(actualDeps) -- 2698
		} -- 2698
		frame.hooks[index + 1] = hook -- 2699
	end -- 2699
	return hook.value -- 2701
end -- 2688
function ____exports.useEffect(effect, deps) -- 2704
	local frame = currentHookFrame -- 2705
	if frame == nil or renderingHookRoot == nil then -- 2705
		error("useEffect() can only be called inside a function component") -- 2707
	end -- 2707
	local index = frame.hookIndex -- 2709
	frame.hookIndex = frame.hookIndex + 1 -- 2710
	local hook = frame.hooks[index + 1] -- 2711
	if hook == nil then -- 2711
		hook = {value = nil} -- 2713
		frame.hooks[index + 1] = hook -- 2714
	end -- 2714
	if not hookDepsEqual(hook.deps, deps) then -- 2714
		hook.deps = copyDeps(deps) -- 2717
		renderingHookRoot:queueEffect(hook, effect) -- 2718
	end -- 2718
end -- 2704
function ____exports.useRef(item) -- 2722
	local frame = currentHookFrame -- 2723
	if frame == nil then -- 2723
		Warn("useRef() called outside a function component; falling back to reference()") -- 2725
		return ____exports.reference(item) -- 2726
	end -- 2726
	local index = frame.hookIndex -- 2728
	frame.hookIndex = frame.hookIndex + 1 -- 2729
	local hook = frame.hooks[index + 1] -- 2730
	if hook == nil then -- 2730
		hook = {value = ____exports.reference(item)} -- 2732
		frame.hooks[index + 1] = hook -- 2733
	end -- 2733
	return hook.value -- 2735
end -- 2722
function ____exports.useSignal(value) -- 2738
	local frame = currentHookFrame -- 2739
	if frame == nil then -- 2739
		error("useSignal() can only be called inside a function component") -- 2741
	end -- 2741
	local index = frame.hookIndex -- 2743
	frame.hookIndex = frame.hookIndex + 1 -- 2744
	local hook = frame.hooks[index + 1] -- 2745
	if hook == nil then -- 2745
		hook = {value = ____exports.signal(value)} -- 2747
		frame.hooks[index + 1] = hook -- 2748
	end -- 2748
	return hook.value -- 2750
end -- 2738
local function getPreload(preloadList, node) -- 2753
	if type(node) ~= "table" then -- 2753
		return -- 2755
	end -- 2755
	local enode = node -- 2757
	if enode.type == nil then -- 2757
		local list = node -- 2759
		if #list > 0 then -- 2759
			for i = 1, #list do -- 2759
				getPreload(preloadList, list[i]) -- 2762
			end -- 2762
		end -- 2762
	else -- 2762
		repeat -- 2762
			local ____switch651 = enode.type -- 2762
			local sprite, playable, frame, model, spine, dragonBone, label -- 2762
			local ____cond651 = ____switch651 == "sprite" -- 2762
			if ____cond651 then -- 2762
				sprite = enode.props -- 2768
				if sprite.file then -- 2768
					preloadList[#preloadList + 1] = sprite.file -- 2770
				end -- 2770
				break -- 2772
			end -- 2772
			____cond651 = ____cond651 or ____switch651 == "playable" -- 2772
			if ____cond651 then -- 2772
				playable = enode.props -- 2774
				preloadList[#preloadList + 1] = playable.file -- 2775
				break -- 2776
			end -- 2776
			____cond651 = ____cond651 or ____switch651 == "frame" -- 2776
			if ____cond651 then -- 2776
				frame = enode.props -- 2778
				preloadList[#preloadList + 1] = frame.file -- 2779
				break -- 2780
			end -- 2780
			____cond651 = ____cond651 or ____switch651 == "model" -- 2780
			if ____cond651 then -- 2780
				model = enode.props -- 2782
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2783
				break -- 2784
			end -- 2784
			____cond651 = ____cond651 or ____switch651 == "spine" -- 2784
			if ____cond651 then -- 2784
				spine = enode.props -- 2786
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2787
				break -- 2788
			end -- 2788
			____cond651 = ____cond651 or ____switch651 == "dragon-bone" -- 2788
			if ____cond651 then -- 2788
				dragonBone = enode.props -- 2790
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2791
				break -- 2792
			end -- 2792
			____cond651 = ____cond651 or ____switch651 == "label" -- 2792
			if ____cond651 then -- 2792
				label = enode.props -- 2794
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2795
				break -- 2796
			end -- 2796
		until true -- 2796
	end -- 2796
	getPreload(preloadList, enode.children) -- 2799
end -- 2753
function ____exports.preloadAsync(enode, handler) -- 2802
	local preloadList = {} -- 2803
	getPreload(preloadList, enode) -- 2804
	Dora.Cache:loadAsync(preloadList, handler) -- 2805
end -- 2802
function ____exports.toAction(enode) -- 2808
	local actionDef = ____exports.reference() -- 2809
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2810
	if not actionDef.current then -- 2810
		error("failed to create action") -- 2811
	end -- 2811
	return actionDef.current -- 2812
end -- 2808
return ____exports -- 2808