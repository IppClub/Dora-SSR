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
		public static extern void platformer_data_set_should_contact(int32_t group_a, int32_t group_b, int32_t contact);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_should_contact(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_relation(int32_t group_a, int32_t group_b, int32_t relation);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation_by_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_get_relation(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_enemy(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_friend(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral_group(int32_t group_a, int32_t group_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t platformer_data_is_neutral(int64_t body_a, int64_t body_b);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_data_set_damage_factor(int32_t damage_type, int32_t defence_type, float bounus);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_data_get_damage_factor(int32_t damage_type, int32_t defence_type);
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
	/// An interface that provides a centralized location for storing and accessing game-related data.
	public static partial class Data
	{
		/// the group key representing the first index for a player group.
		public static int GroupFirstPlayer
		{
			get => Native.platformer_data_get_group_first_player();
		}
		/// the group key representing the last index for a player group.
		public static int GroupLastPlayer
		{
			get => Native.platformer_data_get_group_last_player();
		}
		/// the group key that won't have any contact with other groups by default.
		public static int GroupHide
		{
			get => Native.platformer_data_get_group_hide();
		}
		/// the group key that will have contacts with player groups by default.
		public static int GroupDetectPlayer
		{
			get => Native.platformer_data_get_group_detect_player();
		}
		/// the group key representing terrain that will have contacts with other groups by default.
		public static int GroupTerrain
		{
			get => Native.platformer_data_get_group_terrain();
		}
		/// the group key that will have contacts with other groups by default.
		public static int GroupDetection
		{
			get => Native.platformer_data_get_group_detection();
		}
		/// the dictionary that can be used to store arbitrary data associated with string keys and various values globally.
		public static Dictionary Store
		{
			get => Dictionary.From(Native.platformer_data_get_store());
		}
		/// Sets a boolean value indicating whether two groups should be in contact or not.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		/// * `contact` - A boolean indicating whether the two groups should be in contact.
		public static void SetShouldContact(int group_a, int group_b, bool contact)
		{
			Native.platformer_data_set_should_contact(group_a, group_b, contact ? 1 : 0);
		}
		/// Gets a boolean value indicating whether two groups should be in contact or not.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two groups should be in contact.
		public static bool GetShouldContact(int group_a, int group_b)
		{
			return Native.platformer_data_get_should_contact(group_a, group_b) != 0;
		}
		/// Sets the relation between two groups.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		/// * `relation` - The relation between the two groups.
		public static void SetRelation(int group_a, int group_b, Platformer.Relation relation)
		{
			Native.platformer_data_set_relation(group_a, group_b, (int)relation);
		}
		/// Gets the relation between two groups.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		///
		/// # Returns
		///
		/// * The relation between the two groups.
		public static Platformer.Relation GetRelationByGroup(int group_a, int group_b)
		{
			return (Platformer.Relation)Native.platformer_data_get_relation_by_group(group_a, group_b);
		}
		/// A function that can be used to get the relation between two bodies.
		///
		/// # Arguments
		///
		/// * `body_a` - The first body.
		/// * `body_b` - The second body.
		///
		/// # Returns
		///
		/// * The relation between the two bodies.
		public static Platformer.Relation GetRelation(Body body_a, Body body_b)
		{
			return (Platformer.Relation)Native.platformer_data_get_relation(body_a.Raw, body_b.Raw);
		}
		/// A function that returns whether two groups have an "Enemy" relation.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two groups have an "Enemy" relation.
		public static bool IsEnemyGroup(int group_a, int group_b)
		{
			return Native.platformer_data_is_enemy_group(group_a, group_b) != 0;
		}
		/// A function that returns whether two bodies have an "Enemy" relation.
		///
		/// # Arguments
		///
		/// * `body_a` - The first body.
		/// * `body_b` - The second body.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two bodies have an "Enemy" relation.
		public static bool IsEnemy(Body body_a, Body body_b)
		{
			return Native.platformer_data_is_enemy(body_a.Raw, body_b.Raw) != 0;
		}
		/// A function that returns whether two groups have a "Friend" relation.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two groups have a "Friend" relation.
		public static bool IsFriendGroup(int group_a, int group_b)
		{
			return Native.platformer_data_is_friend_group(group_a, group_b) != 0;
		}
		/// A function that returns whether two bodies have a "Friend" relation.
		///
		/// # Arguments
		///
		/// * `body_a` - The first body.
		/// * `body_b` - The second body.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two bodies have a "Friend" relation.
		public static bool IsFriend(Body body_a, Body body_b)
		{
			return Native.platformer_data_is_friend(body_a.Raw, body_b.Raw) != 0;
		}
		/// A function that returns whether two groups have a "Neutral" relation.
		///
		/// # Arguments
		///
		/// * `group_a` - An integer representing the first group.
		/// * `group_b` - An integer representing the second group.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two groups have a "Neutral" relation.
		public static bool IsNeutralGroup(int group_a, int group_b)
		{
			return Native.platformer_data_is_neutral_group(group_a, group_b) != 0;
		}
		/// A function that returns whether two bodies have a "Neutral" relation.
		///
		/// # Arguments
		///
		/// * `body_a` - The first body.
		/// * `body_b` - The second body.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the two bodies have a "Neutral" relation.
		public static bool IsNeutral(Body body_a, Body body_b)
		{
			return Native.platformer_data_is_neutral(body_a.Raw, body_b.Raw) != 0;
		}
		/// Sets the bonus factor for a particular type of damage against a particular type of defence.
		///
		/// The builtin "MeleeAttack" and "RangeAttack" actions use a simple formula of `finalDamage = damage * bonus`.
		///
		/// # Arguments
		///
		/// * `damage_type` - An integer representing the type of damage.
		/// * `defence_type` - An integer representing the type of defence.
		/// * `bonus` - A number representing the bonus.
		public static void SetDamageFactor(int damage_type, int defence_type, float bounus)
		{
			Native.platformer_data_set_damage_factor(damage_type, defence_type, bounus);
		}
		/// Gets the bonus factor for a particular type of damage against a particular type of defence.
		///
		/// # Arguments
		///
		/// * `damage_type` - An integer representing the type of damage.
		/// * `defence_type` - An integer representing the type of defence.
		///
		/// # Returns
		///
		/// * A number representing the bonus factor.
		public static float GetDamageFactor(int damage_type, int defence_type)
		{
			return Native.platformer_data_get_damage_factor(damage_type, defence_type);
		}
		/// A function that returns whether a body is a player or not.
		///
		/// This works the same as `Data::get_group_first_player() <= body.group and body.group <= Data::get_group_last_player()`.
		///
		/// # Arguments
		///
		/// * `body` - The body to check.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the body is a player.
		public static bool IsPlayer(Body body)
		{
			return Native.platformer_data_is_player(body.Raw) != 0;
		}
		/// A function that returns whether a body is terrain or not.
		///
		/// This works the same as `body.group == Data::get_group_terrain()`.
		///
		/// # Arguments
		///
		/// * `body` - The body to check.
		///
		/// # Returns
		///
		/// * A boolean indicating whether the body is terrain.
		public static bool IsTerrain(Body body)
		{
			return Native.platformer_data_is_terrain(body.Raw) != 0;
		}
		/// Clears all data stored in the "Data" object, including user data in Data.store field. And reset some data to default values.
		public static void Clear()
		{
			Native.platformer_data_clear();
		}
	}
} // namespace Dora.Platformer
