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
local Warn, applyAutoEnableProps, visitAction, visitNode, getElementKey, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, isRunnableActionElement, shallowPropsEqual, collectRunnableActionElements, collectContactElements, getContactKey, patchPhysicsWorldInputs, actionElementEqual, actionChildrenEqual, createActionDef, structuralChildrenEqual, runActionChildren, patchActionChildren, toHostElement, createHostNode, getElementChildren, shouldRecreate, isEventProp, getEventSlot, isPatchableEventProp, patchEventProp, patchContactFilterProp, patchUpdateProp, clearRemovedProp, getAlignStyleText, patchPlayableProps, patchAudioSourceProps, patchParticleProps, patchAlignNodeProps, patchLineProps, clearRef, patchRef, applyProp, patchProps, addChildToParent, mountElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap -- 1
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
	Dora.Log("Warn", "[Dora Warning] " .. msg) -- 14
end -- 14
function applyAutoEnableProps(node, props) -- 129
	local jnode = props -- 130
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 130
		node.touchEnabled = true -- 140
	end -- 140
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 140
		node.keyboardEnabled = true -- 147
	end -- 147
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 147
		node.controllerEnabled = true -- 154
	end -- 154
	local body = Dora.tolua.cast(node, "Body") -- 156
	if body ~= nil then -- 156
		local bodyProps = props -- 158
		if bodyProps.receivingContact ~= false and (bodyProps.onContactStart or bodyProps.onContactEnd) then -- 158
			body.receivingContact = true -- 163
		end -- 163
	end -- 163
end -- 163
function visitAction(actionStack, enode) -- 857
	local createAction = actionMap[enode.type] -- 858
	if createAction ~= nil then -- 858
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 860
		return -- 861
	end -- 861
	repeat -- 861
		local ____switch182 = enode.type -- 861
		local ____cond182 = ____switch182 == "delay" -- 861
		if ____cond182 then -- 861
			do -- 861
				local item = enode.props -- 865
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 866
				break -- 867
			end -- 867
		end -- 867
		____cond182 = ____cond182 or ____switch182 == "event" -- 867
		if ____cond182 then -- 867
			do -- 867
				local item = enode.props -- 870
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 871
				break -- 872
			end -- 872
		end -- 872
		____cond182 = ____cond182 or ____switch182 == "hide" -- 872
		if ____cond182 then -- 872
			do -- 872
				actionStack[#actionStack + 1] = Dora.Hide() -- 875
				break -- 876
			end -- 876
		end -- 876
		____cond182 = ____cond182 or ____switch182 == "show" -- 876
		if ____cond182 then -- 876
			do -- 876
				actionStack[#actionStack + 1] = Dora.Show() -- 879
				break -- 880
			end -- 880
		end -- 880
		____cond182 = ____cond182 or ____switch182 == "move" -- 880
		if ____cond182 then -- 880
			do -- 880
				local item = enode.props -- 883
				actionStack[#actionStack + 1] = Dora.Move( -- 884
					item.time, -- 884
					Dora.Vec2(item.startX, item.startY), -- 884
					Dora.Vec2(item.stopX, item.stopY), -- 884
					item.easing -- 884
				) -- 884
				break -- 885
			end -- 885
		end -- 885
		____cond182 = ____cond182 or ____switch182 == "frame" -- 885
		if ____cond182 then -- 885
			do -- 885
				local item = enode.props -- 888
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 889
				break -- 890
			end -- 890
		end -- 890
		____cond182 = ____cond182 or ____switch182 == "spawn" -- 890
		if ____cond182 then -- 890
			do -- 890
				local spawnStack = {} -- 893
				for i = 1, #enode.children do -- 893
					visitAction(spawnStack, enode.children[i]) -- 895
				end -- 895
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 897
				break -- 898
			end -- 898
		end -- 898
		____cond182 = ____cond182 or ____switch182 == "sequence" -- 898
		if ____cond182 then -- 898
			do -- 898
				local sequenceStack = {} -- 901
				for i = 1, #enode.children do -- 901
					visitAction(sequenceStack, enode.children[i]) -- 903
				end -- 903
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 905
				break -- 906
			end -- 906
		end -- 906
		do -- 906
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 909
			break -- 910
		end -- 910
	until true -- 910
end -- 910
function visitNode(nodeStack, node, parent) -- 1449
	if type(node) ~= "table" then -- 1449
		return -- 1451
	end -- 1451
	local enode = node -- 1453
	if enode.type == nil then -- 1453
		local list = node -- 1455
		if #list > 0 then -- 1455
			for i = 1, #list do -- 1455
				local stack = {} -- 1458
				visitNode(stack, list[i], parent) -- 1459
				for i = 1, #stack do -- 1459
					nodeStack[#nodeStack + 1] = stack[i] -- 1461
				end -- 1461
			end -- 1461
		end -- 1461
	else -- 1461
		local handler = elementMap[enode.type] -- 1466
		if handler ~= nil then -- 1466
			handler(nodeStack, enode, parent) -- 1468
		else -- 1468
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1470
		end -- 1470
	end -- 1470
end -- 1470
function ____exports.toNode(enode) -- 1475
	local nodeStack = {} -- 1476
	visitNode(nodeStack, enode) -- 1477
	if #nodeStack == 1 then -- 1477
		return nodeStack[1] -- 1479
	elseif #nodeStack > 1 then -- 1479
		local node = Dora.Node() -- 1481
		for i = 1, #nodeStack do -- 1481
			node:addChild(nodeStack[i]) -- 1483
		end -- 1483
		return node -- 1485
	end -- 1485
	return nil -- 1487
end -- 1475
function getElementKey(element) -- 1507
	local props = element.props -- 1508
	local ____props_58 -- 1509
	if props then -- 1509
		____props_58 = props.key -- 1509
	else -- 1509
		____props_58 = nil -- 1509
	end -- 1509
	return ____props_58 -- 1509
end -- 1509
function getPrimitiveLabelText(enode) -- 1519
	local label = enode.props -- 1520
	local text = label.text or "" -- 1521
	for i = 1, #enode.children do -- 1521
		local child = enode.children[i] -- 1523
		if type(child) ~= "table" then -- 1523
			text = text .. tostring(child) -- 1525
		end -- 1525
	end -- 1525
	return text -- 1528
end -- 1528
function isDrawShapeElement(element) -- 1531
	repeat -- 1531
		local ____switch331 = element.type -- 1531
		local ____cond331 = ____switch331 == "dot-shape" or ____switch331 == "segment-shape" or ____switch331 == "rect-shape" or ____switch331 == "polygon-shape" or ____switch331 == "verts-shape" -- 1531
		if ____cond331 then -- 1531
			return true -- 1538
		end -- 1538
	until true -- 1538
	return false -- 1540
end -- 1540
function isBodyFixtureElement(element) -- 1543
	repeat -- 1543
		local ____switch333 = element.type -- 1543
		local ____cond333 = ____switch333 == "rect-fixture" or ____switch333 == "polygon-fixture" or ____switch333 == "multi-fixture" or ____switch333 == "disk-fixture" or ____switch333 == "chain-fixture" -- 1543
		if ____cond333 then -- 1543
			return true -- 1550
		end -- 1550
	until true -- 1550
	return false -- 1552
end -- 1552
function isPhysicsWorldInputElement(element) -- 1555
	return element.type == "contact" -- 1556
end -- 1556
function isRunnableActionElement(element) -- 1559
	if element.type == "loop" then -- 1559
		return true -- 1560
	end -- 1560
	return actionMap[element.type] ~= nil or element.type == "delay" or element.type == "event" or element.type == "hide" or element.type == "show" or element.type == "move" or element.type == "frame" or element.type == "spawn" or element.type == "sequence" -- 1561
end -- 1561
function shallowPropsEqual(oldProps, newProps) -- 1572
	for k, v in pairs(oldProps) do -- 1573
		if k ~= "ref" and newProps[k] ~= v then -- 1573
			return false -- 1574
		end -- 1574
	end -- 1574
	for k, v in pairs(newProps) do -- 1576
		if k ~= "ref" and oldProps[k] ~= v then -- 1576
			return false -- 1577
		end -- 1577
	end -- 1577
	return true -- 1579
end -- 1579
function collectRunnableActionElements(element) -- 1582
	local actions = {} -- 1583
	for i = 1, #element.children do -- 1583
		local child = element.children[i] -- 1585
		if type(child) == "table" and isRunnableActionElement(child) then -- 1585
			actions[#actions + 1] = child -- 1587
		end -- 1587
	end -- 1587
	return actions -- 1590
end -- 1590
function collectContactElements(element) -- 1593
	local contacts = {} -- 1594
	for i = 1, #element.children do -- 1594
		local child = element.children[i] -- 1596
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1596
			contacts[#contacts + 1] = child -- 1598
		end -- 1598
	end -- 1598
	return contacts -- 1601
end -- 1601
function getContactKey(contact) -- 1604
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1605
end -- 1605
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1608
	local oldContacts = collectContactElements(oldElement) -- 1609
	local newContacts = collectContactElements(newElement) -- 1610
	local oldByKey = {} -- 1611
	local newByKey = {} -- 1612
	for i = 1, #oldContacts do -- 1612
		local contact = oldContacts[i].props -- 1614
		oldByKey[getContactKey(contact)] = contact -- 1615
	end -- 1615
	for i = 1, #newContacts do -- 1615
		local contact = newContacts[i].props -- 1618
		newByKey[getContactKey(contact)] = contact -- 1619
	end -- 1619
	for i = 1, #oldContacts do -- 1619
		local oldContact = oldContacts[i].props -- 1622
		local key = getContactKey(oldContact) -- 1623
		local newContact = newByKey[key] -- 1624
		if newContact == nil then -- 1624
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1626
		elseif oldContact.enabled ~= newContact.enabled then -- 1626
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1628
		end -- 1628
	end -- 1628
	for i = 1, #newContacts do -- 1628
		local newContact = newContacts[i].props -- 1632
		if oldByKey[getContactKey(newContact)] == nil then -- 1632
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1634
		end -- 1634
	end -- 1634
end -- 1634
function actionElementEqual(oldElement, newElement) -- 1639
	if oldElement.type ~= newElement.type then -- 1639
		return false -- 1640
	end -- 1640
	if not shallowPropsEqual(oldElement.props, newElement.props) then -- 1640
		return false -- 1641
	end -- 1641
	if #oldElement.children ~= #newElement.children then -- 1641
		return false -- 1642
	end -- 1642
	for i = 1, #oldElement.children do -- 1642
		local oldChild = oldElement.children[i] -- 1644
		local newChild = newElement.children[i] -- 1645
		if type(oldChild) ~= type(newChild) then -- 1645
			return false -- 1646
		end -- 1646
		if type(oldChild) == "table" then -- 1646
			if not actionElementEqual(oldChild, newChild) then -- 1646
				return false -- 1648
			end -- 1648
		elseif oldChild ~= newChild then -- 1648
			return false -- 1650
		end -- 1650
	end -- 1650
	return true -- 1653
end -- 1653
function actionChildrenEqual(oldElement, newElement) -- 1656
	local oldActions = collectRunnableActionElements(oldElement) -- 1657
	local newActions = collectRunnableActionElements(newElement) -- 1658
	if #oldActions ~= #newActions then -- 1658
		return false -- 1659
	end -- 1659
	for i = 1, #oldActions do -- 1659
		if not actionElementEqual(oldActions[i], newActions[i]) then -- 1659
			return false -- 1661
		end -- 1661
	end -- 1661
	return true -- 1663
end -- 1663
function createActionDef(actionElement) -- 1666
	if actionElement.type == "loop" then -- 1666
		local actionStack = {} -- 1668
		for i = 1, #actionElement.children do -- 1668
			visitAction(actionStack, actionElement.children[i]) -- 1670
		end -- 1670
		if #actionStack == 1 then -- 1670
			return actionStack[1], true -- 1673
		elseif #actionStack > 1 then -- 1673
			local loop = actionElement.props -- 1675
			return loop.spawn and Dora.Spawn(table.unpack(actionStack)) or Dora.Sequence(table.unpack(actionStack)), true -- 1676
		end -- 1676
		return nil, true -- 1678
	end -- 1678
	local actionStack = {} -- 1680
	visitAction(actionStack, actionElement) -- 1681
	return #actionStack == 1 and actionStack[1] or nil, false -- 1682
end -- 1682
function structuralChildrenEqual(oldElement, newElement, check) -- 1685
	local oldChildren = {} -- 1691
	local newChildren = {} -- 1692
	for i = 1, #oldElement.children do -- 1692
		local child = oldElement.children[i] -- 1694
		if type(child) == "table" and check(child) then -- 1694
			oldChildren[#oldChildren + 1] = child -- 1696
		end -- 1696
	end -- 1696
	for i = 1, #newElement.children do -- 1696
		local child = newElement.children[i] -- 1700
		if type(child) == "table" and check(child) then -- 1700
			newChildren[#newChildren + 1] = child -- 1702
		end -- 1702
	end -- 1702
	if #oldChildren ~= #newChildren then -- 1702
		return false -- 1705
	end -- 1705
	for i = 1, #oldChildren do -- 1705
		local oldChild = oldChildren[i] -- 1707
		local newChild = newChildren[i] -- 1708
		if oldChild.type ~= newChild.type then -- 1708
			return false -- 1709
		end -- 1709
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1709
			return false -- 1710
		end -- 1710
	end -- 1710
	return true -- 1712
end -- 1712
function runActionChildren(node, element) -- 1715
	local actionChildren = collectRunnableActionElements(element) -- 1716
	local exclusiveActions = {} -- 1717
	local exclusiveLoop -- 1718
	local warnedExclusiveConflict = false -- 1719
	for i = 1, #actionChildren do -- 1719
		do -- 1719
			local actionElement = actionChildren[i] -- 1721
			local action, loop = createActionDef(actionElement) -- 1722
			if action == nil then -- 1722
				goto __continue385 -- 1723
			end -- 1723
			if actionElement.props.exclusive == true then -- 1723
				if exclusiveLoop == nil then -- 1723
					exclusiveLoop = loop -- 1726
				end -- 1726
				if exclusiveLoop == loop then -- 1726
					exclusiveActions[#exclusiveActions + 1] = action -- 1729
				elseif not warnedExclusiveConflict then -- 1729
					Warn("exclusive action children on the same node can not mix <loop> and non-<loop>; ignoring conflicting exclusive actions") -- 1731
					warnedExclusiveConflict = true -- 1732
				end -- 1732
			end -- 1732
		end -- 1732
		::__continue385:: -- 1732
	end -- 1732
	if #exclusiveActions == 1 then -- 1732
		node:perform(exclusiveActions[1], exclusiveLoop == true) -- 1737
	elseif #exclusiveActions > 1 then -- 1737
		node:perform( -- 1739
			Dora.Spawn(table.unpack(exclusiveActions)), -- 1739
			exclusiveLoop == true -- 1739
		) -- 1739
	end -- 1739
	for i = 1, #actionChildren do -- 1739
		do -- 1739
			local actionElement = actionChildren[i] -- 1742
			if actionElement.props.exclusive == true then -- 1742
				goto __continue393 -- 1743
			end -- 1743
			local action, loop = createActionDef(actionElement) -- 1744
			if action ~= nil then -- 1744
				node:runAction(action, loop) -- 1746
			end -- 1746
		end -- 1746
		::__continue393:: -- 1746
	end -- 1746
end -- 1746
function patchActionChildren(node, oldElement, newElement) -- 1751
	if not actionChildrenEqual(oldElement, newElement) then -- 1751
		runActionChildren(node, newElement) -- 1753
	end -- 1753
end -- 1753
function toHostElement(enode, parent) -- 1766
	local hostChildren = {} -- 1767
	local props = {} -- 1768
	if enode.props ~= nil then -- 1768
		for k, v in pairs(enode.props) do -- 1770
			props[k] = v -- 1771
		end -- 1771
	end -- 1771
	if enode.type == "label" then -- 1771
		for i = 1, #enode.children do -- 1771
			local child = enode.children[i] -- 1776
			if type(child) ~= "table" then -- 1776
				hostChildren[#hostChildren + 1] = child -- 1778
			end -- 1778
		end -- 1778
	elseif enode.type == "draw-node" then -- 1778
		for i = 1, #enode.children do -- 1778
			local child = enode.children[i] -- 1783
			if type(child) == "table" and isDrawShapeElement(child) then -- 1783
				hostChildren[#hostChildren + 1] = child -- 1785
			end -- 1785
		end -- 1785
	elseif enode.type == "body" then -- 1785
		for i = 1, #enode.children do -- 1785
			local child = enode.children[i] -- 1790
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1790
				hostChildren[#hostChildren + 1] = child -- 1792
			end -- 1792
		end -- 1792
	elseif enode.type == "physics-world" then -- 1792
		for i = 1, #enode.children do -- 1792
			local child = enode.children[i] -- 1797
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1797
				hostChildren[#hostChildren + 1] = child -- 1799
			end -- 1799
		end -- 1799
	end -- 1799
	if enode.type == "body" and props.world == nil then -- 1799
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1804
		if world ~= nil then -- 1804
			props.world = world -- 1806
		end -- 1806
	end -- 1806
	return {type = enode.type, props = props, children = hostChildren} -- 1809
end -- 1809
function createHostNode(enode, parent) -- 1816
	local nodeStack = {} -- 1817
	visitNode( -- 1818
		nodeStack, -- 1818
		toHostElement(enode, parent) -- 1818
	) -- 1818
	if #nodeStack == 1 then -- 1818
		return nodeStack[1] -- 1820
	elseif #nodeStack > 1 then -- 1820
		local node = Dora.Node() -- 1822
		for i = 1, #nodeStack do -- 1822
			node:addChild(nodeStack[i]) -- 1824
		end -- 1824
		return node -- 1826
	end -- 1826
	return nil -- 1828
end -- 1828
function getElementChildren(enode) -- 1831
	local children = {} -- 1832
	if enode.type == "draw-node" or enode.type == "body" then -- 1832
		return children -- 1833
	end -- 1833
	for i = 1, #enode.children do -- 1833
		local child = enode.children[i] -- 1835
		if type(child) == "table" then -- 1835
			local childElement = child -- 1837
			if childElement.type ~= nil then -- 1837
				if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement)) and not isRunnableActionElement(childElement) then -- 1837
					children[#children + 1] = childElement -- 1843
				end -- 1843
			else -- 1843
				local list = child -- 1846
				for j = 1, #list do -- 1846
					local item = list[j] -- 1848
					if type(item) == "table" and item.type ~= nil then -- 1848
						if (enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item)) and not isRunnableActionElement(item) then -- 1848
							children[#children + 1] = item -- 1854
						end -- 1854
					end -- 1854
				end -- 1854
			end -- 1854
		end -- 1854
	end -- 1854
	return children -- 1861
end -- 1861
function shouldRecreate(oldElement, newElement) -- 1864
	if oldElement.type ~= newElement.type then -- 1864
		return true -- 1865
	end -- 1865
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1865
		return true -- 1866
	end -- 1866
	local oldProps = oldElement.props -- 1867
	local newProps = newElement.props -- 1868
	if newElement.type == "draw-node" then -- 1868
		return true -- 1869
	end -- 1869
	for k, v in pairs(oldProps) do -- 1870
		if k == "onMount" and newProps[k] ~= v then -- 1870
			return true -- 1872
		end -- 1872
		if isEventProp(k) and not isPatchableEventProp(k) and newProps[k] ~= v then -- 1872
			return true -- 1875
		end -- 1875
	end -- 1875
	for k, v in pairs(newProps) do -- 1878
		if k == "onMount" and oldProps[k] ~= v then -- 1878
			return true -- 1880
		end -- 1880
		if isEventProp(k) and not isPatchableEventProp(k) and oldProps[k] ~= v then -- 1880
			return true -- 1883
		end -- 1883
	end -- 1883
	repeat -- 1883
		local ____switch442 = newElement.type -- 1883
		local ____cond442 = ____switch442 == "grid" -- 1883
		if ____cond442 then -- 1883
			return oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY -- 1888
		end -- 1888
		____cond442 = ____cond442 or (____switch442 == "sprite" or ____switch442 == "video-node" or ____switch442 == "tic80-node" or ____switch442 == "audio-source" or ____switch442 == "particle" or ____switch442 == "tile-node" or ____switch442 == "playable" or ____switch442 == "dragon-bone" or ____switch442 == "spine" or ____switch442 == "model") -- 1888
		if ____cond442 then -- 1888
			return oldProps.file ~= newProps.file -- 1899
		end -- 1899
		____cond442 = ____cond442 or ____switch442 == "label" -- 1899
		if ____cond442 then -- 1899
			return oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf -- 1901
		end -- 1901
		____cond442 = ____cond442 or ____switch442 == "align-node" -- 1901
		if ____cond442 then -- 1901
			return oldProps.windowRoot ~= newProps.windowRoot -- 1903
		end -- 1903
		____cond442 = ____cond442 or ____switch442 == "custom-node" -- 1903
		if ____cond442 then -- 1903
			return oldProps.onCreate ~= newProps.onCreate -- 1905
		end -- 1905
		____cond442 = ____cond442 or ____switch442 == "body" -- 1905
		if ____cond442 then -- 1905
			return oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement) -- 1907
		end -- 1907
	until true -- 1907
	return false -- 1914
end -- 1914
function isEventProp(key) -- 1917
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1918
end -- 1918
function getEventSlot(key) -- 1921
	repeat -- 1921
		local ____switch445 = key -- 1921
		local ____cond445 = ____switch445 == "onActionEnd" -- 1921
		if ____cond445 then -- 1921
			return "ActionEnd" -- 1923
		end -- 1923
		____cond445 = ____cond445 or ____switch445 == "onTapFilter" -- 1923
		if ____cond445 then -- 1923
			return "TapFilter" -- 1924
		end -- 1924
		____cond445 = ____cond445 or ____switch445 == "onTapBegan" -- 1924
		if ____cond445 then -- 1924
			return "TapBegan" -- 1925
		end -- 1925
		____cond445 = ____cond445 or ____switch445 == "onTapEnded" -- 1925
		if ____cond445 then -- 1925
			return "TapEnded" -- 1926
		end -- 1926
		____cond445 = ____cond445 or ____switch445 == "onTapped" -- 1926
		if ____cond445 then -- 1926
			return "Tapped" -- 1927
		end -- 1927
		____cond445 = ____cond445 or ____switch445 == "onTapMoved" -- 1927
		if ____cond445 then -- 1927
			return "TapMoved" -- 1928
		end -- 1928
		____cond445 = ____cond445 or ____switch445 == "onMouseWheel" -- 1928
		if ____cond445 then -- 1928
			return "MouseWheel" -- 1929
		end -- 1929
		____cond445 = ____cond445 or ____switch445 == "onGesture" -- 1929
		if ____cond445 then -- 1929
			return "Gesture" -- 1930
		end -- 1930
		____cond445 = ____cond445 or ____switch445 == "onEnter" -- 1930
		if ____cond445 then -- 1930
			return "Enter" -- 1931
		end -- 1931
		____cond445 = ____cond445 or ____switch445 == "onExit" -- 1931
		if ____cond445 then -- 1931
			return "Exit" -- 1932
		end -- 1932
		____cond445 = ____cond445 or ____switch445 == "onCleanup" -- 1932
		if ____cond445 then -- 1932
			return "Cleanup" -- 1933
		end -- 1933
		____cond445 = ____cond445 or ____switch445 == "onKeyDown" -- 1933
		if ____cond445 then -- 1933
			return "KeyDown" -- 1934
		end -- 1934
		____cond445 = ____cond445 or ____switch445 == "onKeyUp" -- 1934
		if ____cond445 then -- 1934
			return "KeyUp" -- 1935
		end -- 1935
		____cond445 = ____cond445 or ____switch445 == "onKeyPressed" -- 1935
		if ____cond445 then -- 1935
			return "KeyPressed" -- 1936
		end -- 1936
		____cond445 = ____cond445 or ____switch445 == "onAttachIME" -- 1936
		if ____cond445 then -- 1936
			return "AttachIME" -- 1937
		end -- 1937
		____cond445 = ____cond445 or ____switch445 == "onDetachIME" -- 1937
		if ____cond445 then -- 1937
			return "DetachIME" -- 1938
		end -- 1938
		____cond445 = ____cond445 or ____switch445 == "onTextInput" -- 1938
		if ____cond445 then -- 1938
			return "TextInput" -- 1939
		end -- 1939
		____cond445 = ____cond445 or ____switch445 == "onTextEditing" -- 1939
		if ____cond445 then -- 1939
			return "TextEditing" -- 1940
		end -- 1940
		____cond445 = ____cond445 or ____switch445 == "onButtonDown" -- 1940
		if ____cond445 then -- 1940
			return "ButtonDown" -- 1941
		end -- 1941
		____cond445 = ____cond445 or ____switch445 == "onButtonUp" -- 1941
		if ____cond445 then -- 1941
			return "ButtonUp" -- 1942
		end -- 1942
		____cond445 = ____cond445 or ____switch445 == "onAxis" -- 1942
		if ____cond445 then -- 1942
			return "Axis" -- 1943
		end -- 1943
		____cond445 = ____cond445 or ____switch445 == "onAnimationEnd" -- 1943
		if ____cond445 then -- 1943
			return "AnimationEnd" -- 1944
		end -- 1944
		____cond445 = ____cond445 or ____switch445 == "onFinished" -- 1944
		if ____cond445 then -- 1944
			return "Finished" -- 1945
		end -- 1945
		____cond445 = ____cond445 or ____switch445 == "onLayout" -- 1945
		if ____cond445 then -- 1945
			return "AlignLayout" -- 1946
		end -- 1946
		____cond445 = ____cond445 or ____switch445 == "onBodyEnter" -- 1946
		if ____cond445 then -- 1946
			return "BodyEnter" -- 1947
		end -- 1947
		____cond445 = ____cond445 or ____switch445 == "onBodyLeave" -- 1947
		if ____cond445 then -- 1947
			return "BodyLeave" -- 1948
		end -- 1948
		____cond445 = ____cond445 or ____switch445 == "onContactStart" -- 1948
		if ____cond445 then -- 1948
			return "ContactStart" -- 1949
		end -- 1949
		____cond445 = ____cond445 or ____switch445 == "onContactEnd" -- 1949
		if ____cond445 then -- 1949
			return "ContactEnd" -- 1950
		end -- 1950
	until true -- 1950
	return nil -- 1952
end -- 1952
function isPatchableEventProp(key) -- 1955
	return getEventSlot(key) ~= nil or key == "onContactFilter" or key == "onUpdate" -- 1956
end -- 1956
function patchEventProp(node, key, value) -- 1959
	local slotName = getEventSlot(key) -- 1960
	if slotName == nil then -- 1960
		return -- 1961
	end -- 1961
	node:slot(slotName):clear() -- 1962
	if value ~= nil then -- 1962
		node:slot(slotName, value) -- 1964
	end -- 1964
end -- 1964
function patchContactFilterProp(node, value) -- 1968
	local body = Dora.tolua.cast(node, "Body") -- 1969
	if body == nil then -- 1969
		return -- 1970
	end -- 1970
	if value == nil then -- 1970
		body:onContactFilter(function() return true end) -- 1972
	else -- 1972
		body:onContactFilter(value) -- 1974
	end -- 1974
end -- 1974
function patchUpdateProp(node, value) -- 1978
	if value == nil then -- 1978
		node:unschedule() -- 1980
	elseif type(value) == "thread" then -- 1980
		node:schedule(value) -- 1982
	else -- 1982
		node:schedule(value) -- 1984
	end -- 1984
end -- 1984
function clearRemovedProp(node, key) -- 1988
	repeat -- 1988
		local ____switch460 = key -- 1988
		local ____cond460 = ____switch460 == "transformTarget" or ____switch460 == "stencil" -- 1988
		if ____cond460 then -- 1988
			node[key] = nil -- 1992
			return true -- 1993
		end -- 1993
	until true -- 1993
	return false -- 1995
end -- 1995
function getAlignStyleText(style) -- 1998
	local items = {} -- 1999
	for k, v in pairs(style) do -- 2000
		local name = string.gsub(k, "%u", "-%1") -- 2001
		name = string.lower(name) -- 2002
		repeat -- 2002
			local ____switch463 = k -- 2002
			local ____cond463 = ____switch463 == "margin" or ____switch463 == "padding" or ____switch463 == "border" or ____switch463 == "gap" -- 2002
			if ____cond463 then -- 2002
				do -- 2002
					if type(v) == "table" then -- 2002
						local valueStr = table.concat( -- 2007
							__TS__ArrayMap( -- 2007
								v, -- 2007
								function(____, item) return tostring(item) end -- 2007
							), -- 2007
							"," -- 2007
						) -- 2007
						items[#items + 1] = (name .. ":") .. valueStr -- 2008
					else -- 2008
						items[#items + 1] = (name .. ":") .. tostring(v) -- 2010
					end -- 2010
					break -- 2012
				end -- 2012
			end -- 2012
			do -- 2012
				items[#items + 1] = (name .. ":") .. tostring(v) -- 2015
				break -- 2016
			end -- 2016
		until true -- 2016
	end -- 2016
	return table.concat(items, ";") -- 2019
end -- 2019
function patchPlayableProps(node, oldProps, newProps) -- 2022
	if newProps.play ~= nil and (oldProps.play ~= newProps.play or oldProps.loop ~= newProps.loop) then -- 2022
		node:play(newProps.play, newProps.loop == true) -- 2024
	end -- 2024
end -- 2024
function patchAudioSourceProps(node, oldProps, newProps) -- 2028
	if newProps.playMode ~= nil and (oldProps.playMode ~= newProps.playMode or oldProps.delayTime ~= newProps.delayTime) then -- 2028
		local audio = node -- 2030
		repeat -- 2030
			local ____switch472 = newProps.playMode -- 2030
			local ____cond472 = ____switch472 == "normal" -- 2030
			if ____cond472 then -- 2030
				local ____audio_play_60 = audio.play -- 2032
				local ____newProps_delayTime_59 = newProps.delayTime -- 2032
				if ____newProps_delayTime_59 == nil then -- 2032
					____newProps_delayTime_59 = 0 -- 2032
				end -- 2032
				____audio_play_60(audio, ____newProps_delayTime_59) -- 2032
				break -- 2032
			end -- 2032
			____cond472 = ____cond472 or ____switch472 == "background" -- 2032
			if ____cond472 then -- 2032
				audio:playBackground() -- 2033
				break -- 2033
			end -- 2033
			____cond472 = ____cond472 or ____switch472 == "3D" -- 2033
			if ____cond472 then -- 2033
				local ____audio_play3D_62 = audio.play3D -- 2034
				local ____newProps_delayTime_61 = newProps.delayTime -- 2034
				if ____newProps_delayTime_61 == nil then -- 2034
					____newProps_delayTime_61 = 0 -- 2034
				end -- 2034
				____audio_play3D_62(audio, ____newProps_delayTime_61) -- 2034
				break -- 2034
			end -- 2034
		until true -- 2034
	end -- 2034
end -- 2034
function patchParticleProps(node, oldProps, newProps) -- 2039
	if newProps.emit ~= nil and oldProps.emit ~= newProps.emit then -- 2039
		local particle = node -- 2041
		if newProps.emit then -- 2041
			particle:start() -- 2043
		else -- 2043
			particle:stop() -- 2045
		end -- 2045
	end -- 2045
end -- 2045
function patchAlignNodeProps(node, oldProps, newProps) -- 2050
	if newProps.style ~= nil and oldProps.style ~= newProps.style then -- 2050
		node:css(getAlignStyleText(newProps.style)) -- 2052
	end -- 2052
end -- 2052
function patchLineProps(node, oldProps, newProps) -- 2056
	if newProps.verts ~= nil and (oldProps.verts ~= newProps.verts or oldProps.lineColor ~= newProps.lineColor) then -- 2056
		local ____self_66 = node -- 2056
		local ____self_66_set_67 = ____self_66.set -- 2056
		local ____newProps_verts_65 = newProps.verts -- 2058
		local ____Dora_Color_64 = Dora.Color -- 2058
		local ____newProps_lineColor_63 = newProps.lineColor -- 2058
		if ____newProps_lineColor_63 == nil then -- 2058
			____newProps_lineColor_63 = 4294967295 -- 2058
		end -- 2058
		____self_66_set_67( -- 2058
			____self_66, -- 2058
			____newProps_verts_65, -- 2058
			____Dora_Color_64(____newProps_lineColor_63) -- 2058
		) -- 2058
	end -- 2058
end -- 2058
function clearRef(props, node) -- 2062
	local ref = props.ref -- 2063
	if ref ~= nil and (node == nil or ref.current == node) then -- 2063
		ref.current = nil -- 2065
	end -- 2065
end -- 2065
function patchRef(node, oldProps, newProps) -- 2069
	if oldProps.ref ~= newProps.ref then -- 2069
		clearRef(oldProps, node) -- 2071
		local ref = newProps.ref -- 2072
		if ref ~= nil then -- 2072
			ref.current = node -- 2074
		end -- 2074
	end -- 2074
end -- 2074
function applyProp(node, enode, key, value) -- 2079
	local name = key -- 2080
	repeat -- 2080
		local ____switch487 = name -- 2080
		local ____cond487 = ____switch487 == "key" or ____switch487 == "children" or ____switch487 == "onMount" or ____switch487 == "onUnmount" -- 2080
		if ____cond487 then -- 2080
			return -- 2086
		end -- 2086
		____cond487 = ____cond487 or ____switch487 == "ref" -- 2086
		if ____cond487 then -- 2086
			value.current = node -- 2088
			return -- 2089
		end -- 2089
		____cond487 = ____cond487 or ____switch487 == "anchorX" -- 2089
		if ____cond487 then -- 2089
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 2091
			return -- 2092
		end -- 2092
		____cond487 = ____cond487 or ____switch487 == "anchorY" -- 2092
		if ____cond487 then -- 2092
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 2094
			return -- 2095
		end -- 2095
		____cond487 = ____cond487 or ____switch487 == "color3" -- 2095
		if ____cond487 then -- 2095
			node.color3 = Dora.Color3(value) -- 2097
			return -- 2098
		end -- 2098
		____cond487 = ____cond487 or ____switch487 == "transformTarget" -- 2098
		if ____cond487 then -- 2098
			node.transformTarget = value.current -- 2100
			return -- 2101
		end -- 2101
		____cond487 = ____cond487 or ____switch487 == "outlineColor" -- 2101
		if ____cond487 then -- 2101
			node[name] = Dora.Color(value) -- 2103
			return -- 2104
		end -- 2104
		____cond487 = ____cond487 or ____switch487 == "smoothLower" -- 2104
		if ____cond487 then -- 2104
			do -- 2104
				local smooth = node.smooth -- 2106
				node.smooth = Dora.Vec2(value, smooth.y) -- 2107
				return -- 2108
			end -- 2108
		end -- 2108
		____cond487 = ____cond487 or ____switch487 == "smoothUpper" -- 2108
		if ____cond487 then -- 2108
			do -- 2108
				local smooth = node.smooth -- 2111
				node.smooth = Dora.Vec2(smooth.x, value) -- 2112
				return -- 2113
			end -- 2113
		end -- 2113
	until true -- 2113
	if isEventProp(key) then -- 2113
		if key == "onUpdate" then -- 2113
			patchUpdateProp(node, value) -- 2118
		elseif key == "onContactFilter" then -- 2118
			patchContactFilterProp(node, value) -- 2120
		elseif isPatchableEventProp(key) then -- 2120
			patchEventProp(node, key, value) -- 2122
		end -- 2122
		return -- 2124
	end -- 2124
	node[name] = value -- 2126
end -- 2126
function patchProps(node, oldElement, newElement) -- 2129
	local oldProps = oldElement.props -- 2130
	local newProps = newElement.props -- 2131
	for k in pairs(oldProps) do -- 2132
		if k == "onUpdate" and newProps[k] == nil then -- 2132
			patchUpdateProp(node, nil) -- 2134
		elseif k == "onContactFilter" and newProps[k] == nil then -- 2134
			patchContactFilterProp(node, nil) -- 2136
		elseif isPatchableEventProp(k) and newProps[k] == nil then -- 2136
			patchEventProp(node, k, nil) -- 2138
		elseif newProps[k] == nil then -- 2138
			clearRemovedProp(node, k) -- 2140
		end -- 2140
	end -- 2140
	patchRef(node, oldProps, newProps) -- 2143
	for k, v in pairs(newProps) do -- 2144
		if k ~= "ref" and oldProps[k] ~= v then -- 2144
			applyProp(node, newElement, k, v) -- 2146
		end -- 2146
	end -- 2146
	if newElement.type == "label" then -- 2146
		node.text = getPrimitiveLabelText(newElement) -- 2150
	elseif newElement.type == "physics-world" then -- 2150
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 2152
		if world ~= nil then -- 2152
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 2154
		end -- 2154
	elseif newElement.type == "playable" or newElement.type == "dragon-bone" or newElement.type == "spine" or newElement.type == "model" then -- 2154
		patchPlayableProps(node, oldProps, newProps) -- 2162
	elseif newElement.type == "audio-source" then -- 2162
		patchAudioSourceProps(node, oldProps, newProps) -- 2164
	elseif newElement.type == "particle" then -- 2164
		patchParticleProps(node, oldProps, newProps) -- 2166
	elseif newElement.type == "align-node" then -- 2166
		patchAlignNodeProps(node, oldProps, newProps) -- 2168
	elseif newElement.type == "line" then -- 2168
		patchLineProps(node, oldProps, newProps) -- 2170
	end -- 2170
	applyAutoEnableProps(node, newProps) -- 2172
end -- 2172
function addChildToParent(parent, node, props) -- 2175
	if props.tag ~= nil then -- 2175
		parent:addChild(node, props.order or 0, props.tag) -- 2177
	elseif props.order ~= nil then -- 2177
		parent:addChild(node, props.order) -- 2179
	else -- 2179
		parent:addChild(node) -- 2181
	end -- 2181
end -- 2181
function mountElement(parent, enode) -- 2185
	local node = createHostNode(enode, parent) -- 2186
	if node == nil then -- 2186
		return nil -- 2188
	end -- 2188
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 2188
		return nil -- 2197
	end -- 2197
	local props = enode.props -- 2199
	addChildToParent(parent, node, props) -- 2200
	local mounted = {element = enode, node = node, children = {}} -- 2201
	runActionChildren(node, enode) -- 2202
	mounted.children = reconcileChildren( -- 2203
		node, -- 2203
		{}, -- 2203
		getElementChildren(enode) -- 2203
	) -- 2203
	return mounted -- 2204
end -- 2204
function unmountElement(mounted) -- 2207
	for i = 1, #mounted.children do -- 2207
		unmountElement(mounted.children[i]) -- 2209
	end -- 2209
	local props = mounted.element.props -- 2211
	if props.onUnmount ~= nil then -- 2211
		props.onUnmount(mounted.node) -- 2213
	end -- 2213
	clearRef(mounted.element.props, mounted.node) -- 2215
	mounted.node:removeFromParent(true) -- 2216
end -- 2216
function reconcileElement(parent, oldMounted, newElement) -- 2219
	if oldMounted == nil then -- 2219
		return mountElement(parent, newElement) -- 2221
	end -- 2221
	if shouldRecreate(oldMounted.element, newElement) then -- 2221
		local oldNode = oldMounted.node -- 2224
		local oldOrder = oldNode.order -- 2225
		local oldTag = oldNode.tag -- 2226
		unmountElement(oldMounted) -- 2227
		local mounted = mountElement(parent, newElement) -- 2228
		if mounted ~= nil then -- 2228
			mounted.node.order = newElement.props.order or oldOrder -- 2230
			mounted.node.tag = newElement.props.tag or oldTag -- 2231
		end -- 2231
		return mounted -- 2233
	end -- 2233
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 2235
	patchActionChildren(oldMounted.node, oldMounted.element, newElement) -- 2236
	oldMounted.children = reconcileChildren( -- 2237
		oldMounted.node, -- 2237
		oldMounted.children, -- 2237
		getElementChildren(newElement) -- 2237
	) -- 2237
	oldMounted.element = newElement -- 2238
	return oldMounted -- 2239
end -- 2239
function reconcileChildren(parent, oldChildren, newElements) -- 2242
	local oldByKey = {} -- 2243
	local usedOld = {} -- 2244
	for i = 1, #oldChildren do -- 2244
		local oldChild = oldChildren[i] -- 2246
		local key = getElementKey(oldChild.element) -- 2247
		if key ~= nil then -- 2247
			oldByKey[key] = oldChild -- 2249
		end -- 2249
	end -- 2249
	local nextChildren = {} -- 2252
	for i = 1, #newElements do -- 2252
		local newElement = newElements[i] -- 2254
		local key = getElementKey(newElement) -- 2255
		local oldChild -- 2256
		if key ~= nil then -- 2256
			oldChild = oldByKey[key] -- 2258
		else -- 2258
			oldChild = oldChildren[i] -- 2260
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 2260
				oldChild = nil -- 2262
			end -- 2262
		end -- 2262
		local mounted = reconcileElement(parent, oldChild, newElement) -- 2265
		if mounted ~= nil then -- 2265
			usedOld[mounted] = true -- 2267
			nextChildren[#nextChildren + 1] = mounted -- 2268
			local props = newElement.props -- 2269
			mounted.node.order = props.order or i -- 2270
			if props.tag ~= nil then -- 2270
				mounted.node.tag = props.tag -- 2271
			end -- 2271
		end -- 2271
	end -- 2271
	for i = 1, #oldChildren do -- 2271
		local oldChild = oldChildren[i] -- 2275
		if not usedOld[oldChild] then -- 2275
			unmountElement(oldChild) -- 2277
		end -- 2277
	end -- 2277
	return nextChildren -- 2280
end -- 2280
____exports.React = {} -- 2280
local React = ____exports.React -- 2280
do -- 2280
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
					return typeName(props) -- 80
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
local function getNode(enode, cnode, attribHandler) -- 168
	cnode = cnode or Dora.Node() -- 169
	local jnode = enode.props -- 170
	local anchor -- 171
	local color3 -- 172
	for k, v in pairs(enode.props) do -- 173
		repeat -- 173
			local ____switch38 = k -- 173
			local ____cond38 = ____switch38 == "ref" -- 173
			if ____cond38 then -- 173
				v.current = cnode -- 175
				break -- 175
			end -- 175
			____cond38 = ____cond38 or ____switch38 == "anchorX" -- 175
			if ____cond38 then -- 175
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 176
				break -- 176
			end -- 176
			____cond38 = ____cond38 or ____switch38 == "anchorY" -- 176
			if ____cond38 then -- 176
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 177
				break -- 177
			end -- 177
			____cond38 = ____cond38 or ____switch38 == "color3" -- 177
			if ____cond38 then -- 177
				color3 = Dora.Color3(v) -- 178
				break -- 178
			end -- 178
			____cond38 = ____cond38 or ____switch38 == "transformTarget" -- 178
			if ____cond38 then -- 178
				cnode.transformTarget = v.current -- 179
				break -- 179
			end -- 179
			____cond38 = ____cond38 or ____switch38 == "onUpdate" -- 179
			if ____cond38 then -- 179
				cnode:schedule(v) -- 180
				break -- 180
			end -- 180
			____cond38 = ____cond38 or ____switch38 == "onActionEnd" -- 180
			if ____cond38 then -- 180
				cnode:slot("ActionEnd", v) -- 181
				break -- 181
			end -- 181
			____cond38 = ____cond38 or ____switch38 == "onTapFilter" -- 181
			if ____cond38 then -- 181
				cnode:slot("TapFilter", v) -- 182
				break -- 182
			end -- 182
			____cond38 = ____cond38 or ____switch38 == "onTapBegan" -- 182
			if ____cond38 then -- 182
				cnode:slot("TapBegan", v) -- 183
				break -- 183
			end -- 183
			____cond38 = ____cond38 or ____switch38 == "onTapEnded" -- 183
			if ____cond38 then -- 183
				cnode:slot("TapEnded", v) -- 184
				break -- 184
			end -- 184
			____cond38 = ____cond38 or ____switch38 == "onTapped" -- 184
			if ____cond38 then -- 184
				cnode:slot("Tapped", v) -- 185
				break -- 185
			end -- 185
			____cond38 = ____cond38 or ____switch38 == "onTapMoved" -- 185
			if ____cond38 then -- 185
				cnode:slot("TapMoved", v) -- 186
				break -- 186
			end -- 186
			____cond38 = ____cond38 or ____switch38 == "onMouseWheel" -- 186
			if ____cond38 then -- 186
				cnode:slot("MouseWheel", v) -- 187
				break -- 187
			end -- 187
			____cond38 = ____cond38 or ____switch38 == "onGesture" -- 187
			if ____cond38 then -- 187
				cnode:slot("Gesture", v) -- 188
				break -- 188
			end -- 188
			____cond38 = ____cond38 or ____switch38 == "onEnter" -- 188
			if ____cond38 then -- 188
				cnode:slot("Enter", v) -- 189
				break -- 189
			end -- 189
			____cond38 = ____cond38 or ____switch38 == "onExit" -- 189
			if ____cond38 then -- 189
				cnode:slot("Exit", v) -- 190
				break -- 190
			end -- 190
			____cond38 = ____cond38 or ____switch38 == "onCleanup" -- 190
			if ____cond38 then -- 190
				cnode:slot("Cleanup", v) -- 191
				break -- 191
			end -- 191
			____cond38 = ____cond38 or ____switch38 == "onUnmount" -- 191
			if ____cond38 then -- 191
				break -- 192
			end -- 192
			____cond38 = ____cond38 or ____switch38 == "onKeyDown" -- 192
			if ____cond38 then -- 192
				cnode:slot("KeyDown", v) -- 193
				break -- 193
			end -- 193
			____cond38 = ____cond38 or ____switch38 == "onKeyUp" -- 193
			if ____cond38 then -- 193
				cnode:slot("KeyUp", v) -- 194
				break -- 194
			end -- 194
			____cond38 = ____cond38 or ____switch38 == "onKeyPressed" -- 194
			if ____cond38 then -- 194
				cnode:slot("KeyPressed", v) -- 195
				break -- 195
			end -- 195
			____cond38 = ____cond38 or ____switch38 == "onAttachIME" -- 195
			if ____cond38 then -- 195
				cnode:slot("AttachIME", v) -- 196
				break -- 196
			end -- 196
			____cond38 = ____cond38 or ____switch38 == "onDetachIME" -- 196
			if ____cond38 then -- 196
				cnode:slot("DetachIME", v) -- 197
				break -- 197
			end -- 197
			____cond38 = ____cond38 or ____switch38 == "onTextInput" -- 197
			if ____cond38 then -- 197
				cnode:slot("TextInput", v) -- 198
				break -- 198
			end -- 198
			____cond38 = ____cond38 or ____switch38 == "onTextEditing" -- 198
			if ____cond38 then -- 198
				cnode:slot("TextEditing", v) -- 199
				break -- 199
			end -- 199
			____cond38 = ____cond38 or ____switch38 == "onButtonDown" -- 199
			if ____cond38 then -- 199
				cnode:slot("ButtonDown", v) -- 200
				break -- 200
			end -- 200
			____cond38 = ____cond38 or ____switch38 == "onButtonUp" -- 200
			if ____cond38 then -- 200
				cnode:slot("ButtonUp", v) -- 201
				break -- 201
			end -- 201
			____cond38 = ____cond38 or ____switch38 == "onAxis" -- 201
			if ____cond38 then -- 201
				cnode:slot("Axis", v) -- 202
				break -- 202
			end -- 202
			do -- 202
				do -- 202
					if attribHandler then -- 202
						if not attribHandler(cnode, enode, k, v) then -- 202
							cnode[k] = v -- 206
						end -- 206
					else -- 206
						cnode[k] = v -- 209
					end -- 209
					break -- 211
				end -- 211
			end -- 211
		until true -- 211
	end -- 211
	applyAutoEnableProps(cnode, enode.props) -- 215
	if anchor ~= nil then -- 215
		cnode.anchor = anchor -- 216
	end -- 216
	if color3 ~= nil then -- 216
		cnode.color3 = color3 -- 217
	end -- 217
	if jnode.onMount ~= nil then -- 217
		jnode.onMount(cnode) -- 219
	end -- 219
	return cnode -- 221
end -- 168
local getClipNode -- 224
do -- 224
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 226
		repeat -- 226
			local ____switch48 = k -- 226
			local ____cond48 = ____switch48 == "stencil" -- 226
			if ____cond48 then -- 226
				cnode.stencil = ____exports.toNode(v) -- 233
				return true -- 233
			end -- 233
		until true -- 233
		return false -- 235
	end -- 226
	getClipNode = function(enode) -- 237
		return getNode( -- 238
			enode, -- 238
			Dora.ClipNode(), -- 238
			handleClipNodeAttribute -- 238
		) -- 238
	end -- 237
end -- 237
local getPlayable -- 242
local getDragonBone -- 243
local getSpine -- 244
local getModel -- 245
do -- 245
	local function handlePlayableAttribute(cnode, enode, k, v) -- 247
		repeat -- 247
			local ____switch52 = k -- 247
			local ____cond52 = ____switch52 == "file" -- 247
			if ____cond52 then -- 247
				return true -- 249
			end -- 249
			____cond52 = ____cond52 or ____switch52 == "play" -- 249
			if ____cond52 then -- 249
				cnode:play(v, enode.props.loop == true) -- 250
				return true -- 250
			end -- 250
			____cond52 = ____cond52 or ____switch52 == "loop" -- 250
			if ____cond52 then -- 250
				return true -- 251
			end -- 251
			____cond52 = ____cond52 or ____switch52 == "onAnimationEnd" -- 251
			if ____cond52 then -- 251
				cnode:slot("AnimationEnd", v) -- 252
				return true -- 252
			end -- 252
		until true -- 252
		return false -- 254
	end -- 247
	getPlayable = function(enode, cnode, attribHandler) -- 256
		if attribHandler == nil then -- 256
			attribHandler = handlePlayableAttribute -- 257
		end -- 257
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 258
		if cnode ~= nil then -- 258
			return getNode(enode, cnode, attribHandler) -- 260
		end -- 260
		return nil -- 262
	end -- 256
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 265
		repeat -- 265
			local ____switch56 = k -- 265
			local ____cond56 = ____switch56 == "hitTestEnabled" -- 265
			if ____cond56 then -- 265
				cnode.hitTestEnabled = true -- 267
				return true -- 267
			end -- 267
		until true -- 267
		return handlePlayableAttribute(cnode, enode, k, v) -- 269
	end -- 265
	getDragonBone = function(enode) -- 271
		local node = Dora.DragonBone(enode.props.file) -- 272
		if node ~= nil then -- 272
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 274
			return cnode -- 275
		end -- 275
		return nil -- 277
	end -- 271
	local function handleSpineAttribute(cnode, enode, k, v) -- 280
		repeat -- 280
			local ____switch60 = k -- 280
			local ____cond60 = ____switch60 == "hitTestEnabled" -- 280
			if ____cond60 then -- 280
				cnode.hitTestEnabled = true -- 282
				return true -- 282
			end -- 282
		until true -- 282
		return handlePlayableAttribute(cnode, enode, k, v) -- 284
	end -- 280
	getSpine = function(enode) -- 286
		local node = Dora.Spine(enode.props.file) -- 287
		if node ~= nil then -- 287
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 289
			return cnode -- 290
		end -- 290
		return nil -- 292
	end -- 286
	local function handleModelAttribute(cnode, enode, k, v) -- 295
		repeat -- 295
			local ____switch64 = k -- 295
			local ____cond64 = ____switch64 == "reversed" -- 295
			if ____cond64 then -- 295
				cnode.reversed = v -- 297
				return true -- 297
			end -- 297
		until true -- 297
		return handlePlayableAttribute(cnode, enode, k, v) -- 299
	end -- 295
	getModel = function(enode) -- 301
		local node = Dora.Model(enode.props.file) -- 302
		if node ~= nil then -- 302
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 304
			return cnode -- 305
		end -- 305
		return nil -- 307
	end -- 301
end -- 301
local getDrawNode -- 311
do -- 311
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 313
		repeat -- 313
			local ____switch69 = k -- 313
			local ____cond69 = ____switch69 == "depthWrite" -- 313
			if ____cond69 then -- 313
				cnode.depthWrite = v -- 315
				return true -- 315
			end -- 315
			____cond69 = ____cond69 or ____switch69 == "blendFunc" -- 315
			if ____cond69 then -- 315
				cnode.blendFunc = v -- 316
				return true -- 316
			end -- 316
		until true -- 316
		return false -- 318
	end -- 313
	getDrawNode = function(enode) -- 320
		local node = Dora.DrawNode() -- 321
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 322
		local ____enode_5 = enode -- 323
		local children = ____enode_5.children -- 323
		for i = 1, #children do -- 323
			do -- 323
				local child = children[i] -- 325
				if type(child) ~= "table" then -- 325
					goto __continue71 -- 327
				end -- 327
				repeat -- 327
					local ____switch73 = child.type -- 327
					local ____cond73 = ____switch73 == "dot-shape" -- 327
					if ____cond73 then -- 327
						do -- 327
							local dot = child.props -- 331
							node:drawDot( -- 332
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 333
								dot.radius, -- 334
								Dora.Color(dot.color or 4294967295) -- 335
							) -- 335
							break -- 337
						end -- 337
					end -- 337
					____cond73 = ____cond73 or ____switch73 == "segment-shape" -- 337
					if ____cond73 then -- 337
						do -- 337
							local segment = child.props -- 340
							node:drawSegment( -- 341
								Dora.Vec2(segment.startX, segment.startY), -- 342
								Dora.Vec2(segment.stopX, segment.stopY), -- 343
								segment.radius, -- 344
								Dora.Color(segment.color or 4294967295) -- 345
							) -- 345
							break -- 347
						end -- 347
					end -- 347
					____cond73 = ____cond73 or ____switch73 == "rect-shape" -- 347
					if ____cond73 then -- 347
						do -- 347
							local rect = child.props -- 350
							local centerX = rect.centerX or 0 -- 351
							local centerY = rect.centerY or 0 -- 352
							local hw = rect.width / 2 -- 353
							local hh = rect.height / 2 -- 354
							node:drawPolygon( -- 355
								{ -- 356
									Dora.Vec2(centerX - hw, centerY + hh), -- 357
									Dora.Vec2(centerX + hw, centerY + hh), -- 358
									Dora.Vec2(centerX + hw, centerY - hh), -- 359
									Dora.Vec2(centerX - hw, centerY - hh) -- 360
								}, -- 360
								Dora.Color(rect.fillColor or 4294967295), -- 362
								rect.borderWidth or 0, -- 363
								Dora.Color(rect.borderColor or 4294967295) -- 364
							) -- 364
							break -- 366
						end -- 366
					end -- 366
					____cond73 = ____cond73 or ____switch73 == "polygon-shape" -- 366
					if ____cond73 then -- 366
						do -- 366
							local poly = child.props -- 369
							node:drawPolygon( -- 370
								poly.verts, -- 371
								Dora.Color(poly.fillColor or 4294967295), -- 372
								poly.borderWidth or 0, -- 373
								Dora.Color(poly.borderColor or 4294967295) -- 374
							) -- 374
							break -- 376
						end -- 376
					end -- 376
					____cond73 = ____cond73 or ____switch73 == "verts-shape" -- 376
					if ____cond73 then -- 376
						do -- 376
							local verts = child.props -- 379
							node:drawVertices(__TS__ArrayMap( -- 380
								verts.verts, -- 380
								function(____, ____bindingPattern0) -- 380
									local color -- 380
									local vert -- 380
									vert = ____bindingPattern0[1] -- 380
									color = ____bindingPattern0[2] -- 380
									return { -- 380
										vert, -- 380
										Dora.Color(color) -- 380
									} -- 380
								end -- 380
							)) -- 380
							break -- 381
						end -- 381
					end -- 381
				until true -- 381
			end -- 381
			::__continue71:: -- 381
		end -- 381
		return cnode -- 385
	end -- 320
end -- 320
local getGrid -- 389
do -- 389
	local function handleGridAttribute(cnode, _enode, k, v) -- 391
		repeat -- 391
			local ____switch82 = k -- 391
			local ____cond82 = ____switch82 == "file" or ____switch82 == "gridX" or ____switch82 == "gridY" -- 391
			if ____cond82 then -- 391
				return true -- 393
			end -- 393
			____cond82 = ____cond82 or ____switch82 == "textureRect" -- 393
			if ____cond82 then -- 393
				cnode.textureRect = v -- 394
				return true -- 394
			end -- 394
			____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 394
			if ____cond82 then -- 394
				cnode.depthWrite = v -- 395
				return true -- 395
			end -- 395
			____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 395
			if ____cond82 then -- 395
				cnode.blendFunc = v -- 396
				return true -- 396
			end -- 396
			____cond82 = ____cond82 or ____switch82 == "effect" -- 396
			if ____cond82 then -- 396
				cnode.effect = v -- 397
				return true -- 397
			end -- 397
		until true -- 397
		return false -- 399
	end -- 391
	getGrid = function(enode) -- 401
		local grid = enode.props -- 402
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 403
		local cnode = getNode(enode, node, handleGridAttribute) -- 404
		return cnode -- 405
	end -- 401
end -- 401
local getSprite -- 409
local getVideoNode -- 410
local getTIC80Node -- 411
do -- 411
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 413
		repeat -- 413
			local ____switch86 = k -- 413
			local ____cond86 = ____switch86 == "file" -- 413
			if ____cond86 then -- 413
				return true -- 415
			end -- 415
			____cond86 = ____cond86 or ____switch86 == "textureRect" -- 415
			if ____cond86 then -- 415
				cnode.textureRect = v -- 416
				return true -- 416
			end -- 416
			____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 416
			if ____cond86 then -- 416
				cnode.depthWrite = v -- 417
				return true -- 417
			end -- 417
			____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 417
			if ____cond86 then -- 417
				cnode.blendFunc = v -- 418
				return true -- 418
			end -- 418
			____cond86 = ____cond86 or ____switch86 == "effect" -- 418
			if ____cond86 then -- 418
				cnode.effect = v -- 419
				return true -- 419
			end -- 419
			____cond86 = ____cond86 or ____switch86 == "alphaRef" -- 419
			if ____cond86 then -- 419
				cnode.alphaRef = v -- 420
				return true -- 420
			end -- 420
			____cond86 = ____cond86 or ____switch86 == "uwrap" -- 420
			if ____cond86 then -- 420
				cnode.uwrap = v -- 421
				return true -- 421
			end -- 421
			____cond86 = ____cond86 or ____switch86 == "vwrap" -- 421
			if ____cond86 then -- 421
				cnode.vwrap = v -- 422
				return true -- 422
			end -- 422
			____cond86 = ____cond86 or ____switch86 == "filter" -- 422
			if ____cond86 then -- 422
				cnode.filter = v -- 423
				return true -- 423
			end -- 423
		until true -- 423
		return false -- 425
	end -- 413
	getSprite = function(enode) -- 427
		local sp = enode.props -- 428
		if sp.file then -- 428
			local node = Dora.Sprite(sp.file) -- 430
			if node ~= nil then -- 430
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 432
				return cnode -- 433
			end -- 433
		else -- 433
			local node = Dora.Sprite() -- 436
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 437
			return cnode -- 438
		end -- 438
		return nil -- 440
	end -- 427
	getVideoNode = function(enode) -- 442
		local vn = enode.props -- 443
		local ____Dora_VideoNode_8 = Dora.VideoNode -- 444
		local ____vn_file_7 = vn.file -- 444
		local ____vn_looped_6 = vn.looped -- 444
		if ____vn_looped_6 == nil then -- 444
			____vn_looped_6 = false -- 444
		end -- 444
		local node = ____Dora_VideoNode_8(____vn_file_7, ____vn_looped_6) -- 444
		if node ~= nil then -- 444
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 446
			return cnode -- 447
		end -- 447
		return nil -- 449
	end -- 442
	getTIC80Node = function(enode) -- 451
		local tic = enode.props -- 452
		local node = Dora.TIC80Node(tic.file) -- 453
		if node ~= nil then -- 453
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 455
			return cnode -- 456
		end -- 456
		return nil -- 458
	end -- 451
end -- 451
local getAudioSource -- 462
do -- 462
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 464
		repeat -- 464
			local ____switch97 = k -- 464
			local ____cond97 = ____switch97 == "file" -- 464
			if ____cond97 then -- 464
				return true -- 466
			end -- 466
			____cond97 = ____cond97 or ____switch97 == "autoRemove" -- 466
			if ____cond97 then -- 466
				return true -- 467
			end -- 467
			____cond97 = ____cond97 or ____switch97 == "bus" -- 467
			if ____cond97 then -- 467
				return true -- 468
			end -- 468
			____cond97 = ____cond97 or ____switch97 == "volume" -- 468
			if ____cond97 then -- 468
				cnode.volume = v -- 469
				return true -- 469
			end -- 469
			____cond97 = ____cond97 or ____switch97 == "pan" -- 469
			if ____cond97 then -- 469
				cnode.pan = v -- 470
				return true -- 470
			end -- 470
			____cond97 = ____cond97 or ____switch97 == "looping" -- 470
			if ____cond97 then -- 470
				cnode.looping = v -- 471
				return true -- 471
			end -- 471
			____cond97 = ____cond97 or ____switch97 == "playMode" -- 471
			if ____cond97 then -- 471
				do -- 471
					local aus = enode.props -- 473
					repeat -- 473
						local ____switch99 = v -- 473
						local ____cond99 = ____switch99 == "normal" -- 473
						if ____cond99 then -- 473
							cnode:play(aus.delayTime or 0) -- 475
							break -- 475
						end -- 475
						____cond99 = ____cond99 or ____switch99 == "background" -- 475
						if ____cond99 then -- 475
							cnode:playBackground() -- 476
							break -- 476
						end -- 476
						____cond99 = ____cond99 or ____switch99 == "3D" -- 476
						if ____cond99 then -- 476
							cnode:play3D(aus.delayTime or 0) -- 477
							break -- 477
						end -- 477
					until true -- 477
					return true -- 479
				end -- 479
			end -- 479
			____cond97 = ____cond97 or ____switch97 == "delayTime" -- 479
			if ____cond97 then -- 479
				return true -- 481
			end -- 481
			____cond97 = ____cond97 or ____switch97 == "protected" -- 481
			if ____cond97 then -- 481
				cnode:setProtected(v) -- 482
				return true -- 482
			end -- 482
			____cond97 = ____cond97 or ____switch97 == "loopPoint" -- 482
			if ____cond97 then -- 482
				cnode:setLoopPoint(v) -- 483
				return true -- 483
			end -- 483
			____cond97 = ____cond97 or ____switch97 == "velocity" -- 483
			if ____cond97 then -- 483
				do -- 483
					local vx, vy, vz = table.unpack(v, 1, 3) -- 485
					cnode:setVelocity(vx, vy, vz) -- 486
					return true -- 487
				end -- 487
			end -- 487
			____cond97 = ____cond97 or ____switch97 == "minMaxDistance" -- 487
			if ____cond97 then -- 487
				do -- 487
					local min, max = table.unpack(v, 1, 2) -- 490
					cnode:setMinMaxDistance(min, max) -- 491
					return true -- 492
				end -- 492
			end -- 492
			____cond97 = ____cond97 or ____switch97 == "attenuation" -- 492
			if ____cond97 then -- 492
				do -- 492
					local model, factor = table.unpack(v, 1, 2) -- 495
					cnode:setAttenuation(model, factor) -- 496
					return true -- 497
				end -- 497
			end -- 497
			____cond97 = ____cond97 or ____switch97 == "dopplerFactor" -- 497
			if ____cond97 then -- 497
				cnode:setDopplerFactor(v) -- 499
				return true -- 499
			end -- 499
		until true -- 499
		return false -- 501
	end -- 464
	getAudioSource = function(enode) -- 503
		local aus = enode.props -- 504
		local ____aus_autoRemove_9 = aus.autoRemove -- 505
		if ____aus_autoRemove_9 == nil then -- 505
			____aus_autoRemove_9 = true -- 505
		end -- 505
		local autoRemove = ____aus_autoRemove_9 -- 505
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 506
		if node ~= nil then -- 506
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 508
			return cnode -- 509
		end -- 509
		return nil -- 511
	end -- 503
end -- 503
local getLabel -- 515
do -- 515
	local function handleLabelAttribute(cnode, _enode, k, v) -- 517
		repeat -- 517
			local ____switch107 = k -- 517
			local ____cond107 = ____switch107 == "fontName" or ____switch107 == "fontSize" or ____switch107 == "text" or ____switch107 == "smoothLower" or ____switch107 == "smoothUpper" -- 517
			if ____cond107 then -- 517
				return true -- 519
			end -- 519
			____cond107 = ____cond107 or ____switch107 == "alphaRef" -- 519
			if ____cond107 then -- 519
				cnode.alphaRef = v -- 520
				return true -- 520
			end -- 520
			____cond107 = ____cond107 or ____switch107 == "textWidth" -- 520
			if ____cond107 then -- 520
				cnode.textWidth = v -- 521
				return true -- 521
			end -- 521
			____cond107 = ____cond107 or ____switch107 == "lineGap" -- 521
			if ____cond107 then -- 521
				cnode.lineGap = v -- 522
				return true -- 522
			end -- 522
			____cond107 = ____cond107 or ____switch107 == "spacing" -- 522
			if ____cond107 then -- 522
				cnode.spacing = v -- 523
				return true -- 523
			end -- 523
			____cond107 = ____cond107 or ____switch107 == "outlineColor" -- 523
			if ____cond107 then -- 523
				cnode.outlineColor = Dora.Color(v) -- 524
				return true -- 524
			end -- 524
			____cond107 = ____cond107 or ____switch107 == "outlineWidth" -- 524
			if ____cond107 then -- 524
				cnode.outlineWidth = v -- 525
				return true -- 525
			end -- 525
			____cond107 = ____cond107 or ____switch107 == "blendFunc" -- 525
			if ____cond107 then -- 525
				cnode.blendFunc = v -- 526
				return true -- 526
			end -- 526
			____cond107 = ____cond107 or ____switch107 == "depthWrite" -- 526
			if ____cond107 then -- 526
				cnode.depthWrite = v -- 527
				return true -- 527
			end -- 527
			____cond107 = ____cond107 or ____switch107 == "batched" -- 527
			if ____cond107 then -- 527
				cnode.batched = v -- 528
				return true -- 528
			end -- 528
			____cond107 = ____cond107 or ____switch107 == "effect" -- 528
			if ____cond107 then -- 528
				cnode.effect = v -- 529
				return true -- 529
			end -- 529
			____cond107 = ____cond107 or ____switch107 == "alignment" -- 529
			if ____cond107 then -- 529
				cnode.alignment = v -- 530
				return true -- 530
			end -- 530
		until true -- 530
		return false -- 532
	end -- 517
	getLabel = function(enode) -- 534
		local label = enode.props -- 535
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 536
		if node ~= nil then -- 536
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 536
				local ____node_smooth_10 = node.smooth -- 539
				local x = ____node_smooth_10.x -- 539
				local y = ____node_smooth_10.y -- 539
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 540
			end -- 540
			local cnode = getNode(enode, node, handleLabelAttribute) -- 542
			local ____enode_11 = enode -- 543
			local children = ____enode_11.children -- 543
			local text = label.text or "" -- 544
			for i = 1, #children do -- 544
				local child = children[i] -- 546
				if type(child) ~= "table" then -- 546
					text = text .. tostring(child) -- 548
				end -- 548
			end -- 548
			node.text = text -- 551
			return cnode -- 552
		end -- 552
		return nil -- 554
	end -- 534
end -- 534
local getLine -- 558
do -- 558
	local function handleLineAttribute(cnode, enode, k, v) -- 560
		local line = enode.props -- 561
		repeat -- 561
			local ____switch115 = k -- 561
			local ____cond115 = ____switch115 == "verts" -- 561
			if ____cond115 then -- 561
				cnode:set( -- 563
					v, -- 563
					Dora.Color(line.lineColor or 4294967295) -- 563
				) -- 563
				return true -- 563
			end -- 563
			____cond115 = ____cond115 or ____switch115 == "depthWrite" -- 563
			if ____cond115 then -- 563
				cnode.depthWrite = v -- 564
				return true -- 564
			end -- 564
			____cond115 = ____cond115 or ____switch115 == "blendFunc" -- 564
			if ____cond115 then -- 564
				cnode.blendFunc = v -- 565
				return true -- 565
			end -- 565
		until true -- 565
		return false -- 567
	end -- 560
	getLine = function(enode) -- 569
		local node = Dora.Line() -- 570
		local cnode = getNode(enode, node, handleLineAttribute) -- 571
		return cnode -- 572
	end -- 569
end -- 569
local getParticle -- 576
do -- 576
	local function handleParticleAttribute(cnode, _enode, k, v) -- 578
		repeat -- 578
			local ____switch119 = k -- 578
			local ____cond119 = ____switch119 == "file" -- 578
			if ____cond119 then -- 578
				return true -- 580
			end -- 580
			____cond119 = ____cond119 or ____switch119 == "emit" -- 580
			if ____cond119 then -- 580
				if v then -- 580
					cnode:start() -- 581
				end -- 581
				return true -- 581
			end -- 581
			____cond119 = ____cond119 or ____switch119 == "onFinished" -- 581
			if ____cond119 then -- 581
				cnode:slot("Finished", v) -- 582
				return true -- 582
			end -- 582
		until true -- 582
		return false -- 584
	end -- 578
	getParticle = function(enode) -- 586
		local particle = enode.props -- 587
		local node = Dora.Particle(particle.file) -- 588
		if node ~= nil then -- 588
			local cnode = getNode(enode, node, handleParticleAttribute) -- 590
			return cnode -- 591
		end -- 591
		return nil -- 593
	end -- 586
end -- 586
local getMenu -- 597
do -- 597
	local function handleMenuAttribute(cnode, _enode, k, v) -- 599
		repeat -- 599
			local ____switch125 = k -- 599
			local ____cond125 = ____switch125 == "enabled" -- 599
			if ____cond125 then -- 599
				cnode.enabled = v -- 601
				return true -- 601
			end -- 601
		until true -- 601
		return false -- 603
	end -- 599
	getMenu = function(enode) -- 605
		local node = Dora.Menu() -- 606
		local cnode = getNode(enode, node, handleMenuAttribute) -- 607
		return cnode -- 608
	end -- 605
end -- 605
local function getPhysicsWorld(enode) -- 612
	local node = Dora.PhysicsWorld() -- 613
	local cnode = getNode(enode, node) -- 614
	return cnode -- 615
end -- 612
local getBody -- 618
do -- 618
	local function handleBodyAttribute(cnode, _enode, k, v) -- 620
		repeat -- 620
			local ____switch130 = k -- 620
			local ____cond130 = ____switch130 == "type" or ____switch130 == "linearAcceleration" or ____switch130 == "fixedRotation" or ____switch130 == "bullet" or ____switch130 == "world" -- 620
			if ____cond130 then -- 620
				return true -- 627
			end -- 627
			____cond130 = ____cond130 or ____switch130 == "velocityX" -- 627
			if ____cond130 then -- 627
				cnode.velocityX = v -- 628
				return true -- 628
			end -- 628
			____cond130 = ____cond130 or ____switch130 == "velocityY" -- 628
			if ____cond130 then -- 628
				cnode.velocityY = v -- 629
				return true -- 629
			end -- 629
			____cond130 = ____cond130 or ____switch130 == "angularRate" -- 629
			if ____cond130 then -- 629
				cnode.angularRate = v -- 630
				return true -- 630
			end -- 630
			____cond130 = ____cond130 or ____switch130 == "group" -- 630
			if ____cond130 then -- 630
				cnode.group = v -- 631
				return true -- 631
			end -- 631
			____cond130 = ____cond130 or ____switch130 == "linearDamping" -- 631
			if ____cond130 then -- 631
				cnode.linearDamping = v -- 632
				return true -- 632
			end -- 632
			____cond130 = ____cond130 or ____switch130 == "angularDamping" -- 632
			if ____cond130 then -- 632
				cnode.angularDamping = v -- 633
				return true -- 633
			end -- 633
			____cond130 = ____cond130 or ____switch130 == "owner" -- 633
			if ____cond130 then -- 633
				cnode.owner = v -- 634
				return true -- 634
			end -- 634
			____cond130 = ____cond130 or ____switch130 == "receivingContact" -- 634
			if ____cond130 then -- 634
				cnode.receivingContact = v -- 635
				return true -- 635
			end -- 635
			____cond130 = ____cond130 or ____switch130 == "onBodyEnter" -- 635
			if ____cond130 then -- 635
				cnode:slot("BodyEnter", v) -- 636
				return true -- 636
			end -- 636
			____cond130 = ____cond130 or ____switch130 == "onBodyLeave" -- 636
			if ____cond130 then -- 636
				cnode:slot("BodyLeave", v) -- 637
				return true -- 637
			end -- 637
			____cond130 = ____cond130 or ____switch130 == "onContactStart" -- 637
			if ____cond130 then -- 637
				cnode:slot("ContactStart", v) -- 638
				return true -- 638
			end -- 638
			____cond130 = ____cond130 or ____switch130 == "onContactEnd" -- 638
			if ____cond130 then -- 638
				cnode:slot("ContactEnd", v) -- 639
				return true -- 639
			end -- 639
			____cond130 = ____cond130 or ____switch130 == "onContactFilter" -- 639
			if ____cond130 then -- 639
				cnode:onContactFilter(v) -- 640
				return true -- 640
			end -- 640
		until true -- 640
		return false -- 642
	end -- 620
	getBody = function(enode, world) -- 644
		local def = enode.props -- 645
		local bodyDef = Dora.BodyDef() -- 646
		bodyDef.type = def.type -- 647
		if def.angle ~= nil then -- 647
			bodyDef.angle = def.angle -- 648
		end -- 648
		if def.angularDamping ~= nil then -- 648
			bodyDef.angularDamping = def.angularDamping -- 649
		end -- 649
		if def.bullet ~= nil then -- 649
			bodyDef.bullet = def.bullet -- 650
		end -- 650
		if def.fixedRotation ~= nil then -- 650
			bodyDef.fixedRotation = def.fixedRotation -- 651
		end -- 651
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 652
		if def.linearDamping ~= nil then -- 652
			bodyDef.linearDamping = def.linearDamping -- 653
		end -- 653
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 654
		local extraSensors -- 655
		for i = 1, #enode.children do -- 655
			do -- 655
				local child = enode.children[i] -- 657
				if type(child) ~= "table" then -- 657
					goto __continue137 -- 659
				end -- 659
				repeat -- 659
					local ____switch139 = child.type -- 659
					local ____cond139 = ____switch139 == "rect-fixture" -- 659
					if ____cond139 then -- 659
						do -- 659
							local shape = child.props -- 663
							if shape.sensorTag ~= nil then -- 663
								bodyDef:attachPolygonSensor( -- 665
									shape.sensorTag, -- 666
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 667
									shape.width, -- 668
									shape.height, -- 668
									shape.angle or 0 -- 669
								) -- 669
							else -- 669
								bodyDef:attachPolygon( -- 672
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 673
									shape.width, -- 674
									shape.height, -- 674
									shape.angle or 0, -- 675
									shape.density or 1, -- 676
									shape.friction or 0.4, -- 677
									shape.restitution or 0 -- 678
								) -- 678
							end -- 678
							break -- 681
						end -- 681
					end -- 681
					____cond139 = ____cond139 or ____switch139 == "polygon-fixture" -- 681
					if ____cond139 then -- 681
						do -- 681
							local shape = child.props -- 684
							if shape.sensorTag ~= nil then -- 684
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 686
							else -- 686
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 691
							end -- 691
							break -- 698
						end -- 698
					end -- 698
					____cond139 = ____cond139 or ____switch139 == "multi-fixture" -- 698
					if ____cond139 then -- 698
						do -- 698
							local shape = child.props -- 701
							if shape.sensorTag ~= nil then -- 701
								if extraSensors == nil then -- 701
									extraSensors = {} -- 703
								end -- 703
								extraSensors[#extraSensors + 1] = { -- 704
									shape.sensorTag, -- 704
									Dora.BodyDef:multi(shape.verts) -- 704
								} -- 704
							else -- 704
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 706
							end -- 706
							break -- 713
						end -- 713
					end -- 713
					____cond139 = ____cond139 or ____switch139 == "disk-fixture" -- 713
					if ____cond139 then -- 713
						do -- 713
							local shape = child.props -- 716
							if shape.sensorTag ~= nil then -- 716
								bodyDef:attachDiskSensor( -- 718
									shape.sensorTag, -- 719
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 720
									shape.radius -- 721
								) -- 721
							else -- 721
								bodyDef:attachDisk( -- 724
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 725
									shape.radius, -- 726
									shape.density or 1, -- 727
									shape.friction or 0.4, -- 728
									shape.restitution or 0 -- 729
								) -- 729
							end -- 729
							break -- 732
						end -- 732
					end -- 732
					____cond139 = ____cond139 or ____switch139 == "chain-fixture" -- 732
					if ____cond139 then -- 732
						do -- 732
							local shape = child.props -- 735
							if shape.sensorTag ~= nil then -- 735
								if extraSensors == nil then -- 735
									extraSensors = {} -- 737
								end -- 737
								extraSensors[#extraSensors + 1] = { -- 738
									shape.sensorTag, -- 738
									Dora.BodyDef:chain(shape.verts) -- 738
								} -- 738
							else -- 738
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 740
							end -- 740
							break -- 746
						end -- 746
					end -- 746
				until true -- 746
			end -- 746
			::__continue137:: -- 746
		end -- 746
		local body = Dora.Body(bodyDef, world) -- 750
		if extraSensors ~= nil then -- 750
			for i = 1, #extraSensors do -- 750
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 753
				body:attachSensor(tag, def) -- 754
			end -- 754
		end -- 754
		local cnode = getNode(enode, body, handleBodyAttribute) -- 757
		return cnode -- 758
	end -- 644
end -- 644
local getCustomNode -- 762
do -- 762
	local function handleCustomNode(_cnode, _enode, k, _v) -- 764
		repeat -- 764
			local ____switch159 = k -- 764
			local ____cond159 = ____switch159 == "onCreate" -- 764
			if ____cond159 then -- 764
				return true -- 766
			end -- 766
		until true -- 766
		return false -- 768
	end -- 764
	getCustomNode = function(enode) -- 770
		local custom = enode.props -- 771
		local node = custom.onCreate() -- 772
		if node then -- 772
			local cnode = getNode(enode, node, handleCustomNode) -- 774
			return cnode -- 775
		end -- 775
		return nil -- 777
	end -- 770
end -- 770
local getAlignNode -- 781
do -- 781
	local function handleAlignNode(_cnode, _enode, k, _v) -- 783
		repeat -- 783
			local ____switch164 = k -- 783
			local ____cond164 = ____switch164 == "windowRoot" -- 783
			if ____cond164 then -- 783
				return true -- 785
			end -- 785
			____cond164 = ____cond164 or ____switch164 == "style" -- 785
			if ____cond164 then -- 785
				return true -- 786
			end -- 786
			____cond164 = ____cond164 or ____switch164 == "onLayout" -- 786
			if ____cond164 then -- 786
				return true -- 787
			end -- 787
		until true -- 787
		return false -- 789
	end -- 783
	getAlignNode = function(enode) -- 791
		local alignNode = enode.props -- 792
		local node = Dora.AlignNode(alignNode.windowRoot) -- 793
		if alignNode.style then -- 793
			node:css(getAlignStyleText(alignNode.style)) -- 795
		end -- 795
		if alignNode.onLayout then -- 795
			node:slot("AlignLayout", alignNode.onLayout) -- 798
		end -- 798
		local cnode = getNode(enode, node, handleAlignNode) -- 800
		return cnode -- 801
	end -- 791
end -- 791
local function getEffekNode(enode) -- 805
	return getNode( -- 806
		enode, -- 806
		Dora.EffekNode() -- 806
	) -- 806
end -- 805
local getTileNode -- 809
do -- 809
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 811
		repeat -- 811
			local ____switch171 = k -- 811
			local ____cond171 = ____switch171 == "file" or ____switch171 == "layers" -- 811
			if ____cond171 then -- 811
				return true -- 813
			end -- 813
			____cond171 = ____cond171 or ____switch171 == "depthWrite" -- 813
			if ____cond171 then -- 813
				cnode.depthWrite = v -- 814
				return true -- 814
			end -- 814
			____cond171 = ____cond171 or ____switch171 == "blendFunc" -- 814
			if ____cond171 then -- 814
				cnode.blendFunc = v -- 815
				return true -- 815
			end -- 815
			____cond171 = ____cond171 or ____switch171 == "effect" -- 815
			if ____cond171 then -- 815
				cnode.effect = v -- 816
				return true -- 816
			end -- 816
			____cond171 = ____cond171 or ____switch171 == "filter" -- 816
			if ____cond171 then -- 816
				cnode.filter = v -- 817
				return true -- 817
			end -- 817
		until true -- 817
		return false -- 819
	end -- 811
	getTileNode = function(enode) -- 821
		local tn = enode.props -- 822
		local ____tn_layers_12 -- 823
		if tn.layers then -- 823
			____tn_layers_12 = Dora.TileNode(tn.file, tn.layers) -- 823
		else -- 823
			____tn_layers_12 = Dora.TileNode(tn.file) -- 823
		end -- 823
		local node = ____tn_layers_12 -- 823
		if node ~= nil then -- 823
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 825
			return cnode -- 826
		end -- 826
		return nil -- 828
	end -- 821
end -- 821
local function addChild(nodeStack, cnode, enode) -- 832
	if #nodeStack > 0 then -- 832
		local last = nodeStack[#nodeStack] -- 834
		last:addChild(cnode) -- 835
	end -- 835
	nodeStack[#nodeStack + 1] = cnode -- 837
	local ____enode_13 = enode -- 838
	local children = ____enode_13.children -- 838
	for i = 1, #children do -- 838
		visitNode(nodeStack, children[i], enode) -- 840
	end -- 840
	if #nodeStack > 1 then -- 840
		table.remove(nodeStack) -- 843
	end -- 843
end -- 832
local function drawNodeCheck(_nodeStack, enode, parent) -- 851
	if parent == nil or parent.type ~= "draw-node" then -- 851
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 853
	end -- 853
end -- 851
local function actionCheck(nodeStack, enode, parent) -- 914
	local unsupported = false -- 915
	if parent == nil then -- 915
		unsupported = true -- 917
	else -- 917
		repeat -- 917
			local ____switch196 = parent.type -- 917
			local ____cond196 = ____switch196 == "action" or ____switch196 == "spawn" or ____switch196 == "sequence" -- 917
			if ____cond196 then -- 917
				break -- 920
			end -- 920
			do -- 920
				unsupported = true -- 921
				break -- 921
			end -- 921
		until true -- 921
	end -- 921
	if unsupported then -- 921
		if #nodeStack > 0 then -- 921
			local node = nodeStack[#nodeStack] -- 926
			local actionStack = {} -- 927
			visitAction(actionStack, enode) -- 928
			if #actionStack == 1 then -- 928
				node:runAction(actionStack[1]) -- 930
			end -- 930
		else -- 930
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 933
		end -- 933
	end -- 933
end -- 914
local function bodyCheck(_nodeStack, enode, parent) -- 938
	if parent == nil or parent.type ~= "body" then -- 938
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 940
	end -- 940
end -- 938
actionMap = { -- 944
	["anchor-x"] = Dora.AnchorX, -- 947
	["anchor-y"] = Dora.AnchorY, -- 948
	angle = Dora.Angle, -- 949
	["angle-x"] = Dora.AngleX, -- 950
	["angle-y"] = Dora.AngleY, -- 951
	width = Dora.Width, -- 952
	height = Dora.Height, -- 953
	opacity = Dora.Opacity, -- 954
	roll = Dora.Roll, -- 955
	scale = Dora.Scale, -- 956
	["scale-x"] = Dora.ScaleX, -- 957
	["scale-y"] = Dora.ScaleY, -- 958
	["skew-x"] = Dora.SkewX, -- 959
	["skew-y"] = Dora.SkewY, -- 960
	["move-x"] = Dora.X, -- 961
	["move-y"] = Dora.Y, -- 962
	["move-z"] = Dora.Z -- 963
} -- 963
elementMap = { -- 966
	node = function(nodeStack, enode, parent) -- 967
		addChild( -- 968
			nodeStack, -- 968
			getNode(enode), -- 968
			enode -- 968
		) -- 968
	end, -- 967
	["clip-node"] = function(nodeStack, enode, parent) -- 970
		addChild( -- 971
			nodeStack, -- 971
			getClipNode(enode), -- 971
			enode -- 971
		) -- 971
	end, -- 970
	playable = function(nodeStack, enode, parent) -- 973
		local cnode = getPlayable(enode) -- 974
		if cnode ~= nil then -- 974
			addChild(nodeStack, cnode, enode) -- 976
		end -- 976
	end, -- 973
	["dragon-bone"] = function(nodeStack, enode, parent) -- 979
		local cnode = getDragonBone(enode) -- 980
		if cnode ~= nil then -- 980
			addChild(nodeStack, cnode, enode) -- 982
		end -- 982
	end, -- 979
	spine = function(nodeStack, enode, parent) -- 985
		local cnode = getSpine(enode) -- 986
		if cnode ~= nil then -- 986
			addChild(nodeStack, cnode, enode) -- 988
		end -- 988
	end, -- 985
	model = function(nodeStack, enode, parent) -- 991
		local cnode = getModel(enode) -- 992
		if cnode ~= nil then -- 992
			addChild(nodeStack, cnode, enode) -- 994
		end -- 994
	end, -- 991
	["draw-node"] = function(nodeStack, enode, parent) -- 997
		addChild( -- 998
			nodeStack, -- 998
			getDrawNode(enode), -- 998
			enode -- 998
		) -- 998
	end, -- 997
	["dot-shape"] = drawNodeCheck, -- 1000
	["segment-shape"] = drawNodeCheck, -- 1001
	["rect-shape"] = drawNodeCheck, -- 1002
	["polygon-shape"] = drawNodeCheck, -- 1003
	["verts-shape"] = drawNodeCheck, -- 1004
	grid = function(nodeStack, enode, parent) -- 1005
		addChild( -- 1006
			nodeStack, -- 1006
			getGrid(enode), -- 1006
			enode -- 1006
		) -- 1006
	end, -- 1005
	sprite = function(nodeStack, enode, parent) -- 1008
		local cnode = getSprite(enode) -- 1009
		if cnode ~= nil then -- 1009
			addChild(nodeStack, cnode, enode) -- 1011
		end -- 1011
	end, -- 1008
	["audio-source"] = function(nodeStack, enode, parent) -- 1014
		local cnode = getAudioSource(enode) -- 1015
		if cnode ~= nil then -- 1015
			addChild(nodeStack, cnode, enode) -- 1017
		end -- 1017
	end, -- 1014
	["video-node"] = function(nodeStack, enode, parent) -- 1020
		local cnode = getVideoNode(enode) -- 1021
		if cnode ~= nil then -- 1021
			addChild(nodeStack, cnode, enode) -- 1023
		end -- 1023
	end, -- 1020
	["tic80-node"] = function(nodeStack, enode, parent) -- 1026
		local cnode = getTIC80Node(enode) -- 1027
		if cnode ~= nil then -- 1027
			addChild(nodeStack, cnode, enode) -- 1029
		end -- 1029
	end, -- 1026
	label = function(nodeStack, enode, parent) -- 1032
		local cnode = getLabel(enode) -- 1033
		if cnode ~= nil then -- 1033
			addChild(nodeStack, cnode, enode) -- 1035
		end -- 1035
	end, -- 1032
	line = function(nodeStack, enode, parent) -- 1038
		addChild( -- 1039
			nodeStack, -- 1039
			getLine(enode), -- 1039
			enode -- 1039
		) -- 1039
	end, -- 1038
	particle = function(nodeStack, enode, parent) -- 1041
		local cnode = getParticle(enode) -- 1042
		if cnode ~= nil then -- 1042
			addChild(nodeStack, cnode, enode) -- 1044
		end -- 1044
	end, -- 1041
	menu = function(nodeStack, enode, parent) -- 1047
		addChild( -- 1048
			nodeStack, -- 1048
			getMenu(enode), -- 1048
			enode -- 1048
		) -- 1048
	end, -- 1047
	action = function(_nodeStack, enode, parent) -- 1050
		if #enode.children == 0 then -- 1050
			Warn("<action> tag has no children") -- 1052
			return -- 1053
		end -- 1053
		local action = enode.props -- 1055
		if action.ref == nil then -- 1055
			Warn("<action> tag has no ref") -- 1057
			return -- 1058
		end -- 1058
		local actionStack = {} -- 1060
		for i = 1, #enode.children do -- 1060
			visitAction(actionStack, enode.children[i]) -- 1062
		end -- 1062
		if #actionStack == 1 then -- 1062
			action.ref.current = actionStack[1] -- 1065
		elseif #actionStack > 1 then -- 1065
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1067
		end -- 1067
	end, -- 1050
	["anchor-x"] = actionCheck, -- 1070
	["anchor-y"] = actionCheck, -- 1071
	angle = actionCheck, -- 1072
	["angle-x"] = actionCheck, -- 1073
	["angle-y"] = actionCheck, -- 1074
	delay = actionCheck, -- 1075
	event = actionCheck, -- 1076
	width = actionCheck, -- 1077
	height = actionCheck, -- 1078
	hide = actionCheck, -- 1079
	show = actionCheck, -- 1080
	move = actionCheck, -- 1081
	opacity = actionCheck, -- 1082
	roll = actionCheck, -- 1083
	scale = actionCheck, -- 1084
	["scale-x"] = actionCheck, -- 1085
	["scale-y"] = actionCheck, -- 1086
	["skew-x"] = actionCheck, -- 1087
	["skew-y"] = actionCheck, -- 1088
	["move-x"] = actionCheck, -- 1089
	["move-y"] = actionCheck, -- 1090
	["move-z"] = actionCheck, -- 1091
	frame = actionCheck, -- 1092
	spawn = actionCheck, -- 1093
	sequence = actionCheck, -- 1094
	loop = function(nodeStack, enode, _parent) -- 1095
		if #nodeStack > 0 then -- 1095
			local node = nodeStack[#nodeStack] -- 1097
			local actionStack = {} -- 1098
			for i = 1, #enode.children do -- 1098
				visitAction(actionStack, enode.children[i]) -- 1100
			end -- 1100
			if #actionStack == 1 then -- 1100
				node:runAction(actionStack[1], true) -- 1103
			else -- 1103
				local loop = enode.props -- 1105
				if loop.spawn then -- 1105
					node:runAction( -- 1107
						Dora.Spawn(table.unpack(actionStack)), -- 1107
						true -- 1107
					) -- 1107
				else -- 1107
					node:runAction( -- 1109
						Dora.Sequence(table.unpack(actionStack)), -- 1109
						true -- 1109
					) -- 1109
				end -- 1109
			end -- 1109
		else -- 1109
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1113
		end -- 1113
	end, -- 1095
	["physics-world"] = function(nodeStack, enode, _parent) -- 1116
		addChild( -- 1117
			nodeStack, -- 1117
			getPhysicsWorld(enode), -- 1117
			enode -- 1117
		) -- 1117
	end, -- 1116
	contact = function(nodeStack, enode, _parent) -- 1119
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1120
		if world ~= nil then -- 1120
			local contact = enode.props -- 1122
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1123
		else -- 1123
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1125
		end -- 1125
	end, -- 1119
	body = function(nodeStack, enode, _parent) -- 1128
		local def = enode.props -- 1129
		if def.world then -- 1129
			addChild( -- 1131
				nodeStack, -- 1131
				getBody(enode, def.world), -- 1131
				enode -- 1131
			) -- 1131
			return -- 1132
		end -- 1132
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1134
		if world ~= nil then -- 1134
			addChild( -- 1136
				nodeStack, -- 1136
				getBody(enode, world), -- 1136
				enode -- 1136
			) -- 1136
		else -- 1136
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1138
		end -- 1138
	end, -- 1128
	["rect-fixture"] = bodyCheck, -- 1141
	["polygon-fixture"] = bodyCheck, -- 1142
	["multi-fixture"] = bodyCheck, -- 1143
	["disk-fixture"] = bodyCheck, -- 1144
	["chain-fixture"] = bodyCheck, -- 1145
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1146
		local joint = enode.props -- 1147
		if joint.ref == nil then -- 1147
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1149
			return -- 1150
		end -- 1150
		if joint.bodyA.current == nil then -- 1150
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1153
			return -- 1154
		end -- 1154
		if joint.bodyB.current == nil then -- 1154
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1157
			return -- 1158
		end -- 1158
		local ____joint_ref_17 = joint.ref -- 1160
		local ____self_15 = Dora.Joint -- 1160
		local ____self_15_distance_16 = ____self_15.distance -- 1160
		local ____joint_canCollide_14 = joint.canCollide -- 1161
		if ____joint_canCollide_14 == nil then -- 1161
			____joint_canCollide_14 = false -- 1161
		end -- 1161
		____joint_ref_17.current = ____self_15_distance_16( -- 1160
			____self_15, -- 1160
			____joint_canCollide_14, -- 1161
			joint.bodyA.current, -- 1162
			joint.bodyB.current, -- 1163
			joint.anchorA or Dora.Vec2.zero, -- 1164
			joint.anchorB or Dora.Vec2.zero, -- 1165
			joint.frequency or 0, -- 1166
			joint.damping or 0 -- 1167
		) -- 1167
	end, -- 1146
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1169
		local joint = enode.props -- 1170
		if joint.ref == nil then -- 1170
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1172
			return -- 1173
		end -- 1173
		if joint.bodyA.current == nil then -- 1173
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1176
			return -- 1177
		end -- 1177
		if joint.bodyB.current == nil then -- 1177
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1180
			return -- 1181
		end -- 1181
		local ____joint_ref_21 = joint.ref -- 1183
		local ____self_19 = Dora.Joint -- 1183
		local ____self_19_friction_20 = ____self_19.friction -- 1183
		local ____joint_canCollide_18 = joint.canCollide -- 1184
		if ____joint_canCollide_18 == nil then -- 1184
			____joint_canCollide_18 = false -- 1184
		end -- 1184
		____joint_ref_21.current = ____self_19_friction_20( -- 1183
			____self_19, -- 1183
			____joint_canCollide_18, -- 1184
			joint.bodyA.current, -- 1185
			joint.bodyB.current, -- 1186
			joint.worldPos, -- 1187
			joint.maxForce, -- 1188
			joint.maxTorque -- 1189
		) -- 1189
	end, -- 1169
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1192
		local joint = enode.props -- 1193
		if joint.ref == nil then -- 1193
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1195
			return -- 1196
		end -- 1196
		if joint.jointA.current == nil then -- 1196
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1199
			return -- 1200
		end -- 1200
		if joint.jointB.current == nil then -- 1200
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1203
			return -- 1204
		end -- 1204
		local ____joint_ref_25 = joint.ref -- 1206
		local ____self_23 = Dora.Joint -- 1206
		local ____self_23_gear_24 = ____self_23.gear -- 1206
		local ____joint_canCollide_22 = joint.canCollide -- 1207
		if ____joint_canCollide_22 == nil then -- 1207
			____joint_canCollide_22 = false -- 1207
		end -- 1207
		____joint_ref_25.current = ____self_23_gear_24( -- 1206
			____self_23, -- 1206
			____joint_canCollide_22, -- 1207
			joint.jointA.current, -- 1208
			joint.jointB.current, -- 1209
			joint.ratio or 1 -- 1210
		) -- 1210
	end, -- 1192
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1213
		local joint = enode.props -- 1214
		if joint.ref == nil then -- 1214
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1216
			return -- 1217
		end -- 1217
		if joint.bodyA.current == nil then -- 1217
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1220
			return -- 1221
		end -- 1221
		if joint.bodyB.current == nil then -- 1221
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1224
			return -- 1225
		end -- 1225
		local ____joint_ref_29 = joint.ref -- 1227
		local ____self_27 = Dora.Joint -- 1227
		local ____self_27_spring_28 = ____self_27.spring -- 1227
		local ____joint_canCollide_26 = joint.canCollide -- 1228
		if ____joint_canCollide_26 == nil then -- 1228
			____joint_canCollide_26 = false -- 1228
		end -- 1228
		____joint_ref_29.current = ____self_27_spring_28( -- 1227
			____self_27, -- 1227
			____joint_canCollide_26, -- 1228
			joint.bodyA.current, -- 1229
			joint.bodyB.current, -- 1230
			joint.linearOffset, -- 1231
			joint.angularOffset, -- 1232
			joint.maxForce, -- 1233
			joint.maxTorque, -- 1234
			joint.correctionFactor or 1 -- 1235
		) -- 1235
	end, -- 1213
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1238
		local joint = enode.props -- 1239
		if joint.ref == nil then -- 1239
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1241
			return -- 1242
		end -- 1242
		if joint.body.current == nil then -- 1242
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1245
			return -- 1246
		end -- 1246
		local ____joint_ref_33 = joint.ref -- 1248
		local ____self_31 = Dora.Joint -- 1248
		local ____self_31_move_32 = ____self_31.move -- 1248
		local ____joint_canCollide_30 = joint.canCollide -- 1249
		if ____joint_canCollide_30 == nil then -- 1249
			____joint_canCollide_30 = false -- 1249
		end -- 1249
		____joint_ref_33.current = ____self_31_move_32( -- 1248
			____self_31, -- 1248
			____joint_canCollide_30, -- 1249
			joint.body.current, -- 1250
			joint.targetPos, -- 1251
			joint.maxForce, -- 1252
			joint.frequency, -- 1253
			joint.damping or 0.7 -- 1254
		) -- 1254
	end, -- 1238
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1257
		local joint = enode.props -- 1258
		if joint.ref == nil then -- 1258
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1260
			return -- 1261
		end -- 1261
		if joint.bodyA.current == nil then -- 1261
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1264
			return -- 1265
		end -- 1265
		if joint.bodyB.current == nil then -- 1265
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1268
			return -- 1269
		end -- 1269
		local ____joint_ref_37 = joint.ref -- 1271
		local ____self_35 = Dora.Joint -- 1271
		local ____self_35_prismatic_36 = ____self_35.prismatic -- 1271
		local ____joint_canCollide_34 = joint.canCollide -- 1272
		if ____joint_canCollide_34 == nil then -- 1272
			____joint_canCollide_34 = false -- 1272
		end -- 1272
		____joint_ref_37.current = ____self_35_prismatic_36( -- 1271
			____self_35, -- 1271
			____joint_canCollide_34, -- 1272
			joint.bodyA.current, -- 1273
			joint.bodyB.current, -- 1274
			joint.worldPos, -- 1275
			joint.axisAngle, -- 1276
			joint.lowerTranslation or 0, -- 1277
			joint.upperTranslation or 0, -- 1278
			joint.maxMotorForce or 0, -- 1279
			joint.motorSpeed or 0 -- 1280
		) -- 1280
	end, -- 1257
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1283
		local joint = enode.props -- 1284
		if joint.ref == nil then -- 1284
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1286
			return -- 1287
		end -- 1287
		if joint.bodyA.current == nil then -- 1287
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1290
			return -- 1291
		end -- 1291
		if joint.bodyB.current == nil then -- 1291
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1294
			return -- 1295
		end -- 1295
		local ____joint_ref_41 = joint.ref -- 1297
		local ____self_39 = Dora.Joint -- 1297
		local ____self_39_pulley_40 = ____self_39.pulley -- 1297
		local ____joint_canCollide_38 = joint.canCollide -- 1298
		if ____joint_canCollide_38 == nil then -- 1298
			____joint_canCollide_38 = false -- 1298
		end -- 1298
		____joint_ref_41.current = ____self_39_pulley_40( -- 1297
			____self_39, -- 1297
			____joint_canCollide_38, -- 1298
			joint.bodyA.current, -- 1299
			joint.bodyB.current, -- 1300
			joint.anchorA or Dora.Vec2.zero, -- 1301
			joint.anchorB or Dora.Vec2.zero, -- 1302
			joint.groundAnchorA, -- 1303
			joint.groundAnchorB, -- 1304
			joint.ratio or 1 -- 1305
		) -- 1305
	end, -- 1283
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1308
		local joint = enode.props -- 1309
		if joint.ref == nil then -- 1309
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1311
			return -- 1312
		end -- 1312
		if joint.bodyA.current == nil then -- 1312
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1315
			return -- 1316
		end -- 1316
		if joint.bodyB.current == nil then -- 1316
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1319
			return -- 1320
		end -- 1320
		local ____joint_ref_45 = joint.ref -- 1322
		local ____self_43 = Dora.Joint -- 1322
		local ____self_43_revolute_44 = ____self_43.revolute -- 1322
		local ____joint_canCollide_42 = joint.canCollide -- 1323
		if ____joint_canCollide_42 == nil then -- 1323
			____joint_canCollide_42 = false -- 1323
		end -- 1323
		____joint_ref_45.current = ____self_43_revolute_44( -- 1322
			____self_43, -- 1322
			____joint_canCollide_42, -- 1323
			joint.bodyA.current, -- 1324
			joint.bodyB.current, -- 1325
			joint.worldPos, -- 1326
			joint.lowerAngle or 0, -- 1327
			joint.upperAngle or 0, -- 1328
			joint.maxMotorTorque or 0, -- 1329
			joint.motorSpeed or 0 -- 1330
		) -- 1330
	end, -- 1308
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1333
		local joint = enode.props -- 1334
		if joint.ref == nil then -- 1334
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1336
			return -- 1337
		end -- 1337
		if joint.bodyA.current == nil then -- 1337
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1340
			return -- 1341
		end -- 1341
		if joint.bodyB.current == nil then -- 1341
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1344
			return -- 1345
		end -- 1345
		local ____joint_ref_49 = joint.ref -- 1347
		local ____self_47 = Dora.Joint -- 1347
		local ____self_47_rope_48 = ____self_47.rope -- 1347
		local ____joint_canCollide_46 = joint.canCollide -- 1348
		if ____joint_canCollide_46 == nil then -- 1348
			____joint_canCollide_46 = false -- 1348
		end -- 1348
		____joint_ref_49.current = ____self_47_rope_48( -- 1347
			____self_47, -- 1347
			____joint_canCollide_46, -- 1348
			joint.bodyA.current, -- 1349
			joint.bodyB.current, -- 1350
			joint.anchorA or Dora.Vec2.zero, -- 1351
			joint.anchorB or Dora.Vec2.zero, -- 1352
			joint.maxLength or 0 -- 1353
		) -- 1353
	end, -- 1333
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1356
		local joint = enode.props -- 1357
		if joint.ref == nil then -- 1357
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1359
			return -- 1360
		end -- 1360
		if joint.bodyA.current == nil then -- 1360
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1363
			return -- 1364
		end -- 1364
		if joint.bodyB.current == nil then -- 1364
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1367
			return -- 1368
		end -- 1368
		local ____joint_ref_53 = joint.ref -- 1370
		local ____self_51 = Dora.Joint -- 1370
		local ____self_51_weld_52 = ____self_51.weld -- 1370
		local ____joint_canCollide_50 = joint.canCollide -- 1371
		if ____joint_canCollide_50 == nil then -- 1371
			____joint_canCollide_50 = false -- 1371
		end -- 1371
		____joint_ref_53.current = ____self_51_weld_52( -- 1370
			____self_51, -- 1370
			____joint_canCollide_50, -- 1371
			joint.bodyA.current, -- 1372
			joint.bodyB.current, -- 1373
			joint.worldPos, -- 1374
			joint.frequency or 0, -- 1375
			joint.damping or 0 -- 1376
		) -- 1376
	end, -- 1356
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1379
		local joint = enode.props -- 1380
		if joint.ref == nil then -- 1380
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1382
			return -- 1383
		end -- 1383
		if joint.bodyA.current == nil then -- 1383
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1386
			return -- 1387
		end -- 1387
		if joint.bodyB.current == nil then -- 1387
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1390
			return -- 1391
		end -- 1391
		local ____joint_ref_57 = joint.ref -- 1393
		local ____self_55 = Dora.Joint -- 1393
		local ____self_55_wheel_56 = ____self_55.wheel -- 1393
		local ____joint_canCollide_54 = joint.canCollide -- 1394
		if ____joint_canCollide_54 == nil then -- 1394
			____joint_canCollide_54 = false -- 1394
		end -- 1394
		____joint_ref_57.current = ____self_55_wheel_56( -- 1393
			____self_55, -- 1393
			____joint_canCollide_54, -- 1394
			joint.bodyA.current, -- 1395
			joint.bodyB.current, -- 1396
			joint.worldPos, -- 1397
			joint.axisAngle, -- 1398
			joint.maxMotorTorque or 0, -- 1399
			joint.motorSpeed or 0, -- 1400
			joint.frequency or 0, -- 1401
			joint.damping or 0.7 -- 1402
		) -- 1402
	end, -- 1379
	["custom-node"] = function(nodeStack, enode, _parent) -- 1405
		local node = getCustomNode(enode) -- 1406
		if node ~= nil then -- 1406
			addChild(nodeStack, node, enode) -- 1408
		end -- 1408
	end, -- 1405
	["custom-element"] = function() -- 1411
	end, -- 1411
	["align-node"] = function(nodeStack, enode, _parent) -- 1412
		addChild( -- 1413
			nodeStack, -- 1413
			getAlignNode(enode), -- 1413
			enode -- 1413
		) -- 1413
	end, -- 1412
	["effek-node"] = function(nodeStack, enode, _parent) -- 1415
		addChild( -- 1416
			nodeStack, -- 1416
			getEffekNode(enode), -- 1416
			enode -- 1416
		) -- 1416
	end, -- 1415
	effek = function(nodeStack, enode, parent) -- 1418
		if #nodeStack > 0 then -- 1418
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1420
			if node then -- 1420
				local effek = enode.props -- 1422
				local handle = node:play( -- 1423
					effek.file, -- 1423
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1423
					effek.z or 0 -- 1423
				) -- 1423
				if handle >= 0 then -- 1423
					if effek.ref then -- 1423
						effek.ref.current = handle -- 1426
					end -- 1426
					if effek.onEnd then -- 1426
						local onEnd = effek.onEnd -- 1426
						node:slot( -- 1430
							"EffekEnd", -- 1430
							function(h) -- 1430
								if handle == h then -- 1430
									onEnd(nil) -- 1432
								end -- 1432
							end -- 1430
						) -- 1430
					end -- 1430
				end -- 1430
			else -- 1430
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1438
			end -- 1438
		end -- 1438
	end, -- 1418
	["tile-node"] = function(nodeStack, enode, parent) -- 1442
		local cnode = getTileNode(enode) -- 1443
		if cnode ~= nil then -- 1443
			addChild(nodeStack, cnode, enode) -- 1445
		end -- 1445
	end -- 1442
} -- 1442
local roots = {} -- 1498
local renderQueued = false -- 1499
local queuedRoots = {} -- 1500
local trackingRoot -- 1501
local function isElementList(node) -- 1503
	return node.type == nil -- 1504
end -- 1503
local function getRenderableElement(renderable) -- 1512
	if type(renderable) == "function" then -- 1512
		return renderable() -- 1514
	end -- 1514
	return renderable -- 1516
end -- 1512
local function removeRoot(root) -- 1757
	for i = 1, #roots do -- 1757
		if roots[i] == root then -- 1757
			table.remove(roots, i) -- 1760
			break -- 1761
		end -- 1761
	end -- 1761
end -- 1757
local function toElementList(node) -- 2283
	if isElementList(node) then -- 2283
		return node -- 2285
	end -- 2285
	return {node} -- 2287
end -- 2283
local function scheduleRootRender(root) -- 2290
	if not root.active then -- 2290
		return -- 2291
	end -- 2291
	for i = 1, #queuedRoots do -- 2291
		if queuedRoots[i] == root then -- 2291
			return -- 2293
		end -- 2293
	end -- 2293
	queuedRoots[#queuedRoots + 1] = root -- 2295
	if renderQueued then -- 2295
		return -- 2296
	end -- 2296
	renderQueued = true -- 2297
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 2298
		renderQueued = false -- 2299
		local updatingRoots = queuedRoots -- 2300
		queuedRoots = {} -- 2301
		for i = 1, #updatingRoots do -- 2301
			updatingRoots[i]:update() -- 2303
		end -- 2303
	end)) -- 2298
end -- 2290
____exports.Root = __TS__Class() -- 2308
local Root = ____exports.Root -- 2308
Root.name = "Root" -- 2308
function Root.prototype.____constructor(self, parent) -- 2314
	self.parent = parent -- 2314
	self.mounted = {} -- 2309
	self.signals = {} -- 2311
	self.active = true -- 2312
end -- 2314
function Root.prototype.render(self, enode) -- 2316
	if not self.active then -- 2316
		roots[#roots + 1] = self -- 2318
		self.active = true -- 2319
	end -- 2319
	self.renderable = enode -- 2321
	self:update() -- 2322
end -- 2316
function Root.prototype.update(self) -- 2325
	if not self.active or self.renderable == nil then -- 2325
		return -- 2326
	end -- 2326
	self:unsubscribeSignals() -- 2327
	local lastTrackingRoot = trackingRoot -- 2328
	trackingRoot = self -- 2329
	local elements -- 2330
	do -- 2330
		local ____try, ____error = pcall(function() -- 2330
			elements = getRenderableElement(self.renderable) -- 2332
		end) -- 2332
		do -- 2332
			trackingRoot = lastTrackingRoot -- 2334
		end -- 2334
		if not ____try then -- 2334
			error(____error, 0) -- 2334
		end -- 2334
	end -- 2334
	self.mounted = reconcileChildren( -- 2336
		self.parent, -- 2336
		self.mounted, -- 2336
		toElementList(elements) -- 2336
	) -- 2336
end -- 2325
function Root.prototype.unmount(self) -- 2339
	for i = 1, #self.mounted do -- 2339
		unmountElement(self.mounted[i]) -- 2341
	end -- 2341
	self.mounted = {} -- 2343
	self.renderable = nil -- 2344
	self:unsubscribeSignals() -- 2345
	if self.active then -- 2345
		removeRoot(self) -- 2347
		self.active = false -- 2348
	end -- 2348
end -- 2339
function Root.prototype.trackSignal(self, signal) -- 2352
	for i = 1, #self.signals do -- 2352
		if self.signals[i] == signal then -- 2352
			return -- 2354
		end -- 2354
	end -- 2354
	local ____self_signals_68 = self.signals -- 2354
	____self_signals_68[#____self_signals_68 + 1] = signal -- 2356
	signal:addRoot(self) -- 2357
end -- 2352
function Root.prototype.unsubscribeSignals(self) -- 2360
	for i = 1, #self.signals do -- 2360
		self.signals[i]:removeRoot(self) -- 2362
	end -- 2362
	self.signals = {} -- 2364
end -- 2360
function ____exports.createRoot(parent) -- 2368
	local root = __TS__New(____exports.Root, parent) -- 2369
	roots[#roots + 1] = root -- 2370
	return root -- 2371
end -- 2368
____exports.Signal = __TS__Class() -- 2374
local Signal = ____exports.Signal -- 2374
Signal.name = "Signal" -- 2374
function Signal.prototype.____constructor(self, item) -- 2377
	self.item = item -- 2377
	self.roots = {} -- 2375
end -- 2377
function Signal.prototype.addRoot(self, root) -- 2394
	for i = 1, #self.roots do -- 2394
		if self.roots[i] == root then -- 2394
			return -- 2396
		end -- 2396
	end -- 2396
	local ____self_roots_69 = self.roots -- 2396
	____self_roots_69[#____self_roots_69 + 1] = root -- 2398
end -- 2394
function Signal.prototype.removeRoot(self, root) -- 2401
	for i = 1, #self.roots do -- 2401
		if self.roots[i] == root then -- 2401
			table.remove(self.roots, i) -- 2404
			break -- 2405
		end -- 2405
	end -- 2405
end -- 2401
__TS__SetDescriptor( -- 2401
	Signal.prototype, -- 2401
	"value", -- 2401
	{ -- 2401
		get = function(self) -- 2401
			if trackingRoot ~= nil then -- 2401
				trackingRoot:trackSignal(self) -- 2381
			end -- 2381
			return self.item -- 2383
		end, -- 2383
		set = function(self, value) -- 2383
			if self.item == value then -- 2383
				return -- 2387
			end -- 2387
			self.item = value -- 2388
			for i = 1, #self.roots do -- 2388
				scheduleRootRender(self.roots[i]) -- 2390
			end -- 2390
		end -- 2390
	}, -- 2390
	true -- 2390
) -- 2390
function ____exports.signal(value) -- 2411
	return __TS__New(____exports.Signal, value) -- 2412
end -- 2411
function ____exports.useRef(item) -- 2415
	local ____item_70 = item -- 2416
	if ____item_70 == nil then -- 2416
		____item_70 = nil -- 2416
	end -- 2416
	return {current = ____item_70} -- 2416
end -- 2415
local function getPreload(preloadList, node) -- 2419
	if type(node) ~= "table" then -- 2419
		return -- 2421
	end -- 2421
	local enode = node -- 2423
	if enode.type == nil then -- 2423
		local list = node -- 2425
		if #list > 0 then -- 2425
			for i = 1, #list do -- 2425
				getPreload(preloadList, list[i]) -- 2428
			end -- 2428
		end -- 2428
	else -- 2428
		repeat -- 2428
			local ____switch580 = enode.type -- 2428
			local sprite, playable, frame, model, spine, dragonBone, label -- 2428
			local ____cond580 = ____switch580 == "sprite" -- 2428
			if ____cond580 then -- 2428
				sprite = enode.props -- 2434
				if sprite.file then -- 2434
					preloadList[#preloadList + 1] = sprite.file -- 2436
				end -- 2436
				break -- 2438
			end -- 2438
			____cond580 = ____cond580 or ____switch580 == "playable" -- 2438
			if ____cond580 then -- 2438
				playable = enode.props -- 2440
				preloadList[#preloadList + 1] = playable.file -- 2441
				break -- 2442
			end -- 2442
			____cond580 = ____cond580 or ____switch580 == "frame" -- 2442
			if ____cond580 then -- 2442
				frame = enode.props -- 2444
				preloadList[#preloadList + 1] = frame.file -- 2445
				break -- 2446
			end -- 2446
			____cond580 = ____cond580 or ____switch580 == "model" -- 2446
			if ____cond580 then -- 2446
				model = enode.props -- 2448
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2449
				break -- 2450
			end -- 2450
			____cond580 = ____cond580 or ____switch580 == "spine" -- 2450
			if ____cond580 then -- 2450
				spine = enode.props -- 2452
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2453
				break -- 2454
			end -- 2454
			____cond580 = ____cond580 or ____switch580 == "dragon-bone" -- 2454
			if ____cond580 then -- 2454
				dragonBone = enode.props -- 2456
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2457
				break -- 2458
			end -- 2458
			____cond580 = ____cond580 or ____switch580 == "label" -- 2458
			if ____cond580 then -- 2458
				label = enode.props -- 2460
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2461
				break -- 2462
			end -- 2462
		until true -- 2462
	end -- 2462
	getPreload(preloadList, enode.children) -- 2465
end -- 2419
function ____exports.preloadAsync(enode, handler) -- 2468
	local preloadList = {} -- 2469
	getPreload(preloadList, enode) -- 2470
	Dora.Cache:loadAsync(preloadList, handler) -- 2471
end -- 2468
function ____exports.toAction(enode) -- 2474
	local actionDef = ____exports.useRef() -- 2475
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2476
	if not actionDef.current then -- 2476
		error("failed to create action") -- 2477
	end -- 2477
	return actionDef.current -- 2478
end -- 2474
return ____exports -- 2474