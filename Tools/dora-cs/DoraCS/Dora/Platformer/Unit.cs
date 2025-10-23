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
		public static extern int32_t platformer_unit_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_playable(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_playable(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_detect_distance(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_detect_distance(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_attack_range(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_attack_range(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_face_right(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_face_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_receiving_decision_trace(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_receiving_decision_trace(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_set_decision_tree(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_decision_tree(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_on_surface(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_ground_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_detect_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_attack_sensor(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_unit_def(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_current_action(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_unit_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_entity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_attach_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_remove_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_remove_all_actions(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_get_action(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_each_action(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_start(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_unit_stop(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_unit_is_doing(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_new(int64_t unitDef, int64_t physicsWorld, int64_t entity, int64_t pos, float rot);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_unit_with_store(int64_t unitDefName, int64_t physicsWorldName, int64_t entity, int64_t pos, float rot);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// A struct represents a character or other interactive item in a game scene.
	/// </summary>
	public partial class Unit : Body
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.platformer_unit_type(), From);
		}
		protected Unit(long raw) : base(raw) { }
		internal static new Unit From(long raw)
		{
			return new Unit(raw);
		}
		internal static new Unit? FromOpt(long raw)
		{
			return raw == 0 ? null : new Unit(raw);
		}
		/// <summary>
		/// The property that references a "Playable" object for managing the animation state and playback of the "Unit".
		/// </summary>
		public Playable Playable
		{
			set => Native.platformer_unit_set_playable(Raw, value.Raw);
			get => Playable.From(Native.platformer_unit_get_playable(Raw));
		}
		/// <summary>
		/// The property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
		/// </summary>
		public float DetectDistance
		{
			set => Native.platformer_unit_set_detect_distance(Raw, value);
			get => Native.platformer_unit_get_detect_distance(Raw);
		}
		/// <summary>
		/// The property that specifies the size of the attack range for the "Unit".
		/// </summary>
		public Size AttackRange
		{
			set => Native.platformer_unit_set_attack_range(Raw, value.Raw);
			get => Size.From(Native.platformer_unit_get_attack_range(Raw));
		}
		/// <summary>
		/// The boolean property that specifies whether the "Unit" is facing right or not.
		/// </summary>
		public bool IsFaceRight
		{
			set => Native.platformer_unit_set_face_right(Raw, value ? 1 : 0);
			get => Native.platformer_unit_is_face_right(Raw) != 0;
		}
		/// <summary>
		/// The boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
		/// </summary>
		public bool IsReceivingDecisionTrace
		{
			set => Native.platformer_unit_set_receiving_decision_trace(Raw, value ? 1 : 0);
			get => Native.platformer_unit_is_receiving_decision_trace(Raw) != 0;
		}
		/// <summary>
		/// The string property that specifies the decision tree to use for the "Unit's" AI behavior.
		/// the decision tree object will be searched in The singleton instance Data.store.
		/// </summary>
		public string DecisionTree
		{
			set => Native.platformer_unit_set_decision_tree(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.platformer_unit_get_decision_tree(Raw));
		}
		/// <summary>
		/// Whether the "Unit" is currently on a surface or not.
		/// </summary>
		public bool IsOnSurface
		{
			get => Native.platformer_unit_is_on_surface(Raw) != 0;
		}
		/// <summary>
		/// The "Sensor" object for detecting ground surfaces.
		/// </summary>
		public Sensor GroundSensor
		{
			get => Sensor.From(Native.platformer_unit_get_ground_sensor(Raw));
		}
		/// <summary>
		/// The "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
		/// </summary>
		public Sensor DetectSensor
		{
			get => Sensor.From(Native.platformer_unit_get_detect_sensor(Raw));
		}
		/// <summary>
		/// The "Sensor" object for detecting other "Unit" objects within the attack senser area.
		/// </summary>
		public Sensor AttackSensor
		{
			get => Sensor.From(Native.platformer_unit_get_attack_sensor(Raw));
		}
		/// <summary>
		/// The "Dictionary" object for defining the properties and behavior of the "Unit".
		/// </summary>
		public Dictionary UnitDef
		{
			get => Dictionary.From(Native.platformer_unit_get_unit_def(Raw));
		}
		/// <summary>
		/// The property that specifies the current action being performed by the "Unit".
		/// </summary>
		public Platformer.UnitAction CurrentAction
		{
			get => Platformer.UnitAction.From(Native.platformer_unit_get_current_action(Raw));
		}
		/// <summary>
		/// The width of the "Unit".
		/// </summary>
		public new float Width
		{
			get => Native.platformer_unit_get_width(Raw);
		}
		/// <summary>
		/// The height of the "Unit".
		/// </summary>
		public new float Height
		{
			get => Native.platformer_unit_get_height(Raw);
		}
		/// <summary>
		/// The "Entity" object for representing the "Unit" in the ECS system.
		/// </summary>
		public Entity Entity
		{
			get => Entity.From(Native.platformer_unit_get_entity(Raw));
		}
		/// <summary>
		/// Adds a new `UnitAction` to the `Unit` with the specified name, and returns the new `UnitAction`.
		/// </summary>
		/// <param name="name">The name of the new `UnitAction`.</param>
		public Platformer.UnitAction AttachAction(string name)
		{
			return Platformer.UnitAction.From(Native.platformer_unit_attach_action(Raw, Bridge.FromString(name)));
		}
		/// <summary>
		/// Removes the `UnitAction` with the specified name from the `Unit`.
		/// </summary>
		/// <param name="name">The name of the `UnitAction` to remove.</param>
		public void RemoveAction(string name)
		{
			Native.platformer_unit_remove_action(Raw, Bridge.FromString(name));
		}
		/// <summary>
		/// Removes all "UnitAction" objects from the "Unit".
		/// </summary>
		public void RemoveAllActions()
		{
			Native.platformer_unit_remove_all_actions(Raw);
		}
		/// <summary>
		/// Returns the `UnitAction` with the specified name, or `None` if the `UnitAction` does not exist.
		/// </summary>
		/// <param name="name">The name of the `UnitAction` to retrieve.</param>
		public Platformer.UnitAction GetAction(string name)
		{
			return Platformer.UnitAction.From(Native.platformer_unit_get_action(Raw, Bridge.FromString(name)));
		}
		/// <summary>
		/// Calls the specified function for each `UnitAction` attached to the `Unit`.
		/// </summary>
		/// <param name="visitorFunc">A function to call for each `UnitAction`.</param>
		public void EachAction(System.Action<Platformer.UnitAction> visitorFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				visitorFunc(Platformer.UnitAction.From(stack0.PopI64()));
			});
			Native.platformer_unit_each_action(Raw, func_id0, stack_raw0);
		}
		/// <summary>
		/// Starts the `UnitAction` with the specified name, and returns true if the `UnitAction` was started successfully.
		/// </summary>
		/// <param name="name">The name of the `UnitAction` to start.</param>
		public bool Start(string name)
		{
			return Native.platformer_unit_start(Raw, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// Stops the currently running "UnitAction".
		/// </summary>
		public void Stop()
		{
			Native.platformer_unit_stop(Raw);
		}
		/// <summary>
		/// Returns true if the `Unit` is currently performing the specified `UnitAction`, false otherwise.
		/// </summary>
		/// <param name="name">The name of the `UnitAction` to check.</param>
		public bool IsDoing(string name)
		{
			return Native.platformer_unit_is_doing(Raw, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// A method that creates a new `Unit` object.
		/// </summary>
		/// <param name="unitDef">A `Dictionary` object that defines the properties and behavior of the `Unit`.</param>
		/// <param name="physicsWorld">A `PhysicsWorld` object that represents the physics simulation world.</param>
		/// <param name="entity">An `Entity` object that represents the `Unit` in ECS system.</param>
		/// <param name="pos">A `Vec2` object that specifies the initial position of the `Unit`.</param>
		/// <param name="rot">A number that specifies the initial rotation of the `Unit`.</param>
		public Unit(Dictionary unitDef, PhysicsWorld physicsWorld, Entity entity, Vec2 pos, float rot = 0.0f) : this(Native.platformer_unit_new(unitDef.Raw, physicsWorld.Raw, entity.Raw, pos.Raw, rot)) { }
		/// <summary>
		/// A method that creates a new `Unit` object.
		/// </summary>
		/// <param name="unitDefName">A string that specifies the name of the `Unit` definition to retrieve from `Data.store` table.</param>
		/// <param name="physicsWorldName">A string that specifies the name of the `PhysicsWorld` object to retrieve from `Data.store` table.</param>
		/// <param name="entity">An `Entity` object that represents the `Unit` in ECS system.</param>
		/// <param name="pos">A `Vec2` object that specifies the initial position of the `Unit`.</param>
		/// <param name="rot">An optional number that specifies the initial rotation of the `Unit` (default is 0.0).</param>
		public Unit(string unitDefName, string physicsWorldName, Entity entity, Vec2 pos, float rot = 0.0f) : this(Native.platformer_unit_with_store(Bridge.FromString(unitDefName), Bridge.FromString(physicsWorldName), entity.Raw, pos.Raw, rot)) { }
	}
} // namespace Dora.Platformer
