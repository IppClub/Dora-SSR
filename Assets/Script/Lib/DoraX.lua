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
local Warn, visitNode, getElementKey, getPrimitiveLabelText, isDrawShapeElement, isBodyFixtureElement, isPhysicsWorldInputElement, hasPhysicsWorldInput, toHostElement, createHostNode, getElementChildren, shouldRecreate, isEventProp, applyProp, patchProps, addChildToParent, mountElement, unmountElement, reconcileElement, reconcileChildren, actionMap, elementMap -- 1
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
	Dora.Log("Warn", "[Dora Warning] " .. msg) -- 14
end -- 14
function visitNode(nodeStack, node, parent) -- 1460
	if type(node) ~= "table" then -- 1460
		return -- 1462
	end -- 1462
	local enode = node -- 1464
	if enode.type == nil then -- 1464
		local list = node -- 1466
		if #list > 0 then -- 1466
			for i = 1, #list do -- 1466
				local stack = {} -- 1469
				visitNode(stack, list[i], parent) -- 1470
				for i = 1, #stack do -- 1470
					nodeStack[#nodeStack + 1] = stack[i] -- 1472
				end -- 1472
			end -- 1472
		end -- 1472
	else -- 1472
		local handler = elementMap[enode.type] -- 1477
		if handler ~= nil then -- 1477
			handler(nodeStack, enode, parent) -- 1479
		else -- 1479
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1481
		end -- 1481
	end -- 1481
end -- 1481
function ____exports.toNode(enode) -- 1486
	local nodeStack = {} -- 1487
	visitNode(nodeStack, enode) -- 1488
	if #nodeStack == 1 then -- 1488
		return nodeStack[1] -- 1490
	elseif #nodeStack > 1 then -- 1490
		local node = Dora.Node() -- 1492
		for i = 1, #nodeStack do -- 1492
			node:addChild(nodeStack[i]) -- 1494
		end -- 1494
		return node -- 1496
	end -- 1496
	return nil -- 1498
end -- 1486
function getElementKey(element) -- 1516
	local props = element.props -- 1517
	local ____props_58 -- 1518
	if props then -- 1518
		____props_58 = props.key -- 1518
	else -- 1518
		____props_58 = nil -- 1518
	end -- 1518
	return ____props_58 -- 1518
end -- 1518
function getPrimitiveLabelText(enode) -- 1528
	local label = enode.props -- 1529
	local text = label.text or "" -- 1530
	for i = 1, #enode.children do -- 1530
		local child = enode.children[i] -- 1532
		if type(child) ~= "table" then -- 1532
			text = text .. tostring(child) -- 1534
		end -- 1534
	end -- 1534
	return text -- 1537
end -- 1537
function isDrawShapeElement(element) -- 1540
	repeat -- 1540
		local ____switch335 = element.type -- 1540
		local ____cond335 = ____switch335 == "dot-shape" or ____switch335 == "segment-shape" or ____switch335 == "rect-shape" or ____switch335 == "polygon-shape" or ____switch335 == "verts-shape" -- 1540
		if ____cond335 then -- 1540
			return true -- 1547
		end -- 1547
	until true -- 1547
	return false -- 1549
end -- 1549
function isBodyFixtureElement(element) -- 1552
	repeat -- 1552
		local ____switch337 = element.type -- 1552
		local ____cond337 = ____switch337 == "rect-fixture" or ____switch337 == "polygon-fixture" or ____switch337 == "multi-fixture" or ____switch337 == "disk-fixture" or ____switch337 == "chain-fixture" -- 1552
		if ____cond337 then -- 1552
			return true -- 1559
		end -- 1559
	until true -- 1559
	return false -- 1561
end -- 1561
function isPhysicsWorldInputElement(element) -- 1564
	return element.type == "contact" -- 1565
end -- 1565
function hasPhysicsWorldInput(element) -- 1568
	for i = 1, #element.children do -- 1568
		local child = element.children[i] -- 1570
		if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1570
			return true -- 1572
		end -- 1572
	end -- 1572
	return false -- 1575
end -- 1575
function toHostElement(enode, parent) -- 1578
	local hostChildren = {} -- 1579
	local props = enode.props or ({}) -- 1580
	if enode.type == "label" then -- 1580
		for i = 1, #enode.children do -- 1580
			local child = enode.children[i] -- 1583
			if type(child) ~= "table" then -- 1583
				hostChildren[#hostChildren + 1] = child -- 1585
			end -- 1585
		end -- 1585
	elseif enode.type == "draw-node" then -- 1585
		for i = 1, #enode.children do -- 1585
			local child = enode.children[i] -- 1590
			if type(child) == "table" and isDrawShapeElement(child) then -- 1590
				hostChildren[#hostChildren + 1] = child -- 1592
			end -- 1592
		end -- 1592
	elseif enode.type == "body" then -- 1592
		for i = 1, #enode.children do -- 1592
			local child = enode.children[i] -- 1597
			if type(child) == "table" and isBodyFixtureElement(child) then -- 1597
				hostChildren[#hostChildren + 1] = child -- 1599
			end -- 1599
		end -- 1599
	elseif enode.type == "physics-world" then -- 1599
		for i = 1, #enode.children do -- 1599
			local child = enode.children[i] -- 1604
			if type(child) == "table" and isPhysicsWorldInputElement(child) then -- 1604
				hostChildren[#hostChildren + 1] = child -- 1606
			end -- 1606
		end -- 1606
	end -- 1606
	if enode.type == "body" and props.world == nil then -- 1606
		local world = Dora.tolua.cast(parent, "PhysicsWorld") -- 1611
		if world ~= nil then -- 1611
			props.world = world -- 1613
		end -- 1613
	end -- 1613
	return {type = enode.type, props = props, children = hostChildren} -- 1616
end -- 1616
function createHostNode(enode, parent) -- 1623
	local nodeStack = {} -- 1624
	visitNode( -- 1625
		nodeStack, -- 1625
		toHostElement(enode, parent) -- 1625
	) -- 1625
	if #nodeStack == 1 then -- 1625
		return nodeStack[1] -- 1627
	elseif #nodeStack > 1 then -- 1627
		local node = Dora.Node() -- 1629
		for i = 1, #nodeStack do -- 1629
			node:addChild(nodeStack[i]) -- 1631
		end -- 1631
		return node -- 1633
	end -- 1633
	return nil -- 1635
end -- 1635
function getElementChildren(enode) -- 1638
	local children = {} -- 1639
	if enode.type == "draw-node" or enode.type == "body" then -- 1639
		return children -- 1640
	end -- 1640
	for i = 1, #enode.children do -- 1640
		local child = enode.children[i] -- 1642
		if type(child) == "table" then -- 1642
			local childElement = child -- 1644
			if childElement.type ~= nil then -- 1644
				if enode.type ~= "physics-world" or not isPhysicsWorldInputElement(childElement) then -- 1644
					children[#children + 1] = childElement -- 1647
				end -- 1647
			else -- 1647
				local list = child -- 1650
				for j = 1, #list do -- 1650
					local item = list[j] -- 1652
					if type(item) == "table" and item.type ~= nil then -- 1652
						if enode.type ~= "physics-world" or not isPhysicsWorldInputElement(item) then -- 1652
							children[#children + 1] = item -- 1655
						end -- 1655
					end -- 1655
				end -- 1655
			end -- 1655
		end -- 1655
	end -- 1655
	return children -- 1662
end -- 1662
function shouldRecreate(oldElement, newElement) -- 1665
	if oldElement.type ~= newElement.type then -- 1665
		return true -- 1666
	end -- 1666
	if getElementKey(oldElement) ~= getElementKey(newElement) then -- 1666
		return true -- 1667
	end -- 1667
	local oldProps = oldElement.props -- 1668
	local newProps = newElement.props -- 1669
	if newElement.type == "draw-node" then -- 1669
		return true -- 1670
	end -- 1670
	for k, v in pairs(oldProps) do -- 1671
		if (isEventProp(k) or k == "onMount") and newProps[k] ~= v then -- 1671
			return true -- 1673
		end -- 1673
	end -- 1673
	for k, v in pairs(newProps) do -- 1676
		if (isEventProp(k) or k == "onMount") and oldProps[k] ~= v then -- 1676
			return true -- 1678
		end -- 1678
	end -- 1678
	repeat -- 1678
		local ____switch379 = newElement.type -- 1678
		local ____cond379 = ____switch379 == "grid" -- 1678
		if ____cond379 then -- 1678
			return oldProps.file ~= newProps.file or oldProps.gridX ~= newProps.gridX or oldProps.gridY ~= newProps.gridY -- 1683
		end -- 1683
		____cond379 = ____cond379 or (____switch379 == "sprite" or ____switch379 == "video-node" or ____switch379 == "tic80-node" or ____switch379 == "audio-source" or ____switch379 == "particle" or ____switch379 == "tile-node" or ____switch379 == "playable" or ____switch379 == "dragon-bone" or ____switch379 == "spine" or ____switch379 == "model") -- 1683
		if ____cond379 then -- 1683
			return oldProps.file ~= newProps.file -- 1694
		end -- 1694
		____cond379 = ____cond379 or ____switch379 == "label" -- 1694
		if ____cond379 then -- 1694
			return oldProps.fontName ~= newProps.fontName or oldProps.fontSize ~= newProps.fontSize or oldProps.sdf ~= newProps.sdf -- 1696
		end -- 1696
		____cond379 = ____cond379 or ____switch379 == "align-node" -- 1696
		if ____cond379 then -- 1696
			return oldProps.windowRoot ~= newProps.windowRoot -- 1698
		end -- 1698
		____cond379 = ____cond379 or ____switch379 == "custom-node" -- 1698
		if ____cond379 then -- 1698
			return oldProps.onCreate ~= newProps.onCreate -- 1700
		end -- 1700
		____cond379 = ____cond379 or ____switch379 == "physics-world" -- 1700
		if ____cond379 then -- 1700
			return hasPhysicsWorldInput(oldElement) or hasPhysicsWorldInput(newElement) -- 1702
		end -- 1702
		____cond379 = ____cond379 or ____switch379 == "body" -- 1702
		if ____cond379 then -- 1702
			return true -- 1704
		end -- 1704
	until true -- 1704
	return false -- 1706
end -- 1706
function isEventProp(key) -- 1709
	return type(key) == "string" and string.sub(key, 1, 2) == "on" -- 1710
end -- 1710
function applyProp(node, enode, key, value) -- 1713
	local name = key -- 1714
	repeat -- 1714
		local ____switch382 = name -- 1714
		local ____cond382 = ____switch382 == "key" or ____switch382 == "children" or ____switch382 == "onMount" -- 1714
		if ____cond382 then -- 1714
			return -- 1719
		end -- 1719
		____cond382 = ____cond382 or ____switch382 == "ref" -- 1719
		if ____cond382 then -- 1719
			value.current = node -- 1721
			return -- 1722
		end -- 1722
		____cond382 = ____cond382 or ____switch382 == "anchorX" -- 1722
		if ____cond382 then -- 1722
			node.anchor = Dora.Vec2(value, node.anchor.y) -- 1724
			return -- 1725
		end -- 1725
		____cond382 = ____cond382 or ____switch382 == "anchorY" -- 1725
		if ____cond382 then -- 1725
			node.anchor = Dora.Vec2(node.anchor.x, value) -- 1727
			return -- 1728
		end -- 1728
		____cond382 = ____cond382 or ____switch382 == "color3" -- 1728
		if ____cond382 then -- 1728
			node.color3 = Dora.Color3(value) -- 1730
			return -- 1731
		end -- 1731
		____cond382 = ____cond382 or ____switch382 == "transformTarget" -- 1731
		if ____cond382 then -- 1731
			node.transformTarget = value.current -- 1733
			return -- 1734
		end -- 1734
		____cond382 = ____cond382 or ____switch382 == "outlineColor" -- 1734
		if ____cond382 then -- 1734
			node[name] = Dora.Color(value) -- 1736
			return -- 1737
		end -- 1737
		____cond382 = ____cond382 or ____switch382 == "smoothLower" -- 1737
		if ____cond382 then -- 1737
			do -- 1737
				local smooth = node.smooth -- 1739
				node.smooth = Dora.Vec2(value, smooth.y) -- 1740
				return -- 1741
			end -- 1741
		end -- 1741
		____cond382 = ____cond382 or ____switch382 == "smoothUpper" -- 1741
		if ____cond382 then -- 1741
			do -- 1741
				local smooth = node.smooth -- 1744
				node.smooth = Dora.Vec2(smooth.x, value) -- 1745
				return -- 1746
			end -- 1746
		end -- 1746
	until true -- 1746
	if isEventProp(key) then -- 1746
		return -- 1750
	end -- 1750
	node[name] = value -- 1752
end -- 1752
function patchProps(node, oldElement, newElement) -- 1755
	local oldProps = oldElement.props -- 1756
	local newProps = newElement.props -- 1757
	for k in pairs(oldProps) do -- 1758
		if k ~= "ref" and k ~= "key" and not isEventProp(k) and newProps[k] == nil then -- 1758
			node[k] = nil -- 1760
		end -- 1760
	end -- 1760
	for k, v in pairs(newProps) do -- 1763
		if oldProps[k] ~= v then -- 1763
			applyProp(node, newElement, k, v) -- 1765
		end -- 1765
	end -- 1765
	if newElement.type == "label" then -- 1765
		node.text = getPrimitiveLabelText(newElement) -- 1769
	end -- 1769
end -- 1769
function addChildToParent(parent, node, props) -- 1773
	if props.tag ~= nil then -- 1773
		parent:addChild(node, props.order or 0, props.tag) -- 1775
	elseif props.order ~= nil then -- 1775
		parent:addChild(node, props.order) -- 1777
	else -- 1777
		parent:addChild(node) -- 1779
	end -- 1779
end -- 1779
function mountElement(parent, enode) -- 1783
	local node = createHostNode(enode, parent) -- 1784
	if node == nil then -- 1784
		return nil -- 1786
	end -- 1786
	if enode.type == "dot-shape" or enode.type == "segment-shape" or enode.type == "rect-shape" or enode.type == "polygon-shape" or enode.type == "verts-shape" then -- 1786
		return nil -- 1795
	end -- 1795
	local props = enode.props -- 1797
	addChildToParent(parent, node, props) -- 1798
	local mounted = {element = enode, node = node, children = {}} -- 1799
	mounted.children = reconcileChildren( -- 1800
		node, -- 1800
		{}, -- 1800
		getElementChildren(enode) -- 1800
	) -- 1800
	return mounted -- 1801
end -- 1801
function unmountElement(mounted) -- 1804
	for i = 1, #mounted.children do -- 1804
		unmountElement(mounted.children[i]) -- 1806
	end -- 1806
	mounted.node:removeFromParent(true) -- 1808
end -- 1808
function reconcileElement(parent, oldMounted, newElement) -- 1811
	if oldMounted == nil then -- 1811
		return mountElement(parent, newElement) -- 1813
	end -- 1813
	if shouldRecreate(oldMounted.element, newElement) then -- 1813
		local oldNode = oldMounted.node -- 1816
		local oldOrder = oldNode.order -- 1817
		local oldTag = oldNode.tag -- 1818
		unmountElement(oldMounted) -- 1819
		local mounted = mountElement(parent, newElement) -- 1820
		if mounted ~= nil then -- 1820
			mounted.node.order = newElement.props.order or oldOrder -- 1822
			mounted.node.tag = newElement.props.tag or oldTag -- 1823
		end -- 1823
		return mounted -- 1825
	end -- 1825
	patchProps(oldMounted.node, oldMounted.element, newElement) -- 1827
	oldMounted.children = reconcileChildren( -- 1828
		oldMounted.node, -- 1828
		oldMounted.children, -- 1828
		getElementChildren(newElement) -- 1828
	) -- 1828
	oldMounted.element = newElement -- 1829
	return oldMounted -- 1830
end -- 1830
function reconcileChildren(parent, oldChildren, newElements) -- 1833
	local oldByKey = {} -- 1834
	local usedOld = {} -- 1835
	for i = 1, #oldChildren do -- 1835
		local oldChild = oldChildren[i] -- 1837
		local key = getElementKey(oldChild.element) -- 1838
		if key ~= nil then -- 1838
			oldByKey[key] = oldChild -- 1840
		end -- 1840
	end -- 1840
	local nextChildren = {} -- 1843
	for i = 1, #newElements do -- 1843
		local newElement = newElements[i] -- 1845
		local key = getElementKey(newElement) -- 1846
		local oldChild -- 1847
		if key ~= nil then -- 1847
			oldChild = oldByKey[key] -- 1849
		else -- 1849
			oldChild = oldChildren[i] -- 1851
			if oldChild ~= nil and getElementKey(oldChild.element) ~= nil then -- 1851
				oldChild = nil -- 1853
			end -- 1853
		end -- 1853
		local mounted = reconcileElement(parent, oldChild, newElement) -- 1856
		if mounted ~= nil then -- 1856
			usedOld[mounted] = true -- 1858
			nextChildren[#nextChildren + 1] = mounted -- 1859
			local props = newElement.props -- 1860
			mounted.node.order = props.order or i -- 1861
			if props.tag ~= nil then -- 1861
				mounted.node.tag = props.tag -- 1862
			end -- 1862
		end -- 1862
	end -- 1862
	for i = 1, #oldChildren do -- 1862
		local oldChild = oldChildren[i] -- 1866
		if not usedOld[oldChild] then -- 1866
			unmountElement(oldChild) -- 1868
		end -- 1868
	end -- 1868
	return nextChildren -- 1871
end -- 1871
____exports.React = {} -- 1871
local React = ____exports.React -- 1871
do -- 1871
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
			____cond32 = ____cond32 or ____switch32 == "onKeyDown" -- 152
			if ____cond32 then -- 152
				cnode:slot("KeyDown", v) -- 153
				break -- 153
			end -- 153
			____cond32 = ____cond32 or ____switch32 == "onKeyUp" -- 153
			if ____cond32 then -- 153
				cnode:slot("KeyUp", v) -- 154
				break -- 154
			end -- 154
			____cond32 = ____cond32 or ____switch32 == "onKeyPressed" -- 154
			if ____cond32 then -- 154
				cnode:slot("KeyPressed", v) -- 155
				break -- 155
			end -- 155
			____cond32 = ____cond32 or ____switch32 == "onAttachIME" -- 155
			if ____cond32 then -- 155
				cnode:slot("AttachIME", v) -- 156
				break -- 156
			end -- 156
			____cond32 = ____cond32 or ____switch32 == "onDetachIME" -- 156
			if ____cond32 then -- 156
				cnode:slot("DetachIME", v) -- 157
				break -- 157
			end -- 157
			____cond32 = ____cond32 or ____switch32 == "onTextInput" -- 157
			if ____cond32 then -- 157
				cnode:slot("TextInput", v) -- 158
				break -- 158
			end -- 158
			____cond32 = ____cond32 or ____switch32 == "onTextEditing" -- 158
			if ____cond32 then -- 158
				cnode:slot("TextEditing", v) -- 159
				break -- 159
			end -- 159
			____cond32 = ____cond32 or ____switch32 == "onButtonDown" -- 159
			if ____cond32 then -- 159
				cnode:slot("ButtonDown", v) -- 160
				break -- 160
			end -- 160
			____cond32 = ____cond32 or ____switch32 == "onButtonUp" -- 160
			if ____cond32 then -- 160
				cnode:slot("ButtonUp", v) -- 161
				break -- 161
			end -- 161
			____cond32 = ____cond32 or ____switch32 == "onAxis" -- 161
			if ____cond32 then -- 161
				cnode:slot("Axis", v) -- 162
				break -- 162
			end -- 162
			do -- 162
				do -- 162
					if attribHandler then -- 162
						if not attribHandler(cnode, enode, k, v) then -- 162
							cnode[k] = v -- 166
						end -- 166
					else -- 166
						cnode[k] = v -- 169
					end -- 169
					break -- 171
				end -- 171
			end -- 171
		until true -- 171
	end -- 171
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 171
		cnode.touchEnabled = true -- 184
	end -- 184
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 184
		cnode.keyboardEnabled = true -- 191
	end -- 191
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 191
		cnode.controllerEnabled = true -- 198
	end -- 198
	if anchor ~= nil then -- 198
		cnode.anchor = anchor -- 200
	end -- 200
	if color3 ~= nil then -- 200
		cnode.color3 = color3 -- 201
	end -- 201
	if jnode.onMount ~= nil then -- 201
		jnode.onMount(cnode) -- 203
	end -- 203
	return cnode -- 205
end -- 129
local getClipNode -- 208
do -- 208
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 210
		repeat -- 210
			local ____switch45 = k -- 210
			local ____cond45 = ____switch45 == "stencil" -- 210
			if ____cond45 then -- 210
				cnode.stencil = ____exports.toNode(v) -- 217
				return true -- 217
			end -- 217
		until true -- 217
		return false -- 219
	end -- 210
	getClipNode = function(enode) -- 221
		return getNode( -- 222
			enode, -- 222
			Dora.ClipNode(), -- 222
			handleClipNodeAttribute -- 222
		) -- 222
	end -- 221
end -- 221
local getPlayable -- 226
local getDragonBone -- 227
local getSpine -- 228
local getModel -- 229
do -- 229
	local function handlePlayableAttribute(cnode, enode, k, v) -- 231
		repeat -- 231
			local ____switch49 = k -- 231
			local ____cond49 = ____switch49 == "file" -- 231
			if ____cond49 then -- 231
				return true -- 233
			end -- 233
			____cond49 = ____cond49 or ____switch49 == "play" -- 233
			if ____cond49 then -- 233
				cnode:play(v, enode.props.loop == true) -- 234
				return true -- 234
			end -- 234
			____cond49 = ____cond49 or ____switch49 == "loop" -- 234
			if ____cond49 then -- 234
				return true -- 235
			end -- 235
			____cond49 = ____cond49 or ____switch49 == "onAnimationEnd" -- 235
			if ____cond49 then -- 235
				cnode:slot("AnimationEnd", v) -- 236
				return true -- 236
			end -- 236
		until true -- 236
		return false -- 238
	end -- 231
	getPlayable = function(enode, cnode, attribHandler) -- 240
		if attribHandler == nil then -- 240
			attribHandler = handlePlayableAttribute -- 241
		end -- 241
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 242
		if cnode ~= nil then -- 242
			return getNode(enode, cnode, attribHandler) -- 244
		end -- 244
		return nil -- 246
	end -- 240
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 249
		repeat -- 249
			local ____switch53 = k -- 249
			local ____cond53 = ____switch53 == "hitTestEnabled" -- 249
			if ____cond53 then -- 249
				cnode.hitTestEnabled = true -- 251
				return true -- 251
			end -- 251
		until true -- 251
		return handlePlayableAttribute(cnode, enode, k, v) -- 253
	end -- 249
	getDragonBone = function(enode) -- 255
		local node = Dora.DragonBone(enode.props.file) -- 256
		if node ~= nil then -- 256
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 258
			return cnode -- 259
		end -- 259
		return nil -- 261
	end -- 255
	local function handleSpineAttribute(cnode, enode, k, v) -- 264
		repeat -- 264
			local ____switch57 = k -- 264
			local ____cond57 = ____switch57 == "hitTestEnabled" -- 264
			if ____cond57 then -- 264
				cnode.hitTestEnabled = true -- 266
				return true -- 266
			end -- 266
		until true -- 266
		return handlePlayableAttribute(cnode, enode, k, v) -- 268
	end -- 264
	getSpine = function(enode) -- 270
		local node = Dora.Spine(enode.props.file) -- 271
		if node ~= nil then -- 271
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 273
			return cnode -- 274
		end -- 274
		return nil -- 276
	end -- 270
	local function handleModelAttribute(cnode, enode, k, v) -- 279
		repeat -- 279
			local ____switch61 = k -- 279
			local ____cond61 = ____switch61 == "reversed" -- 279
			if ____cond61 then -- 279
				cnode.reversed = v -- 281
				return true -- 281
			end -- 281
		until true -- 281
		return handlePlayableAttribute(cnode, enode, k, v) -- 283
	end -- 279
	getModel = function(enode) -- 285
		local node = Dora.Model(enode.props.file) -- 286
		if node ~= nil then -- 286
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 288
			return cnode -- 289
		end -- 289
		return nil -- 291
	end -- 285
end -- 285
local getDrawNode -- 295
do -- 295
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 297
		repeat -- 297
			local ____switch66 = k -- 297
			local ____cond66 = ____switch66 == "depthWrite" -- 297
			if ____cond66 then -- 297
				cnode.depthWrite = v -- 299
				return true -- 299
			end -- 299
			____cond66 = ____cond66 or ____switch66 == "blendFunc" -- 299
			if ____cond66 then -- 299
				cnode.blendFunc = v -- 300
				return true -- 300
			end -- 300
		until true -- 300
		return false -- 302
	end -- 297
	getDrawNode = function(enode) -- 304
		local node = Dora.DrawNode() -- 305
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 306
		local ____enode_5 = enode -- 307
		local children = ____enode_5.children -- 307
		for i = 1, #children do -- 307
			do -- 307
				local child = children[i] -- 309
				if type(child) ~= "table" then -- 309
					goto __continue68 -- 311
				end -- 311
				repeat -- 311
					local ____switch70 = child.type -- 311
					local ____cond70 = ____switch70 == "dot-shape" -- 311
					if ____cond70 then -- 311
						do -- 311
							local dot = child.props -- 315
							node:drawDot( -- 316
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 317
								dot.radius, -- 318
								Dora.Color(dot.color or 4294967295) -- 319
							) -- 319
							break -- 321
						end -- 321
					end -- 321
					____cond70 = ____cond70 or ____switch70 == "segment-shape" -- 321
					if ____cond70 then -- 321
						do -- 321
							local segment = child.props -- 324
							node:drawSegment( -- 325
								Dora.Vec2(segment.startX, segment.startY), -- 326
								Dora.Vec2(segment.stopX, segment.stopY), -- 327
								segment.radius, -- 328
								Dora.Color(segment.color or 4294967295) -- 329
							) -- 329
							break -- 331
						end -- 331
					end -- 331
					____cond70 = ____cond70 or ____switch70 == "rect-shape" -- 331
					if ____cond70 then -- 331
						do -- 331
							local rect = child.props -- 334
							local centerX = rect.centerX or 0 -- 335
							local centerY = rect.centerY or 0 -- 336
							local hw = rect.width / 2 -- 337
							local hh = rect.height / 2 -- 338
							node:drawPolygon( -- 339
								{ -- 340
									Dora.Vec2(centerX - hw, centerY + hh), -- 341
									Dora.Vec2(centerX + hw, centerY + hh), -- 342
									Dora.Vec2(centerX + hw, centerY - hh), -- 343
									Dora.Vec2(centerX - hw, centerY - hh) -- 344
								}, -- 344
								Dora.Color(rect.fillColor or 4294967295), -- 346
								rect.borderWidth or 0, -- 347
								Dora.Color(rect.borderColor or 4294967295) -- 348
							) -- 348
							break -- 350
						end -- 350
					end -- 350
					____cond70 = ____cond70 or ____switch70 == "polygon-shape" -- 350
					if ____cond70 then -- 350
						do -- 350
							local poly = child.props -- 353
							node:drawPolygon( -- 354
								poly.verts, -- 355
								Dora.Color(poly.fillColor or 4294967295), -- 356
								poly.borderWidth or 0, -- 357
								Dora.Color(poly.borderColor or 4294967295) -- 358
							) -- 358
							break -- 360
						end -- 360
					end -- 360
					____cond70 = ____cond70 or ____switch70 == "verts-shape" -- 360
					if ____cond70 then -- 360
						do -- 360
							local verts = child.props -- 363
							node:drawVertices(__TS__ArrayMap( -- 364
								verts.verts, -- 364
								function(____, ____bindingPattern0) -- 364
									local color -- 364
									local vert -- 364
									vert = ____bindingPattern0[1] -- 364
									color = ____bindingPattern0[2] -- 364
									return { -- 364
										vert, -- 364
										Dora.Color(color) -- 364
									} -- 364
								end -- 364
							)) -- 364
							break -- 365
						end -- 365
					end -- 365
				until true -- 365
			end -- 365
			::__continue68:: -- 365
		end -- 365
		return cnode -- 369
	end -- 304
end -- 304
local getGrid -- 373
do -- 373
	local function handleGridAttribute(cnode, _enode, k, v) -- 375
		repeat -- 375
			local ____switch79 = k -- 375
			local ____cond79 = ____switch79 == "file" or ____switch79 == "gridX" or ____switch79 == "gridY" -- 375
			if ____cond79 then -- 375
				return true -- 377
			end -- 377
			____cond79 = ____cond79 or ____switch79 == "textureRect" -- 377
			if ____cond79 then -- 377
				cnode.textureRect = v -- 378
				return true -- 378
			end -- 378
			____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 378
			if ____cond79 then -- 378
				cnode.depthWrite = v -- 379
				return true -- 379
			end -- 379
			____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 379
			if ____cond79 then -- 379
				cnode.blendFunc = v -- 380
				return true -- 380
			end -- 380
			____cond79 = ____cond79 or ____switch79 == "effect" -- 380
			if ____cond79 then -- 380
				cnode.effect = v -- 381
				return true -- 381
			end -- 381
		until true -- 381
		return false -- 383
	end -- 375
	getGrid = function(enode) -- 385
		local grid = enode.props -- 386
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 387
		local cnode = getNode(enode, node, handleGridAttribute) -- 388
		return cnode -- 389
	end -- 385
end -- 385
local getSprite -- 393
local getVideoNode -- 394
local getTIC80Node -- 395
do -- 395
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 397
		repeat -- 397
			local ____switch83 = k -- 397
			local ____cond83 = ____switch83 == "file" -- 397
			if ____cond83 then -- 397
				return true -- 399
			end -- 399
			____cond83 = ____cond83 or ____switch83 == "textureRect" -- 399
			if ____cond83 then -- 399
				cnode.textureRect = v -- 400
				return true -- 400
			end -- 400
			____cond83 = ____cond83 or ____switch83 == "depthWrite" -- 400
			if ____cond83 then -- 400
				cnode.depthWrite = v -- 401
				return true -- 401
			end -- 401
			____cond83 = ____cond83 or ____switch83 == "blendFunc" -- 401
			if ____cond83 then -- 401
				cnode.blendFunc = v -- 402
				return true -- 402
			end -- 402
			____cond83 = ____cond83 or ____switch83 == "effect" -- 402
			if ____cond83 then -- 402
				cnode.effect = v -- 403
				return true -- 403
			end -- 403
			____cond83 = ____cond83 or ____switch83 == "alphaRef" -- 403
			if ____cond83 then -- 403
				cnode.alphaRef = v -- 404
				return true -- 404
			end -- 404
			____cond83 = ____cond83 or ____switch83 == "uwrap" -- 404
			if ____cond83 then -- 404
				cnode.uwrap = v -- 405
				return true -- 405
			end -- 405
			____cond83 = ____cond83 or ____switch83 == "vwrap" -- 405
			if ____cond83 then -- 405
				cnode.vwrap = v -- 406
				return true -- 406
			end -- 406
			____cond83 = ____cond83 or ____switch83 == "filter" -- 406
			if ____cond83 then -- 406
				cnode.filter = v -- 407
				return true -- 407
			end -- 407
		until true -- 407
		return false -- 409
	end -- 397
	getSprite = function(enode) -- 411
		local sp = enode.props -- 412
		if sp.file then -- 412
			local node = Dora.Sprite(sp.file) -- 414
			if node ~= nil then -- 414
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 416
				return cnode -- 417
			end -- 417
		else -- 417
			local node = Dora.Sprite() -- 420
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 421
			return cnode -- 422
		end -- 422
		return nil -- 424
	end -- 411
	getVideoNode = function(enode) -- 426
		local vn = enode.props -- 427
		local ____Dora_VideoNode_8 = Dora.VideoNode -- 428
		local ____vn_file_7 = vn.file -- 428
		local ____vn_looped_6 = vn.looped -- 428
		if ____vn_looped_6 == nil then -- 428
			____vn_looped_6 = false -- 428
		end -- 428
		local node = ____Dora_VideoNode_8(____vn_file_7, ____vn_looped_6) -- 428
		if node ~= nil then -- 428
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 430
			return cnode -- 431
		end -- 431
		return nil -- 433
	end -- 426
	getTIC80Node = function(enode) -- 435
		local tic = enode.props -- 436
		local node = Dora.TIC80Node(tic.file) -- 437
		if node ~= nil then -- 437
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 439
			return cnode -- 440
		end -- 440
		return nil -- 442
	end -- 435
end -- 435
local getAudioSource -- 446
do -- 446
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 448
		repeat -- 448
			local ____switch94 = k -- 448
			local ____cond94 = ____switch94 == "file" -- 448
			if ____cond94 then -- 448
				return true -- 450
			end -- 450
			____cond94 = ____cond94 or ____switch94 == "autoRemove" -- 450
			if ____cond94 then -- 450
				return true -- 451
			end -- 451
			____cond94 = ____cond94 or ____switch94 == "bus" -- 451
			if ____cond94 then -- 451
				return true -- 452
			end -- 452
			____cond94 = ____cond94 or ____switch94 == "volume" -- 452
			if ____cond94 then -- 452
				cnode.volume = v -- 453
				return true -- 453
			end -- 453
			____cond94 = ____cond94 or ____switch94 == "pan" -- 453
			if ____cond94 then -- 453
				cnode.pan = v -- 454
				return true -- 454
			end -- 454
			____cond94 = ____cond94 or ____switch94 == "looping" -- 454
			if ____cond94 then -- 454
				cnode.looping = v -- 455
				return true -- 455
			end -- 455
			____cond94 = ____cond94 or ____switch94 == "playMode" -- 455
			if ____cond94 then -- 455
				do -- 455
					local aus = enode.props -- 457
					repeat -- 457
						local ____switch96 = v -- 457
						local ____cond96 = ____switch96 == "normal" -- 457
						if ____cond96 then -- 457
							cnode:play(aus.delayTime or 0) -- 459
							break -- 459
						end -- 459
						____cond96 = ____cond96 or ____switch96 == "background" -- 459
						if ____cond96 then -- 459
							cnode:playBackground() -- 460
							break -- 460
						end -- 460
						____cond96 = ____cond96 or ____switch96 == "3D" -- 460
						if ____cond96 then -- 460
							cnode:play3D(aus.delayTime or 0) -- 461
							break -- 461
						end -- 461
					until true -- 461
					return true -- 463
				end -- 463
			end -- 463
			____cond94 = ____cond94 or ____switch94 == "delayTime" -- 463
			if ____cond94 then -- 463
				return true -- 465
			end -- 465
			____cond94 = ____cond94 or ____switch94 == "protected" -- 465
			if ____cond94 then -- 465
				cnode:setProtected(v) -- 466
				return true -- 466
			end -- 466
			____cond94 = ____cond94 or ____switch94 == "loopPoint" -- 466
			if ____cond94 then -- 466
				cnode:setLoopPoint(v) -- 467
				return true -- 467
			end -- 467
			____cond94 = ____cond94 or ____switch94 == "velocity" -- 467
			if ____cond94 then -- 467
				do -- 467
					local vx, vy, vz = table.unpack(v, 1, 3) -- 469
					cnode:setVelocity(vx, vy, vz) -- 470
					return true -- 471
				end -- 471
			end -- 471
			____cond94 = ____cond94 or ____switch94 == "minMaxDistance" -- 471
			if ____cond94 then -- 471
				do -- 471
					local min, max = table.unpack(v, 1, 2) -- 474
					cnode:setMinMaxDistance(min, max) -- 475
					return true -- 476
				end -- 476
			end -- 476
			____cond94 = ____cond94 or ____switch94 == "attenuation" -- 476
			if ____cond94 then -- 476
				do -- 476
					local model, factor = table.unpack(v, 1, 2) -- 479
					cnode:setAttenuation(model, factor) -- 480
					return true -- 481
				end -- 481
			end -- 481
			____cond94 = ____cond94 or ____switch94 == "dopplerFactor" -- 481
			if ____cond94 then -- 481
				cnode:setDopplerFactor(v) -- 483
				return true -- 483
			end -- 483
		until true -- 483
		return false -- 485
	end -- 448
	getAudioSource = function(enode) -- 487
		local aus = enode.props -- 488
		local ____aus_autoRemove_9 = aus.autoRemove -- 489
		if ____aus_autoRemove_9 == nil then -- 489
			____aus_autoRemove_9 = true -- 489
		end -- 489
		local autoRemove = ____aus_autoRemove_9 -- 489
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 490
		if node ~= nil then -- 490
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 492
			return cnode -- 493
		end -- 493
		return nil -- 495
	end -- 487
end -- 487
local getLabel -- 499
do -- 499
	local function handleLabelAttribute(cnode, _enode, k, v) -- 501
		repeat -- 501
			local ____switch104 = k -- 501
			local ____cond104 = ____switch104 == "fontName" or ____switch104 == "fontSize" or ____switch104 == "text" or ____switch104 == "smoothLower" or ____switch104 == "smoothUpper" -- 501
			if ____cond104 then -- 501
				return true -- 503
			end -- 503
			____cond104 = ____cond104 or ____switch104 == "alphaRef" -- 503
			if ____cond104 then -- 503
				cnode.alphaRef = v -- 504
				return true -- 504
			end -- 504
			____cond104 = ____cond104 or ____switch104 == "textWidth" -- 504
			if ____cond104 then -- 504
				cnode.textWidth = v -- 505
				return true -- 505
			end -- 505
			____cond104 = ____cond104 or ____switch104 == "lineGap" -- 505
			if ____cond104 then -- 505
				cnode.lineGap = v -- 506
				return true -- 506
			end -- 506
			____cond104 = ____cond104 or ____switch104 == "spacing" -- 506
			if ____cond104 then -- 506
				cnode.spacing = v -- 507
				return true -- 507
			end -- 507
			____cond104 = ____cond104 or ____switch104 == "outlineColor" -- 507
			if ____cond104 then -- 507
				cnode.outlineColor = Dora.Color(v) -- 508
				return true -- 508
			end -- 508
			____cond104 = ____cond104 or ____switch104 == "outlineWidth" -- 508
			if ____cond104 then -- 508
				cnode.outlineWidth = v -- 509
				return true -- 509
			end -- 509
			____cond104 = ____cond104 or ____switch104 == "blendFunc" -- 509
			if ____cond104 then -- 509
				cnode.blendFunc = v -- 510
				return true -- 510
			end -- 510
			____cond104 = ____cond104 or ____switch104 == "depthWrite" -- 510
			if ____cond104 then -- 510
				cnode.depthWrite = v -- 511
				return true -- 511
			end -- 511
			____cond104 = ____cond104 or ____switch104 == "batched" -- 511
			if ____cond104 then -- 511
				cnode.batched = v -- 512
				return true -- 512
			end -- 512
			____cond104 = ____cond104 or ____switch104 == "effect" -- 512
			if ____cond104 then -- 512
				cnode.effect = v -- 513
				return true -- 513
			end -- 513
			____cond104 = ____cond104 or ____switch104 == "alignment" -- 513
			if ____cond104 then -- 513
				cnode.alignment = v -- 514
				return true -- 514
			end -- 514
		until true -- 514
		return false -- 516
	end -- 501
	getLabel = function(enode) -- 518
		local label = enode.props -- 519
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 520
		if node ~= nil then -- 520
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 520
				local ____node_smooth_10 = node.smooth -- 523
				local x = ____node_smooth_10.x -- 523
				local y = ____node_smooth_10.y -- 523
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 524
			end -- 524
			local cnode = getNode(enode, node, handleLabelAttribute) -- 526
			local ____enode_11 = enode -- 527
			local children = ____enode_11.children -- 527
			local text = label.text or "" -- 528
			for i = 1, #children do -- 528
				local child = children[i] -- 530
				if type(child) ~= "table" then -- 530
					text = text .. tostring(child) -- 532
				end -- 532
			end -- 532
			node.text = text -- 535
			return cnode -- 536
		end -- 536
		return nil -- 538
	end -- 518
end -- 518
local getLine -- 542
do -- 542
	local function handleLineAttribute(cnode, enode, k, v) -- 544
		local line = enode.props -- 545
		repeat -- 545
			local ____switch112 = k -- 545
			local ____cond112 = ____switch112 == "verts" -- 545
			if ____cond112 then -- 545
				cnode:set( -- 547
					v, -- 547
					Dora.Color(line.lineColor or 4294967295) -- 547
				) -- 547
				return true -- 547
			end -- 547
			____cond112 = ____cond112 or ____switch112 == "depthWrite" -- 547
			if ____cond112 then -- 547
				cnode.depthWrite = v -- 548
				return true -- 548
			end -- 548
			____cond112 = ____cond112 or ____switch112 == "blendFunc" -- 548
			if ____cond112 then -- 548
				cnode.blendFunc = v -- 549
				return true -- 549
			end -- 549
		until true -- 549
		return false -- 551
	end -- 544
	getLine = function(enode) -- 553
		local node = Dora.Line() -- 554
		local cnode = getNode(enode, node, handleLineAttribute) -- 555
		return cnode -- 556
	end -- 553
end -- 553
local getParticle -- 560
do -- 560
	local function handleParticleAttribute(cnode, _enode, k, v) -- 562
		repeat -- 562
			local ____switch116 = k -- 562
			local ____cond116 = ____switch116 == "file" -- 562
			if ____cond116 then -- 562
				return true -- 564
			end -- 564
			____cond116 = ____cond116 or ____switch116 == "emit" -- 564
			if ____cond116 then -- 564
				if v then -- 564
					cnode:start() -- 565
				end -- 565
				return true -- 565
			end -- 565
			____cond116 = ____cond116 or ____switch116 == "onFinished" -- 565
			if ____cond116 then -- 565
				cnode:slot("Finished", v) -- 566
				return true -- 566
			end -- 566
		until true -- 566
		return false -- 568
	end -- 562
	getParticle = function(enode) -- 570
		local particle = enode.props -- 571
		local node = Dora.Particle(particle.file) -- 572
		if node ~= nil then -- 572
			local cnode = getNode(enode, node, handleParticleAttribute) -- 574
			return cnode -- 575
		end -- 575
		return nil -- 577
	end -- 570
end -- 570
local getMenu -- 581
do -- 581
	local function handleMenuAttribute(cnode, _enode, k, v) -- 583
		repeat -- 583
			local ____switch122 = k -- 583
			local ____cond122 = ____switch122 == "enabled" -- 583
			if ____cond122 then -- 583
				cnode.enabled = v -- 585
				return true -- 585
			end -- 585
		until true -- 585
		return false -- 587
	end -- 583
	getMenu = function(enode) -- 589
		local node = Dora.Menu() -- 590
		local cnode = getNode(enode, node, handleMenuAttribute) -- 591
		return cnode -- 592
	end -- 589
end -- 589
local function getPhysicsWorld(enode) -- 596
	local node = Dora.PhysicsWorld() -- 597
	local cnode = getNode(enode, node) -- 598
	return cnode -- 599
end -- 596
local getBody -- 602
do -- 602
	local function handleBodyAttribute(cnode, _enode, k, v) -- 604
		repeat -- 604
			local ____switch127 = k -- 604
			local ____cond127 = ____switch127 == "type" or ____switch127 == "linearAcceleration" or ____switch127 == "fixedRotation" or ____switch127 == "bullet" or ____switch127 == "world" -- 604
			if ____cond127 then -- 604
				return true -- 611
			end -- 611
			____cond127 = ____cond127 or ____switch127 == "velocityX" -- 611
			if ____cond127 then -- 611
				cnode.velocityX = v -- 612
				return true -- 612
			end -- 612
			____cond127 = ____cond127 or ____switch127 == "velocityY" -- 612
			if ____cond127 then -- 612
				cnode.velocityY = v -- 613
				return true -- 613
			end -- 613
			____cond127 = ____cond127 or ____switch127 == "angularRate" -- 613
			if ____cond127 then -- 613
				cnode.angularRate = v -- 614
				return true -- 614
			end -- 614
			____cond127 = ____cond127 or ____switch127 == "group" -- 614
			if ____cond127 then -- 614
				cnode.group = v -- 615
				return true -- 615
			end -- 615
			____cond127 = ____cond127 or ____switch127 == "linearDamping" -- 615
			if ____cond127 then -- 615
				cnode.linearDamping = v -- 616
				return true -- 616
			end -- 616
			____cond127 = ____cond127 or ____switch127 == "angularDamping" -- 616
			if ____cond127 then -- 616
				cnode.angularDamping = v -- 617
				return true -- 617
			end -- 617
			____cond127 = ____cond127 or ____switch127 == "owner" -- 617
			if ____cond127 then -- 617
				cnode.owner = v -- 618
				return true -- 618
			end -- 618
			____cond127 = ____cond127 or ____switch127 == "receivingContact" -- 618
			if ____cond127 then -- 618
				cnode.receivingContact = v -- 619
				return true -- 619
			end -- 619
			____cond127 = ____cond127 or ____switch127 == "onBodyEnter" -- 619
			if ____cond127 then -- 619
				cnode:slot("BodyEnter", v) -- 620
				return true -- 620
			end -- 620
			____cond127 = ____cond127 or ____switch127 == "onBodyLeave" -- 620
			if ____cond127 then -- 620
				cnode:slot("BodyLeave", v) -- 621
				return true -- 621
			end -- 621
			____cond127 = ____cond127 or ____switch127 == "onContactStart" -- 621
			if ____cond127 then -- 621
				cnode:slot("ContactStart", v) -- 622
				return true -- 622
			end -- 622
			____cond127 = ____cond127 or ____switch127 == "onContactEnd" -- 622
			if ____cond127 then -- 622
				cnode:slot("ContactEnd", v) -- 623
				return true -- 623
			end -- 623
			____cond127 = ____cond127 or ____switch127 == "onContactFilter" -- 623
			if ____cond127 then -- 623
				cnode:onContactFilter(v) -- 624
				return true -- 624
			end -- 624
		until true -- 624
		return false -- 626
	end -- 604
	getBody = function(enode, world) -- 628
		local def = enode.props -- 629
		local bodyDef = Dora.BodyDef() -- 630
		bodyDef.type = def.type -- 631
		if def.angle ~= nil then -- 631
			bodyDef.angle = def.angle -- 632
		end -- 632
		if def.angularDamping ~= nil then -- 632
			bodyDef.angularDamping = def.angularDamping -- 633
		end -- 633
		if def.bullet ~= nil then -- 633
			bodyDef.bullet = def.bullet -- 634
		end -- 634
		if def.fixedRotation ~= nil then -- 634
			bodyDef.fixedRotation = def.fixedRotation -- 635
		end -- 635
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 636
		if def.linearDamping ~= nil then -- 636
			bodyDef.linearDamping = def.linearDamping -- 637
		end -- 637
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 638
		local extraSensors -- 639
		for i = 1, #enode.children do -- 639
			do -- 639
				local child = enode.children[i] -- 641
				if type(child) ~= "table" then -- 641
					goto __continue134 -- 643
				end -- 643
				repeat -- 643
					local ____switch136 = child.type -- 643
					local ____cond136 = ____switch136 == "rect-fixture" -- 643
					if ____cond136 then -- 643
						do -- 643
							local shape = child.props -- 647
							if shape.sensorTag ~= nil then -- 647
								bodyDef:attachPolygonSensor( -- 649
									shape.sensorTag, -- 650
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 651
									shape.width, -- 652
									shape.height, -- 652
									shape.angle or 0 -- 653
								) -- 653
							else -- 653
								bodyDef:attachPolygon( -- 656
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 657
									shape.width, -- 658
									shape.height, -- 658
									shape.angle or 0, -- 659
									shape.density or 1, -- 660
									shape.friction or 0.4, -- 661
									shape.restitution or 0 -- 662
								) -- 662
							end -- 662
							break -- 665
						end -- 665
					end -- 665
					____cond136 = ____cond136 or ____switch136 == "polygon-fixture" -- 665
					if ____cond136 then -- 665
						do -- 665
							local shape = child.props -- 668
							if shape.sensorTag ~= nil then -- 668
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 670
							else -- 670
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 675
							end -- 675
							break -- 682
						end -- 682
					end -- 682
					____cond136 = ____cond136 or ____switch136 == "multi-fixture" -- 682
					if ____cond136 then -- 682
						do -- 682
							local shape = child.props -- 685
							if shape.sensorTag ~= nil then -- 685
								if extraSensors == nil then -- 685
									extraSensors = {} -- 687
								end -- 687
								extraSensors[#extraSensors + 1] = { -- 688
									shape.sensorTag, -- 688
									Dora.BodyDef:multi(shape.verts) -- 688
								} -- 688
							else -- 688
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 690
							end -- 690
							break -- 697
						end -- 697
					end -- 697
					____cond136 = ____cond136 or ____switch136 == "disk-fixture" -- 697
					if ____cond136 then -- 697
						do -- 697
							local shape = child.props -- 700
							if shape.sensorTag ~= nil then -- 700
								bodyDef:attachDiskSensor( -- 702
									shape.sensorTag, -- 703
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 704
									shape.radius -- 705
								) -- 705
							else -- 705
								bodyDef:attachDisk( -- 708
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 709
									shape.radius, -- 710
									shape.density or 1, -- 711
									shape.friction or 0.4, -- 712
									shape.restitution or 0 -- 713
								) -- 713
							end -- 713
							break -- 716
						end -- 716
					end -- 716
					____cond136 = ____cond136 or ____switch136 == "chain-fixture" -- 716
					if ____cond136 then -- 716
						do -- 716
							local shape = child.props -- 719
							if shape.sensorTag ~= nil then -- 719
								if extraSensors == nil then -- 719
									extraSensors = {} -- 721
								end -- 721
								extraSensors[#extraSensors + 1] = { -- 722
									shape.sensorTag, -- 722
									Dora.BodyDef:chain(shape.verts) -- 722
								} -- 722
							else -- 722
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 724
							end -- 724
							break -- 730
						end -- 730
					end -- 730
				until true -- 730
			end -- 730
			::__continue134:: -- 730
		end -- 730
		local body = Dora.Body(bodyDef, world) -- 734
		if extraSensors ~= nil then -- 734
			for i = 1, #extraSensors do -- 734
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 737
				body:attachSensor(tag, def) -- 738
			end -- 738
		end -- 738
		local cnode = getNode(enode, body, handleBodyAttribute) -- 741
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 741
			body.receivingContact = true -- 746
		end -- 746
		return cnode -- 748
	end -- 628
end -- 628
local getCustomNode -- 752
do -- 752
	local function handleCustomNode(_cnode, _enode, k, _v) -- 754
		repeat -- 754
			local ____switch157 = k -- 754
			local ____cond157 = ____switch157 == "onCreate" -- 754
			if ____cond157 then -- 754
				return true -- 756
			end -- 756
		until true -- 756
		return false -- 758
	end -- 754
	getCustomNode = function(enode) -- 760
		local custom = enode.props -- 761
		local node = custom.onCreate() -- 762
		if node then -- 762
			local cnode = getNode(enode, node, handleCustomNode) -- 764
			return cnode -- 765
		end -- 765
		return nil -- 767
	end -- 760
end -- 760
local getAlignNode -- 771
do -- 771
	local function handleAlignNode(_cnode, _enode, k, _v) -- 773
		repeat -- 773
			local ____switch162 = k -- 773
			local ____cond162 = ____switch162 == "windowRoot" -- 773
			if ____cond162 then -- 773
				return true -- 775
			end -- 775
			____cond162 = ____cond162 or ____switch162 == "style" -- 775
			if ____cond162 then -- 775
				return true -- 776
			end -- 776
			____cond162 = ____cond162 or ____switch162 == "onLayout" -- 776
			if ____cond162 then -- 776
				return true -- 777
			end -- 777
		until true -- 777
		return false -- 779
	end -- 773
	getAlignNode = function(enode) -- 781
		local alignNode = enode.props -- 782
		local node = Dora.AlignNode(alignNode.windowRoot) -- 783
		if alignNode.style then -- 783
			local items = {} -- 785
			for k, v in pairs(alignNode.style) do -- 786
				local name = string.gsub(k, "%u", "-%1") -- 787
				name = string.lower(name) -- 788
				repeat -- 788
					local ____switch166 = k -- 788
					local ____cond166 = ____switch166 == "margin" or ____switch166 == "padding" or ____switch166 == "border" or ____switch166 == "gap" -- 788
					if ____cond166 then -- 788
						do -- 788
							if type(v) == "table" then -- 788
								local valueStr = table.concat( -- 793
									__TS__ArrayMap( -- 793
										v, -- 793
										function(____, item) return tostring(item) end -- 793
									), -- 793
									"," -- 793
								) -- 793
								items[#items + 1] = (name .. ":") .. valueStr -- 794
							else -- 794
								items[#items + 1] = (name .. ":") .. tostring(v) -- 796
							end -- 796
							break -- 798
						end -- 798
					end -- 798
					do -- 798
						items[#items + 1] = (name .. ":") .. tostring(v) -- 801
						break -- 802
					end -- 802
				until true -- 802
			end -- 802
			local styleStr = table.concat(items, ";") -- 805
			node:css(styleStr) -- 806
		end -- 806
		if alignNode.onLayout then -- 806
			node:slot("AlignLayout", alignNode.onLayout) -- 809
		end -- 809
		local cnode = getNode(enode, node, handleAlignNode) -- 811
		return cnode -- 812
	end -- 781
end -- 781
local function getEffekNode(enode) -- 816
	return getNode( -- 817
		enode, -- 817
		Dora.EffekNode() -- 817
	) -- 817
end -- 816
local getTileNode -- 820
do -- 820
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 822
		repeat -- 822
			local ____switch175 = k -- 822
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 822
			if ____cond175 then -- 822
				return true -- 824
			end -- 824
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 824
			if ____cond175 then -- 824
				cnode.depthWrite = v -- 825
				return true -- 825
			end -- 825
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 825
			if ____cond175 then -- 825
				cnode.blendFunc = v -- 826
				return true -- 826
			end -- 826
			____cond175 = ____cond175 or ____switch175 == "effect" -- 826
			if ____cond175 then -- 826
				cnode.effect = v -- 827
				return true -- 827
			end -- 827
			____cond175 = ____cond175 or ____switch175 == "filter" -- 827
			if ____cond175 then -- 827
				cnode.filter = v -- 828
				return true -- 828
			end -- 828
		until true -- 828
		return false -- 830
	end -- 822
	getTileNode = function(enode) -- 832
		local tn = enode.props -- 833
		local ____tn_layers_12 -- 834
		if tn.layers then -- 834
			____tn_layers_12 = Dora.TileNode(tn.file, tn.layers) -- 834
		else -- 834
			____tn_layers_12 = Dora.TileNode(tn.file) -- 834
		end -- 834
		local node = ____tn_layers_12 -- 834
		if node ~= nil then -- 834
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 836
			return cnode -- 837
		end -- 837
		return nil -- 839
	end -- 832
end -- 832
local function addChild(nodeStack, cnode, enode) -- 843
	if #nodeStack > 0 then -- 843
		local last = nodeStack[#nodeStack] -- 845
		last:addChild(cnode) -- 846
	end -- 846
	nodeStack[#nodeStack + 1] = cnode -- 848
	local ____enode_13 = enode -- 849
	local children = ____enode_13.children -- 849
	for i = 1, #children do -- 849
		visitNode(nodeStack, children[i], enode) -- 851
	end -- 851
	if #nodeStack > 1 then -- 851
		table.remove(nodeStack) -- 854
	end -- 854
end -- 843
local function drawNodeCheck(_nodeStack, enode, parent) -- 862
	if parent == nil or parent.type ~= "draw-node" then -- 862
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 864
	end -- 864
end -- 862
local function visitAction(actionStack, enode) -- 868
	local createAction = actionMap[enode.type] -- 869
	if createAction ~= nil then -- 869
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 871
		return -- 872
	end -- 872
	repeat -- 872
		local ____switch186 = enode.type -- 872
		local ____cond186 = ____switch186 == "delay" -- 872
		if ____cond186 then -- 872
			do -- 872
				local item = enode.props -- 876
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 877
				break -- 878
			end -- 878
		end -- 878
		____cond186 = ____cond186 or ____switch186 == "event" -- 878
		if ____cond186 then -- 878
			do -- 878
				local item = enode.props -- 881
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 882
				break -- 883
			end -- 883
		end -- 883
		____cond186 = ____cond186 or ____switch186 == "hide" -- 883
		if ____cond186 then -- 883
			do -- 883
				actionStack[#actionStack + 1] = Dora.Hide() -- 886
				break -- 887
			end -- 887
		end -- 887
		____cond186 = ____cond186 or ____switch186 == "show" -- 887
		if ____cond186 then -- 887
			do -- 887
				actionStack[#actionStack + 1] = Dora.Show() -- 890
				break -- 891
			end -- 891
		end -- 891
		____cond186 = ____cond186 or ____switch186 == "move" -- 891
		if ____cond186 then -- 891
			do -- 891
				local item = enode.props -- 894
				actionStack[#actionStack + 1] = Dora.Move( -- 895
					item.time, -- 895
					Dora.Vec2(item.startX, item.startY), -- 895
					Dora.Vec2(item.stopX, item.stopY), -- 895
					item.easing -- 895
				) -- 895
				break -- 896
			end -- 896
		end -- 896
		____cond186 = ____cond186 or ____switch186 == "frame" -- 896
		if ____cond186 then -- 896
			do -- 896
				local item = enode.props -- 899
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 900
				break -- 901
			end -- 901
		end -- 901
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 901
		if ____cond186 then -- 901
			do -- 901
				local spawnStack = {} -- 904
				for i = 1, #enode.children do -- 904
					visitAction(spawnStack, enode.children[i]) -- 906
				end -- 906
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 908
				break -- 909
			end -- 909
		end -- 909
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 909
		if ____cond186 then -- 909
			do -- 909
				local sequenceStack = {} -- 912
				for i = 1, #enode.children do -- 912
					visitAction(sequenceStack, enode.children[i]) -- 914
				end -- 914
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 916
				break -- 917
			end -- 917
		end -- 917
		do -- 917
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 920
			break -- 921
		end -- 921
	until true -- 921
end -- 868
local function actionCheck(nodeStack, enode, parent) -- 925
	local unsupported = false -- 926
	if parent == nil then -- 926
		unsupported = true -- 928
	else -- 928
		repeat -- 928
			local ____switch200 = parent.type -- 928
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 928
			if ____cond200 then -- 928
				break -- 931
			end -- 931
			do -- 931
				unsupported = true -- 932
				break -- 932
			end -- 932
		until true -- 932
	end -- 932
	if unsupported then -- 932
		if #nodeStack > 0 then -- 932
			local node = nodeStack[#nodeStack] -- 937
			local actionStack = {} -- 938
			visitAction(actionStack, enode) -- 939
			if #actionStack == 1 then -- 939
				node:runAction(actionStack[1]) -- 941
			end -- 941
		else -- 941
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 944
		end -- 944
	end -- 944
end -- 925
local function bodyCheck(_nodeStack, enode, parent) -- 949
	if parent == nil or parent.type ~= "body" then -- 949
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 951
	end -- 951
end -- 949
actionMap = { -- 955
	["anchor-x"] = Dora.AnchorX, -- 958
	["anchor-y"] = Dora.AnchorY, -- 959
	angle = Dora.Angle, -- 960
	["angle-x"] = Dora.AngleX, -- 961
	["angle-y"] = Dora.AngleY, -- 962
	width = Dora.Width, -- 963
	height = Dora.Height, -- 964
	opacity = Dora.Opacity, -- 965
	roll = Dora.Roll, -- 966
	scale = Dora.Scale, -- 967
	["scale-x"] = Dora.ScaleX, -- 968
	["scale-y"] = Dora.ScaleY, -- 969
	["skew-x"] = Dora.SkewX, -- 970
	["skew-y"] = Dora.SkewY, -- 971
	["move-x"] = Dora.X, -- 972
	["move-y"] = Dora.Y, -- 973
	["move-z"] = Dora.Z -- 974
} -- 974
elementMap = { -- 977
	node = function(nodeStack, enode, parent) -- 978
		addChild( -- 979
			nodeStack, -- 979
			getNode(enode), -- 979
			enode -- 979
		) -- 979
	end, -- 978
	["clip-node"] = function(nodeStack, enode, parent) -- 981
		addChild( -- 982
			nodeStack, -- 982
			getClipNode(enode), -- 982
			enode -- 982
		) -- 982
	end, -- 981
	playable = function(nodeStack, enode, parent) -- 984
		local cnode = getPlayable(enode) -- 985
		if cnode ~= nil then -- 985
			addChild(nodeStack, cnode, enode) -- 987
		end -- 987
	end, -- 984
	["dragon-bone"] = function(nodeStack, enode, parent) -- 990
		local cnode = getDragonBone(enode) -- 991
		if cnode ~= nil then -- 991
			addChild(nodeStack, cnode, enode) -- 993
		end -- 993
	end, -- 990
	spine = function(nodeStack, enode, parent) -- 996
		local cnode = getSpine(enode) -- 997
		if cnode ~= nil then -- 997
			addChild(nodeStack, cnode, enode) -- 999
		end -- 999
	end, -- 996
	model = function(nodeStack, enode, parent) -- 1002
		local cnode = getModel(enode) -- 1003
		if cnode ~= nil then -- 1003
			addChild(nodeStack, cnode, enode) -- 1005
		end -- 1005
	end, -- 1002
	["draw-node"] = function(nodeStack, enode, parent) -- 1008
		addChild( -- 1009
			nodeStack, -- 1009
			getDrawNode(enode), -- 1009
			enode -- 1009
		) -- 1009
	end, -- 1008
	["dot-shape"] = drawNodeCheck, -- 1011
	["segment-shape"] = drawNodeCheck, -- 1012
	["rect-shape"] = drawNodeCheck, -- 1013
	["polygon-shape"] = drawNodeCheck, -- 1014
	["verts-shape"] = drawNodeCheck, -- 1015
	grid = function(nodeStack, enode, parent) -- 1016
		addChild( -- 1017
			nodeStack, -- 1017
			getGrid(enode), -- 1017
			enode -- 1017
		) -- 1017
	end, -- 1016
	sprite = function(nodeStack, enode, parent) -- 1019
		local cnode = getSprite(enode) -- 1020
		if cnode ~= nil then -- 1020
			addChild(nodeStack, cnode, enode) -- 1022
		end -- 1022
	end, -- 1019
	["audio-source"] = function(nodeStack, enode, parent) -- 1025
		local cnode = getAudioSource(enode) -- 1026
		if cnode ~= nil then -- 1026
			addChild(nodeStack, cnode, enode) -- 1028
		end -- 1028
	end, -- 1025
	["video-node"] = function(nodeStack, enode, parent) -- 1031
		local cnode = getVideoNode(enode) -- 1032
		if cnode ~= nil then -- 1032
			addChild(nodeStack, cnode, enode) -- 1034
		end -- 1034
	end, -- 1031
	["tic80-node"] = function(nodeStack, enode, parent) -- 1037
		local cnode = getTIC80Node(enode) -- 1038
		if cnode ~= nil then -- 1038
			addChild(nodeStack, cnode, enode) -- 1040
		end -- 1040
	end, -- 1037
	label = function(nodeStack, enode, parent) -- 1043
		local cnode = getLabel(enode) -- 1044
		if cnode ~= nil then -- 1044
			addChild(nodeStack, cnode, enode) -- 1046
		end -- 1046
	end, -- 1043
	line = function(nodeStack, enode, parent) -- 1049
		addChild( -- 1050
			nodeStack, -- 1050
			getLine(enode), -- 1050
			enode -- 1050
		) -- 1050
	end, -- 1049
	particle = function(nodeStack, enode, parent) -- 1052
		local cnode = getParticle(enode) -- 1053
		if cnode ~= nil then -- 1053
			addChild(nodeStack, cnode, enode) -- 1055
		end -- 1055
	end, -- 1052
	menu = function(nodeStack, enode, parent) -- 1058
		addChild( -- 1059
			nodeStack, -- 1059
			getMenu(enode), -- 1059
			enode -- 1059
		) -- 1059
	end, -- 1058
	action = function(_nodeStack, enode, parent) -- 1061
		if #enode.children == 0 then -- 1061
			Warn("<action> tag has no children") -- 1063
			return -- 1064
		end -- 1064
		local action = enode.props -- 1066
		if action.ref == nil then -- 1066
			Warn("<action> tag has no ref") -- 1068
			return -- 1069
		end -- 1069
		local actionStack = {} -- 1071
		for i = 1, #enode.children do -- 1071
			visitAction(actionStack, enode.children[i]) -- 1073
		end -- 1073
		if #actionStack == 1 then -- 1073
			action.ref.current = actionStack[1] -- 1076
		elseif #actionStack > 1 then -- 1076
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1078
		end -- 1078
	end, -- 1061
	["anchor-x"] = actionCheck, -- 1081
	["anchor-y"] = actionCheck, -- 1082
	angle = actionCheck, -- 1083
	["angle-x"] = actionCheck, -- 1084
	["angle-y"] = actionCheck, -- 1085
	delay = actionCheck, -- 1086
	event = actionCheck, -- 1087
	width = actionCheck, -- 1088
	height = actionCheck, -- 1089
	hide = actionCheck, -- 1090
	show = actionCheck, -- 1091
	move = actionCheck, -- 1092
	opacity = actionCheck, -- 1093
	roll = actionCheck, -- 1094
	scale = actionCheck, -- 1095
	["scale-x"] = actionCheck, -- 1096
	["scale-y"] = actionCheck, -- 1097
	["skew-x"] = actionCheck, -- 1098
	["skew-y"] = actionCheck, -- 1099
	["move-x"] = actionCheck, -- 1100
	["move-y"] = actionCheck, -- 1101
	["move-z"] = actionCheck, -- 1102
	frame = actionCheck, -- 1103
	spawn = actionCheck, -- 1104
	sequence = actionCheck, -- 1105
	loop = function(nodeStack, enode, _parent) -- 1106
		if #nodeStack > 0 then -- 1106
			local node = nodeStack[#nodeStack] -- 1108
			local actionStack = {} -- 1109
			for i = 1, #enode.children do -- 1109
				visitAction(actionStack, enode.children[i]) -- 1111
			end -- 1111
			if #actionStack == 1 then -- 1111
				node:runAction(actionStack[1], true) -- 1114
			else -- 1114
				local loop = enode.props -- 1116
				if loop.spawn then -- 1116
					node:runAction( -- 1118
						Dora.Spawn(table.unpack(actionStack)), -- 1118
						true -- 1118
					) -- 1118
				else -- 1118
					node:runAction( -- 1120
						Dora.Sequence(table.unpack(actionStack)), -- 1120
						true -- 1120
					) -- 1120
				end -- 1120
			end -- 1120
		else -- 1120
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1124
		end -- 1124
	end, -- 1106
	["physics-world"] = function(nodeStack, enode, _parent) -- 1127
		addChild( -- 1128
			nodeStack, -- 1128
			getPhysicsWorld(enode), -- 1128
			enode -- 1128
		) -- 1128
	end, -- 1127
	contact = function(nodeStack, enode, _parent) -- 1130
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1131
		if world ~= nil then -- 1131
			local contact = enode.props -- 1133
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1134
		else -- 1134
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1136
		end -- 1136
	end, -- 1130
	body = function(nodeStack, enode, _parent) -- 1139
		local def = enode.props -- 1140
		if def.world then -- 1140
			addChild( -- 1142
				nodeStack, -- 1142
				getBody(enode, def.world), -- 1142
				enode -- 1142
			) -- 1142
			return -- 1143
		end -- 1143
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1145
		if world ~= nil then -- 1145
			addChild( -- 1147
				nodeStack, -- 1147
				getBody(enode, world), -- 1147
				enode -- 1147
			) -- 1147
		else -- 1147
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1149
		end -- 1149
	end, -- 1139
	["rect-fixture"] = bodyCheck, -- 1152
	["polygon-fixture"] = bodyCheck, -- 1153
	["multi-fixture"] = bodyCheck, -- 1154
	["disk-fixture"] = bodyCheck, -- 1155
	["chain-fixture"] = bodyCheck, -- 1156
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1157
		local joint = enode.props -- 1158
		if joint.ref == nil then -- 1158
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1160
			return -- 1161
		end -- 1161
		if joint.bodyA.current == nil then -- 1161
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1164
			return -- 1165
		end -- 1165
		if joint.bodyB.current == nil then -- 1165
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1168
			return -- 1169
		end -- 1169
		local ____joint_ref_17 = joint.ref -- 1171
		local ____self_15 = Dora.Joint -- 1171
		local ____self_15_distance_16 = ____self_15.distance -- 1171
		local ____joint_canCollide_14 = joint.canCollide -- 1172
		if ____joint_canCollide_14 == nil then -- 1172
			____joint_canCollide_14 = false -- 1172
		end -- 1172
		____joint_ref_17.current = ____self_15_distance_16( -- 1171
			____self_15, -- 1171
			____joint_canCollide_14, -- 1172
			joint.bodyA.current, -- 1173
			joint.bodyB.current, -- 1174
			joint.anchorA or Dora.Vec2.zero, -- 1175
			joint.anchorB or Dora.Vec2.zero, -- 1176
			joint.frequency or 0, -- 1177
			joint.damping or 0 -- 1178
		) -- 1178
	end, -- 1157
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1180
		local joint = enode.props -- 1181
		if joint.ref == nil then -- 1181
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1183
			return -- 1184
		end -- 1184
		if joint.bodyA.current == nil then -- 1184
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1187
			return -- 1188
		end -- 1188
		if joint.bodyB.current == nil then -- 1188
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1191
			return -- 1192
		end -- 1192
		local ____joint_ref_21 = joint.ref -- 1194
		local ____self_19 = Dora.Joint -- 1194
		local ____self_19_friction_20 = ____self_19.friction -- 1194
		local ____joint_canCollide_18 = joint.canCollide -- 1195
		if ____joint_canCollide_18 == nil then -- 1195
			____joint_canCollide_18 = false -- 1195
		end -- 1195
		____joint_ref_21.current = ____self_19_friction_20( -- 1194
			____self_19, -- 1194
			____joint_canCollide_18, -- 1195
			joint.bodyA.current, -- 1196
			joint.bodyB.current, -- 1197
			joint.worldPos, -- 1198
			joint.maxForce, -- 1199
			joint.maxTorque -- 1200
		) -- 1200
	end, -- 1180
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1203
		local joint = enode.props -- 1204
		if joint.ref == nil then -- 1204
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1206
			return -- 1207
		end -- 1207
		if joint.jointA.current == nil then -- 1207
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1210
			return -- 1211
		end -- 1211
		if joint.jointB.current == nil then -- 1211
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1214
			return -- 1215
		end -- 1215
		local ____joint_ref_25 = joint.ref -- 1217
		local ____self_23 = Dora.Joint -- 1217
		local ____self_23_gear_24 = ____self_23.gear -- 1217
		local ____joint_canCollide_22 = joint.canCollide -- 1218
		if ____joint_canCollide_22 == nil then -- 1218
			____joint_canCollide_22 = false -- 1218
		end -- 1218
		____joint_ref_25.current = ____self_23_gear_24( -- 1217
			____self_23, -- 1217
			____joint_canCollide_22, -- 1218
			joint.jointA.current, -- 1219
			joint.jointB.current, -- 1220
			joint.ratio or 1 -- 1221
		) -- 1221
	end, -- 1203
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1224
		local joint = enode.props -- 1225
		if joint.ref == nil then -- 1225
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1227
			return -- 1228
		end -- 1228
		if joint.bodyA.current == nil then -- 1228
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1231
			return -- 1232
		end -- 1232
		if joint.bodyB.current == nil then -- 1232
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1235
			return -- 1236
		end -- 1236
		local ____joint_ref_29 = joint.ref -- 1238
		local ____self_27 = Dora.Joint -- 1238
		local ____self_27_spring_28 = ____self_27.spring -- 1238
		local ____joint_canCollide_26 = joint.canCollide -- 1239
		if ____joint_canCollide_26 == nil then -- 1239
			____joint_canCollide_26 = false -- 1239
		end -- 1239
		____joint_ref_29.current = ____self_27_spring_28( -- 1238
			____self_27, -- 1238
			____joint_canCollide_26, -- 1239
			joint.bodyA.current, -- 1240
			joint.bodyB.current, -- 1241
			joint.linearOffset, -- 1242
			joint.angularOffset, -- 1243
			joint.maxForce, -- 1244
			joint.maxTorque, -- 1245
			joint.correctionFactor or 1 -- 1246
		) -- 1246
	end, -- 1224
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1249
		local joint = enode.props -- 1250
		if joint.ref == nil then -- 1250
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1252
			return -- 1253
		end -- 1253
		if joint.body.current == nil then -- 1253
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1256
			return -- 1257
		end -- 1257
		local ____joint_ref_33 = joint.ref -- 1259
		local ____self_31 = Dora.Joint -- 1259
		local ____self_31_move_32 = ____self_31.move -- 1259
		local ____joint_canCollide_30 = joint.canCollide -- 1260
		if ____joint_canCollide_30 == nil then -- 1260
			____joint_canCollide_30 = false -- 1260
		end -- 1260
		____joint_ref_33.current = ____self_31_move_32( -- 1259
			____self_31, -- 1259
			____joint_canCollide_30, -- 1260
			joint.body.current, -- 1261
			joint.targetPos, -- 1262
			joint.maxForce, -- 1263
			joint.frequency, -- 1264
			joint.damping or 0.7 -- 1265
		) -- 1265
	end, -- 1249
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1268
		local joint = enode.props -- 1269
		if joint.ref == nil then -- 1269
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1271
			return -- 1272
		end -- 1272
		if joint.bodyA.current == nil then -- 1272
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1275
			return -- 1276
		end -- 1276
		if joint.bodyB.current == nil then -- 1276
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1279
			return -- 1280
		end -- 1280
		local ____joint_ref_37 = joint.ref -- 1282
		local ____self_35 = Dora.Joint -- 1282
		local ____self_35_prismatic_36 = ____self_35.prismatic -- 1282
		local ____joint_canCollide_34 = joint.canCollide -- 1283
		if ____joint_canCollide_34 == nil then -- 1283
			____joint_canCollide_34 = false -- 1283
		end -- 1283
		____joint_ref_37.current = ____self_35_prismatic_36( -- 1282
			____self_35, -- 1282
			____joint_canCollide_34, -- 1283
			joint.bodyA.current, -- 1284
			joint.bodyB.current, -- 1285
			joint.worldPos, -- 1286
			joint.axisAngle, -- 1287
			joint.lowerTranslation or 0, -- 1288
			joint.upperTranslation or 0, -- 1289
			joint.maxMotorForce or 0, -- 1290
			joint.motorSpeed or 0 -- 1291
		) -- 1291
	end, -- 1268
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1294
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
		local ____joint_ref_41 = joint.ref -- 1308
		local ____self_39 = Dora.Joint -- 1308
		local ____self_39_pulley_40 = ____self_39.pulley -- 1308
		local ____joint_canCollide_38 = joint.canCollide -- 1309
		if ____joint_canCollide_38 == nil then -- 1309
			____joint_canCollide_38 = false -- 1309
		end -- 1309
		____joint_ref_41.current = ____self_39_pulley_40( -- 1308
			____self_39, -- 1308
			____joint_canCollide_38, -- 1309
			joint.bodyA.current, -- 1310
			joint.bodyB.current, -- 1311
			joint.anchorA or Dora.Vec2.zero, -- 1312
			joint.anchorB or Dora.Vec2.zero, -- 1313
			joint.groundAnchorA, -- 1314
			joint.groundAnchorB, -- 1315
			joint.ratio or 1 -- 1316
		) -- 1316
	end, -- 1294
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1319
		local joint = enode.props -- 1320
		if joint.ref == nil then -- 1320
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1322
			return -- 1323
		end -- 1323
		if joint.bodyA.current == nil then -- 1323
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1326
			return -- 1327
		end -- 1327
		if joint.bodyB.current == nil then -- 1327
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1330
			return -- 1331
		end -- 1331
		local ____joint_ref_45 = joint.ref -- 1333
		local ____self_43 = Dora.Joint -- 1333
		local ____self_43_revolute_44 = ____self_43.revolute -- 1333
		local ____joint_canCollide_42 = joint.canCollide -- 1334
		if ____joint_canCollide_42 == nil then -- 1334
			____joint_canCollide_42 = false -- 1334
		end -- 1334
		____joint_ref_45.current = ____self_43_revolute_44( -- 1333
			____self_43, -- 1333
			____joint_canCollide_42, -- 1334
			joint.bodyA.current, -- 1335
			joint.bodyB.current, -- 1336
			joint.worldPos, -- 1337
			joint.lowerAngle or 0, -- 1338
			joint.upperAngle or 0, -- 1339
			joint.maxMotorTorque or 0, -- 1340
			joint.motorSpeed or 0 -- 1341
		) -- 1341
	end, -- 1319
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1344
		local joint = enode.props -- 1345
		if joint.ref == nil then -- 1345
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1347
			return -- 1348
		end -- 1348
		if joint.bodyA.current == nil then -- 1348
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1351
			return -- 1352
		end -- 1352
		if joint.bodyB.current == nil then -- 1352
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1355
			return -- 1356
		end -- 1356
		local ____joint_ref_49 = joint.ref -- 1358
		local ____self_47 = Dora.Joint -- 1358
		local ____self_47_rope_48 = ____self_47.rope -- 1358
		local ____joint_canCollide_46 = joint.canCollide -- 1359
		if ____joint_canCollide_46 == nil then -- 1359
			____joint_canCollide_46 = false -- 1359
		end -- 1359
		____joint_ref_49.current = ____self_47_rope_48( -- 1358
			____self_47, -- 1358
			____joint_canCollide_46, -- 1359
			joint.bodyA.current, -- 1360
			joint.bodyB.current, -- 1361
			joint.anchorA or Dora.Vec2.zero, -- 1362
			joint.anchorB or Dora.Vec2.zero, -- 1363
			joint.maxLength or 0 -- 1364
		) -- 1364
	end, -- 1344
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1367
		local joint = enode.props -- 1368
		if joint.ref == nil then -- 1368
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1370
			return -- 1371
		end -- 1371
		if joint.bodyA.current == nil then -- 1371
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1374
			return -- 1375
		end -- 1375
		if joint.bodyB.current == nil then -- 1375
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1378
			return -- 1379
		end -- 1379
		local ____joint_ref_53 = joint.ref -- 1381
		local ____self_51 = Dora.Joint -- 1381
		local ____self_51_weld_52 = ____self_51.weld -- 1381
		local ____joint_canCollide_50 = joint.canCollide -- 1382
		if ____joint_canCollide_50 == nil then -- 1382
			____joint_canCollide_50 = false -- 1382
		end -- 1382
		____joint_ref_53.current = ____self_51_weld_52( -- 1381
			____self_51, -- 1381
			____joint_canCollide_50, -- 1382
			joint.bodyA.current, -- 1383
			joint.bodyB.current, -- 1384
			joint.worldPos, -- 1385
			joint.frequency or 0, -- 1386
			joint.damping or 0 -- 1387
		) -- 1387
	end, -- 1367
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1390
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
		local ____joint_ref_57 = joint.ref -- 1404
		local ____self_55 = Dora.Joint -- 1404
		local ____self_55_wheel_56 = ____self_55.wheel -- 1404
		local ____joint_canCollide_54 = joint.canCollide -- 1405
		if ____joint_canCollide_54 == nil then -- 1405
			____joint_canCollide_54 = false -- 1405
		end -- 1405
		____joint_ref_57.current = ____self_55_wheel_56( -- 1404
			____self_55, -- 1404
			____joint_canCollide_54, -- 1405
			joint.bodyA.current, -- 1406
			joint.bodyB.current, -- 1407
			joint.worldPos, -- 1408
			joint.axisAngle, -- 1409
			joint.maxMotorTorque or 0, -- 1410
			joint.motorSpeed or 0, -- 1411
			joint.frequency or 0, -- 1412
			joint.damping or 0.7 -- 1413
		) -- 1413
	end, -- 1390
	["custom-node"] = function(nodeStack, enode, _parent) -- 1416
		local node = getCustomNode(enode) -- 1417
		if node ~= nil then -- 1417
			addChild(nodeStack, node, enode) -- 1419
		end -- 1419
	end, -- 1416
	["custom-element"] = function() -- 1422
	end, -- 1422
	["align-node"] = function(nodeStack, enode, _parent) -- 1423
		addChild( -- 1424
			nodeStack, -- 1424
			getAlignNode(enode), -- 1424
			enode -- 1424
		) -- 1424
	end, -- 1423
	["effek-node"] = function(nodeStack, enode, _parent) -- 1426
		addChild( -- 1427
			nodeStack, -- 1427
			getEffekNode(enode), -- 1427
			enode -- 1427
		) -- 1427
	end, -- 1426
	effek = function(nodeStack, enode, parent) -- 1429
		if #nodeStack > 0 then -- 1429
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1431
			if node then -- 1431
				local effek = enode.props -- 1433
				local handle = node:play( -- 1434
					effek.file, -- 1434
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1434
					effek.z or 0 -- 1434
				) -- 1434
				if handle >= 0 then -- 1434
					if effek.ref then -- 1434
						effek.ref.current = handle -- 1437
					end -- 1437
					if effek.onEnd then -- 1437
						local onEnd = effek.onEnd -- 1437
						node:slot( -- 1441
							"EffekEnd", -- 1441
							function(h) -- 1441
								if handle == h then -- 1441
									onEnd(nil) -- 1443
								end -- 1443
							end -- 1441
						) -- 1441
					end -- 1441
				end -- 1441
			else -- 1441
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1449
			end -- 1449
		end -- 1449
	end, -- 1429
	["tile-node"] = function(nodeStack, enode, parent) -- 1453
		local cnode = getTileNode(enode) -- 1454
		if cnode ~= nil then -- 1454
			addChild(nodeStack, cnode, enode) -- 1456
		end -- 1456
	end -- 1453
} -- 1453
local roots = {} -- 1509
local renderQueued = false -- 1510
local function isElementList(node) -- 1512
	return node.type == nil -- 1513
end -- 1512
local function getRenderableElement(renderable) -- 1521
	if type(renderable) == "function" then -- 1521
		return renderable() -- 1523
	end -- 1523
	return renderable -- 1525
end -- 1521
local function toElementList(node) -- 1874
	if isElementList(node) then -- 1874
		return node -- 1876
	end -- 1876
	return {node} -- 1878
end -- 1874
local function scheduleRender() -- 1881
	if renderQueued then -- 1881
		return -- 1882
	end -- 1882
	renderQueued = true -- 1883
	Dora.Director.systemScheduler:schedule(Dora.once(function() -- 1884
		renderQueued = false -- 1885
		for i = 1, #roots do -- 1885
			roots[i]:update() -- 1887
		end -- 1887
	end)) -- 1884
end -- 1881
____exports.Root = __TS__Class() -- 1892
local Root = ____exports.Root -- 1892
Root.name = "Root" -- 1892
function Root.prototype.____constructor(self, parent) -- 1896
	self.parent = parent -- 1896
	self.mounted = {} -- 1893
end -- 1896
function Root.prototype.render(self, enode) -- 1898
	self.renderable = enode -- 1899
	self:update() -- 1900
end -- 1898
function Root.prototype.update(self) -- 1903
	if self.renderable == nil then -- 1903
		return -- 1904
	end -- 1904
	self.mounted = reconcileChildren( -- 1905
		self.parent, -- 1905
		self.mounted, -- 1905
		toElementList(getRenderableElement(self.renderable)) -- 1905
	) -- 1905
end -- 1903
function Root.prototype.unmount(self) -- 1908
	for i = 1, #self.mounted do -- 1908
		unmountElement(self.mounted[i]) -- 1910
	end -- 1910
	self.mounted = {} -- 1912
	self.renderable = nil -- 1913
end -- 1908
function ____exports.createRoot(parent) -- 1917
	local root = __TS__New(____exports.Root, parent) -- 1918
	roots[#roots + 1] = root -- 1919
	return root -- 1920
end -- 1917
____exports.Signal = __TS__Class() -- 1923
local Signal = ____exports.Signal -- 1923
Signal.name = "Signal" -- 1923
function Signal.prototype.____constructor(self, item) -- 1924
	self.item = item -- 1924
end -- 1924
__TS__SetDescriptor( -- 1924
	Signal.prototype, -- 1924
	"value", -- 1924
	{ -- 1924
		get = function(self) -- 1924
			return self.item -- 1927
		end, -- 1927
		set = function(self, value) -- 1927
			if self.item == value then -- 1927
				return -- 1931
			end -- 1931
			self.item = value -- 1932
			scheduleRender() -- 1933
		end -- 1933
	}, -- 1933
	true -- 1933
) -- 1933
function ____exports.signal(value) -- 1937
	return __TS__New(____exports.Signal, value) -- 1938
end -- 1937
function ____exports.useRef(item) -- 1941
	local ____item_59 = item -- 1942
	if ____item_59 == nil then -- 1942
		____item_59 = nil -- 1942
	end -- 1942
	return {current = ____item_59} -- 1942
end -- 1941
local function getPreload(preloadList, node) -- 1945
	if type(node) ~= "table" then -- 1945
		return -- 1947
	end -- 1947
	local enode = node -- 1949
	if enode.type == nil then -- 1949
		local list = node -- 1951
		if #list > 0 then -- 1951
			for i = 1, #list do -- 1951
				getPreload(preloadList, list[i]) -- 1954
			end -- 1954
		end -- 1954
	else -- 1954
		repeat -- 1954
			local ____switch441 = enode.type -- 1954
			local sprite, playable, frame, model, spine, dragonBone, label -- 1954
			local ____cond441 = ____switch441 == "sprite" -- 1954
			if ____cond441 then -- 1954
				sprite = enode.props -- 1960
				if sprite.file then -- 1960
					preloadList[#preloadList + 1] = sprite.file -- 1962
				end -- 1962
				break -- 1964
			end -- 1964
			____cond441 = ____cond441 or ____switch441 == "playable" -- 1964
			if ____cond441 then -- 1964
				playable = enode.props -- 1966
				preloadList[#preloadList + 1] = playable.file -- 1967
				break -- 1968
			end -- 1968
			____cond441 = ____cond441 or ____switch441 == "frame" -- 1968
			if ____cond441 then -- 1968
				frame = enode.props -- 1970
				preloadList[#preloadList + 1] = frame.file -- 1971
				break -- 1972
			end -- 1972
			____cond441 = ____cond441 or ____switch441 == "model" -- 1972
			if ____cond441 then -- 1972
				model = enode.props -- 1974
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1975
				break -- 1976
			end -- 1976
			____cond441 = ____cond441 or ____switch441 == "spine" -- 1976
			if ____cond441 then -- 1976
				spine = enode.props -- 1978
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1979
				break -- 1980
			end -- 1980
			____cond441 = ____cond441 or ____switch441 == "dragon-bone" -- 1980
			if ____cond441 then -- 1980
				dragonBone = enode.props -- 1982
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1983
				break -- 1984
			end -- 1984
			____cond441 = ____cond441 or ____switch441 == "label" -- 1984
			if ____cond441 then -- 1984
				label = enode.props -- 1986
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1987
				break -- 1988
			end -- 1988
		until true -- 1988
	end -- 1988
	getPreload(preloadList, enode.children) -- 1991
end -- 1945
function ____exports.preloadAsync(enode, handler) -- 1994
	local preloadList = {} -- 1995
	getPreload(preloadList, enode) -- 1996
	Dora.Cache:loadAsync(preloadList, handler) -- 1997
end -- 1994
function ____exports.toAction(enode) -- 2000
	local actionDef = ____exports.useRef() -- 2001
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 2002
	if not actionDef.current then -- 2002
		error("failed to create action") -- 2003
	end -- 2003
	return actionDef.current -- 2004
end -- 2000
return ____exports -- 2000