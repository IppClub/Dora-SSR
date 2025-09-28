using Dora;
using Microsoft.Win32.SafeHandles;
using System;
using System.Diagnostics;
using System.Reflection.Metadata;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace Dora
{
    internal static partial class Native
    {
        private const string Dll = "Dora";

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate int MainFunc();
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        public static extern int dora_run(MainFunc mainFunc);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void CallFunctionPointer(int funcId);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        public static extern int dora_register_call_function(CallFunctionPointer mainFunc);


        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void DerefFuncionPointer(int funcId);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        public static extern int dora_register_deref_function(DerefFuncionPointer mainFunc);

        // ---------- String ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long str_new(int len);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int str_len(long str);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void str_read(IntPtr dest, long src);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void str_write(long dest, IntPtr src);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void str_release(long str);

        // ---------- Buf ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long buf_new_i32(int len);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long buf_new_i64(int len);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long buf_new_f32(int len);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long buf_new_f64(int len);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int buf_len(long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void buf_read(IntPtr dest, long src);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void buf_write(long dest, IntPtr src);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void buf_release(long v);

        // ---------- Vec2 ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern float vec2_distance(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern float vec2_distance_squared(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern float vec2_length(long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern float vec2_angle(long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_normalize(long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_perp(long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern float vec2_dot(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_clamp(long v, long from, long to);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_add(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_sub(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_mul(long a, long b);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_mul_float(long v, float s);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long vec2_div(long v, float s);

        // ---------- Object ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int object_get_id(long obj);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int object_get_type(long obj);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void object_retain(long obj);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void object_release(long obj);

        // ---------- Value ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_i64(long value);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_f64(double value);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_str(long strHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_bool(int value01);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_object(long objHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_vec2(long vec2Bits);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_create_size(long sizeBits);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void value_release(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_into_i64(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern double value_into_f64(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_into_str(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_into_bool(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_into_object(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_into_vec2(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long value_into_size(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_i64(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_f64(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_str(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_bool(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_object(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_vec2(long valueHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int value_is_size(long valueHandle);

        // ---------- CallStack ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_create();
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_release(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_i64(long stack, long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_f64(long stack, double v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_str(long stack, long strHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_bool(long stack, int v01);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_object(long stack, long objHandle);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_vec2(long stack, long vec2Bits);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void call_stack_push_size(long stack, long sizeBits);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_pop_i64(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern double call_stack_pop_f64(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_pop_str(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_pop_bool(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_pop_object(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_pop_vec2(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long call_stack_pop_size(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_pop(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_i64(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_f64(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_bool(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_str(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_object(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_vec2(long stack);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int call_stack_front_size(long stack);

        // ---------- Print ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void dora_print(long var);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void dora_print_warning(long var);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void dora_print_error(long var);

        // ---------- emit ----------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void dora_emit(long name, long stack);

        // -------- Array --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int array_set(long array, int index, long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long array_get(long array, int index);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long array_first(long array);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long array_last(long array);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long array_random_object(long array);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void array_add(long array, long item);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void array_insert(long array, int index, long item);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int array_contains(long array, long item);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int array_index(long array, long item);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long array_remove_last(long array);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int array_fast_remove(long array, long item);

        // -------- Dictionary --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void dictionary_set(long dict, long key, long value);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long dictionary_get(long dict, long key);

        // -------- Content --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long content_load(long filename /* string handle */);

        // -------- Entity --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void entity_set(long e, long k, long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long entity_get(long e, long k);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long entity_get_old(long e, long k);

        // -------- EntityGroup --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void group_watch(long group, int func, long stack);

        // -------- EntityObserver --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void observer_watch(long observer, int func, long stack);

        // -------- Blackboard --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void blackboard_set(long b, long k, long v);
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long blackboard_get(long b, long k);

        // -------- Director --------
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long director_get_scheduler();
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long director_get_wasm_scheduler();
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long director_get_post_scheduler();
        [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
        internal static extern long director_get_post_wasm_scheduler();
    }

    public static class Bridge
    {
        public static string ToString(long str)
        {
            int len = Native.str_len(str);
            if (len <= 0)
            {
                Native.str_release(str);
                return string.Empty;
            }

            byte[] buf = new byte[len];
            unsafe { fixed (byte* p = buf) Native.str_read((IntPtr)p, str); }
            Native.str_release(str);
            return Encoding.UTF8.GetString(buf);
        }

        public static long FromString(string s)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(s);
            long h = Native.str_new(bytes.Length);

            if (bytes.Length > 0)
            {
                unsafe { fixed (byte* p = bytes) Native.str_write(h, (IntPtr)p); }
            }
            return h;
        }
        public static long FromArray(IEnumerable<int> arr)
        {
            if (arr is ICollection<int> coll)
            {
                int len = coll.Count;
                if (len == 0) return Native.buf_new_i32(0);

                var handles = new int[len];
                int i = 0;
                foreach (var v in arr) handles[i++] = v;

                long buf = Native.buf_new_i32(len);
                unsafe { fixed (int* p = handles) Native.buf_write(buf, (IntPtr)p); }
                return buf;
            }
            else
            {
                var tmp = new List<int>();
                foreach (var v in arr) tmp.Add(v);

                int len = tmp.Count;
                long h = Native.buf_new_i32(len);
                if (len == 0) return h;

                var handles = tmp.ToArray();
                unsafe { fixed (int* p = handles) Native.buf_write(h, (IntPtr)p); }
                return h;
            }
        }

        public static long FromArray(IEnumerable<long> arr)
        {
            if (arr is ICollection<long> coll)
            {
                int len = coll.Count;
                if (len == 0) return Native.buf_new_i64(0);

                var handles = new long[len];
                int i = 0;
                foreach (var v in arr) handles[i++] = v;

                long buf = Native.buf_new_i64(len);
                unsafe { fixed (long* p = handles) Native.buf_write(buf, (IntPtr)p); }
                return buf;
            }
            else
            {
                var tmp = new List<long>();
                foreach (var v in arr) tmp.Add(v);

                int len = tmp.Count;
                long h = Native.buf_new_i64(len);
                if (len == 0) return h;

                var handles = tmp.ToArray();
                unsafe { fixed (long* p = handles) Native.buf_write(h, (IntPtr)p); }
                return h;
            }
        }

        public static long FromArray(IEnumerable<float> arr)
        {
            if (arr is ICollection<float> coll)
            {
                int len = coll.Count;
                if (len == 0) return Native.buf_new_f32(0);

                var handles = new float[len];
                int i = 0;
                foreach (var v in arr) handles[i++] = v;

                long buf = Native.buf_new_f32(len);
                unsafe { fixed (float* p = handles) Native.buf_write(buf, (IntPtr)p); }
                return buf;
            }
            else
            {
                var tmp = new List<float>();
                foreach (var v in arr) tmp.Add(v);

                int len = tmp.Count;
                long h = Native.buf_new_f32(len);
                if (len == 0) return h;

                var handles = tmp.ToArray();
                unsafe { fixed (float* p = handles) Native.buf_write(h, (IntPtr)p); }
                return h;
            }
        }

        public static long FromArray(IEnumerable<double> arr)
        {
            if (arr is ICollection<double> coll)
            {
                int len = coll.Count;
                if (len == 0) return Native.buf_new_f64(0);

                var handles = new double[len];
                int i = 0;
                foreach (var v in arr) handles[i++] = v;

                long buf = Native.buf_new_f64(len);
                unsafe { fixed (double* p = handles) Native.buf_write(buf, (IntPtr)p); }
                return buf;
            }
            else
            {
                var tmp = new List<double>();
                foreach (var v in arr) tmp.Add(v);

                int len = tmp.Count;
                long h = Native.buf_new_f64(len);
                if (len == 0) return h;

                var handles = tmp.ToArray();
                unsafe { fixed (double* p = handles) Native.buf_write(h, (IntPtr)p); }
                return h;
            }
        }

        public static long FromArray(IEnumerable<Vec2> arr)
        {
            if (arr == null) throw new ArgumentNullException("arr");

            if (arr is ICollection<Vec2> coll)
            {
                int len = coll.Count;
                if (len == 0) return Native.buf_new_i64(0);

                var handles = new long[len];
                int i = 0;
                foreach (var v in arr) handles[i++] = v.Raw;

                long buf = Native.buf_new_i64(len);
                unsafe { fixed (long* p = handles) Native.buf_write(buf, (IntPtr)p); }
                return buf;
            }
            else
            {
                var tmp = new List<long>();
                foreach (var v in arr) tmp.Add(v.Raw);

                int len = tmp.Count;
                long h = Native.buf_new_i64(len);
                if (len == 0) return h;

                var handles = tmp.ToArray();
                unsafe { fixed (long* p = handles) Native.buf_write(h, (IntPtr)p); }
                return h;
            }
        }

        public static int[] ToI32Array(long buf)
        {
            int n = Native.buf_len(buf);
            var arr = new int[Math.Max(0, n)];
            if (n > 0) { unsafe { fixed (int* p = arr) Native.buf_read((IntPtr)p, buf); } }
            Native.buf_release(buf);
            return arr;
        }

        public static long[] ToI64Array(long buf)
        {
            int n = Native.buf_len(buf);
            var arr = new long[Math.Max(0, n)];
            if (n > 0) { unsafe { fixed (long* p = arr) Native.buf_read((IntPtr)p, buf); } }
            Native.buf_release(buf);
            return arr;
        }

        public static float[] ToF32Array(long buf)
        {
            int n = Native.buf_len(buf);
            var arr = new float[Math.Max(0, n)];
            if (n > 0) { unsafe { fixed (float* p = arr) Native.buf_read((IntPtr)p, buf); } }
            Native.buf_release(buf);
            return arr;
        }

        public static double[] ToF64Array(long buf)
        {
            int n = Native.buf_len(buf);
            var arr = new double[Math.Max(0, n)];
            if (n > 0) { unsafe { fixed (double* p = arr) Native.buf_read((IntPtr)p, buf); } }
            Native.buf_release(buf);
            return arr;
        }

        public static long FromArray(IEnumerable<string> items)
        {
            if (items == null) throw new ArgumentNullException("s");

            var handles = new List<long>();
            foreach (var s in items) handles.Add(FromString(s));
            long[] raw = handles.ToArray();

            long buf = FromArray(raw);
            return buf;
        }

        public static string[] ToStringArray(long buf)
        {
            long[] handles = ToI64Array(buf);
            var list = new string[handles.Length];
            for (int i = 0; i < handles.Length; i++) list[i] = ToString(handles[i]);
            return list;
        }

        public static Vec2[] ToVec2Array(long buf)
        {
            long[] handles = ToI64Array(buf);
            var list = new Vec2[handles.Length];
            for (int i = 0; i < handles.Length; i++) list[i] = Vec2.From(handles[i]);
            return list;
        }

        public static VertexColor[] ToVertexColorArray(long buf)
        {
            long[] handles = ToI64Array(buf);
            var list = new VertexColor[handles.Length];
            for (int i = 0; i < handles.Length; i++) list[i] = VertexColor.From(handles[i]);
            return list;
        }

        public static long FromArray(IEnumerable<VertexColor> items)
        {
            if (items == null) throw new ArgumentNullException("s");

            var handles = new List<long>();
            foreach (var s in items) handles.Add(s.Raw);
            long[] raw = handles.ToArray();

            long buf = FromArray(raw);
            return buf;
        }

        public static long FromArray(IEnumerable<ActionDef> items)
        {
            if (items == null) throw new ArgumentNullException("s");

            var handles = new List<long>();
            foreach (var s in items) handles.Add(s.Raw);
            long[] raw = handles.ToArray();

            long buf = FromArray(raw);
            return buf;
        }

        public static long FromArray(IEnumerable<Platformer.Behavior.Tree> items)
        {
            if (items == null) throw new ArgumentNullException("s");

            var handles = new List<long>();
            foreach (var s in items) handles.Add(s.Raw);
            long[] raw = handles.ToArray();

            long buf = FromArray(raw);
            return buf;
        }

        public static long FromArray(IEnumerable<Platformer.Decision.Tree> items)
        {
            if (items == null) throw new ArgumentNullException("s");

            var handles = new List<long>();
            foreach (var s in items) handles.Add(s.Raw);
            long[] raw = handles.ToArray();

            long buf = FromArray(raw);
            return buf;
        }

        private const int FUNC_FLAG = 0x02000000;
        private const int FUNC_MAX_INDEX = 0xFFFFFF;

        private static readonly List<Action?> _map = new List<Action?>();
        private static readonly Stack<int> _available = new Stack<int>();

        public static int PushFunction(Action func)
        {
            if (func == null) throw new ArgumentNullException(nameof(func));
            if (_map.Count >= FUNC_MAX_INDEX && _available.Count == 0)
            {
                throw new InvalidOperationException("too many functions!");
            }
            int index;
            if (_available.Count > 0)
            {
                index = _available.Pop();
                _map[index] = func;
            }
            else
            {
                _map.Add(func);
                index = _map.Count - 1;
            }
            return index | FUNC_FLAG;
        }

        internal static readonly Native.CallFunctionPointer CallFunction = (int funcId) =>
        {
            int index = funcId & 0x00FFFFFF;
            if (index < 0 || index >= _map.Count)
            {
                throw new IndexOutOfRangeException($"Invalid function id index: {index}");
            }
            var fn = _map[index];
            if (fn == null)
            {
                throw new InvalidOperationException($"Function id {index} was released or not set.");
            }
            fn?.Invoke();
        };

        private static readonly Action Dummy = () =>
        {
            throw new InvalidOperationException("the dummy function should not be called.");
        };

        internal static readonly Native.DerefFuncionPointer DerefFuncion = (int funcId) =>
        {
            int index = funcId & 0x00FFFFFF;
            if (index < 0 || index >= _map.Count)
            {
                throw new IndexOutOfRangeException($"Invalid function id index: {index}");
            }
            _map[index] = Dummy;
            _available.Push(index);
        };

        [StructLayout(LayoutKind.Explicit, Pack = 8)]
        internal struct LightValue
        {
            [FieldOffset(0)] internal Vec2 vec2; // 8 bytes
            [FieldOffset(0)] internal Size size; // 8 bytes
            [FieldOffset(0)] internal long value; // 8 bytes
        }
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    public struct Vec2 : IEquatable<Vec2>
    {
        public float X;
        public float Y;

        public Vec2(float x, float y) { this.X = x; this.Y = y; }

        public static Vec2 Zero => new Vec2(0f, 0f);
        public bool IsZero => X == 0f && Y == 0f;

        public static Vec2 From(long value)
        {
            var lv = new Bridge.LightValue { value = value };
            return lv.vec2;
        }
        public long Raw
        {
            get
            {
                var lv = new Bridge.LightValue { vec2 = this };
                return lv.value;
            }
        }

        public float Distance(in Vec2 other) => Native.vec2_distance(Raw, other.Raw);
        public float DistanceSquared(in Vec2 other) => Native.vec2_distance_squared(Raw, other.Raw);
        public float Length() => Native.vec2_length(Raw);
        public float Angle() => Native.vec2_angle(Raw);
        public Vec2 Normalize() => From(Native.vec2_normalize(Raw));
        public Vec2 Perp() => From(Native.vec2_perp(Raw));
        public float Dot(in Vec2 other) => Native.vec2_dot(Raw, other.Raw);
        public Vec2 Clamp(in Vec2 from, in Vec2 to) => From(Native.vec2_clamp(Raw, from.Raw, to.Raw));

        public static Vec2 operator +(Vec2 a, Vec2 b) => From(Native.vec2_add(a.Raw, b.Raw));
        public static Vec2 operator -(Vec2 a, Vec2 b) => From(Native.vec2_sub(a.Raw, b.Raw));
        public static Vec2 operator *(Vec2 a, Vec2 b) => From(Native.vec2_mul(a.Raw, b.Raw));
        public static Vec2 operator *(Vec2 a, float s) => From(Native.vec2_mul_float(a.Raw, s));
        public static Vec2 operator *(float s, Vec2 a) => From(Native.vec2_mul_float(a.Raw, s));
        public static Vec2 operator /(Vec2 a, float s) => From(Native.vec2_div(a.Raw, s));

        public bool Equals(Vec2 other) => X == other.X && Y == other.Y;
        public override bool Equals(object? obj) => obj is Vec2 v && Equals(v);
        public override int GetHashCode() => HashCode.Combine(X, Y);
        public override string ToString() => $"Vec2({X}, {Y})";
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    public struct Size : IEquatable<Size>
    {
        public float Width;
        public float Height;

        public Size(float width, float height) { this.Width = width; this.Height = height; }

        public static Size Zero => new Size(0f, 0f);
        public bool IsZero => Width == 0f && Height == 0f;

        internal static Size From(long value)
        {
            var lv = new Bridge.LightValue { value = value };
            return lv.size;
        }
        internal long Raw
        {
            get
            {
                var lv = new Bridge.LightValue { size = this };
                return lv.value;
            }
        }

        public bool Equals(Size other) => Width == other.Width && Height == other.Height;
        public override bool Equals(object? obj) => obj is Size s && Equals(s);
        public override int GetHashCode() => HashCode.Combine(Width, Height);
        public override string ToString() => $"Size({Width}, {Height})";
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct Color
    {
        public byte B;
        public byte G;
        public byte R;
        public byte A;

        public static readonly Color WHITE = new Color { R = 255, G = 255, B = 255, A = 255 };
        public static readonly Color BLACK = new Color { R = 0, G = 0, B = 0, A = 255 };
        public static readonly Color TRANSPARENT = new Color { R = 0, G = 0, B = 0, A = 0 };

        public Color(uint argb)
        {
            A = (byte)(argb >> 24);
            R = (byte)((argb & 0x00ff0000) >> 16);
            G = (byte)((argb & 0x0000ff00) >> 8);
            B = (byte)(argb & 0x000000ff);
        }

        public uint ToArgb() => ((uint)A << 24) | ((uint)R << 16) | ((uint)G << 8) | B;

        public Color3 ToColor3() => new Color3 { R = R, G = G, B = B };
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct Color3
    {
        public byte B;
        public byte G;
        public byte R;

        public static readonly Color3 WHITE = new Color3 { R = 255, G = 255, B = 255 };
        public static readonly Color3 BLACK = new Color3 { R = 0, G = 0, B = 0 };

        public Color3(uint rgb)
        {
            R = (byte)((rgb & 0x00ff0000) >> 16);
            G = (byte)((rgb & 0x0000ff00) >> 8);
            B = (byte)(rgb & 0x000000ff);
        }

        public uint ToRgb() => ((uint)R << 16) | ((uint)G << 8) | B;
    }

    public delegate Object CreateFunc(long raw);

    public abstract class Object
    {
        public static (int typeId, CreateFunc func) GetTypeInfo()
        {
            throw new NotImplementedException();
        }
        protected Object(long raw)
        {
            if (raw == 0) throw new ArgumentNullException(nameof(raw));
            Raw = raw;
        }

        ~Object() {
            Native.object_release(Raw);
        }

        public long Raw
        {
            get;
            private set;
        }

        public int TypeId => Native.object_get_type(Raw);
        public int Idx => Native.object_get_id(Raw);

        private static readonly Lazy<List<CreateFunc?>> _objectMap = new Lazy<List<CreateFunc?>>(() =>
        {
            var typeFuncs = new (int typeId, CreateFunc func)[]
            {
                Node.GetTypeInfo()
            };

            var map = new List<CreateFunc?>();
            foreach (var pair in typeFuncs)
            {
                int t = pair.typeId;
                if (map.Count < t + 1)
                {
                    map.AddRange(new CreateFunc?[t + 1 - map.Count]);
                }
                if (map[t] != null)
                {
                    throw new InvalidOperationException($"cpp object type id {t} duplicated!");
                }
                map[t] = pair.func;
            }
            return map;
        });

        internal static Object From(long raw)
        {
            int typeId = Native.object_get_type(raw);
            var map = _objectMap.Value;
            CreateFunc? createFunc = null;
            if ((uint)typeId < (uint)map.Count)
            {
                createFunc = map[typeId];
            }
            if (createFunc != null)
            {
                return createFunc(raw);
            }
            throw new InvalidOperationException($"failed to create cpp object from {raw}!");
        }

        internal static Object? FromOpt(long raw)
        {
            return raw == 0 ? null : From(raw);
        }
    }

    public sealed class Value : SafeHandleZeroOrMinusOneIsInvalid
    {
        private Value(IntPtr raw) : base(ownsHandle: true)
        {
            if (raw == 0) throw new ArgumentNullException(nameof(raw));
            SetHandle(raw);
        }

        protected override bool ReleaseHandle()
        {
            Native.value_release(handle.ToInt64());
            SetHandleAsInvalid();
            return true;
        }

        public long Raw
        {
            get {
                if (IsInvalid) throw new InvalidOperationException();
                return handle.ToInt64();
            }
        }

        public Value(long v): this((IntPtr)Native.value_create_i64(v)) { }
        public Value(int v): this((IntPtr)Native.value_create_i64(v)) { }
        public Value(double v): this((IntPtr)Native.value_create_f64(v)) { }
        public Value(float v): this((IntPtr)Native.value_create_f64(v)) { }
        public Value(bool v): this((IntPtr)Native.value_create_bool(v ? 1 : 0)) { }
        public Value(string s): this((IntPtr)Native.value_create_str(Bridge.FromString(s))) { }
        public Value(Object o): this((IntPtr)Native.value_create_object(o.Raw)) { }
        public Value(in Vec2 v): this(Native.value_create_vec2(v.Raw)) { }
        public Value(in Size s): this(Native.value_create_size(s.Raw)) { }

        public bool IsI64 => Native.value_is_i64(Raw) != 0;
        public bool IsF64 => Native.value_is_f64(Raw) != 0;
        public bool IsStr => Native.value_is_str(Raw) != 0;
        public bool IsBool => Native.value_is_bool(Raw) != 0;
        public bool IsObject => Native.value_is_object(Raw) != 0;
        public bool IsVec2 => Native.value_is_vec2(Raw) != 0;
        public bool IsSize => Native.value_is_size(Raw) != 0;

        public int I32 => (int)Native.value_into_i64(Raw);
        public long I64 => Native.value_into_i64(Raw);
        public float F32 => (float)Native.value_into_f64(Raw);
        public double F64 => Native.value_into_f64(Raw);
        public bool Bool => Native.value_into_bool(Raw) != 0;
        public string String => Bridge.ToString(Native.value_into_str(Raw));
        public Object Object => Object.From(Native.value_into_object(Raw));
        public Vec2 Vec2 => Vec2.From(Native.value_into_vec2(Raw));
        public Size Size => Size.From(Native.value_into_size(Raw));
    }

    public sealed class CallStack : SafeHandleZeroOrMinusOneIsInvalid
    {
        public CallStack() : base(ownsHandle: true)
        {
            long raw = Native.call_stack_create();
            if (raw == 0) throw new InvalidOperationException("call_stack_create failed");
            SetHandle((IntPtr)raw);
        }

        protected override bool ReleaseHandle()
        {
            Native.call_stack_release(handle.ToInt64());
            SetHandleAsInvalid();
            return true;
        }

        public long Raw
        {
            get
            {
                if (IsInvalid) throw new InvalidOperationException();
                return handle.ToInt64();
            }
        }

        public void Push(int v) => Native.call_stack_push_i64(Raw, v);
        public void Push(long v) => Native.call_stack_push_i64(Raw, v);
        public void Push(float v) => Native.call_stack_push_f64(Raw, v);
        public void Push(double v) => Native.call_stack_push_f64(Raw, v);
        public void Push(bool v) => Native.call_stack_push_bool(Raw, v ? 1 : 0);
        public void Push(string s) => Native.call_stack_push_str(Raw, Bridge.FromString(s));
        public void Push(Object o) => Native.call_stack_push_object(Raw, o.Raw);
        public void Push(in Vec2 v) => Native.call_stack_push_vec2(Raw, v.Raw);
        public void Push(in Size s) => Native.call_stack_push_size(Raw, s.Raw);

        public int? PopOptI32() => Native.call_stack_front_i64(Raw) != 0 ? (int?)Native.call_stack_pop_i64(Raw) : null;
        public long? PopOptI64() => Native.call_stack_front_i64(Raw) != 0 ? (long?)Native.call_stack_pop_i64(Raw) : null;
        public float? PopOptF32() => Native.call_stack_front_f64(Raw) != 0 ? (float?)Native.call_stack_pop_f64(Raw) : null;
        public double? PopOptF64() => Native.call_stack_front_f64(Raw) != 0 ? (double?)Native.call_stack_pop_f64(Raw) : null;
        public bool? PopOptBool() => Native.call_stack_front_bool(Raw) != 0 ? (Native.call_stack_pop_bool(Raw) != 0) : null;
        public string? PopOptString()
        {
            if (Native.call_stack_front_str(Raw) == 0) return null;
            long sh = Native.call_stack_pop_str(Raw);
            return Bridge.ToString(sh);
        }
        public Vec2? PopOptVec2()
        {
            if (Native.call_stack_front_vec2(Raw) == 0) return null;
            long bits = Native.call_stack_pop_vec2(Raw);
            return Vec2.From(bits);
        }
        public Size? PopOptSize()
        {
            if (Native.call_stack_front_size(Raw) == 0) return null;
            long bits = Native.call_stack_pop_size(Raw);
            return Size.From(bits);
        }
        public Object? PopOptObject()
        {
            if (Native.call_stack_front_object(Raw) == 0) return null;
            long oh = Native.call_stack_pop_object(Raw);
            return Object.From(oh);
        }

        public int PopI32()
        {
            if (Native.call_stack_front_i64(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop i32 from stack");
            }
            return (int)Native.call_stack_pop_i64(Raw);
        }
        public long PopI64()
        {
            if (Native.call_stack_front_i64(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop i64 from stack");
            }
            return Native.call_stack_pop_i64(Raw);
        }
        public float PopF32()
        {
            if (Native.call_stack_front_f64(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop f32 from stack");
            }
            return (float)Native.call_stack_pop_f64(Raw);
        }
        public double PopF64()
        {
            if (Native.call_stack_front_f64(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop f64 from stack");
            }
            return Native.call_stack_pop_f64(Raw);
        }
        public bool PopBool()
        {
            if (Native.call_stack_front_bool(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop f64 from stack");
            }
            return Native.call_stack_pop_bool(Raw) != 0;
        }
        public string PopString()
        {
            if (Native.call_stack_front_str(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop string from stack");
            }
            long sh = Native.call_stack_pop_str(Raw);
            return Bridge.ToString(sh);
        }
        public Vec2 PopVec2()
        {
            if (Native.call_stack_front_vec2(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop Vec2 from stack");
            }
            long bits = Native.call_stack_pop_vec2(Raw);
            return Vec2.From(bits);
        }
        public Size PopSize()
        {
            if (Native.call_stack_front_size(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop Size from stack");
            }
            long bits = Native.call_stack_pop_size(Raw);
            return Size.From(bits);
        }
        public Object PopObject()
        {
            if (Native.call_stack_front_object(Raw) == 0)
            {
                throw new ArithmeticException("failed to pop Object from stack");
            }
            long oh = Native.call_stack_pop_object(Raw);
            return Object.From(oh);
        }
        public bool Pop() => Native.call_stack_pop(Raw) != 0;

        public static CallStack From(params object[] xs)
        {
            var cs = new CallStack();
            foreach (var x in xs)
            {
                switch (x)
                {
                    case int i: cs.Push(i); break;
                    case long l: cs.Push(l); break;
                    case float f: cs.Push(f); break;
                    case double d: cs.Push(d); break;
                    case bool b: cs.Push(b); break;
                    case string s: cs.Push(s); break;
                    case Object o: cs.Push(o); break;
                    case Vec2 v2: cs.Push(v2); break;
                    case Size sz: cs.Push(sz); break;
                    default: throw new NotSupportedException($"Unsupported arg type: {x?.GetType().FullName ?? "null"}");
                }
            }
            return cs;
        }
    }

    public static class Event
    {
        public static void Emit(string name, params object[] args)
        {
            using (var stack = CallStack.From(args))
            {
                Native.dora_emit(Bridge.FromString(name), stack.Raw);
            }
        }
    }

    public static class Log
    {
        public static void Print(string message)
        {
            Native.dora_print(Bridge.FromString(message));
        }
        public static void Warn(string message)
        {
            Native.dora_print_warning(Bridge.FromString(message));
        }
        public static void Error(string message)
        {
            Native.dora_print_error(Bridge.FromString(message));
        }
    }

    /* BlendFunc */

    public enum BFunc
    {
        Zero = 0x0000000000001000,
        One = 0x0000000000002000,
        SrcColor = 0x0000000000003000,
        InvSrcColor = 0x0000000000004000,
        SrcAlpha = 0x0000000000005000,
        InvSrcAlpha = 0x0000000000006000,
        DstAlpha = 0x0000000000007000,
        InvDstAlpha = 0x0000000000008000,
        DstColor = 0x0000000000009000,
        InvDstColor = 0x000000000000a000
    }

    public class BlendFunc
    {
        private long value = 0;
        internal long Raw => value;
        internal BlendFunc From(long value)
        {
            return new BlendFunc(value);
        }
        private BlendFunc(long raw)
        {
            value = raw;
        }
        public BlendFunc(BFunc src, BFunc dst)
        {
            value = (long)src << 8 | (long)dst << 4;
        }
        public BlendFunc(BFunc src_rgb, BFunc dst_rgb, BFunc src_alpha, BFunc dst_alpha)
        {
            value = ((long)src_rgb << 8 | (long)dst_rgb << 4 | (long)src_alpha << 4 | (long)dst_alpha << 4) << 8;
        }
    }

    public enum BodyType
    {
        Dynamic = 0,
        Static = 1,
        Kinematic = 2,
    }

    public enum EaseType
    {
        Linear = 0,
        InQuad = 1,
        OutQuad = 2,
        InOutQuad = 3,
        InCubic = 4,
        OutCubic = 5,
        InOutCubic = 6,
        InQuart = 7,
        OutQuart = 8,
        InOutQuart = 9,
        InQuint = 10,
        OutQuint = 11,
        InOutQuint = 12,
        InSine = 13,
        OutSine = 14,
        InOutSine = 15,
        InExpo = 16,
        OutExpo = 17,
        InOutExpo = 18,
        InCirc = 19,
        OutCirc = 20,
        InOutCirc = 21,
        InElastic = 22,
        OutElastic = 23,
        InOutElastic = 24,
        InBack = 25,
        OutBack = 26,
        InOutBack = 27,
        InBounce = 28,
        OutBounce = 29,
        InOutBounce = 30,
        OutInQuad = 31,
        OutInCubic = 32,
        OutInQuart = 33,
        OutInQuint = 34,
        OutInSine = 35,
        OutInExpo = 36,
        OutInCirc = 37,
        OutInElastic = 38,
        OutInBack = 39,
        OutInBounce = 40,
    }

    public enum Property
    {
        X = 0,
        Y = 1,
        Z = 2,
        Angle = 3,
        AngleX = 4,
        AngleY = 5,
        ScaleX = 6,
        ScaleY = 7,
        SkewX = 8,
        SkewY = 9,
        Width = 10,
        Height = 11,
        AnchorX = 12,
        AnchorY = 13,
        Opacity = 14,
    }

    public enum TextureWrap
    {
        None = 0,
        Mirror = 1,
        Clamp = 2,
        Border = 3,
    }
    public enum TextureFilter
    {
        None = 0,
        Point = 1,
        Anisotropic = 2,
    }

    public enum TextAlign
    {
        Left = 0,
        Center = 1,
        Right = 2,
    }

    public enum AttenuationModel
    {
        NoAttenuation = 0,
        InverseDistance = 1,
        LinearDistance = 2,
        ExponentialDistance = 3,
    }

    public enum EntityEvent
    {
        Add = 1,
        Change = 2,
        AddOrChange = 3,
        Remove = 4,
    }

    namespace Platformer
    {
        public enum Relation
        {
            Unknown = 0,
            Friend = 1 << 0,
            Neutral = 1 << 1,
            Enemy = 1 << 2,
            Any = (Friend | Neutral | Enemy),
        }
    }

    public static partial class App
    {
        [DllImport("kernel32.dll", SetLastError = false)]
        static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);

        public static void Run(Action main)
        {
            GC.KeepAlive(Bridge.CallFunction);
            GC.KeepAlive(Bridge.DerefFuncion);
            Native.dora_register_call_function(Bridge.CallFunction);
            Native.dora_register_deref_function(Bridge.DerefFuncion);
            Native.MainFunc mainFunc = () =>
            {
                main();
                return 1;
            };
            GC.KeepAlive(mainFunc);
            Native.dora_run(mainFunc);
            TerminateProcess(Process.GetCurrentProcess().Handle, 0);
        }
    }
} // namespace Dora