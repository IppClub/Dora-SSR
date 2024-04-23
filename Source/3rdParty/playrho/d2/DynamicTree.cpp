/*
 * Original work Copyright (c) 2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include <algorithm>
#include <cassert> // for assert
#include <limits> // for std::numeric_limits
#include <utility>
#include <type_traits> // for std::is_nothrow_default_constructible_v, etc

#include "playrho/GrowableStack.hpp"
#include "playrho/DynamicMemory.hpp"
#include "playrho/Templates.hpp"

#include "playrho/d2/AABB.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/Math.hpp" // for NextPowerOfTwo and others

namespace playrho::d2 {

static_assert(std::is_nothrow_default_constructible_v<DynamicTree>,
              "DynamicTree must be nothrow default constructible!");
static_assert(std::is_copy_constructible_v<DynamicTree>,
              "DynamicTree must be copy constructible!");
static_assert(std::is_nothrow_move_constructible_v<DynamicTree>,
              "DynamicTree must be nothrow move constructible!");
static_assert(std::is_copy_assignable_v<DynamicTree>, "DynamicTree must be copy assignable!");
static_assert(std::is_nothrow_move_assignable_v<DynamicTree>,
              "DynamicTree must be move assignable!");

namespace {

inline DynamicTree::TreeNode MakeNode(DynamicTree::Size c1, const AABB& aabb1,
                                      DynamicTree::Height h1, DynamicTree::Size c2,
                                      const AABB& aabb2, DynamicTree::Height h2,
                                      DynamicTree::Size parent) noexcept
{
    return DynamicTree::TreeNode{DynamicTreeBranchData{c1, c2}, GetEnclosingAABB(aabb1, aabb2),
                                 1 + std::max(h1, h2), parent};
}

std::pair<DynamicTree::Size, DynamicTree::Size> MakeMoveStay(const DynamicTree::TreeNode& nodeA,
                                                             DynamicTree::Size indexA,
                                                             const DynamicTree::TreeNode& nodeB,
                                                             DynamicTree::Size indexB,
                                                             const AABB& toBox) noexcept
{
    if (nodeA.GetHeight() < nodeB.GetHeight()) {
        return std::make_pair(indexA, indexB);
    }
    if (nodeB.GetHeight() < nodeA.GetHeight()) {
        return std::make_pair(indexB, indexA);
    }
    const auto perimA = GetPerimeter(GetEnclosingAABB(toBox, nodeA.GetAABB()));
    const auto perimB = GetPerimeter(GetEnclosingAABB(toBox, nodeB.GetAABB()));
    if (perimA < perimB) {
        return std::make_pair(indexA, indexB);
    }
    if (perimB < perimA) {
        return std::make_pair(indexB, indexA);
    }
    return std::make_pair(indexA, indexB);
}

DynamicTree::Size RebalanceAt(DynamicTree::TreeNode nodes[], DynamicTree::Size i) noexcept
{
    // assert(index < GetNodeCapacity());
    assert(DynamicTree::IsBranch(nodes[i].GetHeight()));

    /* note: gcc doesn't like multiline comments within double-slash
    //          o
    //          |
    //          i
    //         / \
    //      *-c1  c2-*
    //     /   |  |   \
    // c1c1 c1c2  c2c1 c2c2
    **/
    const auto oldNodeI = nodes[i];
    const auto o = oldNodeI.GetOther();
    const auto c1 = oldNodeI.AsBranch().child1;
    const auto c2 = oldNodeI.AsBranch().child2;
    auto c1Node = nodes[c1];
    auto c2Node = nodes[c2];
    const auto c1Height = c1Node.GetHeight();
    const auto c2Height = c2Node.GetHeight();

    if (c2Height > (c1Height + 1)) {
        // child 2 heavier than child 1, child 2 must be branch, rotate it up.
        const auto c2c1 = c2Node.AsBranch().child1;
        const auto c2c2 = c2Node.AsBranch().child2;
        const auto c2c1Node = nodes[c2c1];
        const auto c2c2Node = nodes[c2c2];

        /* note: gcc doesn't like multiline comments within double-slash
        // From:
        //          *i*
        //         /   \
        //        c1   c2*
        //            /   \
        //         c2c1   c2c2
        //    where c2c1 or c2c2 is also a branch node
        //
        // To:
        //           c2*
        //          /   \
        //       *i*     c2cY
        //      /   \
        //    c1    c2cX
        //
        // Rotate left and pick the taller of c2c1 or c2c2 or the better fitting to move to the new
        // i node.
        **/
        const auto ms = MakeMoveStay(c2c1Node, c2c1, c2c2Node, c2c2, c1Node.GetAABB());
        const auto newNodeI = MakeNode(c1, c1Node.GetAABB(), c1Height, ms.first,
                                       nodes[ms.first].GetAABB(), nodes[ms.first].GetHeight(), c2);
        c2Node = MakeNode(i, newNodeI.GetAABB(), newNodeI.GetHeight(), ms.second,
                          nodes[ms.second].GetAABB(), nodes[ms.second].GetHeight(), o);
        nodes[ms.first].SetOther(i);
        nodes[i] = newNodeI;
        nodes[c2] = c2Node;
        if (o != DynamicTree::InvalidSize) {
            const auto oNode = nodes[o];
            const auto oNodeBD = oNode.AsBranch();
            assert(oNodeBD.child1 == i || oNodeBD.child2 == i);
            nodes[o] = (oNodeBD.child1 == i)
                           ? MakeNode(c2, c2Node.GetAABB(), c2Node.GetHeight(), oNodeBD.child2,
                                      nodes[oNodeBD.child2].GetAABB(),
                                      nodes[oNodeBD.child2].GetHeight(), oNode.GetOther())
                           : MakeNode(oNodeBD.child1, nodes[oNodeBD.child1].GetAABB(),
                                      nodes[oNodeBD.child1].GetHeight(), c2, c2Node.GetAABB(),
                                      c2Node.GetHeight(), oNode.GetOther());
        }
        return c2;
    }

    if (c1Height > (c2Height + 1)) {
        // child1 must be a branch, rotate it up.
        const auto c1c1 = c1Node.AsBranch().child1;
        const auto c1c2 = c1Node.AsBranch().child2;
        const auto c1c1Node = nodes[c1c1];
        const auto c1c2Node = nodes[c1c2];

        /* note: gcc doesn't like multiline comments within double-slash
        // From:
        //          *i*
        //         /   \
        //       *c1   c2*
        //      /   \
        //   c1c1   c1c2
        //    where c1c1 or c1c2 is also a branch node
        //
        // To:
        //           c1*
        //          /   \
        //       c1cX    *i*
        //              /   \
        //           c1cY    c2
        //
        // Rotate right and pick the taller of c1c1 or c1c2 or the better fitting to move to the new
        // i node.
        **/
        const auto ms = MakeMoveStay(c1c1Node, c1c1, c1c2Node, c1c2, c2Node.GetAABB());
        const auto newNodeI =
            MakeNode(ms.first, nodes[ms.first].GetAABB(), nodes[ms.first].GetHeight(), c2,
                     c2Node.GetAABB(), c2Height, c1);
        c1Node = MakeNode(ms.second, nodes[ms.second].GetAABB(), nodes[ms.second].GetHeight(), i,
                          newNodeI.GetAABB(), newNodeI.GetHeight(), o);
        nodes[ms.first].SetOther(i);
        nodes[i] = newNodeI;
        nodes[c1] = c1Node;
        if (o != DynamicTree::InvalidSize) {
            const auto oNode = nodes[o];
            const auto oNodeBD = oNode.AsBranch();
            assert(oNodeBD.child1 == i || oNodeBD.child2 == i);
            nodes[o] = (oNodeBD.child1 == i)
                           ? MakeNode(c1, c1Node.GetAABB(), c1Node.GetHeight(), oNodeBD.child2,
                                      nodes[oNodeBD.child2].GetAABB(),
                                      nodes[oNodeBD.child2].GetHeight(), oNode.GetOther())
                           : MakeNode(oNodeBD.child1, nodes[oNodeBD.child1].GetAABB(),
                                      nodes[oNodeBD.child1].GetHeight(), c1, c1Node.GetAABB(),
                                      c1Node.GetHeight(), oNode.GetOther());
        }
        return c1;
    }

    nodes[i] =
        MakeNode(c1, c1Node.GetAABB(), c1Node.GetHeight(), c2, c2Node.GetAABB(), c2Height, o);
    return i;
}

/// @brief Updates upward from location in tree.
/// @note In addition to updating the heights & AABBs of branch nodes, this also rebalances
///  the tree.
DynamicTree::Size UpdateUpwardFrom(DynamicTree::TreeNode nodes[], DynamicTree::Size start) noexcept
{
    assert(DynamicTree::IsBranch(nodes[start].GetHeight()));
    auto rootIndex = DynamicTree::InvalidSize;
    for (auto index = start; index != DynamicTree::InvalidSize;
         index = nodes[index].GetOther()) {
        assert(DynamicTree::IsBranch(nodes[index].GetHeight()));
        assert(nodes[nodes[index].AsBranch().child1].GetOther() == index);
        assert(nodes[nodes[index].AsBranch().child2].GetOther() == index);
        if (nodes[index].GetHeight() >= 2) {
            index = RebalanceAt(nodes, index);
        }
        rootIndex = index;
    }
    return rootIndex;
}

/// @brief Finds the lowest cost node to associate the given AABB with
///   starting from the given index.
/// @details Finds the index of the "lowest cost" node using a surface area heuristic
///   (S.A.H.) for two dimensions.
/// @pre <code>IsValid(leafAABB)</code>, <code>index != DynamicTree::InvalidSize</code>,
///   and <code>!playrho::d2::IsUnused(nodes[index])</code> are all true.
DynamicTree::Size FindLowestCostNode(const DynamicTree::TreeNode nodes[], const AABB& leafAABB,
                                     DynamicTree::Size index) noexcept
{
    assert(IsValid(leafAABB));
    assert(index != DynamicTree::InvalidSize);
    assert(!playrho::d2::IsUnused(nodes[index]));

    // Cost function to calculate cost of descending into specified child
    const auto costFunc = [leafAABB](const DynamicTree::TreeNode& childNode, Length inheritCost) {
        const auto childAabb = playrho::d2::GetAABB(childNode);
        const auto isLeaf = playrho::d2::IsLeaf(childNode);
        const auto leafCost = GetPerimeter(GetEnclosingAABB(leafAABB, childAabb)) + inheritCost;
        return isLeaf ? leafCost : (leafCost - GetPerimeter(childAabb));
    };

    while (playrho::d2::IsBranch(nodes[index])) {
        const auto& node = nodes[index];
        const auto branch = node.AsBranch();
        const auto child1 = branch.child1;
        const auto child2 = branch.child2;
        assert(nodes[child1].GetOther() == index);
        assert(nodes[child2].GetOther() == index);
        const auto aabb = node.GetAABB();
        const auto perimeter = GetPerimeter(aabb);
        const auto combinedPerimeter = GetPerimeter(GetEnclosingAABB(aabb, leafAABB));

        assert(combinedPerimeter >= perimeter);
        assert(child1 != DynamicTree::InvalidSize);
        assert(child2 != DynamicTree::InvalidSize);

        // Cost of creating a new parent for this node and the new leaf
        const auto cost = combinedPerimeter * 2;

        // Minimum cost of pushing the leaf further down the tree
        const auto inheritanceCost = (combinedPerimeter - perimeter) * 2;

        const auto cost1 = costFunc(nodes[child1], inheritanceCost);
        const auto cost2 = costFunc(nodes[child2], inheritanceCost);

        if ((cost < cost1) && (cost < cost2)) {
            // Cheaper to create a new parent for this node and the new leaf
            break;
        }

        // Descend into child with least cost.
        index = (cost1 < cost2) ? child1 : child2;
    }
    return index;
}

std::pair<DynamicTree::Size, DynamicTree::Size> RemoveParent(DynamicTree::TreeNode nodes[],
                                                             DynamicTree::Size index) noexcept
{
    const auto parent = nodes[index].GetOther();
    const auto grandParent = nodes[parent].GetOther();
    const auto parentBD = nodes[parent].AsBranch();
    const auto sibling = (parentBD.child1 == index) ? parentBD.child2 : parentBD.child1;

    nodes[index].SetOther(DynamicTree::InvalidSize);
    nodes[sibling].SetOther(grandParent);
    if (grandParent != DynamicTree::InvalidSize) {
        const auto newBD = ReplaceChild(nodes[grandParent].AsBranch(), parent, sibling);
        const auto newAabb =
            GetEnclosingAABB(nodes[newBD.child1].GetAABB(), nodes[newBD.child2].GetAABB());
        const auto newHeight =
            1 + std::max(nodes[newBD.child1].GetHeight(), nodes[newBD.child2].GetHeight());
        nodes[grandParent].Assign(newBD, newAabb, newHeight);
        nodes[parent].SetOther(DynamicTree::InvalidSize);
        return std::make_pair(UpdateUpwardFrom(nodes, grandParent), parent);
    }
    return std::make_pair(sibling, parent);
}

DynamicTree::Size InsertParent(DynamicTree::TreeNode nodes[], DynamicTree::Size newParent,
                               const AABB& aabb, DynamicTree::Size index,
                               DynamicTree::Size rootIndex) noexcept
{
    const auto sibling = FindLowestCostNode(nodes, aabb, rootIndex);
    const auto oldParent = nodes[sibling].GetOther();

    // std::max of leaf height and sibling height + 1 = sibling height + 1
    nodes[newParent] = DynamicTree::TreeNode{DynamicTreeBranchData{sibling, index},
                                             GetEnclosingAABB(aabb, nodes[sibling].GetAABB()),
                                             1 + nodes[sibling].GetHeight(), oldParent};
    nodes[sibling].SetOther(newParent);
    nodes[index].SetOther(newParent);
    if (oldParent != DynamicTree::InvalidSize) {
        const auto newBD = ReplaceChild(nodes[oldParent].AsBranch(), sibling, newParent);
        const auto newAabb =
            GetEnclosingAABB(nodes[newBD.child1].GetAABB(), nodes[newBD.child2].GetAABB());
        const auto newHeight =
            1 + std::max(nodes[newBD.child1].GetHeight(), nodes[newBD.child2].GetHeight());
        nodes[oldParent].Assign(newBD, newAabb, newHeight);
        assert(nodes[nodes[oldParent].AsBranch().child1].GetOther() == oldParent);
        assert(nodes[nodes[oldParent].AsBranch().child2].GetOther() == oldParent);
        return UpdateUpwardFrom(nodes, oldParent);
    }
    return newParent;
}

DynamicTree::Size UpdateNonRoot(DynamicTree::TreeNode nodes[], DynamicTree::Size index,
                                const AABB& aabb) noexcept
{
    assert(nodes[index].GetOther() != DynamicTree::InvalidSize);

    const auto parent = nodes[index].GetOther();
    const auto grandParent = nodes[parent].GetOther();
    const auto parentBD = nodes[parent].AsBranch();
    assert(parentBD.child1 == index || parentBD.child2 == index);
    const auto sibling = (parentBD.child1 == index) ? parentBD.child2 : parentBD.child1;

    nodes[sibling].SetOther(grandParent);
    nodes[index].SetAABB(aabb);
    auto rootIndex = DynamicTree::InvalidSize;
    if (grandParent != DynamicTree::InvalidSize) {
        assert(nodes[grandParent].AsBranch().child1 == parent ||
               nodes[grandParent].AsBranch().child2 == parent);
        const auto newBD = ReplaceChild(nodes[grandParent].AsBranch(), parent, sibling);
        const auto newAabb =
            GetEnclosingAABB(nodes[newBD.child1].GetAABB(), nodes[newBD.child2].GetAABB());
        const auto newHeight =
            1 + std::max(nodes[newBD.child1].GetHeight(), nodes[newBD.child2].GetHeight());
        nodes[grandParent].Assign(newBD, newAabb, newHeight);
        nodes[parent].SetOther(DynamicTree::InvalidSize);
        assert(nodes[nodes[grandParent].AsBranch().child1].GetOther() == grandParent);
        assert(nodes[nodes[grandParent].AsBranch().child2].GetOther() == grandParent);
        rootIndex = UpdateUpwardFrom(nodes, grandParent);
    }
    else // grandParent == InvalidSize
    {
        rootIndex = sibling;
    }

    const auto cheapest = FindLowestCostNode(nodes, aabb, rootIndex);
    const auto cheapestParent = nodes[cheapest].GetOther();

    // std::max of leaf height and cheapest height + 1 = cheapest height + 1
    nodes[parent] = DynamicTree::TreeNode{DynamicTreeBranchData{cheapest, index},
                                          GetEnclosingAABB(aabb, nodes[cheapest].GetAABB()),
                                          1 + nodes[cheapest].GetHeight(), cheapestParent};
    if (cheapestParent != DynamicTree::InvalidSize) {
        const auto newBD = ReplaceChild(nodes[cheapestParent].AsBranch(), cheapest, parent);
        const auto newAabb =
            GetEnclosingAABB(nodes[newBD.child1].GetAABB(), nodes[newBD.child2].GetAABB());
        const auto newHeight =
            1 + std::max(nodes[newBD.child1].GetHeight(), nodes[newBD.child2].GetHeight());
        nodes[cheapestParent].Assign(newBD, newAabb, newHeight);
    }
    nodes[cheapest].SetOther(parent);
    return UpdateUpwardFrom(nodes, parent);
}

} // anonymous namespace

DynamicTree::DynamicTree() noexcept = default;

DynamicTree::DynamicTree(Size nodeCapacity)
    : m_freeIndex{nodeCapacity ? 0 : InvalidSize},
      m_nodeCapacity{NextPowerOfTwo(nodeCapacity - 1u /*rollover okay!*/)},
      m_nodes{m_nodeCapacity ? AllocArray<TreeNode>(m_nodeCapacity) : nullptr}
{
    if (m_nodeCapacity) {
        // Build a linked list for the free list.
        const auto endCapacity = m_nodeCapacity - Size{1};
        for (auto i = decltype(m_nodeCapacity){0}; i < endCapacity; ++i) {
            new (&m_nodes[i]) TreeNode{i + 1};
        }
        new (&m_nodes[endCapacity]) TreeNode{};
    }
}

DynamicTree::DynamicTree(const DynamicTree& other)
    : m_nodeCount{other.m_nodeCount},
      m_leafCount{other.m_leafCount},
      m_rootIndex{other.m_rootIndex},
      m_freeIndex{other.m_freeIndex},
      m_nodeCapacity{other.m_nodeCapacity},
      m_nodes{AllocArray<TreeNode>(other.m_nodeCapacity)}
{
    std::copy(&other.m_nodes[0], &other.m_nodes[other.m_nodeCapacity], &m_nodes[0]);
}

DynamicTree::DynamicTree(DynamicTree&& other) noexcept : DynamicTree{}
{
    swap(*this, other);
}

DynamicTree::~DynamicTree() noexcept
{
    // This frees the entire tree in one shot.
    Free(m_nodes);
}

DynamicTree& DynamicTree::operator=(DynamicTree other) noexcept
{
    // Leverages the "copy-and-swap" idiom.
    // For details, see https://stackoverflow.com/a/3279550/7410358
    swap(*this, other);
    return *this;
}

void DynamicTree::Reserve(Size value)
{
    if (value > m_nodeCapacity) {
        value = NextPowerOfTwo(value - 1u /*rollover okay!*/);
        // Call Realloc first in case it throws so this code doesn't have to restore any state
        // and so this function will have no effect.
        m_nodes = ReallocArray<TreeNode>(m_nodes, value);
        m_nodeCapacity = value;

        // Build a linked list for the free list. The parent
        // pointer becomes the "next" pointer.
        const auto endCapacity = m_nodeCapacity - 1;
        for (auto i = m_nodeCount; i < endCapacity; ++i) {
            new (m_nodes + i) TreeNode{i + 1};
        }
        new (m_nodes + endCapacity) TreeNode{};
        m_freeIndex = m_nodeCount;
    }
}

DynamicTree::Size DynamicTree::AllocateNode() noexcept
{
    // Peel a node off the free list.
    assert(m_freeIndex < m_nodeCapacity);
    const auto index = m_freeIndex;
    m_freeIndex = m_nodes[index].GetOther();
    ++m_nodeCount;
    return index;
}

void DynamicTree::FreeNode(Size index) noexcept
{
    assert(index != InvalidSize);
    assert(index < GetNodeCapacity());
    assert(index != GetFreeIndex());
    assert(m_nodeCount > 0); // index is not necessarily less than m_nodeCount.
    assert(!IsUnused(m_nodes[index].GetHeight()));
    assert(m_nodes[index].GetOther() == InvalidSize);
    m_nodes[index] = TreeNode{m_freeIndex};
    m_freeIndex = index;
    --m_nodeCount;
}

void DynamicTree::Clear() noexcept
{
    m_nodeCount = Size{0u};
    m_leafCount = Size{0u};
    m_rootIndex = InvalidSize;
    if (m_nodeCapacity && m_nodes) {
        m_freeIndex = Size{0u};
        const auto endCapacity = m_nodeCapacity - 1;
        for (auto i = Size{0u}; i < endCapacity; ++i) {
            m_nodes[i] = TreeNode{i + 1};
        }
        m_nodes[endCapacity] = TreeNode{};
    }
    else {
        Free(m_nodes);
        m_nodes = nullptr;
        m_nodeCapacity = Size{0u};
        m_freeIndex = InvalidSize;
    }
}

DynamicTree::Size DynamicTree::FindReference(Size index) const noexcept
{
    const auto it = std::find_if(m_nodes, m_nodes + m_nodeCapacity, [index](TreeNode& node) {
        if (node.GetOther() == index) {
            return true;
        }
        if (IsBranch(node.GetHeight())) {
            const auto bd = node.AsBranch();
            if (bd.child1 == index || bd.child2 == index) {
                return true;
            }
        }
        return false;
    });
    return (it != m_nodes + m_nodeCapacity) ? static_cast<Size>(it - m_nodes) : InvalidSize;
}

DynamicTree::Size DynamicTree::CreateLeaf(const AABB& aabb, const Contactable& data)
{
    assert(m_leafCount < std::numeric_limits<Size>::max());
    assert(IsValid(aabb));
    if (m_rootIndex == InvalidSize) {
        assert(GetNodeCount() < std::numeric_limits<Size>::max());
        Reserve(GetNodeCount() + 1u); // Note: may change m_nodes!
        const auto index = AllocateNode();
        m_nodes[index] = TreeNode{data, aabb};
        m_rootIndex = index;
        ++m_leafCount;
        return index;
    }
    assert(GetNodeCount() < (std::numeric_limits<Size>::max() - 1u));
    Reserve(GetNodeCount() + 2u); // Note: may change m_nodes!
    const auto index = AllocateNode();
    m_nodes[index] = TreeNode{data, aabb};
    m_rootIndex = InsertParent(m_nodes, AllocateNode(), aabb, index, m_rootIndex);
    ++m_leafCount;
    return index;
}

void DynamicTree::DestroyLeaf(Size index) noexcept
{
    assert(index != InvalidSize);
    assert(index < m_nodeCapacity);
    assert(!IsUnused(m_nodes[index].GetHeight()));
    assert(IsLeaf(m_nodes[index].GetHeight()));
    assert(m_leafCount > 0);

    --m_leafCount;

    if (m_rootIndex != index) {
        const auto result = RemoveParent(m_nodes, index);
        m_rootIndex = std::get<0>(result);
        const auto parent = std::get<1>(result);
#ifndef NDEBUG
        const auto found = FindReference(parent);
        assert(found == InvalidSize);
#endif
        FreeNode(parent);
    }
    else {
        assert(m_nodes[index].GetOther() == InvalidSize);
        m_rootIndex = InvalidSize;
    }

#ifndef NDEBUG
    const auto found = FindReference(index);
    assert(found == InvalidSize);
#endif
    FreeNode(index);
}

void DynamicTree::UpdateLeaf(Size index, const AABB& aabb)
{
    assert(index != InvalidSize);
    assert(index < m_nodeCapacity);
    assert(IsLeaf(m_nodes[index].GetHeight()));

    if (m_rootIndex != index) {
        m_rootIndex = UpdateNonRoot(m_nodes, index, aabb);
    }
    else {
        assert(m_nodes[index].GetOther() == InvalidSize);
        m_nodes[index].SetAABB(aabb);
    }
}

void DynamicTree::RebuildBottomUp()
{
    const auto nodes = AllocArray<Size>(m_nodeCount);
    auto count = Size{0};

    // Build array of leaves. Free the rest.
    for (auto i = decltype(m_nodeCapacity){0}; i < m_nodeCapacity; ++i) {
        const auto height = m_nodes[i].GetHeight();
        if (IsLeaf(height)) {
            m_nodes[i].SetOther(InvalidSize);
            nodes[count] = i;
            ++count;
        }
        else if (IsBranch(height)) {
            m_nodes[i].SetOther(InvalidSize);
            FreeNode(i);
        }
    }

    while (count > 1) {
        auto minCost = std::numeric_limits<Length>::infinity();
        auto iMin = InvalidSize;
        auto jMin = InvalidSize;
        for (auto i = decltype(count){0}; i < count; ++i) {
            const auto& aabbi = m_nodes[nodes[i]].GetAABB();

            for (auto j = i + 1; j < count; ++j) {
                const auto& aabbj = m_nodes[nodes[j]].GetAABB();
                const auto b = GetEnclosingAABB(aabbi, aabbj);
                const auto cost = GetPerimeter(b);
                if (minCost > cost) {
                    iMin = i;
                    jMin = j;
                    minCost = cost;
                }
            }
        }

        assert((iMin < m_nodeCount) && (jMin < m_nodeCount));

        const auto index1 = nodes[iMin];
        const auto index2 = nodes[jMin];
        assert(!IsUnused(m_nodes[index1].GetHeight()));
        assert(!IsUnused(m_nodes[index2].GetHeight()));

        const auto aabb = GetEnclosingAABB(m_nodes[index1].GetAABB(), m_nodes[index2].GetAABB());
        const auto height = 1 + std::max(m_nodes[index1].GetHeight(), m_nodes[index2].GetHeight());

        // Warning: the following may change value of m_nodes!
        Reserve(GetNodeCount() + 1u);
        const auto parent = AllocateNode();
        m_nodes[parent] = TreeNode{DynamicTreeBranchData{index1, index2}, aabb, height};
        m_nodes[index1].SetOther(parent);
        m_nodes[index2].SetOther(parent);

        nodes[jMin] = nodes[count - 1];
        nodes[iMin] = parent;
        --count;
    }

    m_rootIndex = nodes[0];
    Free(nodes);
}

void DynamicTree::ShiftOrigin(const Length2& newOrigin) noexcept
{
    // Build array of leaves. Free the rest.
    for (auto i = decltype(m_nodeCapacity){0}; i < m_nodeCapacity; ++i) {
        if (!IsUnused(m_nodes[i].GetHeight())) {
            m_nodes[i].SetAABB(GetMovedAABB(m_nodes[i].GetAABB(), -newOrigin));
        }
    }
}

// Free functions...

void swap(DynamicTree& lhs, DynamicTree& rhs) noexcept
{
    using playrho::swap;
    swap(lhs.m_nodes, rhs.m_nodes);
    swap(lhs.m_rootIndex, rhs.m_rootIndex);
    swap(lhs.m_freeIndex, rhs.m_freeIndex);
    swap(lhs.m_nodeCount, rhs.m_nodeCount);
    swap(lhs.m_nodeCapacity, rhs.m_nodeCapacity);
    swap(lhs.m_leafCount, rhs.m_leafCount);
}

void Query(const DynamicTree& tree, const AABB& aabb, const DynamicTreeSizeCB& callback)
{
    static constexpr auto InitialStackCapacity = 256;
    GrowableStack<DynamicTree::Size, InitialStackCapacity> stack;
    stack.push(tree.GetRootIndex());

    while (!empty(stack)) {
        const auto index = stack.top();
        stack.pop();
        if (index != DynamicTree::InvalidSize) {
            if (TestOverlap(tree.GetAABB(index), aabb)) {
                const auto height = tree.GetHeight(index);
                if (DynamicTree::IsBranch(height)) {
                    const auto branchData = tree.GetBranchData(index);
                    stack.push(branchData.child1);
                    stack.push(branchData.child2);
                }
                else {
                    assert(DynamicTree::IsLeaf(height));
                    const auto sc = callback(index);
                    if (sc == DynamicTreeOpcode::End) {
                        return;
                    }
                }
            }
        }
    }
}

void Query(const DynamicTree& tree, const AABB& aabb, QueryShapeCallback callback)
{
    Query(tree, aabb, [&](DynamicTree::Size treeId) {
        const auto leafData = tree.GetLeafData(treeId);
        return callback(leafData.bodyId, leafData.shapeId, leafData.childId)
                   ? DynamicTreeOpcode::Continue
                   : DynamicTreeOpcode::End;
    });
}

auto FindIndex(const DynamicTree &tree, const Contactable &c) noexcept -> DynamicTree::Size
{
    const auto max = tree.GetNodeCount();
    for (auto i = DynamicTree::Size(0); i < max; ++i) {
        const auto &node = tree.GetNode(i);
        if (IsLeaf(node) && node.AsLeaf() == c) {
            return i;
        }
    }
    return DynamicTree::InvalidSize;
}

Length ComputeTotalPerimeter(const DynamicTree& tree) noexcept
{
    auto total = 0_m;
    const auto nodeCapacity = tree.GetNodeCapacity();
    for (auto i = decltype(nodeCapacity){0}; i < nodeCapacity; ++i) {
        if (!DynamicTree::IsUnused(tree.GetHeight(i))) {
            total += GetPerimeter(tree.GetAABB(i));
        }
    }
    return total;
}

Real ComputePerimeterRatio(const DynamicTree& tree) noexcept
{
    const auto root = tree.GetRootIndex();
    if (root != DynamicTree::InvalidSize) {
        const auto rootPerimeter = GetPerimeter(tree.GetAABB(root));
        const auto total = ComputeTotalPerimeter(tree);
        return total / rootPerimeter;
    }
    return 0;
}

DynamicTree::Height ComputeHeight(const DynamicTree& tree, DynamicTree::Size index) noexcept
{
    assert(index < tree.GetNodeCapacity());
    if (DynamicTree::IsBranch(tree.GetHeight(index))) {
        const auto bd = tree.GetBranchData(index);
        const auto height1 = ComputeHeight(tree, bd.child1);
        const auto height2 = ComputeHeight(tree, bd.child2);
        return 1 + std::max(height1, height2);
    }
    return 0;
}

DynamicTree::Height GetMaxImbalance(const DynamicTree& tree) noexcept
{
    auto maxImbalance = DynamicTree::Height{0};
    const auto nodeCapacity = tree.GetNodeCapacity();
    for (auto i = decltype(nodeCapacity){0}; i < nodeCapacity; ++i) {
        if (DynamicTree::IsBranch(tree.GetHeight(i))) {
            const auto bd = tree.GetBranchData(i);
            const auto height1 = tree.GetHeight(bd.child1);
            const auto height2 = tree.GetHeight(bd.child2);
            const auto imbalance = (height2 >= height1) ? height2 - height1 : height1 - height2;
            maxImbalance = std::max(maxImbalance, imbalance);
        }
    }
    return maxImbalance;
}

bool ValidateStructure(const DynamicTree& tree, DynamicTree::Size index) noexcept
{
    if (index == DynamicTree::InvalidSize) {
        return true;
    }

    // DynamicTree enforces this invariant, so can't setup instance in this state to runtime test.
    assert((index != tree.GetRootIndex()) ||
           (tree.GetOther(index) == DynamicTree::InvalidSize));

    const auto nodeCapacity = tree.GetNodeCapacity();
    if (index >= nodeCapacity) {
        return false;
    }

    const auto height = tree.GetHeight(index);

    if (DynamicTree::IsLeaf(height)) {
        return true;
    }

    if (DynamicTree::IsBranch(height)) {
        const auto bd = tree.GetBranchData(index);
        const auto child1 = bd.child1;
        const auto child2 = bd.child2;
        assert(tree.GetOther(child1) == index);
        assert(tree.GetOther(child2) == index);
        return ValidateStructure(tree, child1) && ValidateStructure(tree, child2);
    }

    assert(DynamicTree::IsUnused(height));
    return ValidateStructure(tree, tree.GetOther(index));
}

bool ValidateMetrics(const DynamicTree& tree, DynamicTree::Size index) noexcept
{
    if (index == DynamicTree::InvalidSize) {
        return true;
    }

    const auto nodeCapacity = tree.GetNodeCapacity();
    if (index >= nodeCapacity) {
        return false;
    }

    const auto height = tree.GetHeight(index);
    if (!DynamicTree::IsBranch(height)) {
        return true;
    }

    const auto bd = tree.GetBranchData(index);
    const auto child1 = bd.child1;
    const auto child2 = bd.child2;

    // DynamicTree doesn't provide way to set up the following states so only assertable...
    assert(tree.GetOther(child1) == index);
    assert(tree.GetOther(child2) == index);
    assert(height == (1 + std::max(tree.GetHeight(child1), tree.GetHeight(child2))));
    assert(tree.GetAABB(index) == GetEnclosingAABB(tree.GetAABB(child1), tree.GetAABB(child2)));

    return ValidateMetrics(tree, child1) && ValidateMetrics(tree, child2);
}

} // namespace playrho::d2
