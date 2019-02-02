/*
 * Original work Copyright (c) 2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_DYNAMICTREE_HPP
#define PLAYRHO_COLLISION_DYNAMICTREE_HPP

/// @file
/// Declaration of the <code>DynamicTree</code> class.

#include "PlayRho/Collision/AABB.hpp"
#include "PlayRho/Common/Settings.hpp"

#include <functional>
#include <type_traits>
#include <utility>

namespace playrho {
namespace d2 {

class Fixture;
class Body;

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
/// @note This data structure is 32-bytes large (on at least one 64-bit platform).
///
/// @sa http://www.randygaul.net/2013/08/06/dynamic-aabb-tree/
/// @sa http://www.cs.utah.edu/~thiago/papers/rotations.pdf ("Fast, Effective
///    BVH Updates for Animated Scenes")
///
class DynamicTree
{
public:
    /// @brief Size type.
    using Size = ContactCounter;
    
    class TreeNode;
    struct UnusedData;
    struct BranchData;
    struct LeafData;
    union VariantData;
    
    /// @brief Gets the invalid size value.
    static PLAYRHO_CONSTEXPR inline Size GetInvalidSize() noexcept
    {
        return static_cast<Size>(-1);
    }
    
    /// @brief Type for heights.
    /// @note The maximum height of a tree can never exceed half of the max value of the
    ///   <code>Size</code> type due to the binary nature of this tree structure.
    using Height = ContactCounter;
    
    /// @brief Invalid height constant value.
    static PLAYRHO_CONSTEXPR const auto InvalidHeight = static_cast<Height>(-1);

    /// @brief Gets the invalid height value.
    static PLAYRHO_CONSTEXPR inline Height GetInvalidHeight() noexcept
    {
        return InvalidHeight;
    }
    
    /// @brief Gets whether the given height is the height for an "unused" node.
    static PLAYRHO_CONSTEXPR inline bool IsUnused(Height value) noexcept
    {
        return value == GetInvalidHeight();
    }
    
    /// @brief Gets whether the given height is the height for a "leaf" node.
    static PLAYRHO_CONSTEXPR inline bool IsLeaf(Height value) noexcept
    {
        return value == 0;
    }
    
    /// @brief Gets whether the given height is a height for a "branch" node.
    static PLAYRHO_CONSTEXPR inline bool IsBranch(Height value) noexcept
    {
        return !IsUnused(value) && !IsLeaf(value);
    }

    /// @brief Gets the default initial node capacity.
    static PLAYRHO_CONSTEXPR inline Size GetDefaultInitialNodeCapacity() noexcept;
    
    /// @brief Default constructor.
    DynamicTree() noexcept;
    
    /// @brief Size initializing constructor.
    explicit DynamicTree(Size nodeCapacity);

    /// @brief Destroys the tree, freeing the node pool.
    ~DynamicTree() noexcept;

    /// @brief Copy constructor.
    DynamicTree(const DynamicTree& other);
    
    /// @brief Move constructor.
    DynamicTree(DynamicTree&& other) noexcept;

    /// @brief Unifying assignment operator.
    /// @note This intentionally takes the argument by-value. Along with the move constructor,
    ///   this assignment method effectively doubles up as both copy assignment and move
    ///   assignment support.
    /// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Copy-and-swap
    /// @see https://stackoverflow.com/a/3279550/7410358
    DynamicTree& operator= (DynamicTree other) noexcept;
    
    /// @brief Creates a new leaf node.
    /// @details Creates a leaf node for a tight fitting AABB and the given data.
    /// @note The indices of leaf nodes that have been destroyed get reused for new nodes.
    /// @post If the root index had been the <code>GetInvalidSize()</code>, then it will
    ///   be set to the index returned from this method.
    /// @post The leaf count will be incremented by one.
    /// @return The index of the created leaf node.
    Size CreateLeaf(const AABB& aabb, const LeafData& data);

    /// @brief Destroys a leaf node.
    /// @post The leaf count will be decremented by one.
    /// @warning Behavior is undefined if the given index is not valid.
    void DestroyLeaf(Size index) noexcept;

    /// @brief Updates a leaf node with a new AABB value.
    /// @warning Behavior is undefined if the given index is not valid.
    /// @param index Leaf node's ID. Behavior is undefined if this is not a valid ID.
    /// @param aabb New axis aligned bounding box for the leaf node.
    void UpdateLeaf(Size index, const AABB& aabb);

    /// @brief Gets the user data for the node identified by the given identifier.
    /// @warning Behavior is undefined if the given index is not valid.
    /// @param index Identifier of node to get the user data for.
    /// @return User data for the specified node.
    LeafData GetLeafData(Size index) const noexcept;

    /// @brief Sets the leaf data for the element at the given index to the given value.
    void SetLeafData(Size index, LeafData value) noexcept;

    /// @brief Gets the AABB for a leaf or branch (a non-unused node).
    /// @warning Behavior is undefined if the given index is not valid.
    /// @param index Leaf or branch node's ID. Must be a valid ID.
    AABB GetAABB(Size index) const noexcept;

    /// @brief Gets the height value for the identified node.
    /// @warning Behavior is undefined if the given index is not valid.
    Height GetHeight(Size index) const noexcept;
    
    /// @brief Gets the "other" index for the node at the given index.
    /// @note For unused nodes, this is the index to the "next" unused node.
    /// @note For used nodes (leaf or branch nodes), this is the index to the "parent" node.
    /// @warning Behavior is undefined if the given index is not valid.
    /// @pre This tree has a node capacity greater than the given index.
    /// @return The invalid index value or a value less than the node capacity.
    Size GetOther(Size index) const noexcept;
    
    /// @brief Gets the branch data for the identified node.
    /// @warning Behavior is undefined if the given index in not a valid branch node.
    BranchData GetBranchData(Size index) const noexcept;

    /// @brief Gets the index of the "root" node if this tree has one.
    /// @note If the tree has a root node, then the "other" property of this node will be
    ///   the invalid size.
    /// @return <code>GetInvalidSize()</code> if this tree is "empty", else index to "root" node.
    Size GetRootIndex() const noexcept;

    /// @brief Gets the free index.
    Size GetFreeIndex() const noexcept;

    /// @brief Builds an optimal tree.
    /// @note This operation is very expensive.
    /// @note Meant for testing.
    void RebuildBottomUp();

    /// @brief Shifts the world origin.
    /// @note Useful for large worlds.
    /// @note The shift formula is: <code>position -= newOrigin</code>.
    /// @param newOrigin the new origin with respect to the old origin.
    void ShiftOrigin(Length2 newOrigin);

    /// @brief Gets the current node capacity of this tree.
    Size GetNodeCapacity() const noexcept;

    /// @brief Gets the current count of allocated nodes.
    /// @return Count of existing proxies (count of nodes currently allocated).
    Size GetNodeCount() const noexcept;
    
    /// @brief Gets the current leaf node count.
    /// @details Gets the current leaf node count.
    Size GetLeafCount() const noexcept;
    
    /// @brief Finds first node which references the given index.
    /// @note Primarily intended for unit testing and/or debugging.
    /// @return Index of node referencing the given index, or the value of
    ///   <code>GetInvalidSize()</code>.
    Size FindReference(Size index) const noexcept;

    /// @brief Customized swap function for <code>DynamicTree</code> objects.
    /// @note This satisfies the <code>Swappable</code> concept.
    /// @see http://en.cppreference.com/w/cpp/concept/Swappable
    friend void swap(DynamicTree& lhs, DynamicTree& rhs) noexcept;
    
private:
    
    /// @brief Sets the node capacity to the given value.
    void SetNodeCapacity(Size value) noexcept;

    /// @brief Allocates a node.
    /// @details This allocates a node from the free list that can be used as either a leaf
    ///   node or a branch node.
    Size AllocateNode() noexcept;

    /// @brief Allocates a leaf node.
    /// @details This allocates a node from the free list as a leaf node.
    Size AllocateNode(const LeafData& data, AABB aabb) noexcept;

    /// @brief Allocates a branch node.
    /// @details This allocates a node from the free list as a branch node.
    /// @post The free list no longer references the returned index.
    Size AllocateNode(const BranchData& data, AABB aabb, Height height,
                      Size parent = GetInvalidSize()) noexcept;
 
    /// @brief Frees the specified node.
    ///
    /// @warning Behavior is undefined if the given index is not valid.
    /// @warning Specified node must be a "leaf" or "branch" node.
    ///
    /// @pre Specified node's other index is the invalid size index.
    /// @pre Specified node isn't referenced by any other nodes.
    /// @post The free list links to the given index.
    ///
    void FreeNode(Size index) noexcept;
    
    TreeNode* m_nodes{nullptr}; ///< Nodes. @details Initialized on construction.
    Size m_rootIndex{GetInvalidSize()}; ///< Index of root element in m_nodes or <code>GetInvalidSize()</code>.
    Size m_freeIndex{GetInvalidSize()}; ///< Free list. @details Index to free nodes.
    Size m_nodeCount{0u}; ///< Node count. @details Count of currently allocated nodes.
    Size m_nodeCapacity{0u}; ///< Node capacity. @details Size of buffer allocated for nodes.
    Size m_leafCount{0u}; ///< Leaf count. @details Count of currently allocated leaf nodes.
};

/// @brief Unused data of a tree node.
/// @note This exists for symmetry and as placeholder in case this needs to later be used.
struct DynamicTree::UnusedData
{
    // Intentionally empty.
};

/// @brief Branch data of a tree node.
struct DynamicTree::BranchData
{
    Size child1; ///< @brief Child 1.
    Size child2; ///< @brief Child 2.
};

/// @brief Leaf data of a tree node.
/// @details This is the leaf node specific data for a <code>DynamicTree::TreeNode</code>.
///   It's data that only pertains to leaf nodes.
/// @note This class is used in the <code>DynamicTree::VariantData</code> union within a
///   <code>DynamicTree::TreeNode</code>.
///   This has ramifications on this class's data contents and size.
struct DynamicTree::LeafData
{
    // In terms of what needs to be in this structure, it minimally needs to have enough
    // information in it to identify the child shape for which the node's AABB represents,
    // and its associated body. A pointer to the fixture and the index of the child in
    // its shape could suffice for this. Meanwhile, a Contact is defined to be the
    // recognition of an overlap between two child shapes having different bodies making
    // the caching of the bodies a potential speed-up opportunity.

    /// @brief Cached pointer to associated body.
    /// @note This field serves merely to potentially avoid the lookup of the body through
    ///   the fixture. It may or may not be worth the extra 8-bytes or so required for it.
    /// @note On 64-bit architectures, this is an 8-byte sized field. As an 8-byte field it
    ///   conceptually identifies 2^64 separate bodies within a world. As a practical matter
    ///   however, even a 4-byte index which could identify 2^32 bodies, is still larger than
    ///   is usable. This suggests that space could be saved by using indexes into arrays of
    ///   bodies instead of direct pointers to memory.
    Body* body;
    
    /// @brief Pointer to associated Fixture.
    /// @note On 64-bit architectures, this is an 8-byte sized field. As an 8-byte field it
    ///   conceptually identifies 2^64 separate fixtures within a world. As a practical matter
    ///   however, even a 4-byte index which could identify 2^32 fixtures, is still larger than
    ///   is usable. This suggests that space could be saved by using indexes into arrays of
    ///   fixtures instead of direct pointers to memory.
    Fixture* fixture;

    /// @brief Child index of related Shape.
    ChildCounter childIndex;
};

/// @brief Equality operator.
/// @relatedalso DynamicTree::LeafData
PLAYRHO_CONSTEXPR inline bool operator== (const DynamicTree::LeafData& lhs,
                                          const DynamicTree::LeafData& rhs) noexcept
{
    return lhs.fixture == rhs.fixture && lhs.childIndex == rhs.childIndex;
}

/// @brief Inequality operator.
/// @relatedalso DynamicTree::LeafData
PLAYRHO_CONSTEXPR inline bool operator!= (const DynamicTree::LeafData& lhs,
                                          const DynamicTree::LeafData& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Variant data.
/// @note A union is used intentionally to save space.
union DynamicTree::VariantData
{
    /// @brief Unused/free-list specific data.
    UnusedData unused;
    
    /// @brief Leaf specific data.
    LeafData leaf;
    
    /// @brief Branch specific data.
    BranchData branch;
    
    /// @brief Default constructor.
    VariantData() noexcept = default;
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline VariantData(UnusedData value) noexcept: unused{value} {}
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline VariantData(LeafData value) noexcept: leaf{value} {}
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline VariantData(BranchData value) noexcept: branch{value} {}
};

/// @brief Is unused.
/// @details Determines whether the given dynamic tree node is an unused node.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsUnused(const DynamicTree::TreeNode& node) noexcept;

/// @brief Is leaf.
/// @details Determines whether the given dynamic tree node is a leaf node.
///   Leaf nodes have a pointer to user data.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsLeaf(const DynamicTree::TreeNode& node) noexcept;

/// @brief Is branch.
/// @details Determines whether the given dynamic tree node is a branch node.
///   Branch nodes have 2 indices to child nodes.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsBranch(const DynamicTree::TreeNode& node) noexcept;

/// @brief A node in the dynamic tree.
/// @note Users do not interact with this directly.
/// @note By using indexes to other tree nodes, these don't need to be updated
///   if the memory for other nodes is relocated.
/// @note On some 64-bit architectures, pointers are 8-bytes, while indices need only be
///   4-bytes. So using indices can also save 4-bytes.
/// @note This data structure is 48-bytes large on at least one 64-bit platform.
class DynamicTree::TreeNode
{
public:
    ~TreeNode() = default;
    
    /// @brief Copy constructor.
    PLAYRHO_CONSTEXPR inline TreeNode(const TreeNode& other) = default;

    /// @brief Move constructor.
    PLAYRHO_CONSTEXPR inline TreeNode(TreeNode&& other) = default;

    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit TreeNode(Size other = DynamicTree::GetInvalidSize()) noexcept:
        m_other{other}
    {
        assert(IsUnused(m_height));
    }

    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline TreeNode(const LeafData& value, AABB aabb,
                                      Size other = DynamicTree::GetInvalidSize()) noexcept:
        m_height{0}, m_other{other}, m_aabb{aabb}, m_variant{value}
    {
        // Intentionally empty.
    }
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline TreeNode(const BranchData& value, AABB aabb, Height height,
                       Size other = DynamicTree::GetInvalidSize()) noexcept:
        m_height{height}, m_other{other}, m_aabb{aabb}, m_variant{value}
    {
        assert(IsBranch(height));
        assert(value.child1 != GetInvalidSize());
        assert(value.child2 != GetInvalidSize());
    }
    
    /// @brief Copy assignment operator.
    TreeNode& operator= (const TreeNode& other) = default;
    
    /// @brief Gets the node "height".
    PLAYRHO_CONSTEXPR inline Height GetHeight() const noexcept
    {
        return m_height;
    }
    
    /// @brief Gets the node's "other" index.
    PLAYRHO_CONSTEXPR inline Size GetOther() const noexcept
    {
        return m_other;
    }
                
    /// @brief Sets the node's "other" index to the given value.
    PLAYRHO_CONSTEXPR inline void SetOther(Size other) noexcept
    {
        m_other = other;
    }

    /// @brief Gets the node's AABB.
    /// @warning Behavior is undefined if called on a free/unused node!
    PLAYRHO_CONSTEXPR inline AABB GetAABB() const noexcept
    {
        assert(!IsUnused(m_height));
        return m_aabb;
    }

    /// @brief Sets the node's AABB.
    /// @warning Behavior is undefined if called on a free/unused node!
    PLAYRHO_CONSTEXPR inline void SetAABB(AABB value) noexcept
    {
        assert(!IsUnused(m_height));
        m_aabb = value;
    }
    
    /// @brief Gets the node as an "unused" value.
    /// @warning Behavior is undefined unless called on a free/unused node!
    PLAYRHO_CONSTEXPR inline UnusedData AsUnused() const noexcept
    {
        assert(IsUnused(m_height));
        return m_variant.unused;
    }
    
    /// @brief Gets the node as a "leaf" value.
    /// @warning Behavior is undefined unless called on a leaf node!
    PLAYRHO_CONSTEXPR inline LeafData AsLeaf() const noexcept
    {
        assert(IsLeaf(m_height));
        return m_variant.leaf;
    }
    
    /// @brief Gets the node as a "branch" value.
    /// @warning Behavior is undefined unless called on a branch node!
    PLAYRHO_CONSTEXPR inline BranchData AsBranch() const noexcept
    {
        assert(IsBranch(m_height));
        return m_variant.branch;
    }

    /// @brief Gets the node as an "unused" value.
    PLAYRHO_CONSTEXPR inline void Assign(const UnusedData& v) noexcept
    {
        m_variant.unused = v;
        m_height = static_cast<Height>(-1);
    }
    
    /// @brief Gets the node as a "leaf" value.
    PLAYRHO_CONSTEXPR inline void Assign(const LeafData& v) noexcept
    {
        m_variant.leaf = v;
        m_height = 0;
    }
    
    /// @brief Assigns the node as a "branch" value.
    PLAYRHO_CONSTEXPR inline void Assign(const BranchData& v, const AABB& bb, Height h) noexcept
    {
        assert(v.child1 != GetInvalidSize());
        assert(v.child2 != GetInvalidSize());
        assert(IsBranch(h));
        m_variant.branch = v;
        m_aabb = bb;
        m_height = h;
    }

private:
    /// @brief Height.
    /// @details "Height" for tree balancing.
    /// @note 0 if leaf node, <code>DynamicTree::GetInvalidHeight()</code> if free (unallocated)
    ///   node, else branch node.
    Height m_height = GetInvalidHeight();

    /// @brief Index to "other" node.
    /// @note This is an index to the next node for a free node, else this is the index to the
    ///   parent node.
    Size m_other = DynamicTree::GetInvalidSize(); ///< Index of another node.
    
    /// @brief AABB.
    /// @note This field is unused for free nodes, else it's the minimally enclosing AABB
    ///   for the node.
    AABB m_aabb;
    
    /// @brief Variant data for the node.
    VariantData m_variant{UnusedData{}};
};

PLAYRHO_CONSTEXPR inline DynamicTree::Size DynamicTree::GetDefaultInitialNodeCapacity() noexcept
{
    return Size{64};
}

inline DynamicTree::Size DynamicTree::GetRootIndex() const noexcept
{
    assert((m_rootIndex == GetInvalidSize() && (m_leafCount == 0)) ||
           ((m_rootIndex < m_nodeCapacity) && (m_leafCount > 0) && (GetOther(m_rootIndex) == GetInvalidSize())));
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
    assert(((m_leafCount == 0) && (m_rootIndex == GetInvalidSize())) ||
           ((m_leafCount > 0) && (m_rootIndex != GetInvalidSize()) && (GetOther(m_rootIndex) == GetInvalidSize())));
    return m_leafCount;
}

inline DynamicTree::Height DynamicTree::GetHeight(Size index) const noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    return m_nodes[index].GetHeight();
}

inline DynamicTree::Size DynamicTree::GetOther(Size index) const noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    return m_nodes[index].GetOther();
}

inline AABB DynamicTree::GetAABB(Size index) const noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    assert(!IsUnused(m_nodes[index].GetHeight()));
    return m_nodes[index].GetAABB();
}

inline DynamicTree::BranchData DynamicTree::GetBranchData(Size index) const noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    assert(IsBranch(m_nodes[index].GetHeight()));
    return m_nodes[index].AsBranch();
}

inline DynamicTree::LeafData DynamicTree::GetLeafData(Size index) const noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    assert(IsLeaf(m_nodes[index].GetHeight()));
    return m_nodes[index].AsLeaf();
}

inline void DynamicTree::SetLeafData(Size index, LeafData value) noexcept
{
    assert(index != GetInvalidSize());
    assert(index < m_nodeCapacity);
    assert(IsLeaf(m_nodes[index].GetHeight()));
    m_nodes[index].AsLeaf() = value;
}

// Free functions...

/// @brief Replaces the old child with the new child.
PLAYRHO_CONSTEXPR inline DynamicTree::BranchData
ReplaceChild(DynamicTree::BranchData bd, DynamicTree::Size oldChild, DynamicTree::Size newChild)
{
    assert(bd.child1 == oldChild || bd.child2 == oldChild);
    return (bd.child1 == oldChild)?
        DynamicTree::BranchData{newChild, bd.child2}: DynamicTree::BranchData{bd.child1, newChild};
}

/// @brief Whether this node is free (or allocated).
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsUnused(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsUnused(node.GetHeight());
}

/// @brief Whether or not this node is a leaf node.
/// @note This has constant complexity.
/// @return <code>true</code> if this is a leaf node, <code>false</code> otherwise.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsLeaf(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsLeaf(node.GetHeight());
}

/// @brief Is branch.
/// @details Determines whether the given node is a "branch" node.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline bool IsBranch(const DynamicTree::TreeNode& node) noexcept
{
    return DynamicTree::IsBranch(node.GetHeight());
}

/// @brief Gets the AABB of the given dynamic tree node.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline AABB GetAABB(const DynamicTree::TreeNode& node) noexcept
{
    assert(!IsUnused(node));
    return node.GetAABB();
}

/// @brief Gets the next index of the given node.
/// @warning Behavior is undefined if the given node is not an "unused" node.
/// @relatedalso DynamicTree::TreeNode
PLAYRHO_CONSTEXPR inline DynamicTree::Size GetNext(const DynamicTree::TreeNode& node) noexcept
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
    return (index != DynamicTree::GetInvalidSize())? tree.GetHeight(index): DynamicTree::Height{0};
}

/// @brief Gets the AABB for the given dynamic tree.
/// @details Gets the AABB that encloses all other AABB instances that are within the
///   given dynamic tree.
/// @return Enclosing AABB or the "unset" AABB.
/// @relatedalso DynamicTree
inline AABB GetAABB(const DynamicTree& tree) noexcept
{
    const auto index = tree.GetRootIndex();
    return (index != DynamicTree::GetInvalidSize())? tree.GetAABB(index): AABB{};
}

/// @brief Tests for overlap of the elements identified in the given dynamic tree.
/// @relatedalso DynamicTree
inline bool TestOverlap(const DynamicTree& tree,
                        DynamicTree::Size leafIdA, DynamicTree::Size leafIdB) noexcept
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
/// @warning Behavior is undefined if the given index is not valid.
/// @param tree Tree to compute the height at the given node for.
/// @param index ID of node to compute height from.
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
enum class DynamicTreeOpcode
{
    End,
    Continue,
};

/// @brief Query callback type.
using DynamicTreeSizeCB = std::function<DynamicTreeOpcode(DynamicTree::Size)>;

/// @brief Query the given dynamic tree and find nodes overlapping the given AABB.
/// @note The callback instance is called for each leaf node that overlaps the supplied AABB.
void Query(const DynamicTree& tree, const AABB& aabb,
           const DynamicTreeSizeCB& callback);

/// @brief Query AABB for fixtures callback function type.
/// @note Returning true will continue the query. Returning false will terminate the query.
using QueryFixtureCallback = std::function<bool(Fixture* fixture, ChildCounter child)>;

/// @brief Queries the world for all fixtures that potentially overlap the provided AABB.
/// @param tree Dynamic tree to do the query over.
/// @param aabb The query box.
/// @param callback User implemented callback function.
void Query(const DynamicTree& tree, const AABB& aabb, QueryFixtureCallback callback);

/// @brief Gets the "size" of the given tree.
/// @note Size in this context is defined as the leaf count.
/// @note This provides ancillary support for the container concept's size method.
/// @see DynamicTree::GetLeafCount()
/// @see http://en.cppreference.com/w/cpp/concept/Container
inline std::size_t size(const DynamicTree& tree) noexcept
{
    return tree.GetLeafCount();
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_DYNAMICTREE_HPP
