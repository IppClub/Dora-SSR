use super::animation::{
    self, AnimationChannel, AnimationClipData, AnimationData, ChannelProperty, Keyframe,
    KeyframeValue, SkeletonData,
};
use super::material::{self, MaterialType};
use super::mesh::{self, SubMesh, Vertex};
use super::node3d;
use super::texture;
use super::types::{Mat4, Quaternion, Vec3, Vec4};
use super::visual3d;
use super::{next_handle, Dora3DHandle};
use crate::print_error;
use gltf::buffer::Data as BufferData;
use gltf::image::{Data as ImageData, Format as ImageFormat};
use gltf::mesh::util::{ReadJoints, ReadWeights};
use gltf::{animation::Property as GltfProperty, animation::util::ReadOutputs};
use gltf::{Document, Node};
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct LoadedModel {
    pub handle: Dora3DHandle,
    pub root: Dora3DHandle,
    pub nodes: Vec<Dora3DHandle>,
    pub visuals: Vec<Dora3DHandle>,
    pub meshes: Vec<Dora3DHandle>,
    pub materials: Vec<Dora3DHandle>,
    pub textures: Vec<Dora3DHandle>,
    pub skeleton: Option<Dora3DHandle>,
    pub skeletons: Vec<Dora3DHandle>,
    pub animations: Vec<Dora3DHandle>,
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, LoadedModel>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, LoadedModel>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn image_to_rgba8(image: &ImageData) -> Option<(u16, u16, Vec<u8>)> {
    let width = u16::try_from(image.width).ok()?;
    let height = u16::try_from(image.height).ok()?;
    let rgba = match image.format {
        ImageFormat::R8 => image
            .pixels
            .iter()
            .flat_map(|value| [*value, *value, *value, u8::MAX])
            .collect(),
        ImageFormat::R8G8 => image
            .pixels
            .chunks_exact(2)
            .flat_map(|value| [value[0], value[1], 0, u8::MAX])
            .collect(),
        ImageFormat::R8G8B8 => image
            .pixels
            .chunks_exact(3)
            .flat_map(|value| [value[0], value[1], value[2], u8::MAX])
            .collect(),
        ImageFormat::R8G8B8A8 => image.pixels.clone(),
        _ => return None,
    };
    Some((width, height, rgba))
}

fn sampler_flags(texture_ref: &gltf::Texture<'_>) -> u64 {
    let sampler = texture_ref.sampler();
    let mut flags = bgfx_wrap_flags(sampler.wrap_s(), true) | bgfx_wrap_flags(sampler.wrap_t(), false);
    if matches!(
        sampler.min_filter(),
        Some(gltf::texture::MinFilter::Nearest)
            | Some(gltf::texture::MinFilter::NearestMipmapNearest)
            | Some(gltf::texture::MinFilter::NearestMipmapLinear)
    ) {
        flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MIN_POINT as u64;
    }
    if matches!(sampler.mag_filter(), Some(gltf::texture::MagFilter::Nearest)) {
        flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MAG_POINT as u64;
    }
    if matches!(
        sampler.min_filter(),
        Some(gltf::texture::MinFilter::LinearMipmapNearest)
            | Some(gltf::texture::MinFilter::NearestMipmapNearest)
    ) {
        flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MIP_POINT as u64;
    }
    flags
}

fn bgfx_wrap_flags(mode: gltf::texture::WrappingMode, u_axis: bool) -> u64 {
    use crate::bgfx_rs::bgfx_sys::{
        BGFX_SAMPLER_U_CLAMP, BGFX_SAMPLER_U_MIRROR, BGFX_SAMPLER_V_CLAMP, BGFX_SAMPLER_V_MIRROR,
    };
    match (mode, u_axis) {
        (gltf::texture::WrappingMode::MirroredRepeat, true) => BGFX_SAMPLER_U_MIRROR as u64,
        (gltf::texture::WrappingMode::ClampToEdge, true) => BGFX_SAMPLER_U_CLAMP as u64,
        (gltf::texture::WrappingMode::MirroredRepeat, false) => BGFX_SAMPLER_V_MIRROR as u64,
        (gltf::texture::WrappingMode::ClampToEdge, false) => BGFX_SAMPLER_V_CLAMP as u64,
        _ => 0,
    }
}

fn load_texture(
    textures: &mut HashMap<usize, Dora3DHandle>,
    image_index: usize,
    image_data: &ImageData,
    sampler_flags: u64,
    label: &str,
    loaded: &mut LoadedModel,
) -> Option<Dora3DHandle> {
    if let Some(handle) = textures.get(&image_index) {
        return Some(*handle);
    }
    let (width, height, rgba) = image_to_rgba8(image_data)?;
    let texture_handle = texture::create_rgba8(width, height, &rgba, sampler_flags, Some(label))?;
    textures.insert(image_index, texture_handle);
    loaded.textures.push(texture_handle);
    Some(texture_handle)
}

fn create_material(
    primitive: &gltf::Primitive<'_>,
    images: &[ImageData],
    texture_cache: &mut HashMap<usize, Dora3DHandle>,
    loaded: &mut LoadedModel,
) -> Dora3DHandle {
    let material_handle = material::create();
    let source_material = primitive.material();
    let pbr = source_material.pbr_metallic_roughness();
    let base_color = Vec4::from_array(pbr.base_color_factor());
    let _ = material::set_type(material_handle, MaterialType::PbrMetallicRoughness);
    let _ = material::ensure_default_pbr_material(material_handle);
    let _ = material::set_base_color(material_handle, base_color);
    let _ = material::set_emissive_factor(
        material_handle,
        Vec3::from_array(source_material.emissive_factor()),
    );
    let _ = material::set_pbr(
        material_handle,
        pbr.metallic_factor(),
        pbr.roughness_factor(),
        source_material.alpha_cutoff().unwrap_or(0.5),
    );
    let _ = material::set_flags(
        material_handle,
        source_material.alpha_mode() == gltf::material::AlphaMode::Blend,
        source_material.double_sided(),
        true,
        source_material.alpha_mode() != gltf::material::AlphaMode::Blend,
    );

    if let Some(info) = pbr.base_color_texture() {
        let image_index = info.texture().source().index();
        let flags = sampler_flags(&info.texture());
        if let Some(texture_handle) = load_texture(
            texture_cache,
            image_index,
            &images[image_index],
            flags,
            "gltf-base-color",
            loaded,
        ) {
            let _ = material::set_texture(
                material_handle,
                material::default_base_color_slot(),
                texture_handle,
                0,
            );
        }
    }
    if let Some(info) = pbr.metallic_roughness_texture() {
        let image_index = info.texture().source().index();
        let flags = sampler_flags(&info.texture());
        if let Some(texture_handle) = load_texture(
            texture_cache,
            image_index,
            &images[image_index],
            flags,
            "gltf-metallic-roughness",
            loaded,
        ) {
            let _ = material::set_texture(
                material_handle,
                material::default_metallic_roughness_slot(),
                texture_handle,
                1,
            );
        }
    }
    if let Some(info) = source_material.normal_texture() {
        let image_index = info.texture().source().index();
        let flags = sampler_flags(&info.texture());
        let _ = material::set_normal_scale(material_handle, info.scale());
        if let Some(texture_handle) = load_texture(
            texture_cache,
            image_index,
            &images[image_index],
            flags,
            "gltf-normal",
            loaded,
        ) {
            let _ = material::set_texture(
                material_handle,
                material::default_normal_slot(),
                texture_handle,
                2,
            );
        }
    }
    if let Some(info) = source_material.emissive_texture() {
        let image_index = info.texture().source().index();
        let flags = sampler_flags(&info.texture());
        if let Some(texture_handle) = load_texture(
            texture_cache,
            image_index,
            &images[image_index],
            flags,
            "gltf-emissive",
            loaded,
        ) {
            let _ = material::set_texture(
                material_handle,
                material::default_emissive_slot(),
                texture_handle,
                3,
            );
        }
    }
    if let Some(info) = source_material.occlusion_texture() {
        let image_index = info.texture().source().index();
        let flags = sampler_flags(&info.texture());
        let _ = material::set_occlusion_strength(material_handle, info.strength());
        if let Some(texture_handle) = load_texture(
            texture_cache,
            image_index,
            &images[image_index],
            flags,
            "gltf-occlusion",
            loaded,
        ) {
            let _ = material::set_texture(
                material_handle,
                material::default_occlusion_slot(),
                texture_handle,
                4,
            );
        }
    }
    material_handle
}

fn primitive_to_mesh(
    primitive: &gltf::Primitive<'_>,
    buffers: &[BufferData],
) -> Option<Dora3DHandle> {
    let reader = primitive.reader(|buffer| Some(&buffers[buffer.index()]));
    let positions: Vec<[f32; 3]> = reader.read_positions()?.collect();
    let normals: Vec<[f32; 3]> = reader
        .read_normals()
        .map(|values| values.collect())
        .unwrap_or_else(|| vec![[0.0, 1.0, 0.0]; positions.len()]);
    let tangents: Vec<[f32; 4]> = reader
        .read_tangents()
        .map(|values| values.collect())
        .unwrap_or_else(|| vec![[1.0, 0.0, 0.0, 1.0]; positions.len()]);
    let uvs: Vec<[f32; 2]> = reader
        .read_tex_coords(0)
        .map(|coords| coords.into_f32().collect())
        .unwrap_or_else(|| vec![[0.0, 0.0]; positions.len()]);
    let colors: Vec<u32> = reader
        .read_colors(0)
        .map(|colors| {
            colors
                .into_rgba_f32()
                .map(|rgba| {
                    let r = (rgba[0].clamp(0.0, 1.0) * 255.0).round() as u32;
                    let g = (rgba[1].clamp(0.0, 1.0) * 255.0).round() as u32;
                    let b = (rgba[2].clamp(0.0, 1.0) * 255.0).round() as u32;
                    let a = (rgba[3].clamp(0.0, 1.0) * 255.0).round() as u32;
                    (a << 24) | (b << 16) | (g << 8) | r
                })
                .collect()
        })
        .unwrap_or_else(|| vec![0xffff_ffff; positions.len()]);
    let joints: Vec<[u16; 4]> = reader
        .read_joints(0)
        .map(|joints| match joints {
            ReadJoints::U8(values) => values
                .map(|joint| {
                    [
                        joint[0] as u16,
                        joint[1] as u16,
                        joint[2] as u16,
                        joint[3] as u16,
                    ]
                })
                .collect(),
            ReadJoints::U16(values) => values.collect(),
        })
        .unwrap_or_else(|| vec![[0, 0, 0, 0]; positions.len()]);
    let weights: Vec<[f32; 4]> = reader
        .read_weights(0)
        .map(|weights| match weights {
            ReadWeights::U8(values) => values
                .map(|weight| {
                    [
                        weight[0] as f32 / 255.0,
                        weight[1] as f32 / 255.0,
                        weight[2] as f32 / 255.0,
                        weight[3] as f32 / 255.0,
                    ]
                })
                .collect(),
            ReadWeights::U16(values) => values
                .map(|weight| {
                    [
                        weight[0] as f32 / 65535.0,
                        weight[1] as f32 / 65535.0,
                        weight[2] as f32 / 65535.0,
                        weight[3] as f32 / 65535.0,
                    ]
                })
                .collect(),
            ReadWeights::F32(values) => values.collect(),
        })
        .unwrap_or_else(|| vec![[0.0, 0.0, 0.0, 0.0]; positions.len()]);
    let indices: Vec<u32> = reader
        .read_indices()
        .map(|indices| indices.into_u32().collect())
        .unwrap_or_else(|| (0..positions.len() as u32).collect());
    let vertices = positions
        .iter()
        .enumerate()
        .map(|(index, position)| Vertex {
            position: *position,
            normal: normals.get(index).copied().unwrap_or([0.0, 1.0, 0.0]),
            tangent: tangents
                .get(index)
                .copied()
                .unwrap_or([1.0, 0.0, 0.0, 1.0]),
            uv0: uvs.get(index).copied().unwrap_or([0.0, 0.0]),
            color: colors.get(index).copied().unwrap_or(0xffff_ffff),
            joint_indices: joints.get(index).copied().unwrap_or([0, 0, 0, 0]),
            joint_weights: weights
                .get(index)
                .copied()
                .unwrap_or([0.0, 0.0, 0.0, 0.0]),
        })
        .collect();
    let sub_meshes = vec![SubMesh {
        start_index: 0,
        index_count: indices.len() as u32,
        material_slot: primitive.material().index().unwrap_or(0) as u32,
    }];
    Some(mesh::create(vertices, indices, Some(sub_meshes)))
}

fn import_node(
    node: Node<'_>,
    parent: Dora3DHandle,
    buffers: &[BufferData],
    images: &[ImageData],
    texture_cache: &mut HashMap<usize, Dora3DHandle>,
    node_handles: &mut HashMap<usize, Dora3DHandle>,
    loaded: &mut LoadedModel,
) {
    let current = node3d::create();
    node_handles.insert(node.index(), current);
    loaded.nodes.push(current);
    let _ = node3d::add_child(parent, current, 0, node.name());
    let (translation, rotation, scale) = node.transform().decomposed();
    let _ = node3d::set_position(current, Vec3::from_array(translation));
    let _ = node3d::set_rotation(current, Quaternion::from_array(rotation));
    let _ = node3d::set_scale(current, Vec3::from_array(scale));

    if let Some(mesh_ref) = node.mesh() {
        for primitive in mesh_ref.primitives() {
            if let Some(mesh_handle) = primitive_to_mesh(&primitive, buffers) {
                let material_handle = create_material(&primitive, images, texture_cache, loaded);
                let visual_handle = visual3d::create(current, mesh_handle, material_handle);
                loaded.meshes.push(mesh_handle);
                loaded.materials.push(material_handle);
                loaded.visuals.push(visual_handle);
            }
        }
    }

    for child in node.children() {
        import_node(
            child,
            current,
            buffers,
            images,
            texture_cache,
            node_handles,
            loaded,
        );
    }
}

fn scene_root(document: &Document) -> Option<gltf::Scene<'_>> {
    document.default_scene().or_else(|| document.scenes().next())
}

fn load_skeletons(
    document: &Document,
    buffers: &[BufferData],
    node_handles: &HashMap<usize, Dora3DHandle>,
    loaded: &mut LoadedModel,
) -> HashMap<Dora3DHandle, usize> {
    let mut primary_joint_lookup = HashMap::new();
    for skin in document.skins() {
        let joints: Vec<Dora3DHandle> = skin
            .joints()
            .filter_map(|joint| node_handles.get(&joint.index()).copied())
            .collect();
        if joints.is_empty() {
            continue;
        }
        let mut inverse_bind_matrices: Vec<Mat4> = skin
            .reader(|buffer| Some(&buffers[buffer.index()]))
            .read_inverse_bind_matrices()
            .map(|matrices| {
                matrices
                    .map(|matrix| Mat4::from_cols_array_2d(&matrix))
                    .collect()
            })
            .unwrap_or_else(|| vec![Mat4::IDENTITY; joints.len()]);
        if inverse_bind_matrices.len() < joints.len() {
            inverse_bind_matrices.resize(joints.len(), Mat4::IDENTITY);
        } else if inverse_bind_matrices.len() > joints.len() {
            inverse_bind_matrices.truncate(joints.len());
        }
        let skeleton_handle = animation::create(AnimationData::Skeleton(SkeletonData {
            handle: 0,
            joints: joints.clone(),
            inverse_bind_matrices,
        }));
        if loaded.skeleton.is_none() {
            loaded.skeleton = Some(skeleton_handle);
            primary_joint_lookup = joints
                .iter()
                .enumerate()
                .map(|(index, handle)| (*handle, index))
                .collect();
        }
        loaded.skeletons.push(skeleton_handle);
    }
    primary_joint_lookup
}

fn load_animation_clips(
    document: &Document,
    buffers: &[BufferData],
    node_handles: &HashMap<usize, Dora3DHandle>,
    joint_lookup: &HashMap<Dora3DHandle, usize>,
    loaded: &mut LoadedModel,
) {
    for animation_ref in document.animations() {
        let mut duration = 0.0f32;
        let mut channels = Vec::new();
        for channel in animation_ref.channels() {
            let target = channel.target();
            let property = match target.property() {
                GltfProperty::Translation => ChannelProperty::Translation,
                GltfProperty::Rotation => ChannelProperty::Rotation,
                GltfProperty::Scale => ChannelProperty::Scale,
                GltfProperty::MorphTargetWeights => continue,
            };
            let Some(target_handle) = node_handles.get(&target.node().index()).copied() else {
                continue;
            };
            let Some(joint_index) = joint_lookup.get(&target_handle).copied() else {
                continue;
            };
            let reader = channel.reader(|buffer| Some(&buffers[buffer.index()]));
            let Some(inputs) = reader.read_inputs() else {
                continue;
            };
            let times: Vec<f32> = inputs.collect();
            if times.is_empty() {
                continue;
            }
            if let Some(last_time) = times.last().copied() {
                duration = duration.max(last_time);
            }
            let Some(outputs) = reader.read_outputs() else {
                continue;
            };
            let keyframes: Vec<Keyframe> = match (property, outputs) {
                (ChannelProperty::Translation, ReadOutputs::Translations(values)) => times
                    .into_iter()
                    .zip(values)
                    .map(|(time, value)| Keyframe {
                        time,
                        value: KeyframeValue::Translation(Vec3::from_array(value)),
                    })
                    .collect(),
                (ChannelProperty::Rotation, ReadOutputs::Rotations(values)) => times
                    .into_iter()
                    .zip(values.into_f32())
                    .map(|(time, value)| Keyframe {
                        time,
                        value: KeyframeValue::Rotation(Quaternion::from_array(value)),
                    })
                    .collect(),
                (ChannelProperty::Scale, ReadOutputs::Scales(values)) => times
                    .into_iter()
                    .zip(values)
                    .map(|(time, value)| Keyframe {
                        time,
                        value: KeyframeValue::Scale(Vec3::from_array(value)),
                    })
                    .collect(),
                _ => continue,
            };
            if keyframes.is_empty() {
                continue;
            }
            channels.push(AnimationChannel {
                joint_index,
                property,
                keyframes,
            });
        }
        if channels.is_empty() {
            continue;
        }
        let name = animation_ref
            .name()
            .map(str::to_owned)
            .unwrap_or_else(|| format!("animation_{}", animation_ref.index()));
        let clip_handle = animation::create(AnimationData::Clip(AnimationClipData {
            handle: 0,
            name,
            duration,
            channels,
        }));
        loaded.animations.push(clip_handle);
    }
}

pub fn load_gltf(path: &str) -> Option<Dora3DHandle> {
    let path_buf = PathBuf::from(path);
    let import = gltf::import(&path_buf);
    let (document, buffers, images) = match import {
        Ok(imported) => imported,
        Err(error) => {
            print_error(&format!("Failed to import glTF '{}': {}", path, error));
            return None;
        }
    };
    let synthetic_root = node3d::create();
    let handle = next_handle();
    let mut loaded = LoadedModel {
        handle,
        root: synthetic_root,
        nodes: vec![synthetic_root],
        visuals: Vec::new(),
        meshes: Vec::new(),
        materials: Vec::new(),
        textures: Vec::new(),
        skeleton: None,
        skeletons: Vec::new(),
        animations: Vec::new(),
    };
    let scene = match scene_root(&document) {
        Some(scene) => scene,
        None => {
            print_error(&format!("glTF '{}' does not contain a scene.", path));
            registry().lock().unwrap().insert(handle, loaded);
            return Some(handle);
        }
    };
    let mut texture_cache = HashMap::new();
    let mut node_handles = HashMap::new();
    for root_node in scene.nodes() {
        import_node(
            root_node,
            synthetic_root,
            &buffers,
            &images,
            &mut texture_cache,
            &mut node_handles,
            &mut loaded,
        );
    }
    let joint_lookup = load_skeletons(&document, &buffers, &node_handles, &mut loaded);
    load_animation_clips(&document, &buffers, &node_handles, &joint_lookup, &mut loaded);
    registry().lock().unwrap().insert(handle, loaded);
    Some(handle)
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    let Some(model) = registry().lock().unwrap().remove(&handle) else {
        return false;
    };
    for visual in model.visuals {
        let _ = visual3d::destroy(visual);
    }
    for material_handle in model.materials {
        let _ = material::destroy(material_handle);
    }
    for mesh_handle in model.meshes {
        let _ = mesh::destroy(mesh_handle);
    }
    for texture_handle in model.textures {
        let _ = texture::destroy(texture_handle);
    }
    for animation_handle in model.animations {
        let _ = animation::destroy(animation_handle);
    }
    for skeleton_handle in model.skeletons {
        let _ = animation::destroy(skeleton_handle);
    }
    let _ = node3d::destroy(model.root);
    true
}

pub fn with_model<R>(handle: Dora3DHandle, f: impl FnOnce(&LoadedModel) -> R) -> Option<R> {
    let models = registry().lock().unwrap();
    models.get(&handle).map(f)
}

pub fn skeleton_for_visual(visual: Dora3DHandle) -> Option<Dora3DHandle> {
    let models = registry().lock().unwrap();
    models
        .values()
        .find(|model| model.visuals.contains(&visual))
        .and_then(|model| model.skeleton)
}

pub fn get_visual(handle: Dora3DHandle, index: u32) -> Option<Dora3DHandle> {
    with_model(handle, |model| model.visuals.get(index as usize).copied()).flatten()
}

pub fn clear_registry() {
    let model_handles: Vec<Dora3DHandle> = registry().lock().unwrap().keys().copied().collect();
    for handle in model_handles {
        let _ = destroy(handle);
    }
}
