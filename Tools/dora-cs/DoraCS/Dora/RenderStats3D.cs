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
		public static extern void renderstats3d_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_scene_nodes(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_visible_visuals(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_culled_visuals(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_opaque_items(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_transparent_items(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_draw_calls(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_triangles(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_program_switches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_material_switches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_texture_switches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_mesh_switches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_node_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_visual_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_model_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_model_instance_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_mesh_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_static_mesh_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_dynamic_mesh_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_material_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_texture_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_animation_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t renderstats3d_get_environment_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_model_resident_bytes(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_mesh_resident_bytes(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_texture_resident_bytes(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_collect_micros(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_sort_micros(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_submit_micros(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_upload_commands(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_upload_bytes(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_upload_micros(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t renderstats3d_get_upload_max_command_micros(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// Statistics captured from the most recent 3D render for a View3D.
	/// </summary>
	public partial class RenderStats3D
	{
		private RenderStats3D(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create RenderStats3D");
			Raw = raw;
		}
		~RenderStats3D()
		{
			Native.renderstats3d_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static RenderStats3D From(long raw)
		{
			return new RenderStats3D(raw);
		}
		public int SceneNodes
		{
			get => Native.renderstats3d_get_scene_nodes(Raw);
		}
		public int VisibleVisuals
		{
			get => Native.renderstats3d_get_visible_visuals(Raw);
		}
		public int CulledVisuals
		{
			get => Native.renderstats3d_get_culled_visuals(Raw);
		}
		public int OpaqueItems
		{
			get => Native.renderstats3d_get_opaque_items(Raw);
		}
		public int TransparentItems
		{
			get => Native.renderstats3d_get_transparent_items(Raw);
		}
		public int DrawCalls
		{
			get => Native.renderstats3d_get_draw_calls(Raw);
		}
		public long Triangles
		{
			get => Native.renderstats3d_get_triangles(Raw);
		}
		public int ProgramSwitches
		{
			get => Native.renderstats3d_get_program_switches(Raw);
		}
		public int MaterialSwitches
		{
			get => Native.renderstats3d_get_material_switches(Raw);
		}
		public int TextureSwitches
		{
			get => Native.renderstats3d_get_texture_switches(Raw);
		}
		public int MeshSwitches
		{
			get => Native.renderstats3d_get_mesh_switches(Raw);
		}
		public int NodeCount
		{
			get => Native.renderstats3d_get_node_count(Raw);
		}
		public int VisualCount
		{
			get => Native.renderstats3d_get_visual_count(Raw);
		}
		public int ModelCount
		{
			get => Native.renderstats3d_get_model_count(Raw);
		}
		public int ModelInstanceCount
		{
			get => Native.renderstats3d_get_model_instance_count(Raw);
		}
		public int MeshCount
		{
			get => Native.renderstats3d_get_mesh_count(Raw);
		}
		public int StaticMeshCount
		{
			get => Native.renderstats3d_get_static_mesh_count(Raw);
		}
		public int DynamicMeshCount
		{
			get => Native.renderstats3d_get_dynamic_mesh_count(Raw);
		}
		public int MaterialCount
		{
			get => Native.renderstats3d_get_material_count(Raw);
		}
		public int TextureCount
		{
			get => Native.renderstats3d_get_texture_count(Raw);
		}
		public int AnimationCount
		{
			get => Native.renderstats3d_get_animation_count(Raw);
		}
		public int EnvironmentCount
		{
			get => Native.renderstats3d_get_environment_count(Raw);
		}
		public long ModelResidentBytes
		{
			get => Native.renderstats3d_get_model_resident_bytes(Raw);
		}
		public long MeshResidentBytes
		{
			get => Native.renderstats3d_get_mesh_resident_bytes(Raw);
		}
		public long TextureResidentBytes
		{
			get => Native.renderstats3d_get_texture_resident_bytes(Raw);
		}
		public long CollectMicros
		{
			get => Native.renderstats3d_get_collect_micros(Raw);
		}
		public long SortMicros
		{
			get => Native.renderstats3d_get_sort_micros(Raw);
		}
		public long SubmitMicros
		{
			get => Native.renderstats3d_get_submit_micros(Raw);
		}
		public long UploadCommands
		{
			get => Native.renderstats3d_get_upload_commands(Raw);
		}
		public long UploadBytes
		{
			get => Native.renderstats3d_get_upload_bytes(Raw);
		}
		public long UploadMicros
		{
			get => Native.renderstats3d_get_upload_micros(Raw);
		}
		public long UploadMaxCommandMicros
		{
			get => Native.renderstats3d_get_upload_max_command_micros(Raw);
		}
	}
} // namespace Dora
