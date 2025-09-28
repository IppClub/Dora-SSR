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
		public static extern void actiondef_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_prop(float duration, float start, float stop, int32_t prop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_tint(float duration, int32_t start, int32_t stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_roll(float duration, float start, float stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_spawn(int64_t defs);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_sequence(int64_t defs);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_delay(float duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_show();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_hide();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_event(int64_t event_name, int64_t msg);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_move_to(float duration, int64_t start, int64_t stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_scale(float duration, float start, float stop, int32_t easing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_frame(int64_t clip_str, float duration);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t actiondef_frame_with_frames(int64_t clip_str, float duration, int64_t frames);
	}
} // namespace Dora

namespace Dora
{
	public partial class ActionDef
	{
		private ActionDef(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create ActionDef");
			Raw = raw;
		}
		~ActionDef()
		{
			Native.actiondef_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static ActionDef From(long raw)
		{
			return new ActionDef(raw);
		}
		/// Creates a new action definition object to change a property of a node.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the action.
		/// * `start` - The starting value of the property.
		/// * `stop` - The ending value of the property.
		/// * `prop` - The property to change.
		/// * `easing` - The easing function to use.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Prop(float duration, float start, float stop, Property prop, EaseType easing)
		{
			return ActionDef.From(Native.actiondef_prop(duration, start, stop, (int)prop, (int)easing));
		}
		/// Creates a new action definition object to change the color of a node.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the action.
		/// * `start` - The starting color.
		/// * `stop` - The ending color.
		/// * `easing` - The easing function to use.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Tint(float duration, Color3 start, Color3 stop, EaseType easing)
		{
			return ActionDef.From(Native.actiondef_tint(duration, (int)start.ToRgb(), (int)stop.ToRgb(), (int)easing));
		}
		/// Creates a new action definition object to rotate a node by smallest angle.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the action.
		/// * `start` - The starting angle.
		/// * `stop` - The ending angle.
		/// * `easing` - The easing function to use.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Roll(float duration, float start, float stop, EaseType easing)
		{
			return ActionDef.From(Native.actiondef_roll(duration, start, stop, (int)easing));
		}
		/// Creates a new action definition object to run a group of actions in parallel.
		///
		/// # Arguments
		///
		/// * `defs` - The actions to run in parallel.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Spawn(IEnumerable<ActionDef> defs)
		{
			return ActionDef.From(Native.actiondef_spawn(Bridge.FromArray(defs)));
		}
		/// Creates a new action definition object to run a group of actions in sequence.
		///
		/// # Arguments
		///
		/// * `defs` - The actions to run in sequence.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Sequence(IEnumerable<ActionDef> defs)
		{
			return ActionDef.From(Native.actiondef_sequence(Bridge.FromArray(defs)));
		}
		/// Creates a new action definition object to delay the execution of following action.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the delay.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Delay(float duration)
		{
			return ActionDef.From(Native.actiondef_delay(duration));
		}
		/// Creates a new action definition object to show a node.
		public static ActionDef Show()
		{
			return ActionDef.From(Native.actiondef_show());
		}
		/// Creates a new action definition object to hide a node.
		public static ActionDef Hide()
		{
			return ActionDef.From(Native.actiondef_hide());
		}
		/// Creates a new action definition object to emit an event.
		///
		/// # Arguments
		///
		/// * `eventName` - The name of the event to emit.
		/// * `msg` - The message to send with the event.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Event(string event_name, string msg)
		{
			return ActionDef.From(Native.actiondef_event(Bridge.FromString(event_name), Bridge.FromString(msg)));
		}
		/// Creates a new action definition object to move a node.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the action.
		/// * `start` - The starting position.
		/// * `stop` - The ending position.
		/// * `easing` - The easing function to use.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef MoveTo(float duration, Vec2 start, Vec2 stop, EaseType easing)
		{
			return ActionDef.From(Native.actiondef_move_to(duration, start.Raw, stop.Raw, (int)easing));
		}
		/// Creates a new action definition object to scale a node.
		///
		/// # Arguments
		///
		/// * `duration` - The duration of the action.
		/// * `start` - The starting scale.
		/// * `stop` - The ending scale.
		/// * `easing` - The easing function to use.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Scale(float duration, float start, float stop, EaseType easing)
		{
			return ActionDef.From(Native.actiondef_scale(duration, start, stop, (int)easing));
		}
		/// Creates a new action definition object to do a frame animation. Can only be performed on a Sprite node.
		///
		/// # Arguments
		///
		/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
		/// * `duration` - The duration of the action.
		///
		/// # Returns
		///
		/// * `ActionDef` - A new ActionDef object.
		public static ActionDef Frame(string clip_str, float duration)
		{
			return ActionDef.From(Native.actiondef_frame(Bridge.FromString(clip_str), duration));
		}
		/// Creates a new action definition object to do a frame animation with frames count for each frame. Can only be performed on a Sprite node.
		///
		/// # Arguments
		///
		/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
		/// * `duration` - The duration of the action.
		/// * `frames` - The number of frames for each frame.
		///
		/// # Returns
		///
		/// * `Action` - A new Action object.
		public static ActionDef FrameWithFrames(string clip_str, float duration, IEnumerable<int> frames)
		{
			return ActionDef.From(Native.actiondef_frame_with_frames(Bridge.FromString(clip_str), duration, Bridge.FromArray(frames)));
		}
	}
} // namespace Dora
