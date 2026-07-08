use super::types::{euler_deg_from_quaternion, quaternion_from_euler_deg, Mat4, Quaternion, Vec3};
use super::{next_handle, Dora3DHandle, INVALID_HANDLE};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct Node3DData {
    pub handle: Dora3DHandle,
    pub parent: Option<Dora3DHandle>,
    pub children: Vec<Dora3DHandle>,
    pub order: i32,
    pub tag: String,
    pub visible: bool,
    pub position: Vec3,
    pub scale: Vec3,
    pub euler_deg: Vec3,
    pub rotation: Quaternion,
    pub local_matrix: Mat4,
    pub world_matrix: Mat4,
    pub local_dirty: bool,
    pub world_dirty: bool,
}

impl Node3DData {
    fn new(handle: Dora3DHandle) -> Self {
        Self {
            handle,
            parent: None,
            children: Vec::new(),
            order: 0,
            tag: String::new(),
            visible: true,
            position: Vec3::ZERO,
            scale: Vec3::ONE,
            euler_deg: Vec3::ZERO,
            rotation: Quaternion::IDENTITY,
            local_matrix: Mat4::IDENTITY,
            world_matrix: Mat4::IDENTITY,
            local_dirty: true,
            world_dirty: true,
        }
    }

    fn rebuild_local_matrix(&mut self) {
        self.local_matrix =
            Mat4::from_scale_rotation_translation(self.scale, self.rotation, self.position);
        self.local_dirty = false;
    }
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, Node3DData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, Node3DData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn mark_subtree_world_dirty(nodes: &mut HashMap<Dora3DHandle, Node3DData>, handle: Dora3DHandle) {
    let children = match nodes.get_mut(&handle) {
        Some(node) => {
            node.world_dirty = true;
            node.children.clone()
        }
        None => return,
    };
    for child in children {
        mark_subtree_world_dirty(nodes, child);
    }
}

fn update_world_internal(
    nodes: &mut HashMap<Dora3DHandle, Node3DData>,
    handle: Dora3DHandle,
) -> Option<Mat4> {
    let (parent, local_dirty, world_dirty) = {
        let node = nodes.get(&handle)?;
        (node.parent, node.local_dirty, node.world_dirty)
    };
    if !local_dirty && !world_dirty {
        return nodes.get(&handle).map(|node| node.world_matrix);
    }
    let parent_world = if let Some(parent_handle) = parent {
        update_world_internal(nodes, parent_handle)?
    } else {
        Mat4::IDENTITY
    };
    let local = {
        let node = nodes.get_mut(&handle)?;
        if node.local_dirty {
            node.rebuild_local_matrix();
        }
        node.local_matrix
    };
    let world = parent_world * local;
    let node = nodes.get_mut(&handle)?;
    node.world_matrix = world;
    node.world_dirty = false;
    Some(world)
}

fn remove_child_link(
    nodes: &mut HashMap<Dora3DHandle, Node3DData>,
    parent: Dora3DHandle,
    child: Dora3DHandle,
) {
    if let Some(parent_node) = nodes.get_mut(&parent) {
        parent_node.children.retain(|candidate| *candidate != child);
    }
}

fn destroy_internal(nodes: &mut HashMap<Dora3DHandle, Node3DData>, handle: Dora3DHandle) {
    let (parent, children) = match nodes.remove(&handle) {
        Some(node) => (node.parent, node.children),
        None => return,
    };
    if let Some(parent_handle) = parent {
        remove_child_link(nodes, parent_handle, handle);
    }
    for child in children {
        if let Some(child_node) = nodes.get_mut(&child) {
            child_node.parent = None;
            child_node.world_dirty = true;
        }
    }
}

pub fn create() -> Dora3DHandle {
    let handle = next_handle();
    let mut nodes = registry().lock().unwrap();
    nodes.insert(handle, Node3DData::new(handle));
    handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    let mut nodes = registry().lock().unwrap();
    if !nodes.contains_key(&handle) {
        return false;
    }
    destroy_internal(&mut nodes, handle);
    true
}

fn clone_subtree_internal(
    nodes: &mut HashMap<Dora3DHandle, Node3DData>,
    source: Dora3DHandle,
    parent: Option<Dora3DHandle>,
    map: &mut HashMap<Dora3DHandle, Dora3DHandle>,
    cloned_nodes: &mut Vec<Dora3DHandle>,
) -> Option<Dora3DHandle> {
    let source_node = nodes.get(&source)?.clone();
    let handle = next_handle();
    let mut cloned = Node3DData::new(handle);
    cloned.parent = parent;
    cloned.order = source_node.order;
    cloned.tag = source_node.tag;
    cloned.visible = source_node.visible;
    cloned.position = source_node.position;
    cloned.scale = source_node.scale;
    cloned.euler_deg = source_node.euler_deg;
    cloned.rotation = source_node.rotation;
    cloned.local_dirty = true;
    cloned.world_dirty = true;
    nodes.insert(handle, cloned);
    map.insert(source, handle);
    cloned_nodes.push(handle);

    let mut children = Vec::new();
    for child in source_node.children {
        if let Some(cloned_child) =
            clone_subtree_internal(nodes, child, Some(handle), map, cloned_nodes)
        {
            children.push(cloned_child);
        }
    }
    if let Some(cloned_node) = nodes.get_mut(&handle) {
        cloned_node.children = children;
    }
    Some(handle)
}

pub fn clone_subtree(
    source: Dora3DHandle,
) -> Option<(
    Dora3DHandle,
    HashMap<Dora3DHandle, Dora3DHandle>,
    Vec<Dora3DHandle>,
)> {
    let mut nodes = registry().lock().unwrap();
    if !nodes.contains_key(&source) {
        return None;
    }
    let mut map = HashMap::new();
    let mut cloned_nodes = Vec::new();
    let root = clone_subtree_internal(&mut nodes, source, None, &mut map, &mut cloned_nodes)?;
    Some((root, map, cloned_nodes))
}

pub fn exists(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().contains_key(&handle)
}

pub fn add_child(parent: Dora3DHandle, child: Dora3DHandle, order: i32, tag: Option<&str>) -> bool {
    if parent == INVALID_HANDLE || child == INVALID_HANDLE || parent == child {
        return false;
    }
    let mut nodes = registry().lock().unwrap();
    if !nodes.contains_key(&parent) || !nodes.contains_key(&child) {
        return false;
    }
    let old_parent = nodes.get(&child).and_then(|node| node.parent);
    if let Some(old_parent_handle) = old_parent {
        remove_child_link(&mut nodes, old_parent_handle, child);
    }
    if let Some(child_node) = nodes.get_mut(&child) {
        child_node.parent = Some(parent);
        child_node.order = order;
        if let Some(tag_value) = tag {
            child_node.tag = tag_value.to_owned();
        }
        child_node.world_dirty = true;
    }
    let mut children = nodes
        .get(&parent)
        .map(|parent_node| parent_node.children.clone())
        .unwrap_or_default();
    children.retain(|candidate| *candidate != child);
    children.push(child);
    let mut ordered_children: Vec<(Dora3DHandle, i32)> = children
        .into_iter()
        .map(|candidate| {
            let order = nodes
                .get(&candidate)
                .map(|node| node.order)
                .unwrap_or_default();
            (candidate, order)
        })
        .collect();
    ordered_children.sort_by_key(|(_, order_value)| *order_value);
    if let Some(parent_node) = nodes.get_mut(&parent) {
        parent_node.children = ordered_children
            .into_iter()
            .map(|(candidate, _)| candidate)
            .collect();
    }
    mark_subtree_world_dirty(&mut nodes, child);
    true
}

pub fn remove_from_parent(child: Dora3DHandle) -> bool {
    let mut nodes = registry().lock().unwrap();
    let parent = match nodes.get(&child).and_then(|node| node.parent) {
        Some(parent) => parent,
        None => return false,
    };
    remove_child_link(&mut nodes, parent, child);
    if let Some(child_node) = nodes.get_mut(&child) {
        child_node.parent = None;
    }
    mark_subtree_world_dirty(&mut nodes, child);
    true
}

pub fn remove_child(parent: Dora3DHandle, child: Dora3DHandle) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(child_node) = nodes.get(&child) else {
        return false;
    };
    if child_node.parent != Some(parent) {
        return false;
    }
    remove_child_link(&mut nodes, parent, child);
    if let Some(child_node) = nodes.get_mut(&child) {
        child_node.parent = None;
    }
    mark_subtree_world_dirty(&mut nodes, child);
    true
}

pub fn set_position(handle: Dora3DHandle, position: Vec3) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.position = position;
    node.local_dirty = true;
    mark_subtree_world_dirty(&mut nodes, handle);
    true
}

pub fn get_position(handle: Dora3DHandle) -> Option<Vec3> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.position)
}

pub fn set_scale(handle: Dora3DHandle, scale: Vec3) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.scale = scale;
    node.local_dirty = true;
    mark_subtree_world_dirty(&mut nodes, handle);
    true
}

pub fn get_scale(handle: Dora3DHandle) -> Option<Vec3> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.scale)
}

pub fn set_rotation(handle: Dora3DHandle, rotation: Quaternion) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.rotation = rotation;
    node.euler_deg = euler_deg_from_quaternion(rotation);
    node.local_dirty = true;
    mark_subtree_world_dirty(&mut nodes, handle);
    true
}

pub fn set_euler_deg(handle: Dora3DHandle, euler_deg: Vec3) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.euler_deg = euler_deg;
    node.rotation = quaternion_from_euler_deg(euler_deg);
    node.local_dirty = true;
    mark_subtree_world_dirty(&mut nodes, handle);
    true
}

pub fn get_rotation(handle: Dora3DHandle) -> Option<Quaternion> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.rotation)
}

pub fn get_euler_deg(handle: Dora3DHandle) -> Option<Vec3> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.euler_deg)
}

pub fn set_tag(handle: Dora3DHandle, tag: &str) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.tag = tag.to_owned();
    true
}

pub fn get_tag(handle: Dora3DHandle) -> Option<String> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.tag.clone())
}

pub fn set_visible(handle: Dora3DHandle, visible: bool) -> bool {
    let mut nodes = registry().lock().unwrap();
    let Some(node) = nodes.get_mut(&handle) else {
        return false;
    };
    node.visible = visible;
    true
}

pub fn is_visible(handle: Dora3DHandle) -> bool {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.visible)
        .unwrap_or(false)
}

pub fn world_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    let mut nodes = registry().lock().unwrap();
    update_world_internal(&mut nodes, handle)
}

pub fn local_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    let mut nodes = registry().lock().unwrap();
    let node = nodes.get_mut(&handle)?;
    if node.local_dirty {
        node.rebuild_local_matrix();
    }
    Some(node.local_matrix)
}

pub fn convert_to_world_space(handle: Dora3DHandle, point: Vec3) -> Option<Vec3> {
    world_matrix(handle).map(|matrix| matrix.transform_point3(point))
}

pub fn convert_to_node_space(handle: Dora3DHandle, point: Vec3) -> Option<Vec3> {
    world_matrix(handle).map(|matrix| matrix.inverse().transform_point3(point))
}

pub fn traverse(root: Dora3DHandle) -> Vec<Dora3DHandle> {
    let mut nodes = registry().lock().unwrap();
    let mut ordered = Vec::new();
    traverse_internal(&mut nodes, root, &mut ordered);
    ordered
}

fn traverse_internal(
    nodes: &mut HashMap<Dora3DHandle, Node3DData>,
    handle: Dora3DHandle,
    ordered: &mut Vec<Dora3DHandle>,
) {
    if update_world_internal(nodes, handle).is_none() {
        return;
    }
    ordered.push(handle);
    let children = nodes
        .get(&handle)
        .map(|node| node.children.clone())
        .unwrap_or_default();
    for child in children {
        traverse_internal(nodes, child, ordered);
    }
}

pub fn children(handle: Dora3DHandle) -> Vec<Dora3DHandle> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .map(|node| node.children.clone())
        .unwrap_or_default()
}

pub fn parent(handle: Dora3DHandle) -> Option<Dora3DHandle> {
    registry()
        .lock()
        .unwrap()
        .get(&handle)
        .and_then(|node| node.parent)
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}
