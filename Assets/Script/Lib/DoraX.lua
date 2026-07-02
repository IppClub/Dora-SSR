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
function renderFunctionComponent(component, props) -- 141
	local frame = renderingHookRoot and renderingHookRoot:beginComponentHooks(component, props.key) -- 142
	if frame == nil then -- 142
		return component(props) -- 144
	end -- 144
	local lastHookFrame = currentHookFrame -- 146
	currentHookFrame = frame -- 147
	do -- 147
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 147
			return true, component(props) -- 149
		end) -- 149
		do -- 149
			currentHookFrame = lastHookFrame -- 151
		end -- 151
		if not ____try then -- 151
			error(____hasReturned, 0) -- 151
		end -- 151
		if ____try and ____hasReturned then -- 151
			return ____returnValue -- 148
		end -- 148
	end -- 148
end -- 148
function applyAutoEnableProps(node, props) -- 157
	local jnode = props -- 158
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 158
		node.touchEnabled = true -- 168
	end -- 168
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 168
		node.keyboardEnabled = true -- 175
	end -- 175
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 175
		node.controllerEnabled = true -- 182
	end -- 182
	local body = Dora.tolua.cast(node, "Body") -- 184
	if body ~= nil then -- 184
		local bodyProps = props -- 186
		if bodyProps.receivingContact ~= false and (bodyProps.onContactStart or bodyProps.onContactEnd) then -- 186
			body.receivingContact = true -- 191
		end -- 191
	end -- 191
end -- 191
function visitAction(actionStack, enode) -- 886
	local createAction = actionMap[enode.type] -- 887
	if createAction ~= nil then -- 887
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 889
		return -- 890
	end -- 890
	repeat -- 890
		local ____switch186 = enode.type -- 890
		local ____cond186 = ____switch186 == "delay" -- 890
		if ____cond186 then -- 890
			do -- 890
				local item = enode.props -- 894
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 895
				break -- 896
			end -- 896
		end -- 896
		____cond186 = ____cond186 or ____switch186 == "event" -- 896
		if ____cond186 then -- 896
			do -- 896
				local item = enode.props -- 899
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 900
				break -- 901
			end -- 901
		end -- 901
		____cond186 = ____cond186 or ____switch186 == "hide" -- 901
		if ____cond186 then -- 901
			do -- 901
				actionStack[#actionStack + 1] = Dora.Hide() -- 904
				break -- 905
			end -- 905
		end -- 905
		____cond186 = ____cond186 or ____switch186 == "show" -- 905
		if ____cond186 then -- 905
			do -- 905
				actionStack[#actionStack + 1] = Dora.Show() -- 908
				break -- 909
			end -- 909
		end -- 909
		____cond186 = ____cond186 or ____switch186 == "move" -- 909
		if ____cond186 then -- 909
			do -- 909
				local item = enode.props -- 912
				actionStack[#actionStack + 1] = Dora.Move( -- 913
					item.time, -- 913
					Dora.Vec2(item.startX, item.startY), -- 913
					Dora.Vec2(item.stopX, item.stopY), -- 913
					item.easing -- 913
				) -- 913
				break -- 914
			end -- 914
		end -- 914
		____cond186 = ____cond186 or ____switch186 == "frame" -- 914
		if ____cond186 then -- 914
			do -- 914
				local item = enode.props -- 917
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 918
				break -- 919
			end -- 919
		end -- 919
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 919
		if ____cond186 then -- 919
			do -- 919
				local spawnStack = {} -- 922
				for i = 1, #enode.children do -- 922
					visitAction(spawnStack, enode.children[i]) -- 924
				end -- 924
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 926
				break -- 927
			end -- 927
		end -- 927
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 927
		if ____cond186 then -- 927
			do -- 927
				local sequenceStack = {} -- 930
				for i = 1, #enode.children do -- 930
					visitAction(sequenceStack, enode.children[i]) -- 932
				end -- 932
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 934
				break -- 935
			end -- 935
		end -- 935
		do -- 935
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 938
			break -- 939
		end -- 939
	until true -- 939
end -- 939
function visitNode(nodeStack, node, parent) -- 1478
	if type(node) ~= "table" then -- 1478
		return -- 1480
	end -- 1480
	local enode = node -- 1482
	if enode.type == nil then -- 1482
		local list = node -- 1484
		if #list > 0 then -- 1484
			for i = 1, #list do -- 1484
				local stack = {} -- 1487
				visitNode(stack, list[i], parent) -- 1488
				for i = 1, #stack do -- 1488
					nodeStack[#nodeStack + 1] = stack[i] -- 1490
				end -- 1490
			end -- 1490
		end -- 1490
	else -- 1490
		local handler = elementMap[enode.type] -- 1495
		if handler ~= nil then -- 1495
			handler(nodeStack, enode, parent) -- 1497
		else -- 1497
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1499
		end -- 1499
	end -- 1499
end -- 1499
function ____exports.toNode(enode) -- 1504
	local nodeStack = {} -- 1505
	visitNode(nodeStack, enode) -- 1506
	if #nodeStack == 1 then -- 1506
		return nodeStack[1] -- 1508
	elseif #nodeStack > 1 then -- 1508
		local node = Dora.Node() -- 1510
		for i = 1, #nodeStack do -- 1510
			node:addChild(nodeStack[i]) -- 1512
		end -- 1512
		return node -- 1514
	end -- 1514
	return nil -- 1516
end -- 1504
function getElementKey(element) -- 1539
	local props = element.props -- 1540
	local ____props_60 -- 1541
	if props then -- 1541
		____props_60 = props.key -- 1541
	else -- 1541
		____props_60 = nil -- 1541
	end -- 1541
	return ____props_60 -- 1541
end -- 1541
function getElementTypeName(element) -- 1544
	local elementType = element.type -- 1545
	if type(elementType) == "string" then -- 1545
		return elementType -- 1546
	end -- 1546
	return tostring(elementType) -- 1547
end -- 1547
function warnUnkeyedDynamicChildren(oldChildren, newElements) -- 1550
	if #oldChildren == #newElements then -- 1550
		return -- 1551
	end -- 1551
	local oldTypes = {} -- 1552
	for i = 1, #oldChildren do -- 1552
		local oldElement = oldChildren[i].element -- 1554
		if getElementKey(oldElement) == nil then -- 1554
			oldTypes[getElementTypeName(oldElement)] = true -- 1556
		end -- 1556
	end -- 1556
	for i = 1, #newElements do -- 1556
		do -- 1556
			local newElement = newElements[i] -- 1560
			if getElementKey(newElement) ~= nil then -- 1560
				goto __continue335 -- 1561
			end -- 1561
			local typeName = getElementTypeName(newElement) -- 1562
			if oldTypes[typeName] == true and not warnedUnkeyedChildTypes[typeName] then -- 1562
				warnedUnkeyedChildTypes[typeName] = true -- 1564
				Warn(("dynamic children include unkeyed <" .. typeName) .. "> siblings while child count changed; add stable key props to conditional, inserted, removed or reordered siblings to avoid index-based reuse") -- 1565
			end -- 1565
		end -- 1565
		::__continue335:: -- 1565
	end -- 1565
end -- 1565
function getPrimitiveLabelText(enode) -- 1577
	local label = enode.props -- 1578
	local text = label.text or "" -- 1579
	for i = 1, #enode.children do -- 1579
		local child = enode.children[i] -- 1581
		if type(child) ~= "table" then -- 1581
			text = text .. tostring(child) -- 1583
		end -- 1583
	end -- 1583
	return text -- 1586
end -- 1586
function isDrawShapeElement(element) -- 1589
	repeat -- 1589
		local ____switch344 = element.type -- 1589
		local ____cond344 = ____switch344 == "dot-shape" or ____switch344 == "segment-shape" or ____switch344 == "rect-shape" or ____switch344 == "polygon-shape" or ____switch344 == "verts-shape" -- 1589
		if ____cond344 then -- 1589
			return true -- 1596
		end -- 1596
	until true -- 1596
	return false -- 1598
end -- 1598
function isBodyFixtureElement(element) -- 1601
	repeat -- 1601
		local ____switch346 = element.type -- 1601
		local ____cond346 = ____switch346 == "rect-fixture" or ____switch346 == "polygon-fixture" or ____switch346 == "multi-fixture" or ____switch346 == "disk-fixture" or ____switch346 == "chain-fixture" -- 1601
		if ____cond346 then -- 1601
			return true -- 1608
		end -- 1608
	until true -- 1608
	return false -- 1610
end -- 1610
function isPhysicsWorldInputElement(element) -- 1613
	return element.type == "contact" -- 1614
end -- 1614
function isRunnableActionElement(element) -- 1617
	if element.type == "loop" then -- 1617
		return true -- 1618
	end -- 1618
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1619
end -- 1619
function shallowPropsEqual(oldProps, newProps) -- 1630
	for k, v in pairs(oldProps) do -- 1631
		if k ~= "ref" and newProps[k] ~= v then -- 1631
			return false -- 1632
		end -- 1632
	end -- 1632
	for k, v in pairs(newProps) do -- 1634
		if k ~= "ref" and oldProps[k] ~= v then -- 1634
			return false -- 1635
		end -- 1635
	end -- 1635
	return true -- 1637
end -- 1637
function collectRunnableActionElements(element) -- 1640
	local actions = {} -- 1641
	for i = 1, #element.children do -- 1641
		local child = element.children[i] -- 1643
		if type(child) == "table" and isRunnableActionElement(child) then -- 1643
			actions[#actions + 1] = child -- 1645
		end -- 1645
	end -- 1645
	return actions -- 1648
end -- 1648
function collectContactElements(element) -- 1651
	local contacts = {} -- 1652
	for i = 1, #element.children do -- 1652
		local child = element.children[i] -- 1654
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1654
			contacts[#contacts + 1] = child -- 1656
		end -- 1656
	end -- 1656
	return contacts -- 1659
end -- 1659
function getContactKey(contact) -- 1662
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1663
end -- 1663
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1666
	local oldContacts = collectContactElements(oldElement) -- 1667
	local newContacts = collectContactElements(newElement) -- 1668
	local oldByKey = {} -- 1669
	local newByKey = {} -- 1670
	for i = 1, #oldContacts do -- 1670
		local contact = oldContacts[i].props -- 1672
		oldByKey[getContactKey(contact)] = contact -- 1673
	end -- 1673
	for i = 1, #newContacts do -- 1673
		local contact = newContacts[i].props -- 1676
		newByKey[getContactKey(contact)] = contact -- 1677
	end -- 1677
	for i = 1, #oldContacts do -- 1677
		local oldContact = oldContacts[i].props -- 1680
		local key = getContactKey(oldContact) -- 1681
		local newContact = newByKey[key] -- 1682
		if newContact == nil then -- 1682
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1684
		elseif oldContact.enabled ~= newContact.enabled then -- 1684
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1686
		end -- 1686
	end -- 1686
	for i = 1, #newContacts do -- 1686
		local newContact = newContacts[i].props -- 1690
		if oldByKey[getContactKey(newContact)] == nil then -- 1690
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1692
		end -- 1692
	end -- 1692
end -- 1692
function actionElementEqual(oldElement, newElement) -- 1697
	if oldElement.type ~= newElement.type then -- 1697
		return false -- 1698
	end -- 1698
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1698
		return false -- 1699
	end -- 1699
	if #oldElement.children ~= #newElement.children then -- 1699
		return false -- 1700
	end -- 1700
	for i = 1, #oldElement.children do -- 1700
		local oldChild = oldElement.children[i] -- 1702
		local newChild = newElement.children[i] -- 1703
		if type(oldChild) ~= type(newChild) then -- 1703
			return false -- 1704
		end -- 1704
		if type(oldChild) == "table" then -- 1704
			if not actionElementEqual(oldChild, newChild) then -- 1704
				return false -- 1706
			end -- 1706
		elseif oldChild ~= newChild then -- 1706
			return false -- 1708
		end -- 1708
	end -- 1708
	return true -- 1711
end -- 1711
function actionChildrenEqual(oldElement, newElement) -- 1714
	local oldActions = collectRunnableActionElements(oldElement) -- 1715
	local newActions = collectRunnableActionElements(newElement) -- 1716
	if #oldActions ~= #newActions then -- 1716
		return false -- 1717
	end -- 1717
	for i = 1, #oldActions do -- 1717
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1717
			return false -- 1719
		end -- 1719
	end -- 1719
	return true -- 1721
end -- 1721
function createActionDef(actionElement) -- 1724
	if actionElement.type == "loop" then -- 1724
		local actionStack = {} -- 1726
		for i = 1, #actionElement.children do -- 1726
			visitAction(actionStack, actionElement.children[i]) -- 1728
		end -- 1728
		if #actionStack == 1 then -- 1728
			return actionStack[1], true -- 1731
		elseif #actionStack > 1 then -- 1731
			local loop = actionElement.props -- 1733
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1734
		end -- 1734
		return nil, true -- 1736
	end -- 1736
	local actionStack = {} -- 1738
	visitAction(actionStack, actionElement) -- 1739
	return #actionStack == 1 and actionStack[1] or nil, false -- 1740
end -- 1740
function structuralChildrenEqual(oldElement, newElement, check) -- 1743
	local oldChildren = {} -- 1749
	local newChildren = {} -- 1750
	for i = 1, #oldElement.children do -- 1750
		local child = oldElement.children[i] -- 1752
		if type(child) == "table" and check(child) then -- 1752
			oldChildren[#oldChildren + 1] = child -- 1754
		end -- 1754
	end -- 1754
	for i = 1, #newElement.children do -- 1754
		local child = newElement.children[i] -- 1758
		if type(child) == "table" and check(child) then -- 1758
			newChildren[#newChildren + 1] = child -- 1760
		end -- 1760
	end -- 1760
	if #oldChildren ~= #newChildren then -- 1760
		return false -- 1763
	end -- 1763
	for i = 1, #oldChildren do -- 1763
		local oldChild = oldChildren[i] -- 1765
		local newChild = newChildren[i] -- 1766
		if oldChild.type ~= newChild.type then -- 1766
			return false -- 1767
		end -- 1767
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1767
			return false -- 1768
		end -- 1768
	end -- 1768
	return true -- 1770
end -- 1770
function runActionChildren(node, element) -- 1773
	local actionChildren = collectRunnableActionElements(element) -- 1774
	local exclusiveActions = {} -- 1775
	local exclusiveLoop -- 1776
	local warnedExclusiveConflict = false -- 1777
	for i = 1, #actionChildren do -- 1777
		do -- 1777
			local actionElement = actionChildren[i] -- 1779
			local action, loop = createActionDef(actionElement) -- 1780
			if action == nil then -- 1780
				goto __continue398 -- 1781
			end -- 1781
			if actionElement.props.exclusive == true then -- 1781
				if exclusiveLoop == nil then -- 1781
					exclusiveLoop = loop -- 1784
				end -- 1784
				if exclusiveLoop == loop then -- 1784
					exclusiveActions[#exclusiveActions + 1] = action -- 1787
				elseif not warnedExclusiveConflict then -- 1787
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1789
					warnedExclusiveConflict = true -- 1790
				end -- 1790
			end -- 1790
		end -- 1790
		::__continue398:: -- 1790
	end -- 1790
	if #exclusiveActions == 1 then -- 1790
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1795
	elseif #exclusiveActions > 1 then -- 1795
		node:perform( -- 1797
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1797
			exclusiveLoop == true -- 1797
		) -- 1797
	end -- 1797
	for i = 1, #actionChildren do -- 1797
		do -- 1797
			local actionElement = actionChildren[i] -- 1800
			if actionElement.props.exclusive == true then -- 1800
				goto __continue406 -- 1801
			end -- 1801
			local action, loop = createActionDef(actionElement) -- 1802
			if action ~= nil then -- 1802
				node:runAction(action, loop) -- 1804
			end -- 1804
		end -- 1804
		::__continue406:: -- 1804
	end -- 1804
end -- 1804
function patchActionChildren(node, oldElement, newElement) -- 1809
	if not actionChildrenEqual(oldElement, newElement) then -- 1809
		runActionChildren(node, newElement) -- 1811
	end -- 1811
end -- 1811
function toHostElement(enode, parent) -- 1824
	local hostChildren = {} -- 1825
	local props = {} -- 1826
	if enode.props ~= nil then -- 1826
		for k, v in pairs(enode.props) do -- 1828
			props[k] = v -- 1829
		end -- 1829
	end -- 1829
	if enode.type == "label" then -- 1829
		for i = 1, #enode.children do -- 1829
			local child = enode.children[i] -- 1834
			if type(child) ~= "table" then -- 1834
				hostChildren[#hostChildren + 1] = child -- 1836
			end -- 1836
		end -- 1836
	elseif enode.type == "draw-node" then -- 1836
		for i = 1, #enode.children do -- 1836
			local child = enode.children[i] -- 1841
			if type(child) == "table" and isDrawShapeElement(child) then -- 1841
				hostChildren[#hostChildren + 1] = child -- 1843
			end -- 1843
		end -- 1843
	elseif enode.type == "body" then -- 1843
		for i = 1, #enode.children do -- 1843
			local child = enode.children[i] -- 1848
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1848
				hostChildren[#hostChildren + 1] = child -- 1850
			end -- 1850
		end -- 1850
	elseif enode.type == "physics-world" then -- 1850
		for i = 1, #enode.children do -- 1850
			local child = enode.children[i] -- 1855
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1855
				hostChildren[#hostChildren + 1] = child -- 1857
			end -- 1857
		end -- 1857
	end -- 1857
	if enode.type == "body" and props.world == nil then -- 1857
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1862
		if world ~= nil then -- 1862
			props.world = world -- 1864
		end -- 1864
	end -- 1864
	return {type = enode.type, props = props, children = hostChildren} -- 1867
end -- 1867
function createHostNode(enode, parent) -- 1874
	local nodeStack = {} -- 1875
	visitNode( -- 1876
		nodeStack, -- 1876
		toHostElement(enode, parent) -- 1876
	) -- 1876
	if #nodeStack == 1 then -- 1876
		return nodeStack[1] -- 1878
	elseif #nodeStack > 1 then -- 1878
		local node = Dora.Node() -- 1880
		for i = 1, #nodeStack do -- 1880
			node:addChild(nodeStack[i]) -- 1882
		end -- 1882
		return node -- 1884
	end -- 1884
	return nil -- 1886
end -- 1886
function getElementChildren(enode) -- 1889
	local children = {} -- 1890
	if enode.type == "draw-node" or enode.type == "body" then -- 1890
		return children -- 1891
	end -- 1891
	for i = 1, #enode.children do -- 1891
		local child = enode.children[i] -- 1893
		if type(child) == "table" then -- 1893
			local childElement = child -- 1895
			if childElement.type ~= nil then -- 1895
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1895
					children[#children + 1] = childElement -- 1901
				end -- 1901
			else -- 1901
				local list = child -- 1904
				for j = 1, #list do -- 1904
					local item = list[j] -- 1906
					if type(item) == "table" and item.type ~= nil then -- 1906
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1906
							children[#children + 1] = item -- 1912
						end -- 1912
					end -- 1912
				end -- 1912
			end -- 1912
		end -- 1912
	end -- 1912
	return children -- 1919
end -- 1919
function getRecreateMode(oldElement, newElement) -- 1924
	if oldElement.type ~= newElement.type then -- 1924
		return "subtree" -- 1925
	end -- 1925
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1925
		return "subtree" -- 1926
	end -- 1926
	local oldProps = oldElement.props -- 1927
	local newProps = newElement.props -- 1928
	if newElement.type == "draw-node" then -- 1928
		return "host" -- 1929
	end -- 1929
	for k, v in pairs(oldProps) do -- 1930
		if k == "onMount" and newProps[k] ~= v then -- 1930
			return "host" -- 1932
		end -- 1932
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1932
			return "host" -- 1935
		end -- 1935
	end -- 1935
	for k, v in pairs(newProps) do -- 1938
		if k == "onMount" and oldProps[k] ~= v then -- 1938
			return "host" -- 1940
		end -- 1940
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1940
			return "host" -- 1943
		end -- 1943
	end -- 1943
	repeat -- 1943
		local ____switch455 = newElement.type -- 1943
		local ____cond455 = ____switch455 == "grid" -- 1943
		if ____cond455 then -- 1943
			return (oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY) and "host" or nil -- 1948
		end -- 1948
		____cond455 = ____cond455 or (____switch455 == "sprite" or ____switch455 == "video-node" or ____switch455 == "tic80-node" or ____switch455 == "audio-source" or ____switch455 == "particle" or ____switch455 == "tile-node" or ____switch455 == "playable" or ____switch455 == "dragon-bone" or ____switch455 == "spine" or ____switch455 == "model") -- 1948
		if ____cond455 then -- 1948
			return oldProps.file ~= newProps.file and "host" or nil -- 1959
		end -- 1959
		____cond455 = ____cond455 or ____switch455 == "label" -- 1959
		if ____cond455 then -- 1959
			return (oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf) and "host" or nil -- 1961
		end -- 1961
		____cond455 = ____cond455 or ____switch455 == "align-node" -- 1961
		if ____cond455 then -- 1961
			return oldProps.windowRoot ~= newProps.windowRoot and "host" or nil -- 1963
		end -- 1963
		____cond455 = ____cond455 or ____switch455 == "custom-node" -- 1963
		if ____cond455 then -- 1963
			return oldProps.onCreate ~= newProps.onCreate and "host" or nil -- 1965
		end -- 1965
		____cond455 = ____cond455 or ____switch455 == "body" -- 1965
		if ____cond455 then -- 1965
			return (oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement)) and "host" or nil -- 1967
		end -- 1967
	until true -- 1967
	return nil -- 1974
end -- 1974
function isEventProp(key) -- 1977
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1978
end -- 1978
function getEventSlot(key) -- 1981
	repeat -- 1981
		local ____switch458 = key -- 1981
		local ____cond458 = ____switch458 == "onActionEnd" -- 1981
		if ____cond458 then -- 1981
			return "ActionEnd" -- 1983
		end -- 1983
		____cond458 = ____cond458 or ____switch458 == "onTapFilter" -- 1983
		if ____cond458 then -- 1983
			return "TapFilter" -- 1984
		end -- 1984
		____cond458 = ____cond458 or ____switch458 == "onTapBegan" -- 1984
		if ____cond458 then -- 1984
			return "TapBegan" -- 1985
		end -- 1985
		____cond458 = ____cond458 or ____switch458 == "onTapEnded" -- 1985
		if ____cond458 then -- 1985
			return "TapEnded" -- 1986
		end -- 1986
		____cond458 = ____cond458 or ____switch458 == "onTapped" -- 1986
		if ____cond458 then -- 1986
			return "Tapped" -- 1987
		end -- 1987
		____cond458 = ____cond458 or ____switch458 == "onTapMoved" -- 1987
		if ____cond458 then -- 1987
			return "TapMoved" -- 1988
		end -- 1988
		____cond458 = ____cond458 or ____switch458 == "onMouseWheel" -- 1988
		if ____cond458 then -- 1988
			return "MouseWheel" -- 1989
		end -- 1989
		____cond458 = ____cond458 or ____switch458 == "onGesture" -- 1989
		if ____cond458 then -- 1989
			return "Gesture" -- 1990
		end -- 1990
		____cond458 = ____cond458 or ____switch458 == "onEnter" -- 1990
		if ____cond458 then -- 1990
			return "Enter" -- 1991
		end -- 1991
		____cond458 = ____cond458 or ____switch458 == "onExit" -- 1991
		if ____cond458 then -- 1991
			return "Exit" -- 1992
		end -- 1992
		____cond458 = ____cond458 or ____switch458 == "onCleanup" -- 1992
		if ____cond458 then -- 1992
			return "Cleanup" -- 1993
		end -- 1993
		____cond458 = ____cond458 or ____switch458 == "onKeyDown" -- 1993
		if ____cond458 then -- 1993
			return "KeyDown" -- 1994
		end -- 1994
		____cond458 = ____cond458 or ____switch458 == "onKeyUp" -- 1994
		if ____cond458 then -- 1994
			return "KeyUp" -- 1995
		end -- 1995
		____cond458 = ____cond458 or ____switch458 == "onKeyPressed" -- 1995
		if ____cond458 then -- 1995
			return "KeyPressed" -- 1996
		end -- 1996
		____cond458 = ____cond458 or ____switch458 == "onAttachIME" -- 1996
		if ____cond458 then -- 1996
			return "AttachIME" -- 1997
		end -- 1997
		____cond458 = ____cond458 or ____switch458 == "onDetachIME" -- 1997
		if ____cond458 then -- 1997
			return "DetachIME" -- 1998
		end -- 1998
		____cond458 = ____cond458 or ____switch458 == "onTextInput" -- 1998
		if ____cond458 then -- 1998
			return "TextInput" -- 1999
		end -- 1999
		____cond458 = ____cond458 or ____switch458 == "onTextEditing" -- 1999
		if ____cond458 then -- 1999
			return "TextEditing" -- 2000
		end -- 2000
		____cond458 = ____cond458 or ____switch458 == "onButtonDown" -- 2000
		if ____cond458 then -- 2000
			return "ButtonDown" -- 2001
		end -- 2001
		____cond458 = ____cond458 or ____switch458 == "onButtonUp" -- 2001
		if ____cond458 then -- 2001
			return "ButtonUp" -- 2002
		end -- 2002
		____cond458 = ____cond458 or ____switch458 == "onAxis" -- 2002
		if ____cond458 then -- 2002
			return "Axis" -- 2003
		end -- 2003
		____cond458 = ____cond458 or ____switch458 == "onAnimationEnd" -- 2003
		if ____cond458 then -- 2003
			return "AnimationEnd" -- 2004
		end -- 2004
		____cond458 = ____cond458 or ____switch458 == "onFinished" -- 2004
		if ____cond458 then -- 2004
			return "Finished" -- 2005
		end -- 2005
		____cond458 = ____cond458 or ____switch458 == "onLayout" -- 2005
		if ____cond458 then -- 2005
			return "AlignLayout" -- 2006
		end -- 2006
		____cond458 = ____cond458 or ____switch458 == "onBodyEnter" -- 2006
		if ____cond458 then -- 2006
			return "BodyEnter" -- 2007
		end -- 2007
		____cond458 = ____cond458 or ____switch458 == "onBodyLeave" -- 2007
		if ____cond458 then -- 2007
			return "BodyLeave" -- 2008
		end -- 2008
		____cond458 = ____cond458 or ____switch458 == "onContactStart" -- 2008
		if ____cond458 then -- 2008
			return "ContactStart" -- 2009
		end -- 2009
		____cond458 = ____cond458 or ____switch458 == "onContactEnd" -- 2009
		if ____cond458 then -- 2009
			return "ContactEnd" -- 2010
		end -- 2010
	until true -- 2010
	return nil -- 2012
end -- 2012
function isPatchableEventProp(key) -- 2015
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 2016
end -- 2016
function patchEventProp(node, key, value) -- 2019
	local slotName = getEventSlot(key) -- 2020
	if slotName == nil then -- 2020
		return -- 2021
	end -- 2021
	node:slot(slotName):clear() -- 2022
	if value ~= nil then -- 2022
		if key == "onLayout" then -- 2022
			node:onAlignLayout(value) -- 2025
		else -- 2025
			node:slot(slotName, value) -- 2027
		end -- 2027
	end -- 2027
end -- 2027
function patchContactFilterProp(node, value) -- 2032
	local body = Dora.tolua.cast(node, "Body") -- 2033
	if body == nil then -- 2033
		return -- 2034
	end -- 2034
	if value == nil then -- 2034
		body:onContactFilter(function() return true end) -- 2036
	else -- 2036
		body:onContactFilter(value) -- 2038
	end -- 2038
end -- 2038
function patchUpdateProp(node, value) -- 2042
	if value == nil then -- 2042
		node:unschedule() -- 2044
	elseif type(value) == "thread" then -- 2044
		node:schedule(value) -- 2046
	else -- 2046
		node:schedule(value) -- 2048
	end -- 2048
end -- 2048
function patchRenderProp(node, value) -- 2052
	local clearRender = node.clearRender -- 2053
	if type(clearRender) == "function" then -- 2053
		clearRender(node) -- 2055
	end -- 2055
	if value == nil then -- 2055
		return -- 2058
	end -- 2058
	node:onRender(value) -- 2060
end -- 2060
function clearRemovedProp(node, key) -- 2063
	repeat -- 2063
		local ____switch478 = key -- 2063
		local ____cond478 = ____switch478 == "transformTarget" or ____switch478 == "stencil" -- 2063
		if ____cond478 then -- 2063
			node[key] = nil -- 2067
			return true -- 2068
		end -- 2068
	until true -- 2068
	return false -- 2070
end -- 2070
function getAlignStyleText(style) -- 2073
	local items = {} -- 2074
	for k, v in pairs(style) do -- 2075
		local name = string.gsub(k, "%u", "-%1") -- 2076
		name = string.lower(name) -- 2077
		repeat -- 2077
			local ____switch481 = k -- 2077
			local ____cond481 = ____switch481 == "margin" or ____switch481 == "padding" or ____switch481 == "border" or ____switch481 == "gap" -- 2077
			if ____cond481 then -- 2077
				do -- 2077
					if type(v) == "table" then -- 2077
						local valueStr = table.concat( -- 2082
							__TS__ArrayMap( -- 2082
								v, -- 2082
								function(____, item) return tostring(item) end -- 2082
							), -- 2082
							"," -- 2082
						) -- 2082
						items[#items + 1] = (name .. ":") .. valueStr -- 2083
					else -- 2083
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2085
					end -- 2085
					break -- 2087
				end -- 2087
			end -- 2087
			do -- 2087
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2090
				break -- 2091
			end -- 2091
		until true -- 2091
	end -- 2091
	return table.concat(items, ";") -- 2094
end -- 2094
function patchPlayableProps(node, oldProps, newProps) -- 2097
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2097
		node:play(newProps.play, newProps.loop == true) -- 2099
	end -- 2099
end -- 2099
function patchAudioSourceProps(node, oldProps, newProps) -- 2103
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2103
		local audio = node -- 2105
		repeat -- 2105
			local ____switch490 = newProps.playMode -- 2105
			local ____cond490 = ____switch490 == "normal" -- 2105
			if ____cond490 then -- 2105
				local ____audio_play_62 = audio.play -- 2107
				local ____newProps_delayTime_61 = newProps.delayTime -- 2107
				if ____newProps_delayTime_61 == nil then -- 2107
					____newProps_delayTime_61 = 0 -- 2107
				end -- 2107
				____audio_play_62(audio, ____newProps_delayTime_61) -- 2107
				break -- 2107
			end -- 2107
			____cond490 = ____cond490 or ____switch490 == "background" -- 2107
			if ____cond490 then -- 2107
				audio:playBackground() -- 2108
				break -- 2108
			end -- 2108
			____cond490 = ____cond490 or ____switch490 == "3D" -- 2108
			if ____cond490 then -- 2108
				local ____audio_play3D_64 = audio.play3D -- 2109
				local ____newProps_delayTime_63 = newProps.delayTime -- 2109
				if ____newProps_delayTime_63 == nil then -- 2109
					____newProps_delayTime_63 = 0 -- 2109
				end -- 2109
				____audio_play3D_64(audio, ____newProps_delayTime_63) -- 2109
				break -- 2109
			end -- 2109
		until true -- 2109
	end -- 2109
end -- 2109
function patchParticleProps(node, oldProps, newProps) -- 2114
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2114
		local particle = node -- 2116
		if newProps.emit then -- 2116
			particle:start() -- 2118
		else -- 2118
			particle:stop() -- 2120
		end -- 2120
	end -- 2120
end -- 2120
function patchAlignNodeProps(node, oldProps, newProps) -- 2125
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2125
		node:css(getAlignStyleText(newProps.style)) -- 2127
	end -- 2127
end -- 2127
function patchLineProps(node, oldProps, newProps) -- 2131
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2131
		local ____self_68 = node -- 2131
		local ____self_68_set_69 = ____self_68.set -- 2131
		local ____newProps_verts_67 = newProps.verts -- 2133
		local ____Dora_Color_66 = Dora.Color -- 2133
		local ____newProps_lineColor_65 = newProps.lineColor -- 2133
		if ____newProps_lineColor_65 == nil then -- 2133
			____newProps_lineColor_65 = 4294967295 -- 2133
		end -- 2133
		____self_68_set_69( -- 2133
			____self_68, -- 2133
			____newProps_verts_67, -- 2133
			____Dora_Color_66(____newProps_lineColor_65) -- 2133
		) -- 2133
	end -- 2133
end -- 2133
function clearRef(props, node) -- 2137
	local ref = props.ref -- 2138
	if ref ~= nil and (node == nil or ref.current == node) then -- 2138
		ref.current = nil -- 2140
	end -- 2140
end -- 2140
function patchRef(node, oldProps, newProps) -- 2144
	if oldProps.ref ~= newProps.ref then -- 2144
		clearRef(oldProps, node) -- 2146
		local ref = newProps.ref -- 2147
		if ref ~= nil then -- 2147
			ref.current = node -- 2149
		end -- 2149
	end -- 2149
end -- 2149
function applyProp(node, enode, key, value) -- 2154
	local name = key -- 2155
	repeat -- 2155
		local ____switch505 = name -- 2155
		local ____cond505 = ____switch505 == "key" or ____switch505 == "children" or ____switch505 == "onMount" or ____switch505 == "onUnmount" -- 2155
		if ____cond505 then -- 2155
			return -- 2161
		end -- 2161
		____cond505 = ____cond505 or ____switch505 == "ref" -- 2161
		if ____cond505 then -- 2161
			value.current = node -- 2163
			return -- 2164
		end -- 2164
		____cond505 = ____cond505 or ____switch505 == "anchorX" -- 2164
		if ____cond505 then -- 2164
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2166
			return -- 2167
		end -- 2167
		____cond505 = ____cond505 or ____switch505 == "anchorY" -- 2167
		if ____cond505 then -- 2167
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2169
			return -- 2170
		end -- 2170
		____cond505 = ____cond505 or ____switch505 == "color3" -- 2170
		if ____cond505 then -- 2170
			node.color3 = Dora.Color3(value) -- 2172
			return -- 2173
		end -- 2173
		____cond505 = ____cond505 or ____switch505 == "transformTarget" -- 2173
		if ____cond505 then -- 2173
			node.transformTarget = value.current -- 2175
			return -- 2176
		end -- 2176
		____cond505 = ____cond505 or ____switch505 == "outlineColor" -- 2176
		if ____cond505 then -- 2176
			node[name] = Dora.Color(value) -- 2178
			return -- 2179
		end -- 2179
		____cond505 = ____cond505 or ____switch505 == "smoothLower" -- 2179
		if ____cond505 then -- 2179
			do -- 2179
				local smooth = node.smooth -- 2181
				node.smooth = Dora.Vec2(value, smooth.y) -- 2182
				return -- 2183
			end -- 2183
		end -- 2183
		____cond505 = ____cond505 or ____switch505 == "smoothUpper" -- 2183
		if ____cond505 then -- 2183
			do -- 2183
				local smooth = node.smooth -- 2186
				node.smooth = Dora.Vec2(smooth.x, value) -- 2187
				return -- 2188
			end -- 2188
		end -- 2188
	until true -- 2188
	if isEventProp(key) then -- 2188
		if key == "onUpdate" then -- 2188
			patchUpdateProp(node, value) -- 2193
		elseif key == "onRender" then -- 2193
			patchRenderProp(node, value) -- 2195
		elseif key == "onContactFilter" then -- 2195
			patchContactFilterProp(node, value) -- 2197
		elseif isPatchableEventProp(key) then -- 2197
			patchEventProp(node, key, value) -- 2199
		end -- 2199
		return -- 2201
	end -- 2201
	node[name] = value -- 2203
end -- 2203
function patchProps(node, oldElement, newElement) -- 2206
	local oldProps = oldElement.props -- 2207
	local newProps = newElement.props -- 2208
	for k in pairs(oldProps) do -- 2209
		if k == "onUpdate" and newProps[k] == nil then -- 2209
			patchUpdateProp(node, nil) -- 2211
		elseif k == "onRender" and newProps[k] == nil then -- 2211
			patchRenderProp(node, nil) -- 2213
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2213
			patchContactFilterProp(node, nil) -- 2215
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2215
			patchEventProp(node, k, nil) -- 2217
		elseif newProps[k] == nil then -- 2217
			clearRemovedProp(node, k) -- 2219
		end -- 2219
	end -- 2219
	patchRef(node, oldProps, newProps) -- 2222
	for k, v in pairs(newProps) do -- 2223
		if k ~= "ref" and oldProps[k] ~= v then -- 2223
			applyProp(node, newElement, k, v) -- 2225
		end -- 2225
	end -- 2225
	if newElement.type == "label" then -- 2225
		node.text = getPrimitiveLabelText(newElement) -- 2229
	elseif newElement.type == "physics-world" then -- 2229
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2231
		if world ~= nil then -- 2231
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2233
		end -- 2233
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2233
		patchPlayableProps(node, oldProps, newProps) -- 2241
	elseif newElement.type == "audio-source" then -- 2241
		patchAudioSourceProps(node, oldProps, newProps) -- 2243
	elseif newElement.type == "particle" then -- 2243
		patchParticleProps(node, oldProps, newProps) -- 2245
	elseif newElement.type == "align-node" then -- 2245
		patchAlignNodeProps(node, oldProps, newProps) -- 2247
	elseif newElement.type == "line" then -- 2247
		patchLineProps(node, oldProps, newProps) -- 2249
	end -- 2249
	applyAutoEnableProps(node, newProps) -- 2251
end -- 2251
function addChildToParent(parent, node, props) -- 2254
	if props.tag ~= nil then -- 2254
		parent:addChild(node, props.order or 0, props.tag) -- 2256
	elseif props.order ~= nil then -- 2256
		parent:addChild(node, props.order) -- 2258
	else -- 2258
		parent:addChild(node) -- 2260
	end -- 2260
end -- 2260
function mountElement(parent, enode) -- 2264
	local node = createHostNode(enode, parent) -- 2265
	if node == nil then -- 2265
		return nil -- 2267
	end -- 2267
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2267
		return nil -- 2276
	end -- 2276
	local props = enode.props -- 2278
	addChildToParent(parent, node, props) -- 2279
	local mounted = {element = enode, node = node, children = {}} -- 2280
	runActionChildren(node, enode) -- 2281
	mounted.children = reconcileChildren( -- 2282
		node, -- 2282
		{}, -- 2282
		getElementChildren(enode) -- 2282
	) -- 2282
	return mounted -- 2283
end -- 2283
function unmountHostElement(mounted) -- 2286
	local props = mounted.element.props -- 2287
	if props.onUnmount ~= nil then -- 2287
		props.onUnmount(mounted.node) -- 2289
	end -- 2289
	clearRef(mounted.element.props, mounted.node) -- 2291
	mounted.node:removeFromParent(true) -- 2292
end -- 2292
function unmountElement(mounted) -- 2295
	for i = 1, #mounted.children do -- 2295
		unmountElement(mounted.children[i]) -- 2297
	end -- 2297
	unmountHostElement(mounted) -- 2299
end -- 2299
function reconcileElement(parent, oldMounted, newElement) -- 2302
	if oldMounted == nil then -- 2302
		return mountElement(parent, newElement) -- 2304
	end -- 2304
	local recreateMode = getRecreateMode(oldMounted.element, newElement) -- 2306
	if recreateMode == "subtree" then -- 2306
		local oldNode = oldMounted.node -- 2308
		local oldOrder = oldNode.order -- 2309
		local oldTag = oldNode.tag -- 2310
		unmountElement(oldMounted) -- 2311
		local mounted = mountElement(parent, newElement) -- 2312
		if mounted ~= nil then -- 2312
			mounted.node.order = newElement.props.order or oldOrder -- 2314
			mounted.node.tag = newElement.props.tag or oldTag -- 2315
		end -- 2315
		return mounted -- 2317
	end -- 2317
	if recreateMode == "host" then -- 2317
		local oldNode = oldMounted.node -- 2320
		local oldOrder = oldNode.order -- 2321
		local oldTag = oldNode.tag -- 2322
		local node = createHostNode(newElement, parent) -- 2323
		if node == nil then -- 2323
			unmountElement(oldMounted) -- 2325
			return nil -- 2326
		end -- 2326
		addChildToParent(parent, node, newElement.props) -- 2328
		node.order = newElement.props.order or oldOrder -- 2329
		node.tag = newElement.props.tag or oldTag -- 2330
		runActionChildren(node, newElement) -- 2331
		for i = 1, #oldMounted.children do -- 2331
			oldMounted.children[i].node:moveToParent(node) -- 2333
		end -- 2333
		unmountHostElement(oldMounted) -- 2335
		oldMounted.node = node -- 2336
		oldMounted.children = reconcileChildren( -- 2337
			node, -- 2337
			oldMounted.children, -- 2337
			getElementChildren(newElement) -- 2337
		) -- 2337
		oldMounted.element = newElement -- 2338
		return oldMounted -- 2339
	end -- 2339
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2341
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2342
	oldMounted.children = reconcileChildren( -- 2343
		oldMounted.node, -- 2343
		oldMounted.children, -- 2343
		getElementChildren(newElement) -- 2343
	) -- 2343
	oldMounted.element = newElement -- 2344
	return oldMounted -- 2345
end -- 2345
function reconcileChildren(parent, oldChildren, newElements) -- 2348
	warnUnkeyedDynamicChildren(oldChildren, newElements) -- 2349
	local oldByKey = {} -- 2350
	local usedOld = {} -- 2351
	for i = 1, #oldChildren do -- 2351
		local oldChild = oldChildren[i] -- 2353
		local key = getElementKey(oldChild.element) -- 2354
		if key ~= nil then -- 2354
			oldByKey[key] = oldChild -- 2356
		end -- 2356
	end -- 2356
	local nextChildren = {} -- 2359
	for i = 1, #newElements do -- 2359
		local newElement = newElements[i] -- 2361
		local key = getElementKey(newElement) -- 2362
		local oldChild -- 2363
		if key ~= nil then -- 2363
			oldChild = oldByKey[key] -- 2365
		else -- 2365
			oldChild = oldChildren[i] -- 2367
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2367
				oldChild = nil -- 2369
			end -- 2369
		end -- 2369
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2372
		if mounted ~= nil then -- 2372
			usedOld[mounted] = true -- 2374
			nextChildren[#nextChildren + 1] = mounted -- 2375
			local props = newElement.props -- 2376
			mounted.node.order = props.order or i -- 2377
			if props.tag ~= nil then -- 2377
				mounted.node.tag = props.tag -- 2378
			end -- 2378
		end -- 2378
	end -- 2378
	for i = 1, #oldChildren do -- 2378
		local oldChild = oldChildren[i] -- 2382
		if not usedOld[oldChild] then -- 2382
			unmountElement(oldChild) -- 2384
		end -- 2384
	end -- 2384
	return nextChildren -- 2387
end -- 2387
____exports.React = {} -- 2387
local React = ____exports.React -- 2387
do -- 2387
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
local function getNode(enode, cnode, attribHandler) -- 196
	cnode = cnode or Dora.Node() -- 197
	local jnode = enode.props -- 198
	local anchor -- 199
	local color3 -- 200
	for k, v in pairs(enode.props) do -- 201
		repeat -- 201
			local ____switch42 = k -- 201
			local ____cond42 = ____switch42 == "ref" -- 201
			if ____cond42 then -- 201
				v.current = cnode -- 203
				break -- 203
			end -- 203
			____cond42 = ____cond42 or ____switch42 == "anchorX" -- 203
			if ____cond42 then -- 203
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 204
				break -- 204
			end -- 204
			____cond42 = ____cond42 or ____switch42 == "anchorY" -- 204
			if ____cond42 then -- 204
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 205
				break -- 205
			end -- 205
			____cond42 = ____cond42 or ____switch42 == "color3" -- 205
			if ____cond42 then -- 205
				color3 = Dora.Color3(v) -- 206
				break -- 206
			end -- 206
			____cond42 = ____cond42 or ____switch42 == "transformTarget" -- 206
			if ____cond42 then -- 206
				cnode.transformTarget = v.current -- 207
				break -- 207
			end -- 207
			____cond42 = ____cond42 or ____switch42 == "onUpdate" -- 207
			if ____cond42 then -- 207
				cnode:schedule(v) -- 208
				break -- 208
			end -- 208
			____cond42 = ____cond42 or ____switch42 == "onRender" -- 208
			if ____cond42 then -- 208
				patchRenderProp(cnode, v) -- 209
				break -- 209
			end -- 209
			____cond42 = ____cond42 or ____switch42 == "onActionEnd" -- 209
			if ____cond42 then -- 209
				cnode:slot("ActionEnd", v) -- 210
				break -- 210
			end -- 210
			____cond42 = ____cond42 or ____switch42 == "onTapFilter" -- 210
			if ____cond42 then -- 210
				cnode:slot("TapFilter", v) -- 211
				break -- 211
			end -- 211
			____cond42 = ____cond42 or ____switch42 == "onTapBegan" -- 211
			if ____cond42 then -- 211
				cnode:slot("TapBegan", v) -- 212
				break -- 212
			end -- 212
			____cond42 = ____cond42 or ____switch42 == "onTapEnded" -- 212
			if ____cond42 then -- 212
				cnode:slot("TapEnded", v) -- 213
				break -- 213
			end -- 213
			____cond42 = ____cond42 or ____switch42 == "onTapped" -- 213
			if ____cond42 then -- 213
				cnode:slot("Tapped", v) -- 214
				break -- 214
			end -- 214
			____cond42 = ____cond42 or ____switch42 == "onTapMoved" -- 214
			if ____cond42 then -- 214
				cnode:slot("TapMoved", v) -- 215
				break -- 215
			end -- 215
			____cond42 = ____cond42 or ____switch42 == "onMouseWheel" -- 215
			if ____cond42 then -- 215
				cnode:slot("MouseWheel", v) -- 216
				break -- 216
			end -- 216
			____cond42 = ____cond42 or ____switch42 == "onGesture" -- 216
			if ____cond42 then -- 216
				cnode:slot("Gesture", v) -- 217
				break -- 217
			end -- 217
			____cond42 = ____cond42 or ____switch42 == "onEnter" -- 217
			if ____cond42 then -- 217
				cnode:slot("Enter", v) -- 218
				break -- 218
			end -- 218
			____cond42 = ____cond42 or ____switch42 == "onExit" -- 218
			if ____cond42 then -- 218
				cnode:slot("Exit", v) -- 219
				break -- 219
			end -- 219
			____cond42 = ____cond42 or ____switch42 == "onCleanup" -- 219
			if ____cond42 then -- 219
				cnode:slot("Cleanup", v) -- 220
				break -- 220
			end -- 220
			____cond42 = ____cond42 or ____switch42 == "onUnmount" -- 220
			if ____cond42 then -- 220
				break -- 221
			end -- 221
			____cond42 = ____cond42 or ____switch42 == "onKeyDown" -- 221
			if ____cond42 then -- 221
				cnode:slot("KeyDown", v) -- 222
				break -- 222
			end -- 222
			____cond42 = ____cond42 or ____switch42 == "onKeyUp" -- 222
			if ____cond42 then -- 222
				cnode:slot("KeyUp", v) -- 223
				break -- 223
			end -- 223
			____cond42 = ____cond42 or ____switch42 == "onKeyPressed" -- 223
			if ____cond42 then -- 223
				cnode:slot("KeyPressed", v) -- 224
				break -- 224
			end -- 224
			____cond42 = ____cond42 or ____switch42 == "onAttachIME" -- 224
			if ____cond42 then -- 224
				cnode:slot("AttachIME", v) -- 225
				break -- 225
			end -- 225
			____cond42 = ____cond42 or ____switch42 == "onDetachIME" -- 225
			if ____cond42 then -- 225
				cnode:slot("DetachIME", v) -- 226
				break -- 226
			end -- 226
			____cond42 = ____cond42 or ____switch42 == "onTextInput" -- 226
			if ____cond42 then -- 226
				cnode:slot("TextInput", v) -- 227
				break -- 227
			end -- 227
			____cond42 = ____cond42 or ____switch42 == "onTextEditing" -- 227
			if ____cond42 then -- 227
				cnode:slot("TextEditing", v) -- 228
				break -- 228
			end -- 228
			____cond42 = ____cond42 or ____switch42 == "onButtonDown" -- 228
			if ____cond42 then -- 228
				cnode:slot("ButtonDown", v) -- 229
				break -- 229
			end -- 229
			____cond42 = ____cond42 or ____switch42 == "onButtonUp" -- 229
			if ____cond42 then -- 229
				cnode:slot("ButtonUp", v) -- 230
				break -- 230
			end -- 230
			____cond42 = ____cond42 or ____switch42 == "onAxis" -- 230
			if ____cond42 then -- 230
				cnode:slot("Axis", v) -- 231
				break -- 231
			end -- 231
			do -- 231
				do -- 231
					if attribHandler then -- 231
						if not attribHandler(cnode, enode, k, v) then -- 231
							cnode[k] = v -- 235
						end -- 235
					else -- 235
						cnode[k] = v -- 238
					end -- 238
					break -- 240
				end -- 240
			end -- 240
		until true -- 240
	end -- 240
	applyAutoEnableProps(cnode, enode.props) -- 244
	if anchor ~= nil then -- 244
		cnode.anchor = anchor -- 245
	end -- 245
	if color3 ~= nil then -- 245
		cnode.color3 = color3 -- 246
	end -- 246
	if jnode.onMount ~= nil then -- 246
		jnode.onMount(cnode) -- 248
	end -- 248
	return cnode -- 250
end -- 196
local getClipNode -- 253
do -- 253
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 255
		repeat -- 255
			local ____switch52 = k -- 255
			local ____cond52 = ____switch52 == "stencil" -- 255
			if ____cond52 then -- 255
				cnode.stencil = ____exports.toNode(v) -- 262
				return true -- 262
			end -- 262
		until true -- 262
		return false -- 264
	end -- 255
	getClipNode = function(enode) -- 266
		return getNode( -- 267
			enode, -- 267
			Dora.ClipNode(), -- 267
			handleClipNodeAttribute -- 267
		) -- 267
	end -- 266
end -- 266
local getPlayable -- 271
local getDragonBone -- 272
local getSpine -- 273
local getModel -- 274
do -- 274
	local function handlePlayableAttribute(cnode, enode, k, v) -- 276
		repeat -- 276
			local ____switch56 = k -- 276
			local ____cond56 = ____switch56 == "file" -- 276
			if ____cond56 then -- 276
				return true -- 278
			end -- 278
			____cond56 = ____cond56 or ____switch56 == "play" -- 278
			if ____cond56 then -- 278
				cnode:play(v, enode.props.loop == true) -- 279
				return true -- 279
			end -- 279
			____cond56 = ____cond56 or ____switch56 == "loop" -- 279
			if ____cond56 then -- 279
				return true -- 280
			end -- 280
			____cond56 = ____cond56 or ____switch56 == "onAnimationEnd" -- 280
			if ____cond56 then -- 280
				cnode:slot("AnimationEnd", v) -- 281
				return true -- 281
			end -- 281
		until true -- 281
		return false -- 283
	end -- 276
	getPlayable = function(enode, cnode, attribHandler) -- 285
		if attribHandler == nil then -- 285
			attribHandler = handlePlayableAttribute -- 286
		end -- 286
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 287
		if cnode ~= nil then -- 287
			return getNode(enode, cnode, attribHandler) -- 289
		end -- 289
		return nil -- 291
	end -- 285
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 294
		repeat -- 294
			local ____switch60 = k -- 294
			local ____cond60 = ____switch60 == "hitTestEnabled" -- 294
			if ____cond60 then -- 294
				cnode.hitTestEnabled = true -- 296
				return true -- 296
			end -- 296
		until true -- 296
		return handlePlayableAttribute(cnode, enode, k, v) -- 298
	end -- 294
	getDragonBone = function(enode) -- 300
		local node = Dora.DragonBone(enode.props.file) -- 301
		if node ~= nil then -- 301
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 303
			return cnode -- 304
		end -- 304
		return nil -- 306
	end -- 300
	local function handleSpineAttribute(cnode, enode, k, v) -- 309
		repeat -- 309
			local ____switch64 = k -- 309
			local ____cond64 = ____switch64 == "hitTestEnabled" -- 309
			if ____cond64 then -- 309
				cnode.hitTestEnabled = true -- 311
				return true -- 311
			end -- 311
		until true -- 311
		return handlePlayableAttribute(cnode, enode, k, v) -- 313
	end -- 309
	getSpine = function(enode) -- 315
		local node = Dora.Spine(enode.props.file) -- 316
		if node ~= nil then -- 316
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 318
			return cnode -- 319
		end -- 319
		return nil -- 321
	end -- 315
	local function handleModelAttribute(cnode, enode, k, v) -- 324
		repeat -- 324
			local ____switch68 = k -- 324
			local ____cond68 = ____switch68 == "reversed" -- 324
			if ____cond68 then -- 324
				cnode.reversed = v -- 326
				return true -- 326
			end -- 326
		until true -- 326
		return handlePlayableAttribute(cnode, enode, k, v) -- 328
	end -- 324
	getModel = function(enode) -- 330
		local node = Dora.Model(enode.props.file) -- 331
		if node ~= nil then -- 331
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 333
			return cnode -- 334
		end -- 334
		return nil -- 336
	end -- 330
end -- 330
local getDrawNode -- 340
do -- 340
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 342
		repeat -- 342
			local ____switch73 = k -- 342
			local ____cond73 = ____switch73 == "depthWrite" -- 342
			if ____cond73 then -- 342
				cnode.depthWrite = v -- 344
				return true -- 344
			end -- 344
			____cond73 = ____cond73 or ____switch73 == "blendFunc" -- 344
			if ____cond73 then -- 344
				cnode.blendFunc = v -- 345
				return true -- 345
			end -- 345
		until true -- 345
		return false -- 347
	end -- 342
	getDrawNode = function(enode) -- 349
		local node = Dora.DrawNode() -- 350
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 351
		local ____enode_7 = enode -- 352
		local children = ____enode_7.children -- 352
		for i = 1, #children do -- 352
			do -- 352
				local child = children[i] -- 354
				if type(child) ~= "table" then -- 354
					goto __continue75 -- 356
				end -- 356
				repeat -- 356
					local ____switch77 = child.type -- 356
					local ____cond77 = ____switch77 == "dot-shape" -- 356
					if ____cond77 then -- 356
						do -- 356
							local dot = child.props -- 360
							node:drawDot( -- 361
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 362
								dot.radius, -- 363
								Dora.Color(dot.color or 4294967295) -- 364
							) -- 364
							break -- 366
						end -- 366
					end -- 366
					____cond77 = ____cond77 or ____switch77 == "segment-shape" -- 366
					if ____cond77 then -- 366
						do -- 366
							local segment = child.props -- 369
							node:drawSegment( -- 370
								Dora.Vec2(segment.startX, segment.startY), -- 371
								Dora.Vec2(segment.stopX, segment.stopY), -- 372
								segment.radius, -- 373
								Dora.Color(segment.color or 4294967295) -- 374
							) -- 374
							break -- 376
						end -- 376
					end -- 376
					____cond77 = ____cond77 or ____switch77 == "rect-shape" -- 376
					if ____cond77 then -- 376
						do -- 376
							local rect = child.props -- 379
							local centerX = rect.centerX or 0 -- 380
							local centerY = rect.centerY or 0 -- 381
							local hw = rect.width / 2 -- 382
							local hh = rect.height / 2 -- 383
							node:drawPolygon( -- 384
								{ -- 385
									Dora.Vec2(centerX - hw, centerY + hh), -- 386
									Dora.Vec2(centerX + hw, centerY + hh), -- 387
									Dora.Vec2(centerX + hw, centerY - hh), -- 388
									Dora.Vec2(centerX - hw, centerY - hh) -- 389
								}, -- 389
								Dora.Color(rect.fillColor or 4294967295), -- 391
								rect.borderWidth or 0, -- 392
								Dora.Color(rect.borderColor or 4294967295) -- 393
							) -- 393
							break -- 395
						end -- 395
					end -- 395
					____cond77 = ____cond77 or ____switch77 == "polygon-shape" -- 395
					if ____cond77 then -- 395
						do -- 395
							local poly = child.props -- 398
							node:drawPolygon( -- 399
								poly.verts, -- 400
								Dora.Color(poly.fillColor or 4294967295), -- 401
								poly.borderWidth or 0, -- 402
								Dora.Color(poly.borderColor or 4294967295) -- 403
							) -- 403
							break -- 405
						end -- 405
					end -- 405
					____cond77 = ____cond77 or ____switch77 == "verts-shape" -- 405
					if ____cond77 then -- 405
						do -- 405
							local verts = child.props -- 408
							node:drawVertices(__TS__ArrayMap( -- 409
								verts.verts, -- 409
								function(____, ____bindingPattern0) -- 409
									local color -- 409
									local vert -- 409
									vert = ____bindingPattern0[1] -- 409
									color = ____bindingPattern0[2] -- 409
									return { -- 409
										vert, -- 409
										Dora.Color(color) -- 409
									} -- 409
								end -- 409
							)) -- 409
							break -- 410
						end -- 410
					end -- 410
				until true -- 410
			end -- 410
			::__continue75:: -- 410
		end -- 410
		return cnode -- 414
	end -- 349
end -- 349
local getGrid -- 418
do -- 418
	local function handleGridAttribute(cnode, _enode, k, v) -- 420
		repeat -- 420
			local ____switch86 = k -- 420
			local ____cond86 = ____switch86 == "file" or ____switch86 == "gridX" or ____switch86 == "gridY" -- 420
			if ____cond86 then -- 420
				return true -- 422
			end -- 422
			____cond86 = ____cond86 or ____switch86 == "textureRect" -- 422
			if ____cond86 then -- 422
				cnode.textureRect = v -- 423
				return true -- 423
			end -- 423
			____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 423
			if ____cond86 then -- 423
				cnode.depthWrite = v -- 424
				return true -- 424
			end -- 424
			____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 424
			if ____cond86 then -- 424
				cnode.blendFunc = v -- 425
				return true -- 425
			end -- 425
			____cond86 = ____cond86 or ____switch86 == "effect" -- 425
			if ____cond86 then -- 425
				cnode.effect = v -- 426
				return true -- 426
			end -- 426
		until true -- 426
		return false -- 428
	end -- 420
	getGrid = function(enode) -- 430
		local grid = enode.props -- 431
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 432
		local cnode = getNode(enode, node, handleGridAttribute) -- 433
		return cnode -- 434
	end -- 430
end -- 430
local getSprite -- 438
local getVideoNode -- 439
local getTIC80Node -- 440
do -- 440
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 442
		repeat -- 442
			local ____switch90 = k -- 442
			local ____cond90 = ____switch90 == "file" -- 442
			if ____cond90 then -- 442
				return true -- 444
			end -- 444
			____cond90 = ____cond90 or ____switch90 == "textureRect" -- 444
			if ____cond90 then -- 444
				cnode.textureRect = v -- 445
				return true -- 445
			end -- 445
			____cond90 = ____cond90 or ____switch90 == "depthWrite" -- 445
			if ____cond90 then -- 445
				cnode.depthWrite = v -- 446
				return true -- 446
			end -- 446
			____cond90 = ____cond90 or ____switch90 == "blendFunc" -- 446
			if ____cond90 then -- 446
				cnode.blendFunc = v -- 447
				return true -- 447
			end -- 447
			____cond90 = ____cond90 or ____switch90 == "effect" -- 447
			if ____cond90 then -- 447
				cnode.effect = v -- 448
				return true -- 448
			end -- 448
			____cond90 = ____cond90 or ____switch90 == "alphaRef" -- 448
			if ____cond90 then -- 448
				cnode.alphaRef = v -- 449
				return true -- 449
			end -- 449
			____cond90 = ____cond90 or ____switch90 == "uwrap" -- 449
			if ____cond90 then -- 449
				cnode.uwrap = v -- 450
				return true -- 450
			end -- 450
			____cond90 = ____cond90 or ____switch90 == "vwrap" -- 450
			if ____cond90 then -- 450
				cnode.vwrap = v -- 451
				return true -- 451
			end -- 451
			____cond90 = ____cond90 or ____switch90 == "filter" -- 451
			if ____cond90 then -- 451
				cnode.filter = v -- 452
				return true -- 452
			end -- 452
		until true -- 452
		return false -- 454
	end -- 442
	getSprite = function(enode) -- 456
		local sp = enode.props -- 457
		if sp.file then -- 457
			local node = Dora.Sprite(sp.file) -- 459
			if node ~= nil then -- 459
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 461
				return cnode -- 462
			end -- 462
		else -- 462
			local node = Dora.Sprite() -- 465
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 466
			return cnode -- 467
		end -- 467
		return nil -- 469
	end -- 456
	getVideoNode = function(enode) -- 471
		local vn = enode.props -- 472
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 473
		local ____vn_file_9 = vn.file -- 473
		local ____vn_looped_8 = vn.looped -- 473
		if ____vn_looped_8 == nil then -- 473
			____vn_looped_8 = false -- 473
		end -- 473
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 473
		if node ~= nil then -- 473
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 475
			return cnode -- 476
		end -- 476
		return nil -- 478
	end -- 471
	getTIC80Node = function(enode) -- 480
		local tic = enode.props -- 481
		local node = Dora.TIC80Node(tic.file) -- 482
		if node ~= nil then -- 482
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 484
			return cnode -- 485
		end -- 485
		return nil -- 487
	end -- 480
end -- 480
local getAudioSource -- 491
do -- 491
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 493
		repeat -- 493
			local ____switch101 = k -- 493
			local ____cond101 = ____switch101 == "file" -- 493
			if ____cond101 then -- 493
				return true -- 495
			end -- 495
			____cond101 = ____cond101 or ____switch101 == "autoRemove" -- 495
			if ____cond101 then -- 495
				return true -- 496
			end -- 496
			____cond101 = ____cond101 or ____switch101 == "bus" -- 496
			if ____cond101 then -- 496
				return true -- 497
			end -- 497
			____cond101 = ____cond101 or ____switch101 == "volume" -- 497
			if ____cond101 then -- 497
				cnode.volume = v -- 498
				return true -- 498
			end -- 498
			____cond101 = ____cond101 or ____switch101 == "pan" -- 498
			if ____cond101 then -- 498
				cnode.pan = v -- 499
				return true -- 499
			end -- 499
			____cond101 = ____cond101 or ____switch101 == "looping" -- 499
			if ____cond101 then -- 499
				cnode.looping = v -- 500
				return true -- 500
			end -- 500
			____cond101 = ____cond101 or ____switch101 == "playMode" -- 500
			if ____cond101 then -- 500
				do -- 500
					local aus = enode.props -- 502
					repeat -- 502
						local ____switch103 = v -- 502
						local ____cond103 = ____switch103 == "normal" -- 502
						if ____cond103 then -- 502
							cnode:play(aus.delayTime or 0) -- 504
							break -- 504
						end -- 504
						____cond103 = ____cond103 or ____switch103 == "background" -- 504
						if ____cond103 then -- 504
							cnode:playBackground() -- 505
							break -- 505
						end -- 505
						____cond103 = ____cond103 or ____switch103 == "3D" -- 505
						if ____cond103 then -- 505
							cnode:play3D(aus.delayTime or 0) -- 506
							break -- 506
						end -- 506
					until true -- 506
					return true -- 508
				end -- 508
			end -- 508
			____cond101 = ____cond101 or ____switch101 == "delayTime" -- 508
			if ____cond101 then -- 508
				return true -- 510
			end -- 510
			____cond101 = ____cond101 or ____switch101 == "protected" -- 510
			if ____cond101 then -- 510
				cnode:setProtected(v) -- 511
				return true -- 511
			end -- 511
			____cond101 = ____cond101 or ____switch101 == "loopPoint" -- 511
			if ____cond101 then -- 511
				cnode:setLoopPoint(v) -- 512
				return true -- 512
			end -- 512
			____cond101 = ____cond101 or ____switch101 == "velocity" -- 512
			if ____cond101 then -- 512
				do -- 512
					local vx, vy, vz = table.unpack(v, 1, 3) -- 514
					cnode:setVelocity(vx, vy, vz) -- 515
					return true -- 516
				end -- 516
			end -- 516
			____cond101 = ____cond101 or ____switch101 == "minMaxDistance" -- 516
			if ____cond101 then -- 516
				do -- 516
					local min, max = table.unpack(v, 1, 2) -- 519
					cnode:setMinMaxDistance(min, max) -- 520
					return true -- 521
				end -- 521
			end -- 521
			____cond101 = ____cond101 or ____switch101 == "attenuation" -- 521
			if ____cond101 then -- 521
				do -- 521
					local model, factor = table.unpack(v, 1, 2) -- 524
					cnode:setAttenuation(model, factor) -- 525
					return true -- 526
				end -- 526
			end -- 526
			____cond101 = ____cond101 or ____switch101 == "dopplerFactor" -- 526
			if ____cond101 then -- 526
				cnode:setDopplerFactor(v) -- 528
				return true -- 528
			end -- 528
		until true -- 528
		return false -- 530
	end -- 493
	getAudioSource = function(enode) -- 532
		local aus = enode.props -- 533
		local ____aus_autoRemove_11 = aus.autoRemove -- 534
		if ____aus_autoRemove_11 == nil then -- 534
			____aus_autoRemove_11 = true -- 534
		end -- 534
		local autoRemove = ____aus_autoRemove_11 -- 534
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 535
		if node ~= nil then -- 535
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 537
			return cnode -- 538
		end -- 538
		return nil -- 540
	end -- 532
end -- 532
local getLabel -- 544
do -- 544
	local function handleLabelAttribute(cnode, _enode, k, v) -- 546
		repeat -- 546
			local ____switch111 = k -- 546
			local ____cond111 = ____switch111 == "fontName" or ____switch111 == "fontSize" or ____switch111 == "text" or ____switch111 == "smoothLower" or ____switch111 == "smoothUpper" -- 546
			if ____cond111 then -- 546
				return true -- 548
			end -- 548
			____cond111 = ____cond111 or ____switch111 == "alphaRef" -- 548
			if ____cond111 then -- 548
				cnode.alphaRef = v -- 549
				return true -- 549
			end -- 549
			____cond111 = ____cond111 or ____switch111 == "textWidth" -- 549
			if ____cond111 then -- 549
				cnode.textWidth = v -- 550
				return true -- 550
			end -- 550
			____cond111 = ____cond111 or ____switch111 == "lineGap" -- 550
			if ____cond111 then -- 550
				cnode.lineGap = v -- 551
				return true -- 551
			end -- 551
			____cond111 = ____cond111 or ____switch111 == "spacing" -- 551
			if ____cond111 then -- 551
				cnode.spacing = v -- 552
				return true -- 552
			end -- 552
			____cond111 = ____cond111 or ____switch111 == "outlineColor" -- 552
			if ____cond111 then -- 552
				cnode.outlineColor = Dora.Color(v) -- 553
				return true -- 553
			end -- 553
			____cond111 = ____cond111 or ____switch111 == "outlineWidth" -- 553
			if ____cond111 then -- 553
				cnode.outlineWidth = v -- 554
				return true -- 554
			end -- 554
			____cond111 = ____cond111 or ____switch111 == "blendFunc" -- 554
			if ____cond111 then -- 554
				cnode.blendFunc = v -- 555
				return true -- 555
			end -- 555
			____cond111 = ____cond111 or ____switch111 == "depthWrite" -- 555
			if ____cond111 then -- 555
				cnode.depthWrite = v -- 556
				return true -- 556
			end -- 556
			____cond111 = ____cond111 or ____switch111 == "batched" -- 556
			if ____cond111 then -- 556
				cnode.batched = v -- 557
				return true -- 557
			end -- 557
			____cond111 = ____cond111 or ____switch111 == "effect" -- 557
			if ____cond111 then -- 557
				cnode.effect = v -- 558
				return true -- 558
			end -- 558
			____cond111 = ____cond111 or ____switch111 == "alignment" -- 558
			if ____cond111 then -- 558
				cnode.alignment = v -- 559
				return true -- 559
			end -- 559
		until true -- 559
		return false -- 561
	end -- 546
	getLabel = function(enode) -- 563
		local label = enode.props -- 564
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 565
		if node ~= nil then -- 565
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 565
				local ____node_smooth_12 = node.smooth -- 568
				local x = ____node_smooth_12.x -- 568
				local y = ____node_smooth_12.y -- 568
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 569
			end -- 569
			local cnode = getNode(enode, node, handleLabelAttribute) -- 571
			local ____enode_13 = enode -- 572
			local children = ____enode_13.children -- 572
			local text = label.text or "" -- 573
			for i = 1, #children do -- 573
				local child = children[i] -- 575
				if type(child) ~= "table" then -- 575
					text = text .. tostring(child) -- 577
				end -- 577
			end -- 577
			node.text = text -- 580
			return cnode -- 581
		end -- 581
		return nil -- 583
	end -- 563
end -- 563
local getLine -- 587
do -- 587
	local function handleLineAttribute(cnode, enode, k, v) -- 589
		local line = enode.props -- 590
		repeat -- 590
			local ____switch119 = k -- 590
			local ____cond119 = ____switch119 == "verts" -- 590
			if ____cond119 then -- 590
				cnode:set( -- 592
					v, -- 592
					Dora.Color(line.lineColor or 4294967295) -- 592
				) -- 592
				return true -- 592
			end -- 592
			____cond119 = ____cond119 or ____switch119 == "depthWrite" -- 592
			if ____cond119 then -- 592
				cnode.depthWrite = v -- 593
				return true -- 593
			end -- 593
			____cond119 = ____cond119 or ____switch119 == "blendFunc" -- 593
			if ____cond119 then -- 593
				cnode.blendFunc = v -- 594
				return true -- 594
			end -- 594
		until true -- 594
		return false -- 596
	end -- 589
	getLine = function(enode) -- 598
		local node = Dora.Line() -- 599
		local cnode = getNode(enode, node, handleLineAttribute) -- 600
		return cnode -- 601
	end -- 598
end -- 598
local getParticle -- 605
do -- 605
	local function handleParticleAttribute(cnode, _enode, k, v) -- 607
		repeat -- 607
			local ____switch123 = k -- 607
			local ____cond123 = ____switch123 == "file" -- 607
			if ____cond123 then -- 607
				return true -- 609
			end -- 609
			____cond123 = ____cond123 or ____switch123 == "emit" -- 609
			if ____cond123 then -- 609
				if v then -- 609
					cnode:start() -- 610
				end -- 610
				return true -- 610
			end -- 610
			____cond123 = ____cond123 or ____switch123 == "onFinished" -- 610
			if ____cond123 then -- 610
				cnode:slot("Finished", v) -- 611
				return true -- 611
			end -- 611
		until true -- 611
		return false -- 613
	end -- 607
	getParticle = function(enode) -- 615
		local particle = enode.props -- 616
		local node = Dora.Particle(particle.file) -- 617
		if node ~= nil then -- 617
			local cnode = getNode(enode, node, handleParticleAttribute) -- 619
			return cnode -- 620
		end -- 620
		return nil -- 622
	end -- 615
end -- 615
local getMenu -- 626
do -- 626
	local function handleMenuAttribute(cnode, _enode, k, v) -- 628
		repeat -- 628
			local ____switch129 = k -- 628
			local ____cond129 = ____switch129 == "enabled" -- 628
			if ____cond129 then -- 628
				cnode.enabled = v -- 630
				return true -- 630
			end -- 630
		until true -- 630
		return false -- 632
	end -- 628
	getMenu = function(enode) -- 634
		local node = Dora.Menu() -- 635
		local cnode = getNode(enode, node, handleMenuAttribute) -- 636
		return cnode -- 637
	end -- 634
end -- 634
local function getPhysicsWorld(enode) -- 641
	local node = Dora.PhysicsWorld() -- 642
	local cnode = getNode(enode, node) -- 643
	return cnode -- 644
end -- 641
local getBody -- 647
do -- 647
	local function handleBodyAttribute(cnode, _enode, k, v) -- 649
		repeat -- 649
			local ____switch134 = k -- 649
			local ____cond134 = ____switch134 == "type" or ____switch134 == "linearAcceleration" or ____switch134 == "fixedRotation" or ____switch134 == "bullet" or ____switch134 == "world" -- 649
			if ____cond134 then -- 649
				return true -- 656
			end -- 656
			____cond134 = ____cond134 or ____switch134 == "velocityX" -- 656
			if ____cond134 then -- 656
				cnode.velocityX = v -- 657
				return true -- 657
			end -- 657
			____cond134 = ____cond134 or ____switch134 == "velocityY" -- 657
			if ____cond134 then -- 657
				cnode.velocityY = v -- 658
				return true -- 658
			end -- 658
			____cond134 = ____cond134 or ____switch134 == "angularRate" -- 658
			if ____cond134 then -- 658
				cnode.angularRate = v -- 659
				return true -- 659
			end -- 659
			____cond134 = ____cond134 or ____switch134 == "group" -- 659
			if ____cond134 then -- 659
				cnode.group = v -- 660
				return true -- 660
			end -- 660
			____cond134 = ____cond134 or ____switch134 == "linearDamping" -- 660
			if ____cond134 then -- 660
				cnode.linearDamping = v -- 661
				return true -- 661
			end -- 661
			____cond134 = ____cond134 or ____switch134 == "angularDamping" -- 661
			if ____cond134 then -- 661
				cnode.angularDamping = v -- 662
				return true -- 662
			end -- 662
			____cond134 = ____cond134 or ____switch134 == "owner" -- 662
			if ____cond134 then -- 662
				cnode.owner = v -- 663
				return true -- 663
			end -- 663
			____cond134 = ____cond134 or ____switch134 == "receivingContact" -- 663
			if ____cond134 then -- 663
				cnode.receivingContact = v -- 664
				return true -- 664
			end -- 664
			____cond134 = ____cond134 or ____switch134 == "onBodyEnter" -- 664
			if ____cond134 then -- 664
				cnode:slot("BodyEnter", v) -- 665
				return true -- 665
			end -- 665
			____cond134 = ____cond134 or ____switch134 == "onBodyLeave" -- 665
			if ____cond134 then -- 665
				cnode:slot("BodyLeave", v) -- 666
				return true -- 666
			end -- 666
			____cond134 = ____cond134 or ____switch134 == "onContactStart" -- 666
			if ____cond134 then -- 666
				cnode:slot("ContactStart", v) -- 667
				return true -- 667
			end -- 667
			____cond134 = ____cond134 or ____switch134 == "onContactEnd" -- 667
			if ____cond134 then -- 667
				cnode:slot("ContactEnd", v) -- 668
				return true -- 668
			end -- 668
			____cond134 = ____cond134 or ____switch134 == "onContactFilter" -- 668
			if ____cond134 then -- 668
				cnode:onContactFilter(v) -- 669
				return true -- 669
			end -- 669
		until true -- 669
		return false -- 671
	end -- 649
	getBody = function(enode, world) -- 673
		local def = enode.props -- 674
		local bodyDef = Dora.BodyDef() -- 675
		bodyDef.type = def.type -- 676
		if def.angle ~= nil then -- 676
			bodyDef.angle = def.angle -- 677
		end -- 677
		if def.angularDamping ~= nil then -- 677
			bodyDef.angularDamping = def.angularDamping -- 678
		end -- 678
		if def.bullet ~= nil then -- 678
			bodyDef.bullet = def.bullet -- 679
		end -- 679
		if def.fixedRotation ~= nil then -- 679
			bodyDef.fixedRotation = def.fixedRotation -- 680
		end -- 680
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 681
		if def.linearDamping ~= nil then -- 681
			bodyDef.linearDamping = def.linearDamping -- 682
		end -- 682
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 683
		local extraSensors -- 684
		for i = 1, #enode.children do -- 684
			do -- 684
				local child = enode.children[i] -- 686
				if type(child) ~= "table" then -- 686
					goto __continue141 -- 688
				end -- 688
				repeat -- 688
					local ____switch143 = child.type -- 688
					local ____cond143 = ____switch143 == "rect-fixture" -- 688
					if ____cond143 then -- 688
						do -- 688
							local shape = child.props -- 692
							if shape.sensorTag ~= nil then -- 692
								bodyDef:attachPolygonSensor( -- 694
									shape.sensorTag, -- 695
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 696
									shape.width, -- 697
									shape.height, -- 697
									shape.angle or 0 -- 698
								) -- 698
							else -- 698
								bodyDef:attachPolygon( -- 701
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 702
									shape.width, -- 703
									shape.height, -- 703
									shape.angle or 0, -- 704
									shape.density or 1, -- 705
									shape.friction or 0.4, -- 706
									shape.restitution or 0 -- 707
								) -- 707
							end -- 707
							break -- 710
						end -- 710
					end -- 710
					____cond143 = ____cond143 or ____switch143 == "polygon-fixture" -- 710
					if ____cond143 then -- 710
						do -- 710
							local shape = child.props -- 713
							if shape.sensorTag ~= nil then -- 713
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 715
							else -- 715
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 720
							end -- 720
							break -- 727
						end -- 727
					end -- 727
					____cond143 = ____cond143 or ____switch143 == "multi-fixture" -- 727
					if ____cond143 then -- 727
						do -- 727
							local shape = child.props -- 730
							if shape.sensorTag ~= nil then -- 730
								if extraSensors == nil then -- 730
									extraSensors = {} -- 732
								end -- 732
								extraSensors[#extraSensors + 1] = { -- 733
									shape.sensorTag, -- 733
									Dora.BodyDef:multi(shape.verts) -- 733
								} -- 733
							else -- 733
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 735
							end -- 735
							break -- 742
						end -- 742
					end -- 742
					____cond143 = ____cond143 or ____switch143 == "disk-fixture" -- 742
					if ____cond143 then -- 742
						do -- 742
							local shape = child.props -- 745
							if shape.sensorTag ~= nil then -- 745
								bodyDef:attachDiskSensor( -- 747
									shape.sensorTag, -- 748
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 749
									shape.radius -- 750
								) -- 750
							else -- 750
								bodyDef:attachDisk( -- 753
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 754
									shape.radius, -- 755
									shape.density or 1, -- 756
									shape.friction or 0.4, -- 757
									shape.restitution or 0 -- 758
								) -- 758
							end -- 758
							break -- 761
						end -- 761
					end -- 761
					____cond143 = ____cond143 or ____switch143 == "chain-fixture" -- 761
					if ____cond143 then -- 761
						do -- 761
							local shape = child.props -- 764
							if shape.sensorTag ~= nil then -- 764
								if extraSensors == nil then -- 764
									extraSensors = {} -- 766
								end -- 766
								extraSensors[#extraSensors + 1] = { -- 767
									shape.sensorTag, -- 767
									Dora.BodyDef:chain(shape.verts) -- 767
								} -- 767
							else -- 767
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 769
							end -- 769
							break -- 775
						end -- 775
					end -- 775
				until true -- 775
			end -- 775
			::__continue141:: -- 775
		end -- 775
		local body = Dora.Body(bodyDef, world) -- 779
		if extraSensors ~= nil then -- 779
			for i = 1, #extraSensors do -- 779
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 782
				body:attachSensor(tag, def) -- 783
			end -- 783
		end -- 783
		local cnode = getNode(enode, body, handleBodyAttribute) -- 786
		return cnode -- 787
	end -- 673
end -- 673
local getCustomNode -- 791
do -- 791
	local function handleCustomNode(_cnode, _enode, k, _v) -- 793
		repeat -- 793
			local ____switch163 = k -- 793
			local ____cond163 = ____switch163 == "onCreate" -- 793
			if ____cond163 then -- 793
				return true -- 795
			end -- 795
		until true -- 795
		return false -- 797
	end -- 793
	getCustomNode = function(enode) -- 799
		local custom = enode.props -- 800
		local node = custom.onCreate() -- 801
		if node then -- 801
			local cnode = getNode(enode, node, handleCustomNode) -- 803
			return cnode -- 804
		end -- 804
		return nil -- 806
	end -- 799
end -- 799
local getAlignNode -- 810
do -- 810
	local function handleAlignNode(_cnode, _enode, k, _v) -- 812
		repeat -- 812
			local ____switch168 = k -- 812
			local ____cond168 = ____switch168 == "windowRoot" -- 812
			if ____cond168 then -- 812
				return true -- 814
			end -- 814
			____cond168 = ____cond168 or ____switch168 == "style" -- 814
			if ____cond168 then -- 814
				return true -- 815
			end -- 815
			____cond168 = ____cond168 or ____switch168 == "onLayout" -- 815
			if ____cond168 then -- 815
				return true -- 816
			end -- 816
		until true -- 816
		return false -- 818
	end -- 812
	getAlignNode = function(enode) -- 820
		local alignNode = enode.props -- 821
		local node = Dora.AlignNode(alignNode.windowRoot) -- 822
		if alignNode.style then -- 822
			node:css(getAlignStyleText(alignNode.style)) -- 824
		end -- 824
		if alignNode.onLayout then -- 824
			node:onAlignLayout(alignNode.onLayout) -- 827
		end -- 827
		local cnode = getNode(enode, node, handleAlignNode) -- 829
		return cnode -- 830
	end -- 820
end -- 820
local function getEffekNode(enode) -- 834
	return getNode( -- 835
		enode, -- 835
		Dora.EffekNode() -- 835
	) -- 835
end -- 834
local getTileNode -- 838
do -- 838
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 840
		repeat -- 840
			local ____switch175 = k -- 840
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 840
			if ____cond175 then -- 840
				return true -- 842
			end -- 842
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 842
			if ____cond175 then -- 842
				cnode.depthWrite = v -- 843
				return true -- 843
			end -- 843
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 843
			if ____cond175 then -- 843
				cnode.blendFunc = v -- 844
				return true -- 844
			end -- 844
			____cond175 = ____cond175 or ____switch175 == "effect" -- 844
			if ____cond175 then -- 844
				cnode.effect = v -- 845
				return true -- 845
			end -- 845
			____cond175 = ____cond175 or ____switch175 == "filter" -- 845
			if ____cond175 then -- 845
				cnode.filter = v -- 846
				return true -- 846
			end -- 846
		until true -- 846
		return false -- 848
	end -- 840
	getTileNode = function(enode) -- 850
		local tn = enode.props -- 851
		local ____tn_layers_14 -- 852
		if tn.layers then -- 852
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 852
		else -- 852
			____tn_layers_14 = Dora.TileNode(tn.file) -- 852
		end -- 852
		local node = ____tn_layers_14 -- 852
		if node ~= nil then -- 852
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 854
			return cnode -- 855
		end -- 855
		return nil -- 857
	end -- 850
end -- 850
local function addChild(nodeStack, cnode, enode) -- 861
	if #nodeStack > 0 then -- 861
		local last = nodeStack[#nodeStack] -- 863
		last:addChild(cnode) -- 864
	end -- 864
	nodeStack[#nodeStack + 1] = cnode -- 866
	local ____enode_15 = enode -- 867
	local children = ____enode_15.children -- 867
	for i = 1, #children do -- 867
		visitNode(nodeStack, children[i], enode) -- 869
	end -- 869
	if #nodeStack > 1 then -- 869
		table.remove(nodeStack) -- 872
	end -- 872
end -- 861
local function drawNodeCheck(_nodeStack, enode, parent) -- 880
	if parent == nil or parent.type ~= "draw-node" then -- 880
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 882
	end -- 882
end -- 880
local function actionCheck(nodeStack, enode, parent) -- 943
	local unsupported = false -- 944
	if parent == nil then -- 944
		unsupported = true -- 946
	else -- 946
		repeat -- 946
			local ____switch200 = parent.type -- 946
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 946
			if ____cond200 then -- 946
				break -- 949
			end -- 949
			do -- 949
				unsupported = true -- 950
				break -- 950
			end -- 950
		until true -- 950
	end -- 950
	if unsupported then -- 950
		if #nodeStack > 0 then -- 950
			local node = nodeStack[#nodeStack] -- 955
			local actionStack = {} -- 956
			visitAction(actionStack, enode) -- 957
			if #actionStack == 1 then -- 957
				node:runAction(actionStack[1]) -- 959
			end -- 959
		else -- 959
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 962
		end -- 962
	end -- 962
end -- 943
local function bodyCheck(_nodeStack, enode, parent) -- 967
	if parent == nil or parent.type ~= "body" then -- 967
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 969
	end -- 969
end -- 967
actionMap = { -- 973
	["anchor-x"] = Dora.AnchorX, -- 976
	["anchor-y"] = Dora.AnchorY, -- 977
	angle = Dora.Angle, -- 978
	["angle-x"] = Dora.AngleX, -- 979
	["angle-y"] = Dora.AngleY, -- 980
	width = Dora.Width, -- 981
	height = Dora.Height, -- 982
	opacity = Dora.Opacity, -- 983
	roll = Dora.Roll, -- 984
	scale = Dora.Scale, -- 985
	["scale-x"] = Dora.ScaleX, -- 986
	["scale-y"] = Dora.ScaleY, -- 987
	["skew-x"] = Dora.SkewX, -- 988
	["skew-y"] = Dora.SkewY, -- 989
	["move-x"] = Dora.X, -- 990
	["move-y"] = Dora.Y, -- 991
	["move-z"] = Dora.Z -- 992
} -- 992
elementMap = { -- 995
	node = function(nodeStack, enode, parent) -- 996
		addChild( -- 997
			nodeStack, -- 997
			getNode(enode), -- 997
			enode -- 997
		) -- 997
	end, -- 996
	["clip-node"] = function(nodeStack, enode, parent) -- 999
		addChild( -- 1000
			nodeStack, -- 1000
			getClipNode(enode), -- 1000
			enode -- 1000
		) -- 1000
	end, -- 999
	playable = function(nodeStack, enode, parent) -- 1002
		local cnode = getPlayable(enode) -- 1003
		if cnode ~= nil then -- 1003
			addChild(nodeStack, cnode, enode) -- 1005
		end -- 1005
	end, -- 1002
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1008
		local cnode = getDragonBone(enode) -- 1009
		if cnode ~= nil then -- 1009
			addChild(nodeStack, cnode, enode) -- 1011
		end -- 1011
	end, -- 1008
	spine = function(nodeStack, enode, parent) -- 1014
		local cnode = getSpine(enode) -- 1015
		if cnode ~= nil then -- 1015
			addChild(nodeStack, cnode, enode) -- 1017
		end -- 1017
	end, -- 1014
	model = function(nodeStack, enode, parent) -- 1020
		local cnode = getModel(enode) -- 1021
		if cnode ~= nil then -- 1021
			addChild(nodeStack, cnode, enode) -- 1023
		end -- 1023
	end, -- 1020
	["draw-node"] = function(nodeStack, enode, parent) -- 1026
		addChild( -- 1027
			nodeStack, -- 1027
			getDrawNode(enode), -- 1027
			enode -- 1027
		) -- 1027
	end, -- 1026
	["dot-shape"] = drawNodeCheck, -- 1029
	["segment-shape"] = drawNodeCheck, -- 1030
	["rect-shape"] = drawNodeCheck, -- 1031
	["polygon-shape"] = drawNodeCheck, -- 1032
	["verts-shape"] = drawNodeCheck, -- 1033
	grid = function(nodeStack, enode, parent) -- 1034
		addChild( -- 1035
			nodeStack, -- 1035
			getGrid(enode), -- 1035
			enode -- 1035
		) -- 1035
	end, -- 1034
	sprite = function(nodeStack, enode, parent) -- 1037
		local cnode = getSprite(enode) -- 1038
		if cnode ~= nil then -- 1038
			addChild(nodeStack, cnode, enode) -- 1040
		end -- 1040
	end, -- 1037
	["audio-source"] = function(nodeStack, enode, parent) -- 1043
		local cnode = getAudioSource(enode) -- 1044
		if cnode ~= nil then -- 1044
			addChild(nodeStack, cnode, enode) -- 1046
		end -- 1046
	end, -- 1043
	["video-node"] = function(nodeStack, enode, parent) -- 1049
		local cnode = getVideoNode(enode) -- 1050
		if cnode ~= nil then -- 1050
			addChild(nodeStack, cnode, enode) -- 1052
		end -- 1052
	end, -- 1049
	["tic80-node"] = function(nodeStack, enode, parent) -- 1055
		local cnode = getTIC80Node(enode) -- 1056
		if cnode ~= nil then -- 1056
			addChild(nodeStack, cnode, enode) -- 1058
		end -- 1058
	end, -- 1055
	label = function(nodeStack, enode, parent) -- 1061
		local cnode = getLabel(enode) -- 1062
		if cnode ~= nil then -- 1062
			addChild(nodeStack, cnode, enode) -- 1064
		end -- 1064
	end, -- 1061
	line = function(nodeStack, enode, parent) -- 1067
		addChild( -- 1068
			nodeStack, -- 1068
			getLine(enode), -- 1068
			enode -- 1068
		) -- 1068
	end, -- 1067
	particle = function(nodeStack, enode, parent) -- 1070
		local cnode = getParticle(enode) -- 1071
		if cnode ~= nil then -- 1071
			addChild(nodeStack, cnode, enode) -- 1073
		end -- 1073
	end, -- 1070
	menu = function(nodeStack, enode, parent) -- 1076
		addChild( -- 1077
			nodeStack, -- 1077
			getMenu(enode), -- 1077
			enode -- 1077
		) -- 1077
	end, -- 1076
	action = function(_nodeStack, enode, parent) -- 1079
		if #enode.children == 0 then -- 1079
			Warn("<action> tag has no children") -- 1081
			return -- 1082
		end -- 1082
		local action = enode.props -- 1084
		if action.ref == nil then -- 1084
			Warn("<action> tag has no ref") -- 1086
			return -- 1087
		end -- 1087
		local actionStack = {} -- 1089
		for i = 1, #enode.children do -- 1089
			visitAction(actionStack, enode.children[i]) -- 1091
		end -- 1091
		if #actionStack == 1 then -- 1091
			action.ref.current = actionStack[1] -- 1094
		elseif #actionStack > 1 then -- 1094
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1096
		end -- 1096
	end, -- 1079
	["anchor-x"] = actionCheck, -- 1099
	["anchor-y"] = actionCheck, -- 1100
	angle = actionCheck, -- 1101
	["angle-x"] = actionCheck, -- 1102
	["angle-y"] = actionCheck, -- 1103
	delay = actionCheck, -- 1104
	event = actionCheck, -- 1105
	width = actionCheck, -- 1106
	height = actionCheck, -- 1107
	hide = actionCheck, -- 1108
	show = actionCheck, -- 1109
	move = actionCheck, -- 1110
	opacity = actionCheck, -- 1111
	roll = actionCheck, -- 1112
	scale = actionCheck, -- 1113
	["scale-x"] = actionCheck, -- 1114
	["scale-y"] = actionCheck, -- 1115
	["skew-x"] = actionCheck, -- 1116
	["skew-y"] = actionCheck, -- 1117
	["move-x"] = actionCheck, -- 1118
	["move-y"] = actionCheck, -- 1119
	["move-z"] = actionCheck, -- 1120
	frame = actionCheck, -- 1121
	spawn = actionCheck, -- 1122
	sequence = actionCheck, -- 1123
	loop = function(nodeStack, enode, _parent) -- 1124
		if #nodeStack > 0 then -- 1124
			local node = nodeStack[#nodeStack] -- 1126
			local actionStack = {} -- 1127
			for i = 1, #enode.children do -- 1127
				visitAction(actionStack, enode.children[i]) -- 1129
			end -- 1129
			if #actionStack == 1 then -- 1129
				node:runAction(actionStack[1], true) -- 1132
			else -- 1132
				local loop = enode.props -- 1134
				if loop.spawn then -- 1134
					node:runAction( -- 1136
						Dora.Spawn(table.unpack(actionStack)), -- 1136
						true -- 1136
					) -- 1136
				else -- 1136
					node:runAction( -- 1138
						Dora.Sequence(table.unpack(actionStack)), -- 1138
						true -- 1138
					) -- 1138
				end -- 1138
			end -- 1138
		else -- 1138
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1142
		end -- 1142
	end, -- 1124
	["physics-world"] = function(nodeStack, enode, _parent) -- 1145
		addChild( -- 1146
			nodeStack, -- 1146
			getPhysicsWorld(enode), -- 1146
			enode -- 1146
		) -- 1146
	end, -- 1145
	contact = function(nodeStack, enode, _parent) -- 1148
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1149
		if world ~= nil then -- 1149
			local contact = enode.props -- 1151
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1152
		else -- 1152
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1154
		end -- 1154
	end, -- 1148
	body = function(nodeStack, enode, _parent) -- 1157
		local def = enode.props -- 1158
		if def.world then -- 1158
			addChild( -- 1160
				nodeStack, -- 1160
				getBody(enode, def.world), -- 1160
				enode -- 1160
			) -- 1160
			return -- 1161
		end -- 1161
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1163
		if world ~= nil then -- 1163
			addChild( -- 1165
				nodeStack, -- 1165
				getBody(enode, world), -- 1165
				enode -- 1165
			) -- 1165
		else -- 1165
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1167
		end -- 1167
	end, -- 1157
	["rect-fixture"] = bodyCheck, -- 1170
	["polygon-fixture"] = bodyCheck, -- 1171
	["multi-fixture"] = bodyCheck, -- 1172
	["disk-fixture"] = bodyCheck, -- 1173
	["chain-fixture"] = bodyCheck, -- 1174
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1175
		local joint = enode.props -- 1176
		if joint.ref == nil then -- 1176
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1178
			return -- 1179
		end -- 1179
		if joint.bodyA.current == nil then -- 1179
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1182
			return -- 1183
		end -- 1183
		if joint.bodyB.current == nil then -- 1183
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1186
			return -- 1187
		end -- 1187
		local ____joint_ref_19 = joint.ref -- 1189
		local ____self_17 = Dora.Joint -- 1189
		local ____self_17_distance_18 = ____self_17.distance -- 1189
		local ____joint_canCollide_16 = joint.canCollide -- 1190
		if ____joint_canCollide_16 == nil then -- 1190
			____joint_canCollide_16 = false -- 1190
		end -- 1190
		____joint_ref_19.current = ____self_17_distance_18( -- 1189
			____self_17, -- 1189
			____joint_canCollide_16, -- 1190
			joint.bodyA.current, -- 1191
			joint.bodyB.current, -- 1192
			joint.anchorA or Dora.Vec2.zero, -- 1193
			joint.anchorB or Dora.Vec2.zero, -- 1194
			joint.frequency or 0, -- 1195
			joint.damping or 0 -- 1196
		) -- 1196
	end, -- 1175
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1198
		local joint = enode.props -- 1199
		if joint.ref == nil then -- 1199
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1201
			return -- 1202
		end -- 1202
		if joint.bodyA.current == nil then -- 1202
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1205
			return -- 1206
		end -- 1206
		if joint.bodyB.current == nil then -- 1206
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1209
			return -- 1210
		end -- 1210
		local ____joint_ref_23 = joint.ref -- 1212
		local ____self_21 = Dora.Joint -- 1212
		local ____self_21_friction_22 = ____self_21.friction -- 1212
		local ____joint_canCollide_20 = joint.canCollide -- 1213
		if ____joint_canCollide_20 == nil then -- 1213
			____joint_canCollide_20 = false -- 1213
		end -- 1213
		____joint_ref_23.current = ____self_21_friction_22( -- 1212
			____self_21, -- 1212
			____joint_canCollide_20, -- 1213
			joint.bodyA.current, -- 1214
			joint.bodyB.current, -- 1215
			joint.worldPos, -- 1216
			joint.maxForce, -- 1217
			joint.maxTorque -- 1218
		) -- 1218
	end, -- 1198
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1221
		local joint = enode.props -- 1222
		if joint.ref == nil then -- 1222
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1224
			return -- 1225
		end -- 1225
		if joint.jointA.current == nil then -- 1225
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1228
			return -- 1229
		end -- 1229
		if joint.jointB.current == nil then -- 1229
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1232
			return -- 1233
		end -- 1233
		local ____joint_ref_27 = joint.ref -- 1235
		local ____self_25 = Dora.Joint -- 1235
		local ____self_25_gear_26 = ____self_25.gear -- 1235
		local ____joint_canCollide_24 = joint.canCollide -- 1236
		if ____joint_canCollide_24 == nil then -- 1236
			____joint_canCollide_24 = false -- 1236
		end -- 1236
		____joint_ref_27.current = ____self_25_gear_26( -- 1235
			____self_25, -- 1235
			____joint_canCollide_24, -- 1236
			joint.jointA.current, -- 1237
			joint.jointB.current, -- 1238
			joint.ratio or 1 -- 1239
		) -- 1239
	end, -- 1221
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1242
		local joint = enode.props -- 1243
		if joint.ref == nil then -- 1243
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1245
			return -- 1246
		end -- 1246
		if joint.bodyA.current == nil then -- 1246
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1249
			return -- 1250
		end -- 1250
		if joint.bodyB.current == nil then -- 1250
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1253
			return -- 1254
		end -- 1254
		local ____joint_ref_31 = joint.ref -- 1256
		local ____self_29 = Dora.Joint -- 1256
		local ____self_29_spring_30 = ____self_29.spring -- 1256
		local ____joint_canCollide_28 = joint.canCollide -- 1257
		if ____joint_canCollide_28 == nil then -- 1257
			____joint_canCollide_28 = false -- 1257
		end -- 1257
		____joint_ref_31.current = ____self_29_spring_30( -- 1256
			____self_29, -- 1256
			____joint_canCollide_28, -- 1257
			joint.bodyA.current, -- 1258
			joint.bodyB.current, -- 1259
			joint.linearOffset, -- 1260
			joint.angularOffset, -- 1261
			joint.maxForce, -- 1262
			joint.maxTorque, -- 1263
			joint.correctionFactor or 1 -- 1264
		) -- 1264
	end, -- 1242
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1267
		local joint = enode.props -- 1268
		if joint.ref == nil then -- 1268
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1270
			return -- 1271
		end -- 1271
		if joint.body.current == nil then -- 1271
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1274
			return -- 1275
		end -- 1275
		local ____joint_ref_35 = joint.ref -- 1277
		local ____self_33 = Dora.Joint -- 1277
		local ____self_33_move_34 = ____self_33.move -- 1277
		local ____joint_canCollide_32 = joint.canCollide -- 1278
		if ____joint_canCollide_32 == nil then -- 1278
			____joint_canCollide_32 = false -- 1278
		end -- 1278
		____joint_ref_35.current = ____self_33_move_34( -- 1277
			____self_33, -- 1277
			____joint_canCollide_32, -- 1278
			joint.body.current, -- 1279
			joint.targetPos, -- 1280
			joint.maxForce, -- 1281
			joint.frequency, -- 1282
			joint.damping or 0.7 -- 1283
		) -- 1283
	end, -- 1267
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1286
		local joint = enode.props -- 1287
		if joint.ref == nil then -- 1287
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1289
			return -- 1290
		end -- 1290
		if joint.bodyA.current == nil then -- 1290
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1293
			return -- 1294
		end -- 1294
		if joint.bodyB.current == nil then -- 1294
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1297
			return -- 1298
		end -- 1298
		local ____joint_ref_39 = joint.ref -- 1300
		local ____self_37 = Dora.Joint -- 1300
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1300
		local ____joint_canCollide_36 = joint.canCollide -- 1301
		if ____joint_canCollide_36 == nil then -- 1301
			____joint_canCollide_36 = false -- 1301
		end -- 1301
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1300
			____self_37, -- 1300
			____joint_canCollide_36, -- 1301
			joint.bodyA.current, -- 1302
			joint.bodyB.current, -- 1303
			joint.worldPos, -- 1304
			joint.axisAngle, -- 1305
			joint.lowerTranslation or 0, -- 1306
			joint.upperTranslation or 0, -- 1307
			joint.maxMotorForce or 0, -- 1308
			joint.motorSpeed or 0 -- 1309
		) -- 1309
	end, -- 1286
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1312
		local joint = enode.props -- 1313
		if joint.ref == nil then -- 1313
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1315
			return -- 1316
		end -- 1316
		if joint.bodyA.current == nil then -- 1316
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1319
			return -- 1320
		end -- 1320
		if joint.bodyB.current == nil then -- 1320
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1323
			return -- 1324
		end -- 1324
		local ____joint_ref_43 = joint.ref -- 1326
		local ____self_41 = Dora.Joint -- 1326
		local ____self_41_pulley_42 = ____self_41.pulley -- 1326
		local ____joint_canCollide_40 = joint.canCollide -- 1327
		if ____joint_canCollide_40 == nil then -- 1327
			____joint_canCollide_40 = false -- 1327
		end -- 1327
		____joint_ref_43.current = ____self_41_pulley_42( -- 1326
			____self_41, -- 1326
			____joint_canCollide_40, -- 1327
			joint.bodyA.current, -- 1328
			joint.bodyB.current, -- 1329
			joint.anchorA or Dora.Vec2.zero, -- 1330
			joint.anchorB or Dora.Vec2.zero, -- 1331
			joint.groundAnchorA, -- 1332
			joint.groundAnchorB, -- 1333
			joint.ratio or 1 -- 1334
		) -- 1334
	end, -- 1312
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1337
		local joint = enode.props -- 1338
		if joint.ref == nil then -- 1338
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1340
			return -- 1341
		end -- 1341
		if joint.bodyA.current == nil then -- 1341
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1344
			return -- 1345
		end -- 1345
		if joint.bodyB.current == nil then -- 1345
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1348
			return -- 1349
		end -- 1349
		local ____joint_ref_47 = joint.ref -- 1351
		local ____self_45 = Dora.Joint -- 1351
		local ____self_45_revolute_46 = ____self_45.revolute -- 1351
		local ____joint_canCollide_44 = joint.canCollide -- 1352
		if ____joint_canCollide_44 == nil then -- 1352
			____joint_canCollide_44 = false -- 1352
		end -- 1352
		____joint_ref_47.current = ____self_45_revolute_46( -- 1351
			____self_45, -- 1351
			____joint_canCollide_44, -- 1352
			joint.bodyA.current, -- 1353
			joint.bodyB.current, -- 1354
			joint.worldPos, -- 1355
			joint.lowerAngle or 0, -- 1356
			joint.upperAngle or 0, -- 1357
			joint.maxMotorTorque or 0, -- 1358
			joint.motorSpeed or 0 -- 1359
		) -- 1359
	end, -- 1337
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1362
		local joint = enode.props -- 1363
		if joint.ref == nil then -- 1363
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1365
			return -- 1366
		end -- 1366
		if joint.bodyA.current == nil then -- 1366
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1369
			return -- 1370
		end -- 1370
		if joint.bodyB.current == nil then -- 1370
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1373
			return -- 1374
		end -- 1374
		local ____joint_ref_51 = joint.ref -- 1376
		local ____self_49 = Dora.Joint -- 1376
		local ____self_49_rope_50 = ____self_49.rope -- 1376
		local ____joint_canCollide_48 = joint.canCollide -- 1377
		if ____joint_canCollide_48 == nil then -- 1377
			____joint_canCollide_48 = false -- 1377
		end -- 1377
		____joint_ref_51.current = ____self_49_rope_50( -- 1376
			____self_49, -- 1376
			____joint_canCollide_48, -- 1377
			joint.bodyA.current, -- 1378
			joint.bodyB.current, -- 1379
			joint.anchorA or Dora.Vec2.zero, -- 1380
			joint.anchorB or Dora.Vec2.zero, -- 1381
			joint.maxLength or 0 -- 1382
		) -- 1382
	end, -- 1362
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1385
		local joint = enode.props -- 1386
		if joint.ref == nil then -- 1386
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1388
			return -- 1389
		end -- 1389
		if joint.bodyA.current == nil then -- 1389
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1392
			return -- 1393
		end -- 1393
		if joint.bodyB.current == nil then -- 1393
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1396
			return -- 1397
		end -- 1397
		local ____joint_ref_55 = joint.ref -- 1399
		local ____self_53 = Dora.Joint -- 1399
		local ____self_53_weld_54 = ____self_53.weld -- 1399
		local ____joint_canCollide_52 = joint.canCollide -- 1400
		if ____joint_canCollide_52 == nil then -- 1400
			____joint_canCollide_52 = false -- 1400
		end -- 1400
		____joint_ref_55.current = ____self_53_weld_54( -- 1399
			____self_53, -- 1399
			____joint_canCollide_52, -- 1400
			joint.bodyA.current, -- 1401
			joint.bodyB.current, -- 1402
			joint.worldPos, -- 1403
			joint.frequency or 0, -- 1404
			joint.damping or 0 -- 1405
		) -- 1405
	end, -- 1385
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1408
		local joint = enode.props -- 1409
		if joint.ref == nil then -- 1409
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1411
			return -- 1412
		end -- 1412
		if joint.bodyA.current == nil then -- 1412
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1415
			return -- 1416
		end -- 1416
		if joint.bodyB.current == nil then -- 1416
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1419
			return -- 1420
		end -- 1420
		local ____joint_ref_59 = joint.ref -- 1422
		local ____self_57 = Dora.Joint -- 1422
		local ____self_57_wheel_58 = ____self_57.wheel -- 1422
		local ____joint_canCollide_56 = joint.canCollide -- 1423
		if ____joint_canCollide_56 == nil then -- 1423
			____joint_canCollide_56 = false -- 1423
		end -- 1423
		____joint_ref_59.current = ____self_57_wheel_58( -- 1422
			____self_57, -- 1422
			____joint_canCollide_56, -- 1423
			joint.bodyA.current, -- 1424
			joint.bodyB.current, -- 1425
			joint.worldPos, -- 1426
			joint.axisAngle, -- 1427
			joint.maxMotorTorque or 0, -- 1428
			joint.motorSpeed or 0, -- 1429
			joint.frequency or 0, -- 1430
			joint.damping or 0.7 -- 1431
		) -- 1431
	end, -- 1408
	["custom-node"] = function(nodeStack, enode, _parent) -- 1434
		local node = getCustomNode(enode) -- 1435
		if node ~= nil then -- 1435
			addChild(nodeStack, node, enode) -- 1437
		end -- 1437
	end, -- 1434
	["custom-element"] = function() -- 1440
	end, -- 1440
	["align-node"] = function(nodeStack, enode, _parent) -- 1441
		addChild( -- 1442
			nodeStack, -- 1442
			getAlignNode(enode), -- 1442
			enode -- 1442
		) -- 1442
	end, -- 1441
	["effek-node"] = function(nodeStack, enode, _parent) -- 1444
		addChild( -- 1445
			nodeStack, -- 1445
			getEffekNode(enode), -- 1445
			enode -- 1445
		) -- 1445
	end, -- 1444
	effek = function(nodeStack, enode, parent) -- 1447
		if #nodeStack > 0 then -- 1447
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1449
			if node then -- 1449
				local effek = enode.props -- 1451
				local handle = node:play( -- 1452
					effek.file, -- 1452
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1452
					effek.z or 0 -- 1452
				) -- 1452
				if handle >= 0 then -- 1452
					if effek.ref then -- 1452
						effek.ref.current = handle -- 1455
					end -- 1455
					if effek.onEnd then -- 1455
						local onEnd = effek.onEnd -- 1455
						node:slot( -- 1459
							"EffekEnd", -- 1459
							function(h) -- 1459
								if handle == h then -- 1459
									onEnd(nil) -- 1461
								end -- 1461
							end -- 1459
						) -- 1459
					end -- 1459
				end -- 1459
			else -- 1459
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1467
			end -- 1467
		end -- 1467
	end, -- 1447
	["tile-node"] = function(nodeStack, enode, parent) -- 1471
		local cnode = getTileNode(enode) -- 1472
		if cnode ~= nil then -- 1472
			addChild(nodeStack, cnode, enode) -- 1474
		end -- 1474
	end -- 1471
} -- 1471
local roots = {} -- 1527
warnedUnkeyedChildTypes = {} -- 1528
local renderQueued = false -- 1529
local queuedRoots = {} -- 1530
local trackingRoot -- 1531
local function isElementList(node) -- 1535
	return node.type == nil -- 1536
end -- 1535
local function getRenderableElement(renderable) -- 1570
	if type(renderable) == "function" then -- 1570
		return renderable() -- 1572
	end -- 1572
	return renderable -- 1574
end -- 1570
local function removeRoot(root) -- 1815
	for i = 1, #roots do -- 1815
		if roots[i] == root then -- 1815
			table.remove(roots, i) -- 1818
			break -- 1819
		end -- 1819
	end -- 1819
end -- 1815
local function toElementList(node) -- 2390
	if isElementList(node) then -- 2390
		return node -- 2392
	end -- 2392
	return {node} -- 2394
end -- 2390
local function scheduleRootRender(root) -- 2397
	if not root.active then -- 2397
		return -- 2398
	end -- 2398
	for i = 1, #queuedRoots do -- 2398
		if queuedRoots[i] == root then -- 2398
			return -- 2400
		end -- 2400
	end -- 2400
	queuedRoots[#queuedRoots + 1] = root -- 2402
	if renderQueued then -- 2402
		return -- 2403
	end -- 2403
	renderQueued = true -- 2404
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2405
		renderQueued = false -- 2406
		local updatingRoots = queuedRoots -- 2407
		queuedRoots = {} -- 2408
		for i = 1, #updatingRoots do -- 2408
			updatingRoots[i]:update() -- 2410
		end -- 2410
	end)) -- 2405
end -- 2397
____exports.Root = __TS__Class() -- 2415
local Root = ____exports.Root -- 2415
Root.name = "Root" -- 2415
function Root.prototype.____constructor(self, parent) -- 2426
	self.parent = parent -- 2426
	self.mounted = {} -- 2416
	self.signals = {} -- 2418
	self.hookFrames = {} -- 2419
	self.keyedHookFrames = {} -- 2420
	self.nextKeyedHookFrames = {} -- 2421
	self.usedHookFrames = {} -- 2422
	self.hookFrameIndex = 0 -- 2423
	self.active = true -- 2424
end -- 2426
function Root.prototype.render(self, enode) -- 2428
	if not self.active then -- 2428
		roots[#roots + 1] = self -- 2430
		self.active = true -- 2431
	end -- 2431
	self.renderable = enode -- 2433
	self:update() -- 2434
end -- 2428
function Root.prototype.update(self) -- 2437
	if not self.active or self.renderable == nil then -- 2437
		return -- 2438
	end -- 2438
	self:unsubscribeSignals() -- 2439
	local lastTrackingRoot = trackingRoot -- 2440
	local lastRenderingHookRoot = renderingHookRoot -- 2441
	trackingRoot = self -- 2442
	renderingHookRoot = self -- 2443
	local elements -- 2444
	do -- 2444
		local ____try, ____error = pcall(function() -- 2444
			self:beginHookRender() -- 2446
			elements = getRenderableElement(self.renderable) -- 2447
		end) -- 2447
		do -- 2447
			self:finishHookRender() -- 2449
			trackingRoot = lastTrackingRoot -- 2450
			renderingHookRoot = lastRenderingHookRoot -- 2451
		end -- 2451
		if not ____try then -- 2451
			error(____error, 0) -- 2451
		end -- 2451
	end -- 2451
	self.mounted = reconcileChildren( -- 2453
		self.parent, -- 2453
		self.mounted, -- 2453
		toElementList(elements) -- 2453
	) -- 2453
end -- 2437
function Root.prototype.unmount(self) -- 2456
	for i = 1, #self.mounted do -- 2456
		unmountElement(self.mounted[i]) -- 2458
	end -- 2458
	self.mounted = {} -- 2460
	self.renderable = nil -- 2461
	self.hookFrames = {} -- 2462
	self.keyedHookFrames = {} -- 2463
	self.nextKeyedHookFrames = {} -- 2464
	self.usedHookFrames = {} -- 2465
	self.hookFrameIndex = 0 -- 2466
	self:unsubscribeSignals() -- 2467
	if self.active then -- 2467
		removeRoot(self) -- 2469
		self.active = false -- 2470
	end -- 2470
end -- 2456
function Root.prototype.trackSignal(self, signal) -- 2474
	for i = 1, #self.signals do -- 2474
		if self.signals[i] == signal then -- 2474
			return -- 2476
		end -- 2476
	end -- 2476
	local ____self_signals_70 = self.signals -- 2476
	____self_signals_70[#____self_signals_70 + 1] = signal -- 2478
	signal:addRoot(self) -- 2479
end -- 2474
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2482
	local index = self.hookFrameIndex -- 2483
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2484
	local frame -- 2485
	if key ~= nil then -- 2485
		local framesByKey = self.keyedHookFrames[____type] -- 2487
		if framesByKey ~= nil then -- 2487
			frame = framesByKey[key] -- 2489
			if frame ~= nil and self.usedHookFrames[frame] == true then -- 2489
				frame = nil -- 2491
			end -- 2491
		end -- 2491
		if frame == nil then -- 2491
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2495
		end -- 2495
		local nextFramesByKey = self.nextKeyedHookFrames[____type] -- 2497
		if nextFramesByKey == nil then -- 2497
			nextFramesByKey = {} -- 2499
			self.nextKeyedHookFrames[____type] = nextFramesByKey -- 2500
		end -- 2500
		nextFramesByKey[key] = frame -- 2502
		self.hookFrames[index + 1] = frame -- 2503
	else -- 2503
		frame = self.hookFrames[index + 1] -- 2505
		if frame == nil or self.usedHookFrames[frame] == true or frame.type ~= ____type or frame.key ~= nil then -- 2505
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2512
			self.hookFrames[index + 1] = frame -- 2513
		end -- 2513
	end -- 2513
	frame.hookIndex = 0 -- 2516
	self.usedHookFrames[frame] = true -- 2517
	return frame -- 2518
end -- 2482
function Root.prototype.beginHookRender(self) -- 2521
	self.hookFrameIndex = 0 -- 2522
	self.usedHookFrames = {} -- 2523
	self.nextKeyedHookFrames = {} -- 2524
end -- 2521
function Root.prototype.finishHookRender(self) -- 2527
	while #self.hookFrames > self.hookFrameIndex do -- 2527
		table.remove(self.hookFrames) -- 2529
	end -- 2529
	self.keyedHookFrames = self.nextKeyedHookFrames -- 2531
end -- 2527
function Root.prototype.unsubscribeSignals(self) -- 2534
	for i = 1, #self.signals do -- 2534
		self.signals[i]:removeRoot(self) -- 2536
	end -- 2536
	self.signals = {} -- 2538
end -- 2534
function ____exports.createRoot(parent) -- 2542
	local root = __TS__New(____exports.Root, parent) -- 2543
	roots[#roots + 1] = root -- 2544
	return root -- 2545
end -- 2542
____exports.Signal = __TS__Class() -- 2548
local Signal = ____exports.Signal -- 2548
Signal.name = "Signal" -- 2548
function Signal.prototype.____constructor(self, item) -- 2551
	self.item = item -- 2551
	self.roots = {} -- 2549
end -- 2551
function Signal.prototype.addRoot(self, root) -- 2568
	for i = 1, #self.roots do -- 2568
		if self.roots[i] == root then -- 2568
			return -- 2570
		end -- 2570
	end -- 2570
	local ____self_roots_71 = self.roots -- 2570
	____self_roots_71[#____self_roots_71 + 1] = root -- 2572
end -- 2568
function Signal.prototype.removeRoot(self, root) -- 2575
	for i = 1, #self.roots do -- 2575
		if self.roots[i] == root then -- 2575
			table.remove(self.roots, i) -- 2578
			break -- 2579
		end -- 2579
	end -- 2579
end -- 2575
__TS__SetDescriptor( -- 2575
	Signal.prototype, -- 2575
	"value", -- 2575
	{ -- 2575
		get = function(self) -- 2575
			if trackingRoot ~= nil then -- 2575
				trackingRoot:trackSignal(self) -- 2555
			end -- 2555
			return self.item -- 2557
		end, -- 2557
		set = function(self, value) -- 2557
			if self.item == value then -- 2557
				return -- 2561
			end -- 2561
			self.item = value -- 2562
			for i = 1, #self.roots do -- 2562
				scheduleRootRender(self.roots[i]) -- 2564
			end -- 2564
		end -- 2564
	}, -- 2564
	true -- 2564
) -- 2564
function ____exports.signal(value) -- 2585
	return __TS__New(____exports.Signal, value) -- 2586
end -- 2585
function ____exports.reference(item) -- 2589
	local ____item_72 = item -- 2590
	if ____item_72 == nil then -- 2590
		____item_72 = nil -- 2590
	end -- 2590
	return {current = ____item_72} -- 2590
end -- 2589
local function hookDepsEqual(oldDeps, newDeps) -- 2593
	if oldDeps == nil or newDeps == nil then -- 2593
		return false -- 2594
	end -- 2594
	if #oldDeps ~= #newDeps then -- 2594
		return false -- 2595
	end -- 2595
	for i = 1, #oldDeps do -- 2595
		if oldDeps[i] ~= newDeps[i] then -- 2595
			return false -- 2597
		end -- 2597
	end -- 2597
	return true -- 2599
end -- 2593
local function copyDeps(deps) -- 2602
	if deps == nil then -- 2602
		return nil -- 2603
	end -- 2603
	local copied = {} -- 2604
	for i = 1, #deps do -- 2604
		copied[#copied + 1] = deps[i] -- 2606
	end -- 2606
	return copied -- 2608
end -- 2602
function ____exports.useMemo(factory, deps) -- 2611
	local frame = currentHookFrame -- 2612
	if frame == nil then -- 2612
		error("useMemo() can only be called inside a function component") -- 2614
	end -- 2614
	local index = frame.hookIndex -- 2616
	frame.hookIndex = frame.hookIndex + 1 -- 2617
	local hook = frame.hooks[index + 1] -- 2618
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2618
		hook = { -- 2620
			value = factory(), -- 2620
			deps = copyDeps(deps) -- 2620
		} -- 2620
		frame.hooks[index + 1] = hook -- 2621
	end -- 2621
	return hook.value -- 2623
end -- 2611
function ____exports.useCallback(callback, deps) -- 2626
	local frame = currentHookFrame -- 2627
	if frame == nil then -- 2627
		error("useCallback() can only be called inside a function component") -- 2629
	end -- 2629
	local actualDeps = deps or ({}) -- 2631
	local index = frame.hookIndex -- 2632
	frame.hookIndex = frame.hookIndex + 1 -- 2633
	local hook = frame.hooks[index + 1] -- 2634
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2634
		hook = { -- 2636
			value = callback, -- 2636
			deps = copyDeps(actualDeps) -- 2636
		} -- 2636
		frame.hooks[index + 1] = hook -- 2637
	end -- 2637
	return hook.value -- 2639
end -- 2626
function ____exports.useRef(item) -- 2642
	local frame = currentHookFrame -- 2643
	if frame == nil then -- 2643
		Warn("useRef() called outside a function component; falling back to reference()") -- 2645
		return ____exports.reference(item) -- 2646
	end -- 2646
	local index = frame.hookIndex -- 2648
	frame.hookIndex = frame.hookIndex + 1 -- 2649
	local hook = frame.hooks[index + 1] -- 2650
	if hook == nil then -- 2650
		hook = {value = ____exports.reference(item)} -- 2652
		frame.hooks[index + 1] = hook -- 2653
	end -- 2653
	return hook.value -- 2655
end -- 2642
function ____exports.useSignal(value) -- 2658
	local frame = currentHookFrame -- 2659
	if frame == nil then -- 2659
		error("useSignal() can only be called inside a function component") -- 2661
	end -- 2661
	local index = frame.hookIndex -- 2663
	frame.hookIndex = frame.hookIndex + 1 -- 2664
	local hook = frame.hooks[index + 1] -- 2665
	if hook == nil then -- 2665
		hook = {value = ____exports.signal(value)} -- 2667
		frame.hooks[index + 1] = hook -- 2668
	end -- 2668
	return hook.value -- 2670
end -- 2658
local function getPreload(preloadList, node) -- 2673
	if type(node) ~= "table" then -- 2673
		return -- 2675
	end -- 2675
	local enode = node -- 2677
	if enode.type == nil then -- 2677
		local list = node -- 2679
		if #list > 0 then -- 2679
			for i = 1, #list do -- 2679
				getPreload(preloadList, list[i]) -- 2682
			end -- 2682
		end -- 2682
	else -- 2682
		repeat -- 2682
			local ____switch635 = enode.type -- 2682
			local sprite, playable, frame, model, spine, dragonBone, label -- 2682
			local ____cond635 = ____switch635 == "sprite" -- 2682
			if ____cond635 then -- 2682
				sprite = enode.props -- 2688
				if sprite.file then -- 2688
					preloadList[#preloadList + 1] = sprite.file -- 2690
				end -- 2690
				break -- 2692
			end -- 2692
			____cond635 = ____cond635 or ____switch635 == "playable" -- 2692
			if ____cond635 then -- 2692
				playable = enode.props -- 2694
				preloadList[#preloadList + 1] = playable.file -- 2695
				break -- 2696
			end -- 2696
			____cond635 = ____cond635 or ____switch635 == "frame" -- 2696
			if ____cond635 then -- 2696
				frame = enode.props -- 2698
				preloadList[#preloadList + 1] = frame.file -- 2699
				break -- 2700
			end -- 2700
			____cond635 = ____cond635 or ____switch635 == "model" -- 2700
			if ____cond635 then -- 2700
				model = enode.props -- 2702
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2703
				break -- 2704
			end -- 2704
			____cond635 = ____cond635 or ____switch635 == "spine" -- 2704
			if ____cond635 then -- 2704
				spine = enode.props -- 2706
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2707
				break -- 2708
			end -- 2708
			____cond635 = ____cond635 or ____switch635 == "dragon-bone" -- 2708
			if ____cond635 then -- 2708
				dragonBone = enode.props -- 2710
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2711
				break -- 2712
			end -- 2712
			____cond635 = ____cond635 or ____switch635 == "label" -- 2712
			if ____cond635 then -- 2712
				label = enode.props -- 2714
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2715
				break -- 2716
			end -- 2716
		until true -- 2716
	end -- 2716
	getPreload(preloadList, enode.children) -- 2719
end -- 2673
function ____exports.preloadAsync(enode, handler) -- 2722
	local preloadList = {} -- 2723
	getPreload(preloadList, enode) -- 2724
	Dora.Cache:loadAsync(preloadList, handler) -- 2725
end -- 2722
function ____exports.toAction(enode) -- 2728
	local actionDef = ____exports.reference() -- 2729
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2730
	if not actionDef.current then -- 2730
		error("failed to create action") -- 2731
	end -- 2731
	return actionDef.current -- 2732
end -- 2728
return ____exports -- 2728