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
		node.touchEnabled = true -- 174
	end -- 174
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 174
		node.keyboardEnabled = true -- 181
	end -- 181
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 181
		node.controllerEnabled = true -- 188
	end -- 188
	local body = Dora.tolua.cast(node, "Body") -- 190
	if body ~= nil then -- 190
		local bodyProps = props -- 192
		if bodyProps.receivingContact ~= false and (bodyProps.onContactStart or bodyProps.onContactEnd) then -- 192
			body.receivingContact = true -- 197
		end -- 197
	end -- 197
end -- 197
function visitAction(actionStack, enode) -- 892
	local createAction = actionMap[enode.type] -- 893
	if createAction ~= nil then -- 893
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 895
		return -- 896
	end -- 896
	repeat -- 896
		local ____switch186 = enode.type -- 896
		local ____cond186 = ____switch186 == "delay" -- 896
		if ____cond186 then -- 896
			do -- 896
				local item = enode.props -- 900
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 901
				break -- 902
			end -- 902
		end -- 902
		____cond186 = ____cond186 or ____switch186 == "event" -- 902
		if ____cond186 then -- 902
			do -- 902
				local item = enode.props -- 905
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 906
				break -- 907
			end -- 907
		end -- 907
		____cond186 = ____cond186 or ____switch186 == "hide" -- 907
		if ____cond186 then -- 907
			do -- 907
				actionStack[#actionStack + 1] = Dora.Hide() -- 910
				break -- 911
			end -- 911
		end -- 911
		____cond186 = ____cond186 or ____switch186 == "show" -- 911
		if ____cond186 then -- 911
			do -- 911
				actionStack[#actionStack + 1] = Dora.Show() -- 914
				break -- 915
			end -- 915
		end -- 915
		____cond186 = ____cond186 or ____switch186 == "move" -- 915
		if ____cond186 then -- 915
			do -- 915
				local item = enode.props -- 918
				actionStack[#actionStack + 1] = Dora.Move( -- 919
					item.time, -- 919
					Dora.Vec2(item.startX, item.startY), -- 919
					Dora.Vec2(item.stopX, item.stopY), -- 919
					item.easing -- 919
				) -- 919
				break -- 920
			end -- 920
		end -- 920
		____cond186 = ____cond186 or ____switch186 == "frame" -- 920
		if ____cond186 then -- 920
			do -- 920
				local item = enode.props -- 923
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 924
				break -- 925
			end -- 925
		end -- 925
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 925
		if ____cond186 then -- 925
			do -- 925
				local spawnStack = {} -- 928
				for i = 1, #enode.children do -- 928
					visitAction(spawnStack, enode.children[i]) -- 930
				end -- 930
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 932
				break -- 933
			end -- 933
		end -- 933
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 933
		if ____cond186 then -- 933
			do -- 933
				local sequenceStack = {} -- 936
				for i = 1, #enode.children do -- 936
					visitAction(sequenceStack, enode.children[i]) -- 938
				end -- 938
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 940
				break -- 941
			end -- 941
		end -- 941
		do -- 941
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 944
			break -- 945
		end -- 945
	until true -- 945
end -- 945
function visitNode(nodeStack, node, parent) -- 1484
	if type(node) ~= "table" then -- 1484
		return -- 1486
	end -- 1486
	local enode = node -- 1488
	if enode.type == nil then -- 1488
		local list = node -- 1490
		if #list > 0 then -- 1490
			for i = 1, #list do -- 1490
				local stack = {} -- 1493
				visitNode(stack, list[i], parent) -- 1494
				for i = 1, #stack do -- 1494
					nodeStack[#nodeStack + 1] = stack[i] -- 1496
				end -- 1496
			end -- 1496
		end -- 1496
	else -- 1496
		local handler = elementMap[enode.type] -- 1501
		if handler ~= nil then -- 1501
			handler(nodeStack, enode, parent) -- 1503
		else -- 1503
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1505
		end -- 1505
	end -- 1505
end -- 1505
function ____exports.toNode(enode) -- 1510
	local nodeStack = {} -- 1511
	visitNode(nodeStack, enode) -- 1512
	if #nodeStack == 1 then -- 1512
		return nodeStack[1] -- 1514
	elseif #nodeStack > 1 then -- 1514
		local node = Dora.Node() -- 1516
		for i = 1, #nodeStack do -- 1516
			node:addChild(nodeStack[i]) -- 1518
		end -- 1518
		return node -- 1520
	end -- 1520
	return nil -- 1522
end -- 1510
function getElementKey(element) -- 1545
	local props = element.props -- 1546
	local ____props_60 -- 1547
	if props then -- 1547
		____props_60 = props.key -- 1547
	else -- 1547
		____props_60 = nil -- 1547
	end -- 1547
	return ____props_60 -- 1547
end -- 1547
function getElementTypeName(element) -- 1550
	local elementType = element.type -- 1551
	if type(elementType) == "string" then -- 1551
		return elementType -- 1552
	end -- 1552
	return tostring(elementType) -- 1553
end -- 1553
function warnUnkeyedDynamicChildren(oldChildren, newElements) -- 1556
	if #oldChildren == #newElements then -- 1556
		return -- 1557
	end -- 1557
	local oldTypes = {} -- 1558
	for i = 1, #oldChildren do -- 1558
		local oldElement = oldChildren[i].element -- 1560
		if getElementKey(oldElement) == nil then -- 1560
			oldTypes[getElementTypeName(oldElement)] = true -- 1562
		end -- 1562
	end -- 1562
	for i = 1, #newElements do -- 1562
		do -- 1562
			local newElement = newElements[i] -- 1566
			if getElementKey(newElement) ~= nil then -- 1566
				goto __continue335 -- 1567
			end -- 1567
			local typeName = getElementTypeName(newElement) -- 1568
			if oldTypes[typeName] == true and not warnedUnkeyedChildTypes[typeName] then -- 1568
				warnedUnkeyedChildTypes[typeName] = true -- 1570
				Warn(("dynamic children include unkeyed <" .. typeName) .. "> siblings while child count changed; add stable key props to conditional, inserted, removed or reordered siblings to avoid index-based reuse") -- 1571
			end -- 1571
		end -- 1571
		::__continue335:: -- 1571
	end -- 1571
end -- 1571
function getPrimitiveLabelText(enode) -- 1583
	local label = enode.props -- 1584
	local text = label.text or "" -- 1585
	for i = 1, #enode.children do -- 1585
		local child = enode.children[i] -- 1587
		if type(child) ~= "table" then -- 1587
			text = text .. tostring(child) -- 1589
		end -- 1589
	end -- 1589
	return text -- 1592
end -- 1592
function isDrawShapeElement(element) -- 1595
	repeat -- 1595
		local ____switch344 = element.type -- 1595
		local ____cond344 = ____switch344 == "dot-shape" or ____switch344 == "segment-shape" or ____switch344 == "rect-shape" or ____switch344 == "polygon-shape" or ____switch344 == "verts-shape" -- 1595
		if ____cond344 then -- 1595
			return true -- 1602
		end -- 1602
	until true -- 1602
	return false -- 1604
end -- 1604
function isBodyFixtureElement(element) -- 1607
	repeat -- 1607
		local ____switch346 = element.type -- 1607
		local ____cond346 = ____switch346 == "rect-fixture" or ____switch346 == "polygon-fixture" or ____switch346 == "multi-fixture" or ____switch346 == "disk-fixture" or ____switch346 == "chain-fixture" -- 1607
		if ____cond346 then -- 1607
			return true -- 1614
		end -- 1614
	until true -- 1614
	return false -- 1616
end -- 1616
function isPhysicsWorldInputElement(element) -- 1619
	return element.type == "contact" -- 1620
end -- 1620
function isRunnableActionElement(element) -- 1623
	if element.type == "loop" then -- 1623
		return true -- 1624
	end -- 1624
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1625
end -- 1625
function shallowPropsEqual(oldProps, newProps) -- 1636
	for k, v in pairs(oldProps) do -- 1637
		if k ~= "ref" and newProps[k] ~= v then -- 1637
			return false -- 1638
		end -- 1638
	end -- 1638
	for k, v in pairs(newProps) do -- 1640
		if k ~= "ref" and oldProps[k] ~= v then -- 1640
			return false -- 1641
		end -- 1641
	end -- 1641
	return true -- 1643
end -- 1643
function collectRunnableActionElements(element) -- 1646
	local actions = {} -- 1647
	for i = 1, #element.children do -- 1647
		local child = element.children[i] -- 1649
		if type(child) == "table" and isRunnableActionElement(child) then -- 1649
			actions[#actions + 1] = child -- 1651
		end -- 1651
	end -- 1651
	return actions -- 1654
end -- 1654
function collectContactElements(element) -- 1657
	local contacts = {} -- 1658
	for i = 1, #element.children do -- 1658
		local child = element.children[i] -- 1660
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1660
			contacts[#contacts + 1] = child -- 1662
		end -- 1662
	end -- 1662
	return contacts -- 1665
end -- 1665
function getContactKey(contact) -- 1668
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1669
end -- 1669
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1672
	local oldContacts = collectContactElements(oldElement) -- 1673
	local newContacts = collectContactElements(newElement) -- 1674
	local oldByKey = {} -- 1675
	local newByKey = {} -- 1676
	for i = 1, #oldContacts do -- 1676
		local contact = oldContacts[i].props -- 1678
		oldByKey[getContactKey(contact)] = contact -- 1679
	end -- 1679
	for i = 1, #newContacts do -- 1679
		local contact = newContacts[i].props -- 1682
		newByKey[getContactKey(contact)] = contact -- 1683
	end -- 1683
	for i = 1, #oldContacts do -- 1683
		local oldContact = oldContacts[i].props -- 1686
		local key = getContactKey(oldContact) -- 1687
		local newContact = newByKey[key] -- 1688
		if newContact == nil then -- 1688
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1690
		elseif oldContact.enabled ~= newContact.enabled then -- 1690
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1692
		end -- 1692
	end -- 1692
	for i = 1, #newContacts do -- 1692
		local newContact = newContacts[i].props -- 1696
		if oldByKey[getContactKey(newContact)] == nil then -- 1696
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1698
		end -- 1698
	end -- 1698
end -- 1698
function actionElementEqual(oldElement, newElement) -- 1703
	if oldElement.type ~= newElement.type then -- 1703
		return false -- 1704
	end -- 1704
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1704
		return false -- 1705
	end -- 1705
	if #oldElement.children ~= #newElement.children then -- 1705
		return false -- 1706
	end -- 1706
	for i = 1, #oldElement.children do -- 1706
		local oldChild = oldElement.children[i] -- 1708
		local newChild = newElement.children[i] -- 1709
		if type(oldChild) ~= type(newChild) then -- 1709
			return false -- 1710
		end -- 1710
		if type(oldChild) == "table" then -- 1710
			if not actionElementEqual(oldChild, newChild) then -- 1710
				return false -- 1712
			end -- 1712
		elseif oldChild ~= newChild then -- 1712
			return false -- 1714
		end -- 1714
	end -- 1714
	return true -- 1717
end -- 1717
function actionChildrenEqual(oldElement, newElement) -- 1720
	local oldActions = collectRunnableActionElements(oldElement) -- 1721
	local newActions = collectRunnableActionElements(newElement) -- 1722
	if #oldActions ~= #newActions then -- 1722
		return false -- 1723
	end -- 1723
	for i = 1, #oldActions do -- 1723
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1723
			return false -- 1725
		end -- 1725
	end -- 1725
	return true -- 1727
end -- 1727
function createActionDef(actionElement) -- 1730
	if actionElement.type == "loop" then -- 1730
		local actionStack = {} -- 1732
		for i = 1, #actionElement.children do -- 1732
			visitAction(actionStack, actionElement.children[i]) -- 1734
		end -- 1734
		if #actionStack == 1 then -- 1734
			return actionStack[1], true -- 1737
		elseif #actionStack > 1 then -- 1737
			local loop = actionElement.props -- 1739
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1740
		end -- 1740
		return nil, true -- 1742
	end -- 1742
	local actionStack = {} -- 1744
	visitAction(actionStack, actionElement) -- 1745
	return #actionStack == 1 and actionStack[1] or nil, false -- 1746
end -- 1746
function structuralChildrenEqual(oldElement, newElement, check) -- 1749
	local oldChildren = {} -- 1755
	local newChildren = {} -- 1756
	for i = 1, #oldElement.children do -- 1756
		local child = oldElement.children[i] -- 1758
		if type(child) == "table" and check(child) then -- 1758
			oldChildren[#oldChildren + 1] = child -- 1760
		end -- 1760
	end -- 1760
	for i = 1, #newElement.children do -- 1760
		local child = newElement.children[i] -- 1764
		if type(child) == "table" and check(child) then -- 1764
			newChildren[#newChildren + 1] = child -- 1766
		end -- 1766
	end -- 1766
	if #oldChildren ~= #newChildren then -- 1766
		return false -- 1769
	end -- 1769
	for i = 1, #oldChildren do -- 1769
		local oldChild = oldChildren[i] -- 1771
		local newChild = newChildren[i] -- 1772
		if oldChild.type ~= newChild.type then -- 1772
			return false -- 1773
		end -- 1773
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1773
			return false -- 1774
		end -- 1774
	end -- 1774
	return true -- 1776
end -- 1776
function runActionChildren(node, element) -- 1779
	local actionChildren = collectRunnableActionElements(element) -- 1780
	local exclusiveActions = {} -- 1781
	local exclusiveLoop -- 1782
	local warnedExclusiveConflict = false -- 1783
	for i = 1, #actionChildren do -- 1783
		do -- 1783
			local actionElement = actionChildren[i] -- 1785
			local action, loop = createActionDef(actionElement) -- 1786
			if action == nil then -- 1786
				goto __continue398 -- 1787
			end -- 1787
			if actionElement.props.exclusive == true then -- 1787
				if exclusiveLoop == nil then -- 1787
					exclusiveLoop = loop -- 1790
				end -- 1790
				if exclusiveLoop == loop then -- 1790
					exclusiveActions[#exclusiveActions + 1] = action -- 1793
				elseif not warnedExclusiveConflict then -- 1793
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1795
					warnedExclusiveConflict = true -- 1796
				end -- 1796
			end -- 1796
		end -- 1796
		::__continue398:: -- 1796
	end -- 1796
	if #exclusiveActions == 1 then -- 1796
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1801
	elseif #exclusiveActions > 1 then -- 1801
		node:perform( -- 1803
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1803
			exclusiveLoop == true -- 1803
		) -- 1803
	end -- 1803
	for i = 1, #actionChildren do -- 1803
		do -- 1803
			local actionElement = actionChildren[i] -- 1806
			if actionElement.props.exclusive == true then -- 1806
				goto __continue406 -- 1807
			end -- 1807
			local action, loop = createActionDef(actionElement) -- 1808
			if action ~= nil then -- 1808
				node:runAction(action, loop) -- 1810
			end -- 1810
		end -- 1810
		::__continue406:: -- 1810
	end -- 1810
end -- 1810
function patchActionChildren(node, oldElement, newElement) -- 1815
	if not actionChildrenEqual(oldElement, newElement) then -- 1815
		runActionChildren(node, newElement) -- 1817
	end -- 1817
end -- 1817
function toHostElement(enode, parent) -- 1830
	local hostChildren = {} -- 1831
	local props = {} -- 1832
	if enode.props ~= nil then -- 1832
		for k, v in pairs(enode.props) do -- 1834
			props[k] = v -- 1835
		end -- 1835
	end -- 1835
	if enode.type == "label" then -- 1835
		for i = 1, #enode.children do -- 1835
			local child = enode.children[i] -- 1840
			if type(child) ~= "table" then -- 1840
				hostChildren[#hostChildren + 1] = child -- 1842
			end -- 1842
		end -- 1842
	elseif enode.type == "draw-node" then -- 1842
		for i = 1, #enode.children do -- 1842
			local child = enode.children[i] -- 1847
			if type(child) == "table" and isDrawShapeElement(child) then -- 1847
				hostChildren[#hostChildren + 1] = child -- 1849
			end -- 1849
		end -- 1849
	elseif enode.type == "body" then -- 1849
		for i = 1, #enode.children do -- 1849
			local child = enode.children[i] -- 1854
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1854
				hostChildren[#hostChildren + 1] = child -- 1856
			end -- 1856
		end -- 1856
	elseif enode.type == "physics-world" then -- 1856
		for i = 1, #enode.children do -- 1856
			local child = enode.children[i] -- 1861
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1861
				hostChildren[#hostChildren + 1] = child -- 1863
			end -- 1863
		end -- 1863
	end -- 1863
	if enode.type == "body" and props.world == nil then -- 1863
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1868
		if world ~= nil then -- 1868
			props.world = world -- 1870
		end -- 1870
	end -- 1870
	return {type = enode.type, props = props, children = hostChildren} -- 1873
end -- 1873
function createHostNode(enode, parent) -- 1880
	local nodeStack = {} -- 1881
	visitNode( -- 1882
		nodeStack, -- 1882
		toHostElement(enode, parent) -- 1882
	) -- 1882
	if #nodeStack == 1 then -- 1882
		return nodeStack[1] -- 1884
	elseif #nodeStack > 1 then -- 1884
		local node = Dora.Node() -- 1886
		for i = 1, #nodeStack do -- 1886
			node:addChild(nodeStack[i]) -- 1888
		end -- 1888
		return node -- 1890
	end -- 1890
	return nil -- 1892
end -- 1892
function getElementChildren(enode) -- 1895
	local children = {} -- 1896
	if enode.type == "draw-node" or enode.type == "body" then -- 1896
		return children -- 1897
	end -- 1897
	for i = 1, #enode.children do -- 1897
		local child = enode.children[i] -- 1899
		if type(child) == "table" then -- 1899
			local childElement = child -- 1901
			if childElement.type ~= nil then -- 1901
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1901
					children[#children + 1] = childElement -- 1907
				end -- 1907
			else -- 1907
				local list = child -- 1910
				for j = 1, #list do -- 1910
					local item = list[j] -- 1912
					if type(item) == "table" and item.type ~= nil then -- 1912
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1912
							children[#children + 1] = item -- 1918
						end -- 1918
					end -- 1918
				end -- 1918
			end -- 1918
		end -- 1918
	end -- 1918
	return children -- 1925
end -- 1925
function getRecreateMode(oldElement, newElement) -- 1930
	if oldElement.type ~= newElement.type then -- 1930
		return "subtree" -- 1931
	end -- 1931
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1931
		return "subtree" -- 1932
	end -- 1932
	local oldProps = oldElement.props -- 1933
	local newProps = newElement.props -- 1934
	if newElement.type == "draw-node" then -- 1934
		return "host" -- 1935
	end -- 1935
	for k, v in pairs(oldProps) do -- 1936
		if k == "onMount" and newProps[k] ~= v then -- 1936
			return "host" -- 1938
		end -- 1938
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1938
			return "host" -- 1941
		end -- 1941
	end -- 1941
	for k, v in pairs(newProps) do -- 1944
		if k == "onMount" and oldProps[k] ~= v then -- 1944
			return "host" -- 1946
		end -- 1946
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1946
			return "host" -- 1949
		end -- 1949
	end -- 1949
	repeat -- 1949
		local ____switch455 = newElement.type -- 1949
		local ____cond455 = ____switch455 == "grid" -- 1949
		if ____cond455 then -- 1949
			return (oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY) and "host" or nil -- 1954
		end -- 1954
		____cond455 = ____cond455 or (____switch455 == "sprite" or ____switch455 == "video-node" or ____switch455 == "tic80-node" or ____switch455 == "audio-source" or ____switch455 == "particle" or ____switch455 == "tile-node" or ____switch455 == "playable" or ____switch455 == "dragon-bone" or ____switch455 == "spine" or ____switch455 == "model") -- 1954
		if ____cond455 then -- 1954
			return oldProps.file ~= newProps.file and "host" or nil -- 1965
		end -- 1965
		____cond455 = ____cond455 or ____switch455 == "label" -- 1965
		if ____cond455 then -- 1965
			return (oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf) and "host" or nil -- 1967
		end -- 1967
		____cond455 = ____cond455 or ____switch455 == "align-node" -- 1967
		if ____cond455 then -- 1967
			return oldProps.windowRoot ~= newProps.windowRoot and "host" or nil -- 1969
		end -- 1969
		____cond455 = ____cond455 or ____switch455 == "custom-node" -- 1969
		if ____cond455 then -- 1969
			return oldProps.onCreate ~= newProps.onCreate and "host" or nil -- 1971
		end -- 1971
		____cond455 = ____cond455 or ____switch455 == "body" -- 1971
		if ____cond455 then -- 1971
			return (oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement)) and "host" or nil -- 1973
		end -- 1973
	until true -- 1973
	return nil -- 1980
end -- 1980
function isEventProp(key) -- 1983
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1984
end -- 1984
function getEventSlot(key) -- 1987
	repeat -- 1987
		local ____switch458 = key -- 1987
		local ____cond458 = ____switch458 == "onActionEnd" -- 1987
		if ____cond458 then -- 1987
			return "ActionEnd" -- 1989
		end -- 1989
		____cond458 = ____cond458 or ____switch458 == "onTapFilter" -- 1989
		if ____cond458 then -- 1989
			return "TapFilter" -- 1990
		end -- 1990
		____cond458 = ____cond458 or ____switch458 == "onTapBegan" -- 1990
		if ____cond458 then -- 1990
			return "TapBegan" -- 1991
		end -- 1991
		____cond458 = ____cond458 or ____switch458 == "onTapEnded" -- 1991
		if ____cond458 then -- 1991
			return "TapEnded" -- 1992
		end -- 1992
		____cond458 = ____cond458 or ____switch458 == "onTapped" -- 1992
		if ____cond458 then -- 1992
			return "Tapped" -- 1993
		end -- 1993
		____cond458 = ____cond458 or ____switch458 == "onTapMoved" -- 1993
		if ____cond458 then -- 1993
			return "TapMoved" -- 1994
		end -- 1994
		____cond458 = ____cond458 or ____switch458 == "onMouseMove" -- 1994
		if ____cond458 then -- 1994
			return "MouseMove" -- 1995
		end -- 1995
		____cond458 = ____cond458 or ____switch458 == "onMouseWheel" -- 1994
		if ____cond458 then -- 1994
			return "MouseWheel" -- 1995
		end -- 1995
		____cond458 = ____cond458 or ____switch458 == "onGesture" -- 1995
		if ____cond458 then -- 1995
			return "Gesture" -- 1996
		end -- 1996
		____cond458 = ____cond458 or ____switch458 == "onEnter" -- 1996
		if ____cond458 then -- 1996
			return "Enter" -- 1997
		end -- 1997
		____cond458 = ____cond458 or ____switch458 == "onExit" -- 1997
		if ____cond458 then -- 1997
			return "Exit" -- 1998
		end -- 1998
		____cond458 = ____cond458 or ____switch458 == "onCleanup" -- 1998
		if ____cond458 then -- 1998
			return "Cleanup" -- 1999
		end -- 1999
		____cond458 = ____cond458 or ____switch458 == "onKeyDown" -- 1999
		if ____cond458 then -- 1999
			return "KeyDown" -- 2000
		end -- 2000
		____cond458 = ____cond458 or ____switch458 == "onKeyUp" -- 2000
		if ____cond458 then -- 2000
			return "KeyUp" -- 2001
		end -- 2001
		____cond458 = ____cond458 or ____switch458 == "onKeyPressed" -- 2001
		if ____cond458 then -- 2001
			return "KeyPressed" -- 2002
		end -- 2002
		____cond458 = ____cond458 or ____switch458 == "onAttachIME" -- 2002
		if ____cond458 then -- 2002
			return "AttachIME" -- 2003
		end -- 2003
		____cond458 = ____cond458 or ____switch458 == "onDetachIME" -- 2003
		if ____cond458 then -- 2003
			return "DetachIME" -- 2004
		end -- 2004
		____cond458 = ____cond458 or ____switch458 == "onTextInput" -- 2004
		if ____cond458 then -- 2004
			return "TextInput" -- 2005
		end -- 2005
		____cond458 = ____cond458 or ____switch458 == "onTextEditing" -- 2005
		if ____cond458 then -- 2005
			return "TextEditing" -- 2006
		end -- 2006
		____cond458 = ____cond458 or ____switch458 == "onButtonDown" -- 2006
		if ____cond458 then -- 2006
			return "ButtonDown" -- 2007
		end -- 2007
		____cond458 = ____cond458 or ____switch458 == "onButtonUp" -- 2007
		if ____cond458 then -- 2007
			return "ButtonUp" -- 2008
		end -- 2008
		____cond458 = ____cond458 or ____switch458 == "onAxis" -- 2008
		if ____cond458 then -- 2008
			return "Axis" -- 2009
		end -- 2009
		____cond458 = ____cond458 or ____switch458 == "onAnimationEnd" -- 2009
		if ____cond458 then -- 2009
			return "AnimationEnd" -- 2010
		end -- 2010
		____cond458 = ____cond458 or ____switch458 == "onFinished" -- 2010
		if ____cond458 then -- 2010
			return "Finished" -- 2011
		end -- 2011
		____cond458 = ____cond458 or ____switch458 == "onLayout" -- 2011
		if ____cond458 then -- 2011
			return "AlignLayout" -- 2012
		end -- 2012
		____cond458 = ____cond458 or ____switch458 == "onBodyEnter" -- 2012
		if ____cond458 then -- 2012
			return "BodyEnter" -- 2013
		end -- 2013
		____cond458 = ____cond458 or ____switch458 == "onBodyLeave" -- 2013
		if ____cond458 then -- 2013
			return "BodyLeave" -- 2014
		end -- 2014
		____cond458 = ____cond458 or ____switch458 == "onContactStart" -- 2014
		if ____cond458 then -- 2014
			return "ContactStart" -- 2015
		end -- 2015
		____cond458 = ____cond458 or ____switch458 == "onContactEnd" -- 2015
		if ____cond458 then -- 2015
			return "ContactEnd" -- 2016
		end -- 2016
	until true -- 2016
	return nil -- 2018
end -- 2018
function isPatchableEventProp(key) -- 2021
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 2022
end -- 2022
function patchEventProp(node, key, value) -- 2025
	local slotName = getEventSlot(key) -- 2026
	if slotName == nil then -- 2026
		return -- 2027
	end -- 2027
	node:slot(slotName):clear() -- 2028
	if value ~= nil then -- 2028
		if key == "onLayout" then -- 2028
			node:onAlignLayout(value) -- 2031
		else -- 2031
			node:slot(slotName, value) -- 2033
		end -- 2033
	end -- 2033
end -- 2033
function patchContactFilterProp(node, value) -- 2038
	local body = Dora.tolua.cast(node, "Body") -- 2039
	if body == nil then -- 2039
		return -- 2040
	end -- 2040
	if value == nil then -- 2040
		body:onContactFilter(function() return true end) -- 2042
	else -- 2042
		body:onContactFilter(value) -- 2044
	end -- 2044
end -- 2044
function patchUpdateProp(node, value) -- 2048
	if value == nil then -- 2048
		node:unschedule() -- 2050
	elseif type(value) == "thread" then -- 2050
		node:schedule(value) -- 2052
	else -- 2052
		node:schedule(value) -- 2054
	end -- 2054
end -- 2054
function patchRenderProp(node, value) -- 2058
	local clearRender = node.clearRender -- 2059
	if type(clearRender) == "function" then -- 2059
		clearRender(node) -- 2061
	end -- 2061
	if value == nil then -- 2061
		return -- 2064
	end -- 2064
	node:onRender(value) -- 2066
end -- 2066
function clearRemovedProp(node, key) -- 2069
	repeat -- 2069
		local ____switch478 = key -- 2069
		local ____cond478 = ____switch478 == "transformTarget" or ____switch478 == "stencil" -- 2069
		if ____cond478 then -- 2069
			node[key] = nil -- 2073
			return true -- 2074
		end -- 2074
	until true -- 2074
	return false -- 2076
end -- 2076
function getAlignStyleText(style) -- 2079
	local items = {} -- 2080
	for k, v in pairs(style) do -- 2081
		local name = string.gsub(k, "%u", "-%1") -- 2082
		name = string.lower(name) -- 2083
		repeat -- 2083
			local ____switch481 = k -- 2083
			local ____cond481 = ____switch481 == "margin" or ____switch481 == "padding" or ____switch481 == "border" or ____switch481 == "gap" -- 2083
			if ____cond481 then -- 2083
				do -- 2083
					if type(v) == "table" then -- 2083
						local valueStr = table.concat( -- 2088
							__TS__ArrayMap( -- 2088
								v, -- 2088
								function(____, item) return tostring(item) end -- 2088
							), -- 2088
							"," -- 2088
						) -- 2088
						items[#items + 1] = (name .. ":") .. valueStr -- 2089
					else -- 2089
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2091
					end -- 2091
					break -- 2093
				end -- 2093
			end -- 2093
			do -- 2093
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2096
				break -- 2097
			end -- 2097
		until true -- 2097
	end -- 2097
	return table.concat(items, ";") -- 2100
end -- 2100
function patchPlayableProps(node, oldProps, newProps) -- 2103
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2103
		node:play(newProps.play, newProps.loop == true) -- 2105
	end -- 2105
end -- 2105
function patchAudioSourceProps(node, oldProps, newProps) -- 2109
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2109
		local audio = node -- 2111
		repeat -- 2111
			local ____switch490 = newProps.playMode -- 2111
			local ____cond490 = ____switch490 == "normal" -- 2111
			if ____cond490 then -- 2111
				local ____audio_play_62 = audio.play -- 2113
				local ____newProps_delayTime_61 = newProps.delayTime -- 2113
				if ____newProps_delayTime_61 == nil then -- 2113
					____newProps_delayTime_61 = 0 -- 2113
				end -- 2113
				____audio_play_62(audio, ____newProps_delayTime_61) -- 2113
				break -- 2113
			end -- 2113
			____cond490 = ____cond490 or ____switch490 == "background" -- 2113
			if ____cond490 then -- 2113
				audio:playBackground() -- 2114
				break -- 2114
			end -- 2114
			____cond490 = ____cond490 or ____switch490 == "3D" -- 2114
			if ____cond490 then -- 2114
				local ____audio_play3D_64 = audio.play3D -- 2115
				local ____newProps_delayTime_63 = newProps.delayTime -- 2115
				if ____newProps_delayTime_63 == nil then -- 2115
					____newProps_delayTime_63 = 0 -- 2115
				end -- 2115
				____audio_play3D_64(audio, ____newProps_delayTime_63) -- 2115
				break -- 2115
			end -- 2115
		until true -- 2115
	end -- 2115
end -- 2115
function patchParticleProps(node, oldProps, newProps) -- 2120
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2120
		local particle = node -- 2122
		if newProps.emit then -- 2122
			particle:start() -- 2124
		else -- 2124
			particle:stop() -- 2126
		end -- 2126
	end -- 2126
end -- 2126
function patchAlignNodeProps(node, oldProps, newProps) -- 2131
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2131
		node:css(getAlignStyleText(newProps.style)) -- 2133
	end -- 2133
end -- 2133
function patchLineProps(node, oldProps, newProps) -- 2137
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2137
		local ____self_68 = node -- 2137
		local ____self_68_set_69 = ____self_68.set -- 2137
		local ____newProps_verts_67 = newProps.verts -- 2139
		local ____Dora_Color_66 = Dora.Color -- 2139
		local ____newProps_lineColor_65 = newProps.lineColor -- 2139
		if ____newProps_lineColor_65 == nil then -- 2139
			____newProps_lineColor_65 = 4294967295 -- 2139
		end -- 2139
		____self_68_set_69( -- 2139
			____self_68, -- 2139
			____newProps_verts_67, -- 2139
			____Dora_Color_66(____newProps_lineColor_65) -- 2139
		) -- 2139
	end -- 2139
end -- 2139
function clearRef(props, node) -- 2143
	local ref = props.ref -- 2144
	if ref ~= nil and (node == nil or ref.current == node) then -- 2144
		ref.current = nil -- 2146
	end -- 2146
end -- 2146
function patchRef(node, oldProps, newProps) -- 2150
	if oldProps.ref ~= newProps.ref then -- 2150
		clearRef(oldProps, node) -- 2152
		local ref = newProps.ref -- 2153
		if ref ~= nil then -- 2153
			ref.current = node -- 2155
		end -- 2155
	end -- 2155
end -- 2155
function applyProp(node, enode, key, value) -- 2160
	local name = key -- 2161
	repeat -- 2161
		local ____switch505 = name -- 2161
		local ____cond505 = ____switch505 == "key" or ____switch505 == "children" or ____switch505 == "onMount" or ____switch505 == "onUnmount" -- 2161
		if ____cond505 then -- 2161
			return -- 2167
		end -- 2167
		____cond505 = ____cond505 or ____switch505 == "ref" -- 2167
		if ____cond505 then -- 2167
			value.current = node -- 2169
			return -- 2170
		end -- 2170
		____cond505 = ____cond505 or ____switch505 == "anchorX" -- 2170
		if ____cond505 then -- 2170
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2172
			return -- 2173
		end -- 2173
		____cond505 = ____cond505 or ____switch505 == "anchorY" -- 2173
		if ____cond505 then -- 2173
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2175
			return -- 2176
		end -- 2176
		____cond505 = ____cond505 or ____switch505 == "color3" -- 2176
		if ____cond505 then -- 2176
			node.color3 = Dora.Color3(value) -- 2178
			return -- 2179
		end -- 2179
		____cond505 = ____cond505 or ____switch505 == "transformTarget" -- 2179
		if ____cond505 then -- 2179
			node.transformTarget = value.current -- 2181
			return -- 2182
		end -- 2182
		____cond505 = ____cond505 or ____switch505 == "outlineColor" -- 2182
		if ____cond505 then -- 2182
			node[name] = Dora.Color(value) -- 2184
			return -- 2185
		end -- 2185
		____cond505 = ____cond505 or ____switch505 == "smoothLower" -- 2185
		if ____cond505 then -- 2185
			do -- 2185
				local smooth = node.smooth -- 2187
				node.smooth = Dora.Vec2(value, smooth.y) -- 2188
				return -- 2189
			end -- 2189
		end -- 2189
		____cond505 = ____cond505 or ____switch505 == "smoothUpper" -- 2189
		if ____cond505 then -- 2189
			do -- 2189
				local smooth = node.smooth -- 2192
				node.smooth = Dora.Vec2(smooth.x, value) -- 2193
				return -- 2194
			end -- 2194
		end -- 2194
	until true -- 2194
	if isEventProp(key) then -- 2194
		if key == "onUpdate" then -- 2194
			patchUpdateProp(node, value) -- 2199
		elseif key == "onRender" then -- 2199
			patchRenderProp(node, value) -- 2201
		elseif key == "onContactFilter" then -- 2201
			patchContactFilterProp(node, value) -- 2203
		elseif isPatchableEventProp(key) then -- 2203
			patchEventProp(node, key, value) -- 2205
		end -- 2205
		return -- 2207
	end -- 2207
	node[name] = value -- 2209
end -- 2209
function patchProps(node, oldElement, newElement) -- 2212
	local oldProps = oldElement.props -- 2213
	local newProps = newElement.props -- 2214
	for k in pairs(oldProps) do -- 2215
		if k == "onUpdate" and newProps[k] == nil then -- 2215
			patchUpdateProp(node, nil) -- 2217
		elseif k == "onRender" and newProps[k] == nil then -- 2217
			patchRenderProp(node, nil) -- 2219
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2219
			patchContactFilterProp(node, nil) -- 2221
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2221
			patchEventProp(node, k, nil) -- 2223
		elseif newProps[k] == nil then -- 2223
			clearRemovedProp(node, k) -- 2225
		end -- 2225
	end -- 2225
	patchRef(node, oldProps, newProps) -- 2228
	for k, v in pairs(newProps) do -- 2229
		if k ~= "ref" and oldProps[k] ~= v then -- 2229
			applyProp(node, newElement, k, v) -- 2231
		end -- 2231
	end -- 2231
	if newElement.type == "label" then -- 2231
		node.text = getPrimitiveLabelText(newElement) -- 2235
	elseif newElement.type == "physics-world" then -- 2235
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2237
		if world ~= nil then -- 2237
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2239
		end -- 2239
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2239
		patchPlayableProps(node, oldProps, newProps) -- 2247
	elseif newElement.type == "audio-source" then -- 2247
		patchAudioSourceProps(node, oldProps, newProps) -- 2249
	elseif newElement.type == "particle" then -- 2249
		patchParticleProps(node, oldProps, newProps) -- 2251
	elseif newElement.type == "align-node" then -- 2251
		patchAlignNodeProps(node, oldProps, newProps) -- 2253
	elseif newElement.type == "line" then -- 2253
		patchLineProps(node, oldProps, newProps) -- 2255
	end -- 2255
	applyAutoEnableProps(node, newProps) -- 2257
end -- 2257
function addChildToParent(parent, node, props) -- 2260
	if props.tag ~= nil then -- 2260
		parent:addChild(node, props.order or 0, props.tag) -- 2262
	elseif props.order ~= nil then -- 2262
		parent:addChild(node, props.order) -- 2264
	else -- 2264
		parent:addChild(node) -- 2266
	end -- 2266
end -- 2266
function mountElement(parent, enode) -- 2270
	local node = createHostNode(enode, parent) -- 2271
	if node == nil then -- 2271
		return nil -- 2273
	end -- 2273
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2273
		return nil -- 2282
	end -- 2282
	local props = enode.props -- 2284
	addChildToParent(parent, node, props) -- 2285
	local mounted = {element = enode, node = node, children = {}} -- 2286
	runActionChildren(node, enode) -- 2287
	mounted.children = reconcileChildren( -- 2288
		node, -- 2288
		{}, -- 2288
		getElementChildren(enode) -- 2288
	) -- 2288
	return mounted -- 2289
end -- 2289
function unmountHostElement(mounted) -- 2292
	local props = mounted.element.props -- 2293
	if props.onUnmount ~= nil then -- 2293
		props.onUnmount(mounted.node) -- 2295
	end -- 2295
	clearRef(mounted.element.props, mounted.node) -- 2297
	mounted.node:removeFromParent(true) -- 2298
end -- 2298
function unmountElement(mounted) -- 2301
	for i = 1, #mounted.children do -- 2301
		unmountElement(mounted.children[i]) -- 2303
	end -- 2303
	unmountHostElement(mounted) -- 2305
end -- 2305
function reconcileElement(parent, oldMounted, newElement) -- 2308
	if oldMounted == nil then -- 2308
		return mountElement(parent, newElement) -- 2310
	end -- 2310
	local recreateMode = getRecreateMode(oldMounted.element, newElement) -- 2312
	if recreateMode == "subtree" then -- 2312
		local oldNode = oldMounted.node -- 2314
		local oldOrder = oldNode.order -- 2315
		local oldTag = oldNode.tag -- 2316
		unmountElement(oldMounted) -- 2317
		local mounted = mountElement(parent, newElement) -- 2318
		if mounted ~= nil then -- 2318
			mounted.node.order = newElement.props.order or oldOrder -- 2320
			mounted.node.tag = newElement.props.tag or oldTag -- 2321
		end -- 2321
		return mounted -- 2323
	end -- 2323
	if recreateMode == "host" then -- 2323
		local oldNode = oldMounted.node -- 2326
		local oldOrder = oldNode.order -- 2327
		local oldTag = oldNode.tag -- 2328
		local node = createHostNode(newElement, parent) -- 2329
		if node == nil then -- 2329
			unmountElement(oldMounted) -- 2331
			return nil -- 2332
		end -- 2332
		addChildToParent(parent, node, newElement.props) -- 2334
		node.order = newElement.props.order or oldOrder -- 2335
		node.tag = newElement.props.tag or oldTag -- 2336
		runActionChildren(node, newElement) -- 2337
		for i = 1, #oldMounted.children do -- 2337
			oldMounted.children[i].node:moveToParent(node) -- 2339
		end -- 2339
		unmountHostElement(oldMounted) -- 2341
		oldMounted.node = node -- 2342
		oldMounted.children = reconcileChildren( -- 2343
			node, -- 2343
			oldMounted.children, -- 2343
			getElementChildren(newElement) -- 2343
		) -- 2343
		oldMounted.element = newElement -- 2344
		return oldMounted -- 2345
	end -- 2345
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2347
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2348
	oldMounted.children = reconcileChildren( -- 2349
		oldMounted.node, -- 2349
		oldMounted.children, -- 2349
		getElementChildren(newElement) -- 2349
	) -- 2349
	oldMounted.element = newElement -- 2350
	return oldMounted -- 2351
end -- 2351
function reconcileChildren(parent, oldChildren, newElements) -- 2354
	warnUnkeyedDynamicChildren(oldChildren, newElements) -- 2355
	local oldByKey = {} -- 2356
	local usedOld = {} -- 2357
	for i = 1, #oldChildren do -- 2357
		local oldChild = oldChildren[i] -- 2359
		local key = getElementKey(oldChild.element) -- 2360
		if key ~= nil then -- 2360
			oldByKey[key] = oldChild -- 2362
		end -- 2362
	end -- 2362
	local nextChildren = {} -- 2365
	for i = 1, #newElements do -- 2365
		local newElement = newElements[i] -- 2367
		local key = getElementKey(newElement) -- 2368
		local oldChild -- 2369
		if key ~= nil then -- 2369
			oldChild = oldByKey[key] -- 2371
		else -- 2371
			oldChild = oldChildren[i] -- 2373
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2373
				oldChild = nil -- 2375
			end -- 2375
		end -- 2375
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2378
		if mounted ~= nil then -- 2378
			usedOld[mounted] = true -- 2380
			nextChildren[#nextChildren + 1] = mounted -- 2381
			local props = newElement.props -- 2382
			mounted.node.order = props.order or i -- 2383
			if props.tag ~= nil then -- 2383
				mounted.node.tag = props.tag -- 2384
			end -- 2384
		end -- 2384
	end -- 2384
	for i = 1, #oldChildren do -- 2384
		local oldChild = oldChildren[i] -- 2388
		if not usedOld[oldChild] then -- 2388
			unmountElement(oldChild) -- 2390
		end -- 2390
	end -- 2390
	return nextChildren -- 2393
end -- 2393
____exports.React = {} -- 2393
local React = ____exports.React -- 2393
do -- 2393
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
local function getNode(enode, cnode, attribHandler) -- 202
	cnode = cnode or Dora.Node() -- 203
	local jnode = enode.props -- 204
	local anchor -- 205
	local color3 -- 206
	for k, v in pairs(enode.props) do -- 207
		repeat -- 207
			local ____switch42 = k -- 207
			local ____cond42 = ____switch42 == "ref" -- 207
			if ____cond42 then -- 207
				v.current = cnode -- 209
				break -- 209
			end -- 209
			____cond42 = ____cond42 or ____switch42 == "anchorX" -- 209
			if ____cond42 then -- 209
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 210
				break -- 210
			end -- 210
			____cond42 = ____cond42 or ____switch42 == "anchorY" -- 210
			if ____cond42 then -- 210
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 211
				break -- 211
			end -- 211
			____cond42 = ____cond42 or ____switch42 == "color3" -- 211
			if ____cond42 then -- 211
				color3 = Dora.Color3(v) -- 212
				break -- 212
			end -- 212
			____cond42 = ____cond42 or ____switch42 == "transformTarget" -- 212
			if ____cond42 then -- 212
				cnode.transformTarget = v.current -- 213
				break -- 213
			end -- 213
			____cond42 = ____cond42 or ____switch42 == "onUpdate" -- 213
			if ____cond42 then -- 213
				cnode:schedule(v) -- 214
				break -- 214
			end -- 214
			____cond42 = ____cond42 or ____switch42 == "onRender" -- 214
			if ____cond42 then -- 214
				patchRenderProp(cnode, v) -- 215
				break -- 215
			end -- 215
			____cond42 = ____cond42 or ____switch42 == "onActionEnd" -- 215
			if ____cond42 then -- 215
				cnode:slot("ActionEnd", v) -- 216
				break -- 216
			end -- 216
			____cond42 = ____cond42 or ____switch42 == "onTapFilter" -- 216
			if ____cond42 then -- 216
				cnode:slot("TapFilter", v) -- 217
				break -- 217
			end -- 217
			____cond42 = ____cond42 or ____switch42 == "onTapBegan" -- 217
			if ____cond42 then -- 217
				cnode:slot("TapBegan", v) -- 218
				break -- 218
			end -- 218
			____cond42 = ____cond42 or ____switch42 == "onTapEnded" -- 218
			if ____cond42 then -- 218
				cnode:slot("TapEnded", v) -- 219
				break -- 219
			end -- 219
			____cond42 = ____cond42 or ____switch42 == "onTapped" -- 219
			if ____cond42 then -- 219
				cnode:slot("Tapped", v) -- 220
				break -- 220
			end -- 220
			____cond42 = ____cond42 or ____switch42 == "onTapMoved" -- 220
			if ____cond42 then -- 220
				cnode:slot("TapMoved", v) -- 221
				break -- 221
			end -- 221
			____cond42 = ____cond42 or ____switch42 == "onMouseMove" -- 221
			if ____cond42 then -- 221
				cnode:slot("MouseMove", v) -- 222
				break -- 222
			end -- 222
			____cond42 = ____cond42 or ____switch42 == "onMouseWheel" -- 221
			if ____cond42 then -- 221
				cnode:slot("MouseWheel", v) -- 222
				break -- 222
			end -- 222
			____cond42 = ____cond42 or ____switch42 == "onGesture" -- 222
			if ____cond42 then -- 222
				cnode:slot("Gesture", v) -- 223
				break -- 223
			end -- 223
			____cond42 = ____cond42 or ____switch42 == "onEnter" -- 223
			if ____cond42 then -- 223
				cnode:slot("Enter", v) -- 224
				break -- 224
			end -- 224
			____cond42 = ____cond42 or ____switch42 == "onExit" -- 224
			if ____cond42 then -- 224
				cnode:slot("Exit", v) -- 225
				break -- 225
			end -- 225
			____cond42 = ____cond42 or ____switch42 == "onCleanup" -- 225
			if ____cond42 then -- 225
				cnode:slot("Cleanup", v) -- 226
				break -- 226
			end -- 226
			____cond42 = ____cond42 or ____switch42 == "onUnmount" -- 226
			if ____cond42 then -- 226
				break -- 227
			end -- 227
			____cond42 = ____cond42 or ____switch42 == "onKeyDown" -- 227
			if ____cond42 then -- 227
				cnode:slot("KeyDown", v) -- 228
				break -- 228
			end -- 228
			____cond42 = ____cond42 or ____switch42 == "onKeyUp" -- 228
			if ____cond42 then -- 228
				cnode:slot("KeyUp", v) -- 229
				break -- 229
			end -- 229
			____cond42 = ____cond42 or ____switch42 == "onKeyPressed" -- 229
			if ____cond42 then -- 229
				cnode:slot("KeyPressed", v) -- 230
				break -- 230
			end -- 230
			____cond42 = ____cond42 or ____switch42 == "onAttachIME" -- 230
			if ____cond42 then -- 230
				cnode:slot("AttachIME", v) -- 231
				break -- 231
			end -- 231
			____cond42 = ____cond42 or ____switch42 == "onDetachIME" -- 231
			if ____cond42 then -- 231
				cnode:slot("DetachIME", v) -- 232
				break -- 232
			end -- 232
			____cond42 = ____cond42 or ____switch42 == "onTextInput" -- 232
			if ____cond42 then -- 232
				cnode:slot("TextInput", v) -- 233
				break -- 233
			end -- 233
			____cond42 = ____cond42 or ____switch42 == "onTextEditing" -- 233
			if ____cond42 then -- 233
				cnode:slot("TextEditing", v) -- 234
				break -- 234
			end -- 234
			____cond42 = ____cond42 or ____switch42 == "onButtonDown" -- 234
			if ____cond42 then -- 234
				cnode:slot("ButtonDown", v) -- 235
				break -- 235
			end -- 235
			____cond42 = ____cond42 or ____switch42 == "onButtonUp" -- 235
			if ____cond42 then -- 235
				cnode:slot("ButtonUp", v) -- 236
				break -- 236
			end -- 236
			____cond42 = ____cond42 or ____switch42 == "onAxis" -- 236
			if ____cond42 then -- 236
				cnode:slot("Axis", v) -- 237
				break -- 237
			end -- 237
			do -- 237
				do -- 237
					if attribHandler then -- 237
						if not attribHandler(cnode, enode, k, v) then -- 237
							cnode[k] = v -- 241
						end -- 241
					else -- 241
						cnode[k] = v -- 244
					end -- 244
					break -- 246
				end -- 246
			end -- 246
		until true -- 246
	end -- 246
	applyAutoEnableProps(cnode, enode.props) -- 250
	if anchor ~= nil then -- 250
		cnode.anchor = anchor -- 251
	end -- 251
	if color3 ~= nil then -- 251
		cnode.color3 = color3 -- 252
	end -- 252
	if jnode.onMount ~= nil then -- 252
		jnode.onMount(cnode) -- 254
	end -- 254
	return cnode -- 256
end -- 202
local getClipNode -- 259
do -- 259
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 261
		repeat -- 261
			local ____switch52 = k -- 261
			local ____cond52 = ____switch52 == "stencil" -- 261
			if ____cond52 then -- 261
				cnode.stencil = ____exports.toNode(v) -- 268
				return true -- 268
			end -- 268
		until true -- 268
		return false -- 270
	end -- 261
	getClipNode = function(enode) -- 272
		return getNode( -- 273
			enode, -- 273
			Dora.ClipNode(), -- 273
			handleClipNodeAttribute -- 273
		) -- 273
	end -- 272
end -- 272
local getPlayable -- 277
local getDragonBone -- 278
local getSpine -- 279
local getModel -- 280
do -- 280
	local function handlePlayableAttribute(cnode, enode, k, v) -- 282
		repeat -- 282
			local ____switch56 = k -- 282
			local ____cond56 = ____switch56 == "file" -- 282
			if ____cond56 then -- 282
				return true -- 284
			end -- 284
			____cond56 = ____cond56 or ____switch56 == "play" -- 284
			if ____cond56 then -- 284
				cnode:play(v, enode.props.loop == true) -- 285
				return true -- 285
			end -- 285
			____cond56 = ____cond56 or ____switch56 == "loop" -- 285
			if ____cond56 then -- 285
				return true -- 286
			end -- 286
			____cond56 = ____cond56 or ____switch56 == "onAnimationEnd" -- 286
			if ____cond56 then -- 286
				cnode:slot("AnimationEnd", v) -- 287
				return true -- 287
			end -- 287
		until true -- 287
		return false -- 289
	end -- 282
	getPlayable = function(enode, cnode, attribHandler) -- 291
		if attribHandler == nil then -- 291
			attribHandler = handlePlayableAttribute -- 292
		end -- 292
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 293
		if cnode ~= nil then -- 293
			return getNode(enode, cnode, attribHandler) -- 295
		end -- 295
		return nil -- 297
	end -- 291
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 300
		repeat -- 300
			local ____switch60 = k -- 300
			local ____cond60 = ____switch60 == "hitTestEnabled" -- 300
			if ____cond60 then -- 300
				cnode.hitTestEnabled = true -- 302
				return true -- 302
			end -- 302
		until true -- 302
		return handlePlayableAttribute(cnode, enode, k, v) -- 304
	end -- 300
	getDragonBone = function(enode) -- 306
		local node = Dora.DragonBone(enode.props.file) -- 307
		if node ~= nil then -- 307
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 309
			return cnode -- 310
		end -- 310
		return nil -- 312
	end -- 306
	local function handleSpineAttribute(cnode, enode, k, v) -- 315
		repeat -- 315
			local ____switch64 = k -- 315
			local ____cond64 = ____switch64 == "hitTestEnabled" -- 315
			if ____cond64 then -- 315
				cnode.hitTestEnabled = true -- 317
				return true -- 317
			end -- 317
		until true -- 317
		return handlePlayableAttribute(cnode, enode, k, v) -- 319
	end -- 315
	getSpine = function(enode) -- 321
		local node = Dora.Spine(enode.props.file) -- 322
		if node ~= nil then -- 322
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 324
			return cnode -- 325
		end -- 325
		return nil -- 327
	end -- 321
	local function handleModelAttribute(cnode, enode, k, v) -- 330
		repeat -- 330
			local ____switch68 = k -- 330
			local ____cond68 = ____switch68 == "reversed" -- 330
			if ____cond68 then -- 330
				cnode.reversed = v -- 332
				return true -- 332
			end -- 332
		until true -- 332
		return handlePlayableAttribute(cnode, enode, k, v) -- 334
	end -- 330
	getModel = function(enode) -- 336
		local node = Dora.Model(enode.props.file) -- 337
		if node ~= nil then -- 337
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 339
			return cnode -- 340
		end -- 340
		return nil -- 342
	end -- 336
end -- 336
local getDrawNode -- 346
do -- 346
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 348
		repeat -- 348
			local ____switch73 = k -- 348
			local ____cond73 = ____switch73 == "depthWrite" -- 348
			if ____cond73 then -- 348
				cnode.depthWrite = v -- 350
				return true -- 350
			end -- 350
			____cond73 = ____cond73 or ____switch73 == "blendFunc" -- 350
			if ____cond73 then -- 350
				cnode.blendFunc = v -- 351
				return true -- 351
			end -- 351
		until true -- 351
		return false -- 353
	end -- 348
	getDrawNode = function(enode) -- 355
		local node = Dora.DrawNode() -- 356
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 357
		local ____enode_7 = enode -- 358
		local children = ____enode_7.children -- 358
		for i = 1, #children do -- 358
			do -- 358
				local child = children[i] -- 360
				if type(child) ~= "table" then -- 360
					goto __continue75 -- 362
				end -- 362
				repeat -- 362
					local ____switch77 = child.type -- 362
					local ____cond77 = ____switch77 == "dot-shape" -- 362
					if ____cond77 then -- 362
						do -- 362
							local dot = child.props -- 366
							node:drawDot( -- 367
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 368
								dot.radius, -- 369
								Dora.Color(dot.color or 4294967295) -- 370
							) -- 370
							break -- 372
						end -- 372
					end -- 372
					____cond77 = ____cond77 or ____switch77 == "segment-shape" -- 372
					if ____cond77 then -- 372
						do -- 372
							local segment = child.props -- 375
							node:drawSegment( -- 376
								Dora.Vec2(segment.startX, segment.startY), -- 377
								Dora.Vec2(segment.stopX, segment.stopY), -- 378
								segment.radius, -- 379
								Dora.Color(segment.color or 4294967295) -- 380
							) -- 380
							break -- 382
						end -- 382
					end -- 382
					____cond77 = ____cond77 or ____switch77 == "rect-shape" -- 382
					if ____cond77 then -- 382
						do -- 382
							local rect = child.props -- 385
							local centerX = rect.centerX or 0 -- 386
							local centerY = rect.centerY or 0 -- 387
							local hw = rect.width / 2 -- 388
							local hh = rect.height / 2 -- 389
							node:drawPolygon( -- 390
								{ -- 391
									Dora.Vec2(centerX - hw, centerY + hh), -- 392
									Dora.Vec2(centerX + hw, centerY + hh), -- 393
									Dora.Vec2(centerX + hw, centerY - hh), -- 394
									Dora.Vec2(centerX - hw, centerY - hh) -- 395
								}, -- 395
								Dora.Color(rect.fillColor or 4294967295), -- 397
								rect.borderWidth or 0, -- 398
								Dora.Color(rect.borderColor or 4294967295) -- 399
							) -- 399
							break -- 401
						end -- 401
					end -- 401
					____cond77 = ____cond77 or ____switch77 == "polygon-shape" -- 401
					if ____cond77 then -- 401
						do -- 401
							local poly = child.props -- 404
							node:drawPolygon( -- 405
								poly.verts, -- 406
								Dora.Color(poly.fillColor or 4294967295), -- 407
								poly.borderWidth or 0, -- 408
								Dora.Color(poly.borderColor or 4294967295) -- 409
							) -- 409
							break -- 411
						end -- 411
					end -- 411
					____cond77 = ____cond77 or ____switch77 == "verts-shape" -- 411
					if ____cond77 then -- 411
						do -- 411
							local verts = child.props -- 414
							node:drawVertices(__TS__ArrayMap( -- 415
								verts.verts, -- 415
								function(____, ____bindingPattern0) -- 415
									local color -- 415
									local vert -- 415
									vert = ____bindingPattern0[1] -- 415
									color = ____bindingPattern0[2] -- 415
									return { -- 415
										vert, -- 415
										Dora.Color(color) -- 415
									} -- 415
								end -- 415
							)) -- 415
							break -- 416
						end -- 416
					end -- 416
				until true -- 416
			end -- 416
			::__continue75:: -- 416
		end -- 416
		return cnode -- 420
	end -- 355
end -- 355
local getGrid -- 424
do -- 424
	local function handleGridAttribute(cnode, _enode, k, v) -- 426
		repeat -- 426
			local ____switch86 = k -- 426
			local ____cond86 = ____switch86 == "file" or ____switch86 == "gridX" or ____switch86 == "gridY" -- 426
			if ____cond86 then -- 426
				return true -- 428
			end -- 428
			____cond86 = ____cond86 or ____switch86 == "textureRect" -- 428
			if ____cond86 then -- 428
				cnode.textureRect = v -- 429
				return true -- 429
			end -- 429
			____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 429
			if ____cond86 then -- 429
				cnode.depthWrite = v -- 430
				return true -- 430
			end -- 430
			____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 430
			if ____cond86 then -- 430
				cnode.blendFunc = v -- 431
				return true -- 431
			end -- 431
			____cond86 = ____cond86 or ____switch86 == "effect" -- 431
			if ____cond86 then -- 431
				cnode.effect = v -- 432
				return true -- 432
			end -- 432
		until true -- 432
		return false -- 434
	end -- 426
	getGrid = function(enode) -- 436
		local grid = enode.props -- 437
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 438
		local cnode = getNode(enode, node, handleGridAttribute) -- 439
		return cnode -- 440
	end -- 436
end -- 436
local getSprite -- 444
local getVideoNode -- 445
local getTIC80Node -- 446
do -- 446
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 448
		repeat -- 448
			local ____switch90 = k -- 448
			local ____cond90 = ____switch90 == "file" -- 448
			if ____cond90 then -- 448
				return true -- 450
			end -- 450
			____cond90 = ____cond90 or ____switch90 == "textureRect" -- 450
			if ____cond90 then -- 450
				cnode.textureRect = v -- 451
				return true -- 451
			end -- 451
			____cond90 = ____cond90 or ____switch90 == "depthWrite" -- 451
			if ____cond90 then -- 451
				cnode.depthWrite = v -- 452
				return true -- 452
			end -- 452
			____cond90 = ____cond90 or ____switch90 == "blendFunc" -- 452
			if ____cond90 then -- 452
				cnode.blendFunc = v -- 453
				return true -- 453
			end -- 453
			____cond90 = ____cond90 or ____switch90 == "effect" -- 453
			if ____cond90 then -- 453
				cnode.effect = v -- 454
				return true -- 454
			end -- 454
			____cond90 = ____cond90 or ____switch90 == "alphaRef" -- 454
			if ____cond90 then -- 454
				cnode.alphaRef = v -- 455
				return true -- 455
			end -- 455
			____cond90 = ____cond90 or ____switch90 == "uwrap" -- 455
			if ____cond90 then -- 455
				cnode.uwrap = v -- 456
				return true -- 456
			end -- 456
			____cond90 = ____cond90 or ____switch90 == "vwrap" -- 456
			if ____cond90 then -- 456
				cnode.vwrap = v -- 457
				return true -- 457
			end -- 457
			____cond90 = ____cond90 or ____switch90 == "filter" -- 457
			if ____cond90 then -- 457
				cnode.filter = v -- 458
				return true -- 458
			end -- 458
		until true -- 458
		return false -- 460
	end -- 448
	getSprite = function(enode) -- 462
		local sp = enode.props -- 463
		if sp.file then -- 463
			local node = Dora.Sprite(sp.file) -- 465
			if node ~= nil then -- 465
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 467
				return cnode -- 468
			end -- 468
		else -- 468
			local node = Dora.Sprite() -- 471
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 472
			return cnode -- 473
		end -- 473
		return nil -- 475
	end -- 462
	getVideoNode = function(enode) -- 477
		local vn = enode.props -- 478
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 479
		local ____vn_file_9 = vn.file -- 479
		local ____vn_looped_8 = vn.looped -- 479
		if ____vn_looped_8 == nil then -- 479
			____vn_looped_8 = false -- 479
		end -- 479
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 479
		if node ~= nil then -- 479
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 481
			return cnode -- 482
		end -- 482
		return nil -- 484
	end -- 477
	getTIC80Node = function(enode) -- 486
		local tic = enode.props -- 487
		local node = Dora.TIC80Node(tic.file) -- 488
		if node ~= nil then -- 488
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 490
			return cnode -- 491
		end -- 491
		return nil -- 493
	end -- 486
end -- 486
local getAudioSource -- 497
do -- 497
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 499
		repeat -- 499
			local ____switch101 = k -- 499
			local ____cond101 = ____switch101 == "file" -- 499
			if ____cond101 then -- 499
				return true -- 501
			end -- 501
			____cond101 = ____cond101 or ____switch101 == "autoRemove" -- 501
			if ____cond101 then -- 501
				return true -- 502
			end -- 502
			____cond101 = ____cond101 or ____switch101 == "bus" -- 502
			if ____cond101 then -- 502
				return true -- 503
			end -- 503
			____cond101 = ____cond101 or ____switch101 == "volume" -- 503
			if ____cond101 then -- 503
				cnode.volume = v -- 504
				return true -- 504
			end -- 504
			____cond101 = ____cond101 or ____switch101 == "pan" -- 504
			if ____cond101 then -- 504
				cnode.pan = v -- 505
				return true -- 505
			end -- 505
			____cond101 = ____cond101 or ____switch101 == "looping" -- 505
			if ____cond101 then -- 505
				cnode.looping = v -- 506
				return true -- 506
			end -- 506
			____cond101 = ____cond101 or ____switch101 == "playMode" -- 506
			if ____cond101 then -- 506
				do -- 506
					local aus = enode.props -- 508
					repeat -- 508
						local ____switch103 = v -- 508
						local ____cond103 = ____switch103 == "normal" -- 508
						if ____cond103 then -- 508
							cnode:play(aus.delayTime or 0) -- 510
							break -- 510
						end -- 510
						____cond103 = ____cond103 or ____switch103 == "background" -- 510
						if ____cond103 then -- 510
							cnode:playBackground() -- 511
							break -- 511
						end -- 511
						____cond103 = ____cond103 or ____switch103 == "3D" -- 511
						if ____cond103 then -- 511
							cnode:play3D(aus.delayTime or 0) -- 512
							break -- 512
						end -- 512
					until true -- 512
					return true -- 514
				end -- 514
			end -- 514
			____cond101 = ____cond101 or ____switch101 == "delayTime" -- 514
			if ____cond101 then -- 514
				return true -- 516
			end -- 516
			____cond101 = ____cond101 or ____switch101 == "protected" -- 516
			if ____cond101 then -- 516
				cnode:setProtected(v) -- 517
				return true -- 517
			end -- 517
			____cond101 = ____cond101 or ____switch101 == "loopPoint" -- 517
			if ____cond101 then -- 517
				cnode:setLoopPoint(v) -- 518
				return true -- 518
			end -- 518
			____cond101 = ____cond101 or ____switch101 == "velocity" -- 518
			if ____cond101 then -- 518
				do -- 518
					local vx, vy, vz = table.unpack(v, 1, 3) -- 520
					cnode:setVelocity(vx, vy, vz) -- 521
					return true -- 522
				end -- 522
			end -- 522
			____cond101 = ____cond101 or ____switch101 == "minMaxDistance" -- 522
			if ____cond101 then -- 522
				do -- 522
					local min, max = table.unpack(v, 1, 2) -- 525
					cnode:setMinMaxDistance(min, max) -- 526
					return true -- 527
				end -- 527
			end -- 527
			____cond101 = ____cond101 or ____switch101 == "attenuation" -- 527
			if ____cond101 then -- 527
				do -- 527
					local model, factor = table.unpack(v, 1, 2) -- 530
					cnode:setAttenuation(model, factor) -- 531
					return true -- 532
				end -- 532
			end -- 532
			____cond101 = ____cond101 or ____switch101 == "dopplerFactor" -- 532
			if ____cond101 then -- 532
				cnode:setDopplerFactor(v) -- 534
				return true -- 534
			end -- 534
		until true -- 534
		return false -- 536
	end -- 499
	getAudioSource = function(enode) -- 538
		local aus = enode.props -- 539
		local ____aus_autoRemove_11 = aus.autoRemove -- 540
		if ____aus_autoRemove_11 == nil then -- 540
			____aus_autoRemove_11 = true -- 540
		end -- 540
		local autoRemove = ____aus_autoRemove_11 -- 540
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 541
		if node ~= nil then -- 541
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 543
			return cnode -- 544
		end -- 544
		return nil -- 546
	end -- 538
end -- 538
local getLabel -- 550
do -- 550
	local function handleLabelAttribute(cnode, _enode, k, v) -- 552
		repeat -- 552
			local ____switch111 = k -- 552
			local ____cond111 = ____switch111 == "fontName" or ____switch111 == "fontSize" or ____switch111 == "text" or ____switch111 == "smoothLower" or ____switch111 == "smoothUpper" -- 552
			if ____cond111 then -- 552
				return true -- 554
			end -- 554
			____cond111 = ____cond111 or ____switch111 == "alphaRef" -- 554
			if ____cond111 then -- 554
				cnode.alphaRef = v -- 555
				return true -- 555
			end -- 555
			____cond111 = ____cond111 or ____switch111 == "textWidth" -- 555
			if ____cond111 then -- 555
				cnode.textWidth = v -- 556
				return true -- 556
			end -- 556
			____cond111 = ____cond111 or ____switch111 == "lineGap" -- 556
			if ____cond111 then -- 556
				cnode.lineGap = v -- 557
				return true -- 557
			end -- 557
			____cond111 = ____cond111 or ____switch111 == "spacing" -- 557
			if ____cond111 then -- 557
				cnode.spacing = v -- 558
				return true -- 558
			end -- 558
			____cond111 = ____cond111 or ____switch111 == "outlineColor" -- 558
			if ____cond111 then -- 558
				cnode.outlineColor = Dora.Color(v) -- 559
				return true -- 559
			end -- 559
			____cond111 = ____cond111 or ____switch111 == "outlineWidth" -- 559
			if ____cond111 then -- 559
				cnode.outlineWidth = v -- 560
				return true -- 560
			end -- 560
			____cond111 = ____cond111 or ____switch111 == "blendFunc" -- 560
			if ____cond111 then -- 560
				cnode.blendFunc = v -- 561
				return true -- 561
			end -- 561
			____cond111 = ____cond111 or ____switch111 == "depthWrite" -- 561
			if ____cond111 then -- 561
				cnode.depthWrite = v -- 562
				return true -- 562
			end -- 562
			____cond111 = ____cond111 or ____switch111 == "batched" -- 562
			if ____cond111 then -- 562
				cnode.batched = v -- 563
				return true -- 563
			end -- 563
			____cond111 = ____cond111 or ____switch111 == "effect" -- 563
			if ____cond111 then -- 563
				cnode.effect = v -- 564
				return true -- 564
			end -- 564
			____cond111 = ____cond111 or ____switch111 == "alignment" -- 564
			if ____cond111 then -- 564
				cnode.alignment = v -- 565
				return true -- 565
			end -- 565
		until true -- 565
		return false -- 567
	end -- 552
	getLabel = function(enode) -- 569
		local label = enode.props -- 570
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 571
		if node ~= nil then -- 571
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 571
				local ____node_smooth_12 = node.smooth -- 574
				local x = ____node_smooth_12.x -- 574
				local y = ____node_smooth_12.y -- 574
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 575
			end -- 575
			local cnode = getNode(enode, node, handleLabelAttribute) -- 577
			local ____enode_13 = enode -- 578
			local children = ____enode_13.children -- 578
			local text = label.text or "" -- 579
			for i = 1, #children do -- 579
				local child = children[i] -- 581
				if type(child) ~= "table" then -- 581
					text = text .. tostring(child) -- 583
				end -- 583
			end -- 583
			node.text = text -- 586
			return cnode -- 587
		end -- 587
		return nil -- 589
	end -- 569
end -- 569
local getLine -- 593
do -- 593
	local function handleLineAttribute(cnode, enode, k, v) -- 595
		local line = enode.props -- 596
		repeat -- 596
			local ____switch119 = k -- 596
			local ____cond119 = ____switch119 == "verts" -- 596
			if ____cond119 then -- 596
				cnode:set( -- 598
					v, -- 598
					Dora.Color(line.lineColor or 4294967295) -- 598
				) -- 598
				return true -- 598
			end -- 598
			____cond119 = ____cond119 or ____switch119 == "depthWrite" -- 598
			if ____cond119 then -- 598
				cnode.depthWrite = v -- 599
				return true -- 599
			end -- 599
			____cond119 = ____cond119 or ____switch119 == "blendFunc" -- 599
			if ____cond119 then -- 599
				cnode.blendFunc = v -- 600
				return true -- 600
			end -- 600
		until true -- 600
		return false -- 602
	end -- 595
	getLine = function(enode) -- 604
		local node = Dora.Line() -- 605
		local cnode = getNode(enode, node, handleLineAttribute) -- 606
		return cnode -- 607
	end -- 604
end -- 604
local getParticle -- 611
do -- 611
	local function handleParticleAttribute(cnode, _enode, k, v) -- 613
		repeat -- 613
			local ____switch123 = k -- 613
			local ____cond123 = ____switch123 == "file" -- 613
			if ____cond123 then -- 613
				return true -- 615
			end -- 615
			____cond123 = ____cond123 or ____switch123 == "emit" -- 615
			if ____cond123 then -- 615
				if v then -- 615
					cnode:start() -- 616
				end -- 616
				return true -- 616
			end -- 616
			____cond123 = ____cond123 or ____switch123 == "onFinished" -- 616
			if ____cond123 then -- 616
				cnode:slot("Finished", v) -- 617
				return true -- 617
			end -- 617
		until true -- 617
		return false -- 619
	end -- 613
	getParticle = function(enode) -- 621
		local particle = enode.props -- 622
		local node = Dora.Particle(particle.file) -- 623
		if node ~= nil then -- 623
			local cnode = getNode(enode, node, handleParticleAttribute) -- 625
			return cnode -- 626
		end -- 626
		return nil -- 628
	end -- 621
end -- 621
local getMenu -- 632
do -- 632
	local function handleMenuAttribute(cnode, _enode, k, v) -- 634
		repeat -- 634
			local ____switch129 = k -- 634
			local ____cond129 = ____switch129 == "enabled" -- 634
			if ____cond129 then -- 634
				cnode.enabled = v -- 636
				return true -- 636
			end -- 636
		until true -- 636
		return false -- 638
	end -- 634
	getMenu = function(enode) -- 640
		local node = Dora.Menu() -- 641
		local cnode = getNode(enode, node, handleMenuAttribute) -- 642
		return cnode -- 643
	end -- 640
end -- 640
local function getPhysicsWorld(enode) -- 647
	local node = Dora.PhysicsWorld() -- 648
	local cnode = getNode(enode, node) -- 649
	return cnode -- 650
end -- 647
local getBody -- 653
do -- 653
	local function handleBodyAttribute(cnode, _enode, k, v) -- 655
		repeat -- 655
			local ____switch134 = k -- 655
			local ____cond134 = ____switch134 == "type" or ____switch134 == "linearAcceleration" or ____switch134 == "fixedRotation" or ____switch134 == "bullet" or ____switch134 == "world" -- 655
			if ____cond134 then -- 655
				return true -- 662
			end -- 662
			____cond134 = ____cond134 or ____switch134 == "velocityX" -- 662
			if ____cond134 then -- 662
				cnode.velocityX = v -- 663
				return true -- 663
			end -- 663
			____cond134 = ____cond134 or ____switch134 == "velocityY" -- 663
			if ____cond134 then -- 663
				cnode.velocityY = v -- 664
				return true -- 664
			end -- 664
			____cond134 = ____cond134 or ____switch134 == "angularRate" -- 664
			if ____cond134 then -- 664
				cnode.angularRate = v -- 665
				return true -- 665
			end -- 665
			____cond134 = ____cond134 or ____switch134 == "group" -- 665
			if ____cond134 then -- 665
				cnode.group = v -- 666
				return true -- 666
			end -- 666
			____cond134 = ____cond134 or ____switch134 == "linearDamping" -- 666
			if ____cond134 then -- 666
				cnode.linearDamping = v -- 667
				return true -- 667
			end -- 667
			____cond134 = ____cond134 or ____switch134 == "angularDamping" -- 667
			if ____cond134 then -- 667
				cnode.angularDamping = v -- 668
				return true -- 668
			end -- 668
			____cond134 = ____cond134 or ____switch134 == "owner" -- 668
			if ____cond134 then -- 668
				cnode.owner = v -- 669
				return true -- 669
			end -- 669
			____cond134 = ____cond134 or ____switch134 == "receivingContact" -- 669
			if ____cond134 then -- 669
				cnode.receivingContact = v -- 670
				return true -- 670
			end -- 670
			____cond134 = ____cond134 or ____switch134 == "onBodyEnter" -- 670
			if ____cond134 then -- 670
				cnode:slot("BodyEnter", v) -- 671
				return true -- 671
			end -- 671
			____cond134 = ____cond134 or ____switch134 == "onBodyLeave" -- 671
			if ____cond134 then -- 671
				cnode:slot("BodyLeave", v) -- 672
				return true -- 672
			end -- 672
			____cond134 = ____cond134 or ____switch134 == "onContactStart" -- 672
			if ____cond134 then -- 672
				cnode:slot("ContactStart", v) -- 673
				return true -- 673
			end -- 673
			____cond134 = ____cond134 or ____switch134 == "onContactEnd" -- 673
			if ____cond134 then -- 673
				cnode:slot("ContactEnd", v) -- 674
				return true -- 674
			end -- 674
			____cond134 = ____cond134 or ____switch134 == "onContactFilter" -- 674
			if ____cond134 then -- 674
				cnode:onContactFilter(v) -- 675
				return true -- 675
			end -- 675
		until true -- 675
		return false -- 677
	end -- 655
	getBody = function(enode, world) -- 679
		local def = enode.props -- 680
		local bodyDef = Dora.BodyDef() -- 681
		bodyDef.type = def.type -- 682
		if def.angle ~= nil then -- 682
			bodyDef.angle = def.angle -- 683
		end -- 683
		if def.angularDamping ~= nil then -- 683
			bodyDef.angularDamping = def.angularDamping -- 684
		end -- 684
		if def.bullet ~= nil then -- 684
			bodyDef.bullet = def.bullet -- 685
		end -- 685
		if def.fixedRotation ~= nil then -- 685
			bodyDef.fixedRotation = def.fixedRotation -- 686
		end -- 686
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 687
		if def.linearDamping ~= nil then -- 687
			bodyDef.linearDamping = def.linearDamping -- 688
		end -- 688
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 689
		local extraSensors -- 690
		for i = 1, #enode.children do -- 690
			do -- 690
				local child = enode.children[i] -- 692
				if type(child) ~= "table" then -- 692
					goto __continue141 -- 694
				end -- 694
				repeat -- 694
					local ____switch143 = child.type -- 694
					local ____cond143 = ____switch143 == "rect-fixture" -- 694
					if ____cond143 then -- 694
						do -- 694
							local shape = child.props -- 698
							if shape.sensorTag ~= nil then -- 698
								bodyDef:attachPolygonSensor( -- 700
									shape.sensorTag, -- 701
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 702
									shape.width, -- 703
									shape.height, -- 703
									shape.angle or 0 -- 704
								) -- 704
							else -- 704
								bodyDef:attachPolygon( -- 707
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 708
									shape.width, -- 709
									shape.height, -- 709
									shape.angle or 0, -- 710
									shape.density or 1, -- 711
									shape.friction or 0.4, -- 712
									shape.restitution or 0 -- 713
								) -- 713
							end -- 713
							break -- 716
						end -- 716
					end -- 716
					____cond143 = ____cond143 or ____switch143 == "polygon-fixture" -- 716
					if ____cond143 then -- 716
						do -- 716
							local shape = child.props -- 719
							if shape.sensorTag ~= nil then -- 719
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 721
							else -- 721
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 726
							end -- 726
							break -- 733
						end -- 733
					end -- 733
					____cond143 = ____cond143 or ____switch143 == "multi-fixture" -- 733
					if ____cond143 then -- 733
						do -- 733
							local shape = child.props -- 736
							if shape.sensorTag ~= nil then -- 736
								if extraSensors == nil then -- 736
									extraSensors = {} -- 738
								end -- 738
								extraSensors[#extraSensors + 1] = { -- 739
									shape.sensorTag, -- 739
									Dora.BodyDef:multi(shape.verts) -- 739
								} -- 739
							else -- 739
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 741
							end -- 741
							break -- 748
						end -- 748
					end -- 748
					____cond143 = ____cond143 or ____switch143 == "disk-fixture" -- 748
					if ____cond143 then -- 748
						do -- 748
							local shape = child.props -- 751
							if shape.sensorTag ~= nil then -- 751
								bodyDef:attachDiskSensor( -- 753
									shape.sensorTag, -- 754
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 755
									shape.radius -- 756
								) -- 756
							else -- 756
								bodyDef:attachDisk( -- 759
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 760
									shape.radius, -- 761
									shape.density or 1, -- 762
									shape.friction or 0.4, -- 763
									shape.restitution or 0 -- 764
								) -- 764
							end -- 764
							break -- 767
						end -- 767
					end -- 767
					____cond143 = ____cond143 or ____switch143 == "chain-fixture" -- 767
					if ____cond143 then -- 767
						do -- 767
							local shape = child.props -- 770
							if shape.sensorTag ~= nil then -- 770
								if extraSensors == nil then -- 770
									extraSensors = {} -- 772
								end -- 772
								extraSensors[#extraSensors + 1] = { -- 773
									shape.sensorTag, -- 773
									Dora.BodyDef:chain(shape.verts) -- 773
								} -- 773
							else -- 773
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 775
							end -- 775
							break -- 781
						end -- 781
					end -- 781
				until true -- 781
			end -- 781
			::__continue141:: -- 781
		end -- 781
		local body = Dora.Body(bodyDef, world) -- 785
		if extraSensors ~= nil then -- 785
			for i = 1, #extraSensors do -- 785
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 788
				body:attachSensor(tag, def) -- 789
			end -- 789
		end -- 789
		local cnode = getNode(enode, body, handleBodyAttribute) -- 792
		return cnode -- 793
	end -- 679
end -- 679
local getCustomNode -- 797
do -- 797
	local function handleCustomNode(_cnode, _enode, k, _v) -- 799
		repeat -- 799
			local ____switch163 = k -- 799
			local ____cond163 = ____switch163 == "onCreate" -- 799
			if ____cond163 then -- 799
				return true -- 801
			end -- 801
		until true -- 801
		return false -- 803
	end -- 799
	getCustomNode = function(enode) -- 805
		local custom = enode.props -- 806
		local node = custom.onCreate() -- 807
		if node then -- 807
			local cnode = getNode(enode, node, handleCustomNode) -- 809
			return cnode -- 810
		end -- 810
		return nil -- 812
	end -- 805
end -- 805
local getAlignNode -- 816
do -- 816
	local function handleAlignNode(_cnode, _enode, k, _v) -- 818
		repeat -- 818
			local ____switch168 = k -- 818
			local ____cond168 = ____switch168 == "windowRoot" -- 818
			if ____cond168 then -- 818
				return true -- 820
			end -- 820
			____cond168 = ____cond168 or ____switch168 == "style" -- 820
			if ____cond168 then -- 820
				return true -- 821
			end -- 821
			____cond168 = ____cond168 or ____switch168 == "onLayout" -- 821
			if ____cond168 then -- 821
				return true -- 822
			end -- 822
		until true -- 822
		return false -- 824
	end -- 818
	getAlignNode = function(enode) -- 826
		local alignNode = enode.props -- 827
		local node = Dora.AlignNode(alignNode.windowRoot) -- 828
		if alignNode.style then -- 828
			node:css(getAlignStyleText(alignNode.style)) -- 830
		end -- 830
		if alignNode.onLayout then -- 830
			node:onAlignLayout(alignNode.onLayout) -- 833
		end -- 833
		local cnode = getNode(enode, node, handleAlignNode) -- 835
		return cnode -- 836
	end -- 826
end -- 826
local function getEffekNode(enode) -- 840
	return getNode( -- 841
		enode, -- 841
		Dora.EffekNode() -- 841
	) -- 841
end -- 840
local getTileNode -- 844
do -- 844
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 846
		repeat -- 846
			local ____switch175 = k -- 846
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 846
			if ____cond175 then -- 846
				return true -- 848
			end -- 848
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 848
			if ____cond175 then -- 848
				cnode.depthWrite = v -- 849
				return true -- 849
			end -- 849
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 849
			if ____cond175 then -- 849
				cnode.blendFunc = v -- 850
				return true -- 850
			end -- 850
			____cond175 = ____cond175 or ____switch175 == "effect" -- 850
			if ____cond175 then -- 850
				cnode.effect = v -- 851
				return true -- 851
			end -- 851
			____cond175 = ____cond175 or ____switch175 == "filter" -- 851
			if ____cond175 then -- 851
				cnode.filter = v -- 852
				return true -- 852
			end -- 852
		until true -- 852
		return false -- 854
	end -- 846
	getTileNode = function(enode) -- 856
		local tn = enode.props -- 857
		local ____tn_layers_14 -- 858
		if tn.layers then -- 858
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 858
		else -- 858
			____tn_layers_14 = Dora.TileNode(tn.file) -- 858
		end -- 858
		local node = ____tn_layers_14 -- 858
		if node ~= nil then -- 858
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 860
			return cnode -- 861
		end -- 861
		return nil -- 863
	end -- 856
end -- 856
local function addChild(nodeStack, cnode, enode) -- 867
	if #nodeStack > 0 then -- 867
		local last = nodeStack[#nodeStack] -- 869
		last:addChild(cnode) -- 870
	end -- 870
	nodeStack[#nodeStack + 1] = cnode -- 872
	local ____enode_15 = enode -- 873
	local children = ____enode_15.children -- 873
	for i = 1, #children do -- 873
		visitNode(nodeStack, children[i], enode) -- 875
	end -- 875
	if #nodeStack > 1 then -- 875
		table.remove(nodeStack) -- 878
	end -- 878
end -- 867
local function drawNodeCheck(_nodeStack, enode, parent) -- 886
	if parent == nil or parent.type ~= "draw-node" then -- 886
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 888
	end -- 888
end -- 886
local function actionCheck(nodeStack, enode, parent) -- 949
	local unsupported = false -- 950
	if parent == nil then -- 950
		unsupported = true -- 952
	else -- 952
		repeat -- 952
			local ____switch200 = parent.type -- 952
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 952
			if ____cond200 then -- 952
				break -- 955
			end -- 955
			do -- 955
				unsupported = true -- 956
				break -- 956
			end -- 956
		until true -- 956
	end -- 956
	if unsupported then -- 956
		if #nodeStack > 0 then -- 956
			local node = nodeStack[#nodeStack] -- 961
			local actionStack = {} -- 962
			visitAction(actionStack, enode) -- 963
			if #actionStack == 1 then -- 963
				node:runAction(actionStack[1]) -- 965
			end -- 965
		else -- 965
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 968
		end -- 968
	end -- 968
end -- 949
local function bodyCheck(_nodeStack, enode, parent) -- 973
	if parent == nil or parent.type ~= "body" then -- 973
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 975
	end -- 975
end -- 973
actionMap = { -- 979
	["anchor-x"] = Dora.AnchorX, -- 982
	["anchor-y"] = Dora.AnchorY, -- 983
	angle = Dora.Angle, -- 984
	["angle-x"] = Dora.AngleX, -- 985
	["angle-y"] = Dora.AngleY, -- 986
	width = Dora.Width, -- 987
	height = Dora.Height, -- 988
	opacity = Dora.Opacity, -- 989
	roll = Dora.Roll, -- 990
	scale = Dora.Scale, -- 991
	["scale-x"] = Dora.ScaleX, -- 992
	["scale-y"] = Dora.ScaleY, -- 993
	["skew-x"] = Dora.SkewX, -- 994
	["skew-y"] = Dora.SkewY, -- 995
	["move-x"] = Dora.X, -- 996
	["move-y"] = Dora.Y, -- 997
	["move-z"] = Dora.Z -- 998
} -- 998
elementMap = { -- 1001
	node = function(nodeStack, enode, parent) -- 1002
		addChild( -- 1003
			nodeStack, -- 1003
			getNode(enode), -- 1003
			enode -- 1003
		) -- 1003
	end, -- 1002
	["clip-node"] = function(nodeStack, enode, parent) -- 1005
		addChild( -- 1006
			nodeStack, -- 1006
			getClipNode(enode), -- 1006
			enode -- 1006
		) -- 1006
	end, -- 1005
	playable = function(nodeStack, enode, parent) -- 1008
		local cnode = getPlayable(enode) -- 1009
		if cnode ~= nil then -- 1009
			addChild(nodeStack, cnode, enode) -- 1011
		end -- 1011
	end, -- 1008
	["dragon-bone"] = function(nodeStack, enode, parent) -- 1014
		local cnode = getDragonBone(enode) -- 1015
		if cnode ~= nil then -- 1015
			addChild(nodeStack, cnode, enode) -- 1017
		end -- 1017
	end, -- 1014
	spine = function(nodeStack, enode, parent) -- 1020
		local cnode = getSpine(enode) -- 1021
		if cnode ~= nil then -- 1021
			addChild(nodeStack, cnode, enode) -- 1023
		end -- 1023
	end, -- 1020
	model = function(nodeStack, enode, parent) -- 1026
		local cnode = getModel(enode) -- 1027
		if cnode ~= nil then -- 1027
			addChild(nodeStack, cnode, enode) -- 1029
		end -- 1029
	end, -- 1026
	["draw-node"] = function(nodeStack, enode, parent) -- 1032
		addChild( -- 1033
			nodeStack, -- 1033
			getDrawNode(enode), -- 1033
			enode -- 1033
		) -- 1033
	end, -- 1032
	["dot-shape"] = drawNodeCheck, -- 1035
	["segment-shape"] = drawNodeCheck, -- 1036
	["rect-shape"] = drawNodeCheck, -- 1037
	["polygon-shape"] = drawNodeCheck, -- 1038
	["verts-shape"] = drawNodeCheck, -- 1039
	grid = function(nodeStack, enode, parent) -- 1040
		addChild( -- 1041
			nodeStack, -- 1041
			getGrid(enode), -- 1041
			enode -- 1041
		) -- 1041
	end, -- 1040
	sprite = function(nodeStack, enode, parent) -- 1043
		local cnode = getSprite(enode) -- 1044
		if cnode ~= nil then -- 1044
			addChild(nodeStack, cnode, enode) -- 1046
		end -- 1046
	end, -- 1043
	["audio-source"] = function(nodeStack, enode, parent) -- 1049
		local cnode = getAudioSource(enode) -- 1050
		if cnode ~= nil then -- 1050
			addChild(nodeStack, cnode, enode) -- 1052
		end -- 1052
	end, -- 1049
	["video-node"] = function(nodeStack, enode, parent) -- 1055
		local cnode = getVideoNode(enode) -- 1056
		if cnode ~= nil then -- 1056
			addChild(nodeStack, cnode, enode) -- 1058
		end -- 1058
	end, -- 1055
	["tic80-node"] = function(nodeStack, enode, parent) -- 1061
		local cnode = getTIC80Node(enode) -- 1062
		if cnode ~= nil then -- 1062
			addChild(nodeStack, cnode, enode) -- 1064
		end -- 1064
	end, -- 1061
	label = function(nodeStack, enode, parent) -- 1067
		local cnode = getLabel(enode) -- 1068
		if cnode ~= nil then -- 1068
			addChild(nodeStack, cnode, enode) -- 1070
		end -- 1070
	end, -- 1067
	line = function(nodeStack, enode, parent) -- 1073
		addChild( -- 1074
			nodeStack, -- 1074
			getLine(enode), -- 1074
			enode -- 1074
		) -- 1074
	end, -- 1073
	particle = function(nodeStack, enode, parent) -- 1076
		local cnode = getParticle(enode) -- 1077
		if cnode ~= nil then -- 1077
			addChild(nodeStack, cnode, enode) -- 1079
		end -- 1079
	end, -- 1076
	menu = function(nodeStack, enode, parent) -- 1082
		addChild( -- 1083
			nodeStack, -- 1083
			getMenu(enode), -- 1083
			enode -- 1083
		) -- 1083
	end, -- 1082
	action = function(_nodeStack, enode, parent) -- 1085
		if #enode.children == 0 then -- 1085
			Warn("<action> tag has no children") -- 1087
			return -- 1088
		end -- 1088
		local action = enode.props -- 1090
		if action.ref == nil then -- 1090
			Warn("<action> tag has no ref") -- 1092
			return -- 1093
		end -- 1093
		local actionStack = {} -- 1095
		for i = 1, #enode.children do -- 1095
			visitAction(actionStack, enode.children[i]) -- 1097
		end -- 1097
		if #actionStack == 1 then -- 1097
			action.ref.current = actionStack[1] -- 1100
		elseif #actionStack > 1 then -- 1100
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1102
		end -- 1102
	end, -- 1085
	["anchor-x"] = actionCheck, -- 1105
	["anchor-y"] = actionCheck, -- 1106
	angle = actionCheck, -- 1107
	["angle-x"] = actionCheck, -- 1108
	["angle-y"] = actionCheck, -- 1109
	delay = actionCheck, -- 1110
	event = actionCheck, -- 1111
	width = actionCheck, -- 1112
	height = actionCheck, -- 1113
	hide = actionCheck, -- 1114
	show = actionCheck, -- 1115
	move = actionCheck, -- 1116
	opacity = actionCheck, -- 1117
	roll = actionCheck, -- 1118
	scale = actionCheck, -- 1119
	["scale-x"] = actionCheck, -- 1120
	["scale-y"] = actionCheck, -- 1121
	["skew-x"] = actionCheck, -- 1122
	["skew-y"] = actionCheck, -- 1123
	["move-x"] = actionCheck, -- 1124
	["move-y"] = actionCheck, -- 1125
	["move-z"] = actionCheck, -- 1126
	frame = actionCheck, -- 1127
	spawn = actionCheck, -- 1128
	sequence = actionCheck, -- 1129
	loop = function(nodeStack, enode, _parent) -- 1130
		if #nodeStack > 0 then -- 1130
			local node = nodeStack[#nodeStack] -- 1132
			local actionStack = {} -- 1133
			for i = 1, #enode.children do -- 1133
				visitAction(actionStack, enode.children[i]) -- 1135
			end -- 1135
			if #actionStack == 1 then -- 1135
				node:runAction(actionStack[1], true) -- 1138
			else -- 1138
				local loop = enode.props -- 1140
				if loop.spawn then -- 1140
					node:runAction( -- 1142
						Dora.Spawn(table.unpack(actionStack)), -- 1142
						true -- 1142
					) -- 1142
				else -- 1142
					node:runAction( -- 1144
						Dora.Sequence(table.unpack(actionStack)), -- 1144
						true -- 1144
					) -- 1144
				end -- 1144
			end -- 1144
		else -- 1144
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1148
		end -- 1148
	end, -- 1130
	["physics-world"] = function(nodeStack, enode, _parent) -- 1151
		addChild( -- 1152
			nodeStack, -- 1152
			getPhysicsWorld(enode), -- 1152
			enode -- 1152
		) -- 1152
	end, -- 1151
	contact = function(nodeStack, enode, _parent) -- 1154
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1155
		if world ~= nil then -- 1155
			local contact = enode.props -- 1157
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1158
		else -- 1158
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1160
		end -- 1160
	end, -- 1154
	body = function(nodeStack, enode, _parent) -- 1163
		local def = enode.props -- 1164
		if def.world then -- 1164
			addChild( -- 1166
				nodeStack, -- 1166
				getBody(enode, def.world), -- 1166
				enode -- 1166
			) -- 1166
			return -- 1167
		end -- 1167
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1169
		if world ~= nil then -- 1169
			addChild( -- 1171
				nodeStack, -- 1171
				getBody(enode, world), -- 1171
				enode -- 1171
			) -- 1171
		else -- 1171
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1173
		end -- 1173
	end, -- 1163
	["rect-fixture"] = bodyCheck, -- 1176
	["polygon-fixture"] = bodyCheck, -- 1177
	["multi-fixture"] = bodyCheck, -- 1178
	["disk-fixture"] = bodyCheck, -- 1179
	["chain-fixture"] = bodyCheck, -- 1180
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1181
		local joint = enode.props -- 1182
		if joint.ref == nil then -- 1182
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1184
			return -- 1185
		end -- 1185
		if joint.bodyA.current == nil then -- 1185
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1188
			return -- 1189
		end -- 1189
		if joint.bodyB.current == nil then -- 1189
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1192
			return -- 1193
		end -- 1193
		local ____joint_ref_19 = joint.ref -- 1195
		local ____self_17 = Dora.Joint -- 1195
		local ____self_17_distance_18 = ____self_17.distance -- 1195
		local ____joint_canCollide_16 = joint.canCollide -- 1196
		if ____joint_canCollide_16 == nil then -- 1196
			____joint_canCollide_16 = false -- 1196
		end -- 1196
		____joint_ref_19.current = ____self_17_distance_18( -- 1195
			____self_17, -- 1195
			____joint_canCollide_16, -- 1196
			joint.bodyA.current, -- 1197
			joint.bodyB.current, -- 1198
			joint.anchorA or Dora.Vec2.zero, -- 1199
			joint.anchorB or Dora.Vec2.zero, -- 1200
			joint.frequency or 0, -- 1201
			joint.damping or 0 -- 1202
		) -- 1202
	end, -- 1181
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1204
		local joint = enode.props -- 1205
		if joint.ref == nil then -- 1205
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1207
			return -- 1208
		end -- 1208
		if joint.bodyA.current == nil then -- 1208
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1211
			return -- 1212
		end -- 1212
		if joint.bodyB.current == nil then -- 1212
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1215
			return -- 1216
		end -- 1216
		local ____joint_ref_23 = joint.ref -- 1218
		local ____self_21 = Dora.Joint -- 1218
		local ____self_21_friction_22 = ____self_21.friction -- 1218
		local ____joint_canCollide_20 = joint.canCollide -- 1219
		if ____joint_canCollide_20 == nil then -- 1219
			____joint_canCollide_20 = false -- 1219
		end -- 1219
		____joint_ref_23.current = ____self_21_friction_22( -- 1218
			____self_21, -- 1218
			____joint_canCollide_20, -- 1219
			joint.bodyA.current, -- 1220
			joint.bodyB.current, -- 1221
			joint.worldPos, -- 1222
			joint.maxForce, -- 1223
			joint.maxTorque -- 1224
		) -- 1224
	end, -- 1204
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1227
		local joint = enode.props -- 1228
		if joint.ref == nil then -- 1228
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1230
			return -- 1231
		end -- 1231
		if joint.jointA.current == nil then -- 1231
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1234
			return -- 1235
		end -- 1235
		if joint.jointB.current == nil then -- 1235
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1238
			return -- 1239
		end -- 1239
		local ____joint_ref_27 = joint.ref -- 1241
		local ____self_25 = Dora.Joint -- 1241
		local ____self_25_gear_26 = ____self_25.gear -- 1241
		local ____joint_canCollide_24 = joint.canCollide -- 1242
		if ____joint_canCollide_24 == nil then -- 1242
			____joint_canCollide_24 = false -- 1242
		end -- 1242
		____joint_ref_27.current = ____self_25_gear_26( -- 1241
			____self_25, -- 1241
			____joint_canCollide_24, -- 1242
			joint.jointA.current, -- 1243
			joint.jointB.current, -- 1244
			joint.ratio or 1 -- 1245
		) -- 1245
	end, -- 1227
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1248
		local joint = enode.props -- 1249
		if joint.ref == nil then -- 1249
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1251
			return -- 1252
		end -- 1252
		if joint.bodyA.current == nil then -- 1252
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1255
			return -- 1256
		end -- 1256
		if joint.bodyB.current == nil then -- 1256
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1259
			return -- 1260
		end -- 1260
		local ____joint_ref_31 = joint.ref -- 1262
		local ____self_29 = Dora.Joint -- 1262
		local ____self_29_spring_30 = ____self_29.spring -- 1262
		local ____joint_canCollide_28 = joint.canCollide -- 1263
		if ____joint_canCollide_28 == nil then -- 1263
			____joint_canCollide_28 = false -- 1263
		end -- 1263
		____joint_ref_31.current = ____self_29_spring_30( -- 1262
			____self_29, -- 1262
			____joint_canCollide_28, -- 1263
			joint.bodyA.current, -- 1264
			joint.bodyB.current, -- 1265
			joint.linearOffset, -- 1266
			joint.angularOffset, -- 1267
			joint.maxForce, -- 1268
			joint.maxTorque, -- 1269
			joint.correctionFactor or 1 -- 1270
		) -- 1270
	end, -- 1248
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1273
		local joint = enode.props -- 1274
		if joint.ref == nil then -- 1274
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1276
			return -- 1277
		end -- 1277
		if joint.body.current == nil then -- 1277
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1280
			return -- 1281
		end -- 1281
		local ____joint_ref_35 = joint.ref -- 1283
		local ____self_33 = Dora.Joint -- 1283
		local ____self_33_move_34 = ____self_33.move -- 1283
		local ____joint_canCollide_32 = joint.canCollide -- 1284
		if ____joint_canCollide_32 == nil then -- 1284
			____joint_canCollide_32 = false -- 1284
		end -- 1284
		____joint_ref_35.current = ____self_33_move_34( -- 1283
			____self_33, -- 1283
			____joint_canCollide_32, -- 1284
			joint.body.current, -- 1285
			joint.targetPos, -- 1286
			joint.maxForce, -- 1287
			joint.frequency, -- 1288
			joint.damping or 0.7 -- 1289
		) -- 1289
	end, -- 1273
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1292
		local joint = enode.props -- 1293
		if joint.ref == nil then -- 1293
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1295
			return -- 1296
		end -- 1296
		if joint.bodyA.current == nil then -- 1296
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1299
			return -- 1300
		end -- 1300
		if joint.bodyB.current == nil then -- 1300
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1303
			return -- 1304
		end -- 1304
		local ____joint_ref_39 = joint.ref -- 1306
		local ____self_37 = Dora.Joint -- 1306
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1306
		local ____joint_canCollide_36 = joint.canCollide -- 1307
		if ____joint_canCollide_36 == nil then -- 1307
			____joint_canCollide_36 = false -- 1307
		end -- 1307
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1306
			____self_37, -- 1306
			____joint_canCollide_36, -- 1307
			joint.bodyA.current, -- 1308
			joint.bodyB.current, -- 1309
			joint.worldPos, -- 1310
			joint.axisAngle, -- 1311
			joint.lowerTranslation or 0, -- 1312
			joint.upperTranslation or 0, -- 1313
			joint.maxMotorForce or 0, -- 1314
			joint.motorSpeed or 0 -- 1315
		) -- 1315
	end, -- 1292
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1318
		local joint = enode.props -- 1319
		if joint.ref == nil then -- 1319
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1321
			return -- 1322
		end -- 1322
		if joint.bodyA.current == nil then -- 1322
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1325
			return -- 1326
		end -- 1326
		if joint.bodyB.current == nil then -- 1326
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1329
			return -- 1330
		end -- 1330
		local ____joint_ref_43 = joint.ref -- 1332
		local ____self_41 = Dora.Joint -- 1332
		local ____self_41_pulley_42 = ____self_41.pulley -- 1332
		local ____joint_canCollide_40 = joint.canCollide -- 1333
		if ____joint_canCollide_40 == nil then -- 1333
			____joint_canCollide_40 = false -- 1333
		end -- 1333
		____joint_ref_43.current = ____self_41_pulley_42( -- 1332
			____self_41, -- 1332
			____joint_canCollide_40, -- 1333
			joint.bodyA.current, -- 1334
			joint.bodyB.current, -- 1335
			joint.anchorA or Dora.Vec2.zero, -- 1336
			joint.anchorB or Dora.Vec2.zero, -- 1337
			joint.groundAnchorA, -- 1338
			joint.groundAnchorB, -- 1339
			joint.ratio or 1 -- 1340
		) -- 1340
	end, -- 1318
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1343
		local joint = enode.props -- 1344
		if joint.ref == nil then -- 1344
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1346
			return -- 1347
		end -- 1347
		if joint.bodyA.current == nil then -- 1347
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1350
			return -- 1351
		end -- 1351
		if joint.bodyB.current == nil then -- 1351
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1354
			return -- 1355
		end -- 1355
		local ____joint_ref_47 = joint.ref -- 1357
		local ____self_45 = Dora.Joint -- 1357
		local ____self_45_revolute_46 = ____self_45.revolute -- 1357
		local ____joint_canCollide_44 = joint.canCollide -- 1358
		if ____joint_canCollide_44 == nil then -- 1358
			____joint_canCollide_44 = false -- 1358
		end -- 1358
		____joint_ref_47.current = ____self_45_revolute_46( -- 1357
			____self_45, -- 1357
			____joint_canCollide_44, -- 1358
			joint.bodyA.current, -- 1359
			joint.bodyB.current, -- 1360
			joint.worldPos, -- 1361
			joint.lowerAngle or 0, -- 1362
			joint.upperAngle or 0, -- 1363
			joint.maxMotorTorque or 0, -- 1364
			joint.motorSpeed or 0 -- 1365
		) -- 1365
	end, -- 1343
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1368
		local joint = enode.props -- 1369
		if joint.ref == nil then -- 1369
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1371
			return -- 1372
		end -- 1372
		if joint.bodyA.current == nil then -- 1372
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1375
			return -- 1376
		end -- 1376
		if joint.bodyB.current == nil then -- 1376
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1379
			return -- 1380
		end -- 1380
		local ____joint_ref_51 = joint.ref -- 1382
		local ____self_49 = Dora.Joint -- 1382
		local ____self_49_rope_50 = ____self_49.rope -- 1382
		local ____joint_canCollide_48 = joint.canCollide -- 1383
		if ____joint_canCollide_48 == nil then -- 1383
			____joint_canCollide_48 = false -- 1383
		end -- 1383
		____joint_ref_51.current = ____self_49_rope_50( -- 1382
			____self_49, -- 1382
			____joint_canCollide_48, -- 1383
			joint.bodyA.current, -- 1384
			joint.bodyB.current, -- 1385
			joint.anchorA or Dora.Vec2.zero, -- 1386
			joint.anchorB or Dora.Vec2.zero, -- 1387
			joint.maxLength or 0 -- 1388
		) -- 1388
	end, -- 1368
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1391
		local joint = enode.props -- 1392
		if joint.ref == nil then -- 1392
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1394
			return -- 1395
		end -- 1395
		if joint.bodyA.current == nil then -- 1395
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1398
			return -- 1399
		end -- 1399
		if joint.bodyB.current == nil then -- 1399
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1402
			return -- 1403
		end -- 1403
		local ____joint_ref_55 = joint.ref -- 1405
		local ____self_53 = Dora.Joint -- 1405
		local ____self_53_weld_54 = ____self_53.weld -- 1405
		local ____joint_canCollide_52 = joint.canCollide -- 1406
		if ____joint_canCollide_52 == nil then -- 1406
			____joint_canCollide_52 = false -- 1406
		end -- 1406
		____joint_ref_55.current = ____self_53_weld_54( -- 1405
			____self_53, -- 1405
			____joint_canCollide_52, -- 1406
			joint.bodyA.current, -- 1407
			joint.bodyB.current, -- 1408
			joint.worldPos, -- 1409
			joint.frequency or 0, -- 1410
			joint.damping or 0 -- 1411
		) -- 1411
	end, -- 1391
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1414
		local joint = enode.props -- 1415
		if joint.ref == nil then -- 1415
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1417
			return -- 1418
		end -- 1418
		if joint.bodyA.current == nil then -- 1418
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1421
			return -- 1422
		end -- 1422
		if joint.bodyB.current == nil then -- 1422
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1425
			return -- 1426
		end -- 1426
		local ____joint_ref_59 = joint.ref -- 1428
		local ____self_57 = Dora.Joint -- 1428
		local ____self_57_wheel_58 = ____self_57.wheel -- 1428
		local ____joint_canCollide_56 = joint.canCollide -- 1429
		if ____joint_canCollide_56 == nil then -- 1429
			____joint_canCollide_56 = false -- 1429
		end -- 1429
		____joint_ref_59.current = ____self_57_wheel_58( -- 1428
			____self_57, -- 1428
			____joint_canCollide_56, -- 1429
			joint.bodyA.current, -- 1430
			joint.bodyB.current, -- 1431
			joint.worldPos, -- 1432
			joint.axisAngle, -- 1433
			joint.maxMotorTorque or 0, -- 1434
			joint.motorSpeed or 0, -- 1435
			joint.frequency or 0, -- 1436
			joint.damping or 0.7 -- 1437
		) -- 1437
	end, -- 1414
	["custom-node"] = function(nodeStack, enode, _parent) -- 1440
		local node = getCustomNode(enode) -- 1441
		if node ~= nil then -- 1441
			addChild(nodeStack, node, enode) -- 1443
		end -- 1443
	end, -- 1440
	["custom-element"] = function() -- 1446
	end, -- 1446
	["align-node"] = function(nodeStack, enode, _parent) -- 1447
		addChild( -- 1448
			nodeStack, -- 1448
			getAlignNode(enode), -- 1448
			enode -- 1448
		) -- 1448
	end, -- 1447
	["effek-node"] = function(nodeStack, enode, _parent) -- 1450
		addChild( -- 1451
			nodeStack, -- 1451
			getEffekNode(enode), -- 1451
			enode -- 1451
		) -- 1451
	end, -- 1450
	effek = function(nodeStack, enode, parent) -- 1453
		if #nodeStack > 0 then -- 1453
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1455
			if node then -- 1455
				local effek = enode.props -- 1457
				local handle = node:play( -- 1458
					effek.file, -- 1458
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1458
					effek.z or 0 -- 1458
				) -- 1458
				if handle >= 0 then -- 1458
					if effek.ref then -- 1458
						effek.ref.current = handle -- 1461
					end -- 1461
					if effek.onEnd then -- 1461
						local onEnd = effek.onEnd -- 1461
						node:slot( -- 1465
							"EffekEnd", -- 1465
							function(h) -- 1465
								if handle == h then -- 1465
									onEnd(nil) -- 1467
								end -- 1467
							end -- 1465
						) -- 1465
					end -- 1465
				end -- 1465
			else -- 1465
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1473
			end -- 1473
		end -- 1473
	end, -- 1453
	["tile-node"] = function(nodeStack, enode, parent) -- 1477
		local cnode = getTileNode(enode) -- 1478
		if cnode ~= nil then -- 1478
			addChild(nodeStack, cnode, enode) -- 1480
		end -- 1480
	end -- 1477
} -- 1477
local roots = {} -- 1533
warnedUnkeyedChildTypes = {} -- 1534
local renderQueued = false -- 1535
local queuedRoots = {} -- 1536
local trackingRoot -- 1537
local function isElementList(node) -- 1541
	return node.type == nil -- 1542
end -- 1541
local function getRenderableElement(renderable) -- 1576
	if type(renderable) == "function" then -- 1576
		return renderable() -- 1578
	end -- 1578
	return renderable -- 1580
end -- 1576
local function removeRoot(root) -- 1821
	for i = 1, #roots do -- 1821
		if roots[i] == root then -- 1821
			table.remove(roots, i) -- 1824
			break -- 1825
		end -- 1825
	end -- 1825
end -- 1821
local function toElementList(node) -- 2396
	if isElementList(node) then -- 2396
		return node -- 2398
	end -- 2398
	return {node} -- 2400
end -- 2396
local function scheduleRootRender(root) -- 2403
	if not root.active then -- 2403
		return -- 2404
	end -- 2404
	for i = 1, #queuedRoots do -- 2404
		if queuedRoots[i] == root then -- 2404
			return -- 2406
		end -- 2406
	end -- 2406
	queuedRoots[#queuedRoots + 1] = root -- 2408
	if renderQueued then -- 2408
		return -- 2409
	end -- 2409
	renderQueued = true -- 2410
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2411
		renderQueued = false -- 2412
		local updatingRoots = queuedRoots -- 2413
		queuedRoots = {} -- 2414
		for i = 1, #updatingRoots do -- 2414
			updatingRoots[i]:update() -- 2416
		end -- 2416
	end)) -- 2411
end -- 2403
____exports.Root = __TS__Class() -- 2421
local Root = ____exports.Root -- 2421
Root.name = "Root" -- 2421
function Root.prototype.____constructor(self, parent) -- 2435
	self.parent = parent -- 2435
	self.mounted = {} -- 2422
	self.signals = {} -- 2424
	self.hookFrames = {} -- 2425
	self.keyedHookFrames = {} -- 2426
	self.nextKeyedHookFrames = {} -- 2427
	self.usedHookFrames = {} -- 2428
	self.previousHookFrames = {} -- 2429
	self.pendingEffects = {} -- 2430
	self.pendingCleanups = {} -- 2431
	self.hookFrameIndex = 0 -- 2432
	self.active = true -- 2433
end -- 2435
function Root.prototype.render(self, enode) -- 2437
	if not self.active then -- 2437
		roots[#roots + 1] = self -- 2439
		self.active = true -- 2440
	end -- 2440
	self.renderable = enode -- 2442
	self:update() -- 2443
end -- 2437
function Root.prototype.update(self) -- 2446
	if not self.active or self.renderable == nil then -- 2446
		return -- 2447
	end -- 2447
	self:unsubscribeSignals() -- 2448
	local lastTrackingRoot = trackingRoot -- 2449
	local lastRenderingHookRoot = renderingHookRoot -- 2450
	trackingRoot = self -- 2451
	renderingHookRoot = self -- 2452
	local elements -- 2453
	do -- 2453
		local ____try, ____error = pcall(function() -- 2453
			self:beginHookRender() -- 2455
			elements = getRenderableElement(self.renderable) -- 2456
		end) -- 2456
		do -- 2456
			self:finishHookRender() -- 2458
			trackingRoot = lastTrackingRoot -- 2459
			renderingHookRoot = lastRenderingHookRoot -- 2460
		end -- 2460
		if not ____try then -- 2460
			error(____error, 0) -- 2460
		end -- 2460
	end -- 2460
	self.mounted = reconcileChildren( -- 2462
		self.parent, -- 2462
		self.mounted, -- 2462
		toElementList(elements) -- 2462
	) -- 2462
	self:flushEffects() -- 2463
end -- 2446
function Root.prototype.unmount(self) -- 2466
	for i = 1, #self.mounted do -- 2466
		unmountElement(self.mounted[i]) -- 2468
	end -- 2468
	for i = 1, #self.hookFrames do -- 2468
		self:queueFrameCleanup(self.hookFrames[i]) -- 2471
	end -- 2471
	self.pendingEffects = {} -- 2473
	self:flushEffects() -- 2474
	self.mounted = {} -- 2475
	self.renderable = nil -- 2476
	self.hookFrames = {} -- 2477
	self.keyedHookFrames = {} -- 2478
	self.nextKeyedHookFrames = {} -- 2479
	self.usedHookFrames = {} -- 2480
	self.previousHookFrames = {} -- 2481
	self.hookFrameIndex = 0 -- 2482
	self:unsubscribeSignals() -- 2483
	if self.active then -- 2483
		removeRoot(self) -- 2485
		self.active = false -- 2486
	end -- 2486
end -- 2466
function Root.prototype.trackSignal(self, signal) -- 2490
	for i = 1, #self.signals do -- 2490
		if self.signals[i] == signal then -- 2490
			return -- 2492
		end -- 2492
	end -- 2492
	local ____self_signals_70 = self.signals -- 2492
	____self_signals_70[#____self_signals_70 + 1] = signal -- 2494
	signal:addRoot(self) -- 2495
end -- 2490
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2498
	local index = self.hookFrameIndex -- 2499
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2500
	local frame -- 2501
	if key ~= nil then -- 2501
		local framesByKey = self.keyedHookFrames[____type] -- 2503
		if framesByKey ~= nil then -- 2503
			frame = framesByKey[key] -- 2505
			if frame ~= nil and self.usedHookFrames[frame] == true then -- 2505
				frame = nil -- 2507
			end -- 2507
		end -- 2507
		if frame == nil then -- 2507
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2511
		end -- 2511
		local nextFramesByKey = self.nextKeyedHookFrames[____type] -- 2513
		if nextFramesByKey == nil then -- 2513
			nextFramesByKey = {} -- 2515
			self.nextKeyedHookFrames[____type] = nextFramesByKey -- 2516
		end -- 2516
		nextFramesByKey[key] = frame -- 2518
		self.hookFrames[index + 1] = frame -- 2519
	else -- 2519
		frame = self.hookFrames[index + 1] -- 2521
		if frame == nil or self.usedHookFrames[frame] == true or frame.type ~= ____type or frame.key ~= nil then -- 2521
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2528
			self.hookFrames[index + 1] = frame -- 2529
		end -- 2529
	end -- 2529
	frame.hookIndex = 0 -- 2532
	self.usedHookFrames[frame] = true -- 2533
	return frame -- 2534
end -- 2498
function Root.prototype.queueEffect(self, hook, effect) -- 2537
	if hook.cleanup ~= nil then -- 2537
		local ____self_pendingCleanups_71 = self.pendingCleanups -- 2537
		____self_pendingCleanups_71[#____self_pendingCleanups_71 + 1] = hook.cleanup -- 2539
		hook.cleanup = nil -- 2540
	end -- 2540
	local ____self_pendingEffects_72 = self.pendingEffects -- 2540
	____self_pendingEffects_72[#____self_pendingEffects_72 + 1] = {hook = hook, effect = effect} -- 2542
end -- 2537
function Root.prototype.beginHookRender(self) -- 2545
	self.previousHookFrames = {table.unpack(self.hookFrames)} -- 2546
	self.hookFrameIndex = 0 -- 2547
	self.usedHookFrames = {} -- 2548
	self.nextKeyedHookFrames = {} -- 2549
end -- 2545
function Root.prototype.finishHookRender(self) -- 2552
	for i = 1, #self.previousHookFrames do -- 2552
		local frame = self.previousHookFrames[i] -- 2554
		if self.usedHookFrames[frame] ~= true then -- 2554
			self:queueFrameCleanup(frame) -- 2556
		end -- 2556
	end -- 2556
	while #self.hookFrames > self.hookFrameIndex do -- 2556
		table.remove(self.hookFrames) -- 2560
	end -- 2560
	self.keyedHookFrames = self.nextKeyedHookFrames -- 2562
	self.previousHookFrames = {} -- 2563
end -- 2552
function Root.prototype.unsubscribeSignals(self) -- 2566
	for i = 1, #self.signals do -- 2566
		self.signals[i]:removeRoot(self) -- 2568
	end -- 2568
	self.signals = {} -- 2570
end -- 2566
function Root.prototype.queueFrameCleanup(self, frame) -- 2573
	for i = 1, #frame.hooks do -- 2573
		local hook = frame.hooks[i] -- 2575
		if hook.cleanup ~= nil then -- 2575
			local ____self_pendingCleanups_73 = self.pendingCleanups -- 2575
			____self_pendingCleanups_73[#____self_pendingCleanups_73 + 1] = hook.cleanup -- 2577
			hook.cleanup = nil -- 2578
		end -- 2578
	end -- 2578
end -- 2573
function Root.prototype.flushEffects(self) -- 2583
	local cleanups = self.pendingCleanups -- 2584
	self.pendingCleanups = {} -- 2585
	for i = 1, #cleanups do -- 2585
		cleanups[i]() -- 2587
	end -- 2587
	local effects = self.pendingEffects -- 2589
	self.pendingEffects = {} -- 2590
	for i = 1, #effects do -- 2590
		local task = effects[i] -- 2592
		local cleanup = task.effect() -- 2593
		if type(cleanup) == "function" then -- 2593
			task.hook.cleanup = cleanup -- 2595
		end -- 2595
	end -- 2595
end -- 2583
function ____exports.createRoot(parent) -- 2601
	local root = __TS__New(____exports.Root, parent) -- 2602
	roots[#roots + 1] = root -- 2603
	return root -- 2604
end -- 2601
____exports.Signal = __TS__Class() -- 2607
local Signal = ____exports.Signal -- 2607
Signal.name = "Signal" -- 2607
function Signal.prototype.____constructor(self, item) -- 2610
	self.item = item -- 2610
	self.roots = {} -- 2608
end -- 2610
function Signal.prototype.addRoot(self, root) -- 2627
	for i = 1, #self.roots do -- 2627
		if self.roots[i] == root then -- 2627
			return -- 2629
		end -- 2629
	end -- 2629
	local ____self_roots_74 = self.roots -- 2629
	____self_roots_74[#____self_roots_74 + 1] = root -- 2631
end -- 2627
function Signal.prototype.removeRoot(self, root) -- 2634
	for i = 1, #self.roots do -- 2634
		if self.roots[i] == root then -- 2634
			table.remove(self.roots, i) -- 2637
			break -- 2638
		end -- 2638
	end -- 2638
end -- 2634
__TS__SetDescriptor( -- 2634
	Signal.prototype, -- 2634
	"value", -- 2634
	{ -- 2634
		get = function(self) -- 2634
			if trackingRoot ~= nil then -- 2634
				trackingRoot:trackSignal(self) -- 2614
			end -- 2614
			return self.item -- 2616
		end, -- 2616
		set = function(self, value) -- 2616
			if self.item == value then -- 2616
				return -- 2620
			end -- 2620
			self.item = value -- 2621
			for i = 1, #self.roots do -- 2621
				scheduleRootRender(self.roots[i]) -- 2623
			end -- 2623
		end -- 2623
	}, -- 2623
	true -- 2623
) -- 2623
function ____exports.signal(value) -- 2644
	return __TS__New(____exports.Signal, value) -- 2645
end -- 2644
function ____exports.reference(item) -- 2648
	local ____item_75 = item -- 2649
	if ____item_75 == nil then -- 2649
		____item_75 = nil -- 2649
	end -- 2649
	return {current = ____item_75} -- 2649
end -- 2648
local function hookDepsEqual(oldDeps, newDeps) -- 2652
	if oldDeps == nil or newDeps == nil then -- 2652
		return false -- 2653
	end -- 2653
	if #oldDeps ~= #newDeps then -- 2653
		return false -- 2654
	end -- 2654
	for i = 1, #oldDeps do -- 2654
		if oldDeps[i] ~= newDeps[i] then -- 2654
			return false -- 2656
		end -- 2656
	end -- 2656
	return true -- 2658
end -- 2652
local function copyDeps(deps) -- 2661
	if deps == nil then -- 2661
		return nil -- 2662
	end -- 2662
	local copied = {} -- 2663
	for i = 1, #deps do -- 2663
		copied[#copied + 1] = deps[i] -- 2665
	end -- 2665
	return copied -- 2667
end -- 2661
function ____exports.useMemo(factory, deps) -- 2670
	local frame = currentHookFrame -- 2671
	if frame == nil then -- 2671
		error("useMemo() can only be called inside a function component") -- 2673
	end -- 2673
	local index = frame.hookIndex -- 2675
	frame.hookIndex = frame.hookIndex + 1 -- 2676
	local hook = frame.hooks[index + 1] -- 2677
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2677
		hook = { -- 2679
			value = factory(), -- 2679
			deps = copyDeps(deps) -- 2679
		} -- 2679
		frame.hooks[index + 1] = hook -- 2680
	end -- 2680
	return hook.value -- 2682
end -- 2670
function ____exports.useCallback(callback, deps) -- 2685
	local frame = currentHookFrame -- 2686
	if frame == nil then -- 2686
		error("useCallback() can only be called inside a function component") -- 2688
	end -- 2688
	local actualDeps = deps or ({}) -- 2690
	local index = frame.hookIndex -- 2691
	frame.hookIndex = frame.hookIndex + 1 -- 2692
	local hook = frame.hooks[index + 1] -- 2693
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2693
		hook = { -- 2695
			value = callback, -- 2695
			deps = copyDeps(actualDeps) -- 2695
		} -- 2695
		frame.hooks[index + 1] = hook -- 2696
	end -- 2696
	return hook.value -- 2698
end -- 2685
function ____exports.useEffect(effect, deps) -- 2701
	local frame = currentHookFrame -- 2702
	if frame == nil or renderingHookRoot == nil then -- 2702
		error("useEffect() can only be called inside a function component") -- 2704
	end -- 2704
	local index = frame.hookIndex -- 2706
	frame.hookIndex = frame.hookIndex + 1 -- 2707
	local hook = frame.hooks[index + 1] -- 2708
	if hook == nil then -- 2708
		hook = {value = nil} -- 2710
		frame.hooks[index + 1] = hook -- 2711
	end -- 2711
	if not hookDepsEqual(hook.deps, deps) then -- 2711
		hook.deps = copyDeps(deps) -- 2714
		renderingHookRoot:queueEffect(hook, effect) -- 2715
	end -- 2715
end -- 2701
function ____exports.useRef(item) -- 2719
	local frame = currentHookFrame -- 2720
	if frame == nil then -- 2720
		Warn("useRef() called outside a function component; falling back to reference()") -- 2722
		return ____exports.reference(item) -- 2723
	end -- 2723
	local index = frame.hookIndex -- 2725
	frame.hookIndex = frame.hookIndex + 1 -- 2726
	local hook = frame.hooks[index + 1] -- 2727
	if hook == nil then -- 2727
		hook = {value = ____exports.reference(item)} -- 2729
		frame.hooks[index + 1] = hook -- 2730
	end -- 2730
	return hook.value -- 2732
end -- 2719
function ____exports.useSignal(value) -- 2735
	local frame = currentHookFrame -- 2736
	if frame == nil then -- 2736
		error("useSignal() can only be called inside a function component") -- 2738
	end -- 2738
	local index = frame.hookIndex -- 2740
	frame.hookIndex = frame.hookIndex + 1 -- 2741
	local hook = frame.hooks[index + 1] -- 2742
	if hook == nil then -- 2742
		hook = {value = ____exports.signal(value)} -- 2744
		frame.hooks[index + 1] = hook -- 2745
	end -- 2745
	return hook.value -- 2747
end -- 2735
local function getPreload(preloadList, node) -- 2750
	if type(node) ~= "table" then -- 2750
		return -- 2752
	end -- 2752
	local enode = node -- 2754
	if enode.type == nil then -- 2754
		local list = node -- 2756
		if #list > 0 then -- 2756
			for i = 1, #list do -- 2756
				getPreload(preloadList, list[i]) -- 2759
			end -- 2759
		end -- 2759
	else -- 2759
		repeat -- 2759
			local ____switch651 = enode.type -- 2759
			local sprite, playable, frame, model, spine, dragonBone, label -- 2759
			local ____cond651 = ____switch651 == "sprite" -- 2759
			if ____cond651 then -- 2759
				sprite = enode.props -- 2765
				if sprite.file then -- 2765
					preloadList[#preloadList + 1] = sprite.file -- 2767
				end -- 2767
				break -- 2769
			end -- 2769
			____cond651 = ____cond651 or ____switch651 == "playable" -- 2769
			if ____cond651 then -- 2769
				playable = enode.props -- 2771
				preloadList[#preloadList + 1] = playable.file -- 2772
				break -- 2773
			end -- 2773
			____cond651 = ____cond651 or ____switch651 == "frame" -- 2773
			if ____cond651 then -- 2773
				frame = enode.props -- 2775
				preloadList[#preloadList + 1] = frame.file -- 2776
				break -- 2777
			end -- 2777
			____cond651 = ____cond651 or ____switch651 == "model" -- 2777
			if ____cond651 then -- 2777
				model = enode.props -- 2779
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2780
				break -- 2781
			end -- 2781
			____cond651 = ____cond651 or ____switch651 == "spine" -- 2781
			if ____cond651 then -- 2781
				spine = enode.props -- 2783
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2784
				break -- 2785
			end -- 2785
			____cond651 = ____cond651 or ____switch651 == "dragon-bone" -- 2785
			if ____cond651 then -- 2785
				dragonBone = enode.props -- 2787
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2788
				break -- 2789
			end -- 2789
			____cond651 = ____cond651 or ____switch651 == "label" -- 2789
			if ____cond651 then -- 2789
				label = enode.props -- 2791
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2792
				break -- 2793
			end -- 2793
		until true -- 2793
	end -- 2793
	getPreload(preloadList, enode.children) -- 2796
end -- 2750
function ____exports.preloadAsync(enode, handler) -- 2799
	local preloadList = {} -- 2800
	getPreload(preloadList, enode) -- 2801
	Dora.Cache:loadAsync(preloadList, handler) -- 2802
end -- 2799
function ____exports.toAction(enode) -- 2805
	local actionDef = ____exports.reference() -- 2806
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2807
	if not actionDef.current then -- 2807
		error("failed to create action") -- 2808
	end -- 2808
	return actionDef.current -- 2809
end -- 2805
return ____exports -- 2805