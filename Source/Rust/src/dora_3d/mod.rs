pub mod animation;
pub mod c_api;
pub mod camera3d;
pub mod material;
pub mod mesh;
pub mod model_loader;
pub mod node3d;
pub mod renderer3d;
pub mod shader;
pub mod skinning;
pub mod texture;
pub mod types;
pub mod visual3d;

use std::sync::atomic::{AtomicU64, Ordering};

pub type Dora3DHandle = u64;
pub const INVALID_HANDLE: Dora3DHandle = 0;

static NEXT_HANDLE: AtomicU64 = AtomicU64::new(1);

pub(crate) fn next_handle() -> Dora3DHandle {
    NEXT_HANDLE.fetch_add(1, Ordering::Relaxed)
}
