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
local Warn, renderFunctionComponent, applyAutoEnableProps, visitAction, visitNode, getElementKey, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, isRunnableActionElement, shallowPropsEqual, collectRunnableActionElements, collectContactElements, getContactKey, patchPhysicsWorldInputs, actionElementEqual, actionChildrenEqual, createActionDef, structuralChildrenEqual, runActionChildren, patchActionChildren, toHostElement, createHostNode, getElementChildren, shouldRecreate, isEventProp, getEventSlot, isPatchableEventProp, patchEventProp, patchContactFilterProp, patchUpdateProp, patchRenderProp, clearRemovedProp, getAlignStyleText, patchPlayableProps, patchAudioSourceProps, patchParticleProps, patchAlignNodeProps, patchLineProps, clearRef, patchRef, applyProp, patchProps, addChildToParent, mountElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap, renderingHookRoot, currentHookFrame -- 1
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
function getElementKey(element) -- 1538
	local props = element.props -- 1539
	local ____props_60 -- 1540
	if props then -- 1540
		____props_60 = props.key -- 1540
	else -- 1540
		____props_60 = nil -- 1540
	end -- 1540
	return ____props_60 -- 1540
end -- 1540
function getPrimitiveLabelText(enode) -- 1550
	local label = enode.props -- 1551
	local text = label.text or "" -- 1552
	for i = 1, #enode.children do -- 1552
		local child = enode.children[i] -- 1554
		if type(child) ~= "table" then -- 1554
			text = text .. tostring(child) -- 1556
		end -- 1556
	end -- 1556
	return text -- 1559
end -- 1559
function isDrawShapeElement(element) -- 1562
	repeat -- 1562
		local ____switch335 = element.type -- 1562
		local ____cond335 = ____switch335 == "dot-shape" or ____switch335 == "segment-shape" or ____switch335 == "rect-shape" or ____switch335 == "polygon-shape" or ____switch335 == "verts-shape" -- 1562
		if ____cond335 then -- 1562
			return true -- 1569
		end -- 1569
	until true -- 1569
	return false -- 1571
end -- 1571
function isBodyFixtureElement(element) -- 1574
	repeat -- 1574
		local ____switch337 = element.type -- 1574
		local ____cond337 = ____switch337 == "rect-fixture" or ____switch337 == "polygon-fixture" or ____switch337 == "multi-fixture" or ____switch337 == "disk-fixture" or ____switch337 == "chain-fixture" -- 1574
		if ____cond337 then -- 1574
			return true -- 1581
		end -- 1581
	until true -- 1581
	return false -- 1583
end -- 1583
function isPhysicsWorldInputElement(element) -- 1586
	return element.type == "contact" -- 1587
end -- 1587
function isRunnableActionElement(element) -- 1590
	if element.type == "loop" then -- 1590
		return true -- 1591
	end -- 1591
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1592
end -- 1592
function shallowPropsEqual(oldProps, newProps) -- 1603
	for k, v in pairs(oldProps) do -- 1604
		if k ~= "ref" and newProps[k] ~= v then -- 1604
			return false -- 1605
		end -- 1605
	end -- 1605
	for k, v in pairs(newProps) do -- 1607
		if k ~= "ref" and oldProps[k] ~= v then -- 1607
			return false -- 1608
		end -- 1608
	end -- 1608
	return true -- 1610
end -- 1610
function collectRunnableActionElements(element) -- 1613
	local actions = {} -- 1614
	for i = 1, #element.children do -- 1614
		local child = element.children[i] -- 1616
		if type(child) == "table" and isRunnableActionElement(child) then -- 1616
			actions[#actions + 1] = child -- 1618
		end -- 1618
	end -- 1618
	return actions -- 1621
end -- 1621
function collectContactElements(element) -- 1624
	local contacts = {} -- 1625
	for i = 1, #element.children do -- 1625
		local child = element.children[i] -- 1627
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1627
			contacts[#contacts + 1] = child -- 1629
		end -- 1629
	end -- 1629
	return contacts -- 1632
end -- 1632
function getContactKey(contact) -- 1635
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1636
end -- 1636
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1639
	local oldContacts = collectContactElements(oldElement) -- 1640
	local newContacts = collectContactElements(newElement) -- 1641
	local oldByKey = {} -- 1642
	local newByKey = {} -- 1643
	for i = 1, #oldContacts do -- 1643
		local contact = oldContacts[i].props -- 1645
		oldByKey[getContactKey(contact)] = contact -- 1646
	end -- 1646
	for i = 1, #newContacts do -- 1646
		local contact = newContacts[i].props -- 1649
		newByKey[getContactKey(contact)] = contact -- 1650
	end -- 1650
	for i = 1, #oldContacts do -- 1650
		local oldContact = oldContacts[i].props -- 1653
		local key = getContactKey(oldContact) -- 1654
		local newContact = newByKey[key] -- 1655
		if newContact == nil then -- 1655
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1657
		elseif oldContact.enabled ~= newContact.enabled then -- 1657
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1659
		end -- 1659
	end -- 1659
	for i = 1, #newContacts do -- 1659
		local newContact = newContacts[i].props -- 1663
		if oldByKey[getContactKey(newContact)] == nil then -- 1663
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1665
		end -- 1665
	end -- 1665
end -- 1665
function actionElementEqual(oldElement, newElement) -- 1670
	if oldElement.type ~= newElement.type then -- 1670
		return false -- 1671
	end -- 1671
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1671
		return false -- 1672
	end -- 1672
	if #oldElement.children ~= #newElement.children then -- 1672
		return false -- 1673
	end -- 1673
	for i = 1, #oldElement.children do -- 1673
		local oldChild = oldElement.children[i] -- 1675
		local newChild = newElement.children[i] -- 1676
		if type(oldChild) ~= type(newChild) then -- 1676
			return false -- 1677
		end -- 1677
		if type(oldChild) == "table" then -- 1677
			if not actionElementEqual(oldChild, newChild) then -- 1677
				return false -- 1679
			end -- 1679
		elseif oldChild ~= newChild then -- 1679
			return false -- 1681
		end -- 1681
	end -- 1681
	return true -- 1684
end -- 1684
function actionChildrenEqual(oldElement, newElement) -- 1687
	local oldActions = collectRunnableActionElements(oldElement) -- 1688
	local newActions = collectRunnableActionElements(newElement) -- 1689
	if #oldActions ~= #newActions then -- 1689
		return false -- 1690
	end -- 1690
	for i = 1, #oldActions do -- 1690
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1690
			return false -- 1692
		end -- 1692
	end -- 1692
	return true -- 1694
end -- 1694
function createActionDef(actionElement) -- 1697
	if actionElement.type == "loop" then -- 1697
		local actionStack = {} -- 1699
		for i = 1, #actionElement.children do -- 1699
			visitAction(actionStack, actionElement.children[i]) -- 1701
		end -- 1701
		if #actionStack == 1 then -- 1701
			return actionStack[1], true -- 1704
		elseif #actionStack > 1 then -- 1704
			local loop = actionElement.props -- 1706
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1707
		end -- 1707
		return nil, true -- 1709
	end -- 1709
	local actionStack = {} -- 1711
	visitAction(actionStack, actionElement) -- 1712
	return #actionStack == 1 and actionStack[1] or nil, false -- 1713
end -- 1713
function structuralChildrenEqual(oldElement, newElement, check) -- 1716
	local oldChildren = {} -- 1722
	local newChildren = {} -- 1723
	for i = 1, #oldElement.children do -- 1723
		local child = oldElement.children[i] -- 1725
		if type(child) == "table" and check(child) then -- 1725
			oldChildren[#oldChildren + 1] = child -- 1727
		end -- 1727
	end -- 1727
	for i = 1, #newElement.children do -- 1727
		local child = newElement.children[i] -- 1731
		if type(child) == "table" and check(child) then -- 1731
			newChildren[#newChildren + 1] = child -- 1733
		end -- 1733
	end -- 1733
	if #oldChildren ~= #newChildren then -- 1733
		return false -- 1736
	end -- 1736
	for i = 1, #oldChildren do -- 1736
		local oldChild = oldChildren[i] -- 1738
		local newChild = newChildren[i] -- 1739
		if oldChild.type ~= newChild.type then -- 1739
			return false -- 1740
		end -- 1740
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1740
			return false -- 1741
		end -- 1741
	end -- 1741
	return true -- 1743
end -- 1743
function runActionChildren(node, element) -- 1746
	local actionChildren = collectRunnableActionElements(element) -- 1747
	local exclusiveActions = {} -- 1748
	local exclusiveLoop -- 1749
	local warnedExclusiveConflict = false -- 1750
	for i = 1, #actionChildren do -- 1750
		do -- 1750
			local actionElement = actionChildren[i] -- 1752
			local action, loop = createActionDef(actionElement) -- 1753
			if action == nil then -- 1753
				goto __continue389 -- 1754
			end -- 1754
			if actionElement.props.exclusive == true then -- 1754
				if exclusiveLoop == nil then -- 1754
					exclusiveLoop = loop -- 1757
				end -- 1757
				if exclusiveLoop == loop then -- 1757
					exclusiveActions[#exclusiveActions + 1] = action -- 1760
				elseif not warnedExclusiveConflict then -- 1760
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1762
					warnedExclusiveConflict = true -- 1763
				end -- 1763
			end -- 1763
		end -- 1763
		::__continue389:: -- 1763
	end -- 1763
	if #exclusiveActions == 1 then -- 1763
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1768
	elseif #exclusiveActions > 1 then -- 1768
		node:perform( -- 1770
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1770
			exclusiveLoop == true -- 1770
		) -- 1770
	end -- 1770
	for i = 1, #actionChildren do -- 1770
		do -- 1770
			local actionElement = actionChildren[i] -- 1773
			if actionElement.props.exclusive == true then -- 1773
				goto __continue397 -- 1774
			end -- 1774
			local action, loop = createActionDef(actionElement) -- 1775
			if action ~= nil then -- 1775
				node:runAction(action, loop) -- 1777
			end -- 1777
		end -- 1777
		::__continue397:: -- 1777
	end -- 1777
end -- 1777
function patchActionChildren(node, oldElement, newElement) -- 1782
	if not actionChildrenEqual(oldElement, newElement) then -- 1782
		runActionChildren(node, newElement) -- 1784
	end -- 1784
end -- 1784
function toHostElement(enode, parent) -- 1797
	local hostChildren = {} -- 1798
	local props = {} -- 1799
	if enode.props ~= nil then -- 1799
		for k, v in pairs(enode.props) do -- 1801
			props[k] = v -- 1802
		end -- 1802
	end -- 1802
	if enode.type == "label" then -- 1802
		for i = 1, #enode.children do -- 1802
			local child = enode.children[i] -- 1807
			if type(child) ~= "table" then -- 1807
				hostChildren[#hostChildren + 1] = child -- 1809
			end -- 1809
		end -- 1809
	elseif enode.type == "draw-node" then -- 1809
		for i = 1, #enode.children do -- 1809
			local child = enode.children[i] -- 1814
			if type(child) == "table" and isDrawShapeElement(child) then -- 1814
				hostChildren[#hostChildren + 1] = child -- 1816
			end -- 1816
		end -- 1816
	elseif enode.type == "body" then -- 1816
		for i = 1, #enode.children do -- 1816
			local child = enode.children[i] -- 1821
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1821
				hostChildren[#hostChildren + 1] = child -- 1823
			end -- 1823
		end -- 1823
	elseif enode.type == "physics-world" then -- 1823
		for i = 1, #enode.children do -- 1823
			local child = enode.children[i] -- 1828
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1828
				hostChildren[#hostChildren + 1] = child -- 1830
			end -- 1830
		end -- 1830
	end -- 1830
	if enode.type == "body" and props.world == nil then -- 1830
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1835
		if world ~= nil then -- 1835
			props.world = world -- 1837
		end -- 1837
	end -- 1837
	return {type = enode.type, props = props, children = hostChildren} -- 1840
end -- 1840
function createHostNode(enode, parent) -- 1847
	local nodeStack = {} -- 1848
	visitNode( -- 1849
		nodeStack, -- 1849
		toHostElement(enode, parent) -- 1849
	) -- 1849
	if #nodeStack == 1 then -- 1849
		return nodeStack[1] -- 1851
	elseif #nodeStack > 1 then -- 1851
		local node = Dora.Node() -- 1853
		for i = 1, #nodeStack do -- 1853
			node:addChild(nodeStack[i]) -- 1855
		end -- 1855
		return node -- 1857
	end -- 1857
	return nil -- 1859
end -- 1859
function getElementChildren(enode) -- 1862
	local children = {} -- 1863
	if enode.type == "draw-node" or enode.type == "body" then -- 1863
		return children -- 1864
	end -- 1864
	for i = 1, #enode.children do -- 1864
		local child = enode.children[i] -- 1866
		if type(child) == "table" then -- 1866
			local childElement = child -- 1868
			if childElement.type ~= nil then -- 1868
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1868
					children[#children + 1] = childElement -- 1874
				end -- 1874
			else -- 1874
				local list = child -- 1877
				for j = 1, #list do -- 1877
					local item = list[j] -- 1879
					if type(item) == "table" and item.type ~= nil then -- 1879
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1879
							children[#children + 1] = item -- 1885
						end -- 1885
					end -- 1885
				end -- 1885
			end -- 1885
		end -- 1885
	end -- 1885
	return children -- 1892
end -- 1892
function shouldRecreate(oldElement, newElement) -- 1895
	if oldElement.type ~= newElement.type then -- 1895
		return true -- 1896
	end -- 1896
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1896
		return true -- 1897
	end -- 1897
	local oldProps = oldElement.props -- 1898
	local newProps = newElement.props -- 1899
	if newElement.type == "draw-node" then -- 1899
		return true -- 1900
	end -- 1900
	for k, v in pairs(oldProps) do -- 1901
		if k == "onMount" and newProps[k] ~= v then -- 1901
			return true -- 1903
		end -- 1903
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1903
			return true -- 1906
		end -- 1906
	end -- 1906
	for k, v in pairs(newProps) do -- 1909
		if k == "onMount" and oldProps[k] ~= v then -- 1909
			return true -- 1911
		end -- 1911
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1911
			return true -- 1914
		end -- 1914
	end -- 1914
	repeat -- 1914
		local ____switch446 = newElement.type -- 1914
		local ____cond446 = ____switch446 == "grid" -- 1914
		if ____cond446 then -- 1914
			return oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY -- 1919
		end -- 1919
		____cond446 = ____cond446 or (____switch446 == "sprite" or ____switch446 == "video-node" or ____switch446 == "tic80-node" or ____switch446 == "audio-source" or ____switch446 == "particle" or ____switch446 == "tile-node" or ____switch446 == "playable" or ____switch446 == "dragon-bone" or ____switch446 == "spine" or ____switch446 == "model") -- 1919
		if ____cond446 then -- 1919
			return oldProps.file ~= newProps.file -- 1930
		end -- 1930
		____cond446 = ____cond446 or ____switch446 == "label" -- 1930
		if ____cond446 then -- 1930
			return oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf -- 1932
		end -- 1932
		____cond446 = ____cond446 or ____switch446 == "align-node" -- 1932
		if ____cond446 then -- 1932
			return oldProps.windowRoot ~= newProps.windowRoot -- 1934
		end -- 1934
		____cond446 = ____cond446 or ____switch446 == "custom-node" -- 1934
		if ____cond446 then -- 1934
			return oldProps.onCreate ~= newProps.onCreate -- 1936
		end -- 1936
		____cond446 = ____cond446 or ____switch446 == "body" -- 1936
		if ____cond446 then -- 1936
			return oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement) -- 1938
		end -- 1938
	until true -- 1938
	return false -- 1945
end -- 1945
function isEventProp(key) -- 1948
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1949
end -- 1949
function getEventSlot(key) -- 1952
	repeat -- 1952
		local ____switch449 = key -- 1952
		local ____cond449 = ____switch449 == "onActionEnd" -- 1952
		if ____cond449 then -- 1952
			return "ActionEnd" -- 1954
		end -- 1954
		____cond449 = ____cond449 or ____switch449 == "onTapFilter" -- 1954
		if ____cond449 then -- 1954
			return "TapFilter" -- 1955
		end -- 1955
		____cond449 = ____cond449 or ____switch449 == "onTapBegan" -- 1955
		if ____cond449 then -- 1955
			return "TapBegan" -- 1956
		end -- 1956
		____cond449 = ____cond449 or ____switch449 == "onTapEnded" -- 1956
		if ____cond449 then -- 1956
			return "TapEnded" -- 1957
		end -- 1957
		____cond449 = ____cond449 or ____switch449 == "onTapped" -- 1957
		if ____cond449 then -- 1957
			return "Tapped" -- 1958
		end -- 1958
		____cond449 = ____cond449 or ____switch449 == "onTapMoved" -- 1958
		if ____cond449 then -- 1958
			return "TapMoved" -- 1959
		end -- 1959
		____cond449 = ____cond449 or ____switch449 == "onMouseWheel" -- 1959
		if ____cond449 then -- 1959
			return "MouseWheel" -- 1960
		end -- 1960
		____cond449 = ____cond449 or ____switch449 == "onGesture" -- 1960
		if ____cond449 then -- 1960
			return "Gesture" -- 1961
		end -- 1961
		____cond449 = ____cond449 or ____switch449 == "onEnter" -- 1961
		if ____cond449 then -- 1961
			return "Enter" -- 1962
		end -- 1962
		____cond449 = ____cond449 or ____switch449 == "onExit" -- 1962
		if ____cond449 then -- 1962
			return "Exit" -- 1963
		end -- 1963
		____cond449 = ____cond449 or ____switch449 == "onCleanup" -- 1963
		if ____cond449 then -- 1963
			return "Cleanup" -- 1964
		end -- 1964
		____cond449 = ____cond449 or ____switch449 == "onKeyDown" -- 1964
		if ____cond449 then -- 1964
			return "KeyDown" -- 1965
		end -- 1965
		____cond449 = ____cond449 or ____switch449 == "onKeyUp" -- 1965
		if ____cond449 then -- 1965
			return "KeyUp" -- 1966
		end -- 1966
		____cond449 = ____cond449 or ____switch449 == "onKeyPressed" -- 1966
		if ____cond449 then -- 1966
			return "KeyPressed" -- 1967
		end -- 1967
		____cond449 = ____cond449 or ____switch449 == "onAttachIME" -- 1967
		if ____cond449 then -- 1967
			return "AttachIME" -- 1968
		end -- 1968
		____cond449 = ____cond449 or ____switch449 == "onDetachIME" -- 1968
		if ____cond449 then -- 1968
			return "DetachIME" -- 1969
		end -- 1969
		____cond449 = ____cond449 or ____switch449 == "onTextInput" -- 1969
		if ____cond449 then -- 1969
			return "TextInput" -- 1970
		end -- 1970
		____cond449 = ____cond449 or ____switch449 == "onTextEditing" -- 1970
		if ____cond449 then -- 1970
			return "TextEditing" -- 1971
		end -- 1971
		____cond449 = ____cond449 or ____switch449 == "onButtonDown" -- 1971
		if ____cond449 then -- 1971
			return "ButtonDown" -- 1972
		end -- 1972
		____cond449 = ____cond449 or ____switch449 == "onButtonUp" -- 1972
		if ____cond449 then -- 1972
			return "ButtonUp" -- 1973
		end -- 1973
		____cond449 = ____cond449 or ____switch449 == "onAxis" -- 1973
		if ____cond449 then -- 1973
			return "Axis" -- 1974
		end -- 1974
		____cond449 = ____cond449 or ____switch449 == "onAnimationEnd" -- 1974
		if ____cond449 then -- 1974
			return "AnimationEnd" -- 1975
		end -- 1975
		____cond449 = ____cond449 or ____switch449 == "onFinished" -- 1975
		if ____cond449 then -- 1975
			return "Finished" -- 1976
		end -- 1976
		____cond449 = ____cond449 or ____switch449 == "onLayout" -- 1976
		if ____cond449 then -- 1976
			return "AlignLayout" -- 1977
		end -- 1977
		____cond449 = ____cond449 or ____switch449 == "onBodyEnter" -- 1977
		if ____cond449 then -- 1977
			return "BodyEnter" -- 1978
		end -- 1978
		____cond449 = ____cond449 or ____switch449 == "onBodyLeave" -- 1978
		if ____cond449 then -- 1978
			return "BodyLeave" -- 1979
		end -- 1979
		____cond449 = ____cond449 or ____switch449 == "onContactStart" -- 1979
		if ____cond449 then -- 1979
			return "ContactStart" -- 1980
		end -- 1980
		____cond449 = ____cond449 or ____switch449 == "onContactEnd" -- 1980
		if ____cond449 then -- 1980
			return "ContactEnd" -- 1981
		end -- 1981
	until true -- 1981
	return nil -- 1983
end -- 1983
function isPatchableEventProp(key) -- 1986
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" or key == "onRender" -- 1987
end -- 1987
function patchEventProp(node, key, value) -- 1990
	local slotName = getEventSlot(key) -- 1991
	if slotName == nil then -- 1991
		return -- 1992
	end -- 1992
	node:slot(slotName):clear() -- 1993
	if value ~= nil then -- 1993
		node:slot(slotName, value) -- 1995
	end -- 1995
end -- 1995
function patchContactFilterProp(node, value) -- 1999
	local body = Dora.tolua.cast(node, "Body") -- 2000
	if body == nil then -- 2000
		return -- 2001
	end -- 2001
	if value == nil then -- 2001
		body:onContactFilter(function() return true end) -- 2003
	else -- 2003
		body:onContactFilter(value) -- 2005
	end -- 2005
end -- 2005
function patchUpdateProp(node, value) -- 2009
	if value == nil then -- 2009
		node:unschedule() -- 2011
	elseif type(value) == "thread" then -- 2011
		node:schedule(value) -- 2013
	else -- 2013
		node:schedule(value) -- 2015
	end -- 2015
end -- 2015
function patchRenderProp(node, value) -- 2019
	node:clearRender() -- 2020
	if value == nil then -- 2020
		return -- 2022
	end -- 2022
	node:onRender(value) -- 2024
end -- 2024
function clearRemovedProp(node, key) -- 2027
	repeat -- 2027
		local ____switch466 = key -- 2027
		local ____cond466 = ____switch466 == "transformTarget" or ____switch466 == "stencil" -- 2027
		if ____cond466 then -- 2027
			node[key] = nil -- 2031
			return true -- 2032
		end -- 2032
	until true -- 2032
	return false -- 2034
end -- 2034
function getAlignStyleText(style) -- 2037
	local items = {} -- 2038
	for k, v in pairs(style) do -- 2039
		local name = string.gsub(k, "%u", "-%1") -- 2040
		name = string.lower(name) -- 2041
		repeat -- 2041
			local ____switch469 = k -- 2041
			local ____cond469 = ____switch469 == "margin" or ____switch469 == "padding" or ____switch469 == "border" or ____switch469 == "gap" -- 2041
			if ____cond469 then -- 2041
				do -- 2041
					if type(v) == "table" then -- 2041
						local valueStr = table.concat( -- 2046
							__TS__ArrayMap( -- 2046
								v, -- 2046
								function(____, item) return tostring(item) end -- 2046
							), -- 2046
							"," -- 2046
						) -- 2046
						items[#items + 1] = (name .. ":") .. valueStr -- 2047
					else -- 2047
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2049
					end -- 2049
					break -- 2051
				end -- 2051
			end -- 2051
			do -- 2051
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2054
				break -- 2055
			end -- 2055
		until true -- 2055
	end -- 2055
	return table.concat(items, ";") -- 2058
end -- 2058
function patchPlayableProps(node, oldProps, newProps) -- 2061
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2061
		node:play(newProps.play, newProps.loop == true) -- 2063
	end -- 2063
end -- 2063
function patchAudioSourceProps(node, oldProps, newProps) -- 2067
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2067
		local audio = node -- 2069
		repeat -- 2069
			local ____switch478 = newProps.playMode -- 2069
			local ____cond478 = ____switch478 == "normal" -- 2069
			if ____cond478 then -- 2069
				local ____audio_play_62 = audio.play -- 2071
				local ____newProps_delayTime_61 = newProps.delayTime -- 2071
				if ____newProps_delayTime_61 == nil then -- 2071
					____newProps_delayTime_61 = 0 -- 2071
				end -- 2071
				____audio_play_62(audio, ____newProps_delayTime_61) -- 2071
				break -- 2071
			end -- 2071
			____cond478 = ____cond478 or ____switch478 == "background" -- 2071
			if ____cond478 then -- 2071
				audio:playBackground() -- 2072
				break -- 2072
			end -- 2072
			____cond478 = ____cond478 or ____switch478 == "3D" -- 2072
			if ____cond478 then -- 2072
				local ____audio_play3D_64 = audio.play3D -- 2073
				local ____newProps_delayTime_63 = newProps.delayTime -- 2073
				if ____newProps_delayTime_63 == nil then -- 2073
					____newProps_delayTime_63 = 0 -- 2073
				end -- 2073
				____audio_play3D_64(audio, ____newProps_delayTime_63) -- 2073
				break -- 2073
			end -- 2073
		until true -- 2073
	end -- 2073
end -- 2073
function patchParticleProps(node, oldProps, newProps) -- 2078
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2078
		local particle = node -- 2080
		if newProps.emit then -- 2080
			particle:start() -- 2082
		else -- 2082
			particle:stop() -- 2084
		end -- 2084
	end -- 2084
end -- 2084
function patchAlignNodeProps(node, oldProps, newProps) -- 2089
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2089
		node:css(getAlignStyleText(newProps.style)) -- 2091
	end -- 2091
end -- 2091
function patchLineProps(node, oldProps, newProps) -- 2095
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2095
		local ____self_68 = node -- 2095
		local ____self_68_set_69 = ____self_68.set -- 2095
		local ____newProps_verts_67 = newProps.verts -- 2097
		local ____Dora_Color_66 = Dora.Color -- 2097
		local ____newProps_lineColor_65 = newProps.lineColor -- 2097
		if ____newProps_lineColor_65 == nil then -- 2097
			____newProps_lineColor_65 = 4294967295 -- 2097
		end -- 2097
		____self_68_set_69( -- 2097
			____self_68, -- 2097
			____newProps_verts_67, -- 2097
			____Dora_Color_66(____newProps_lineColor_65) -- 2097
		) -- 2097
	end -- 2097
end -- 2097
function clearRef(props, node) -- 2101
	local ref = props.ref -- 2102
	if ref ~= nil and (node == nil or ref.current == node) then -- 2102
		ref.current = nil -- 2104
	end -- 2104
end -- 2104
function patchRef(node, oldProps, newProps) -- 2108
	if oldProps.ref ~= newProps.ref then -- 2108
		clearRef(oldProps, node) -- 2110
		local ref = newProps.ref -- 2111
		if ref ~= nil then -- 2111
			ref.current = node -- 2113
		end -- 2113
	end -- 2113
end -- 2113
function applyProp(node, enode, key, value) -- 2118
	local name = key -- 2119
	repeat -- 2119
		local ____switch493 = name -- 2119
		local ____cond493 = ____switch493 == "key" or ____switch493 == "children" or ____switch493 == "onMount" or ____switch493 == "onUnmount" -- 2119
		if ____cond493 then -- 2119
			return -- 2125
		end -- 2125
		____cond493 = ____cond493 or ____switch493 == "ref" -- 2125
		if ____cond493 then -- 2125
			value.current = node -- 2127
			return -- 2128
		end -- 2128
		____cond493 = ____cond493 or ____switch493 == "anchorX" -- 2128
		if ____cond493 then -- 2128
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2130
			return -- 2131
		end -- 2131
		____cond493 = ____cond493 or ____switch493 == "anchorY" -- 2131
		if ____cond493 then -- 2131
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2133
			return -- 2134
		end -- 2134
		____cond493 = ____cond493 or ____switch493 == "color3" -- 2134
		if ____cond493 then -- 2134
			node.color3 = Dora.Color3(value) -- 2136
			return -- 2137
		end -- 2137
		____cond493 = ____cond493 or ____switch493 == "transformTarget" -- 2137
		if ____cond493 then -- 2137
			node.transformTarget = value.current -- 2139
			return -- 2140
		end -- 2140
		____cond493 = ____cond493 or ____switch493 == "outlineColor" -- 2140
		if ____cond493 then -- 2140
			node[name] = Dora.Color(value) -- 2142
			return -- 2143
		end -- 2143
		____cond493 = ____cond493 or ____switch493 == "smoothLower" -- 2143
		if ____cond493 then -- 2143
			do -- 2143
				local smooth = node.smooth -- 2145
				node.smooth = Dora.Vec2(value, smooth.y) -- 2146
				return -- 2147
			end -- 2147
		end -- 2147
		____cond493 = ____cond493 or ____switch493 == "smoothUpper" -- 2147
		if ____cond493 then -- 2147
			do -- 2147
				local smooth = node.smooth -- 2150
				node.smooth = Dora.Vec2(smooth.x, value) -- 2151
				return -- 2152
			end -- 2152
		end -- 2152
	until true -- 2152
	if isEventProp(key) then -- 2152
		if key == "onUpdate" then -- 2152
			patchUpdateProp(node, value) -- 2157
		elseif key == "onRender" then -- 2157
			patchRenderProp(node, value) -- 2159
		elseif key == "onContactFilter" then -- 2159
			patchContactFilterProp(node, value) -- 2161
		elseif isPatchableEventProp(key) then -- 2161
			patchEventProp(node, key, value) -- 2163
		end -- 2163
		return -- 2165
	end -- 2165
	node[name] = value -- 2167
end -- 2167
function patchProps(node, oldElement, newElement) -- 2170
	local oldProps = oldElement.props -- 2171
	local newProps = newElement.props -- 2172
	for k in pairs(oldProps) do -- 2173
		if k == "onUpdate" and newProps[k] == nil then -- 2173
			patchUpdateProp(node, nil) -- 2175
		elseif k == "onRender" and newProps[k] == nil then -- 2175
			patchRenderProp(node, nil) -- 2177
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2177
			patchContactFilterProp(node, nil) -- 2179
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2179
			patchEventProp(node, k, nil) -- 2181
		elseif newProps[k] == nil then -- 2181
			clearRemovedProp(node, k) -- 2183
		end -- 2183
	end -- 2183
	patchRef(node, oldProps, newProps) -- 2186
	for k, v in pairs(newProps) do -- 2187
		if k ~= "ref" and oldProps[k] ~= v then -- 2187
			applyProp(node, newElement, k, v) -- 2189
		end -- 2189
	end -- 2189
	if newElement.type == "label" then -- 2189
		node.text = getPrimitiveLabelText(newElement) -- 2193
	elseif newElement.type == "physics-world" then -- 2193
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2195
		if world ~= nil then -- 2195
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2197
		end -- 2197
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2197
		patchPlayableProps(node, oldProps, newProps) -- 2205
	elseif newElement.type == "audio-source" then -- 2205
		patchAudioSourceProps(node, oldProps, newProps) -- 2207
	elseif newElement.type == "particle" then -- 2207
		patchParticleProps(node, oldProps, newProps) -- 2209
	elseif newElement.type == "align-node" then -- 2209
		patchAlignNodeProps(node, oldProps, newProps) -- 2211
	elseif newElement.type == "line" then -- 2211
		patchLineProps(node, oldProps, newProps) -- 2213
	end -- 2213
	applyAutoEnableProps(node, newProps) -- 2215
end -- 2215
function addChildToParent(parent, node, props) -- 2218
	if props.tag ~= nil then -- 2218
		parent:addChild(node, props.order or 0, props.tag) -- 2220
	elseif props.order ~= nil then -- 2220
		parent:addChild(node, props.order) -- 2222
	else -- 2222
		parent:addChild(node) -- 2224
	end -- 2224
end -- 2224
function mountElement(parent, enode) -- 2228
	local node = createHostNode(enode, parent) -- 2229
	if node == nil then -- 2229
		return nil -- 2231
	end -- 2231
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2231
		return nil -- 2240
	end -- 2240
	local props = enode.props -- 2242
	addChildToParent(parent, node, props) -- 2243
	local mounted = {element = enode, node = node, children = {}} -- 2244
	runActionChildren(node, enode) -- 2245
	mounted.children = reconcileChildren( -- 2246
		node, -- 2246
		{}, -- 2246
		getElementChildren(enode) -- 2246
	) -- 2246
	return mounted -- 2247
end -- 2247
function unmountElement(mounted) -- 2250
	for i = 1, #mounted.children do -- 2250
		unmountElement(mounted.children[i]) -- 2252
	end -- 2252
	local props = mounted.element.props -- 2254
	if props.onUnmount ~= nil then -- 2254
		props.onUnmount(mounted.node) -- 2256
	end -- 2256
	clearRef(mounted.element.props, mounted.node) -- 2258
	mounted.node:removeFromParent(true) -- 2259
end -- 2259
function reconcileElement(parent, oldMounted, newElement) -- 2262
	if oldMounted == nil then -- 2262
		return mountElement(parent, newElement) -- 2264
	end -- 2264
	if shouldRecreate(oldMounted.element, newElement) then -- 2264
		local oldNode = oldMounted.node -- 2267
		local oldOrder = oldNode.order -- 2268
		local oldTag = oldNode.tag -- 2269
		unmountElement(oldMounted) -- 2270
		local mounted = mountElement(parent, newElement) -- 2271
		if mounted ~= nil then -- 2271
			mounted.node.order = newElement.props.order or oldOrder -- 2273
			mounted.node.tag = newElement.props.tag or oldTag -- 2274
		end -- 2274
		return mounted -- 2276
	end -- 2276
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2278
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2279
	oldMounted.children = reconcileChildren( -- 2280
		oldMounted.node, -- 2280
		oldMounted.children, -- 2280
		getElementChildren(newElement) -- 2280
	) -- 2280
	oldMounted.element = newElement -- 2281
	return oldMounted -- 2282
end -- 2282
function reconcileChildren(parent, oldChildren, newElements) -- 2285
	local oldByKey = {} -- 2286
	local usedOld = {} -- 2287
	for i = 1, #oldChildren do -- 2287
		local oldChild = oldChildren[i] -- 2289
		local key = getElementKey(oldChild.element) -- 2290
		if key ~= nil then -- 2290
			oldByKey[key] = oldChild -- 2292
		end -- 2292
	end -- 2292
	local nextChildren = {} -- 2295
	for i = 1, #newElements do -- 2295
		local newElement = newElements[i] -- 2297
		local key = getElementKey(newElement) -- 2298
		local oldChild -- 2299
		if key ~= nil then -- 2299
			oldChild = oldByKey[key] -- 2301
		else -- 2301
			oldChild = oldChildren[i] -- 2303
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2303
				oldChild = nil -- 2305
			end -- 2305
		end -- 2305
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2308
		if mounted ~= nil then -- 2308
			usedOld[mounted] = true -- 2310
			nextChildren[#nextChildren + 1] = mounted -- 2311
			local props = newElement.props -- 2312
			mounted.node.order = props.order or i -- 2313
			if props.tag ~= nil then -- 2313
				mounted.node.tag = props.tag -- 2314
			end -- 2314
		end -- 2314
	end -- 2314
	for i = 1, #oldChildren do -- 2314
		local oldChild = oldChildren[i] -- 2318
		if not usedOld[oldChild] then -- 2318
			unmountElement(oldChild) -- 2320
		end -- 2320
	end -- 2320
	return nextChildren -- 2323
end -- 2323
____exports.React = {} -- 2323
local React = ____exports.React -- 2323
do -- 2323
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
			node:slot("AlignLayout", alignNode.onLayout) -- 827
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
local renderQueued = false -- 1528
local queuedRoots = {} -- 1529
local trackingRoot -- 1530
local function isElementList(node) -- 1534
	return node.type == nil -- 1535
end -- 1534
local function getRenderableElement(renderable) -- 1543
	if type(renderable) == "function" then -- 1543
		return renderable() -- 1545
	end -- 1545
	return renderable -- 1547
end -- 1543
local function removeRoot(root) -- 1788
	for i = 1, #roots do -- 1788
		if roots[i] == root then -- 1788
			table.remove(roots, i) -- 1791
			break -- 1792
		end -- 1792
	end -- 1792
end -- 1788
local function toElementList(node) -- 2326
	if isElementList(node) then -- 2326
		return node -- 2328
	end -- 2328
	return {node} -- 2330
end -- 2326
local function scheduleRootRender(root) -- 2333
	if not root.active then -- 2333
		return -- 2334
	end -- 2334
	for i = 1, #queuedRoots do -- 2334
		if queuedRoots[i] == root then -- 2334
			return -- 2336
		end -- 2336
	end -- 2336
	queuedRoots[#queuedRoots + 1] = root -- 2338
	if renderQueued then -- 2338
		return -- 2339
	end -- 2339
	renderQueued = true -- 2340
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2341
		renderQueued = false -- 2342
		local updatingRoots = queuedRoots -- 2343
		queuedRoots = {} -- 2344
		for i = 1, #updatingRoots do -- 2344
			updatingRoots[i]:update() -- 2346
		end -- 2346
	end)) -- 2341
end -- 2333
____exports.Root = __TS__Class() -- 2351
local Root = ____exports.Root -- 2351
Root.name = "Root" -- 2351
function Root.prototype.____constructor(self, parent) -- 2359
	self.parent = parent -- 2359
	self.mounted = {} -- 2352
	self.signals = {} -- 2354
	self.hookFrames = {} -- 2355
	self.hookFrameIndex = 0 -- 2356
	self.active = true -- 2357
end -- 2359
function Root.prototype.render(self, enode) -- 2361
	if not self.active then -- 2361
		roots[#roots + 1] = self -- 2363
		self.active = true -- 2364
	end -- 2364
	self.renderable = enode -- 2366
	self:update() -- 2367
end -- 2361
function Root.prototype.update(self) -- 2370
	if not self.active or self.renderable == nil then -- 2370
		return -- 2371
	end -- 2371
	self:unsubscribeSignals() -- 2372
	local lastTrackingRoot = trackingRoot -- 2373
	local lastRenderingHookRoot = renderingHookRoot -- 2374
	trackingRoot = self -- 2375
	renderingHookRoot = self -- 2376
	local elements -- 2377
	do -- 2377
		local ____try, ____error = pcall(function() -- 2377
			self:beginHookRender() -- 2379
			elements = getRenderableElement(self.renderable) -- 2380
		end) -- 2380
		do -- 2380
			self:finishHookRender() -- 2382
			trackingRoot = lastTrackingRoot -- 2383
			renderingHookRoot = lastRenderingHookRoot -- 2384
		end -- 2384
		if not ____try then -- 2384
			error(____error, 0) -- 2384
		end -- 2384
	end -- 2384
	self.mounted = reconcileChildren( -- 2386
		self.parent, -- 2386
		self.mounted, -- 2386
		toElementList(elements) -- 2386
	) -- 2386
end -- 2370
function Root.prototype.unmount(self) -- 2389
	for i = 1, #self.mounted do -- 2389
		unmountElement(self.mounted[i]) -- 2391
	end -- 2391
	self.mounted = {} -- 2393
	self.renderable = nil -- 2394
	self.hookFrames = {} -- 2395
	self.hookFrameIndex = 0 -- 2396
	self:unsubscribeSignals() -- 2397
	if self.active then -- 2397
		removeRoot(self) -- 2399
		self.active = false -- 2400
	end -- 2400
end -- 2389
function Root.prototype.trackSignal(self, signal) -- 2404
	for i = 1, #self.signals do -- 2404
		if self.signals[i] == signal then -- 2404
			return -- 2406
		end -- 2406
	end -- 2406
	local ____self_signals_70 = self.signals -- 2406
	____self_signals_70[#____self_signals_70 + 1] = signal -- 2408
	signal:addRoot(self) -- 2409
end -- 2404
function Root.prototype.beginComponentHooks(self, ____type, key) -- 2412
	local index = self.hookFrameIndex -- 2413
	self.hookFrameIndex = self.hookFrameIndex + 1 -- 2414
	local frame = self.hookFrames[index + 1] -- 2415
	if frame == nil or frame.type ~= ____type or frame.key ~= key then -- 2415
		frame = nil -- 2417
		if key ~= nil then -- 2417
			for i = index + 2, #self.hookFrames do -- 2417
				local candidate = self.hookFrames[i] -- 2420
				if candidate.type == ____type and candidate.key == key then -- 2420
					table.remove(self.hookFrames, i) -- 2422
					table.insert(self.hookFrames, index + 1, candidate) -- 2423
					frame = candidate -- 2424
					break -- 2425
				end -- 2425
			end -- 2425
		end -- 2425
		if frame == nil then -- 2425
			frame = {type = ____type, key = key, hooks = {}, hookIndex = 0} -- 2430
			if key ~= nil then -- 2430
				table.insert(self.hookFrames, index + 1, frame) -- 2432
			else -- 2432
				self.hookFrames[index + 1] = frame -- 2434
			end -- 2434
		end -- 2434
	end -- 2434
	frame.hookIndex = 0 -- 2438
	return frame -- 2439
end -- 2412
function Root.prototype.beginHookRender(self) -- 2442
	self.hookFrameIndex = 0 -- 2443
end -- 2442
function Root.prototype.finishHookRender(self) -- 2446
	while #self.hookFrames > self.hookFrameIndex do -- 2446
		table.remove(self.hookFrames) -- 2448
	end -- 2448
end -- 2446
function Root.prototype.unsubscribeSignals(self) -- 2452
	for i = 1, #self.signals do -- 2452
		self.signals[i]:removeRoot(self) -- 2454
	end -- 2454
	self.signals = {} -- 2456
end -- 2452
function ____exports.createRoot(parent) -- 2460
	local root = __TS__New(____exports.Root, parent) -- 2461
	roots[#roots + 1] = root -- 2462
	return root -- 2463
end -- 2460
____exports.Signal = __TS__Class() -- 2466
local Signal = ____exports.Signal -- 2466
Signal.name = "Signal" -- 2466
function Signal.prototype.____constructor(self, item) -- 2469
	self.item = item -- 2469
	self.roots = {} -- 2467
end -- 2469
function Signal.prototype.addRoot(self, root) -- 2486
	for i = 1, #self.roots do -- 2486
		if self.roots[i] == root then -- 2486
			return -- 2488
		end -- 2488
	end -- 2488
	local ____self_roots_71 = self.roots -- 2488
	____self_roots_71[#____self_roots_71 + 1] = root -- 2490
end -- 2486
function Signal.prototype.removeRoot(self, root) -- 2493
	for i = 1, #self.roots do -- 2493
		if self.roots[i] == root then -- 2493
			table.remove(self.roots, i) -- 2496
			break -- 2497
		end -- 2497
	end -- 2497
end -- 2493
__TS__SetDescriptor( -- 2493
	Signal.prototype, -- 2493
	"value", -- 2493
	{ -- 2493
		get = function(self) -- 2493
			if trackingRoot ~= nil then -- 2493
				trackingRoot:trackSignal(self) -- 2473
			end -- 2473
			return self.item -- 2475
		end, -- 2475
		set = function(self, value) -- 2475
			if self.item == value then -- 2475
				return -- 2479
			end -- 2479
			self.item = value -- 2480
			for i = 1, #self.roots do -- 2480
				scheduleRootRender(self.roots[i]) -- 2482
			end -- 2482
		end -- 2482
	}, -- 2482
	true -- 2482
) -- 2482
function ____exports.signal(value) -- 2503
	return __TS__New(____exports.Signal, value) -- 2504
end -- 2503
function ____exports.reference(item) -- 2507
	local ____item_72 = item -- 2508
	if ____item_72 == nil then -- 2508
		____item_72 = nil -- 2508
	end -- 2508
	return {current = ____item_72} -- 2508
end -- 2507
local function hookDepsEqual(oldDeps, newDeps) -- 2511
	if oldDeps == nil or newDeps == nil then -- 2511
		return false -- 2512
	end -- 2512
	if #oldDeps ~= #newDeps then -- 2512
		return false -- 2513
	end -- 2513
	for i = 1, #oldDeps do -- 2513
		if oldDeps[i] ~= newDeps[i] then -- 2513
			return false -- 2515
		end -- 2515
	end -- 2515
	return true -- 2517
end -- 2511
local function copyDeps(deps) -- 2520
	if deps == nil then -- 2520
		return nil -- 2521
	end -- 2521
	local copied = {} -- 2522
	for i = 1, #deps do -- 2522
		copied[#copied + 1] = deps[i] -- 2524
	end -- 2524
	return copied -- 2526
end -- 2520
function ____exports.useMemo(factory, deps) -- 2529
	local frame = currentHookFrame -- 2530
	if frame == nil then -- 2530
		error("useMemo() can only be called inside a function component") -- 2532
	end -- 2532
	local index = frame.hookIndex -- 2534
	frame.hookIndex = frame.hookIndex + 1 -- 2535
	local hook = frame.hooks[index + 1] -- 2536
	if hook == nil or not hookDepsEqual(hook.deps, deps) then -- 2536
		hook = { -- 2538
			value = factory(), -- 2538
			deps = copyDeps(deps) -- 2538
		} -- 2538
		frame.hooks[index + 1] = hook -- 2539
	end -- 2539
	return hook.value -- 2541
end -- 2529
function ____exports.useCallback(callback, deps) -- 2544
	local frame = currentHookFrame -- 2545
	if frame == nil then -- 2545
		error("useCallback() can only be called inside a function component") -- 2547
	end -- 2547
	local actualDeps = deps or ({}) -- 2549
	local index = frame.hookIndex -- 2550
	frame.hookIndex = frame.hookIndex + 1 -- 2551
	local hook = frame.hooks[index + 1] -- 2552
	if hook == nil or not hookDepsEqual(hook.deps, actualDeps) then -- 2552
		hook = { -- 2554
			value = callback, -- 2554
			deps = copyDeps(actualDeps) -- 2554
		} -- 2554
		frame.hooks[index + 1] = hook -- 2555
	end -- 2555
	return hook.value -- 2557
end -- 2544
function ____exports.useRef(item) -- 2560
	local frame = currentHookFrame -- 2561
	if frame == nil then -- 2561
		error("useRef() can only be called inside a function component") -- 2563
	end -- 2563
	local index = frame.hookIndex -- 2565
	frame.hookIndex = frame.hookIndex + 1 -- 2566
	local hook = frame.hooks[index + 1] -- 2567
	if hook == nil then -- 2567
		hook = {value = ____exports.reference(item)} -- 2569
		frame.hooks[index + 1] = hook -- 2570
	end -- 2570
	return hook.value -- 2572
end -- 2560
function ____exports.useSignal(value) -- 2575
	local frame = currentHookFrame -- 2576
	if frame == nil then -- 2576
		error("useSignal() can only be called inside a function component") -- 2578
	end -- 2578
	local index = frame.hookIndex -- 2580
	frame.hookIndex = frame.hookIndex + 1 -- 2581
	local hook = frame.hooks[index + 1] -- 2582
	if hook == nil then -- 2582
		hook = {value = ____exports.signal(value)} -- 2584
		frame.hooks[index + 1] = hook -- 2585
	end -- 2585
	return hook.value -- 2587
end -- 2575
local function getPreload(preloadList, node) -- 2590
	if type(node) ~= "table" then -- 2590
		return -- 2592
	end -- 2592
	local enode = node -- 2594
	if enode.type == nil then -- 2594
		local list = node -- 2596
		if #list > 0 then -- 2596
			for i = 1, #list do -- 2596
				getPreload(preloadList, list[i]) -- 2599
			end -- 2599
		end -- 2599
	else -- 2599
		repeat -- 2599
			local ____switch619 = enode.type -- 2599
			local sprite, playable, frame, model, spine, dragonBone, label -- 2599
			local ____cond619 = ____switch619 == "sprite" -- 2599
			if ____cond619 then -- 2599
				sprite = enode.props -- 2605
				if sprite.file then -- 2605
					preloadList[#preloadList + 1] = sprite.file -- 2607
				end -- 2607
				break -- 2609
			end -- 2609
			____cond619 = ____cond619 or ____switch619 == "playable" -- 2609
			if ____cond619 then -- 2609
				playable = enode.props -- 2611
				preloadList[#preloadList + 1] = playable.file -- 2612
				break -- 2613
			end -- 2613
			____cond619 = ____cond619 or ____switch619 == "frame" -- 2613
			if ____cond619 then -- 2613
				frame = enode.props -- 2615
				preloadList[#preloadList + 1] = frame.file -- 2616
				break -- 2617
			end -- 2617
			____cond619 = ____cond619 or ____switch619 == "model" -- 2617
			if ____cond619 then -- 2617
				model = enode.props -- 2619
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2620
				break -- 2621
			end -- 2621
			____cond619 = ____cond619 or ____switch619 == "spine" -- 2621
			if ____cond619 then -- 2621
				spine = enode.props -- 2623
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2624
				break -- 2625
			end -- 2625
			____cond619 = ____cond619 or ____switch619 == "dragon-bone" -- 2625
			if ____cond619 then -- 2625
				dragonBone = enode.props -- 2627
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2628
				break -- 2629
			end -- 2629
			____cond619 = ____cond619 or ____switch619 == "label" -- 2629
			if ____cond619 then -- 2629
				label = enode.props -- 2631
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2632
				break -- 2633
			end -- 2633
		until true -- 2633
	end -- 2633
	getPreload(preloadList, enode.children) -- 2636
end -- 2590
function ____exports.preloadAsync(enode, handler) -- 2639
	local preloadList = {} -- 2640
	getPreload(preloadList, enode) -- 2641
	Dora.Cache:loadAsync(preloadList, handler) -- 2642
end -- 2639
function ____exports.toAction(enode) -- 2645
	local actionDef = ____exports.reference() -- 2646
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2647
	if not actionDef.current then -- 2647
		error("failed to create action") -- 2648
	end -- 2648
	return actionDef.current -- 2649
end -- 2645
return ____exports -- 2645