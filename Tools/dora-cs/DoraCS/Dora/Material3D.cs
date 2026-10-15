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
		public static extern int32_t material3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_base_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t material3d_get_base_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_emissive(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t material3d_get_emissive(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_metallic(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float material3d_get_metallic(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_roughness(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float material3d_get_roughness(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_alpha_mode(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t material3d_get_alpha_mode(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_alpha_cutoff(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float material3d_get_alpha_cutoff(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_base_color_texture(int64_t self, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_clear_base_color_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_metallic_roughness_texture(int64_t self, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_clear_metallic_roughness_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_normal_texture(int64_t self, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_clear_normal_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_emissive_texture(int64_t self, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_clear_emissive_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_set_occlusion_texture(int64_t self, int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void material3d_clear_occlusion_texture(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A per-instance material slot owned by a Model3D instance.</summary>
	public partial class Material3D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.material3d_type(), From);
		}
		protected Material3D(long raw) : base(raw) { }
		internal static new Material3D From(long raw)
		{
			return new Material3D(raw);
		}
		internal static new Material3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Material3D(raw);
		}
		/// <summary>The base color tint.</summary>
		public Color BaseColor
		{
			set => Native.material3d_set_base_color(Raw, (int)value.ToARGB());
			get => new Color((uint)Native.material3d_get_base_color(Raw));
		}
		/// <summary>The emissive color factor.</summary>
		public Color3 Emissive
		{
			set => Native.material3d_set_emissive(Raw, (int)value.ToRGB());
			get => new Color3((uint)Native.material3d_get_emissive(Raw));
		}
		/// <summary>The metallic factor.</summary>
		public float Metallic
		{
			set => Native.material3d_set_metallic(Raw, value);
			get => Native.material3d_get_metallic(Raw);
		}
		/// <summary>The roughness factor.</summary>
		public float Roughness
		{
			set => Native.material3d_set_roughness(Raw, value);
			get => Native.material3d_get_roughness(Raw);
		}
		/// <summary>The alpha rendering mode.</summary>
		public MaterialAlphaMode3D AlphaMode
		{
			set => Native.material3d_set_alpha_mode(Raw, (int)value);
			get => (MaterialAlphaMode3D)Native.material3d_get_alpha_mode(Raw);
		}
		/// <summary>The alpha mask cutoff.</summary>
		public float AlphaCutoff
		{
			set => Native.material3d_set_alpha_cutoff(Raw, value);
			get => Native.material3d_get_alpha_cutoff(Raw);
		}
		/// <summary>Replaces or clears the base color texture.</summary>
		public void SetBaseColorTexture(Texture2D texture)
		{
			Native.material3d_set_base_color_texture(Raw, texture.Raw);
		}
		/// <summary>Clears the base color texture override.</summary>
		public void ClearBaseColorTexture()
		{
			Native.material3d_clear_base_color_texture(Raw);
		}
		/// <summary>Replaces or clears the metallic-roughness texture.</summary>
		public void SetMetallicRoughnessTexture(Texture2D texture)
		{
			Native.material3d_set_metallic_roughness_texture(Raw, texture.Raw);
		}
		/// <summary>Clears the metallic-roughness texture override.</summary>
		public void ClearMetallicRoughnessTexture()
		{
			Native.material3d_clear_metallic_roughness_texture(Raw);
		}
		/// <summary>Replaces or clears the normal texture.</summary>
		public void SetNormalTexture(Texture2D texture)
		{
			Native.material3d_set_normal_texture(Raw, texture.Raw);
		}
		/// <summary>Clears the normal texture override.</summary>
		public void ClearNormalTexture()
		{
			Native.material3d_clear_normal_texture(Raw);
		}
		/// <summary>Replaces or clears the emissive texture.</summary>
		public void SetEmissiveTexture(Texture2D texture)
		{
			Native.material3d_set_emissive_texture(Raw, texture.Raw);
		}
		/// <summary>Clears the emissive texture override.</summary>
		public void ClearEmissiveTexture()
		{
			Native.material3d_clear_emissive_texture(Raw);
		}
		/// <summary>Replaces or clears the occlusion texture.</summary>
		public void SetOcclusionTexture(Texture2D texture)
		{
			Native.material3d_set_occlusion_texture(Raw, texture.Raw);
		}
		/// <summary>Clears the occlusion texture override.</summary>
		public void ClearOcclusionTexture()
		{
			Native.material3d_clear_occlusion_texture(Raw);
		}
	}
} // namespace Dora
