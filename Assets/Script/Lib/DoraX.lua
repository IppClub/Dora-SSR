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
local Warn, renderFunctionComponent, applyAutoEnableProps, visitAction, visitNode, getElementKey, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, isRunnableActionElement, shallowPropsEqual, collectRunnableActionElements, collectContactElements, getContactKey, patchPhysicsWorldInputs, actionElementEqual, actionChildrenEqual, createActionDef, structuralChildrenEqual, runActionChildren, patchActionChildren, toHostElement, createHostNode, getElementChildren, shouldRecreate, isEventProp, getEventSlot, isPatchableEventProp, patchEventProp, patchContactFilterProp, patchUpdateProp, clearRemovedProp, getAlignStyleText, patchPlayableProps, patchAudioSourceProps, patchParticleProps, patchAlignNodeProps, patchLineProps, clearRef, patchRef, applyProp, patchProps, addChildToParent, mountElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap, renderingHookRoot, currentHookFrame -- 1
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
function visitAction(actionStack, enode) -- 885
	local createAction = actionMap[enode.type] -- 886
	if createAction ~= nil then -- 886
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 888
		return -- 889
	end -- 889
	repeat -- 889
		local ____switch186 = enode.type -- 889
		local ____cond186 = ____switch186 == "delay" -- 889
		if ____cond186 then -- 889
			do -- 889
				local item = enode.props -- 893
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 894
				break -- 895
			end -- 895
		end -- 895
		____cond186 = ____cond186 or ____switch186 == "event" -- 895
		if ____cond186 then -- 895
			do -- 895
				local item = enode.props -- 898
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 899
				break -- 900
			end -- 900
		end -- 900
		____cond186 = ____cond186 or ____switch186 == "hide" -- 900
		if ____cond186 then -- 900
			do -- 900
				actionStack[#actionStack + 1] = Dora.Hide() -- 903
				break -- 904
			end -- 904
		end -- 904
		____cond186 = ____cond186 or ____switch186 == "show" -- 904
		if ____cond186 then -- 904
			do -- 904
				actionStack[#actionStack + 1] = Dora.Show() -- 907
				break -- 908
			end -- 908
		end -- 908
		____cond186 = ____cond186 or ____switch186 == "move" -- 908
		if ____cond186 then -- 908
			do -- 908
				local item = enode.props -- 911
				actionStack[#actionStack + 1] = Dora.Move( -- 912
					item.time, -- 912
					Dora.Vec2(item.startX, item.startY), -- 912
					Dora.Vec2(item.stopX, item.stopY), -- 912
					item.easing -- 912
				) -- 912
				break -- 913
			end -- 913
		end -- 913
		____cond186 = ____cond186 or ____switch186 == "frame" -- 913
		if ____cond186 then -- 913
			do -- 913
				local item = enode.props -- 916
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 917
				break -- 918
			end -- 918
		end -- 918
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 918
		if ____cond186 then -- 918
			do -- 918
				local spawnStack = {} -- 921
				for i = 1, #enode.children do -- 921
					visitAction(spawnStack, enode.children[i]) -- 923
				end -- 923
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 925
				break -- 926
			end -- 926
		end -- 926
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 926
		if ____cond186 then -- 926
			do -- 926
				local sequenceStack = {} -- 929
				for i = 1, #enode.children do -- 929
					visitAction(sequenceStack, enode.children[i]) -- 931
				end -- 931
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 933
				break -- 934
			end -- 934
		end -- 934
		do -- 934
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 937
			break -- 938
		end -- 938
	until true -- 938
end -- 938
function visitNode(nodeStack, node, parent) -- 1477
	if type(node) ~= "table" then -- 1477
		return -- 1479
	end -- 1479
	local enode = node -- 1481
	if enode.type == nil then -- 1481
		local list = node -- 1483
		if #list > 0 then -- 1483
			for i = 1, #list do -- 1483
				local stack = {} -- 1486
				visitNode(stack, list[i], parent) -- 1487
				for i = 1, #stack do -- 1487
					nodeStack[#nodeStack + 1] = stack[i] -- 1489
				end -- 1489
			end -- 1489
		end -- 1489
	else -- 1489
		local handler = elementMap[enode.type] -- 1494
		if handler ~= nil then -- 1494
			handler(nodeStack, enode, parent) -- 1496
		else -- 1496
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1498
		end -- 1498
	end -- 1498
end -- 1498
function ____exports.toNode(enode) -- 1503
	local nodeStack = {} -- 1504
	visitNode(nodeStack, enode) -- 1505
	if #nodeStack == 1 then -- 1505
		return nodeStack[1] -- 1507
	elseif #nodeStack > 1 then -- 1507
		local node = Dora.Node() -- 1509
		for i = 1, #nodeStack do -- 1509
			node:addChild(nodeStack[i]) -- 1511
		end -- 1511
		return node -- 1513
	end -- 1513
	return nil -- 1515
end -- 1503
function getElementKey(element) -- 1537
	local props = element.props -- 1538
	local ____props_60 -- 1539
	if props then -- 1539
		____props_60 = props.key -- 1539
	else -- 1539
		____props_60 = nil -- 1539
	end -- 1539
	return ____props_60 -- 1539
end -- 1539
function getPrimitiveLabelText(enode) -- 1549
	local label = enode.props -- 1550
	local text = label.text or "" -- 1551
	for i = 1, #enode.children do -- 1551
		local child = enode.children[i] -- 1553
		if type(child) ~= "table" then -- 1553
			text = text .. tostring(child) -- 1555
		end -- 1555
	end -- 1555
	return text -- 1558
end -- 1558
function isDrawShapeElement(element) -- 1561
	repeat -- 1561
		local ____switch335 = element.type -- 1561
		local ____cond335 = ____switch335 == "dot-shape" or ____switch335 == "segment-shape" or ____switch335 == "rect-shape" or ____switch335 == "polygon-shape" or ____switch335 == "verts-shape" -- 1561
		if ____cond335 then -- 1561
			return true -- 1568
		end -- 1568
	until true -- 1568
	return false -- 1570
end -- 1570
function isBodyFixtureElement(element) -- 1573
	repeat -- 1573
		local ____switch337 = element.type -- 1573
		local ____cond337 = ____switch337 == "rect-fixture" or ____switch337 == "polygon-fixture" or ____switch337 == "multi-fixture" or ____switch337 == "disk-fixture" or ____switch337 == "chain-fixture" -- 1573
		if ____cond337 then -- 1573
			return true -- 1580
		end -- 1580
	until true -- 1580
	return false -- 1582
end -- 1582
function isPhysicsWorldInputElement(element) -- 1585
	return element.type == "contact" -- 1586
end -- 1586
function isRunnableActionElement(element) -- 1589
	if element.type == "loop" then -- 1589
		return true -- 1590
	end -- 1590
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1591
end -- 1591
function shallowPropsEqual(oldProps, newProps) -- 1602
	for k, v in pairs(oldProps) do -- 1603
		if k ~= "ref" and newProps[k] ~= v then -- 1603
			return false -- 1604
		end -- 1604
	end -- 1604
	for k, v in pairs(newProps) do -- 1606
		if k ~= "ref" and oldProps[k] ~= v then -- 1606
			return false -- 1607
		end -- 1607
	end -- 1607
	return true -- 1609
end -- 1609
function collectRunnableActionElements(element) -- 1612
	local actions = {} -- 1613
	for i = 1, #element.children do -- 1613
		local child = element.children[i] -- 1615
		if type(child) == "table" and isRunnableActionElement(child) then -- 1615
			actions[#actions + 1] = child -- 1617
		end -- 1617
	end -- 1617
	return actions -- 1620
end -- 1620
function collectContactElements(element) -- 1623
	local contacts = {} -- 1624
	for i = 1, #element.children do -- 1624
		local child = element.children[i] -- 1626
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1626
			contacts[#contacts + 1] = child -- 1628
		end -- 1628
	end -- 1628
	return contacts -- 1631
end -- 1631
function getContactKey(contact) -- 1634
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1635
end -- 1635
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1638
	local oldContacts = collectContactElements(oldElement) -- 1639
	local newContacts = collectContactElements(newElement) -- 1640
	local oldByKey = {} -- 1641
	local newByKey = {} -- 1642
	for i = 1, #oldContacts do -- 1642
		local contact = oldContacts[i].props -- 1644
		oldByKey[getContactKey(contact)] = contact -- 1645
	end -- 1645
	for i = 1, #newContacts do -- 1645
		local contact = newContacts[i].props -- 1648
		newByKey[getContactKey(contact)] = contact -- 1649
	end -- 1649
	for i = 1, #oldContacts do -- 1649
		local oldContact = oldContacts[i].props -- 1652
		local key = getContactKey(oldContact) -- 1653
		local newContact = newByKey[key] -- 1654
		if newContact == nil then -- 1654
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1656
		elseif oldContact.enabled ~= newContact.enabled then -- 1656
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1658
		end -- 1658
	end -- 1658
	for i = 1, #newContacts do -- 1658
		local newContact = newContacts[i].props -- 1662
		if oldByKey[getContactKey(newContact)] == nil then -- 1662
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1664
		end -- 1664
	end -- 1664
end -- 1664
function actionElementEqual(oldElement, newElement) -- 1669
	if oldElement.type ~= newElement.type then -- 1669
		return false -- 1670
	end -- 1670
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1670
		return false -- 1671
	end -- 1671
	if #oldElement.children ~= #newElement.children then -- 1671
		return false -- 1672
	end -- 1672
	for i = 1, #oldElement.children do -- 1672
		local oldChild = oldElement.children[i] -- 1674
		local newChild = newElement.children[i] -- 1675
		if type(oldChild) ~= type(newChild) then -- 1675
			return false -- 1676
		end -- 1676
		if type(oldChild) == "table" then -- 1676
			if not actionElementEqual(oldChild, newChild) then -- 1676
				return false -- 1678
			end -- 1678
		elseif oldChild ~= newChild then -- 1678
			return false -- 1680
		end -- 1680
	end -- 1680
	return true -- 1683
end -- 1683
function actionChildrenEqual(oldElement, newElement) -- 1686
	local oldActions = collectRunnableActionElements(oldElement) -- 1687
	local newActions = collectRunnableActionElements(newElement) -- 1688
	if #oldActions ~= #newActions then -- 1688
		return false -- 1689
	end -- 1689
	for i = 1, #oldActions do -- 1689
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1689
			return false -- 1691
		end -- 1691
	end -- 1691
	return true -- 1693
end -- 1693
function createActionDef(actionElement) -- 1696
	if actionElement.type == "loop" then -- 1696
		local actionStack = {} -- 1698
		for i = 1, #actionElement.children do -- 1698
			visitAction(actionStack, actionElement.children[i]) -- 1700
		end -- 1700
		if #actionStack == 1 then -- 1700
			return actionStack[1], true -- 1703
		elseif #actionStack > 1 then -- 1703
			local loop = actionElement.props -- 1705
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1706
		end -- 1706
		return nil, true -- 1708
	end -- 1708
	local actionStack = {} -- 1710
	visitAction(actionStack, actionElement) -- 1711
	return #actionStack == 1 and actionStack[1] or nil, false -- 1712
end -- 1712
function structuralChildrenEqual(oldElement, newElement, check) -- 1715
	local oldChildren = {} -- 1721
	local newChildren = {} -- 1722
	for i = 1, #oldElement.children do -- 1722
		local child = oldElement.children[i] -- 1724
		if type(child) == "table" and check(child) then -- 1724
			oldChildren[#oldChildren + 1] = child -- 1726
		end -- 1726
	end -- 1726
	for i = 1, #newElement.children do -- 1726
		local child = newElement.children[i] -- 1730
		if type(child) == "table" and check(child) then -- 1730
			newChildren[#newChildren + 1] = child -- 1732
		end -- 1732
	end -- 1732
	if #oldChildren ~= #newChildren then -- 1732
		return false -- 1735
	end -- 1735
	for i = 1, #oldChildren do -- 1735
		local oldChild = oldChildren[i] -- 1737
		local newChild = newChildren[i] -- 1738
		if oldChild.type ~= newChild.type then -- 1738
			return false -- 1739
		end -- 1739
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1739
			return false -- 1740
		end -- 1740
	end -- 1740
	return true -- 1742
end -- 1742
function runActionChildren(node, element) -- 1745
	local actionChildren = collectRunnableActionElements(element) -- 1746
	local exclusiveActions = {} -- 1747
	local exclusiveLoop -- 1748
	local warnedExclusiveConflict = false -- 1749
	for i = 1, #actionChildren do -- 1749
		do -- 1749
			local actionElement = actionChildren[i] -- 1751
			local action, loop = createActionDef(actionElement) -- 1752
			if action == nil then -- 1752
				goto __continue389 -- 1753
			end -- 1753
			if actionElement.props.exclusive == true then -- 1753
				if exclusiveLoop == nil then -- 1753
					exclusiveLoop = loop -- 1756
				end -- 1756
				if exclusiveLoop == loop then -- 1756
					exclusiveActions[#exclusiveActions + 1] = action -- 1759
				elseif not warnedExclusiveConflict then -- 1759
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1761
					warnedExclusiveConflict = true -- 1762
				end -- 1762
			end -- 1762
		end -- 1762
		::__continue389:: -- 1762
	end -- 1762
	if #exclusiveActions == 1 then -- 1762
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1767
	elseif #exclusiveActions > 1 then -- 1767
		node:perform( -- 1769
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1769
			exclusiveLoop == true -- 1769
		) -- 1769
	end -- 1769
	for i = 1, #actionChildren do -- 1769
		do -- 1769
			local actionElement = actionChildren[i] -- 1772
			if actionElement.props.exclusive == true then -- 1772
				goto __continue397 -- 1773
			end -- 1773
			local action, loop = createActionDef(actionElement) -- 1774
			if action ~= nil then -- 1774
				node:runAction(action, loop) -- 1776
			end -- 1776
		end -- 1776
		::__continue397:: -- 1776
	end -- 1776
end -- 1776
function patchActionChildren(node, oldElement, newElement) -- 1781
	if not actionChildrenEqual(oldElement, newElement) then -- 1781
		runActionChildren(node, newElement) -- 1783
	end -- 1783
end -- 1783
function toHostElement(enode, parent) -- 1796
	local hostChildren = {} -- 1797
	local props = {} -- 1798
	if enode.props ~= nil then -- 1798
		for k, v in pairs(enode.props) do -- 1800
			props[k] = v -- 1801
		end -- 1801
	end -- 1801
	if enode.type == "label" then -- 1801
		for i = 1, #enode.children do -- 1801
			local child = enode.children[i] -- 1806
			if type(child) ~= "table" then -- 1806
				hostChildren[#hostChildren + 1] = child -- 1808
			end -- 1808
		end -- 1808
	elseif enode.type == "draw-node" then -- 1808
		for i = 1, #enode.children do -- 1808
			local child = enode.children[i] -- 1813
			if type(child) == "table" and isDrawShapeElement(child) then -- 1813
				hostChildren[#hostChildren + 1] = child -- 1815
			end -- 1815
		end -- 1815
	elseif enode.type == "body" then -- 1815
		for i = 1, #enode.children do -- 1815
			local child = enode.children[i] -- 1820
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1820
				hostChildren[#hostChildren + 1] = child -- 1822
			end -- 1822
		end -- 1822
	elseif enode.type == "physics-world" then -- 1822
		for i = 1, #enode.children do -- 1822
			local child = enode.children[i] -- 1827
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1827
				hostChildren[#hostChildren + 1] = child -- 1829
			end -- 1829
		end -- 1829
	end -- 1829
	if enode.type == "body" and props.world == nil then -- 1829
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1834
		if world ~= nil then -- 1834
			props.world = world -- 1836
		end -- 1836
	end -- 1836
	return {type = enode.type, props = props, children = hostChildren} -- 1839
end -- 1839
function createHostNode(enode, parent) -- 1846
	local nodeStack = {} -- 1847
	visitNode( -- 1848
		nodeStack, -- 1848
		toHostElement(enode, parent) -- 1848
	) -- 1848
	if #nodeStack == 1 then -- 1848
		return nodeStack[1] -- 1850
	elseif #nodeStack > 1 then -- 1850
		local node = Dora.Node() -- 1852
		for i = 1, #nodeStack do -- 1852
			node:addChild(nodeStack[i]) -- 1854
		end -- 1854
		return node -- 1856
	end -- 1856
	return nil -- 1858
end -- 1858
function getElementChildren(enode) -- 1861
	local children = {} -- 1862
	if enode.type == "draw-node" or enode.type == "body" then -- 1862
		return children -- 1863
	end -- 1863
	for i = 1, #enode.children do -- 1863
		local child = enode.children[i] -- 1865
		if type(child) == "table" then -- 1865
			local childElement = child -- 1867
			if childElement.type ~= nil then -- 1867
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1867
					children[#children + 1] = childElement -- 1873
				end -- 1873
			else -- 1873
				local list = child -- 1876
				for j = 1, #list do -- 1876
					local item = list[j] -- 1878
					if type(item) == "table" and item.type ~= nil then -- 1878
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1878
							children[#children + 1] = item -- 1884
						end -- 1884
					end -- 1884
				end -- 1884
			end -- 1884
		end -- 1884
	end -- 1884
	return children -- 1891
end -- 1891
function shouldRecreate(oldElement, newElement) -- 1894
	if oldElement.type ~= newElement.type then -- 1894
		return true -- 1895
	end -- 1895
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1895
		return true -- 1896
	end -- 1896
	local oldProps = oldElement.props -- 1897
	local newProps = newElement.props -- 1898
	if newElement.type == "draw-node" then -- 1898
		return true -- 1899
	end -- 1899
	for k, v in pairs(oldProps) do -- 1900
		if k == "onMount" and newProps[k] ~= v then -- 1900
			return true -- 1902
		end -- 1902
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1902
			return true -- 1905
		end -- 1905
	end -- 1905
	for k, v in pairs(newProps) do -- 1908
		if k == "onMount" and oldProps[k] ~= v then -- 1908
			return true -- 1910
		end -- 1910
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1910
			return true -- 1913
		end -- 1913
	end -- 1913
	repeat -- 1913
		local ____switch446 = newElement.type -- 1913
		local ____cond446 = ____switch446 == "grid" -- 1913
		if ____cond446 then -- 1913
			return oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY -- 1918
		end -- 1918
		____cond446 = ____cond446 or (____switch446 == "sprite" or ____switch446 == "video-node" or ____switch446 == "tic80-node" or ____switch446 == "audio-source" or ____switch446 == "particle" or ____switch446 == "tile-node" or ____switch446 == "playable" or ____switch446 == "dragon-bone" or ____switch446 == "spine" or ____switch446 == "model") -- 1918
		if ____cond446 then -- 1918
			return oldProps.file ~= newProps.file -- 1929
		end -- 1929
		____cond446 = ____cond446 or ____switch446 == "label" -- 1929
		if ____cond446 then -- 1929
			return oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf -- 1931
		end -- 1931
		____cond446 = ____cond446 or ____switch446 == "align-node" -- 1931
		if ____cond446 then -- 1931
			return oldProps.windowRoot ~= newProps.windowRoot -- 1933
		end -- 1933
		____cond446 = ____cond446 or ____switch446 == "custom-node" -- 1933
		if ____cond446 then -- 1933
			return oldProps.onCreate ~= newProps.onCreate -- 1935
		end -- 1935
		____cond446 = ____cond446 or ____switch446 == "body" -- 1935
		if ____cond446 then -- 1935
			return oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement) -- 1937
		end -- 1937
	until true -- 1937
	return false -- 1944
end -- 1944
function isEventProp(key) -- 1947
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1948
end -- 1948
function getEventSlot(key) -- 1951
	repeat -- 1951
		local ____switch449 = key -- 1951
		local ____cond449 = ____switch449 == "onActionEnd" -- 1951
		if ____cond449 then -- 1951
			return "ActionEnd" -- 1953
		end -- 1953
		____cond449 = ____cond449 or ____switch449 == "onTapFilter" -- 1953
		if ____cond449 then -- 1953
			return "TapFilter" -- 1954
		end -- 1954
		____cond449 = ____cond449 or ____switch449 == "onTapBegan" -- 1954
		if ____cond449 then -- 1954
			return "TapBegan" -- 1955
		end -- 1955
		____cond449 = ____cond449 or ____switch449 == "onTapEnded" -- 1955
		if ____cond449 then -- 1955
			return "TapEnded" -- 1956
		end -- 1956
		____cond449 = ____cond449 or ____switch449 == "onTapped" -- 1956
		if ____cond449 then -- 1956
			return "Tapped" -- 1957
		end -- 1957
		____cond449 = ____cond449 or ____switch449 == "onTapMoved" -- 1957
		if ____cond449 then -- 1957
			return "TapMoved" -- 1958
		end -- 1958
		____cond449 = ____cond449 or ____switch449 == "onMouseWheel" -- 1958
		if ____cond449 then -- 1958
			return "MouseWheel" -- 1959
		end -- 1959
		____cond449 = ____cond449 or ____switch449 == "onGesture" -- 1959
		if ____cond449 then -- 1959
			return "Gesture" -- 1960
		end -- 1960
		____cond449 = ____cond449 or ____switch449 == "onEnter" -- 1960
		if ____cond449 then -- 1960
			return "Enter" -- 1961
		end -- 1961
		____cond449 = ____cond449 or ____switch449 == "onExit" -- 1961
		if ____cond449 then -- 1961
			return "Exit" -- 1962
		end -- 1962
		____cond449 = ____cond449 or ____switch449 == "onCleanup" -- 1962
		if ____cond449 then -- 1962
			return "Cleanup" -- 1963
		end -- 1963
		____cond449 = ____cond449 or ____switch449 == "onKeyDown" -- 1963
		if ____cond449 then -- 1963
			return "KeyDown" -- 1964
		end -- 1964
		____cond449 = ____cond449 or ____switch449 == "onKeyUp" -- 1964
		if ____cond449 then -- 1964
			return "KeyUp" -- 1965
		end -- 1965
		____cond449 = ____cond449 or ____switch449 == "onKeyPressed" -- 1965
		if ____cond449 then -- 1965
			return "KeyPressed" -- 1966
		end -- 1966
		____cond449 = ____cond449 or ____switch449 == "onAttachIME" -- 1966
		if ____cond449 then -- 1966
			return "AttachIME" -- 1967
		end -- 1967
		____cond449 = ____cond449 or ____switch449 == "onDetachIME" -- 1967
		if ____cond449 then -- 1967
			return "DetachIME" -- 1968
		end -- 1968
		____cond449 = ____cond449 or ____switch449 == "onTextInput" -- 1968
		if ____cond449 then -- 1968
			return "TextInput" -- 1969
		end -- 1969
		____cond449 = ____cond449 or ____switch449 == "onTextEditing" -- 1969
		if ____cond449 then -- 1969
			return "TextEditing" -- 1970
		end -- 1970
		____cond449 = ____cond449 or ____switch449 == "onButtonDown" -- 1970
		if ____cond449 then -- 1970
			return "ButtonDown" -- 1971
		end -- 1971
		____cond449 = ____cond449 or ____switch449 == "onButtonUp" -- 1971
		if ____cond449 then -- 1971
			return "ButtonUp" -- 1972
		end -- 1972
		____cond449 = ____cond449 or ____switch449 == "onAxis" -- 1972
		if ____cond449 then -- 1972
			return "Axis" -- 1973
		end -- 1973
		____cond449 = ____cond449 or ____switch449 == "onAnimationEnd" -- 1973
		if ____cond449 then -- 1973
			return "AnimationEnd" -- 1974
		end -- 1974
		____cond449 = ____cond449 or ____switch449 == "onFinished" -- 1974
		if ____cond449 then -- 1974
			return "Finished" -- 1975
		end -- 1975
		____cond449 = ____cond449 or ____switch449 == "onLayout" -- 1975
		if ____cond449 then -- 1975
			return "AlignLayout" -- 1976
		end -- 1976
		____cond449 = ____cond449 or ____switch449 == "onBodyEnter" -- 1976
		if ____cond449 then -- 1976
			return "BodyEnter" -- 1977
		end -- 1977
		____cond449 = ____cond449 or ____switch449 == "onBodyLeave" -- 1977
		if ____cond449 then -- 1977
			return "BodyLeave" -- 1978
		end -- 1978
		____cond449 = ____cond449 or ____switch449 == "onContactStart" -- 1978
		if ____cond449 then -- 1978
			return "ContactStart" -- 1979
		end -- 1979
		____cond449 = ____cond449 or ____switch449 == "onContactEnd" -- 1979
		if ____cond449 then -- 1979
			return "ContactEnd" -- 1980
		end -- 1980
	until true -- 1980
	return nil -- 1982
end -- 1982
function isPatchableEventProp(key) -- 1985
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" -- 1986
end -- 1986
function patchEventProp(node, key, value) -- 1989
	local slotName = getEventSlot(key) -- 1990
	if slotName == nil then -- 1990
		return -- 1991
	end -- 1991
	node:slot(slotName):clear() -- 1992
	if value ~= nil then -- 1992
		node:slot(slotName, value) -- 1994
	end -- 1994
end -- 1994
function patchContactFilterProp(node, value) -- 1998
	local body = Dora.tolua.cast(node, "Body") -- 1999
	if body == nil then -- 1999
		return -- 2000
	end -- 2000
	if value == nil then -- 2000
		body:onContactFilter(function() return true end) -- 2002
	else -- 2002
		body:onContactFilter(value) -- 2004
	end -- 2004
end -- 2004
function patchUpdateProp(node, value) -- 2008
	if value == nil then -- 2008
		node:unschedule() -- 2010
	elseif type(value) == "thread" then -- 2010
		node:schedule(value) -- 2012
	else -- 2012
		node:schedule(value) -- 2014
	end -- 2014
end -- 2014
function clearRemovedProp(node, key) -- 2018
	repeat -- 2018
		local ____switch464 = key -- 2018
		local ____cond464 = ____switch464 == "transformTarget" or ____switch464 == "stencil" -- 2018
		if ____cond464 then -- 2018
			node[key] = nil -- 2022
			return true -- 2023
		end -- 2023
	until true -- 2023
	return false -- 2025
end -- 2025
function getAlignStyleText(style) -- 2028
	local items = {} -- 2029
	for k, v in pairs(style) do -- 2030
		local name = string.gsub(k, "%u", "-%1") -- 2031
		name = string.lower(name) -- 2032
		repeat -- 2032
			local ____switch467 = k -- 2032
			local ____cond467 = ____switch467 == "margin" or ____switch467 == "padding" or ____switch467 == "border" or ____switch467 == "gap" -- 2032
			if ____cond467 then -- 2032
				do -- 2032
					if type(v) == "table" then -- 2032
						local valueStr = table.concat( -- 2037
							__TS__ArrayMap( -- 2037
								v, -- 2037
								function(____, item) return tostring(item) end -- 2037
							), -- 2037
							"," -- 2037
						) -- 2037
						items[#items + 1] = (name .. ":") .. valueStr -- 2038
					else -- 2038
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2040
					end -- 2040
					break -- 2042
				end -- 2042
			end -- 2042
			do -- 2042
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2045
				break -- 2046
			end -- 2046
		until true -- 2046
	end -- 2046
	return table.concat(items, ";") -- 2049
end -- 2049
function patchPlayableProps(node, oldProps, newProps) -- 2052
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2052
		node:play(newProps.play, newProps.loop == true) -- 2054
	end -- 2054
end -- 2054
function patchAudioSourceProps(node, oldProps, newProps) -- 2058
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2058
		local audio = node -- 2060
		repeat -- 2060
			local ____switch476 = newProps.playMode -- 2060
			local ____cond476 = ____switch476 == "normal" -- 2060
			if ____cond476 then -- 2060
				local ____audio_play_62 = audio.play -- 2062
				local ____newProps_delayTime_61 = newProps.delayTime -- 2062
				if ____newProps_delayTime_61 == nil then -- 2062
					____newProps_delayTime_61 = 0 -- 2062
				end -- 2062
				____audio_play_62(audio, ____newProps_delayTime_61) -- 2062
				break -- 2062
			end -- 2062
			____cond476 = ____cond476 or ____switch476 == "background" -- 2062
			if ____cond476 then -- 2062
				audio:playBackground() -- 2063
				break -- 2063
			end -- 2063
			____cond476 = ____cond476 or ____switch476 == "3D" -- 2063
			if ____cond476 then -- 2063
				local ____audio_play3D_64 = audio.play3D -- 2064
				local ____newProps_delayTime_63 = newProps.delayTime -- 2064
				if ____newProps_delayTime_63 == nil then -- 2064
					____newProps_delayTime_63 = 0 -- 2064
				end -- 2064
				____audio_play3D_64(audio, ____newProps_delayTime_63) -- 2064
				break -- 2064
			end -- 2064
		until true -- 2064
	end -- 2064
end -- 2064
function patchParticleProps(node, oldProps, newProps) -- 2069
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2069
		local particle = node -- 2071
		if newProps.emit then -- 2071
			particle:start() -- 2073
		else -- 2073
			particle:stop() -- 2075
		end -- 2075
	end -- 2075
end -- 2075
function patchAlignNodeProps(node, oldProps, newProps) -- 2080
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2080
		node:css(getAlignStyleText(newProps.style)) -- 2082
	end -- 2082
end -- 2082
function patchLineProps(node, oldProps, newProps) -- 2086
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2086
		local ____self_68 = node -- 2086
		local ____self_68_set_69 = ____self_68.set -- 2086
		local ____newProps_verts_67 = newProps.verts -- 2088
		local ____Dora_Color_66 = Dora.Color -- 2088
		local ____newProps_lineColor_65 = newProps.lineColor -- 2088
		if ____newProps_lineColor_65 == nil then -- 2088
			____newProps_lineColor_65 = 4294967295 -- 2088
		end -- 2088
		____self_68_set_69( -- 2088
			____self_68, -- 2088
			____newProps_verts_67, -- 2088
			____Dora_Color_66(____newProps_lineColor_65) -- 2088
		) -- 2088
	end -- 2088
end -- 2088
function clearRef(props, node) -- 2092
	local ref = props.ref -- 2093
	if ref ~= nil and (node == nil or ref.current == node) then -- 2093
		ref.current = nil -- 2095
	end -- 2095
end -- 2095
function patchRef(node, oldProps, newProps) -- 2099
	if oldProps.ref ~= newProps.ref then -- 2099
		clearRef(oldProps, node) -- 2101
		local ref = newProps.ref -- 2102
		if ref ~= nil then -- 2102
			ref.current = node -- 2104
		end -- 2104
	end -- 2104
end -- 2104
function applyProp(node, enode, key, value) -- 2109
	local name = key -- 2110
	repeat -- 2110
		local ____switch491 = name -- 2110
		local ____cond491 = ____switch491 == "key" or ____switch491 == "children" or ____switch491 == "onMount" or ____switch491 == "onUnmount" -- 2110
		if ____cond491 then -- 2110
			return -- 2116
		end -- 2116
		____cond491 = ____cond491 or ____switch491 == "ref" -- 2116
		if ____cond491 then -- 2116
			value.current = node -- 2118
			return -- 2119
		end -- 2119
		____cond491 = ____cond491 or ____switch491 == "anchorX" -- 2119
		if ____cond491 then -- 2119
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2121
			return -- 2122
		end -- 2122
		____cond491 = ____cond491 or ____switch491 == "anchorY" -- 2122
		if ____cond491 then -- 2122
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2124
			return -- 2125
		end -- 2125
		____cond491 = ____cond491 or ____switch491 == "color3" -- 2125
		if ____cond491 then -- 2125
			node.color3 = Dora.Color3(value) -- 2127
			return -- 2128
		end -- 2128
		____cond491 = ____cond491 or ____switch491 == "transformTarget" -- 2128
		if ____cond491 then -- 2128
			node.transformTarget = value.current -- 2130
			return -- 2131
		end -- 2131
		____cond491 = ____cond491 or ____switch491 == "outlineColor" -- 2131
		if ____cond491 then -- 2131
			node[name] = Dora.Color(value) -- 2133
			return -- 2134
		end -- 2134
		____cond491 = ____cond491 or ____switch491 == "smoothLower" -- 2134
		if ____cond491 then -- 2134
			do -- 2134
				local smooth = node.smooth -- 2136
				node.smooth = Dora.Vec2(value, smooth.y) -- 2137
				return -- 2138
			end -- 2138
		end -- 2138
		____cond491 = ____cond491 or ____switch491 == "smoothUpper" -- 2138
		if ____cond491 then -- 2138
			do -- 2138
				local smooth = node.smooth -- 2141
				node.smooth = Dora.Vec2(smooth.x, value) -- 2142
				return -- 2143
			end -- 2143
		end -- 2143
	until true -- 2143
	if isEventProp(key) then -- 2143
		if key == "onUpdate" then -- 2143
			patchUpdateProp(node, value) -- 2148
		elseif key == "onContactFilter" then -- 2148
			patchContactFilterProp(node, value) -- 2150
		elseif isPatchableEventProp(key) then -- 2150
			patchEventProp(node, key, value) -- 2152
		end -- 2152
		return -- 2154
	end -- 2154
	node[name] = value -- 2156
end -- 2156
function patchProps(node, oldElement, newElement) -- 2159
	local oldProps = oldElement.props -- 2160
	local newProps = newElement.props -- 2161
	for k in pairs(oldProps) do -- 2162
		if k == "onUpdate" and newProps[k] == nil then -- 2162
			patchUpdateProp(node, nil) -- 2164
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2164
			patchContactFilterProp(node, nil) -- 2166
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2166
			patchEventProp(node, k, nil) -- 2168
		elseif newProps[k] == nil then -- 2168
			clearRemovedProp(node, k) -- 2170
		end -- 2170
	end -- 2170
	patchRef(node, oldProps, newProps) -- 2173
	for k, v in pairs(newProps) do -- 2174
		if k ~= "ref" and oldProps[k] ~= v then -- 2174
			applyProp(node, newElement, k, v) -- 2176
		end -- 2176
	end -- 2176
	if newElement.type == "label" then -- 2176
		node.text = getPrimitiveLabelText(newElement) -- 2180
	elseif newElement.type == "physics-world" then -- 2180
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2182
		if world ~= nil then -- 2182
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2184
		end -- 2184
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2184
		patchPlayableProps(node, oldProps, newProps) -- 2192
	elseif newElement.type == "audio-source" then -- 2192
		patchAudioSourceProps(node, oldProps, newProps) -- 2194
	elseif newElement.type == "particle" then -- 2194
		patchParticleProps(node, oldProps, newProps) -- 2196
	elseif newElement.type == "align-node" then -- 2196
		patchAlignNodeProps(node, oldProps, newProps) -- 2198
	elseif newElement.type == "line" then -- 2198
		patchLineProps(node, oldProps, newProps) -- 2200
	end -- 2200
	applyAutoEnableProps(node, newProps) -- 2202
end -- 2202
function addChildToParent(parent, node, props) -- 2205
	if props.tag ~= nil then -- 2205
		parent:addChild(node, props.order or 0, props.tag) -- 2207
	elseif props.order ~= nil then -- 2207
		parent:addChild(node, props.order) -- 2209
	else -- 2209
		parent:addChild(node) -- 2211
	end -- 2211
end -- 2211
function mountElement(parent, enode) -- 2215
	local node = createHostNode(enode, parent) -- 2216
	if node == nil then -- 2216
		return nil -- 2218
	end -- 2218
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2218
		return nil -- 2227
	end -- 2227
	local props = enode.props -- 2229
	addChildToParent(parent, node, props) -- 2230
	local mounted = {element = enode, node = node, children = {}} -- 2231
	runActionChildren(node, enode) -- 2232
	mounted.children = reconcileChildren( -- 2233
		node, -- 2233
		{}, -- 2233
		getElementChildren(enode) -- 2233
	) -- 2233
	return mounted -- 2234
end -- 2234
function unmountElement(mounted) -- 2237
	for i = 1, #mounted.children do -- 2237
		unmountElement(mounted.children[i]) -- 2239
	end -- 2239
	local props = mounted.element.props -- 2241
	if props.onUnmount ~= nil then -- 2241
		props.onUnmount(mounted.node) -- 2243
	end -- 2243
	clearRef(mounted.element.props, mounted.node) -- 2245
	mounted.node:removeFromParent(true) -- 2246
end -- 2246
function reconcileElement(parent, oldMounted, newElement) -- 2249
	if oldMounted == nil then -- 2249
		return mountElement(parent, newElement) -- 2251
	end -- 2251
	if shouldRecreate(oldMounted.element, newElement) then -- 2251
		local oldNode = oldMounted.node -- 2254
		local oldOrder = oldNode.order -- 2255
		local oldTag = oldNode.tag -- 2256
		unmountElement(oldMounted) -- 2257
		local mounted = mountElement(parent, newElement) -- 2258
		if mounted ~= nil then -- 2258
			mounted.node.order = newElement.props.order or oldOrder -- 2260
			mounted.node.tag = newElement.props.tag or oldTag -- 2261
		end -- 2261
		return mounted -- 2263
	end -- 2263
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2265
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2266
	oldMounted.children = reconcileChildren( -- 2267
		oldMounted.node, -- 2267
		oldMounted.children, -- 2267
		getElementChildren(newElement) -- 2267
	) -- 2267
	oldMounted.element = newElement -- 2268
	return oldMounted -- 2269
end -- 2269
function reconcileChildren(parent, oldChildren, newElements) -- 2272
	local oldByKey = {} -- 2273
	local usedOld = {} -- 2274
	for i = 1, #oldChildren do -- 2274
		local oldChild = oldChildren[i] -- 2276
		local key = getElementKey(oldChild.element) -- 2277
		if key ~= nil then -- 2277
			oldByKey[key] = oldChild -- 2279
		end -- 2279
	end -- 2279
	local nextChildren = {} -- 2282
	for i = 1, #newElements do -- 2282
		local newElement = newElements[i] -- 2284
		local key = getElementKey(newElement) -- 2285
		local oldChild -- 2286
		if key ~= nil then -- 2286
			oldChild = oldByKey[key] -- 2288
		else -- 2288
			oldChild = oldChildren[i] -- 2290
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2290
				oldChild = nil -- 2292
			end -- 2292
		end -- 2292
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2295
		if mounted ~= nil then -- 2295
			usedOld[mounted] = true -- 2297
			nextChildren[#nextChildren + 1] = mounted -- 2298
			local props = newElement.props -- 2299
			mounted.node.order = props.order or i -- 2300
			if props.tag ~= nil then -- 2300
				mounted.node.tag = props.tag -- 2301
			end -- 2301
		end -- 2301
	end -- 2301
	for i = 1, #oldChildren do -- 2301
		local oldChild = oldChildren[i] -- 2305
		if not usedOld[oldChild] then -- 2305
			unmountElement(oldChild) -- 2307
		end -- 2307
	end -- 2307
	return nextChildren -- 2310
end -- 2310
____exports.React = {} -- 2310
local React = ____exports.React -- 2310
do -- 2310
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
			____cond42 = ____cond42 or ____switch42 == "onActionEnd" -- 208
			if ____cond42 then -- 208
				cnode:slot("ActionEnd", v) -- 209
				break -- 209
			end -- 209
			____cond42 = ____cond42 or ____switch42 == "onTapFilter" -- 209
			if ____cond42 then -- 209
				cnode:slot("TapFilter", v) -- 210
				break -- 210
			end -- 210
			____cond42 = ____cond42 or ____switch42 == "onTapBegan" -- 210
			if ____cond42 then -- 210
				cnode:slot("TapBegan", v) -- 211
				break -- 211
			end -- 211
			____cond42 = ____cond42 or ____switch42 == "onTapEnded" -- 211
			if ____cond42 then -- 211
				cnode:slot("TapEnded", v) -- 212
				break -- 212
			end -- 212
			____cond42 = ____cond42 or ____switch42 == "onTapped" -- 212
			if ____cond42 then -- 212
				cnode:slot("Tapped", v) -- 213
				break -- 213
			end -- 213
			____cond42 = ____cond42 or ____switch42 == "onTapMoved" -- 213
			if ____cond42 then -- 213
				cnode:slot("TapMoved", v) -- 214
				break -- 214
			end -- 214
			____cond42 = ____cond42 or ____switch42 == "onMouseWheel" -- 214
			if ____cond42 then -- 214
				cnode:slot("MouseWheel", v) -- 215
				break -- 215
			end -- 215
			____cond42 = ____cond42 or ____switch42 == "onGesture" -- 215
			if ____cond42 then -- 215
				cnode:slot("Gesture", v) -- 216
				break -- 216
			end -- 216
			____cond42 = ____cond42 or ____switch42 == "onEnter" -- 216
			if ____cond42 then -- 216
				cnode:slot("Enter", v) -- 217
				break -- 217
			end -- 217
			____cond42 = ____cond42 or ____switch42 == "onExit" -- 217
			if ____cond42 then -- 217
				cnode:slot("Exit", v) -- 218
				break -- 218
			end -- 218
			____cond42 = ____cond42 or ____switch42 == "onCleanup" -- 218
			if ____cond42 then -- 218
				cnode:slot("Cleanup", v) -- 219
				break -- 219
			end -- 219
			____cond42 = ____cond42 or ____switch42 == "onUnmount" -- 219
			if ____cond42 then -- 219
				break -- 220
			end -- 220
			____cond42 = ____cond42 or ____switch42 == "onKeyDown" -- 220
			if ____cond42 then -- 220
				cnode:slot("KeyDown", v) -- 221
				break -- 221
			end -- 221
			____cond42 = ____cond42 or ____switch42 == "onKeyUp" -- 221
			if ____cond42 then -- 221
				cnode:slot("KeyUp", v) -- 222
				break -- 222
			end -- 222
			____cond42 = ____cond42 or ____switch42 == "onKeyPressed" -- 222
			if ____cond42 then -- 222
				cnode:slot("KeyPressed", v) -- 223
				break -- 223
			end -- 223
			____cond42 = ____cond42 or ____switch42 == "onAttachIME" -- 223
			if ____cond42 then -- 223
				cnode:slot("AttachIME", v) -- 224
				break -- 224
			end -- 224
			____cond42 = ____cond42 or ____switch42 == "onDetachIME" -- 224
			if ____cond42 then -- 224
				cnode:slot("DetachIME", v) -- 225
				break -- 225
			end -- 225
			____cond42 = ____cond42 or ____switch42 == "onTextInput" -- 225
			if ____cond42 then -- 225
				cnode:slot("TextInput", v) -- 226
				break -- 226
			end -- 226
			____cond42 = ____cond42 or ____switch42 == "onTextEditing" -- 226
			if ____cond42 then -- 226
				cnode:slot("TextEditing", v) -- 227
				break -- 227
			end -- 227
			____cond42 = ____cond42 or ____switch42 == "onButtonDown" -- 227
			if ____cond42 then -- 227
				cnode:slot("ButtonDown", v) -- 228
				break -- 228
			end -- 228
			____cond42 = ____cond42 or ____switch42 == "onButtonUp" -- 228
			if ____cond42 then -- 228
				cnode:slot("ButtonUp", v) -- 229
				break -- 229
			end -- 229
			____cond42 = ____cond42 or ____switch42 == "onAxis" -- 229
			if ____cond42 then -- 229
				cnode:slot("Axis", v) -- 230
				break -- 230
			end -- 230
			do -- 230
				do -- 230
					if attribHandler then -- 230
						if not attribHandler(cnode, enode, k, v) then -- 230
							cnode[k] = v -- 234
						end -- 234
					else -- 234
						cnode[k] = v -- 237
					end -- 237
					break -- 239
				end -- 239
			end -- 239
		until true -- 239
	end -- 239
	applyAutoEnableProps(cnode, enode.props) -- 243
	if anchor ~= nil then -- 243
		cnode.anchor = anchor -- 244
	end -- 244
	if color3 ~= nil then -- 244
		cnode.color3 = color3 -- 245
	end -- 245
	if jnode.onMount ~= nil then -- 245
		jnode.onMount(cnode) -- 247
	end -- 247
	return cnode -- 249
end -- 196
local getClipNode -- 252
do -- 252
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 254
		repeat -- 254
			local ____switch52 = k -- 254
			local ____cond52 = ____switch52 == "stencil" -- 254
			if ____cond52 then -- 254
				cnode.stencil = ____exports.toNode(v) -- 261
				return true -- 261
			end -- 261
		until true -- 261
		return false -- 263
	end -- 254
	getClipNode = function(enode) -- 265
		return getNode( -- 266
			enode, -- 266
			Dora.ClipNode(), -- 266
			handleClipNodeAttribute -- 266
		) -- 266
	end -- 265
end -- 265
local getPlayable -- 270
local getDragonBone -- 271
local getSpine -- 272
local getModel -- 273
do -- 273
	local function handlePlayableAttribute(cnode, enode, k, v) -- 275
		repeat -- 275
			local ____switch56 = k -- 275
			local ____cond56 = ____switch56 == "file" -- 275
			if ____cond56 then -- 275
				return true -- 277
			end -- 277
			____cond56 = ____cond56 or ____switch56 == "play" -- 277
			if ____cond56 then -- 277
				cnode:play(v, enode.props.loop == true) -- 278
				return true -- 278
			end -- 278
			____cond56 = ____cond56 or ____switch56 == "loop" -- 278
			if ____cond56 then -- 278
				return true -- 279
			end -- 279
			____cond56 = ____cond56 or ____switch56 == "onAnimationEnd" -- 279
			if ____cond56 then -- 279
				cnode:slot("AnimationEnd", v) -- 280
				return true -- 280
			end -- 280
		until true -- 280
		return false -- 282
	end -- 275
	getPlayable = function(enode, cnode, attribHandler) -- 284
		if attribHandler == nil then -- 284
			attribHandler = handlePlayableAttribute -- 285
		end -- 285
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 286
		if cnode ~= nil then -- 286
			return getNode(enode, cnode, attribHandler) -- 288
		end -- 288
		return nil -- 290
	end -- 284
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 293
		repeat -- 293
			local ____switch60 = k -- 293
			local ____cond60 = ____switch60 == "hitTestEnabled" -- 293
			if ____cond60 then -- 293
				cnode.hitTestEnabled = true -- 295
				return true -- 295
			end -- 295
		until true -- 295
		return handlePlayableAttribute(cnode, enode, k, v) -- 297
	end -- 293
	getDragonBone = function(enode) -- 299
		local node = Dora.DragonBone(enode.props.file) -- 300
		if node ~= nil then -- 300
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 302
			return cnode -- 303
		end -- 303
		return nil -- 305
	end -- 299
	local function handleSpineAttribute(cnode, enode, k, v) -- 308
		repeat -- 308
			local ____switch64 = k -- 308
			local ____cond64 = ____switch64 == "hitTestEnabled" -- 308
			if ____cond64 then -- 308
				cnode.hitTestEnabled = true -- 310
				return true -- 310
			end -- 310
		until true -- 310
		return handlePlayableAttribute(cnode, enode, k, v) -- 312
	end -- 308
	getSpine = function(enode) -- 314
		local node = Dora.Spine(enode.props.file) -- 315
		if node ~= nil then -- 315
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 317
			return cnode -- 318
		end -- 318
		return nil -- 320
	end -- 314
	local function handleModelAttribute(cnode, enode, k, v) -- 323
		repeat -- 323
			local ____switch68 = k -- 323
			local ____cond68 = ____switch68 == "reversed" -- 323
			if ____cond68 then -- 323
				cnode.reversed = v -- 325
				return true -- 325
			end -- 325
		until true -- 325
		return handlePlayableAttribute(cnode, enode, k, v) -- 327
	end -- 323
	getModel = function(enode) -- 329
		local node = Dora.Model(enode.props.file) -- 330
		if node ~= nil then -- 330
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 332
			return cnode -- 333
		end -- 333
		return nil -- 335
	end -- 329
end -- 329
local getDrawNode -- 339
do -- 339
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 341
		repeat -- 341
			local ____switch73 = k -- 341
			local ____cond73 = ____switch73 == "depthWrite" -- 341
			if ____cond73 then -- 341
				cnode.depthWrite = v -- 343
				return true -- 343
			end -- 343
			____cond73 = ____cond73 or ____switch73 == "blendFunc" -- 343
			if ____cond73 then -- 343
				cnode.blendFunc = v -- 344
				return true -- 344
			end -- 344
		until true -- 344
		return false -- 346
	end -- 341
	getDrawNode = function(enode) -- 348
		local node = Dora.DrawNode() -- 349
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 350
		local ____enode_7 = enode -- 351
		local children = ____enode_7.children -- 351
		for i = 1, #children do -- 351
			do -- 351
				local child = children[i] -- 353
				if type(child) ~= "table" then -- 353
					goto __continue75 -- 355
				end -- 355
				repeat -- 355
					local ____switch77 = child.type -- 355
					local ____cond77 = ____switch77 == "dot-shape" -- 355
					if ____cond77 then -- 355
						do -- 355
							local dot = child.props -- 359
							node:drawDot( -- 360
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 361
								dot.radius, -- 362
								Dora.Color(dot.color or 4294967295) -- 363
							) -- 363
							break -- 365
						end -- 365
					end -- 365
					____cond77 = ____cond77 or ____switch77 == "segment-shape" -- 365
					if ____cond77 then -- 365
						do -- 365
							local segment = child.props -- 368
							node:drawSegment( -- 369
								Dora.Vec2(segment.startX, segment.startY), -- 370
								Dora.Vec2(segment.stopX, segment.stopY), -- 371
								segment.radius, -- 372
								Dora.Color(segment.color or 4294967295) -- 373
							) -- 373
							break -- 375
						end -- 375
					end -- 375
					____cond77 = ____cond77 or ____switch77 == "rect-shape" -- 375
					if ____cond77 then -- 375
						do -- 375
							local rect = child.props -- 378
							local centerX = rect.centerX or 0 -- 379
							local centerY = rect.centerY or 0 -- 380
							local hw = rect.width / 2 -- 381
							local hh = rect.height / 2 -- 382
							node:drawPolygon( -- 383
								{ -- 384
									Dora.Vec2(centerX - hw, centerY + hh), -- 385
									Dora.Vec2(centerX + hw, centerY + hh), -- 386
									Dora.Vec2(centerX + hw, centerY - hh), -- 387
									Dora.Vec2(centerX - hw, centerY - hh) -- 388
								}, -- 388
								Dora.Color(rect.fillColor or 4294967295), -- 390
								rect.borderWidth or 0, -- 391
								Dora.Color(rect.borderColor or 4294967295) -- 392
							) -- 392
							break -- 394
						end -- 394
					end -- 394
					____cond77 = ____cond77 or ____switch77 == "polygon-shape" -- 394
					if ____cond77 then -- 394
						do -- 394
							local poly = child.props -- 397
							node:drawPolygon( -- 398
								poly.verts, -- 399
								Dora.Color(poly.fillColor or 4294967295), -- 400
								poly.borderWidth or 0, -- 401
								Dora.Color(poly.borderColor or 4294967295) -- 402
							) -- 402
							break -- 404
						end -- 404
					end -- 404
					____cond77 = ____cond77 or ____switch77 == "verts-shape" -- 404
					if ____cond77 then -- 404
						do -- 404
							local verts = child.props -- 407
							node:drawVertices(__TS__ArrayMap( -- 408
								verts.verts, -- 408
								function(____, ____bindingPattern0) -- 408
									local color -- 408
									local vert -- 408
									vert = ____bindingPattern0[1] -- 408
									color = ____bindingPattern0[2] -- 408
									return { -- 408
										vert, -- 408
										Dora.Color(color) -- 408
									} -- 408
								end -- 408
							)) -- 408
							break -- 409
						end -- 409
					end -- 409
				until true -- 409
			end -- 409
			::__continue75:: -- 409
		end -- 409
		return cnode -- 413
	end -- 348
end -- 348
local getGrid -- 417
do -- 417
	local function handleGridAttribute(cnode, _enode, k, v) -- 419
		repeat -- 419
			local ____switch86 = k -- 419
			local ____cond86 = ____switch86 == "file" or ____switch86 == "gridX" or ____switch86 == "gridY" -- 419
			if ____cond86 then -- 419
				return true -- 421
			end -- 421
			____cond86 = ____cond86 or ____switch86 == "textureRect" -- 421
			if ____cond86 then -- 421
				cnode.textureRect = v -- 422
				return true -- 422
			end -- 422
			____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 422
			if ____cond86 then -- 422
				cnode.depthWrite = v -- 423
				return true -- 423
			end -- 423
			____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 423
			if ____cond86 then -- 423
				cnode.blendFunc = v -- 424
				return true -- 424
			end -- 424
			____cond86 = ____cond86 or ____switch86 == "effect" -- 424
			if ____cond86 then -- 424
				cnode.effect = v -- 425
				return true -- 425
			end -- 425
		until true -- 425
		return false -- 427
	end -- 419
	getGrid = function(enode) -- 429
		local grid = enode.props -- 430
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 431
		local cnode = getNode(enode, node, handleGridAttribute) -- 432
		return cnode -- 433
	end -- 429
end -- 429
local getSprite -- 437
local getVideoNode -- 438
local getTIC80Node -- 439
do -- 439
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 441
		repeat -- 441
			local ____switch90 = k -- 441
			local ____cond90 = ____switch90 == "file" -- 441
			if ____cond90 then -- 441
				return true -- 443
			end -- 443
			____cond90 = ____cond90 or ____switch90 == "textureRect" -- 443
			if ____cond90 then -- 443
				cnode.textureRect = v -- 444
				return true -- 444
			end -- 444
			____cond90 = ____cond90 or ____switch90 == "depthWrite" -- 444
			if ____cond90 then -- 444
				cnode.depthWrite = v -- 445
				return true -- 445
			end -- 445
			____cond90 = ____cond90 or ____switch90 == "blendFunc" -- 445
			if ____cond90 then -- 445
				cnode.blendFunc = v -- 446
				return true -- 446
			end -- 446
			____cond90 = ____cond90 or ____switch90 == "effect" -- 446
			if ____cond90 then -- 446
				cnode.effect = v -- 447
				return true -- 447
			end -- 447
			____cond90 = ____cond90 or ____switch90 == "alphaRef" -- 447
			if ____cond90 then -- 447
				cnode.alphaRef = v -- 448
				return true -- 448
			end -- 448
			____cond90 = ____cond90 or ____switch90 == "uwrap" -- 448
			if ____cond90 then -- 448
				cnode.uwrap = v -- 449
				return true -- 449
			end -- 449
			____cond90 = ____cond90 or ____switch90 == "vwrap" -- 449
			if ____cond90 then -- 449
				cnode.vwrap = v -- 450
				return true -- 450
			end -- 450
			____cond90 = ____cond90 or ____switch90 == "filter" -- 450
			if ____cond90 then -- 450
				cnode.filter = v -- 451
				return true -- 451
			end -- 451
		until true -- 451
		return false -- 453
	end -- 441
	getSprite = function(enode) -- 455
		local sp = enode.props -- 456
		if sp.file then -- 456
			local node = Dora.Sprite(sp.file) -- 458
			if node ~= nil then -- 458
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 460
				return cnode -- 461
			end -- 461
		else -- 461
			local node = Dora.Sprite() -- 464
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 465
			return cnode -- 466
		end -- 466
		return nil -- 468
	end -- 455
	getVideoNode = function(enode) -- 470
		local vn = enode.props -- 471
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 472
		local ____vn_file_9 = vn.file -- 472
		local ____vn_looped_8 = vn.looped -- 472
		if ____vn_looped_8 == nil then -- 472
			____vn_looped_8 = false -- 472
		end -- 472
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 472
		if node ~= nil then -- 472
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 474
			return cnode -- 475
		end -- 475
		return nil -- 477
	end -- 470
	getTIC80Node = function(enode) -- 479
		local tic = enode.props -- 480
		local node = Dora.TIC80Node(tic.file) -- 481
		if node ~= nil then -- 481
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 483
			return cnode -- 484
		end -- 484
		return nil -- 486
	end -- 479
end -- 479
local getAudioSource -- 490
do -- 490
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 492
		repeat -- 492
			local ____switch101 = k -- 492
			local ____cond101 = ____switch101 == "file" -- 492
			if ____cond101 then -- 492
				return true -- 494
			end -- 494
			____cond101 = ____cond101 or ____switch101 == "autoRemove" -- 494
			if ____cond101 then -- 494
				return true -- 495
			end -- 495
			____cond101 = ____cond101 or ____switch101 == "bus" -- 495
			if ____cond101 then -- 495
				return true -- 496
			end -- 496
			____cond101 = ____cond101 or ____switch101 == "volume" -- 496
			if ____cond101 then -- 496
				cnode.volume = v -- 497
				return true -- 497
			end -- 497
			____cond101 = ____cond101 or ____switch101 == "pan" -- 497
			if ____cond101 then -- 497
				cnode.pan = v -- 498
				return true -- 498
			end -- 498
			____cond101 = ____cond101 or ____switch101 == "looping" -- 498
			if ____cond101 then -- 498
				cnode.looping = v -- 499
				return true -- 499
			end -- 499
			____cond101 = ____cond101 or ____switch101 == "playMode" -- 499
			if ____cond101 then -- 499
				do -- 499
					local aus = enode.props -- 501
					repeat -- 501
						local ____switch103 = v -- 501
						local ____cond103 = ____switch103 == "normal" -- 501
						if ____cond103 then -- 501
							cnode:play(aus.delayTime or 0) -- 503
							break -- 503
						end -- 503
						____cond103 = ____cond103 or ____switch103 == "background" -- 503
						if ____cond103 then -- 503
							cnode:playBackground() -- 504
							break -- 504
						end -- 504
						____cond103 = ____cond103 or ____switch103 == "3D" -- 504
						if ____cond103 then -- 504
							cnode:play3D(aus.delayTime or 0) -- 505
							break -- 505
						end -- 505
					until true -- 505
					return true -- 507
				end -- 507
			end -- 507
			____cond101 = ____cond101 or ____switch101 == "delayTime" -- 507
			if ____cond101 then -- 507
				return true -- 509
			end -- 509
			____cond101 = ____cond101 or ____switch101 == "protected" -- 509
			if ____cond101 then -- 509
				cnode:setProtected(v) -- 510
				return true -- 510
			end -- 510
			____cond101 = ____cond101 or ____switch101 == "loopPoint" -- 510
			if ____cond101 then -- 510
				cnode:setLoopPoint(v) -- 511
				return true -- 511
			end -- 511
			____cond101 = ____cond101 or ____switch101 == "velocity" -- 511
			if ____cond101 then -- 511
				do -- 511
					local vx, vy, vz = table.unpack(v, 1, 3) -- 513
					cnode:setVelocity(vx, vy, vz) -- 514
					return true -- 515
				end -- 515
			end -- 515
			____cond101 = ____cond101 or ____switch101 == "minMaxDistance" -- 515
			if ____cond101 then -- 515
				do -- 515
					local min, max = table.unpack(v, 1, 2) -- 518
					cnode:setMinMaxDistance(min, max) -- 519
					return true -- 520
				end -- 520
			end -- 520
			____cond101 = ____cond101 or ____switch101 == "attenuation" -- 520
			if ____cond101 then -- 520
				do -- 520
					local model, factor = table.unpack(v, 1, 2) -- 523
					cnode:setAttenuation(model, factor) -- 524
					return true -- 525
				end -- 525
			end -- 525
			____cond101 = ____cond101 or ____switch101 == "dopplerFactor" -- 525
			if ____cond101 then -- 525
				cnode:setDopplerFactor(v) -- 527
				return true -- 527
			end -- 527
		until true -- 527
		return false -- 529
	end -- 492
	getAudioSource = function(enode) -- 531
		local aus = enode.props -- 532
		local ____aus_autoRemove_11 = aus.autoRemove -- 533
		if ____aus_autoRemove_11 == nil then -- 533
			____aus_autoRemove_11 = true -- 533
		end -- 533
		local autoRemove = ____aus_autoRemove_11 -- 533
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 534
		if node ~= nil then -- 534
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 536
			return cnode -- 537
		end -- 537
		return nil -- 539
	end -- 531
end -- 531
local getLabel -- 543
do -- 543
	local function handleLabelAttribute(cnode, _enode, k, v) -- 545
		repeat -- 545
			local ____switch111 = k -- 545
			local ____cond111 = ____switch111 == "fontName" or ____switch111 == "fontSize" or ____switch111 == "text" or ____switch111 == "smoothLower" or ____switch111 == "smoothUpper" -- 545
			if ____cond111 then -- 545
				return true -- 547
			end -- 547
			____cond111 = ____cond111 or ____switch111 == "alphaRef" -- 547
			if ____cond111 then -- 547
				cnode.alphaRef = v -- 548
				return true -- 548
			end -- 548
			____cond111 = ____cond111 or ____switch111 == "textWidth" -- 548
			if ____cond111 then -- 548
				cnode.textWidth = v -- 549
				return true -- 549
			end -- 549
			____cond111 = ____cond111 or ____switch111 == "lineGap" -- 549
			if ____cond111 then -- 549
				cnode.lineGap = v -- 550
				return true -- 550
			end -- 550
			____cond111 = ____cond111 or ____switch111 == "spacing" -- 550
			if ____cond111 then -- 550
				cnode.spacing = v -- 551
				return true -- 551
			end -- 551
			____cond111 = ____cond111 or ____switch111 == "outlineColor" -- 551
			if ____cond111 then -- 551
				cnode.outlineColor = Dora.Color(v) -- 552
				return true -- 552
			end -- 552
			____cond111 = ____cond111 or ____switch111 == "outlineWidth" -- 552
			if ____cond111 then -- 552
				cnode.outlineWidth = v -- 553
				return true -- 553
			end -- 553
			____cond111 = ____cond111 or ____switch111 == "blendFunc" -- 553
			if ____cond111 then -- 553
				cnode.blendFunc = v -- 554
				return true -- 554
			end -- 554
			____cond111 = ____cond111 or ____switch111 == "depthWrite" -- 554
			if ____cond111 then -- 554
				cnode.depthWrite = v -- 555
				return true -- 555
			end -- 555
			____cond111 = ____cond111 or ____switch111 == "batched" -- 555
			if ____cond111 then -- 555
				cnode.batched = v -- 556
				return true -- 556
			end -- 556
			____cond111 = ____cond111 or ____switch111 == "effect" -- 556
			if ____cond111 then -- 556
				cnode.effect = v -- 557
				return true -- 557
			end -- 557
			____cond111 = ____cond111 or ____switch111 == "alignment" -- 557
			if ____cond111 then -- 557
				cnode.alignment = v -- 558
				return true -- 558
			end -- 558
		until true -- 558
		return false -- 560
	end -- 545
	getLabel = function(enode) -- 562
		local label = enode.props -- 563
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 564
		if node ~= nil then -- 564
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 564
				local ____node_smooth_12 = node.smooth -- 567
				local x = ____node_smooth_12.x -- 567
				local y = ____node_smooth_12.y -- 567
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 568
			end -- 568
			local cnode = getNode(enode, node, handleLabelAttribute) -- 570
			local ____enode_13 = enode -- 571
			local children = ____enode_13.children -- 571
			local text = label.text or "" -- 572
			for i = 1, #children do -- 572
				local child = children[i] -- 574
				if type(child) ~= "table" then -- 574
					text = text .. tostring(child) -- 576
				end -- 576
			end -- 576
			node.text = text -- 579
			return cnode -- 580
		end -- 580
		return nil -- 582
	end -- 562
end -- 562
local getLine -- 586
do -- 586
	local function handleLineAttribute(cnode, enode, k, v) -- 588
		local line = enode.props -- 589
		repeat -- 589
			local ____switch119 = k -- 589
			local ____cond119 = ____switch119 == "verts" -- 589
			if ____cond119 then -- 589
				cnode:set( -- 591
					v, -- 591
					Dora.Color(line.lineColor or 4294967295) -- 591
				) -- 591
				return true -- 591
			end -- 591
			____cond119 = ____cond119 or ____switch119 == "depthWrite" -- 591
			if ____cond119 then -- 591
				cnode.depthWrite = v -- 592
				return true -- 592
			end -- 592
			____cond119 = ____cond119 or ____switch119 == "blendFunc" -- 592
			if ____cond119 then -- 592
				cnode.blendFunc = v -- 593
				return true -- 593
			end -- 593
		until true -- 593
		return false -- 595
	end -- 588
	getLine = function(enode) -- 597
		local node = Dora.Line() -- 598
		local cnode = getNode(enode, node, handleLineAttribute) -- 599
		return cnode -- 600
	end -- 597
end -- 597
local getParticle -- 604
do -- 604
	local function handleParticleAttribute(cnode, _enode, k, v) -- 606
		repeat -- 606
			local ____switch123 = k -- 606
			local ____cond123 = ____switch123 == "file" -- 606
			if ____cond123 then -- 606
				return true -- 608
			end -- 608
			____cond123 = ____cond123 or ____switch123 == "emit" -- 608
			if ____cond123 then -- 608
				if v then -- 608
					cnode:start() -- 609
				end -- 609
				return true -- 609
			end -- 609
			____cond123 = ____cond123 or ____switch123 == "onFinished" -- 609
			if ____cond123 then -- 609
				cnode:slot("Finished", v) -- 610
				return true -- 610
			end -- 610
		until true -- 610
		return false -- 612
	end -- 606
	getParticle = function(enode) -- 614
		local particle = enode.props -- 615
		local node = Dora.Particle(particle.file) -- 616
		if node ~= nil then -- 616
			local cnode = getNode(enode, node, handleParticleAttribute) -- 618
			return cnode -- 619
		end -- 619
		return nil -- 621
	end -- 614
end -- 614
local getMenu -- 625
do -- 625
	local function handleMenuAttribute(cnode, _enode, k, v) -- 627
		repeat -- 627
			local ____switch129 = k -- 627
			local ____cond129 = ____switch129 == "enabled" -- 627
			if ____cond129 then -- 627
				cnode.enabled = v -- 629
				return true -- 629
			end -- 629
		until true -- 629
		return false -- 631
	end -- 627
	getMenu = function(enode) -- 633
		local node = Dora.Menu() -- 634
		local cnode = getNode(enode, node, handleMenuAttribute) -- 635
		return cnode -- 636
	end -- 633
end -- 633
local function getPhysicsWorld(enode) -- 640
	local node = Dora.PhysicsWorld() -- 641
	local cnode = getNode(enode, node) -- 642
	return cnode -- 643
end -- 640
local getBody -- 646
do -- 646
	local function handleBodyAttribute(cnode, _enode, k, v) -- 648
		repeat -- 648
			local ____switch134 = k -- 648
			local ____cond134 = ____switch134 == "type" or ____switch134 == "linearAcceleration" or ____switch134 == "fixedRotation" or ____switch134 == "bullet" or ____switch134 == "world" -- 648
			if ____cond134 then -- 648
				return true -- 655
			end -- 655
			____cond134 = ____cond134 or ____switch134 == "velocityX" -- 655
			if ____cond134 then -- 655
				cnode.velocityX = v -- 656
				return true -- 656
			end -- 656
			____cond134 = ____cond134 or ____switch134 == "velocityY" -- 656
			if ____cond134 then -- 656
				cnode.velocityY = v -- 657
				return true -- 657
			end -- 657
			____cond134 = ____cond134 or ____switch134 == "angularRate" -- 657
			if ____cond134 then -- 657
				cnode.angularRate = v -- 658
				return true -- 658
			end -- 658
			____cond134 = ____cond134 or ____switch134 == "group" -- 658
			if ____cond134 then -- 658
				cnode.group = v -- 659
				return true -- 659
			end -- 659
			____cond134 = ____cond134 or ____switch134 == "linearDamping" -- 659
			if ____cond134 then -- 659
				cnode.linearDamping = v -- 660
				return true -- 660
			end -- 660
			____cond134 = ____cond134 or ____switch134 == "angularDamping" -- 660
			if ____cond134 then -- 660
				cnode.angularDamping = v -- 661
				return true -- 661
			end -- 661
			____cond134 = ____cond134 or ____switch134 == "owner" -- 661
			if ____cond134 then -- 661
				cnode.owner = v -- 662
				return true -- 662
			end -- 662
			____cond134 = ____cond134 or ____switch134 == "receivingContact" -- 662
			if ____cond134 then -- 662
				cnode.receivingContact = v -- 663
				return true -- 663
			end -- 663
			____cond134 = ____cond134 or ____switch134 == "onBodyEnter" -- 663
			if ____cond134 then -- 663
				cnode:slot("BodyEnter", v) -- 664
				return true -- 664
			end -- 664
			____cond134 = ____cond134 or ____switch134 == "onBodyLeave" -- 664
			if ____cond134 then -- 664
				cnode:slot("BodyLeave", v) -- 665
				return true -- 665
			end -- 665
			____cond134 = ____cond134 or ____switch134 == "onContactStart" -- 665
			if ____cond134 then -- 665
				cnode:slot("ContactStart", v) -- 666
				return true -- 666
			end -- 666
			____cond134 = ____cond134 or ____switch134 == "onContactEnd" -- 666
			if ____cond134 then -- 666
				cnode:slot("ContactEnd", v) -- 667
				return true -- 667
			end -- 667
			____cond134 = ____cond134 or ____switch134 == "onContactFilter" -- 667
			if ____cond134 then -- 667
				cnode:onContactFilter(v) -- 668
				return true -- 668
			end -- 668
		until true -- 668
		return false -- 670
	end -- 648
	getBody = function(enode, world) -- 672
		local def = enode.props -- 673
		local bodyDef = Dora.BodyDef() -- 674
		bodyDef.type = def.type -- 675
		if def.angle ~= nil then -- 675
			bodyDef.angle = def.angle -- 676
		end -- 676
		if def.angularDamping ~= nil then -- 676
			bodyDef.angularDamping = def.angularDamping -- 677
		end -- 677
		if def.bullet ~= nil then -- 677
			bodyDef.bullet = def.bullet -- 678
		end -- 678
		if def.fixedRotation ~= nil then -- 678
			bodyDef.fixedRotation = def.fixedRotation -- 679
		end -- 679
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 680
		if def.linearDamping ~= nil then -- 680
			bodyDef.linearDamping = def.linearDamping -- 681
		end -- 681
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 682
		local extraSensors -- 683
		for i = 1, #enode.children do -- 683
			do -- 683
				local child = enode.children[i] -- 685
				if type(child) ~= "table" then -- 685
					goto __continue141 -- 687
				end -- 687
				repeat -- 687
					local ____switch143 = child.type -- 687
					local ____cond143 = ____switch143 == "rect-fixture" -- 687
					if ____cond143 then -- 687
						do -- 687
							local shape = child.props -- 691
							if shape.sensorTag ~= nil then -- 691
								bodyDef:attachPolygonSensor( -- 693
									shape.sensorTag, -- 694
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 695
									shape.width, -- 696
									shape.height, -- 696
									shape.angle or 0 -- 697
								) -- 697
							else -- 697
								bodyDef:attachPolygon( -- 700
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 701
									shape.width, -- 702
									shape.height, -- 702
									shape.angle or 0, -- 703
									shape.density or 1, -- 704
									shape.friction or 0.4, -- 705
									shape.restitution or 0 -- 706
								) -- 706
							end -- 706
							break -- 709
						end -- 709
					end -- 709
					____cond143 = ____cond143 or ____switch143 == "polygon-fixture" -- 709
					if ____cond143 then -- 709
						do -- 709
							local shape = child.props -- 712
							if shape.sensorTag ~= nil then -- 712
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 714
							else -- 714
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 719
							end -- 719
							break -- 726
						end -- 726
					end -- 726
					____cond143 = ____cond143 or ____switch143 == "multi-fixture" -- 726
					if ____cond143 then -- 726
						do -- 726
							local shape = child.props -- 729
							if shape.sensorTag ~= nil then -- 729
								if extraSensors == nil then -- 729
									extraSensors = {} -- 731
								end -- 731
								extraSensors[#extraSensors + 1] = { -- 732
									shape.sensorTag, -- 732
									Dora.BodyDef:multi(shape.verts) -- 732
								} -- 732
							else -- 732
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 734
							end -- 734
							break -- 741
						end -- 741
					end -- 741
					____cond143 = ____cond143 or ____switch143 == "disk-fixture" -- 741
					if ____cond143 then -- 741
						do -- 741
							local shape = child.props -- 744
							if shape.sensorTag ~= nil then -- 744
								bodyDef:attachDiskSensor( -- 746
									shape.sensorTag, -- 747
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 748
									shape.radius -- 749
								) -- 749
							else -- 749
								bodyDef:attachDisk( -- 752
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 753
									shape.radius, -- 754
									shape.density or 1, -- 755
									shape.friction or 0.4, -- 756
									shape.restitution or 0 -- 757
								) -- 757
							end -- 757
							break -- 760
						end -- 760
					end -- 760
					____cond143 = ____cond143 or ____switch143 == "chain-fixture" -- 760
					if ____cond143 then -- 760
						do -- 760
							local shape = child.props -- 763
							if shape.sensorTag ~= nil then -- 763
								if extraSensors == nil then -- 763
									extraSensors = {} -- 765
								end -- 765
								extraSensors[#extraSensors + 1] = { -- 766
									shape.sensorTag, -- 766
									Dora.BodyDef:chain(shape.verts) -- 766
								} -- 766
							else -- 766
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 768
							end -- 768
							break -- 774
						end -- 774
					end -- 774
				until true -- 774
			end -- 774
			::__continue141:: -- 774
		end -- 774
		local body = Dora.Body(bodyDef, world) -- 778
		if extraSensors ~= nil then -- 778
			for i = 1, #extraSensors do -- 778
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 781
				body:attachSensor(tag, def) -- 782
			end -- 782
		end -- 782
		local cnode = getNode(enode, body, handleBodyAttribute) -- 785
		return cnode -- 786
	end -- 672
end -- 672
local getCustomNode -- 790
do -- 790
	local function handleCustomNode(_cnode, _enode, k, _v) -- 792
		repeat -- 792
			local ____switch163 = k -- 792
			local ____cond163 = ____switch163 == "onCreate" -- 792
			if ____cond163 then -- 792
				return true -- 794
			end -- 794
		until true -- 794
		return false -- 796
	end -- 792
	getCustomNode = function(enode) -- 798
		local custom = enode.props -- 799
		local node = custom.onCreate() -- 800
		if node then -- 800
			local cnode = getNode(enode, node, handleCustomNode) -- 802
			return cnode -- 803
		end -- 803
		return nil -- 805
	end -- 798
end -- 798
local getAlignNode -- 809
do -- 809
	local function handleAlignNode(_cnode, _enode, k, _v) -- 811
		repeat -- 811
			local ____switch168 = k -- 811
			local ____cond168 = ____switch168 == "windowRoot" -- 811
			if ____cond168 then -- 811
				return true -- 813
			end -- 813
			____cond168 = ____cond168 or ____switch168 == "style" -- 813
			if ____cond168 then -- 813
				return true -- 814
			end -- 814
			____cond168 = ____cond168 or ____switch168 == "onLayout" -- 814
			if ____cond168 then -- 814
				return true -- 815
			end -- 815
		until true -- 815
		return false -- 817
	end -- 811
	getAlignNode = function(enode) -- 819
		local alignNode = enode.props -- 820
		local node = Dora.AlignNode(alignNode.windowRoot) -- 821
		if alignNode.style then -- 821
			node:css(getAlignStyleText(alignNode.style)) -- 823
		end -- 823
		if alignNode.onLayout then -- 823
			node:slot("AlignLayout", alignNode.onLayout) -- 826
		end -- 826
		local cnode = getNode(enode, node, handleAlignNode) -- 828
		return cnode -- 829
	end -- 819
end -- 819
local function getEffekNode(enode) -- 833
	return getNode( -- 834
		enode, -- 834
		Dora.EffekNode() -- 834
	) -- 834
end -- 833
local getTileNode -- 837
do -- 837
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 839
		repeat -- 839
			local ____switch175 = k -- 839
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 839
			if ____cond175 then -- 839
				return true -- 841
			end -- 841
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 841
			if ____cond175 then -- 841
				cnode.depthWrite = v -- 842
				return true -- 842
			end -- 842
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 842
			if ____cond175 then -- 842
				cnode.blendFunc = v -- 843
				return true -- 843
			end -- 843
			____cond175 = ____cond175 or ____switch175 == "effect" -- 843
			if ____cond175 then -- 843
				cnode.effect = v -- 844
				return true -- 844
			end -- 844
			____cond175 = ____cond175 or ____switch175 == "filter" -- 844
			if ____cond175 then -- 844
				cnode.filter = v -- 845
				return true -- 845
			end -- 845
		until true -- 845
		return false -- 847
	end -- 839
	getTileNode = function(enode) -- 849
		local tn = enode.props -- 850
		local ____tn_layers_14 -- 851
		if tn.layers then -- 851
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 851
		else -- 851
			____tn_layers_14 = Dora.TileNode(tn.file) -- 851
		end -- 851
		local node = ____tn_layers_14 -- 851
		if node ~= nil then -- 851
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 853
			return cnode -- 854
		end -- 854
		return nil -- 856
	end -- 849
end -- 849
local function addChild(nodeStack, cnode, enode) -- 860
	if #nodeStack > 0 then -- 860
		local last = nodeStack[#nodeStack] -- 862
		last:addChild(cnode) -- 863
	end -- 863
	nodeStack[#nodeStack + 1] = cnode -- 865
	local ____enode_15 = enode -- 866
	local children = ____enode_15.children -- 866
	for i = 1, #children do -- 866
		visitNode(nodeStack, children[i], enode) -- 868
	end -- 868
	if #nodeStack > 1 then -- 868
		table.remove(nodeStack) -- 871
	end -- 871
end -- 860
local function drawNodeCheck(_nodeStack, enode, parent) -- 879
	if parent == nil or parent.type ~= "draw-node" then -- 879
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 881
	end -- 881
end -- 879
local function actionCheck(nodeStack, enode, parent) -- 942
	local unsupported = false -- 943
	if parent == nil then -- 943
		unsupported = true -- 945
	else -- 945
		repeat -- 945
			local ____switch200 = parent.type -- 945
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 945
			if ____cond200 then -- 945
				break -- 948
			end -- 948
			do -- 948
				unsupported = true -- 949
				break -- 949
			end -- 949
		until true -- 949
	end -- 949
	if unsupported then -- 949
		if #nodeStack > 0 then -- 949
			local node = nodeStack[#nodeStack] -- 954
			local actionStack = {} -- 955
			visitAction(actionStack, enode) -- 956
			if #actionStack == 1 then -- 956
				node:runAction(actionStack[1]) -- 958
			end -- 958
		else -- 958
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 961
		end -- 961
	end -- 961
end -- 942
local function bodyCheck(_nodeStack, enode, parent) -- 966
	if parent == nil or parent.type ~= "body" then -- 966
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 968
	end -- 968
end -- 966
actionMap = { -- 972
	["anchor-x"] = Dora.AnchorX, -- 975
	["anchor-y"] = Dora.AnchorY, -- 976
	angle = Dora.Angle, -- 977
	["angle-x"] = Dora.AngleX, -- 978
	["angle-y"] = Dora.AngleY, -- 979
	width = Dora.Width, -- 980
	height = Dora.Height, -- 981
	opacity = Dora.Opacity, -- 982
	roll = Dora.Roll, -- 983
	scale = Dora.Scale, -- 984
	["scale-x"] = Dora.ScaleX, -- 985
	["scale-y"] = Dora.ScaleY, -- 986
	["skew-x"] = Dora.SkewX, -- 987
	["skew-y"] = Dora.SkewY, -- 988
	["move-x"] = Dora.X, -- 989
	["move-y"] = Dora.Y, -- 990
	["move-z"] = Dora.Z -- 991
} -- 991
elementMap = { -- 994
	node = function(nodeStack, enode, parent) -- 995
		addChild( -- 996
			nodeStack, -- 996
			getNode(enode), -- 996
			enode -- 996
		) -- 996
	end, -- 995
	["clip-node"] = function(nodeStack, enode, parent) -- 998
		addChild( -- 999
			nodeStack, -- 999
			getClipNode(enode), -- 999
			enode -- 999
		) -- 999
	end, -- 998
	playable = function(nodeStack, enode, parent) -- 1001
		local cnode = getPlayable(enode) -- 1002
		if cnode ~= nil then -- 1002
			addChild(nodeStack, cnode, enode) -- 1004
		end -- 1004
	end, -- 1001
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1007
		local cnode = getDragonBone(enode) -- 1008
		if cnode ~= nil then -- 1008
			addChild(nodeStack, cnode, enode) -- 1010
		end -- 1010
	end, -- 1007
	spine = function(nodeStack, enode, parent) -- 1013
		local cnode = getSpine(enode) -- 1014
		if cnode ~= nil then -- 1014
			addChild(nodeStack, cnode, enode) -- 1016
		end -- 1016
	end, -- 1013
	model = function(nodeStack, enode, parent) -- 1019
		local cnode = getModel(enode) -- 1020
		if cnode ~= nil then -- 1020
			addChild(nodeStack, cnode, enode) -- 1022
		end -- 1022
	end, -- 1019
	["draw-node"] = function(nodeStack, enode, parent) -- 1025
		addChild( -- 1026
			nodeStack, -- 1026
			getDrawNode(enode), -- 1026
			enode -- 1026
		) -- 1026
	end, -- 1025
	["dot-shape"] = drawNodeCheck, -- 1028
	["segment-shape"] = drawNodeCheck, -- 1029
	["rect-shape"] = drawNodeCheck, -- 1030
	["polygon-shape"] = drawNodeCheck, -- 1031
	["verts-shape"] = drawNodeCheck, -- 1032
	grid = function(nodeStack, enode, parent) -- 1033
		addChild( -- 1034
			nodeStack, -- 1034
			getGrid(enode), -- 1034
			enode -- 1034
		) -- 1034
	end, -- 1033
	sprite = function(nodeStack, enode, parent) -- 1036
		local cnode = getSprite(enode) -- 1037
		if cnode ~= nil then -- 1037
			addChild(nodeStack, cnode, enode) -- 1039
		end -- 1039
	end, -- 1036
	["audio-source"] = function(nodeStack, enode, parent) -- 1042
		local cnode = getAudioSource(enode) -- 1043
		if cnode ~= nil then -- 1043
			addChild(nodeStack, cnode, enode) -- 1045
		end -- 1045
	end, -- 1042
	["video-node"] = function(nodeStack, enode, parent) -- 1048
		local cnode = getVideoNode(enode) -- 1049
		if cnode ~= nil then -- 1049
			addChild(nodeStack, cnode, enode) -- 1051
		end -- 1051
	end, -- 1048
	["tic80-node"] = function(nodeStack, enode, parent) -- 1054
		local cnode = getTIC80Node(enode) -- 1055
		if cnode ~= nil then -- 1055
			addChild(nodeStack, cnode, enode) -- 1057
		end -- 1057
	end, -- 1054
	label = function(nodeStack, enode, parent) -- 1060
		local cnode = getLabel(enode) -- 1061
		if cnode ~= nil then -- 1061
			addChild(nodeStack, cnode, enode) -- 1063
		end -- 1063
	end, -- 1060
	line = function(nodeStack, enode, parent) -- 1066
		addChild( -- 1067
			nodeStack, -- 1067
			getLine(enode), -- 1067
			enode -- 1067
		) -- 1067
	end, -- 1066
	particle = function(nodeStack, enode, parent) -- 1069
		local cnode = getParticle(enode) -- 1070
		if cnode ~= nil then -- 1070
			addChild(nodeStack, cnode, enode) -- 1072
		end -- 1072
	end, -- 1069
	menu = function(nodeStack, enode, parent) -- 1075
		addChild( -- 1076
			nodeStack, -- 1076
			getMenu(enode), -- 1076
			enode -- 1076
		) -- 1076
	end, -- 1075
	action = function(_nodeStack, enode, parent) -- 1078
		if #enode.children == 0 then -- 1078
			Warn("<action> tag has no children") -- 1080
			return -- 1081
		end -- 1081
		local action = enode.props -- 1083
		if action.ref == nil then -- 1083
			Warn("<action> tag has no ref") -- 1085
			return -- 1086
		end -- 1086
		local actionStack = {} -- 1088
		for i = 1, #enode.children do -- 1088
			visitAction(actionStack, enode.children[i]) -- 1090
		end -- 1090
		if #actionStack == 1 then -- 1090
			action.ref.current = actionStack[1] -- 1093
		elseif #actionStack > 1 then -- 1093
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1095
		end -- 1095
	end, -- 1078
	["anchor-x"] = actionCheck, -- 1098
	["anchor-y"] = actionCheck, -- 1099
	angle = actionCheck, -- 1100
	["angle-x"] = actionCheck, -- 1101
	["angle-y"] = actionCheck, -- 1102
	delay = actionCheck, -- 1103
	event = actionCheck, -- 1104
	width = actionCheck, -- 1105
	height = actionCheck, -- 1106
	hide = actionCheck, -- 1107
	show = actionCheck, -- 1108
	move = actionCheck, -- 1109
	opacity = actionCheck, -- 1110
	roll = actionCheck, -- 1111
	scale = actionCheck, -- 1112
	["scale-x"] = actionCheck, -- 1113
	["scale-y"] = actionCheck, -- 1114
	["skew-x"] = actionCheck, -- 1115
	["skew-y"] = actionCheck, -- 1116
	["move-x"] = actionCheck, -- 1117
	["move-y"] = actionCheck, -- 1118
	["move-z"] = actionCheck, -- 1119
	frame = actionCheck, -- 1120
	spawn = actionCheck, -- 1121
	sequence = actionCheck, -- 1122
	loop = function(nodeStack, enode, _parent) -- 1123
		if #nodeStack > 0 then -- 1123
			local node = nodeStack[#nodeStack] -- 1125
			local actionStack = {} -- 1126
			for i = 1, #enode.children do -- 1126
				visitAction(actionStack, enode.children[i]) -- 1128
			end -- 1128
			if #actionStack == 1 then -- 1128
				node:runAction(actionStack[1], true) -- 1131
			else -- 1131
				local loop = enode.props -- 1133
				if loop.spawn then -- 1133
					node:runAction( -- 1135
						Dora.Spawn(table.unpack(actionStack)), -- 1135
						true -- 1135
					) -- 1135
				else -- 1135
					node:runAction( -- 1137
						Dora.Sequence(table.unpack(actionStack)), -- 1137
						true -- 1137
					) -- 1137
				end -- 1137
			end -- 1137
		else -- 1137
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1141
		end -- 1141
	end, -- 1123
	["physics-world"] = function(nodeStack, enode, _parent) -- 1144
		addChild( -- 1145
			nodeStack, -- 1145
			getPhysicsWorld(enode), -- 1145
			enode -- 1145
		) -- 1145
	end, -- 1144
	contact = function(nodeStack, enode, _parent) -- 1147
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1148
		if world ~= nil then -- 1148
			local contact = enode.props -- 1150
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1151
		else -- 1151
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1153
		end -- 1153
	end, -- 1147
	body = function(nodeStack, enode, _parent) -- 1156
		local def = enode.props -- 1157
		if def.world then -- 1157
			addChild( -- 1159
				nodeStack, -- 1159
				getBody(enode, def.world), -- 1159
				enode -- 1159
			) -- 1159
			return -- 1160
		end -- 1160
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1162
		if world ~= nil then -- 1162
			addChild( -- 1164
				nodeStack, -- 1164
				getBody(enode, world), -- 1164
				enode -- 1164
			) -- 1164
		else -- 1164
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1166
		end -- 1166
	end, -- 1156
	["rect-fixture"] = bodyCheck, -- 1169
	["polygon-fixture"] = bodyCheck, -- 1170
	["multi-fixture"] = bodyCheck, -- 1171
	["disk-fixture"] = bodyCheck, -- 1172
	["chain-fixture"] = bodyCheck, -- 1173
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1174
		local joint = enode.props -- 1175
		if joint.ref == nil then -- 1175
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1177
			return -- 1178
		end -- 1178
		if joint.bodyA.current == nil then -- 1178
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1181
			return -- 1182
		end -- 1182
		if joint.bodyB.current == nil then -- 1182
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1185
			return -- 1186
		end -- 1186
		local ____joint_ref_19 = joint.ref -- 1188
		local ____self_17 = Dora.Joint -- 1188
		local ____self_17_distance_18 = ____self_17.distance -- 1188
		local ____joint_canCollide_16 = joint.canCollide -- 1189
		if ____joint_canCollide_16 == nil then -- 1189
			____joint_canCollide_16 = false -- 1189
		end -- 1189
		____joint_ref_19.current = ____self_17_distance_18( -- 1188
			____self_17, -- 1188
			____joint_canCollide_16, -- 1189
			joint.bodyA.current, -- 1190
			joint.bodyB.current, -- 1191
			joint.anchorA or Dora.Vec2.zero, -- 1192
			joint.anchorB or Dora.Vec2.zero, -- 1193
			joint.frequency or 0, -- 1194
			joint.damping or 0 -- 1195
		) -- 1195
	end, -- 1174
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1197
		local joint = enode.props -- 1198
		if joint.ref == nil then -- 1198
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1200
			return -- 1201
		end -- 1201
		if joint.bodyA.current == nil then -- 1201
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1204
			return -- 1205
		end -- 1205
		if joint.bodyB.current == nil then -- 1205
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1208
			return -- 1209
		end -- 1209
		local ____joint_ref_23 = joint.ref -- 1211
		local ____self_21 = Dora.Joint -- 1211
		local ____self_21_friction_22 = ____self_21.friction -- 1211
		local ____joint_canCollide_20 = joint.canCollide -- 1212
		if ____joint_canCollide_20 == nil then -- 1212
			____joint_canCollide_20 = false -- 1212
		end -- 1212
		____joint_ref_23.current = ____self_21_friction_22( -- 1211
			____self_21, -- 1211
			____joint_canCollide_20, -- 1212
			joint.bodyA.current, -- 1213
			joint.bodyB.current, -- 1214
			joint.worldPos, -- 1215
			joint.maxForce, -- 1216
			joint.maxTorque -- 1217
		) -- 1217
	end, -- 1197
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1220
		local joint = enode.props -- 1221
		if joint.ref == nil then -- 1221
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1223
			return -- 1224
		end -- 1224
		if joint.jointA.current == nil then -- 1224
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1227
			return -- 1228
		end -- 1228
		if joint.jointB.current == nil then -- 1228
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1231
			return -- 1232
		end -- 1232
		local ____joint_ref_27 = joint.ref -- 1234
		local ____self_25 = Dora.Joint -- 1234
		local ____self_25_gear_26 = ____self_25.gear -- 1234
		local ____joint_canCollide_24 = joint.canCollide -- 1235
		if ____joint_canCollide_24 == nil then -- 1235
			____joint_canCollide_24 = false -- 1235
		end -- 1235
		____joint_ref_27.current = ____self_25_gear_26( -- 1234
			____self_25, -- 1234
			____joint_canCollide_24, -- 1235
			joint.jointA.current, -- 1236
			joint.jointB.current, -- 1237
			joint.ratio or 1 -- 1238
		) -- 1238
	end, -- 1220
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1241
		local joint = enode.props -- 1242
		if joint.ref == nil then -- 1242
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1244
			return -- 1245
		end -- 1245
		if joint.bodyA.current == nil then -- 1245
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1248
			return -- 1249
		end -- 1249
		if joint.bodyB.current == nil then -- 1249
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1252
			return -- 1253
		end -- 1253
		local ____joint_ref_31 = joint.ref -- 1255
		local ____self_29 = Dora.Joint -- 1255
		local ____self_29_spring_30 = ____self_29.spring -- 1255
		local ____joint_canCollide_28 = joint.canCollide -- 1256
		if ____joint_canCollide_28 == nil then -- 1256
			____joint_canCollide_28 = false -- 1256
		end -- 1256
		____joint_ref_31.current = ____self_29_spring_30( -- 1255
			____self_29, -- 1255
			____joint_canCollide_28, -- 1256
			joint.bodyA.current, -- 1257
			joint.bodyB.current, -- 1258
			joint.linearOffset, -- 1259
			joint.angularOffset, -- 1260
			joint.maxForce, -- 1261
			joint.maxTorque, -- 1262
			joint.correctionFactor or 1 -- 1263
		) -- 1263
	end, -- 1241
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1266
		local joint = enode.props -- 1267
		if joint.ref == nil then -- 1267
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1269
			return -- 1270
		end -- 1270
		if joint.body.current == nil then -- 1270
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1273
			return -- 1274
		end -- 1274
		local ____joint_ref_35 = joint.ref -- 1276
		local ____self_33 = Dora.Joint -- 1276
		local ____self_33_move_34 = ____self_33.move -- 1276
		local ____joint_canCollide_32 = joint.canCollide -- 1277
		if ____joint_canCollide_32 == nil then -- 1277
			____joint_canCollide_32 = false -- 1277
		end -- 1277
		____joint_ref_35.current = ____self_33_move_34( -- 1276
			____self_33, -- 1276
			____joint_canCollide_32, -- 1277
			joint.body.current, -- 1278
			joint.targetPos, -- 1279
			joint.maxForce, -- 1280
			joint.frequency, -- 1281
			joint.damping or 0.7 -- 1282
		) -- 1282
	end, -- 1266
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1285
		local joint = enode.props -- 1286
		if joint.ref == nil then -- 1286
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1288
			return -- 1289
		end -- 1289
		if joint.bodyA.current == nil then -- 1289
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1292
			return -- 1293
		end -- 1293
		if joint.bodyB.current == nil then -- 1293
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1296
			return -- 1297
		end -- 1297
		local ____joint_ref_39 = joint.ref -- 1299
		local ____self_37 = Dora.Joint -- 1299
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1299
		local ____joint_canCollide_36 = joint.canCollide -- 1300
		if ____joint_canCollide_36 == nil then -- 1300
			____joint_canCollide_36 = false -- 1300
		end -- 1300
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1299
			____self_37, -- 1299
			____joint_canCollide_36, -- 1300
			joint.bodyA.current, -- 1301
			joint.bodyB.current, -- 1302
			joint.worldPos, -- 1303
			joint.axisAngle, -- 1304
			joint.lowerTranslation or 0, -- 1305
			joint.upperTranslation or 0, -- 1306
			joint.maxMotorForce or 0, -- 1307
			joint.motorSpeed or 0 -- 1308
		) -- 1308
	end, -- 1285
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1311
		local joint = enode.props -- 1312
		if joint.ref == nil then -- 1312
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1314
			return -- 1315
		end -- 1315
		if joint.bodyA.current == nil then -- 1315
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1318
			return -- 1319
		end -- 1319
		if joint.bodyB.current == nil then -- 1319
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1322
			return -- 1323
		end -- 1323
		local ____joint_ref_43 = joint.ref -- 1325
		local ____self_41 = Dora.Joint -- 1325
		local ____self_41_pulley_42 = ____self_41.pulley -- 1325
		local ____joint_canCollide_40 = joint.canCollide -- 1326
		if ____joint_canCollide_40 == nil then -- 1326
			____joint_canCollide_40 = false -- 1326
		end -- 1326
		____joint_ref_43.current = ____self_41_pulley_42( -- 1325
			____self_41, -- 1325
			____joint_canCollide_40, -- 1326
			joint.bodyA.current, -- 1327
			joint.bodyB.current, -- 1328
			joint.anchorA or Dora.Vec2.zero, -- 1329
			joint.anchorB or Dora.Vec2.zero, -- 1330
			joint.groundAnchorA, -- 1331
			joint.groundAnchorB, -- 1332
			joint.ratio or 1 -- 1333
		) -- 1333
	end, -- 1311
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1336
		local joint = enode.props -- 1337
		if joint.ref == nil then -- 1337
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1339
			return -- 1340
		end -- 1340
		if joint.bodyA.current == nil then -- 1340
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1343
			return -- 1344
		end -- 1344
		if joint.bodyB.current == nil then -- 1344
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1347
			return -- 1348
		end -- 1348
		local ____joint_ref_47 = joint.ref -- 1350
		local ____self_45 = Dora.Joint -- 1350
		local ____self_45_revolute_46 = ____self_45.revolute -- 1350
		local ____joint_canCollide_44 = joint.canCollide -- 1351
		if ____joint_canCollide_44 == nil then -- 1351
			____joint_canCollide_44 = false -- 1351
		end -- 1351
		____joint_ref_47.current = ____self_45_revolute_46( -- 1350
			____self_45, -- 1350
			____joint_canCollide_44, -- 1351
			joint.bodyA.current, -- 1352
			joint.bodyB.current, -- 1353
			joint.worldPos, -- 1354
			joint.lowerAngle or 0, -- 1355
			joint.upperAngle or 0, -- 1356
			joint.maxMotorTorque or 0, -- 1357
			joint.motorSpeed or 0 -- 1358
		) -- 1358
	end, -- 1336
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1361
		local joint = enode.props -- 1362
		if joint.ref == nil then -- 1362
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1364
			return -- 1365
		end -- 1365
		if joint.bodyA.current == nil then -- 1365
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1368
			return -- 1369
		end -- 1369
		if joint.bodyB.current == nil then -- 1369
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1372
			return -- 1373
		end -- 1373
		local ____joint_ref_51 = joint.ref -- 1375
		local ____self_49 = Dora.Joint -- 1375
		local ____self_49_rope_50 = ____self_49.rope -- 1375
		local ____joint_canCollide_48 = joint.canCollide -- 1376
		if ____joint_canCollide_48 == nil then -- 1376
			____joint_canCollide_48 = false -- 1376
		end -- 1376
		____joint_ref_51.current = ____self_49_rope_50( -- 1375
			____self_49, -- 1375
			____joint_canCollide_48, -- 1376
			joint.bodyA.current, -- 1377
			joint.bodyB.current, -- 1378
			joint.anchorA or Dora.Vec2.zero, -- 1379
			joint.anchorB or Dora.Vec2.zero, -- 1380
			joint.maxLength or 0 -- 1381
		) -- 1381
	end, -- 1361
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1384
		local joint = enode.props -- 1385
		if joint.ref == nil then -- 1385
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1387
			return -- 1388
		end -- 1388
		if joint.bodyA.current == nil then -- 1388
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1391
			return -- 1392
		end -- 1392
		if joint.bodyB.current == nil then -- 1392
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1395
			return -- 1396
		end -- 1396
		local ____joint_ref_55 = joint.ref -- 1398
		local ____self_53 = Dora.Joint -- 1398
		local ____self_53_weld_54 = ____self_53.weld -- 1398
		local ____joint_canCollide_52 = joint.canCollide -- 1399
		if ____joint_canCollide_52 == nil then -- 1399
			____joint_canCollide_52 = false -- 1399
		end -- 1399
		____joint_ref_55.current = ____self_53_weld_54( -- 1398
			____self_53, -- 1398
			____joint_canCollide_52, -- 1399
			joint.bodyA.current, -- 1400
			joint.bodyB.current, -- 1401
			joint.worldPos, -- 1402
			joint.frequency or 0, -- 1403
			joint.damping or 0 -- 1404
		) -- 1404
	end, -- 1384
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1407
		local joint = enode.props -- 1408
		if joint.ref == nil then -- 1408
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1410
			return -- 1411
		end -- 1411
		if joint.bodyA.current == nil then -- 1411
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1414
			return -- 1415
		end -- 1415
		if joint.bodyB.current == nil then -- 1415
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1418
			return -- 1419
		end -- 1419
		local ____joint_ref_59 = joint.ref -- 1421
		local ____self_57 = Dora.Joint -- 1421
		local ____self_57_wheel_58 = ____self_57.wheel -- 1421
		local ____joint_canCollide_56 = joint.canCollide -- 1422
		if ____joint_canCollide_56 == nil then -- 1422
			____joint_canCollide_56 = false -- 1422
		end -- 1422
		____joint_ref_59.current = ____self_57_wheel_58( -- 1421
			____self_57, -- 1421
			____joint_canCollide_56, -- 1422
			joint.bodyA.current, -- 1423
			joint.bodyB.current, -- 1424
			joint.worldPos, -- 1425
			joint.axisAngle, -- 1426
			joint.maxMotorTorque or 0, -- 1427
			joint.motorSpeed or 0, -- 1428
			joint.frequency or 0, -- 1429
			joint.damping or 0.7 -- 1430
		) -- 1430
	end, -- 1407
	["custom-node"] = function(nodeStack, enode, _parent) -- 1433
		local node = getCustomNode(enode) -- 1434
		if node ~= nil then -- 1434
			addChild(nodeStack, node, enode) -- 1436
		end -- 1436
	end, -- 1433
	["custom-element"] = function() -- 1439
	end, -- 1439
	["align-node"] = function(nodeStack, enode, _parent) -- 1440
		addChild( -- 1441
			nodeStack, -- 1441
			getAlignNode(enode), -- 1441
			enode -- 1441
		) -- 1441
	end, -- 1440
	["effek-node"] = function(nodeStack, enode, _parent) -- 1443
		addChild( -- 1444
			nodeStack, -- 1444
			getEffekNode(enode), -- 1444
			enode -- 1444
		) -- 1444
	end, -- 1443
	effek = function(nodeStack, enode, parent) -- 1446
		if #nodeStack > 0 then -- 1446
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1448
			if node then -- 1448
				local effek = enode.props -- 1450
				local handle = node:play( -- 1451
					effek.file, -- 1451
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1451
					effek.z or 0 -- 1451
				) -- 1451
				if handle >= 0 then -- 1451
					if effek.ref then -- 1451
						effek.ref.current = handle -- 1454
					end -- 1454
					if effek.onEnd then -- 1454
						local onEnd = effek.onEnd -- 1454
						node:slot( -- 1458
							"EffekEnd", -- 1458
							function(h) -- 1458
								if handle == h then -- 1458
									onEnd(nil) -- 1460
								end -- 1460
							end -- 1458
						) -- 1458
					end -- 1458
				end -- 1458
			else -- 1458
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1466
			end -- 1466
		end -- 1466
	end, -- 1446
	["tile-node"] = function(nodeStack, enode, parent) -- 1470
		local cnode = getTileNode(enode) -- 1471
		if cnode ~= nil then -- 1471
			addChild(nodeStack, cnode, enode) -- 1473
		end -- 1473
	end -- 1470
} -- 1470
local roots = {} -- 1526
local renderQueued = false -- 1527
local queuedRoots = {} -- 1528
local trackingRoot -- 1529
local function isElementList(node) -- 1533
	return node.type == nil -- 1534
end -- 1533
local function getRenderableElement(renderable) -- 1542
	if type(renderable) == "function" then -- 1542
		return renderable() -- 1544
	end -- 1544
	return renderable -- 1546
end -- 1542
local function removeRoot(root) -- 1787
	for i = 1, #roots do -- 1787
		if roots[i] == root then -- 1787
			table.remove(roots, i) -- 1790
			break -- 1791
		end -- 1791
	end -- 1791
end -- 1787
local function toElementList(node) -- 2313
	if isElementList(node) then -- 2313
		return node -- 2315
	end -- 2315
	return {node} -- 2317
end -- 2313
local function scheduleRootRender(root) -- 2320
	if not root.active then -- 2320
		return -- 2321
	end -- 2321
	for i = 1, #queuedRoots do -- 2321
		if queuedRoots[i] == root then -- 2321
			return -- 2323
		end -- 2323
	end -- 2323
	queuedRoots[#queuedRoots + 1] = root -- 2325
	if renderQueued then -- 2325
		return -- 2326
	end -- 2326
	renderQueued = true -- 2327
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2328
		renderQueued = false -- 2329
		local updatingRoots = queuedRoots -- 2330
		queuedRoots = {} -- 2331
		for i = 1, #updatingRoots do -- 2331
			updatingRoots[i]:update() -- 2333
		end -- 2333
	end)) -- 2328
end -- 2320
____exports.Root = __TS__Class() -- 2338
local Root = ____exports.Root -- 2338
Root.name = "Root" -- 2338
function Root.prototype.____constructor(self, parent) -- 2346
	self.parent = parent -- 2346
	self.mounted = {} -- 2339
	self.signals = {} -- 2341
	self.hookFrames = {} -- 2342
	self.hookFrameIndex = 0 -- 2343
	self.active = true -- 2344
end -- 2346
function Root.prototype.render(self, enode) -- 2348
	if not self.active then -- 2348
		roots[#roots + 1] = self -- 2350
		self.active = true -- 2351
	end -- 2351
	self.renderable = enode -- 2353
	self:update() -- 2354
end -- 2348
function Root.prototype.update(self) -- 2357
	if not self.active or self.renderable == nil then -- 2357
		return -- 2358
	end -- 2358
	self:unsubscribeSignals() -- 2359
	local lastTrackingRoot = trackingRoot -- 2360
	local lastRenderingHookRoot = renderingHookRoot -- 2361
	trackingRoot = self -- 2362
	renderingHookRoot = self -- 2363
	local elements -- 2364
	do -- 2364
		local ____try, ____error = pcall(function() -- 2364
			self:beginHookRender() -- 2366
			elements = getRenderableElement(self.renderable) -- 2367
		end) -- 2367
		do -- 2367
			self:finishHookRender() -- 2369
			trackingRoot = lastTrackingRoot -- 2370
			renderingHookRoot = lastRenderingHookRoot -- 2371
		end -- 2371
		if not ____try then -- 2371
			error(____error, 0) -- 2371
		end -- 2371
	end -- 2371
	self.mounted = reconcileChildren( -- 2373
		self.parent, -- 2373
		self.mounted, -- 2373
		toElementList(elements) -- 2373
	) -- 2373
end -- 2357
function Root.prototype.unmount(self) -- 2376
	for i = 1, #self.mounted do -- 2376
		unmountElement(self.mounted[i]) -- 2378
	end -- 2378
	self.mounted = {} -- 2380
	self.renderable = nil -- 2381
	self.hookFrames = {} -- 2382
	self.hookFrameIndex = 0 -- 2383
	self:unsubscribeSignals() -- 2384
	if self.active then -- 2384
		removeRoot(self) -- 2386
		self.active = false -- 2387
	end -- 2387
end -- 2376
function Root.prototype.trackSignal(self, signal) -- 2391
	for i = 1, #self.signals do -- 2391
		if self.signals[i] == signal then -- 2391
			return -- 2393
		end -- 2393
	end -- 2393
	local ____self_signals_70 = self.signals -- 2393
	____self_signals_70[#____self_signals_70 + 1] = signal -- 2395
	signal:addRoot(self) -- 2396
end -- 2391
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2399
	local index = self.hookFrameIndex -- 2400
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2401
	local frame = self.hookFrames[index + 1] -- 2402
	if frame == nil or frame.type ~= ____type or frame.key ~= key then -- 2402
		frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2404
		self.hookFrames[index + 1] = frame -- 2405
	end -- 2405
	frame.hookIndex = 0 -- 2407
	return frame -- 2408
end -- 2399
function Root.prototype.beginHookRender(self) -- 2411
	self.hookFrameIndex = 0 -- 2412
end -- 2411
function Root.prototype.finishHookRender(self) -- 2415
	while #self.hookFrames > self.hookFrameIndex do -- 2415
		table.remove(self.hookFrames) -- 2417
	end -- 2417
end -- 2415
function Root.prototype.unsubscribeSignals(self) -- 2421
	for i = 1, #self.signals do -- 2421
		self.signals[i]:removeRoot(self) -- 2423
	end -- 2423
	self.signals = {} -- 2425
end -- 2421
function ____exports.createRoot(parent) -- 2429
	local root = __TS__New(____exports.Root, parent) -- 2430
	roots[#roots + 1] = root -- 2431
	return root -- 2432
end -- 2429
____exports.Signal = __TS__Class() -- 2435
local Signal = ____exports.Signal -- 2435
Signal.name = "Signal" -- 2435
function Signal.prototype.____constructor(self, item) -- 2438
	self.item = item -- 2438
	self.roots = {} -- 2436
end -- 2438
function Signal.prototype.addRoot(self, root) -- 2455
	for i = 1, #self.roots do -- 2455
		if self.roots[i] == root then -- 2455
			return -- 2457
		end -- 2457
	end -- 2457
	local ____self_roots_71 = self.roots -- 2457
	____self_roots_71[#____self_roots_71 + 1] = root -- 2459
end -- 2455
function Signal.prototype.removeRoot(self, root) -- 2462
	for i = 1, #self.roots do -- 2462
		if self.roots[i] == root then -- 2462
			table.remove(self.roots, i) -- 2465
			break -- 2466
		end -- 2466
	end -- 2466
end -- 2462
__TS__SetDescriptor( -- 2462
	Signal.prototype, -- 2462
	"value", -- 2462
	{ -- 2462
		get = function(self) -- 2462
			if trackingRoot ~= nil then -- 2462
				trackingRoot:trackSignal(self) -- 2442
			end -- 2442
			return self.item -- 2444
		end, -- 2444
		set = function(self, value) -- 2444
			if self.item == value then -- 2444
				return -- 2448
			end -- 2448
			self.item = value -- 2449
			for i = 1, #self.roots do -- 2449
				scheduleRootRender(self.roots[i]) -- 2451
			end -- 2451
		end -- 2451
	}, -- 2451
	true -- 2451
) -- 2451
function ____exports.signal(value) -- 2472
	return __TS__New(____exports.Signal, value) -- 2473
end -- 2472
function ____exports.reference(item) -- 2476
	local ____item_72 = item -- 2477
	if ____item_72 == nil then -- 2477
		____item_72 = nil -- 2477
	end -- 2477
	return {current = ____item_72} -- 2477
end -- 2476
local function hookDepsEqual(oldDeps, newDeps) -- 2480
	if oldDeps == nil or newDeps == nil then -- 2480
		return false -- 2481
	end -- 2481
	if #oldDeps ~= #newDeps then -- 2481
		return false -- 2482
	end -- 2482
	for i = 1, #oldDeps do -- 2482
		if oldDeps[i] ~= newDeps[i] then -- 2482
			return false -- 2484
		end -- 2484
	end -- 2484
	return true -- 2486
end -- 2480
local function copyDeps(deps) -- 2489
	if deps == nil then -- 2489
		return nil -- 2490
	end -- 2490
	local copied = {} -- 2491
	for i = 1, #deps do -- 2491
		copied[#copied + 1] = deps[i] -- 2493
	end -- 2493
	return copied -- 2495
end -- 2489
function ____exports.useMemo(factory, deps) -- 2498
	local frame = currentHookFrame -- 2499
	if frame == nil then -- 2499
		error("useMemo() can only be called inside a function component") -- 2501
	end -- 2501
	local index = frame.hookIndex -- 2503
	frame.hookIndex = frame.hookIndex + 1 -- 2504
	local hook = frame.hooks[index + 1] -- 2505
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2505
		hook = { -- 2507
			value = factory(), -- 2507
			deps = copyDeps(deps) -- 2507
		} -- 2507
		frame.hooks[index + 1] = hook -- 2508
	end -- 2508
	return hook.value -- 2510
end -- 2498
function ____exports.useCallback(callback, deps) -- 2513
	return ____exports.useMemo( -- 2514
		function() return callback end, -- 2514
		deps -- 2514
	) -- 2514
end -- 2513
function ____exports.useRef(item) -- 2517
	if currentHookFrame == nil then -- 2517
		error("useRef() can only be called inside a function component") -- 2519
	end -- 2519
	return ____exports.useMemo( -- 2521
		function() return ____exports.reference(item) end, -- 2521
		{} -- 2521
	) -- 2521
end -- 2517
function ____exports.useSignal(value) -- 2524
	if currentHookFrame == nil then -- 2524
		error("useSignal() can only be called inside a function component") -- 2526
	end -- 2526
	return ____exports.useMemo( -- 2528
		function() return ____exports.signal(value) end, -- 2528
		{} -- 2528
	) -- 2528
end -- 2524
local function getPreload(preloadList, node) -- 2531
	if type(node) ~= "table" then -- 2531
		return -- 2533
	end -- 2533
	local enode = node -- 2535
	if enode.type == nil then -- 2535
		local list = node -- 2537
		if #list > 0 then -- 2537
			for i = 1, #list do -- 2537
				getPreload(preloadList, list[i]) -- 2540
			end -- 2540
		end -- 2540
	else -- 2540
		repeat -- 2540
			local ____switch608 = enode.type -- 2540
			local sprite, playable, frame, model, spine, dragonBone, label -- 2540
			local ____cond608 = ____switch608 == "sprite" -- 2540
			if ____cond608 then -- 2540
				sprite = enode.props -- 2546
				if sprite.file then -- 2546
					preloadList[#preloadList + 1] = sprite.file -- 2548
				end -- 2548
				break -- 2550
			end -- 2550
			____cond608 = ____cond608 or ____switch608 == "playable" -- 2550
			if ____cond608 then -- 2550
				playable = enode.props -- 2552
				preloadList[#preloadList + 1] = playable.file -- 2553
				break -- 2554
			end -- 2554
			____cond608 = ____cond608 or ____switch608 == "frame" -- 2554
			if ____cond608 then -- 2554
				frame = enode.props -- 2556
				preloadList[#preloadList + 1] = frame.file -- 2557
				break -- 2558
			end -- 2558
			____cond608 = ____cond608 or ____switch608 == "model" -- 2558
			if ____cond608 then -- 2558
				model = enode.props -- 2560
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2561
				break -- 2562
			end -- 2562
			____cond608 = ____cond608 or ____switch608 == "spine" -- 2562
			if ____cond608 then -- 2562
				spine = enode.props -- 2564
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2565
				break -- 2566
			end -- 2566
			____cond608 = ____cond608 or ____switch608 == "dragon-bone" -- 2566
			if ____cond608 then -- 2566
				dragonBone = enode.props -- 2568
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2569
				break -- 2570
			end -- 2570
			____cond608 = ____cond608 or ____switch608 == "label" -- 2570
			if ____cond608 then -- 2570
				label = enode.props -- 2572
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2573
				break -- 2574
			end -- 2574
		until true -- 2574
	end -- 2574
	getPreload(preloadList, enode.children) -- 2577
end -- 2531
function ____exports.preloadAsync(enode, handler) -- 2580
	local preloadList = {} -- 2581
	getPreload(preloadList, enode) -- 2582
	Dora.Cache:loadAsync(preloadList, handler) -- 2583
end -- 2580
function ____exports.toAction(enode) -- 2586
	local actionDef = ____exports.reference() -- 2587
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2588
	if not actionDef.current then -- 2588
		error("failed to create action") -- 2589
	end -- 2589
	return actionDef.current -- 2590
end -- 2586
return ____exports -- 2586