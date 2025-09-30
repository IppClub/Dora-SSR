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
		public static extern int32_t platformer_data_get_group_first_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_last_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_hide();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_detect_player();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_terrain();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_group_detection();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_data_get_store();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_should_contact(int32_t groupA, int32_t groupB, int32_t contact);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_should_contact(int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_relation(int32_t groupA, int32_t groupB, int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation_by_group(int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation(int64_t bodyA, int64_t bodyB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy_group(int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy(int64_t bodyA, int64_t bodyB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend_group(int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend(int64_t bodyA, int64_t bodyB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral_group(int32_t groupA, int32_t groupB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral(int64_t bodyA, int64_t bodyB);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_damage_factor(int32_t damageType, int32_t defenceType, float bounus);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_data_get_damage_factor(int32_t damageType, int32_t defenceType);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_player(int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_terrain(int64_t body);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_clear();
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// <summary>
	/// An interface that provides a centralized location for storing and accessing game-related data.
	/// </summary>
	public static partial class Data
	{
		/// <summary>
		/// The group key representing the first index for a player group.
		/// </summary>
		public static int GroupFirstPlayer
		{
			get => Native.platformer_data_get_group_first_player();
		}
		/// <summary>
		/// The group key representing the last index for a player group.
		/// </summary>
		public static int GroupLastPlayer
		{
			get => Native.platformer_data_get_group_last_player();
		}
		/// <summary>
		/// The group key that won't have any contact with other groups by default.
		/// </summary>
		public static int GroupHide
		{
			get => Native.platformer_data_get_group_hide();
		}
		/// <summary>
		/// The group key that will have contacts with player groups by default.
		/// </summary>
		public static int GroupDetectPlayer
		{
			get => Native.platformer_data_get_group_detect_player();
		}
		/// <summary>
		/// The group key representing terrain that will have contacts with other groups by default.
		/// </summary>
		public static int GroupTerrain
		{
			get => Native.platformer_data_get_group_terrain();
		}
		/// <summary>
		/// The group key that will have contacts with other groups by default.
		/// </summary>
		public static int GroupDetection
		{
			get => Native.platformer_data_get_group_detection();
		}
		/// <summary>
		/// The dictionary that can be used to store arbitrary data associated with string keys and various values globally.
		/// </summary>
		public static Dictionary Store
		{
			get => Dictionary.From(Native.platformer_data_get_store());
		}
		/// <summary>
		/// Sets a boolean value indicating whether two groups should be in contact or not.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		/// <param name="contact">A boolean indicating whether the two groups should be in contact.</param>
		public static void SetShouldContact(int groupA, int groupB, bool contact)
		{
			Native.platformer_data_set_should_contact(groupA, groupB, contact ? 1 : 0);
		}
		/// <summary>
		/// Gets a boolean value indicating whether two groups should be in contact or not.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		public static bool GetShouldContact(int groupA, int groupB)
		{
			return Native.platformer_data_get_should_contact(groupA, groupB) != 0;
		}
		/// <summary>
		/// Sets the relation between two groups.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		/// <param name="relation">The relation between the two groups.</param>
		public static void SetRelation(int groupA, int groupB, Platformer.Relation relation)
		{
			Native.platformer_data_set_relation(groupA, groupB, (int)relation);
		}
		/// <summary>
		/// Gets the relation between two groups.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		public static Platformer.Relation GetRelationByGroup(int groupA, int groupB)
		{
			return (Platformer.Relation)Native.platformer_data_get_relation_by_group(groupA, groupB);
		}
		/// <summary>
		/// A function that can be used to get the relation between two bodies.
		/// </summary>
		/// <param name="bodyA">The first body.</param>
		/// <param name="bodyB">The second body.</param>
		public static Platformer.Relation GetRelation(Body bodyA, Body bodyB)
		{
			return (Platformer.Relation)Native.platformer_data_get_relation(bodyA.Raw, bodyB.Raw);
		}
		/// <summary>
		/// A function that returns whether two groups have an "Enemy" relation.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		public static bool IsEnemyGroup(int groupA, int groupB)
		{
			return Native.platformer_data_is_enemy_group(groupA, groupB) != 0;
		}
		/// <summary>
		/// A function that returns whether two bodies have an "Enemy" relation.
		/// </summary>
		/// <param name="bodyA">The first body.</param>
		/// <param name="bodyB">The second body.</param>
		public static bool IsEnemy(Body bodyA, Body bodyB)
		{
			return Native.platformer_data_is_enemy(bodyA.Raw, bodyB.Raw) != 0;
		}
		/// <summary>
		/// A function that returns whether two groups have a "Friend" relation.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		public static bool IsFriendGroup(int groupA, int groupB)
		{
			return Native.platformer_data_is_friend_group(groupA, groupB) != 0;
		}
		/// <summary>
		/// A function that returns whether two bodies have a "Friend" relation.
		/// </summary>
		/// <param name="bodyA">The first body.</param>
		/// <param name="bodyB">The second body.</param>
		public static bool IsFriend(Body bodyA, Body bodyB)
		{
			return Native.platformer_data_is_friend(bodyA.Raw, bodyB.Raw) != 0;
		}
		/// <summary>
		/// A function that returns whether two groups have a "Neutral" relation.
		/// </summary>
		/// <param name="groupA">An integer representing the first group.</param>
		/// <param name="groupB">An integer representing the second group.</param>
		public static bool IsNeutralGroup(int groupA, int groupB)
		{
			return Native.platformer_data_is_neutral_group(groupA, groupB) != 0;
		}
		/// <summary>
		/// A function that returns whether two bodies have a "Neutral" relation.
		/// </summary>
		/// <param name="bodyA">The first body.</param>
		/// <param name="bodyB">The second body.</param>
		public static bool IsNeutral(Body bodyA, Body bodyB)
		{
			return Native.platformer_data_is_neutral(bodyA.Raw, bodyB.Raw) != 0;
		}
		/// <summary>
		/// Sets the bonus factor for a particular type of damage against a particular type of defence.
		/// The builtin "MeleeAttack" and "RangeAttack" actions use a simple formula of `finalDamage = damage * bonus`.
		/// </summary>
		/// <param name="damageType">An integer representing the type of damage.</param>
		/// <param name="defenceType">An integer representing the type of defence.</param>
		/// <param name="bonus">A number representing the bonus.</param>
		public static void SetDamageFactor(int damageType, int defenceType, float bounus)
		{
			Native.platformer_data_set_damage_factor(damageType, defenceType, bounus);
		}
		/// <summary>
		/// Gets the bonus factor for a particular type of damage against a particular type of defence.
		/// </summary>
		/// <param name="damageType">An integer representing the type of damage.</param>
		/// <param name="defenceType">An integer representing the type of defence.</param>
		public static float GetDamageFactor(int damageType, int defenceType)
		{
			return Native.platformer_data_get_damage_factor(damageType, defenceType);
		}
		/// <summary>
		/// A function that returns whether a body is a player or not.
		/// This works the same as `Data::get_group_first_player() <= body.group and body.group <= Data::get_group_last_player()`.
		/// </summary>
		/// <param name="body">The body to check.</param>
		public static bool IsPlayer(Body body)
		{
			return Native.platformer_data_is_player(body.Raw) != 0;
		}
		/// <summary>
		/// A function that returns whether a body is terrain or not.
		/// This works the same as `body.group == Data.GetGroupTerrain()`.
		/// </summary>
		/// <param name="body">The body to check.</param>
		public static bool IsTerrain(Body body)
		{
			return Native.platformer_data_is_terrain(body.Raw) != 0;
		}
		/// <summary>
		/// Clears all data stored in the "Data" object, including user data in Data.store field. And reset some data to default values.
		/// </summary>
		public static void Clear()
		{
			Native.platformer_data_clear();
		}
	}
} // namespace Dora.Platformer
