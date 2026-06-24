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
local Warn, visitNode, getElementKey, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, shallowPropsEqual, collectContactElements, getContactKey, patchPhysicsWorldInputs, structuralChildrenEqual, toHostElement, createHostNode, getElementChildren, shouldRecreate, isEventProp, applyProp, patchProps, addChildToParent, mountElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap -- 1
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
	Dora.Log("Warn", "[Dora Warning] " .. msg) -- 14
end -- 14
function visitNode(nodeStack, node, parent) -- 1461
	if type(node) ~= "table" then -- 1461
		return -- 1463
	end -- 1463
	local enode = node -- 1465
	if enode.type == nil then -- 1465
		local list = node -- 1467
		if #list > 0 then -- 1467
			for i = 1, #list do -- 1467
				local stack = {} -- 1470
				visitNode(stack, list[i], parent) -- 1471
				for i = 1, #stack do -- 1471
					nodeStack[#nodeStack + 1] = stack[i] -- 1473
				end -- 1473
			end -- 1473
		end -- 1473
	else -- 1473
		local handler = elementMap[enode.type] -- 1478
		if handler ~= nil then -- 1478
			handler(nodeStack, enode, parent) -- 1480
		else -- 1480
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1482
		end -- 1482
	end -- 1482
end -- 1482
function ____exports.toNode(enode) -- 1487
	local nodeStack = {} -- 1488
	visitNode(nodeStack, enode) -- 1489
	if #nodeStack == 1 then -- 1489
		return nodeStack[1] -- 1491
	elseif #nodeStack > 1 then -- 1491
		local node = Dora.Node() -- 1493
		for i = 1, #nodeStack do -- 1493
			node:addChild(nodeStack[i]) -- 1495
		end -- 1495
		return node -- 1497
	end -- 1497
	return nil -- 1499
end -- 1487
function getElementKey(element) -- 1519
	local props = element.props -- 1520
	local ____props_58 -- 1521
	if props then -- 1521
		____props_58 = props.key -- 1521
	else -- 1521
		____props_58 = nil -- 1521
	end -- 1521
	return ____props_58 -- 1521
end -- 1521
function getPrimitiveLabelText(enode) -- 1531
	local label = enode.props -- 1532
	local text = label.text or "" -- 1533
	for i = 1, #enode.children do -- 1533
		local child = enode.children[i] -- 1535
		if type(child) ~= "table" then -- 1535
			text = text .. tostring(child) -- 1537
		end -- 1537
	end -- 1537
	return text -- 1540
end -- 1540
function isDrawShapeElement(element) -- 1543
	repeat -- 1543
		local ____switch335 = element.type -- 1543
		local ____cond335 = ____switch335 == "dot-shape" or ____switch335 == "segment-shape" or ____switch335 == "rect-shape" or ____switch335 == "polygon-shape" or ____switch335 == "verts-shape" -- 1543
		if ____cond335 then -- 1543
			return true -- 1550
		end -- 1550
	until true -- 1550
	return false -- 1552
end -- 1552
function isBodyFixtureElement(element) -- 1555
	repeat -- 1555
		local ____switch337 = element.type -- 1555
		local ____cond337 = ____switch337 == "rect-fixture" or ____switch337 == "polygon-fixture" or ____switch337 == "multi-fixture" or ____switch337 == "disk-fixture" or ____switch337 == "chain-fixture" -- 1555
		if ____cond337 then -- 1555
			return true -- 1562
		end -- 1562
	until true -- 1562
	return false -- 1564
end -- 1564
function isPhysicsWorldInputElement(element) -- 1567
	return element.type == "contact" -- 1568
end -- 1568
function shallowPropsEqual(oldProps, newProps) -- 1571
	for k, v in pairs(oldProps) do -- 1572
		if k ~= "ref" and newProps[k] ~= v then -- 1572
			return false -- 1573
		end -- 1573
	end -- 1573
	for k, v in pairs(newProps) do -- 1575
		if k ~= "ref" and oldProps[k] ~= v then -- 1575
			return false -- 1576
		end -- 1576
	end -- 1576
	return true -- 1578
end -- 1578
function collectContactElements(element) -- 1581
	local contacts = {} -- 1582
	for i = 1, #element.children do -- 1582
		local child = element.children[i] -- 1584
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1584
			contacts[#contacts + 1] = child -- 1586
		end -- 1586
	end -- 1586
	return contacts -- 1589
end -- 1589
function getContactKey(contact) -- 1592
	return (tostring(contact.groupA) .. ":") .. tostring(contact.groupB) -- 1593
end -- 1593
function patchPhysicsWorldInputs(world, oldElement, newElement) -- 1596
	local oldContacts = collectContactElements(oldElement) -- 1597
	local newContacts = collectContactElements(newElement) -- 1598
	local oldByKey = {} -- 1599
	local newByKey = {} -- 1600
	for i = 1, #oldContacts do -- 1600
		local contact = oldContacts[i].props -- 1602
		oldByKey[getContactKey(contact)] = contact -- 1603
	end -- 1603
	for i = 1, #newContacts do -- 1603
		local contact = newContacts[i].props -- 1606
		newByKey[getContactKey(contact)] = contact -- 1607
	end -- 1607
	for i = 1, #oldContacts do -- 1607
		local oldContact = oldContacts[i].props -- 1610
		local key = getContactKey(oldContact) -- 1611
		local newContact = newByKey[key] -- 1612
		if newContact == nil then -- 1612
			world:setShouldContact(oldContact.groupA, oldContact.groupB, true) -- 1614
		elseif oldContact.enabled ~= newContact.enabled then -- 1614
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1616
		end -- 1616
	end -- 1616
	for i = 1, #newContacts do -- 1616
		local newContact = newContacts[i].props -- 1620
		if oldByKey[getContactKey(newContact)] == nil then -- 1620
			world:setShouldContact(newContact.groupA, newContact.groupB, newContact.enabled) -- 1622
		end -- 1622
	end -- 1622
end -- 1622
function structuralChildrenEqual(oldElement, newElement, check) -- 1627
	local oldChildren = {} -- 1633
	local newChildren = {} -- 1634
	for i = 1, #oldElement.children do -- 1634
		local child = oldElement.children[i] -- 1636
		if type(child) == "table" and check(child) then -- 1636
			oldChildren[#oldChildren + 1] = child -- 1638
		end -- 1638
	end -- 1638
	for i = 1, #newElement.children do -- 1638
		local child = newElement.children[i] -- 1642
		if type(child) == "table" and check(child) then -- 1642
			newChildren[#newChildren + 1] = child -- 1644
		end -- 1644
	end -- 1644
	if #oldChildren ~= #newChildren then -- 1644
		return false -- 1647
	end -- 1647
	for i = 1, #oldChildren do -- 1647
		local oldChild = oldChildren[i] -- 1649
		local newChild = newChildren[i] -- 1650
		if oldChild.type ~= newChild.type then -- 1650
			return false -- 1651
		end -- 1651
		if not shallowPropsEqual(oldChild.props, newChild.props) then -- 1651
			return false -- 1652
		end -- 1652
	end -- 1652
	return true -- 1654
end -- 1654
function toHostElement(enode, parent) -- 1666
	local hostChildren = {} -- 1667
	local props = {} -- 1668
	if enode.props ~= nil then -- 1668
		for k, v in pairs(enode.props) do -- 1670
			props[k] = v -- 1671
		end -- 1671
	end -- 1671
	if enode.type == "label" then -- 1671
		for i = 1, #enode.children do -- 1671
			local child = enode.children[i] -- 1676
			if type(child) ~= "table" then -- 1676
				hostChildren[#hostChildren + 1] = child -- 1678
			end -- 1678
		end -- 1678
	elseif enode.type == "draw-node" then -- 1678
		for i = 1, #enode.children do -- 1678
			local child = enode.children[i] -- 1683
			if type(child) == "table" and isDrawShapeElement(child) then -- 1683
				hostChildren[#hostChildren + 1] = child -- 1685
			end -- 1685
		end -- 1685
	elseif enode.type == "body" then -- 1685
		for i = 1, #enode.children do -- 1685
			local child = enode.children[i] -- 1690
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1690
				hostChildren[#hostChildren + 1] = child -- 1692
			end -- 1692
		end -- 1692
	elseif enode.type == "physics-world" then -- 1692
		for i = 1, #enode.children do -- 1692
			local child = enode.children[i] -- 1697
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1697
				hostChildren[#hostChildren + 1] = child -- 1699
			end -- 1699
		end -- 1699
	end -- 1699
	if enode.type == "body" and props.world == nil then -- 1699
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1704
		if world ~= nil then -- 1704
			props.world = world -- 1706
		end -- 1706
	end -- 1706
	return {type = enode.type, props = props, children = hostChildren} -- 1709
end -- 1709
function createHostNode(enode, parent) -- 1716
	local nodeStack = {} -- 1717
	visitNode( -- 1718
		nodeStack, -- 1718
		toHostElement(enode, parent) -- 1718
	) -- 1718
	if #nodeStack == 1 then -- 1718
		return nodeStack[1] -- 1720
	elseif #nodeStack > 1 then -- 1720
		local node = Dora.Node() -- 1722
		for i = 1, #nodeStack do -- 1722
			node:addChild(nodeStack[i]) -- 1724
		end -- 1724
		return node -- 1726
	end -- 1726
	return nil -- 1728
end -- 1728
function getElementChildren(enode) -- 1731
	local children = {} -- 1732
	if enode.type == "draw-node" or enode.type == "body" then -- 1732
		return children -- 1733
	end -- 1733
	for i = 1, #enode.children do -- 1733
		local child = enode.children[i] -- 1735
		if type(child) == "table" then -- 1735
			local childElement = child -- 1737
			if childElement.type ~= nil then -- 1737
				if enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement) then -- 1737
					children[#children + 1] = childElement -- 1740
				end -- 1740
			else -- 1740
				local list = child -- 1743
				for j = 1, #list do -- 1743
					local item = list[j] -- 1745
					if type(item) == "table" and item.type ~= nil then -- 1745
						if enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item) then -- 1745
							children[#children + 1] = item -- 1748
						end -- 1748
					end -- 1748
				end -- 1748
			end -- 1748
		end -- 1748
	end -- 1748
	return children -- 1755
end -- 1755
function shouldRecreate(oldElement, newElement) -- 1758
	if oldElement.type ~= newElement.type then -- 1758
		return true -- 1759
	end -- 1759
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1759
		return true -- 1760
	end -- 1760
	local oldProps = oldElement.props -- 1761
	local newProps = newElement.props -- 1762
	if newElement.type == "draw-node" then -- 1762
		return true -- 1763
	end -- 1763
	for k, v in pairs(oldProps) do -- 1764
		if (isEventProp(k) or k == "onMount") and newProps[k] ~= v then -- 1764
			return true -- 1766
		end -- 1766
	end -- 1766
	for k, v in pairs(newProps) do -- 1769
		if (isEventProp(k) or k == "onMount") and oldProps[k] ~= v then -- 1769
			return true -- 1771
		end -- 1771
	end -- 1771
	repeat -- 1771
		local ____switch407 = newElement.type -- 1771
		local ____cond407 = ____switch407 == "grid" -- 1771
		if ____cond407 then -- 1771
			return oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY -- 1776
		end -- 1776
		____cond407 = ____cond407 or (____switch407 == "sprite" or ____switch407 == "video-node" or ____switch407 == "tic80-node" or ____switch407 == "audio-source" or ____switch407 == "particle" or ____switch407 == "tile-node" or ____switch407 == "playable" or ____switch407 == "dragon-bone" or ____switch407 == "spine" or ____switch407 == "model") -- 1776
		if ____cond407 then -- 1776
			return oldProps.file ~= newProps.file -- 1787
		end -- 1787
		____cond407 = ____cond407 or ____switch407 == "label" -- 1787
		if ____cond407 then -- 1787
			return oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf -- 1789
		end -- 1789
		____cond407 = ____cond407 or ____switch407 == "align-node" -- 1789
		if ____cond407 then -- 1789
			return oldProps.windowRoot ~= newProps.windowRoot -- 1791
		end -- 1791
		____cond407 = ____cond407 or ____switch407 == "custom-node" -- 1791
		if ____cond407 then -- 1791
			return oldProps.onCreate ~= newProps.onCreate -- 1793
		end -- 1793
		____cond407 = ____cond407 or ____switch407 == "body" -- 1793
		if ____cond407 then -- 1793
			return oldProps.type ~= newProps.type or oldProps.world ~= newProps.world or oldProps.fixedRotation ~= newProps.fixedRotation or oldProps.bullet ~= newProps.bullet or oldProps.linearAcceleration ~= newProps.linearAcceleration or not structuralChildrenEqual(oldElement, newElement, isBodyFixtureElement) -- 1795
		end -- 1795
	until true -- 1795
	return false -- 1802
end -- 1802
function isEventProp(key) -- 1805
	return type(key) == "string" and key ~= "onUnmount" and string.sub(key, 1, 2) == "on" -- 1806
end -- 1806
function applyProp(node, enode, key, value) -- 1809
	local name = key -- 1810
	repeat -- 1810
		local ____switch410 = name -- 1810
		local ____cond410 = ____switch410 == "key" or ____switch410 == "children" or ____switch410 == "onMount" or ____switch410 == "onUnmount" -- 1810
		if ____cond410 then -- 1810
			return -- 1816
		end -- 1816
		____cond410 = ____cond410 or ____switch410 == "ref" -- 1816
		if ____cond410 then -- 1816
			value.current = node -- 1818
			return -- 1819
		end -- 1819
		____cond410 = ____cond410 or ____switch410 == "anchorX" -- 1819
		if ____cond410 then -- 1819
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 1821
			return -- 1822
		end -- 1822
		____cond410 = ____cond410 or ____switch410 == "anchorY" -- 1822
		if ____cond410 then -- 1822
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 1824
			return -- 1825
		end -- 1825
		____cond410 = ____cond410 or ____switch410 == "color3" -- 1825
		if ____cond410 then -- 1825
			node.color3 = Dora.Color3(value) -- 1827
			return -- 1828
		end -- 1828
		____cond410 = ____cond410 or ____switch410 == "transformTarget" -- 1828
		if ____cond410 then -- 1828
			node.transformTarget = value.current -- 1830
			return -- 1831
		end -- 1831
		____cond410 = ____cond410 or ____switch410 == "outlineColor" -- 1831
		if ____cond410 then -- 1831
			node[name] = Dora.Color(value) -- 1833
			return -- 1834
		end -- 1834
		____cond410 = ____cond410 or ____switch410 == "smoothLower" -- 1834
		if ____cond410 then -- 1834
			do -- 1834
				local smooth = node.smooth -- 1836
				node.smooth = Dora.Vec2(value, smooth.y) -- 1837
				return -- 1838
			end -- 1838
		end -- 1838
		____cond410 = ____cond410 or ____switch410 == "smoothUpper" -- 1838
		if ____cond410 then -- 1838
			do -- 1838
				local smooth = node.smooth -- 1841
				node.smooth = Dora.Vec2(smooth.x, value) -- 1842
				return -- 1843
			end -- 1843
		end -- 1843
	until true -- 1843
	if isEventProp(key) then -- 1843
		return -- 1847
	end -- 1847
	node[name] = value -- 1849
end -- 1849
function patchProps(node, oldElement, newElement) -- 1852
	local oldProps = oldElement.props -- 1853
	local newProps = newElement.props -- 1854
	for k in pairs(oldProps) do -- 1855
		if k ~= "ref" and k ~= "key" and not isEventProp(k) and newProps[k] == nil then -- 1855
			node[k] = nil -- 1857
		end -- 1857
	end -- 1857
	for k, v in pairs(newProps) do -- 1860
		if oldProps[k] ~= v then -- 1860
			applyProp(node, newElement, k, v) -- 1862
		end -- 1862
	end -- 1862
	if newElement.type == "label" then -- 1862
		node.text = getPrimitiveLabelText(newElement) -- 1866
	elseif newElement.type == "physics-world" then -- 1866
		local world = Dora.tolua.cast(node, "PhysicsWorld") -- 1868
		if world ~= nil then -- 1868
			patchPhysicsWorldInputs(world, oldElement, newElement) -- 1870
		end -- 1870
	end -- 1870
end -- 1870
function addChildToParent(parent, node, props) -- 1875
	if props.tag ~= nil then -- 1875
		parent:addChild(node, props.order or 0, props.tag) -- 1877
	elseif props.order ~= nil then -- 1877
		parent:addChild(node, props.order) -- 1879
	else -- 1879
		parent:addChild(node) -- 1881
	end -- 1881
end -- 1881
function mountElement(parent, enode) -- 1885
	local node = createHostNode(enode, parent) -- 1886
	if node == nil then -- 1886
		return nil -- 1888
	end -- 1888
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 1888
		return nil -- 1897
	end -- 1897
	local props = enode.props -- 1899
	addChildToParent(parent, node, props) -- 1900
	local mounted = {element = enode, node = node, children = {}} -- 1901
	mounted.children = reconcileChildren( -- 1902
		node, -- 1902
		{}, -- 1902
		getElementChildren(enode) -- 1902
	) -- 1902
	return mounted -- 1903
end -- 1903
function unmountElement(mounted) -- 1906
	for i = 1, #mounted.children do -- 1906
		unmountElement(mounted.children[i]) -- 1908
	end -- 1908
	local props = mounted.element.props -- 1910
	if props.onUnmount ~= nil then -- 1910
		props.onUnmount(mounted.node) -- 1912
	end -- 1912
	mounted.node:removeFromParent(true) -- 1914
end -- 1914
function reconcileElement(parent, oldMounted, newElement) -- 1917
	if oldMounted == nil then -- 1917
		return mountElement(parent, newElement) -- 1919
	end -- 1919
	if shouldRecreate(oldMounted.element, newElement) then -- 1919
		local oldNode = oldMounted.node -- 1922
		local oldOrder = oldNode.order -- 1923
		local oldTag = oldNode.tag -- 1924
		unmountElement(oldMounted) -- 1925
		local mounted = mountElement(parent, newElement) -- 1926
		if mounted ~= nil then -- 1926
			mounted.node.order = newElement.props.order or oldOrder -- 1928
			mounted.node.tag = newElement.props.tag or oldTag -- 1929
		end -- 1929
		return mounted -- 1931
	end -- 1931
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 1933
	oldMounted.children = reconcileChildren( -- 1934
		oldMounted.node, -- 1934
		oldMounted.children, -- 1934
		getElementChildren(newElement) -- 1934
	) -- 1934
	oldMounted.element = newElement -- 1935
	return oldMounted -- 1936
end -- 1936
function reconcileChildren(parent, oldChildren, newElements) -- 1939
	local oldByKey = {} -- 1940
	local usedOld = {} -- 1941
	for i = 1, #oldChildren do -- 1941
		local oldChild = oldChildren[i] -- 1943
		local key = getElementKey(oldChild.element) -- 1944
		if key ~= nil then -- 1944
			oldByKey[key] = oldChild -- 1946
		end -- 1946
	end -- 1946
	local nextChildren = {} -- 1949
	for i = 1, #newElements do -- 1949
		local newElement = newElements[i] -- 1951
		local key = getElementKey(newElement) -- 1952
		local oldChild -- 1953
		if key ~= nil then -- 1953
			oldChild = oldByKey[key] -- 1955
		else -- 1955
			oldChild = oldChildren[i] -- 1957
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 1957
				oldChild = nil -- 1959
			end -- 1959
		end -- 1959
		local mounted = reconcileElement(parent, oldChild, newElement) -- 1962
		if mounted ~= nil then -- 1962
			usedOld[mounted] = true -- 1964
			nextChildren[#nextChildren + 1] = mounted -- 1965
			local props = newElement.props -- 1966
			mounted.node.order = props.order or i -- 1967
			if props.tag ~= nil then -- 1967
				mounted.node.tag = props.tag -- 1968
			end -- 1968
		end -- 1968
	end -- 1968
	for i = 1, #oldChildren do -- 1968
		local oldChild = oldChildren[i] -- 1972
		if not usedOld[oldChild] then -- 1972
			unmountElement(oldChild) -- 1974
		end -- 1974
	end -- 1974
	return nextChildren -- 1977
end -- 1977
____exports.React = {} -- 1977
local React = ____exports.React -- 1977
do -- 1977
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
local function getNode(enode, cnode, attribHandler) -- 129
	cnode = cnode or Dora.Node() -- 130
	local jnode = enode.props -- 131
	local anchor -- 132
	local color3 -- 133
	for k, v in pairs(enode.props) do -- 134
		repeat -- 134
			local ____switch32 = k -- 134
			local ____cond32 = ____switch32 == "ref" -- 134
			if ____cond32 then -- 134
				v.current = cnode -- 136
				break -- 136
			end -- 136
			____cond32 = ____cond32 or ____switch32 == "anchorX" -- 136
			if ____cond32 then -- 136
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 137
				break -- 137
			end -- 137
			____cond32 = ____cond32 or ____switch32 == "anchorY" -- 137
			if ____cond32 then -- 137
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 138
				break -- 138
			end -- 138
			____cond32 = ____cond32 or ____switch32 == "color3" -- 138
			if ____cond32 then -- 138
				color3 = Dora.Color3(v) -- 139
				break -- 139
			end -- 139
			____cond32 = ____cond32 or ____switch32 == "transformTarget" -- 139
			if ____cond32 then -- 139
				cnode.transformTarget = v.current -- 140
				break -- 140
			end -- 140
			____cond32 = ____cond32 or ____switch32 == "onUpdate" -- 140
			if ____cond32 then -- 140
				cnode:schedule(v) -- 141
				break -- 141
			end -- 141
			____cond32 = ____cond32 or ____switch32 == "onActionEnd" -- 141
			if ____cond32 then -- 141
				cnode:slot("ActionEnd", v) -- 142
				break -- 142
			end -- 142
			____cond32 = ____cond32 or ____switch32 == "onTapFilter" -- 142
			if ____cond32 then -- 142
				cnode:slot("TapFilter", v) -- 143
				break -- 143
			end -- 143
			____cond32 = ____cond32 or ____switch32 == "onTapBegan" -- 143
			if ____cond32 then -- 143
				cnode:slot("TapBegan", v) -- 144
				break -- 144
			end -- 144
			____cond32 = ____cond32 or ____switch32 == "onTapEnded" -- 144
			if ____cond32 then -- 144
				cnode:slot("TapEnded", v) -- 145
				break -- 145
			end -- 145
			____cond32 = ____cond32 or ____switch32 == "onTapped" -- 145
			if ____cond32 then -- 145
				cnode:slot("Tapped", v) -- 146
				break -- 146
			end -- 146
			____cond32 = ____cond32 or ____switch32 == "onTapMoved" -- 146
			if ____cond32 then -- 146
				cnode:slot("TapMoved", v) -- 147
				break -- 147
			end -- 147
			____cond32 = ____cond32 or ____switch32 == "onMouseWheel" -- 147
			if ____cond32 then -- 147
				cnode:slot("MouseWheel", v) -- 148
				break -- 148
			end -- 148
			____cond32 = ____cond32 or ____switch32 == "onGesture" -- 148
			if ____cond32 then -- 148
				cnode:slot("Gesture", v) -- 149
				break -- 149
			end -- 149
			____cond32 = ____cond32 or ____switch32 == "onEnter" -- 149
			if ____cond32 then -- 149
				cnode:slot("Enter", v) -- 150
				break -- 150
			end -- 150
			____cond32 = ____cond32 or ____switch32 == "onExit" -- 150
			if ____cond32 then -- 150
				cnode:slot("Exit", v) -- 151
				break -- 151
			end -- 151
			____cond32 = ____cond32 or ____switch32 == "onCleanup" -- 151
			if ____cond32 then -- 151
				cnode:slot("Cleanup", v) -- 152
				break -- 152
			end -- 152
			____cond32 = ____cond32 or ____switch32 == "onUnmount" -- 152
			if ____cond32 then -- 152
				break -- 153
			end -- 153
			____cond32 = ____cond32 or ____switch32 == "onKeyDown" -- 153
			if ____cond32 then -- 153
				cnode:slot("KeyDown", v) -- 154
				break -- 154
			end -- 154
			____cond32 = ____cond32 or ____switch32 == "onKeyUp" -- 154
			if ____cond32 then -- 154
				cnode:slot("KeyUp", v) -- 155
				break -- 155
			end -- 155
			____cond32 = ____cond32 or ____switch32 == "onKeyPressed" -- 155
			if ____cond32 then -- 155
				cnode:slot("KeyPressed", v) -- 156
				break -- 156
			end -- 156
			____cond32 = ____cond32 or ____switch32 == "onAttachIME" -- 156
			if ____cond32 then -- 156
				cnode:slot("AttachIME", v) -- 157
				break -- 157
			end -- 157
			____cond32 = ____cond32 or ____switch32 == "onDetachIME" -- 157
			if ____cond32 then -- 157
				cnode:slot("DetachIME", v) -- 158
				break -- 158
			end -- 158
			____cond32 = ____cond32 or ____switch32 == "onTextInput" -- 158
			if ____cond32 then -- 158
				cnode:slot("TextInput", v) -- 159
				break -- 159
			end -- 159
			____cond32 = ____cond32 or ____switch32 == "onTextEditing" -- 159
			if ____cond32 then -- 159
				cnode:slot("TextEditing", v) -- 160
				break -- 160
			end -- 160
			____cond32 = ____cond32 or ____switch32 == "onButtonDown" -- 160
			if ____cond32 then -- 160
				cnode:slot("ButtonDown", v) -- 161
				break -- 161
			end -- 161
			____cond32 = ____cond32 or ____switch32 == "onButtonUp" -- 161
			if ____cond32 then -- 161
				cnode:slot("ButtonUp", v) -- 162
				break -- 162
			end -- 162
			____cond32 = ____cond32 or ____switch32 == "onAxis" -- 162
			if ____cond32 then -- 162
				cnode:slot("Axis", v) -- 163
				break -- 163
			end -- 163
			do -- 163
				do -- 163
					if attribHandler then -- 163
						if not attribHandler(cnode, enode, k, v) then -- 163
							cnode[k] = v -- 167
						end -- 167
					else -- 167
						cnode[k] = v -- 170
					end -- 170
					break -- 172
				end -- 172
			end -- 172
		until true -- 172
	end -- 172
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 172
		cnode.touchEnabled = true -- 185
	end -- 185
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 185
		cnode.keyboardEnabled = true -- 192
	end -- 192
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 192
		cnode.controllerEnabled = true -- 199
	end -- 199
	if anchor ~= nil then -- 199
		cnode.anchor = anchor -- 201
	end -- 201
	if color3 ~= nil then -- 201
		cnode.color3 = color3 -- 202
	end -- 202
	if jnode.onMount ~= nil then -- 202
		jnode.onMount(cnode) -- 204
	end -- 204
	return cnode -- 206
end -- 129
local getClipNode -- 209
do -- 209
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 211
		repeat -- 211
			local ____switch45 = k -- 211
			local ____cond45 = ____switch45 == "stencil" -- 211
			if ____cond45 then -- 211
				cnode.stencil = ____exports.toNode(v) -- 218
				return true -- 218
			end -- 218
		until true -- 218
		return false -- 220
	end -- 211
	getClipNode = function(enode) -- 222
		return getNode( -- 223
			enode, -- 223
			Dora.ClipNode(), -- 223
			handleClipNodeAttribute -- 223
		) -- 223
	end -- 222
end -- 222
local getPlayable -- 227
local getDragonBone -- 228
local getSpine -- 229
local getModel -- 230
do -- 230
	local function handlePlayableAttribute(cnode, enode, k, v) -- 232
		repeat -- 232
			local ____switch49 = k -- 232
			local ____cond49 = ____switch49 == "file" -- 232
			if ____cond49 then -- 232
				return true -- 234
			end -- 234
			____cond49 = ____cond49 or ____switch49 == "play" -- 234
			if ____cond49 then -- 234
				cnode:play(v, enode.props.loop == true) -- 235
				return true -- 235
			end -- 235
			____cond49 = ____cond49 or ____switch49 == "loop" -- 235
			if ____cond49 then -- 235
				return true -- 236
			end -- 236
			____cond49 = ____cond49 or ____switch49 == "onAnimationEnd" -- 236
			if ____cond49 then -- 236
				cnode:slot("AnimationEnd", v) -- 237
				return true -- 237
			end -- 237
		until true -- 237
		return false -- 239
	end -- 232
	getPlayable = function(enode, cnode, attribHandler) -- 241
		if attribHandler == nil then -- 241
			attribHandler = handlePlayableAttribute -- 242
		end -- 242
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 243
		if cnode ~= nil then -- 243
			return getNode(enode, cnode, attribHandler) -- 245
		end -- 245
		return nil -- 247
	end -- 241
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 250
		repeat -- 250
			local ____switch53 = k -- 250
			local ____cond53 = ____switch53 == "hitTestEnabled" -- 250
			if ____cond53 then -- 250
				cnode.hitTestEnabled = true -- 252
				return true -- 252
			end -- 252
		until true -- 252
		return handlePlayableAttribute(cnode, enode, k, v) -- 254
	end -- 250
	getDragonBone = function(enode) -- 256
		local node = Dora.DragonBone(enode.props.file) -- 257
		if node ~= nil then -- 257
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 259
			return cnode -- 260
		end -- 260
		return nil -- 262
	end -- 256
	local function handleSpineAttribute(cnode, enode, k, v) -- 265
		repeat -- 265
			local ____switch57 = k -- 265
			local ____cond57 = ____switch57 == "hitTestEnabled" -- 265
			if ____cond57 then -- 265
				cnode.hitTestEnabled = true -- 267
				return true -- 267
			end -- 267
		until true -- 267
		return handlePlayableAttribute(cnode, enode, k, v) -- 269
	end -- 265
	getSpine = function(enode) -- 271
		local node = Dora.Spine(enode.props.file) -- 272
		if node ~= nil then -- 272
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 274
			return cnode -- 275
		end -- 275
		return nil -- 277
	end -- 271
	local function handleModelAttribute(cnode, enode, k, v) -- 280
		repeat -- 280
			local ____switch61 = k -- 280
			local ____cond61 = ____switch61 == "reversed" -- 280
			if ____cond61 then -- 280
				cnode.reversed = v -- 282
				return true -- 282
			end -- 282
		until true -- 282
		return handlePlayableAttribute(cnode, enode, k, v) -- 284
	end -- 280
	getModel = function(enode) -- 286
		local node = Dora.Model(enode.props.file) -- 287
		if node ~= nil then -- 287
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 289
			return cnode -- 290
		end -- 290
		return nil -- 292
	end -- 286
end -- 286
local getDrawNode -- 296
do -- 296
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 298
		repeat -- 298
			local ____switch66 = k -- 298
			local ____cond66 = ____switch66 == "depthWrite" -- 298
			if ____cond66 then -- 298
				cnode.depthWrite = v -- 300
				return true -- 300
			end -- 300
			____cond66 = ____cond66 or ____switch66 == "blendFunc" -- 300
			if ____cond66 then -- 300
				cnode.blendFunc = v -- 301
				return true -- 301
			end -- 301
		until true -- 301
		return false -- 303
	end -- 298
	getDrawNode = function(enode) -- 305
		local node = Dora.DrawNode() -- 306
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 307
		local ____enode_5 = enode -- 308
		local children = ____enode_5.children -- 308
		for i = 1, #children do -- 308
			do -- 308
				local child = children[i] -- 310
				if type(child) ~= "table" then -- 310
					goto __continue68 -- 312
				end -- 312
				repeat -- 312
					local ____switch70 = child.type -- 312
					local ____cond70 = ____switch70 == "dot-shape" -- 312
					if ____cond70 then -- 312
						do -- 312
							local dot = child.props -- 316
							node:drawDot( -- 317
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 318
								dot.radius, -- 319
								Dora.Color(dot.color or 4294967295) -- 320
							) -- 320
							break -- 322
						end -- 322
					end -- 322
					____cond70 = ____cond70 or ____switch70 == "segment-shape" -- 322
					if ____cond70 then -- 322
						do -- 322
							local segment = child.props -- 325
							node:drawSegment( -- 326
								Dora.Vec2(segment.startX, segment.startY), -- 327
								Dora.Vec2(segment.stopX, segment.stopY), -- 328
								segment.radius, -- 329
								Dora.Color(segment.color or 4294967295) -- 330
							) -- 330
							break -- 332
						end -- 332
					end -- 332
					____cond70 = ____cond70 or ____switch70 == "rect-shape" -- 332
					if ____cond70 then -- 332
						do -- 332
							local rect = child.props -- 335
							local centerX = rect.centerX or 0 -- 336
							local centerY = rect.centerY or 0 -- 337
							local hw = rect.width / 2 -- 338
							local hh = rect.height / 2 -- 339
							node:drawPolygon( -- 340
								{ -- 341
									Dora.Vec2(centerX - hw, centerY + hh), -- 342
									Dora.Vec2(centerX + hw, centerY + hh), -- 343
									Dora.Vec2(centerX + hw, centerY - hh), -- 344
									Dora.Vec2(centerX - hw, centerY - hh) -- 345
								}, -- 345
								Dora.Color(rect.fillColor or 4294967295), -- 347
								rect.borderWidth or 0, -- 348
								Dora.Color(rect.borderColor or 4294967295) -- 349
							) -- 349
							break -- 351
						end -- 351
					end -- 351
					____cond70 = ____cond70 or ____switch70 == "polygon-shape" -- 351
					if ____cond70 then -- 351
						do -- 351
							local poly = child.props -- 354
							node:drawPolygon( -- 355
								poly.verts, -- 356
								Dora.Color(poly.fillColor or 4294967295), -- 357
								poly.borderWidth or 0, -- 358
								Dora.Color(poly.borderColor or 4294967295) -- 359
							) -- 359
							break -- 361
						end -- 361
					end -- 361
					____cond70 = ____cond70 or ____switch70 == "verts-shape" -- 361
					if ____cond70 then -- 361
						do -- 361
							local verts = child.props -- 364
							node:drawVertices(__TS__ArrayMap( -- 365
								verts.verts, -- 365
								function(____, ____bindingPattern0) -- 365
									local color -- 365
									local vert -- 365
									vert = ____bindingPattern0[1] -- 365
									color = ____bindingPattern0[2] -- 365
									return { -- 365
										vert, -- 365
										Dora.Color(color) -- 365
									} -- 365
								end -- 365
							)) -- 365
							break -- 366
						end -- 366
					end -- 366
				until true -- 366
			end -- 366
			::__continue68:: -- 366
		end -- 366
		return cnode -- 370
	end -- 305
end -- 305
local getGrid -- 374
do -- 374
	local function handleGridAttribute(cnode, _enode, k, v) -- 376
		repeat -- 376
			local ____switch79 = k -- 376
			local ____cond79 = ____switch79 == "file" or ____switch79 == "gridX" or ____switch79 == "gridY" -- 376
			if ____cond79 then -- 376
				return true -- 378
			end -- 378
			____cond79 = ____cond79 or ____switch79 == "textureRect" -- 378
			if ____cond79 then -- 378
				cnode.textureRect = v -- 379
				return true -- 379
			end -- 379
			____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 379
			if ____cond79 then -- 379
				cnode.depthWrite = v -- 380
				return true -- 380
			end -- 380
			____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 380
			if ____cond79 then -- 380
				cnode.blendFunc = v -- 381
				return true -- 381
			end -- 381
			____cond79 = ____cond79 or ____switch79 == "effect" -- 381
			if ____cond79 then -- 381
				cnode.effect = v -- 382
				return true -- 382
			end -- 382
		until true -- 382
		return false -- 384
	end -- 376
	getGrid = function(enode) -- 386
		local grid = enode.props -- 387
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 388
		local cnode = getNode(enode, node, handleGridAttribute) -- 389
		return cnode -- 390
	end -- 386
end -- 386
local getSprite -- 394
local getVideoNode -- 395
local getTIC80Node -- 396
do -- 396
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 398
		repeat -- 398
			local ____switch83 = k -- 398
			local ____cond83 = ____switch83 == "file" -- 398
			if ____cond83 then -- 398
				return true -- 400
			end -- 400
			____cond83 = ____cond83 or ____switch83 == "textureRect" -- 400
			if ____cond83 then -- 400
				cnode.textureRect = v -- 401
				return true -- 401
			end -- 401
			____cond83 = ____cond83 or ____switch83 == "depthWrite" -- 401
			if ____cond83 then -- 401
				cnode.depthWrite = v -- 402
				return true -- 402
			end -- 402
			____cond83 = ____cond83 or ____switch83 == "blendFunc" -- 402
			if ____cond83 then -- 402
				cnode.blendFunc = v -- 403
				return true -- 403
			end -- 403
			____cond83 = ____cond83 or ____switch83 == "effect" -- 403
			if ____cond83 then -- 403
				cnode.effect = v -- 404
				return true -- 404
			end -- 404
			____cond83 = ____cond83 or ____switch83 == "alphaRef" -- 404
			if ____cond83 then -- 404
				cnode.alphaRef = v -- 405
				return true -- 405
			end -- 405
			____cond83 = ____cond83 or ____switch83 == "uwrap" -- 405
			if ____cond83 then -- 405
				cnode.uwrap = v -- 406
				return true -- 406
			end -- 406
			____cond83 = ____cond83 or ____switch83 == "vwrap" -- 406
			if ____cond83 then -- 406
				cnode.vwrap = v -- 407
				return true -- 407
			end -- 407
			____cond83 = ____cond83 or ____switch83 == "filter" -- 407
			if ____cond83 then -- 407
				cnode.filter = v -- 408
				return true -- 408
			end -- 408
		until true -- 408
		return false -- 410
	end -- 398
	getSprite = function(enode) -- 412
		local sp = enode.props -- 413
		if sp.file then -- 413
			local node = Dora.Sprite(sp.file) -- 415
			if node ~= nil then -- 415
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 417
				return cnode -- 418
			end -- 418
		else -- 418
			local node = Dora.Sprite() -- 421
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 422
			return cnode -- 423
		end -- 423
		return nil -- 425
	end -- 412
	getVideoNode = function(enode) -- 427
		local vn = enode.props -- 428
		local ____Dora_VideoNode_8 = Dora.VideoNode -- 429
		local ____vn_file_7 = vn.file -- 429
		local ____vn_looped_6 = vn.looped -- 429
		if ____vn_looped_6 == nil then -- 429
			____vn_looped_6 = false -- 429
		end -- 429
		local node = ____Dora_VideoNode_8(____vn_file_7, ____vn_looped_6) -- 429
		if node ~= nil then -- 429
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 431
			return cnode -- 432
		end -- 432
		return nil -- 434
	end -- 427
	getTIC80Node = function(enode) -- 436
		local tic = enode.props -- 437
		local node = Dora.TIC80Node(tic.file) -- 438
		if node ~= nil then -- 438
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 440
			return cnode -- 441
		end -- 441
		return nil -- 443
	end -- 436
end -- 436
local getAudioSource -- 447
do -- 447
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 449
		repeat -- 449
			local ____switch94 = k -- 449
			local ____cond94 = ____switch94 == "file" -- 449
			if ____cond94 then -- 449
				return true -- 451
			end -- 451
			____cond94 = ____cond94 or ____switch94 == "autoRemove" -- 451
			if ____cond94 then -- 451
				return true -- 452
			end -- 452
			____cond94 = ____cond94 or ____switch94 == "bus" -- 452
			if ____cond94 then -- 452
				return true -- 453
			end -- 453
			____cond94 = ____cond94 or ____switch94 == "volume" -- 453
			if ____cond94 then -- 453
				cnode.volume = v -- 454
				return true -- 454
			end -- 454
			____cond94 = ____cond94 or ____switch94 == "pan" -- 454
			if ____cond94 then -- 454
				cnode.pan = v -- 455
				return true -- 455
			end -- 455
			____cond94 = ____cond94 or ____switch94 == "looping" -- 455
			if ____cond94 then -- 455
				cnode.looping = v -- 456
				return true -- 456
			end -- 456
			____cond94 = ____cond94 or ____switch94 == "playMode" -- 456
			if ____cond94 then -- 456
				do -- 456
					local aus = enode.props -- 458
					repeat -- 458
						local ____switch96 = v -- 458
						local ____cond96 = ____switch96 == "normal" -- 458
						if ____cond96 then -- 458
							cnode:play(aus.delayTime or 0) -- 460
							break -- 460
						end -- 460
						____cond96 = ____cond96 or ____switch96 == "background" -- 460
						if ____cond96 then -- 460
							cnode:playBackground() -- 461
							break -- 461
						end -- 461
						____cond96 = ____cond96 or ____switch96 == "3D" -- 461
						if ____cond96 then -- 461
							cnode:play3D(aus.delayTime or 0) -- 462
							break -- 462
						end -- 462
					until true -- 462
					return true -- 464
				end -- 464
			end -- 464
			____cond94 = ____cond94 or ____switch94 == "delayTime" -- 464
			if ____cond94 then -- 464
				return true -- 466
			end -- 466
			____cond94 = ____cond94 or ____switch94 == "protected" -- 466
			if ____cond94 then -- 466
				cnode:setProtected(v) -- 467
				return true -- 467
			end -- 467
			____cond94 = ____cond94 or ____switch94 == "loopPoint" -- 467
			if ____cond94 then -- 467
				cnode:setLoopPoint(v) -- 468
				return true -- 468
			end -- 468
			____cond94 = ____cond94 or ____switch94 == "velocity" -- 468
			if ____cond94 then -- 468
				do -- 468
					local vx, vy, vz = table.unpack(v, 1, 3) -- 470
					cnode:setVelocity(vx, vy, vz) -- 471
					return true -- 472
				end -- 472
			end -- 472
			____cond94 = ____cond94 or ____switch94 == "minMaxDistance" -- 472
			if ____cond94 then -- 472
				do -- 472
					local min, max = table.unpack(v, 1, 2) -- 475
					cnode:setMinMaxDistance(min, max) -- 476
					return true -- 477
				end -- 477
			end -- 477
			____cond94 = ____cond94 or ____switch94 == "attenuation" -- 477
			if ____cond94 then -- 477
				do -- 477
					local model, factor = table.unpack(v, 1, 2) -- 480
					cnode:setAttenuation(model, factor) -- 481
					return true -- 482
				end -- 482
			end -- 482
			____cond94 = ____cond94 or ____switch94 == "dopplerFactor" -- 482
			if ____cond94 then -- 482
				cnode:setDopplerFactor(v) -- 484
				return true -- 484
			end -- 484
		until true -- 484
		return false -- 486
	end -- 449
	getAudioSource = function(enode) -- 488
		local aus = enode.props -- 489
		local ____aus_autoRemove_9 = aus.autoRemove -- 490
		if ____aus_autoRemove_9 == nil then -- 490
			____aus_autoRemove_9 = true -- 490
		end -- 490
		local autoRemove = ____aus_autoRemove_9 -- 490
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 491
		if node ~= nil then -- 491
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 493
			return cnode -- 494
		end -- 494
		return nil -- 496
	end -- 488
end -- 488
local getLabel -- 500
do -- 500
	local function handleLabelAttribute(cnode, _enode, k, v) -- 502
		repeat -- 502
			local ____switch104 = k -- 502
			local ____cond104 = ____switch104 == "fontName" or ____switch104 == "fontSize" or ____switch104 == "text" or ____switch104 == "smoothLower" or ____switch104 == "smoothUpper" -- 502
			if ____cond104 then -- 502
				return true -- 504
			end -- 504
			____cond104 = ____cond104 or ____switch104 == "alphaRef" -- 504
			if ____cond104 then -- 504
				cnode.alphaRef = v -- 505
				return true -- 505
			end -- 505
			____cond104 = ____cond104 or ____switch104 == "textWidth" -- 505
			if ____cond104 then -- 505
				cnode.textWidth = v -- 506
				return true -- 506
			end -- 506
			____cond104 = ____cond104 or ____switch104 == "lineGap" -- 506
			if ____cond104 then -- 506
				cnode.lineGap = v -- 507
				return true -- 507
			end -- 507
			____cond104 = ____cond104 or ____switch104 == "spacing" -- 507
			if ____cond104 then -- 507
				cnode.spacing = v -- 508
				return true -- 508
			end -- 508
			____cond104 = ____cond104 or ____switch104 == "outlineColor" -- 508
			if ____cond104 then -- 508
				cnode.outlineColor = Dora.Color(v) -- 509
				return true -- 509
			end -- 509
			____cond104 = ____cond104 or ____switch104 == "outlineWidth" -- 509
			if ____cond104 then -- 509
				cnode.outlineWidth = v -- 510
				return true -- 510
			end -- 510
			____cond104 = ____cond104 or ____switch104 == "blendFunc" -- 510
			if ____cond104 then -- 510
				cnode.blendFunc = v -- 511
				return true -- 511
			end -- 511
			____cond104 = ____cond104 or ____switch104 == "depthWrite" -- 511
			if ____cond104 then -- 511
				cnode.depthWrite = v -- 512
				return true -- 512
			end -- 512
			____cond104 = ____cond104 or ____switch104 == "batched" -- 512
			if ____cond104 then -- 512
				cnode.batched = v -- 513
				return true -- 513
			end -- 513
			____cond104 = ____cond104 or ____switch104 == "effect" -- 513
			if ____cond104 then -- 513
				cnode.effect = v -- 514
				return true -- 514
			end -- 514
			____cond104 = ____cond104 or ____switch104 == "alignment" -- 514
			if ____cond104 then -- 514
				cnode.alignment = v -- 515
				return true -- 515
			end -- 515
		until true -- 515
		return false -- 517
	end -- 502
	getLabel = function(enode) -- 519
		local label = enode.props -- 520
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 521
		if node ~= nil then -- 521
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 521
				local ____node_smooth_10 = node.smooth -- 524
				local x = ____node_smooth_10.x -- 524
				local y = ____node_smooth_10.y -- 524
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 525
			end -- 525
			local cnode = getNode(enode, node, handleLabelAttribute) -- 527
			local ____enode_11 = enode -- 528
			local children = ____enode_11.children -- 528
			local text = label.text or "" -- 529
			for i = 1, #children do -- 529
				local child = children[i] -- 531
				if type(child) ~= "table" then -- 531
					text = text .. tostring(child) -- 533
				end -- 533
			end -- 533
			node.text = text -- 536
			return cnode -- 537
		end -- 537
		return nil -- 539
	end -- 519
end -- 519
local getLine -- 543
do -- 543
	local function handleLineAttribute(cnode, enode, k, v) -- 545
		local line = enode.props -- 546
		repeat -- 546
			local ____switch112 = k -- 546
			local ____cond112 = ____switch112 == "verts" -- 546
			if ____cond112 then -- 546
				cnode:set( -- 548
					v, -- 548
					Dora.Color(line.lineColor or 4294967295) -- 548
				) -- 548
				return true -- 548
			end -- 548
			____cond112 = ____cond112 or ____switch112 == "depthWrite" -- 548
			if ____cond112 then -- 548
				cnode.depthWrite = v -- 549
				return true -- 549
			end -- 549
			____cond112 = ____cond112 or ____switch112 == "blendFunc" -- 549
			if ____cond112 then -- 549
				cnode.blendFunc = v -- 550
				return true -- 550
			end -- 550
		until true -- 550
		return false -- 552
	end -- 545
	getLine = function(enode) -- 554
		local node = Dora.Line() -- 555
		local cnode = getNode(enode, node, handleLineAttribute) -- 556
		return cnode -- 557
	end -- 554
end -- 554
local getParticle -- 561
do -- 561
	local function handleParticleAttribute(cnode, _enode, k, v) -- 563
		repeat -- 563
			local ____switch116 = k -- 563
			local ____cond116 = ____switch116 == "file" -- 563
			if ____cond116 then -- 563
				return true -- 565
			end -- 565
			____cond116 = ____cond116 or ____switch116 == "emit" -- 565
			if ____cond116 then -- 565
				if v then -- 565
					cnode:start() -- 566
				end -- 566
				return true -- 566
			end -- 566
			____cond116 = ____cond116 or ____switch116 == "onFinished" -- 566
			if ____cond116 then -- 566
				cnode:slot("Finished", v) -- 567
				return true -- 567
			end -- 567
		until true -- 567
		return false -- 569
	end -- 563
	getParticle = function(enode) -- 571
		local particle = enode.props -- 572
		local node = Dora.Particle(particle.file) -- 573
		if node ~= nil then -- 573
			local cnode = getNode(enode, node, handleParticleAttribute) -- 575
			return cnode -- 576
		end -- 576
		return nil -- 578
	end -- 571
end -- 571
local getMenu -- 582
do -- 582
	local function handleMenuAttribute(cnode, _enode, k, v) -- 584
		repeat -- 584
			local ____switch122 = k -- 584
			local ____cond122 = ____switch122 == "enabled" -- 584
			if ____cond122 then -- 584
				cnode.enabled = v -- 586
				return true -- 586
			end -- 586
		until true -- 586
		return false -- 588
	end -- 584
	getMenu = function(enode) -- 590
		local node = Dora.Menu() -- 591
		local cnode = getNode(enode, node, handleMenuAttribute) -- 592
		return cnode -- 593
	end -- 590
end -- 590
local function getPhysicsWorld(enode) -- 597
	local node = Dora.PhysicsWorld() -- 598
	local cnode = getNode(enode, node) -- 599
	return cnode -- 600
end -- 597
local getBody -- 603
do -- 603
	local function handleBodyAttribute(cnode, _enode, k, v) -- 605
		repeat -- 605
			local ____switch127 = k -- 605
			local ____cond127 = ____switch127 == "type" or ____switch127 == "linearAcceleration" or ____switch127 == "fixedRotation" or ____switch127 == "bullet" or ____switch127 == "world" -- 605
			if ____cond127 then -- 605
				return true -- 612
			end -- 612
			____cond127 = ____cond127 or ____switch127 == "velocityX" -- 612
			if ____cond127 then -- 612
				cnode.velocityX = v -- 613
				return true -- 613
			end -- 613
			____cond127 = ____cond127 or ____switch127 == "velocityY" -- 613
			if ____cond127 then -- 613
				cnode.velocityY = v -- 614
				return true -- 614
			end -- 614
			____cond127 = ____cond127 or ____switch127 == "angularRate" -- 614
			if ____cond127 then -- 614
				cnode.angularRate = v -- 615
				return true -- 615
			end -- 615
			____cond127 = ____cond127 or ____switch127 == "group" -- 615
			if ____cond127 then -- 615
				cnode.group = v -- 616
				return true -- 616
			end -- 616
			____cond127 = ____cond127 or ____switch127 == "linearDamping" -- 616
			if ____cond127 then -- 616
				cnode.linearDamping = v -- 617
				return true -- 617
			end -- 617
			____cond127 = ____cond127 or ____switch127 == "angularDamping" -- 617
			if ____cond127 then -- 617
				cnode.angularDamping = v -- 618
				return true -- 618
			end -- 618
			____cond127 = ____cond127 or ____switch127 == "owner" -- 618
			if ____cond127 then -- 618
				cnode.owner = v -- 619
				return true -- 619
			end -- 619
			____cond127 = ____cond127 or ____switch127 == "receivingContact" -- 619
			if ____cond127 then -- 619
				cnode.receivingContact = v -- 620
				return true -- 620
			end -- 620
			____cond127 = ____cond127 or ____switch127 == "onBodyEnter" -- 620
			if ____cond127 then -- 620
				cnode:slot("BodyEnter", v) -- 621
				return true -- 621
			end -- 621
			____cond127 = ____cond127 or ____switch127 == "onBodyLeave" -- 621
			if ____cond127 then -- 621
				cnode:slot("BodyLeave", v) -- 622
				return true -- 622
			end -- 622
			____cond127 = ____cond127 or ____switch127 == "onContactStart" -- 622
			if ____cond127 then -- 622
				cnode:slot("ContactStart", v) -- 623
				return true -- 623
			end -- 623
			____cond127 = ____cond127 or ____switch127 == "onContactEnd" -- 623
			if ____cond127 then -- 623
				cnode:slot("ContactEnd", v) -- 624
				return true -- 624
			end -- 624
			____cond127 = ____cond127 or ____switch127 == "onContactFilter" -- 624
			if ____cond127 then -- 624
				cnode:onContactFilter(v) -- 625
				return true -- 625
			end -- 625
		until true -- 625
		return false -- 627
	end -- 605
	getBody = function(enode, world) -- 629
		local def = enode.props -- 630
		local bodyDef = Dora.BodyDef() -- 631
		bodyDef.type = def.type -- 632
		if def.angle ~= nil then -- 632
			bodyDef.angle = def.angle -- 633
		end -- 633
		if def.angularDamping ~= nil then -- 633
			bodyDef.angularDamping = def.angularDamping -- 634
		end -- 634
		if def.bullet ~= nil then -- 634
			bodyDef.bullet = def.bullet -- 635
		end -- 635
		if def.fixedRotation ~= nil then -- 635
			bodyDef.fixedRotation = def.fixedRotation -- 636
		end -- 636
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 637
		if def.linearDamping ~= nil then -- 637
			bodyDef.linearDamping = def.linearDamping -- 638
		end -- 638
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 639
		local extraSensors -- 640
		for i = 1, #enode.children do -- 640
			do -- 640
				local child = enode.children[i] -- 642
				if type(child) ~= "table" then -- 642
					goto __continue134 -- 644
				end -- 644
				repeat -- 644
					local ____switch136 = child.type -- 644
					local ____cond136 = ____switch136 == "rect-fixture" -- 644
					if ____cond136 then -- 644
						do -- 644
							local shape = child.props -- 648
							if shape.sensorTag ~= nil then -- 648
								bodyDef:attachPolygonSensor( -- 650
									shape.sensorTag, -- 651
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 652
									shape.width, -- 653
									shape.height, -- 653
									shape.angle or 0 -- 654
								) -- 654
							else -- 654
								bodyDef:attachPolygon( -- 657
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 658
									shape.width, -- 659
									shape.height, -- 659
									shape.angle or 0, -- 660
									shape.density or 1, -- 661
									shape.friction or 0.4, -- 662
									shape.restitution or 0 -- 663
								) -- 663
							end -- 663
							break -- 666
						end -- 666
					end -- 666
					____cond136 = ____cond136 or ____switch136 == "polygon-fixture" -- 666
					if ____cond136 then -- 666
						do -- 666
							local shape = child.props -- 669
							if shape.sensorTag ~= nil then -- 669
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 671
							else -- 671
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 676
							end -- 676
							break -- 683
						end -- 683
					end -- 683
					____cond136 = ____cond136 or ____switch136 == "multi-fixture" -- 683
					if ____cond136 then -- 683
						do -- 683
							local shape = child.props -- 686
							if shape.sensorTag ~= nil then -- 686
								if extraSensors == nil then -- 686
									extraSensors = {} -- 688
								end -- 688
								extraSensors[#extraSensors + 1] = { -- 689
									shape.sensorTag, -- 689
									Dora.BodyDef:multi(shape.verts) -- 689
								} -- 689
							else -- 689
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 691
							end -- 691
							break -- 698
						end -- 698
					end -- 698
					____cond136 = ____cond136 or ____switch136 == "disk-fixture" -- 698
					if ____cond136 then -- 698
						do -- 698
							local shape = child.props -- 701
							if shape.sensorTag ~= nil then -- 701
								bodyDef:attachDiskSensor( -- 703
									shape.sensorTag, -- 704
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 705
									shape.radius -- 706
								) -- 706
							else -- 706
								bodyDef:attachDisk( -- 709
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 710
									shape.radius, -- 711
									shape.density or 1, -- 712
									shape.friction or 0.4, -- 713
									shape.restitution or 0 -- 714
								) -- 714
							end -- 714
							break -- 717
						end -- 717
					end -- 717
					____cond136 = ____cond136 or ____switch136 == "chain-fixture" -- 717
					if ____cond136 then -- 717
						do -- 717
							local shape = child.props -- 720
							if shape.sensorTag ~= nil then -- 720
								if extraSensors == nil then -- 720
									extraSensors = {} -- 722
								end -- 722
								extraSensors[#extraSensors + 1] = { -- 723
									shape.sensorTag, -- 723
									Dora.BodyDef:chain(shape.verts) -- 723
								} -- 723
							else -- 723
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 725
							end -- 725
							break -- 731
						end -- 731
					end -- 731
				until true -- 731
			end -- 731
			::__continue134:: -- 731
		end -- 731
		local body = Dora.Body(bodyDef, world) -- 735
		if extraSensors ~= nil then -- 735
			for i = 1, #extraSensors do -- 735
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 738
				body:attachSensor(tag, def) -- 739
			end -- 739
		end -- 739
		local cnode = getNode(enode, body, handleBodyAttribute) -- 742
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 742
			body.receivingContact = true -- 747
		end -- 747
		return cnode -- 749
	end -- 629
end -- 629
local getCustomNode -- 753
do -- 753
	local function handleCustomNode(_cnode, _enode, k, _v) -- 755
		repeat -- 755
			local ____switch157 = k -- 755
			local ____cond157 = ____switch157 == "onCreate" -- 755
			if ____cond157 then -- 755
				return true -- 757
			end -- 757
		until true -- 757
		return false -- 759
	end -- 755
	getCustomNode = function(enode) -- 761
		local custom = enode.props -- 762
		local node = custom.onCreate() -- 763
		if node then -- 763
			local cnode = getNode(enode, node, handleCustomNode) -- 765
			return cnode -- 766
		end -- 766
		return nil -- 768
	end -- 761
end -- 761
local getAlignNode -- 772
do -- 772
	local function handleAlignNode(_cnode, _enode, k, _v) -- 774
		repeat -- 774
			local ____switch162 = k -- 774
			local ____cond162 = ____switch162 == "windowRoot" -- 774
			if ____cond162 then -- 774
				return true -- 776
			end -- 776
			____cond162 = ____cond162 or ____switch162 == "style" -- 776
			if ____cond162 then -- 776
				return true -- 777
			end -- 777
			____cond162 = ____cond162 or ____switch162 == "onLayout" -- 777
			if ____cond162 then -- 777
				return true -- 778
			end -- 778
		until true -- 778
		return false -- 780
	end -- 774
	getAlignNode = function(enode) -- 782
		local alignNode = enode.props -- 783
		local node = Dora.AlignNode(alignNode.windowRoot) -- 784
		if alignNode.style then -- 784
			local items = {} -- 786
			for k, v in pairs(alignNode.style) do -- 787
				local name = string.gsub(k, "%u", "-%1") -- 788
				name = string.lower(name) -- 789
				repeat -- 789
					local ____switch166 = k -- 789
					local ____cond166 = ____switch166 == "margin" or ____switch166 == "padding" or ____switch166 == "border" or ____switch166 == "gap" -- 789
					if ____cond166 then -- 789
						do -- 789
							if type(v) == "table" then -- 789
								local valueStr = table.concat( -- 794
									__TS__ArrayMap( -- 794
										v, -- 794
										function(____, item) return tostring(item) end -- 794
									), -- 794
									"," -- 794
								) -- 794
								items[#items + 1] = (name .. ":") .. valueStr -- 795
							else -- 795
								items[#items + 1] = (name .. ":") .. tostring(v) -- 797
							end -- 797
							break -- 799
						end -- 799
					end -- 799
					do -- 799
						items[#items + 1] = (name .. ":") .. tostring(v) -- 802
						break -- 803
					end -- 803
				until true -- 803
			end -- 803
			local styleStr = table.concat(items, ";") -- 806
			node:css(styleStr) -- 807
		end -- 807
		if alignNode.onLayout then -- 807
			node:slot("AlignLayout", alignNode.onLayout) -- 810
		end -- 810
		local cnode = getNode(enode, node, handleAlignNode) -- 812
		return cnode -- 813
	end -- 782
end -- 782
local function getEffekNode(enode) -- 817
	return getNode( -- 818
		enode, -- 818
		Dora.EffekNode() -- 818
	) -- 818
end -- 817
local getTileNode -- 821
do -- 821
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 823
		repeat -- 823
			local ____switch175 = k -- 823
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 823
			if ____cond175 then -- 823
				return true -- 825
			end -- 825
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 825
			if ____cond175 then -- 825
				cnode.depthWrite = v -- 826
				return true -- 826
			end -- 826
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 826
			if ____cond175 then -- 826
				cnode.blendFunc = v -- 827
				return true -- 827
			end -- 827
			____cond175 = ____cond175 or ____switch175 == "effect" -- 827
			if ____cond175 then -- 827
				cnode.effect = v -- 828
				return true -- 828
			end -- 828
			____cond175 = ____cond175 or ____switch175 == "filter" -- 828
			if ____cond175 then -- 828
				cnode.filter = v -- 829
				return true -- 829
			end -- 829
		until true -- 829
		return false -- 831
	end -- 823
	getTileNode = function(enode) -- 833
		local tn = enode.props -- 834
		local ____tn_layers_12 -- 835
		if tn.layers then -- 835
			____tn_layers_12 = Dora.TileNode(tn.file, tn.layers) -- 835
		else -- 835
			____tn_layers_12 = Dora.TileNode(tn.file) -- 835
		end -- 835
		local node = ____tn_layers_12 -- 835
		if node ~= nil then -- 835
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 837
			return cnode -- 838
		end -- 838
		return nil -- 840
	end -- 833
end -- 833
local function addChild(nodeStack, cnode, enode) -- 844
	if #nodeStack > 0 then -- 844
		local last = nodeStack[#nodeStack] -- 846
		last:addChild(cnode) -- 847
	end -- 847
	nodeStack[#nodeStack + 1] = cnode -- 849
	local ____enode_13 = enode -- 850
	local children = ____enode_13.children -- 850
	for i = 1, #children do -- 850
		visitNode(nodeStack, children[i], enode) -- 852
	end -- 852
	if #nodeStack > 1 then -- 852
		table.remove(nodeStack) -- 855
	end -- 855
end -- 844
local function drawNodeCheck(_nodeStack, enode, parent) -- 863
	if parent == nil or parent.type ~= "draw-node" then -- 863
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 865
	end -- 865
end -- 863
local function visitAction(actionStack, enode) -- 869
	local createAction = actionMap[enode.type] -- 870
	if createAction ~= nil then -- 870
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 872
		return -- 873
	end -- 873
	repeat -- 873
		local ____switch186 = enode.type -- 873
		local ____cond186 = ____switch186 == "delay" -- 873
		if ____cond186 then -- 873
			do -- 873
				local item = enode.props -- 877
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 878
				break -- 879
			end -- 879
		end -- 879
		____cond186 = ____cond186 or ____switch186 == "event" -- 879
		if ____cond186 then -- 879
			do -- 879
				local item = enode.props -- 882
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 883
				break -- 884
			end -- 884
		end -- 884
		____cond186 = ____cond186 or ____switch186 == "hide" -- 884
		if ____cond186 then -- 884
			do -- 884
				actionStack[#actionStack + 1] = Dora.Hide() -- 887
				break -- 888
			end -- 888
		end -- 888
		____cond186 = ____cond186 or ____switch186 == "show" -- 888
		if ____cond186 then -- 888
			do -- 888
				actionStack[#actionStack + 1] = Dora.Show() -- 891
				break -- 892
			end -- 892
		end -- 892
		____cond186 = ____cond186 or ____switch186 == "move" -- 892
		if ____cond186 then -- 892
			do -- 892
				local item = enode.props -- 895
				actionStack[#actionStack + 1] = Dora.Move( -- 896
					item.time, -- 896
					Dora.Vec2(item.startX, item.startY), -- 896
					Dora.Vec2(item.stopX, item.stopY), -- 896
					item.easing -- 896
				) -- 896
				break -- 897
			end -- 897
		end -- 897
		____cond186 = ____cond186 or ____switch186 == "frame" -- 897
		if ____cond186 then -- 897
			do -- 897
				local item = enode.props -- 900
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 901
				break -- 902
			end -- 902
		end -- 902
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 902
		if ____cond186 then -- 902
			do -- 902
				local spawnStack = {} -- 905
				for i = 1, #enode.children do -- 905
					visitAction(spawnStack, enode.children[i]) -- 907
				end -- 907
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 909
				break -- 910
			end -- 910
		end -- 910
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 910
		if ____cond186 then -- 910
			do -- 910
				local sequenceStack = {} -- 913
				for i = 1, #enode.children do -- 913
					visitAction(sequenceStack, enode.children[i]) -- 915
				end -- 915
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 917
				break -- 918
			end -- 918
		end -- 918
		do -- 918
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 921
			break -- 922
		end -- 922
	until true -- 922
end -- 869
local function actionCheck(nodeStack, enode, parent) -- 926
	local unsupported = false -- 927
	if parent == nil then -- 927
		unsupported = true -- 929
	else -- 929
		repeat -- 929
			local ____switch200 = parent.type -- 929
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 929
			if ____cond200 then -- 929
				break -- 932
			end -- 932
			do -- 932
				unsupported = true -- 933
				break -- 933
			end -- 933
		until true -- 933
	end -- 933
	if unsupported then -- 933
		if #nodeStack > 0 then -- 933
			local node = nodeStack[#nodeStack] -- 938
			local actionStack = {} -- 939
			visitAction(actionStack, enode) -- 940
			if #actionStack == 1 then -- 940
				node:runAction(actionStack[1]) -- 942
			end -- 942
		else -- 942
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 945
		end -- 945
	end -- 945
end -- 926
local function bodyCheck(_nodeStack, enode, parent) -- 950
	if parent == nil or parent.type ~= "body" then -- 950
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 952
	end -- 952
end -- 950
actionMap = { -- 956
	["anchor-x"] = Dora.AnchorX, -- 959
	["anchor-y"] = Dora.AnchorY, -- 960
	angle = Dora.Angle, -- 961
	["angle-x"] = Dora.AngleX, -- 962
	["angle-y"] = Dora.AngleY, -- 963
	width = Dora.Width, -- 964
	height = Dora.Height, -- 965
	opacity = Dora.Opacity, -- 966
	roll = Dora.Roll, -- 967
	scale = Dora.Scale, -- 968
	["scale-x"] = Dora.ScaleX, -- 969
	["scale-y"] = Dora.ScaleY, -- 970
	["skew-x"] = Dora.SkewX, -- 971
	["skew-y"] = Dora.SkewY, -- 972
	["move-x"] = Dora.X, -- 973
	["move-y"] = Dora.Y, -- 974
	["move-z"] = Dora.Z -- 975
} -- 975
elementMap = { -- 978
	node = function(nodeStack, enode, parent) -- 979
		addChild( -- 980
			nodeStack, -- 980
			getNode(enode), -- 980
			enode -- 980
		) -- 980
	end, -- 979
	["clip-node"] = function(nodeStack, enode, parent) -- 982
		addChild( -- 983
			nodeStack, -- 983
			getClipNode(enode), -- 983
			enode -- 983
		) -- 983
	end, -- 982
	playable = function(nodeStack, enode, parent) -- 985
		local cnode = getPlayable(enode) -- 986
		if cnode ~= nil then -- 986
			addChild(nodeStack, cnode, enode) -- 988
		end -- 988
	end, -- 985
	["dragon-bone"] = function(nodeStack, enode, parent) -- 991
		local cnode = getDragonBone(enode) -- 992
		if cnode ~= nil then -- 992
			addChild(nodeStack, cnode, enode) -- 994
		end -- 994
	end, -- 991
	spine = function(nodeStack, enode, parent) -- 997
		local cnode = getSpine(enode) -- 998
		if cnode ~= nil then -- 998
			addChild(nodeStack, cnode, enode) -- 1000
		end -- 1000
	end, -- 997
	model = function(nodeStack, enode, parent) -- 1003
		local cnode = getModel(enode) -- 1004
		if cnode ~= nil then -- 1004
			addChild(nodeStack, cnode, enode) -- 1006
		end -- 1006
	end, -- 1003
	["draw-node"] = function(nodeStack, enode, parent) -- 1009
		addChild( -- 1010
			nodeStack, -- 1010
			getDrawNode(enode), -- 1010
			enode -- 1010
		) -- 1010
	end, -- 1009
	["dot-shape"] = drawNodeCheck, -- 1012
	["segment-shape"] = drawNodeCheck, -- 1013
	["rect-shape"] = drawNodeCheck, -- 1014
	["polygon-shape"] = drawNodeCheck, -- 1015
	["verts-shape"] = drawNodeCheck, -- 1016
	grid = function(nodeStack, enode, parent) -- 1017
		addChild( -- 1018
			nodeStack, -- 1018
			getGrid(enode), -- 1018
			enode -- 1018
		) -- 1018
	end, -- 1017
	sprite = function(nodeStack, enode, parent) -- 1020
		local cnode = getSprite(enode) -- 1021
		if cnode ~= nil then -- 1021
			addChild(nodeStack, cnode, enode) -- 1023
		end -- 1023
	end, -- 1020
	["audio-source"] = function(nodeStack, enode, parent) -- 1026
		local cnode = getAudioSource(enode) -- 1027
		if cnode ~= nil then -- 1027
			addChild(nodeStack, cnode, enode) -- 1029
		end -- 1029
	end, -- 1026
	["video-node"] = function(nodeStack, enode, parent) -- 1032
		local cnode = getVideoNode(enode) -- 1033
		if cnode ~= nil then -- 1033
			addChild(nodeStack, cnode, enode) -- 1035
		end -- 1035
	end, -- 1032
	["tic80-node"] = function(nodeStack, enode, parent) -- 1038
		local cnode = getTIC80Node(enode) -- 1039
		if cnode ~= nil then -- 1039
			addChild(nodeStack, cnode, enode) -- 1041
		end -- 1041
	end, -- 1038
	label = function(nodeStack, enode, parent) -- 1044
		local cnode = getLabel(enode) -- 1045
		if cnode ~= nil then -- 1045
			addChild(nodeStack, cnode, enode) -- 1047
		end -- 1047
	end, -- 1044
	line = function(nodeStack, enode, parent) -- 1050
		addChild( -- 1051
			nodeStack, -- 1051
			getLine(enode), -- 1051
			enode -- 1051
		) -- 1051
	end, -- 1050
	particle = function(nodeStack, enode, parent) -- 1053
		local cnode = getParticle(enode) -- 1054
		if cnode ~= nil then -- 1054
			addChild(nodeStack, cnode, enode) -- 1056
		end -- 1056
	end, -- 1053
	menu = function(nodeStack, enode, parent) -- 1059
		addChild( -- 1060
			nodeStack, -- 1060
			getMenu(enode), -- 1060
			enode -- 1060
		) -- 1060
	end, -- 1059
	action = function(_nodeStack, enode, parent) -- 1062
		if #enode.children == 0 then -- 1062
			Warn("<action> tag has no children") -- 1064
			return -- 1065
		end -- 1065
		local action = enode.props -- 1067
		if action.ref == nil then -- 1067
			Warn("<action> tag has no ref") -- 1069
			return -- 1070
		end -- 1070
		local actionStack = {} -- 1072
		for i = 1, #enode.children do -- 1072
			visitAction(actionStack, enode.children[i]) -- 1074
		end -- 1074
		if #actionStack == 1 then -- 1074
			action.ref.current = actionStack[1] -- 1077
		elseif #actionStack > 1 then -- 1077
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1079
		end -- 1079
	end, -- 1062
	["anchor-x"] = actionCheck, -- 1082
	["anchor-y"] = actionCheck, -- 1083
	angle = actionCheck, -- 1084
	["angle-x"] = actionCheck, -- 1085
	["angle-y"] = actionCheck, -- 1086
	delay = actionCheck, -- 1087
	event = actionCheck, -- 1088
	width = actionCheck, -- 1089
	height = actionCheck, -- 1090
	hide = actionCheck, -- 1091
	show = actionCheck, -- 1092
	move = actionCheck, -- 1093
	opacity = actionCheck, -- 1094
	roll = actionCheck, -- 1095
	scale = actionCheck, -- 1096
	["scale-x"] = actionCheck, -- 1097
	["scale-y"] = actionCheck, -- 1098
	["skew-x"] = actionCheck, -- 1099
	["skew-y"] = actionCheck, -- 1100
	["move-x"] = actionCheck, -- 1101
	["move-y"] = actionCheck, -- 1102
	["move-z"] = actionCheck, -- 1103
	frame = actionCheck, -- 1104
	spawn = actionCheck, -- 1105
	sequence = actionCheck, -- 1106
	loop = function(nodeStack, enode, _parent) -- 1107
		if #nodeStack > 0 then -- 1107
			local node = nodeStack[#nodeStack] -- 1109
			local actionStack = {} -- 1110
			for i = 1, #enode.children do -- 1110
				visitAction(actionStack, enode.children[i]) -- 1112
			end -- 1112
			if #actionStack == 1 then -- 1112
				node:runAction(actionStack[1], true) -- 1115
			else -- 1115
				local loop = enode.props -- 1117
				if loop.spawn then -- 1117
					node:runAction( -- 1119
						Dora.Spawn(table.unpack(actionStack)), -- 1119
						true -- 1119
					) -- 1119
				else -- 1119
					node:runAction( -- 1121
						Dora.Sequence(table.unpack(actionStack)), -- 1121
						true -- 1121
					) -- 1121
				end -- 1121
			end -- 1121
		else -- 1121
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1125
		end -- 1125
	end, -- 1107
	["physics-world"] = function(nodeStack, enode, _parent) -- 1128
		addChild( -- 1129
			nodeStack, -- 1129
			getPhysicsWorld(enode), -- 1129
			enode -- 1129
		) -- 1129
	end, -- 1128
	contact = function(nodeStack, enode, _parent) -- 1131
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1132
		if world ~= nil then -- 1132
			local contact = enode.props -- 1134
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1135
		else -- 1135
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1137
		end -- 1137
	end, -- 1131
	body = function(nodeStack, enode, _parent) -- 1140
		local def = enode.props -- 1141
		if def.world then -- 1141
			addChild( -- 1143
				nodeStack, -- 1143
				getBody(enode, def.world), -- 1143
				enode -- 1143
			) -- 1143
			return -- 1144
		end -- 1144
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1146
		if world ~= nil then -- 1146
			addChild( -- 1148
				nodeStack, -- 1148
				getBody(enode, world), -- 1148
				enode -- 1148
			) -- 1148
		else -- 1148
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1150
		end -- 1150
	end, -- 1140
	["rect-fixture"] = bodyCheck, -- 1153
	["polygon-fixture"] = bodyCheck, -- 1154
	["multi-fixture"] = bodyCheck, -- 1155
	["disk-fixture"] = bodyCheck, -- 1156
	["chain-fixture"] = bodyCheck, -- 1157
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1158
		local joint = enode.props -- 1159
		if joint.ref == nil then -- 1159
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1161
			return -- 1162
		end -- 1162
		if joint.bodyA.current == nil then -- 1162
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1165
			return -- 1166
		end -- 1166
		if joint.bodyB.current == nil then -- 1166
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1169
			return -- 1170
		end -- 1170
		local ____joint_ref_17 = joint.ref -- 1172
		local ____self_15 = Dora.Joint -- 1172
		local ____self_15_distance_16 = ____self_15.distance -- 1172
		local ____joint_canCollide_14 = joint.canCollide -- 1173
		if ____joint_canCollide_14 == nil then -- 1173
			____joint_canCollide_14 = false -- 1173
		end -- 1173
		____joint_ref_17.current = ____self_15_distance_16( -- 1172
			____self_15, -- 1172
			____joint_canCollide_14, -- 1173
			joint.bodyA.current, -- 1174
			joint.bodyB.current, -- 1175
			joint.anchorA or Dora.Vec2.zero, -- 1176
			joint.anchorB or Dora.Vec2.zero, -- 1177
			joint.frequency or 0, -- 1178
			joint.damping or 0 -- 1179
		) -- 1179
	end, -- 1158
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1181
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
		local ____joint_ref_21 = joint.ref -- 1195
		local ____self_19 = Dora.Joint -- 1195
		local ____self_19_friction_20 = ____self_19.friction -- 1195
		local ____joint_canCollide_18 = joint.canCollide -- 1196
		if ____joint_canCollide_18 == nil then -- 1196
			____joint_canCollide_18 = false -- 1196
		end -- 1196
		____joint_ref_21.current = ____self_19_friction_20( -- 1195
			____self_19, -- 1195
			____joint_canCollide_18, -- 1196
			joint.bodyA.current, -- 1197
			joint.bodyB.current, -- 1198
			joint.worldPos, -- 1199
			joint.maxForce, -- 1200
			joint.maxTorque -- 1201
		) -- 1201
	end, -- 1181
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1204
		local joint = enode.props -- 1205
		if joint.ref == nil then -- 1205
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1207
			return -- 1208
		end -- 1208
		if joint.jointA.current == nil then -- 1208
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1211
			return -- 1212
		end -- 1212
		if joint.jointB.current == nil then -- 1212
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1215
			return -- 1216
		end -- 1216
		local ____joint_ref_25 = joint.ref -- 1218
		local ____self_23 = Dora.Joint -- 1218
		local ____self_23_gear_24 = ____self_23.gear -- 1218
		local ____joint_canCollide_22 = joint.canCollide -- 1219
		if ____joint_canCollide_22 == nil then -- 1219
			____joint_canCollide_22 = false -- 1219
		end -- 1219
		____joint_ref_25.current = ____self_23_gear_24( -- 1218
			____self_23, -- 1218
			____joint_canCollide_22, -- 1219
			joint.jointA.current, -- 1220
			joint.jointB.current, -- 1221
			joint.ratio or 1 -- 1222
		) -- 1222
	end, -- 1204
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1225
		local joint = enode.props -- 1226
		if joint.ref == nil then -- 1226
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1228
			return -- 1229
		end -- 1229
		if joint.bodyA.current == nil then -- 1229
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1232
			return -- 1233
		end -- 1233
		if joint.bodyB.current == nil then -- 1233
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1236
			return -- 1237
		end -- 1237
		local ____joint_ref_29 = joint.ref -- 1239
		local ____self_27 = Dora.Joint -- 1239
		local ____self_27_spring_28 = ____self_27.spring -- 1239
		local ____joint_canCollide_26 = joint.canCollide -- 1240
		if ____joint_canCollide_26 == nil then -- 1240
			____joint_canCollide_26 = false -- 1240
		end -- 1240
		____joint_ref_29.current = ____self_27_spring_28( -- 1239
			____self_27, -- 1239
			____joint_canCollide_26, -- 1240
			joint.bodyA.current, -- 1241
			joint.bodyB.current, -- 1242
			joint.linearOffset, -- 1243
			joint.angularOffset, -- 1244
			joint.maxForce, -- 1245
			joint.maxTorque, -- 1246
			joint.correctionFactor or 1 -- 1247
		) -- 1247
	end, -- 1225
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1250
		local joint = enode.props -- 1251
		if joint.ref == nil then -- 1251
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1253
			return -- 1254
		end -- 1254
		if joint.body.current == nil then -- 1254
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1257
			return -- 1258
		end -- 1258
		local ____joint_ref_33 = joint.ref -- 1260
		local ____self_31 = Dora.Joint -- 1260
		local ____self_31_move_32 = ____self_31.move -- 1260
		local ____joint_canCollide_30 = joint.canCollide -- 1261
		if ____joint_canCollide_30 == nil then -- 1261
			____joint_canCollide_30 = false -- 1261
		end -- 1261
		____joint_ref_33.current = ____self_31_move_32( -- 1260
			____self_31, -- 1260
			____joint_canCollide_30, -- 1261
			joint.body.current, -- 1262
			joint.targetPos, -- 1263
			joint.maxForce, -- 1264
			joint.frequency, -- 1265
			joint.damping or 0.7 -- 1266
		) -- 1266
	end, -- 1250
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1269
		local joint = enode.props -- 1270
		if joint.ref == nil then -- 1270
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1272
			return -- 1273
		end -- 1273
		if joint.bodyA.current == nil then -- 1273
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1276
			return -- 1277
		end -- 1277
		if joint.bodyB.current == nil then -- 1277
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1280
			return -- 1281
		end -- 1281
		local ____joint_ref_37 = joint.ref -- 1283
		local ____self_35 = Dora.Joint -- 1283
		local ____self_35_prismatic_36 = ____self_35.prismatic -- 1283
		local ____joint_canCollide_34 = joint.canCollide -- 1284
		if ____joint_canCollide_34 == nil then -- 1284
			____joint_canCollide_34 = false -- 1284
		end -- 1284
		____joint_ref_37.current = ____self_35_prismatic_36( -- 1283
			____self_35, -- 1283
			____joint_canCollide_34, -- 1284
			joint.bodyA.current, -- 1285
			joint.bodyB.current, -- 1286
			joint.worldPos, -- 1287
			joint.axisAngle, -- 1288
			joint.lowerTranslation or 0, -- 1289
			joint.upperTranslation or 0, -- 1290
			joint.maxMotorForce or 0, -- 1291
			joint.motorSpeed or 0 -- 1292
		) -- 1292
	end, -- 1269
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1295
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
		local ____joint_ref_41 = joint.ref -- 1309
		local ____self_39 = Dora.Joint -- 1309
		local ____self_39_pulley_40 = ____self_39.pulley -- 1309
		local ____joint_canCollide_38 = joint.canCollide -- 1310
		if ____joint_canCollide_38 == nil then -- 1310
			____joint_canCollide_38 = false -- 1310
		end -- 1310
		____joint_ref_41.current = ____self_39_pulley_40( -- 1309
			____self_39, -- 1309
			____joint_canCollide_38, -- 1310
			joint.bodyA.current, -- 1311
			joint.bodyB.current, -- 1312
			joint.anchorA or Dora.Vec2.zero, -- 1313
			joint.anchorB or Dora.Vec2.zero, -- 1314
			joint.groundAnchorA, -- 1315
			joint.groundAnchorB, -- 1316
			joint.ratio or 1 -- 1317
		) -- 1317
	end, -- 1295
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1320
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
		local ____joint_ref_45 = joint.ref -- 1334
		local ____self_43 = Dora.Joint -- 1334
		local ____self_43_revolute_44 = ____self_43.revolute -- 1334
		local ____joint_canCollide_42 = joint.canCollide -- 1335
		if ____joint_canCollide_42 == nil then -- 1335
			____joint_canCollide_42 = false -- 1335
		end -- 1335
		____joint_ref_45.current = ____self_43_revolute_44( -- 1334
			____self_43, -- 1334
			____joint_canCollide_42, -- 1335
			joint.bodyA.current, -- 1336
			joint.bodyB.current, -- 1337
			joint.worldPos, -- 1338
			joint.lowerAngle or 0, -- 1339
			joint.upperAngle or 0, -- 1340
			joint.maxMotorTorque or 0, -- 1341
			joint.motorSpeed or 0 -- 1342
		) -- 1342
	end, -- 1320
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1345
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
		local ____joint_ref_49 = joint.ref -- 1359
		local ____self_47 = Dora.Joint -- 1359
		local ____self_47_rope_48 = ____self_47.rope -- 1359
		local ____joint_canCollide_46 = joint.canCollide -- 1360
		if ____joint_canCollide_46 == nil then -- 1360
			____joint_canCollide_46 = false -- 1360
		end -- 1360
		____joint_ref_49.current = ____self_47_rope_48( -- 1359
			____self_47, -- 1359
			____joint_canCollide_46, -- 1360
			joint.bodyA.current, -- 1361
			joint.bodyB.current, -- 1362
			joint.anchorA or Dora.Vec2.zero, -- 1363
			joint.anchorB or Dora.Vec2.zero, -- 1364
			joint.maxLength or 0 -- 1365
		) -- 1365
	end, -- 1345
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1368
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
		local ____joint_ref_53 = joint.ref -- 1382
		local ____self_51 = Dora.Joint -- 1382
		local ____self_51_weld_52 = ____self_51.weld -- 1382
		local ____joint_canCollide_50 = joint.canCollide -- 1383
		if ____joint_canCollide_50 == nil then -- 1383
			____joint_canCollide_50 = false -- 1383
		end -- 1383
		____joint_ref_53.current = ____self_51_weld_52( -- 1382
			____self_51, -- 1382
			____joint_canCollide_50, -- 1383
			joint.bodyA.current, -- 1384
			joint.bodyB.current, -- 1385
			joint.worldPos, -- 1386
			joint.frequency or 0, -- 1387
			joint.damping or 0 -- 1388
		) -- 1388
	end, -- 1368
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1391
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
		local ____joint_ref_57 = joint.ref -- 1405
		local ____self_55 = Dora.Joint -- 1405
		local ____self_55_wheel_56 = ____self_55.wheel -- 1405
		local ____joint_canCollide_54 = joint.canCollide -- 1406
		if ____joint_canCollide_54 == nil then -- 1406
			____joint_canCollide_54 = false -- 1406
		end -- 1406
		____joint_ref_57.current = ____self_55_wheel_56( -- 1405
			____self_55, -- 1405
			____joint_canCollide_54, -- 1406
			joint.bodyA.current, -- 1407
			joint.bodyB.current, -- 1408
			joint.worldPos, -- 1409
			joint.axisAngle, -- 1410
			joint.maxMotorTorque or 0, -- 1411
			joint.motorSpeed or 0, -- 1412
			joint.frequency or 0, -- 1413
			joint.damping or 0.7 -- 1414
		) -- 1414
	end, -- 1391
	["custom-node"] = function(nodeStack, enode, _parent) -- 1417
		local node = getCustomNode(enode) -- 1418
		if node ~= nil then -- 1418
			addChild(nodeStack, node, enode) -- 1420
		end -- 1420
	end, -- 1417
	["custom-element"] = function() -- 1423
	end, -- 1423
	["align-node"] = function(nodeStack, enode, _parent) -- 1424
		addChild( -- 1425
			nodeStack, -- 1425
			getAlignNode(enode), -- 1425
			enode -- 1425
		) -- 1425
	end, -- 1424
	["effek-node"] = function(nodeStack, enode, _parent) -- 1427
		addChild( -- 1428
			nodeStack, -- 1428
			getEffekNode(enode), -- 1428
			enode -- 1428
		) -- 1428
	end, -- 1427
	effek = function(nodeStack, enode, parent) -- 1430
		if #nodeStack > 0 then -- 1430
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1432
			if node then -- 1432
				local effek = enode.props -- 1434
				local handle = node:play( -- 1435
					effek.file, -- 1435
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1435
					effek.z or 0 -- 1435
				) -- 1435
				if handle >= 0 then -- 1435
					if effek.ref then -- 1435
						effek.ref.current = handle -- 1438
					end -- 1438
					if effek.onEnd then -- 1438
						local onEnd = effek.onEnd -- 1438
						node:slot( -- 1442
							"EffekEnd", -- 1442
							function(h) -- 1442
								if handle == h then -- 1442
									onEnd(nil) -- 1444
								end -- 1444
							end -- 1442
						) -- 1442
					end -- 1442
				end -- 1442
			else -- 1442
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1450
			end -- 1450
		end -- 1450
	end, -- 1430
	["tile-node"] = function(nodeStack, enode, parent) -- 1454
		local cnode = getTileNode(enode) -- 1455
		if cnode ~= nil then -- 1455
			addChild(nodeStack, cnode, enode) -- 1457
		end -- 1457
	end -- 1454
} -- 1454
local roots = {} -- 1510
local renderQueued = false -- 1511
local queuedRoots = {} -- 1512
local trackingRoot -- 1513
local function isElementList(node) -- 1515
	return node.type == nil -- 1516
end -- 1515
local function getRenderableElement(renderable) -- 1524
	if type(renderable) == "function" then -- 1524
		return renderable() -- 1526
	end -- 1526
	return renderable -- 1528
end -- 1524
local function removeRoot(root) -- 1657
	for i = 1, #roots do -- 1657
		if roots[i] == root then -- 1657
			table.remove(roots, i) -- 1660
			break -- 1661
		end -- 1661
	end -- 1661
end -- 1657
local function toElementList(node) -- 1980
	if isElementList(node) then -- 1980
		return node -- 1982
	end -- 1982
	return {node} -- 1984
end -- 1980
local function scheduleRootRender(root) -- 1987
	if not root.active then -- 1987
		return -- 1988
	end -- 1988
	for i = 1, #queuedRoots do -- 1988
		if queuedRoots[i] == root then -- 1988
			return -- 1990
		end -- 1990
	end -- 1990
	queuedRoots[#queuedRoots + 1] = root -- 1992
	if renderQueued then -- 1992
		return -- 1993
	end -- 1993
	renderQueued = true -- 1994
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 1995
		renderQueued = false -- 1996
		local updatingRoots = queuedRoots -- 1997
		queuedRoots = {} -- 1998
		for i = 1, #updatingRoots do -- 1998
			updatingRoots[i]:update() -- 2000
		end -- 2000
	end)) -- 1995
end -- 1987
____exports.Root = __TS__Class() -- 2005
local Root = ____exports.Root -- 2005
Root.name = "Root" -- 2005
function Root.prototype.____constructor(self, parent) -- 2011
	self.parent = parent -- 2011
	self.mounted = {} -- 2006
	self.signals = {} -- 2008
	self.active = true -- 2009
end -- 2011
function Root.prototype.render(self, enode) -- 2013
	if not self.active then -- 2013
		roots[#roots + 1] = self -- 2015
		self.active = true -- 2016
	end -- 2016
	self.renderable = enode -- 2018
	self:update() -- 2019
end -- 2013
function Root.prototype.update(self) -- 2022
	if not self.active or self.renderable == nil then -- 2022
		return -- 2023
	end -- 2023
	self:unsubscribeSignals() -- 2024
	local lastTrackingRoot = trackingRoot -- 2025
	trackingRoot = self -- 2026
	local elements -- 2027
	do -- 2027
		local ____try, ____error = pcall(function() -- 2027
			elements = getRenderableElement(self.renderable) -- 2029
		end) -- 2029
		do -- 2029
			trackingRoot = lastTrackingRoot -- 2031
		end -- 2031
		if not ____try then -- 2031
			error(____error, 0) -- 2031
		end -- 2031
	end -- 2031
	self.mounted = reconcileChildren( -- 2033
		self.parent, -- 2033
		self.mounted, -- 2033
		toElementList(elements) -- 2033
	) -- 2033
end -- 2022
function Root.prototype.unmount(self) -- 2036
	for i = 1, #self.mounted do -- 2036
		unmountElement(self.mounted[i]) -- 2038
	end -- 2038
	self.mounted = {} -- 2040
	self.renderable = nil -- 2041
	self:unsubscribeSignals() -- 2042
	if self.active then -- 2042
		removeRoot(self) -- 2044
		self.active = false -- 2045
	end -- 2045
end -- 2036
function Root.prototype.trackSignal(self, signal) -- 2049
	for i = 1, #self.signals do -- 2049
		if self.signals[i] == signal then -- 2049
			return -- 2051
		end -- 2051
	end -- 2051
	local ____self_signals_59 = self.signals -- 2051
	____self_signals_59[#____self_signals_59 + 1] = signal -- 2053
	signal:addRoot(self) -- 2054
end -- 2049
function Root.prototype.unsubscribeSignals(self) -- 2057
	for i = 1, #self.signals do -- 2057
		self.signals[i]:removeRoot(self) -- 2059
	end -- 2059
	self.signals = {} -- 2061
end -- 2057
function ____exports.createRoot(parent) -- 2065
	local root = __TS__New(____exports.Root, parent) -- 2066
	roots[#roots + 1] = root -- 2067
	return root -- 2068
end -- 2065
____exports.Signal = __TS__Class() -- 2071
local Signal = ____exports.Signal -- 2071
Signal.name = "Signal" -- 2071
function Signal.prototype.____constructor(self, item) -- 2074
	self.item = item -- 2074
	self.roots = {} -- 2072
end -- 2074
function Signal.prototype.addRoot(self, root) -- 2091
	for i = 1, #self.roots do -- 2091
		if self.roots[i] == root then -- 2091
			return -- 2093
		end -- 2093
	end -- 2093
	local ____self_roots_60 = self.roots -- 2093
	____self_roots_60[#____self_roots_60 + 1] = root -- 2095
end -- 2091
function Signal.prototype.removeRoot(self, root) -- 2098
	for i = 1, #self.roots do -- 2098
		if self.roots[i] == root then -- 2098
			table.remove(self.roots, i) -- 2101
			break -- 2102
		end -- 2102
	end -- 2102
end -- 2098
__TS__SetDescriptor( -- 2098
	Signal.prototype, -- 2098
	"value", -- 2098
	{ -- 2098
		get = function(self) -- 2098
			if trackingRoot ~= nil then -- 2098
				trackingRoot:trackSignal(self) -- 2078
			end -- 2078
			return self.item -- 2080
		end, -- 2080
		set = function(self, value) -- 2080
			if self.item == value then -- 2080
				return -- 2084
			end -- 2084
			self.item = value -- 2085
			for i = 1, #self.roots do -- 2085
				scheduleRootRender(self.roots[i]) -- 2087
			end -- 2087
		end -- 2087
	}, -- 2087
	true -- 2087
) -- 2087
function ____exports.signal(value) -- 2108
	return __TS__New(____exports.Signal, value) -- 2109
end -- 2108
function ____exports.useRef(item) -- 2112
	local ____item_61 = item -- 2113
	if ____item_61 == nil then -- 2113
		____item_61 = nil -- 2113
	end -- 2113
	return {current = ____item_61} -- 2113
end -- 2112
local function getPreload(preloadList, node) -- 2116
	if type(node) ~= "table" then -- 2116
		return -- 2118
	end -- 2118
	local enode = node -- 2120
	if enode.type == nil then -- 2120
		local list = node -- 2122
		if #list > 0 then -- 2122
			for i = 1, #list do -- 2122
				getPreload(preloadList, list[i]) -- 2125
			end -- 2125
		end -- 2125
	else -- 2125
		repeat -- 2125
			local ____switch492 = enode.type -- 2125
			local sprite, playable, frame, model, spine, dragonBone, label -- 2125
			local ____cond492 = ____switch492 == "sprite" -- 2125
			if ____cond492 then -- 2125
				sprite = enode.props -- 2131
				if sprite.file then -- 2131
					preloadList[#preloadList + 1] = sprite.file -- 2133
				end -- 2133
				break -- 2135
			end -- 2135
			____cond492 = ____cond492 or ____switch492 == "playable" -- 2135
			if ____cond492 then -- 2135
				playable = enode.props -- 2137
				preloadList[#preloadList + 1] = playable.file -- 2138
				break -- 2139
			end -- 2139
			____cond492 = ____cond492 or ____switch492 == "frame" -- 2139
			if ____cond492 then -- 2139
				frame = enode.props -- 2141
				preloadList[#preloadList + 1] = frame.file -- 2142
				break -- 2143
			end -- 2143
			____cond492 = ____cond492 or ____switch492 == "model" -- 2143
			if ____cond492 then -- 2143
				model = enode.props -- 2145
				preloadList[#preloadList + 1] = "model:" .. model.file -- 2146
				break -- 2147
			end -- 2147
			____cond492 = ____cond492 or ____switch492 == "spine" -- 2147
			if ____cond492 then -- 2147
				spine = enode.props -- 2149
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 2150
				break -- 2151
			end -- 2151
			____cond492 = ____cond492 or ____switch492 == "dragon-bone" -- 2151
			if ____cond492 then -- 2151
				dragonBone = enode.props -- 2153
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 2154
				break -- 2155
			end -- 2155
			____cond492 = ____cond492 or ____switch492 == "label" -- 2155
			if ____cond492 then -- 2155
				label = enode.props -- 2157
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 2158
				break -- 2159
			end -- 2159
		until true -- 2159
	end -- 2159
	getPreload(preloadList, enode.children) -- 2162
end -- 2116
function ____exports.preloadAsync(enode, handler) -- 2165
	local preloadList = {} -- 2166
	getPreload(preloadList, enode) -- 2167
	Dora.Cache:loadAsync(preloadList, handler) -- 2168
end -- 2165
function ____exports.toAction(enode) -- 2171
	local actionDef = ____exports.useRef() -- 2172
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2173
	if not actionDef.current then -- 2173
		error("failed to create action") -- 2174
	end -- 2174
	return actionDef.current -- 2175
end -- 2171
return ____exports -- 2171