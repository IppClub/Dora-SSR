/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

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
		public static extern int32_t node_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_order(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_order(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_angle_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_angle_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scale_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_scale_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scale_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_scale_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_z(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_z(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_skew_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_skew_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_skew_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_skew_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_visible(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_visible(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_anchor(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_anchor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_height(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_tag(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_tag(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_opacity(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_get_opacity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_color3(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_color3(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_pass_opacity(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_pass_opacity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_pass_color3(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_pass_color3(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_transform_target(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_transform_target_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_transform_target(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_scheduler(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_scheduler(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_children(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_parent(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_running(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_scheduled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_action_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_data(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_touch_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_touch_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_swallow_touches(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_swallow_touches(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_swallow_mouse_wheel(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_swallow_mouse_wheel(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_keyboard_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_keyboard_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_controller_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_controller_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_render_group(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_render_group(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_show_debug(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_is_show_debug(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_set_render_order(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_get_render_order(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child_with_order_tag(int64_t self, int64_t child, int32_t order, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child_with_order(int64_t self, int64_t child, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_add_child(int64_t self, int64_t child);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to_with_order_tag(int64_t self, int64_t parent, int32_t order, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to_with_order(int64_t self, int64_t parent, int32_t order);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_add_to(int64_t self, int64_t parent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_child(int64_t self, int64_t child, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_child_by_tag(int64_t self, int64_t tag, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_all_children(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_remove_from_parent(int64_t self, int32_t cleanup);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_move_to_parent(int64_t self, int64_t parent);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_cleanup(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_get_child_by_tag(int64_t self, int64_t tag);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_schedule(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_unschedule(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_convert_to_node_space(int64_t self, int64_t worldPoint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_convert_to_world_space(int64_t self, int64_t nodePoint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_convert_to_window_space(int64_t self, int64_t nodePoint, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_each_child(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_traverse(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t node_traverse_all(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_run_action_def(int64_t self, int64_t actionDef, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_run_action(int64_t self, int64_t action, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_all_actions(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_perform_def(int64_t self, int64_t actionDef, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float node_perform(int64_t self, int64_t action, int32_t looped);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_action(int64_t self, int64_t action);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_vertically(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_vertically_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_horizontally(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_horizontally_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items(int64_t self, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_align_items_with_size(int64_t self, int64_t size, float padding);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_move_and_cull_items(int64_t self, int64_t delta);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_attach_ime(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_detach_ime(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_grab(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_grab_with_size(int64_t self, int32_t gridX, int32_t gridY);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_stop_grab(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_slot(int64_t self, int64_t eventName, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_gslot(int64_t self, int64_t eventName, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_emit(int64_t self, int64_t name, int64_t stack);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_on_update(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void node_on_render(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t node_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// Struct used for building a hierarchical tree structure of game objects.
	/// </summary>
	public partial class Node : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected Node(long raw) : base(raw) { }
		internal static new Node From(long raw)
		{
			return new Node(raw);
		}
		internal static new Node? FromOpt(long raw)
		{
			return raw == 0 ? null : new Node(raw);
		}
		/// <summary>
		/// The order of the node in the parent's children array.
		/// </summary>
		public int Order
		{
			set => Native.node_set_order(Raw, value);
			get => Native.node_get_order(Raw);
		}
		/// <summary>
		/// The rotation angle of the node in degrees.
		/// </summary>
		public float Angle
		{
			set => Native.node_set_angle(Raw, value);
			get => Native.node_get_angle(Raw);
		}
		/// <summary>
		/// The X-axis rotation angle of the node in degrees.
		/// </summary>
		public float AngleX
		{
			set => Native.node_set_angle_x(Raw, value);
			get => Native.node_get_angle_x(Raw);
		}
		/// <summary>
		/// The Y-axis rotation angle of the node in degrees.
		/// </summary>
		public float AngleY
		{
			set => Native.node_set_angle_y(Raw, value);
			get => Native.node_get_angle_y(Raw);
		}
		/// <summary>
		/// The X-axis scale factor of the node.
		/// </summary>
		public float ScaleX
		{
			set => Native.node_set_scale_x(Raw, value);
			get => Native.node_get_scale_x(Raw);
		}
		/// <summary>
		/// The Y-axis scale factor of the node.
		/// </summary>
		public float ScaleY
		{
			set => Native.node_set_scale_y(Raw, value);
			get => Native.node_get_scale_y(Raw);
		}
		/// <summary>
		/// The X-axis position of the node.
		/// </summary>
		public float X
		{
			set => Native.node_set_x(Raw, value);
			get => Native.node_get_x(Raw);
		}
		/// <summary>
		/// The Y-axis position of the node.
		/// </summary>
		public float Y
		{
			set => Native.node_set_y(Raw, value);
			get => Native.node_get_y(Raw);
		}
		/// <summary>
		/// The Z-axis position of the node.
		/// </summary>
		public float Z
		{
			set => Native.node_set_z(Raw, value);
			get => Native.node_get_z(Raw);
		}
		/// <summary>
		/// The position of the node as a Vec2 object.
		/// </summary>
		public Vec2 Position
		{
			set => Native.node_set_position(Raw, value.Raw);
			get => Vec2.From(Native.node_get_position(Raw));
		}
		/// <summary>
		/// The X-axis skew angle of the node in degrees.
		/// </summary>
		public float SkewX
		{
			set => Native.node_set_skew_x(Raw, value);
			get => Native.node_get_skew_x(Raw);
		}
		/// <summary>
		/// The Y-axis skew angle of the node in degrees.
		/// </summary>
		public float SkewY
		{
			set => Native.node_set_skew_y(Raw, value);
			get => Native.node_get_skew_y(Raw);
		}
		/// <summary>
		/// Whether the node is visible.
		/// </summary>
		public bool IsVisible
		{
			set => Native.node_set_visible(Raw, value ? 1 : 0);
			get => Native.node_is_visible(Raw) != 0;
		}
		/// <summary>
		/// The anchor point of the node as a Vec2 object.
		/// </summary>
		public Vec2 Anchor
		{
			set => Native.node_set_anchor(Raw, value.Raw);
			get => Vec2.From(Native.node_get_anchor(Raw));
		}
		/// <summary>
		/// The width of the node.
		/// </summary>
		public float Width
		{
			set => Native.node_set_width(Raw, value);
			get => Native.node_get_width(Raw);
		}
		/// <summary>
		/// The height of the node.
		/// </summary>
		public float Height
		{
			set => Native.node_set_height(Raw, value);
			get => Native.node_get_height(Raw);
		}
		/// <summary>
		/// The size of the node as a Size object.
		/// </summary>
		public Size Size
		{
			set => Native.node_set_size(Raw, value.Raw);
			get => Size.From(Native.node_get_size(Raw));
		}
		/// <summary>
		/// The tag of the node as a string.
		/// </summary>
		public string Tag
		{
			set => Native.node_set_tag(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.node_get_tag(Raw));
		}
		/// <summary>
		/// The opacity of the node, should be 0 to 1.0.
		/// </summary>
		public float Opacity
		{
			set => Native.node_set_opacity(Raw, value);
			get => Native.node_get_opacity(Raw);
		}
		/// <summary>
		/// The color of the node as a Color object.
		/// </summary>
		public Color Color
		{
			set => Native.node_set_color(Raw, (int)value.ToARGB());
			get => new Color((uint)Native.node_get_color(Raw));
		}
		/// <summary>
		/// The color of the node as a Color3 object.
		/// </summary>
		public Color3 Color3
		{
			set => Native.node_set_color3(Raw, (int)value.ToRGB());
			get => new Color3((uint)Native.node_get_color3(Raw));
		}
		/// <summary>
		/// Whether to pass the opacity value to child nodes.
		/// </summary>
		public bool IsPassOpacity
		{
			set => Native.node_set_pass_opacity(Raw, value ? 1 : 0);
			get => Native.node_is_pass_opacity(Raw) != 0;
		}
		/// <summary>
		/// Whether to pass the color value to child nodes.
		/// </summary>
		public bool IsPassColor3
		{
			set => Native.node_set_pass_color3(Raw, value ? 1 : 0);
			get => Native.node_is_pass_color3(Raw) != 0;
		}
		/// <summary>
		/// The target node acts as a parent node for transforming this node.
		/// </summary>
		public Node? TransformTarget
		{
			set
			{
				if (value == null) Native.node_set_transform_target_null(Raw);
				else Native.node_set_transform_target(Raw, value.Raw);
			}
			get => Node.FromOpt(Native.node_get_transform_target(Raw));
		}
		/// <summary>
		/// The scheduler used for scheduling update and action callbacks.
		/// </summary>
		public Scheduler Scheduler
		{
			set => Native.node_set_scheduler(Raw, value.Raw);
			get => Scheduler.From(Native.node_get_scheduler(Raw));
		}
		/// <summary>
		/// The children of the node as an Array object, could be None.
		/// </summary>
		public Array? Children
		{
			get => Array.FromOpt(Native.node_get_children(Raw));
		}
		/// <summary>
		/// The parent of the node, could be None.
		/// </summary>
		public Node? Parent
		{
			get => Node.FromOpt(Native.node_get_parent(Raw));
		}
		/// <summary>
		/// Whether the node is currently running in a scene tree.
		/// </summary>
		public bool IsRunning
		{
			get => Native.node_is_running(Raw) != 0;
		}
		/// <summary>
		/// Whether the node is currently scheduling a function for updates.
		/// </summary>
		public bool IsScheduled
		{
			get => Native.node_is_scheduled(Raw) != 0;
		}
		/// <summary>
		/// The number of actions currently running on the node.
		/// </summary>
		public int ActionCount
		{
			get => Native.node_get_action_count(Raw);
		}
		/// <summary>
		/// Additional data stored on the node as a Dictionary object.
		/// </summary>
		public Dictionary Data
		{
			get => Dictionary.From(Native.node_get_data(Raw));
		}
		/// <summary>
		/// Whether touch events are enabled on the node.
		/// </summary>
		public bool IsTouchEnabled
		{
			set => Native.node_set_touch_enabled(Raw, value ? 1 : 0);
			get => Native.node_is_touch_enabled(Raw) != 0;
		}
		/// <summary>
		/// Whether the node should swallow touch events.
		/// </summary>
		public bool IsSwallowTouches
		{
			set => Native.node_set_swallow_touches(Raw, value ? 1 : 0);
			get => Native.node_is_swallow_touches(Raw) != 0;
		}
		/// <summary>
		/// Whether the node should swallow mouse wheel events.
		/// </summary>
		public bool IsSwallowMouseWheel
		{
			set => Native.node_set_swallow_mouse_wheel(Raw, value ? 1 : 0);
			get => Native.node_is_swallow_mouse_wheel(Raw) != 0;
		}
		/// <summary>
		/// Whether keyboard events are enabled on the node.
		/// </summary>
		public bool IsKeyboardEnabled
		{
			set => Native.node_set_keyboard_enabled(Raw, value ? 1 : 0);
			get => Native.node_is_keyboard_enabled(Raw) != 0;
		}
		/// <summary>
		/// Whether controller events are enabled on the node.
		/// </summary>
		public bool IsControllerEnabled
		{
			set => Native.node_set_controller_enabled(Raw, value ? 1 : 0);
			get => Native.node_is_controller_enabled(Raw) != 0;
		}
		/// <summary>
		/// Whether to group the node's rendering with all its recursive children.
		/// </summary>
		public bool IsRenderGroup
		{
			set => Native.node_set_render_group(Raw, value ? 1 : 0);
			get => Native.node_is_render_group(Raw) != 0;
		}
		/// <summary>
		/// Whether debug graphic should be displayed for the node.
		/// </summary>
		public bool IsShowDebug
		{
			set => Native.node_set_show_debug(Raw, value ? 1 : 0);
			get => Native.node_is_show_debug(Raw) != 0;
		}
		/// <summary>
		/// The rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
		/// </summary>
		public int RenderOrder
		{
			set => Native.node_set_render_order(Raw, value);
			get => Native.node_get_render_order(Raw);
		}
		/// <summary>
		/// Adds a child node to the current node.
		/// </summary>
		/// <param name="child">The child node to add.</param>
		/// <param name="order">The drawing order of the child node.</param>
		/// <param name="tag">The tag of the child node.</param>
		public void AddChild(Node child, int order, string tag)
		{
			Native.node_add_child_with_order_tag(Raw, child.Raw, order, Bridge.FromString(tag));
		}
		/// <summary>
		/// Adds a child node to the current node.
		/// </summary>
		/// <param name="child">The child node to add.</param>
		/// <param name="order">The drawing order of the child node.</param>
		public void AddChild(Node child, int order)
		{
			Native.node_add_child_with_order(Raw, child.Raw, order);
		}
		/// <summary>
		/// Adds a child node to the current node.
		/// </summary>
		/// <param name="child">The child node to add.</param>
		public void AddChild(Node child)
		{
			Native.node_add_child(Raw, child.Raw);
		}
		/// <summary>
		/// Adds the current node to a parent node.
		/// </summary>
		/// <param name="parent">The parent node to add the current node to.</param>
		/// <param name="order">The drawing order of the current node.</param>
		/// <param name="tag">The tag of the current node.</param>
		/// <returns>The current node.</returns>
		public Node AddTo(Node parent, int order, string tag)
		{
			return Node.From(Native.node_add_to_with_order_tag(Raw, parent.Raw, order, Bridge.FromString(tag)));
		}
		/// <summary>
		/// Adds the current node to a parent node.
		/// </summary>
		/// <param name="parent">The parent node to add the current node to.</param>
		/// <param name="order">The drawing order of the current node.</param>
		/// <returns>The current node.</returns>
		public Node AddTo(Node parent, int order)
		{
			return Node.From(Native.node_add_to_with_order(Raw, parent.Raw, order));
		}
		/// <summary>
		/// Adds the current node to a parent node.
		/// </summary>
		/// <param name="parent">The parent node to add the current node to.</param>
		/// <returns>The current node.</returns>
		public Node AddTo(Node parent)
		{
			return Node.From(Native.node_add_to(Raw, parent.Raw));
		}
		/// <summary>
		/// Removes a child node from the current node.
		/// </summary>
		/// <param name="child">The child node to remove.</param>
		/// <param name="cleanup">Whether to cleanup the child node.</param>
		public void RemoveChild(Node child, bool cleanup)
		{
			Native.node_remove_child(Raw, child.Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Removes a child node from the current node by tag.
		/// </summary>
		/// <param name="tag">The tag of the child node to remove.</param>
		/// <param name="cleanup">Whether to cleanup the child node.</param>
		public void RemoveChildByTag(string tag, bool cleanup)
		{
			Native.node_remove_child_by_tag(Raw, Bridge.FromString(tag), cleanup ? 1 : 0);
		}
		/// <summary>
		/// Removes all child nodes from the current node.
		/// </summary>
		/// <param name="cleanup">Whether to cleanup the child nodes.</param>
		public void RemoveAllChildren(bool cleanup)
		{
			Native.node_remove_all_children(Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Removes the current node from its parent node.
		/// </summary>
		/// <param name="cleanup">Whether to cleanup the current node.</param>
		public void RemoveFromParent(bool cleanup)
		{
			Native.node_remove_from_parent(Raw, cleanup ? 1 : 0);
		}
		/// <summary>
		/// Moves the current node to a new parent node without triggering node events.
		/// </summary>
		/// <param name="parent">The new parent node to move the current node to.</param>
		public void MoveToParent(Node parent)
		{
			Native.node_move_to_parent(Raw, parent.Raw);
		}
		/// <summary>
		/// Cleans up the current node.
		/// </summary>
		public void Cleanup()
		{
			Native.node_cleanup(Raw);
		}
		/// <summary>
		/// Gets a child node by tag.
		/// </summary>
		/// <param name="tag">The tag of the child node to get.</param>
		/// <returns>The child node, or `None` if not found.</returns>
		public Node? GetChildByTag(string tag)
		{
			return Node.FromOpt(Native.node_get_child_by_tag(Raw, Bridge.FromString(tag)));
		}
		/// <summary>
		/// Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
		/// </summary>
		/// <param name="updateFunc">The function to be called. If the function returns `true`, it will not be called again.</param>
		public void Schedule(Func<double, bool> updateFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = updateFunc(stack0.PopF64());
				stack0.Push(result);
			});
			Native.node_schedule(Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Unschedules the current node's scheduled main function.
		/// </summary>
		public void Unschedule()
		{
			Native.node_unschedule(Raw);
		}
		/// <summary>
		/// Converts a point from world space to node space.
		/// </summary>
		/// <param name="worldPoint">The point in world space, represented by a Vec2 object.</param>
		/// <returns>The converted point in world space.</returns>
		public Vec2 ConvertToNodeSpace(Vec2 worldPoint)
		{
			return Vec2.From(Native.node_convert_to_node_space(Raw, worldPoint.Raw));
		}
		/// <summary>
		/// Converts a point from node space to world space.
		/// </summary>
		/// <param name="nodePoint">The point in node space, represented by a Vec2 object.</param>
		/// <returns>The converted point in world space.</returns>
		public Vec2 ConvertToWorldSpace(Vec2 nodePoint)
		{
			return Vec2.From(Native.node_convert_to_world_space(Raw, nodePoint.Raw));
		}
		/// <summary>
		/// Converts a point from node space to world space.
		/// </summary>
		/// <param name="nodePoint">The point in node space, represented by a Vec2 object.</param>
		/// <param name="callback">The function to call with the converted point in world space.</param>
		/// <returns>The converted point in world space.</returns>
		public void ConvertToWindowSpace(Vec2 nodePoint, System.Action<Vec2> callback)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				callback(stack0.PopVec2());
			});
			Native.node_convert_to_window_space(Raw, nodePoint.Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Calls the given function for each child node of this node.
		/// </summary>
		/// <param name="visitorFunc">The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.</param>
		/// <returns>`false` if all children have been visited, `true` if the iteration was interrupted by the function.</returns>
		public bool EachChild(Func<Node, bool> visitorFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = visitorFunc((Node)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.node_each_child(Raw, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited.
		/// </summary>
		/// <param name="visitorFunc">The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.</param>
		/// <returns>`false` if all nodes have been visited, `true` if the traversal was interrupted by the function.</returns>
		public bool Traverse(Func<Node, bool> visitorFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = visitorFunc((Node)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.node_traverse(Raw, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Traverses the entire node hierarchy starting from this node and calls the given function for each visited node.
		/// </summary>
		/// <param name="visitorFunc">The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.</param>
		/// <returns>`false` if all nodes have been visited, `true` if the traversal was interrupted by the function.</returns>
		public bool TraverseAll(Func<Node, bool> visitorFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = visitorFunc((Node)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.node_traverse_all(Raw, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Runs an action defined by the given action definition on this node.
		/// </summary>
		/// <param name="actionDef">The action definition to run.</param>
		/// <param name="looped">Whether to loop the action.</param>
		/// <returns>The duration of the newly running action in seconds.</returns>
		public float RunActionDef(ActionDef actionDef, bool looped)
		{
			return Native.node_run_action_def(Raw, actionDef.Raw, looped ? 1 : 0);
		}
		/// <summary>
		/// Runs an action on this node.
		/// </summary>
		/// <param name="action">The action to run.</param>
		/// <param name="looped">Whether to loop the action.</param>
		/// <returns>The duration of the newly running action in seconds.</returns>
		public float RunAction(Action action, bool looped)
		{
			return Native.node_run_action(Raw, action.Raw, looped ? 1 : 0);
		}
		/// <summary>
		/// Stops all actions running on this node.
		/// </summary>
		public void StopAllActions()
		{
			Native.node_stop_all_actions(Raw);
		}
		/// <summary>
		/// Runs an action defined by the given action definition right after clearing all the previous running actions.
		/// </summary>
		/// <param name="actionDef">The action definition to run.</param>
		/// <param name="looped">Whether to loop the action.</param>
		/// <returns>The duration of the newly running action in seconds.</returns>
		public float PerformDef(ActionDef actionDef, bool looped)
		{
			return Native.node_perform_def(Raw, actionDef.Raw, looped ? 1 : 0);
		}
		/// <summary>
		/// Runs an action on this node right after clearing all the previous running actions.
		/// </summary>
		/// <param name="action">The action to run.</param>
		/// <param name="looped">Whether to loop the action.</param>
		/// <returns>The duration of the newly running action in seconds.</returns>
		public float Perform(Action action, bool looped)
		{
			return Native.node_perform(Raw, action.Raw, looped ? 1 : 0);
		}
		/// <summary>
		/// Stops the given action running on this node.
		/// </summary>
		/// <param name="action">The action to stop.</param>
		public void StopAction(Action action)
		{
			Native.node_stop_action(Raw, action.Raw);
		}
		/// <summary>
		/// Vertically aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItemsVertically(float padding)
		{
			return Size.From(Native.node_align_items_vertically(Raw, padding));
		}
		/// <summary>
		/// Vertically aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="size">The size to use for alignment.</param>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItemsVertically(Size size, float padding)
		{
			return Size.From(Native.node_align_items_vertically_with_size(Raw, size.Raw, padding));
		}
		/// <summary>
		/// Horizontally aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItemsHorizontally(float padding)
		{
			return Size.From(Native.node_align_items_horizontally(Raw, padding));
		}
		/// <summary>
		/// Horizontally aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="size">The size to hint for alignment.</param>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItemsHorizontally(Size size, float padding)
		{
			return Size.From(Native.node_align_items_horizontally_with_size(Raw, size.Raw, padding));
		}
		/// <summary>
		/// Aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItems(float padding)
		{
			return Size.From(Native.node_align_items(Raw, padding));
		}
		/// <summary>
		/// Aligns all child nodes within the node using the given size and padding.
		/// </summary>
		/// <param name="size">The size to use for alignment.</param>
		/// <param name="padding">The amount of padding to use between each child node.</param>
		/// <returns>The size of the node after alignment.</returns>
		public Size AlignItems(Size size, float padding)
		{
			return Size.From(Native.node_align_items_with_size(Raw, size.Raw, padding));
		}
		/// <summary>
		/// Moves and changes child nodes' visibility based on their position in parent's area.
		/// </summary>
		/// <param name="delta">The distance to move its children, represented by a Vec2 object.</param>
		public void MoveAndCullItems(Vec2 delta)
		{
			Native.node_move_and_cull_items(Raw, delta.Raw);
		}
		/// <summary>
		/// Attaches the input method editor (IME) to the node.
		/// Makes node recieving "AttachIME", "DetachIME", "TextInput", "TextEditing" events.
		/// </summary>
		public void AttachIme()
		{
			Native.node_attach_ime(Raw);
		}
		/// <summary>
		/// Detaches the input method editor (IME) from the node.
		/// </summary>
		public void DetachIme()
		{
			Native.node_detach_ime(Raw);
		}
		/// <summary>
		/// Creates a texture grabber for the specified node.
		/// </summary>
		/// <returns>A Grabber object with gridX == 1 and gridY == 1.</returns>
		public Grabber Grab()
		{
			return Grabber.From(Native.node_grab(Raw));
		}
		/// <summary>
		/// Creates a texture grabber for the specified node with a specified grid size.
		/// </summary>
		/// <param name="gridX">The number of horizontal grid cells to divide the grabber into.</param>
		/// <param name="gridY">The number of vertical grid cells to divide the grabber into.</param>
		/// <returns>A Grabber object.</returns>
		public Grabber Grab(int gridX, int gridY)
		{
			return Grabber.From(Native.node_grab_with_size(Raw, gridX, gridY));
		}
		/// <summary>
		/// Removes the texture grabber for the specified node.
		/// </summary>
		public void StopGrab()
		{
			Native.node_stop_grab(Raw);
		}
		/// <summary>
		/// Associates the given handler function with the node event.
		/// </summary>
		/// <param name="eventName">The name of the node event.</param>
		/// <param name="handler">The handler function to associate with the node event.</param>
		public void Slot(string eventName, System.Action<CallStack> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler(stack0);
			});
			Native.node_slot(Raw, Bridge.FromString(eventName), func_id0, stack_raw0);
		}
		/// <summary>
		/// Associates the given handler function with a global event.
		/// </summary>
		/// <param name="eventName">The name of the global event.</param>
		/// <param name="handler">The handler function to associate with the event.</param>
		public void Gslot(string eventName, System.Action<CallStack> handler)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				handler(stack0);
			});
			Native.node_gslot(Raw, Bridge.FromString(eventName), func_id0, stack_raw0);
		}
		/// <summary>
		/// Emits an event to a node, triggering the event handler associated with the event name.
		/// </summary>
		/// <param name="name">The name of the event.</param>
		/// <param name="stack">The argument stack to be passed to the event handler.</param>
		public void Emit(string name, CallStack stack)
		{
			Native.node_emit(Raw, Bridge.FromString(name), stack.Raw);
		}
		/// <summary>
		/// Schedules a function to run every frame. Call this function again to schedule multiple functions.
		/// </summary>
		/// <param name="updateFunc">The function to run every frame. If the function returns `true`, it will not be called again.</param>
		public void OnUpdate(Func<double, bool> updateFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = updateFunc(stack0.PopF64());
				stack0.Push(result);
			});
			Native.node_on_update(Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
		/// </summary>
		/// <param name="renderFunc">The function to call when the node is entering the rendering phase, returns true to stop.</param>
		/// <returns>True to stop the function from running.</returns>
		public void OnRender(Func<double, bool> renderFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = renderFunc(stack0.PopF64());
				stack0.Push(result);
			});
			Native.node_on_render(Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Creates a new instance of the `Node` struct.
		/// </summary>
		public Node() : this(Native.node_new()) { }
	}
} // namespace Dora
