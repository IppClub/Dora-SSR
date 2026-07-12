/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model3d_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model3d_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model3d_get_duration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model3d_get_elapsed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_get_animation_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_get_material_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_animation_name(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_has_node(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model3d_attach_to_node(int64_t self, int64_t name, int64_t child);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_local_bounds_min(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_local_bounds_max(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_world_bounds_min(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_world_bounds_max(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_get_material(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model3d_play(int64_t self, int64_t name, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model3d_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model3d_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model3d_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model3d_new(int64_t path);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A 3D model node loaded from a glTF/GLB file.
	/// </summary>
	public partial class Model3D : Node3D
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.model3d_type(), From);
		}
		protected Model3D(long raw) : base(raw) { }
		internal static new Model3D From(long raw)
		{
			return new Model3D(raw);
		}
		internal static new Model3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Model3D(raw);
		}
		/// <summary>
		/// The animation playback speed.
		/// </summary>
		public float Speed
		{
			set => Native.model3d_set_speed(Raw, value);
			get => Native.model3d_get_speed(Raw);
		}
		/// <summary>
		/// The current animation duration.
		/// </summary>
		public float Duration
		{
			get => Native.model3d_get_duration(Raw);
		}
		/// <summary>
		/// The elapsed playback time.
		/// </summary>
		public float Elapsed
		{
			get => Native.model3d_get_elapsed(Raw);
		}
		/// <summary>
		/// Whether an animation is playing.
		/// </summary>
		public bool IsPlaying
		{
			get => Native.model3d_is_playing(Raw) != 0;
		}
		/// <summary>
		/// Whether animation playback is paused.
		/// </summary>
		public bool IsPaused
		{
			get => Native.model3d_is_paused(Raw) != 0;
		}
		/// <summary>
		/// The number of animation clips in this model.
		/// </summary>
		public int AnimationCount
		{
			get => Native.model3d_get_animation_count(Raw);
		}
		/// <summary>The number of material slots in this model instance.</summary>
		public int MaterialCount
		{
			get => Native.model3d_get_material_count(Raw);
		}
		/// <summary>Gets an animation clip name by index.</summary>
		public string GetAnimationName(int index)
		{
			return Bridge.ToString(Native.model3d_get_animation_name(Raw, index));
		}
		/// <summary>Checks whether an imported node with the given name exists.</summary>
		public bool HasNode(string name)
		{
			return Native.model3d_has_node(Raw, Bridge.FromString(name)) != 0;
		}
		/// <summary>Attaches a user-owned Node3D below an imported node.</summary>
		public bool AttachToNode(string name, Node3D child)
		{
			return Native.model3d_attach_to_node(Raw, Bridge.FromString(name), child.Raw) != 0;
		}
		/// <summary>Gets the current model-space bounds minimum.</summary>
		public Vec3 GetLocalBoundsMin()
		{
			return Vec3.From(Native.model3d_get_local_bounds_min(Raw));
		}
		/// <summary>Gets the current model-space bounds maximum.</summary>
		public Vec3 GetLocalBoundsMax()
		{
			return Vec3.From(Native.model3d_get_local_bounds_max(Raw));
		}
		/// <summary>Gets the current world-space bounds minimum.</summary>
		public Vec3 GetWorldBoundsMin()
		{
			return Vec3.From(Native.model3d_get_world_bounds_min(Raw));
		}
		/// <summary>Gets the current world-space bounds maximum.</summary>
		public Vec3 GetWorldBoundsMax()
		{
			return Vec3.From(Native.model3d_get_world_bounds_max(Raw));
		}
		/// <summary>Gets a per-instance material slot by zero-based index.</summary>
		public Material3D? GetMaterial(int index)
		{
			return Material3D.FromOpt(Native.model3d_get_material(Raw, index));
		}
		/// <summary>
		/// Plays an animation by name.
		/// </summary>
		public float Play(string name = "", bool looped = false)
		{
			return Native.model3d_play(Raw, Bridge.FromString(name), looped ? 1 : 0);
		}
		/// <summary>
		/// Stops animation playback.
		/// </summary>
		public void Stop()
		{
			Native.model3d_stop(Raw);
		}
		/// <summary>
		/// Pauses animation playback.
		/// </summary>
		public void Pause()
		{
			Native.model3d_pause(Raw);
		}
		/// <summary>
		/// Resumes animation playback.
		/// </summary>
		public void Resume()
		{
			Native.model3d_resume(Raw);
		}
		/// <summary>
		/// Creates a model from a glTF/GLB file.
		/// </summary>
		public Model3D(string path) : this(Native.model3d_new(Bridge.FromString(path))) { }
		public static Model3D? TryCreate(string path)
		{
			var raw = Native.model3d_new(Bridge.FromString(path));
			return raw == 0 ? null : new Model3D(raw);
		}
	}
} // namespace Dora
