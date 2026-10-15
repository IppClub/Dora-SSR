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

#ifndef PLAYRHO_D2_DYNAMICTREE_HPP
#define PLAYRHO_D2_DYNAMICTREE_HPP

/// @file
/// @brief Declaration of the <code>DynamicTree</code> class.

#include <cassert> // for assert
#include <cstddef> // for std::size_t
#include <functional> // for std::function

// IWYU pragma: begin_exports

#include "playrho/d2/AABB.hpp"
#include "playrho/d2/DynamicTreeData.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Vector2.hpp"
#include "playrho/BodyID.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief A dynamic AABB tree broad-phase.
///
/// @details A dynamic tree arranges data in a binary tree to accelerate
///   queries such as volume queries and ray casts. Leafs are proxies
///   with an AABB.
///
/// @invariant A dynamic tree with a capacity of N nodes will always have N minus M "free"
///   nodes and M "allocated" nodes where M is never more than N.
/// @invariant Freed nodes' "other" nodes are valid "next" older freed nodes, or they
///   have the invalid size value indicating that they are the oldest freed node.
/// @invariant Allocated nodes' "other" nodes are valid "parent" nodes, or they
///   have the invalid size value indicating that they are parentless.
/// @invariant The root node's index is either the index to the node at the root of the tree
///   or it's the invalid size value indicating that this tree is empty.
/// @invariant The root node's "other" index will be the invalid size value.
/// @invariant Allocated nodes can only be "branch" or "leaf" nodes.
/// @invariant Branch nodes always have two valid "child" nodes.
/// @invariant Branch nodes always have a "height" of 1 plus the maximum height of its children.
/// @invariant Branch nodes' AABBs are always the AABB which minimally encloses its children.
/// @invariant Leaf nodes always have a "height" of zero.
/// @invariant Freed nodes always have a "height" of the maximum value of the height type.
///
/// @note This code was inspired by Nathanael Presson's <code>btDbvt</code>.
/// @note Nodes are pooled and relocatable, so we use node indices rather than pointers.
///
/// @see http://www.randygaul.net/2013/08/06/dynamic-aabb-tree/
/// @see http://www.cs.utah.edu/~thiago/papers/rotations.pdf ("Fast, Effective
///    BVH Updates for Animated Scenes")
///
class DynamicTree
{
public:
    /// @brief Size type.
    using Size = DynamicTreeSize;

    class TreeNode;

    /// @brief Invalid size constant value.
    static constexpr auto InvalidSize = static_cast<Size>(-1);

    /// @brief Type for heights.
    /// @note The maximum height of a tree can never exceed half of the max value of the
    ///   <code>Size</code> type due to the binary nature of this tree structure.
    using Height = DynamicTreeSize;

    /// @brief Invalid height constant value.
    static constexpr auto InvalidHeight = static_cast<Height>(-1);

    /// @brief Gets whether the given height is the height for an "unused" node.
    static constexpr bool IsUnused(Height value) noexcept
    {
        return value == InvalidHeight;
    }

    /// @brief Gets whether the given height is the height for a "leaf" node.
    static constexpr bool IsLeaf(Height value) noexcept
    {
        return value == 0;
    }

    /// @brief Gets whether the given height is a height for a "branch" node.
    static constexpr bool IsBranch(Height value) noexcept
    {
        return !IsUnused(value) && !IsLeaf(value);
    }

    /// @brief Non-throwing default constructor.
    /// @post <code>GetNodeCapacity()</code> returns 0.
    /// @post <code>GetNodeCount()</code> returns 0.
    /// @post <code>GetFreeIndex()</code> and <code>GetRootIndex()</code> return
    ///   <code>InvalidSize</code>.
    DynamicTree() noexcept;

    /// @brief Size initializing constructor.
    /// @param nodeCapacity Node capacity. If zero, this is the same as calling the
    ///   default constructor except this isn't recognized as non-throwing.
    /// @post <code>GetNodeCapacity()</code> returns value of the next power of two
    ///   of the result of @p nodeCapacity minus one, where a @p nodeCapacity of zero
    ///   results in <code>GetNodeCapacity()</code> returning zero.
    /// @post <code>GetNodeCount()</code> returns 0.
    /// @post <code>GetFreeIndex()</code> and <code>GetRootIndex()</code> return
    ///   <code>InvalidSize</code>.
    /// @throws std::bad_alloc If unable to allocate non-zero sized memory.
    explicit DynamicTree(Size nodeCapacity);

    /// @brief Copy constructor.
    /// @throws std::bad_alloc If unable to allocate non-zero sized memory.
    DynamicTree(const DynamicTree& other);

    /// @brief Move constructor.
    DynamicTree(DynamicTree&& other) noexcept;

    /// @brief Destroys the tree, freeing the node pool.
    ~DynamicTree() noexcept;

    /// @brief Unifying assignment operator.
    /// @note This intentionally takes the argument by-value. Along with the move constructor,
    ///   this assignment operator effectively doubles up as both copy assignment and move
    ///   assignment support.
    /// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Copy-and-swap
    /// @see https://stackoverflow.com/a/3279550/7410358
    DynamicTree& operator=(DynamicTree other) noexcept;

    /// @brief Clears the dynamic tree.
    /// @details Clears the leafs and branches from this tree. This does not deallocate any
    ///    memory nor reduce this tree's capacity; this only reduces this tree's usage of that
    ///    capacity.
    /// @post <code>GetLeafCount()</code> will return 0.
    /// @post <code>GetNodeCount()</code> will return 0.
    /// @post <code>GetRootIndex()</code> will return <code>InvalidSize</code>.
    /// @post <code>GetFreeIndex()</code> will return 0 if this tree had any node capacity,
    ///   else the value of <code>InvalidSize</code>.
    void Clear() noexcept;

    /// @brief Creates a new leaf node.
    /// @details Creates a leaf node for a tight fitting AABB and the given data.
    /// @note The indices of leaf nodes that have been destroyed get reused for new nodes.
    /// @pre The number of leaves already allocated (as reported by <code>GetLeafCount()</code>)
    ///   is less than <code>std::numeric_limits<Size>::max()</code>.
    /// @pre The number of nodes already allocated (as reported by <code>GetNodeCount()</code>)
    ///   is at least one or two less than <code>std::numeric_limits<Size>::max()</code> depending
    ///   on whether root index is <code>InvalidSize</code> or not.
    /// @post If the root index had been the <code>InvalidSize</code>, then it will
    ///   be set to the index returned from this function.
    /// @post The leaf count per <code>GetLeafCount()</code> is incremented by one.
    /// @post The node count (as reported by <code>GetNodeCount()</code>) will be incremented by one
    ///   or two (if the root index had not been <code>InvalidSize</code>).
    /// @return The index of the created leaf node. This will be a value not equal to
    ///   <code>InvalidSize</code>.
    /// @throws std::bad_alloc If unable to allocate necessary memory. If this exception is
    ///   thrown, this function has no effect.
    /// @see GetLeafCount(), GetNodeCount()
    Size CreateLeaf(const AABB& aabb, const Contactable& data);

    /// @brief Destroys a leaf node.
    /// @param index Identifier of node to destroy.
    /// @pre @p index is less than <code>GetNodeCapacity()</code> and
    ///   <code>IsLeaf(GetNode(index).GetHeight())</code> is true.
    /// @post The leaf count per <code>GetLeafCount()</code> is decremented by one.
    /// @see GetLeafCount().
    void DestroyLeaf(Size index) noexcept;

    /// @brief Updates a leaf node with a new AABB value.
    /// @param index Leaf node's ID.
    /// @param aabb New axis aligned bounding box for the leaf node.
    /// @pre @p index is less than <code>GetNodeCapacity()</code> and
    ///   <code>IsLeaf(GetNode(index).GetHeight())</code> is true.
    void UpdateLeaf(Size index, const AABB& aabb);

    /// @brief Gets the node identified by the given identifier.
    /// @param index Identifier of node to get.
    /// @pre @p index is less than <code>GetNodeCapacity()</code>.
    const TreeNode& GetNode(Size index) const noexcept;

    /// @brief Gets the leaf data for the node identified by the given identifier.
    /// @param index Identifier of node to get the leaf data for.
    /// @pre @p index is less than <code>GetNodeCapacity()</code> and
    ///   <code>IsLeaf(GetNode(index).GetHeight())</code> is true.
    /// @return Leaf data for the specified node.
    Contactable GetLeafData(Size index) const noexcept;

    /// @brief Gets the AABB for a leaf or branch (a non-unused node).
    /// @param index Leaf or branch node's ID. Must be a valid ID.
    /// @pre @p index is less than <code>GetNodeCapacity()</code> and
    ///   <code>IsUnused(GetNode(index).GetHeight())</code> is false.
    AABB GetAABB(Size index) const noexcept;

    /// @brief Gets the height value for the identified node.
    /// @param index Identifier of node to get "height" for.
    /// @pre @p index is less than <code>GetNodeCapacity()</code>.
    Height GetHeight(Size index) const noexcept;

    /// @brief Gets the "other" index for the node at the given index.
    /// @note For unused nodes, this is the index to the "next" unused node.
    /// @note For used nodes (leaf or branch nodes), this is the index to the "parent" node.
    /// @param index Identifier of node to get "other" for.
    /// @pre This tree has a node capacity greater than the given index.
    /// @return The invalid index value or a value less than the node capacity.
    Size GetOther(Size index) const noexcept;

    /// @brief Gets the branch data for the identified node.
    /// @param index Identifier of node to get branch data for.
    /// @pre @p index is less than <code>GetNodeCapacity()</code>.
    DynamicTreeBranchData GetBranchData(Size index) const noexcept;

    /// @brief Gets the index of the "root" node if this tree has one.
    /// @note If the tree has a root node, then the "other" property of this node will be
    ///   the invalid size.
    /// @return <code>InvalidSize</code> if this tree is "empty", else index to "root" node.
    Size GetRootIndex() const noexcept;

    /// @brief Gets the free index.
    Size GetFreeIndex() const noexcept;

    /// @brief Builds an optimal tree.
    /// @note This operation is very expensive.
    /// @note Meant for testing.
    /// @throws std::bad_alloc If unable to allocate necessary memory.
    void RebuildBottomUp();

    /// @brief Shifts the world origin.
    /// @note Useful for large worlds.
    /// @note The shift formula is: <code>position -= newOrigin</code>.
    /// @param newOrigin the new origin with respect to the old origin.
    void ShiftOrigin(const Length2& newOrigin) noexcept;

    /// @brief Gets the current node capacity of this tree.
    /// @see Reserve.
    Size GetNodeCapacity() const noexcept;

    /// @brief Reserves at least as much capacity as requested.
    /// @throws std::bad_alloc If unable to allocate necessary memory. If this exception is
    ///   thrown, this function has no effect.
    /// @post <code>GetNodeCapacity()</code> returns a new capacity that's at least as much
    ///   as the requested capacity if that's greater than before.
    /// @post <code>GetFreeIndex()</code> returns the value of <code>GetNodeCount()</code> if the
    ///   new capacity is greater than before.
    /// @see GetNodeCapacity, GetFreeIndex, GetNodeCount.
    void Reserve(Size value);

    /// @brief Gets the current count of allocated nodes.
    /// @return Count of existing proxies (count of nodes currently allocated).
    Size GetNodeCount() const noexcept;

    /// @brief Gets the current leaf node count.
    /// @details Gets the current leaf node count.
    Size GetLeafCount() const noexcept;

    /// @brief Finds first node which references the given index.
    /// @note Primarily intended for unit testing and/or debugging.
    /// @return Index of node referencing the given index, or the value of
    ///   <code>InvalidSize</code>.
    Size FindReference(Size index) const noexcept;

    /// @brief Customized swap function for <code>DynamicTree</code> objects.
    /// @note This satisfies the <code>Swappable</code> named requirement.
    /// @see https://en.cppreference.com/w/cpp/named_req/Swappable
    friend void swap(DynamicTree& lhs, DynamicTree& rhs) noexcept;

private:
    /// @brief Allocates a node.
    /// @details This allocates a node from the free list that can be used as either a leaf
    ///   node or a branch node.
    /// @pre <code>GetNodeCapacity()</code> returns a value at least one greater than the value
    ///   returned from <code>GetNodeCount()</code>.
    /// @warning Behavior is not specified unless the number of nodes allocated (as reported by
    ///   <code>GetNodeCount()</code>) is less than <code>GetNodeCapacity()</code>.
    /// @note Call <code>Reserve(GetNodeCount() + 1u)</code> before this if uncertain of whether
    ///   any entries are available on the free list.
    /// @return Value not equal to <code>InvalidSize</code>.
    /// @see GetNodeCount()
    Size AllocateNode() noexcept;

    /// @brief Frees the specified node.
    /// @pre @p index is less than <code>GetNodeCapacity()</code>.
    /// @pre <code>GetNodeCount()</code> is greater than zero.
    /// @pre Specified node is not "unused".
    /// @pre Specified node's other index is the invalid size index.
    /// @pre Specified node isn't referenced by any other nodes.
    /// @post The free list links to the given index.
    void FreeNode(Size index) noexcept;

    Size m_nodeCount{0u}; ///< Node count. @details Count of currently allocated nodes.
    Size m_leafCount{0u}; ///< Leaf count. @details Count of currently allocated leaf nodes.
    Size m_rootIndex{
        InvalidSize}; ///< Index of root element in m_nodes or <code>InvalidSize</code>.
    Size m_freeIndex{InvalidSize}; ///< Free list. @details Index to free nodes.
    Size m_nodeCapacity{0u}; ///< Node capacity. @details Size of buffer allocated for nodes.
    TreeNode* m_nodes{nullptr}; ///< Nodes. @details Initialized on construction.
};

/// @brief Is unused.
/// @details Determines whether the given dynamic tree node is an unused node.
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsUnused(const DynamicTree::TreeNode& node) noexcept;

/// @brief Is leaf.
/// @details Determines whether the given dynamic tree node is a leaf node.
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsLeaf(const DynamicTree::TreeNode& node) noexcept;

/// @brief Is branch.
/// @details Determines whether the given dynamic tree node is a branch node.
///   Branch nodes have 2 indices to child nodes.
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsBranch(const DynamicTree::TreeNode& node) noexcept;

/// @brief A node in the dynamic tree.
/// @note Users do not interact with this directly.
/// @note By using indexes to other tree nodes, these don't need to be updated
///   if the memory for other nodes is relocated.
/// @note On some 64-bit architectures, pointers are 8-bytes, while indices need only be
///   4-bytes. So using indices can also save 4-bytes.
class DynamicTree::TreeNode
{
public:
    ~TreeNode() = default;

    /// @brief Copy constructor.
    constexpr TreeNode(const TreeNode& other) = default;

    /// @brief Move constructor.
    constexpr TreeNode(TreeNode&& other) = default;

    /// @brief Initializing constructor.
    constexpr explicit TreeNode(Size other = DynamicTree::InvalidSize) noexcept
        : m_other{other}
    {
        assert(IsUnused(GetHeight()));
    }

    /// @brief Initializing constructor.
    constexpr TreeNode(const Contactable& value, const AABB& aabb,
                       Size other = DynamicTree::InvalidSize) noexcept
        : m_aabb{aabb}, m_variant{value}, m_height{0}, m_other{other}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor.
    /// @pre @c height is a value such that <code>IsBranch(height)</code> is true.
    /// @pre Neither @c value.child1 nor @c value.child2 is equal to <code>InvalidSize</code>.
    constexpr TreeNode(const DynamicTreeBranchData& value, const AABB& aabb, Height height,
                       Size other = DynamicTree::InvalidSize) noexcept
        : m_aabb{aabb}, m_variant{value}, m_height{height}, m_other{other}
    {
        assert(IsBranch(height));
        assert(value.child1 != InvalidSize);
        assert(value.child2 != InvalidSize);
    }

    /// @brief Copy assignment operator.
    TreeNode& operator=(const TreeNode& other) = default;

    /// @brief Gets the node "height".
    constexpr Height GetHeight() const noexcept
    {
        return m_height;
    }

    /// @brief Gets the node's "other" index.
    constexpr Size GetOther() const noexcept
    {
        return m_other;
    }

    /// @brief Sets the node's "other" index to the given value.
    constexpr void SetOther(Size other) noexcept
    {
        m_other = other;
    }

    /// @brief Gets the node's AABB.
    /// @pre This node is not unused, i.e.: <code>IsUnused(GetHeight())</code> is false.
    constexpr AABB GetAABB() const noexcept
    {
        assert(!IsUnused(GetHeight()));
        return m_aabb;
    }

    /// @brief Sets the node's AABB.
    /// @pre This node is not unused, i.e.: <code>IsUnused(GetHeight())</code> is false.
    constexpr void SetAABB(const AABB& value) noexcept
    {
        assert(!IsUnused(GetHeight()));
        m_aabb = value;
    }

    /// @brief Gets the node as an "unused" value.
    /// @pre This node is unused, i.e.: <code>IsUnused(GetHeight())</code> is true.
    constexpr DynamicTreeUnusedData AsUnused() const noexcept
    {
        assert(IsUnused(GetHeight()));
        return m_variant.unused;
    }

    /// @brief Gets the node as a "leaf" value.
    /// @pre This node is a leaf, i.e.: <code>IsLeaf(GetHeight())</code> is true.
    constexpr Contactable AsLeaf() const noexcept
    {
        assert(IsLeaf(GetHeight()));
        return m_variant.leaf;
    }

    /// @brief Gets the node as a "branch" value.
    /// @pre This node is a branch, i.e.: <code>IsBranch(GetHeight())</code> is true.
    constexpr DynamicTreeBranchData AsBranch() const noexcept
    {
        assert(IsBranch(GetHeight()));
        return m_variant.branch;
    }

    /// @brief Gets the node as an "unused" value.
    /// @pre This node is unused, i.e.: <code>IsUnused(GetHeight())</code> is true.
    constexpr void Assign(const DynamicTreeUnusedData& v) noexcept
    {
        assert(IsUnused(GetHeight()));
        m_variant.unused = v;
        m_height = static_cast<Height>(-1);
    }

    /// @brief Gets the node as a "leaf" value.
    /// @pre This node is a leaf, i.e.: <code>IsLeaf(GetHeight())</code> is true.
    constexpr void Assign(const Contactable& v) noexcept
    {
        assert(IsLeaf(GetHeight()));
        m_variant.leaf = v;
        m_height = 0;
    }

    /// @brief Assigns the node as a "branch" value.
    /// @pre This node is a branch, i.e.: <code>IsBranch(GetHeight())</code> is true.
    /// @pre Neither @c v.child1 nor @c v.child2 is equal to <code>InvalidSize</code>.
    constexpr void Assign(const DynamicTreeBranchData& v, const AABB& bb, Height h) noexcept
    {
        assert(IsBranch(GetHeight()));
        assert(v.child1 != InvalidSize);
        assert(v.child2 != InvalidSize);
        assert(IsBranch(h));
        m_variant.branch = v;
        m_aabb = bb;
        m_height = h;
    }

private:
    /// @brief AABB.
    /// @note This field is unused for free nodes, else it's the minimally enclosing AABB
    ///   for the node.
    AABB m_aabb;

    /// @brief Variant data for the node.
    DynamicTreeVariantData m_variant{DynamicTreeUnusedData{}};

    /// @brief Height.
    /// @details "Height" for tree balancing.
    /// @note 0 if leaf node, <code>DynamicTree::InvalidHeight</code> if free (unallocated)
    ///   node, else branch node.
    Height m_height = InvalidHeight;

    /// @brief Index to "other" node.
    /// @note This is an index to the next node for a free node, else this is the index to the
    ///   parent node.
    Size m_other = DynamicTree::InvalidSize; ///< Index of another node.
};

inline DynamicTree::Size DynamicTree::GetRootIndex() const noexcept
{
    assert((m_rootIndex == InvalidSize && (m_leafCount == 0)) ||
           ((m_rootIndex < m_nodeCapacity) && (m_leafCount > 0) &&
            (GetOther(m_rootIndex) == InvalidSize)));
    return m_rootIndex;
}

inline DynamicTree::Size DynamicTree::GetFreeIndex() const noexcept
{
    return m_freeIndex;
}

inline DynamicTree::Size DynamicTree::GetNodeCapacity() const noexcept
{
    return m_nodeCapacity;
}

inline DynamicTree::Size DynamicTree::GetNodeCount() const noexcept
{
    return m_nodeCount;
}

inline DynamicTree::Size DynamicTree::GetLeafCount() const noexcept
{
    assert(((m_leafCount == 0) && (m_rootIndex == InvalidSize)) ||
           ((m_leafCount > 0) && (m_rootIndex != InvalidSize) &&
            (GetOther(m_rootIndex) == InvalidSize)));
    return m_leafCount;
}

inline const DynamicTree::TreeNode& DynamicTree::GetNode(Size index) const noexcept
{
    assert(index != InvalidSize);
    assert(index < GetNodeCapacity());
    return *(m_nodes + index); // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
}

inline DynamicTree::Height DynamicTree::GetHeight(Size index) const noexcept
{
    return GetNode(index).GetHeight();
}

inline DynamicTree::Size DynamicTree::GetOther(Size index) const noexcept
{
    return GetNode(index).GetOther();
}

inline AABB DynamicTree::GetAABB(Size index) const noexcept
{
    const auto& node = GetNode(index);
    assert(!IsUnused(node.GetHeight()));
    return node.GetAABB();
}

inline DynamicTreeBranchData DynamicTree::GetBranchData(Size index) const noexcept
{
    const auto& node = GetNode(index);
    assert(IsBranch(node.GetHeight()));
    return node.AsBranch();
}

inline Contactable DynamicTree::GetLeafData(Size index) const noexcept
{
    const auto& node = GetNode(index);
    assert(IsLeaf(node.GetHeight()));
    return node.AsLeaf();
}

// Free functions...

/// @brief Finds index of node matching given contactble using a linear search.
/// @return Node index or <code>DynamicTree::InvalidSize</code>.
/// @see DynamicTree::InvalidSize.
/// @relatedalso DynamicTree
auto FindIndex(const DynamicTree &tree, const Contactable &c) noexcept -> DynamicTree::Size;

/// @brief Replaces the old child with the new child.
/// @pre Either @c bd.child1 or @c bd.child2 is equal to @c oldChild .
constexpr DynamicTreeBranchData ReplaceChild(DynamicTreeBranchData bd, DynamicTree::Size oldChild,
                                             DynamicTree::Size newChild)
{
    assert(bd.child1 == oldChild || bd.child2 == oldChild);
    return (bd.child1 == oldChild) ? DynamicTreeBranchData{newChild, bd.child2}
                                   : DynamicTreeBranchData{bd.child1, newChild};
}

/// @brief Whether this node is free (or allocated).
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsUnused(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsUnused(node.GetHeight());
}

/// @brief Whether or not this node is a leaf node.
/// @note This has constant complexity.
/// @return <code>true</code> if this is a leaf node, <code>false</code> otherwise.
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsLeaf(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsLeaf(node.GetHeight());
}

/// @brief Is branch.
/// @details Determines whether the given node is a "branch" node.
/// @relatedalso DynamicTree::TreeNode
constexpr bool IsBranch(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsBranch(node.GetHeight());
}

/// @brief Gets the AABB of the given dynamic tree node.
/// @pre @c node must be a used node. I.e. <code>IsUnused(node)</code> must be false.
/// @relatedalso DynamicTree::TreeNode
constexpr AABB GetAABB(const DynamicTree::TreeNode& node) noexcept
{
    assert(!IsUnused(node));
    return node.GetAABB();
}

/// @brief Gets the next index of the given node.
/// @pre The given node is unused, i.e.: <code>IsUnused(node)</code> is true.
/// @relatedalso DynamicTree::TreeNode
constexpr DynamicTree::Size GetNext(const DynamicTree::TreeNode& node) noexcept
{
    assert(IsUnused(node));
    return node.GetOther();
}

/// @brief Gets the height of the binary tree.
/// @return Height of the tree (as stored in the root node) or 0 if the root node is not valid.
/// @relatedalso DynamicTree
inline DynamicTree::Height GetHeight(const DynamicTree& tree) noexcept
{
    const auto index = tree.GetRootIndex();
    return (index != DynamicTree::InvalidSize) ? tree.GetHeight(index)
                                                    : DynamicTree::Height{0};
}

/// @brief Gets the AABB for the given dynamic tree.
/// @details Gets the AABB that encloses all other AABB instances that are within the
///   given dynamic tree.
/// @return Enclosing AABB or the "unset" AABB.
/// @relatedalso DynamicTree
inline AABB GetAABB(const DynamicTree& tree) noexcept
{
    const auto index = tree.GetRootIndex();
    return (index != DynamicTree::InvalidSize) ? tree.GetAABB(index) : AABB{};
}

/// @brief Tests for overlap of the elements identified in the given dynamic tree.
/// @relatedalso DynamicTree
inline bool TestOverlap(const DynamicTree& tree,
                        DynamicTree::Size leafIdA,
                        DynamicTree::Size leafIdB) noexcept
{
    return TestOverlap(tree.GetAABB(leafIdA), tree.GetAABB(leafIdB));
}

/// @brief Gets the sum of the perimeters of nodes.
/// @note Zero is returned if no proxies exist at the time of the call.
/// @return Value of zero or more.
Length ComputeTotalPerimeter(const DynamicTree& tree) noexcept;

/// @brief Gets the ratio of the sum of the perimeters of nodes to the root perimeter.
/// @note Zero is returned if no proxies exist at the time of the call.
/// @return Value of zero or more.
Real ComputePerimeterRatio(const DynamicTree& tree) noexcept;

/// @brief Computes the height of the tree from a given node.
/// @param tree Tree to compute the height at the given node for.
/// @param index ID of node to compute height from.
/// @pre @p index is less than <code>tree.GetNodeCapacity()</code>.
/// @return 0 unless the given index is to a branch node.
DynamicTree::Height ComputeHeight(const DynamicTree& tree, DynamicTree::Size index) noexcept;

/// @brief Computes the height of the given dynamic tree.
inline DynamicTree::Height ComputeHeight(const DynamicTree& tree) noexcept
{
    return ComputeHeight(tree, tree.GetRootIndex());
}

/// @brief Validates the structure of the given tree from the given index.
/// @note Meant for testing.
/// @return <code>true</code> if valid, <code>false</code> otherwise.
bool ValidateStructure(const DynamicTree& tree, DynamicTree::Size index) noexcept;

/// @brief Validates the metrics of the given tree from the given index.
/// @note Meant for testing.
/// @return <code>true</code> if valid, <code>false</code> otherwise.
bool ValidateMetrics(const DynamicTree& tree, DynamicTree::Size index) noexcept;

/// @brief Gets the maximum imbalance.
/// @details This gets the maximum imbalance of nodes in the given tree.
/// @note The imbalance is the difference in height of the two children of a node.
DynamicTree::Height GetMaxImbalance(const DynamicTree& tree) noexcept;

/// @brief Opcodes for dynamic tree callbacks.
enum class DynamicTreeOpcode {
    End,
    Continue,
};

/// @brief Query callback type.
using DynamicTreeSizeCB = std::function<DynamicTreeOpcode(DynamicTree::Size)>;

/// @brief Query the given dynamic tree and find nodes overlapping the given AABB.
/// @note The callback instance is called for each leaf node that overlaps the supplied AABB.
void Query(const DynamicTree& tree, const AABB& aabb, const DynamicTreeSizeCB& callback);

/// @brief Query AABB for fixtures callback function type.
/// @note Returning true will continue the query. Returning false will terminate the query.
using QueryShapeCallback = std::function<bool(BodyID body, ShapeID shape, ChildCounter child)>;

/// @brief Queries the world for all fixtures that potentially overlap the provided AABB.
/// @param tree Dynamic tree to do the query over.
/// @param aabb The query box.
/// @param callback User implemented callback function.
void Query(const DynamicTree& tree, const AABB& aabb, QueryShapeCallback callback);

/// @brief Gets the "size" of the given tree.
/// @note Size in this context is defined as the leaf count.
/// @note This provides ancillary support for the container named requirement's size function.
/// @see DynamicTree::GetLeafCount()
/// @see https://en.cppreference.com/w/cpp/named_req/Container
inline std::size_t size(const DynamicTree& tree) noexcept
{
    return tree.GetLeafCount();
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_DYNAMICTREE_HPP
