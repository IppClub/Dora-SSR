using Microsoft.Win32.SafeHandles;
using System.Collections;
using System.Diagnostics;
using System.Runtime.InteropServices;
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
        internal static extern long director_get_post_scheduler();
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

        private static readonly List<System.Action?> _map = new List<System.Action?>();
        private static readonly Stack<int> _available = new Stack<int>();

        public static int PushFunction(System.Action func)
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

        private static readonly System.Action Dummy = () =>
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

        public static readonly Vec2 Zero = new(0f, 0f);
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

        public static readonly Size Zero = new(0f, 0f);
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

        public static readonly Color White = new Color { R = 255, G = 255, B = 255, A = 255 };
        public static readonly Color Black = new Color { R = 0, G = 0, B = 0, A = 255 };
        public static readonly Color Transparent = new Color { R = 0, G = 0, B = 0, A = 0 };

        public Color(uint argb)
        {
            A = (byte)(argb >> 24);
            R = (byte)((argb & 0x00ff0000) >> 16);
            G = (byte)((argb & 0x0000ff00) >> 8);
            B = (byte)(argb & 0x000000ff);
        }

        public uint ToARGB() => ((uint)A << 24) | ((uint)R << 16) | ((uint)G << 8) | B;

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

        public uint ToRGB() => ((uint)R << 16) | ((uint)G << 8) | B;
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

        ~Object()
        {
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
                Array.GetTypeInfo(),
                Dictionary.GetTypeInfo(),
                Entity.GetTypeInfo(),
                Group.GetTypeInfo(),
                Observer.GetTypeInfo(),
                Scheduler.GetTypeInfo(),
                Camera.GetTypeInfo(),
                Camera2D.GetTypeInfo(),
                CameraOtho.GetTypeInfo(),
                Pass.GetTypeInfo(),
                Effect.GetTypeInfo(),
                SpriteEffect.GetTypeInfo(),
                Grabber.GetTypeInfo(),
                Action.GetTypeInfo(),
                Node.GetTypeInfo(),
                Texture2D.GetTypeInfo(),
                Sprite.GetTypeInfo(),
                Grid.GetTypeInfo(),
                Touch.GetTypeInfo(),
                Label.GetTypeInfo(),
                RenderTarget.GetTypeInfo(),
                ClipNode.GetTypeInfo(),
                DrawNode.GetTypeInfo(),
                Line.GetTypeInfo(),
                Particle.GetTypeInfo(),
                Playable.GetTypeInfo(),
                Model.GetTypeInfo(),
                Spine.GetTypeInfo(),
                DragonBone.GetTypeInfo(),
                AlignNode.GetTypeInfo(),
                EffekNode.GetTypeInfo(),
                TileNode.GetTypeInfo(),
                PhysicsWorld.GetTypeInfo(),
                FixtureDef.GetTypeInfo(),
                BodyDef.GetTypeInfo(),
                Sensor.GetTypeInfo(),
                Body.GetTypeInfo(),
                JointDef.GetTypeInfo(),
                Joint.GetTypeInfo(),
                MotorJoint.GetTypeInfo(),
                MoveJoint.GetTypeInfo(),
                SVG.GetTypeInfo(),
                AudioBus.GetTypeInfo(),
                AudioSource.GetTypeInfo(),
                QLearner.GetTypeInfo(),
                Platformer.ActionUpdate.GetTypeInfo(),
                Platformer.Face.GetTypeInfo(),
                Platformer.BulletDef.GetTypeInfo(),
                Platformer.Bullet.GetTypeInfo(),
                Platformer.Visual.GetTypeInfo(),
                Platformer.Behavior.Tree.GetTypeInfo(),
                Platformer.Decision.Tree.GetTypeInfo(),
                Platformer.Unit.GetTypeInfo(),
                Platformer.PlatformCamera.GetTypeInfo(),
                Platformer.PlatformWorld.GetTypeInfo(),
                Buffer.GetTypeInfo(),
                VGNode.GetTypeInfo(),
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

    public sealed class Value
    {
        private Value(IntPtr raw)
        {
            if (raw == 0) throw new ArgumentNullException(nameof(raw));
            Raw = raw;
        }

        ~Value()
        {
            Native.value_release(Raw);
        }

        public static Value From(long raw)
        {
            return new Value(raw);
        }

        public long Raw { get; private set; }

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
            if (raw == 0) throw new InvalidOperationException("failed to create CallStack");
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

    public enum KeyName
    {
        Return,
        Escape,
        BackSpace,
        Tab,
        Space,
        Exclamation,
        DoubleQuote,
        Hash,
        Percent,
        Dollar,
        Ampersand,
        SingleQuote,
        LeftParen,
        RightParen,
        Asterisk,
        Plus,
        Comma,
        Minus,
        Dot,
        Slash,
        Num1,
        Num2,
        Num3,
        Num4,
        Num5,
        Num6,
        Num7,
        Num8,
        Num9,
        Num0,
        Colon,
        Semicolon,
        LessThan,
        Equal,
        GreaterThan,
        Question,
        At,
        LeftBracket,
        Backslash,
        RightBracket,
        Caret,
        Underscore,
        Backtick,
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z,
        Delete,
        CapsLock,
        F1,
        F2,
        F3,
        F4,
        F5,
        F6,
        F7,
        F8,
        F9,
        F10,
        F11,
        F12,
        PrintScreen,
        ScrollLock,
        Pause,
        Insert,
        Home,
        PageUp,
        End,
        PageDown,
        Right,
        Left,
        Down,
        Up,
        Application,
        LCtrl,
        LShift,
        LAlt,
        LGui,
        RCtrl,
        RShift,
        RAlt,
        RGui,
    }

    public static class KeyNameExtension
    {
        public static string ToValue(this KeyName keyName) => keyName switch
        {
            KeyName.Return => "Return",
            KeyName.Escape => "Escape",
            KeyName.BackSpace => "BackSpace",
            KeyName.Tab => "Tab",
            KeyName.Space => "Space",
            KeyName.Exclamation => "!",
            KeyName.DoubleQuote => "\"",
            KeyName.Hash => "#",
            KeyName.Percent => "%",
            KeyName.Dollar => "$",
            KeyName.Ampersand => "&",
            KeyName.SingleQuote => "'",
            KeyName.LeftParen => "(",
            KeyName.RightParen => ")",
            KeyName.Asterisk => "*",
            KeyName.Plus => "+",
            KeyName.Comma => ",",
            KeyName.Minus => "-",
            KeyName.Dot => ".",
            KeyName.Slash => "/",
            KeyName.Num1 => "1",
            KeyName.Num2 => "2",
            KeyName.Num3 => "3",
            KeyName.Num4 => "4",
            KeyName.Num5 => "5",
            KeyName.Num6 => "6",
            KeyName.Num7 => "7",
            KeyName.Num8 => "8",
            KeyName.Num9 => "9",
            KeyName.Num0 => "0",
            KeyName.Colon => ":",
            KeyName.Semicolon => ";",
            KeyName.LessThan => "<",
            KeyName.Equal => "=",
            KeyName.GreaterThan => ">",
            KeyName.Question => "?",
            KeyName.At => "@",
            KeyName.LeftBracket => "[",
            KeyName.Backslash => "\\",
            KeyName.RightBracket => "]",
            KeyName.Caret => "^",
            KeyName.Underscore => "_",
            KeyName.Backtick => "`",
            KeyName.A => "A",
            KeyName.B => "B",
            KeyName.C => "C",
            KeyName.D => "D",
            KeyName.E => "E",
            KeyName.F => "F",
            KeyName.G => "G",
            KeyName.H => "H",
            KeyName.I => "I",
            KeyName.J => "J",
            KeyName.K => "K",
            KeyName.L => "L",
            KeyName.M => "M",
            KeyName.N => "N",
            KeyName.O => "O",
            KeyName.P => "P",
            KeyName.Q => "Q",
            KeyName.R => "R",
            KeyName.S => "S",
            KeyName.T => "T",
            KeyName.U => "U",
            KeyName.V => "V",
            KeyName.W => "W",
            KeyName.X => "X",
            KeyName.Y => "Y",
            KeyName.Z => "Z",
            KeyName.Delete => "Delete",
            KeyName.CapsLock => "CapsLock",
            KeyName.F1 => "F1",
            KeyName.F2 => "F2",
            KeyName.F3 => "F3",
            KeyName.F4 => "F4",
            KeyName.F5 => "F5",
            KeyName.F6 => "F6",
            KeyName.F7 => "F7",
            KeyName.F8 => "F8",
            KeyName.F9 => "F9",
            KeyName.F10 => "F10",
            KeyName.F11 => "F11",
            KeyName.F12 => "F12",
            KeyName.PrintScreen => "PrintScreen",
            KeyName.ScrollLock => "ScrollLock",
            KeyName.Pause => "Pause",
            KeyName.Insert => "Insert",
            KeyName.Home => "Home",
            KeyName.PageUp => "PageUp",
            KeyName.End => "End",
            KeyName.PageDown => "PageDown",
            KeyName.Right => "Right",
            KeyName.Left => "Left",
            KeyName.Down => "Down",
            KeyName.Up => "Up",
            KeyName.Application => "Application",
            KeyName.LCtrl => "LCtrl",
            KeyName.LShift => "LShift",
            KeyName.LAlt => "LAlt",
            KeyName.LGui => "LGui",
            KeyName.RCtrl => "RCtrl",
            KeyName.RShift => "RShift",
            KeyName.RAlt => "RAlt",
            KeyName.RGui => "RGui",
            _ => throw new ArgumentOutOfRangeException(nameof(keyName))
        };
        public static KeyName FromValue(this string keyName) => keyName switch
        {
            "Return" => KeyName.Return,
            "Escape" => KeyName.Escape,
            "BackSpace" => KeyName.BackSpace,
            "Tab" => KeyName.Tab,
            "Space" => KeyName.Space,
            "!" => KeyName.Exclamation,
            "\"" => KeyName.DoubleQuote,
            "#" => KeyName.Hash,
            "%" => KeyName.Percent,
            "$" => KeyName.Dollar,
            "&" => KeyName.Ampersand,
            "'" => KeyName.SingleQuote,
            "(" => KeyName.LeftParen,
            ")" => KeyName.RightParen,
            "*" => KeyName.Asterisk,
            "+" => KeyName.Plus,
            "," => KeyName.Comma,
            "-" => KeyName.Minus,
            "." => KeyName.Dot,
            "/" => KeyName.Slash,
            "1" => KeyName.Num1,
            "2" => KeyName.Num2,
            "3" => KeyName.Num3,
            "4" => KeyName.Num4,
            "5" => KeyName.Num5,
            "6" => KeyName.Num6,
            "7" => KeyName.Num7,
            "8" => KeyName.Num8,
            "9" => KeyName.Num9,
            "0" => KeyName.Num0,
            ":" => KeyName.Colon,
            ";" => KeyName.Semicolon,
            "<" => KeyName.LessThan,
            "=" => KeyName.Equal,
            ">" => KeyName.GreaterThan,
            "?" => KeyName.Question,
            "@" => KeyName.At,
            "[" => KeyName.LeftBracket,
            "\\" => KeyName.Backslash,
            "]" => KeyName.RightBracket,
            "^" => KeyName.Caret,
            "_" => KeyName.Underscore,
            "`" => KeyName.Backtick,
            "A" => KeyName.A,
            "B" => KeyName.B,
            "C" => KeyName.C,
            "D" => KeyName.D,
            "E" => KeyName.E,
            "F" => KeyName.F,
            "G" => KeyName.G,
            "H" => KeyName.H,
            "I" => KeyName.I,
            "J" => KeyName.J,
            "K" => KeyName.K,
            "L" => KeyName.L,
            "M" => KeyName.M,
            "N" => KeyName.N,
            "O" => KeyName.O,
            "P" => KeyName.P,
            "Q" => KeyName.Q,
            "R" => KeyName.R,
            "S" => KeyName.S,
            "T" => KeyName.T,
            "U" => KeyName.U,
            "V" => KeyName.V,
            "W" => KeyName.W,
            "X" => KeyName.X,
            "Y" => KeyName.Y,
            "Z" => KeyName.Z,
            "Delete" => KeyName.Delete,
            "CapsLock" => KeyName.CapsLock,
            "F1" => KeyName.F1,
            "F2" => KeyName.F2,
            "F3" => KeyName.F3,
            "F4" => KeyName.F4,
            "F5" => KeyName.F5,
            "F6" => KeyName.F6,
            "F7" => KeyName.F7,
            "F8" => KeyName.F8,
            "F9" => KeyName.F9,
            "F10" => KeyName.F10,
            "F11" => KeyName.F11,
            "F12" => KeyName.F12,
            "PrintScreen" => KeyName.PrintScreen,
            "ScrollLock" => KeyName.ScrollLock,
            "Pause" => KeyName.Pause,
            "Insert" => KeyName.Insert,
            "Home" => KeyName.Home,
            "PageUp" => KeyName.PageUp,
            "End" => KeyName.End,
            "PageDown" => KeyName.PageDown,
            "Right" => KeyName.Right,
            "Left" => KeyName.Left,
            "Down" => KeyName.Down,
            "Up" => KeyName.Up,
            "Application" => KeyName.Application,
            "LCtrl" => KeyName.LCtrl,
            "LShift" => KeyName.LShift,
            "LAlt" => KeyName.LAlt,
            "LGui" => KeyName.LGui,
            "RCtrl" => KeyName.RCtrl,
            "RShift" => KeyName.RShift,
            "RAlt" => KeyName.RAlt,
            "RGui" => KeyName.RGui,
            _ => throw new ArgumentOutOfRangeException(nameof(keyName))
        };
    }

    public static partial class Keyboard
    {
        public static bool IsKeyDown(KeyName keyName)
        {
            return _IsKeyDown(KeyNameExtension.ToValue(keyName));
        }
        public static bool IsKeyUp(KeyName keyName)
        {
            return _IsKeyUp(KeyNameExtension.ToValue(keyName));
        }
        public static bool IsKeyPressed(KeyName keyName)
        {
            return _IsKeyPressed(KeyNameExtension.ToValue(keyName));
        }
    }

    public enum AxisName
    {
        LeftX,
        LeftY,
        RightX,
        RightY,
        LeftTrigger,
        RightTrigger,
    }

    public static class AxisNameExtension
    {
        public static string ToValue(this AxisName axisName) => axisName switch
        {
            AxisName.LeftX => "leftx",
            AxisName.LeftY => "lefty",
            AxisName.RightX => "rightx",
            AxisName.RightY => "righty",
            AxisName.LeftTrigger => "lefttrigger",
            AxisName.RightTrigger => "righttrigger",
            _ => throw new ArgumentOutOfRangeException(nameof(axisName))
        };
        public static AxisName FromValue(this string value) => value switch
        {
            "leftx" => AxisName.LeftX,
            "lefty" => AxisName.LeftY,
            "rightx" => AxisName.RightX,
            "righty" => AxisName.RightY,
            "lefttrigger" => AxisName.LeftTrigger,
            "righttrigger" => AxisName.RightTrigger,
            _ => throw new ArgumentOutOfRangeException(nameof(value))
        };
    }

    public enum ButtonName
    {
        A,
        B,
        Back,
        DPDown,
        DPLeft,
        DPRight,
        DPUp,
        LeftShoulder,
        LeftStick,
        RightShoulder,
        RightStick,
        Start,
        X,
        Y,
    }

    public static class ButtonNameExtension
    {
        public static string ToValue(this ButtonName buttonName) => buttonName switch
        {
            ButtonName.A => "a",
            ButtonName.B => "b",
            ButtonName.Back => "back",
            ButtonName.DPDown => "dpdown",
            ButtonName.DPLeft => "dpleft",
            ButtonName.DPRight => "dpright",
            ButtonName.DPUp => "dpup",
            ButtonName.LeftShoulder => "leftshoulder",
            ButtonName.LeftStick => "leftstick",
            ButtonName.RightShoulder => "rightshoulder",
            ButtonName.RightStick => "rightstick",
            ButtonName.Start => "start",
            ButtonName.X => "x",
            ButtonName.Y => "y",
            _ => throw new ArgumentOutOfRangeException(nameof(buttonName))
        };
        public static ButtonName FromValue(this string value) => value switch
        {
            "a" => ButtonName.A,
            "b" => ButtonName.B,
            "back" => ButtonName.Back,
            "dpdown" => ButtonName.DPDown,
            "dpleft" => ButtonName.DPLeft,
            "dpright" => ButtonName.DPRight,
            "dpup" => ButtonName.DPUp,
            "leftshoulder" => ButtonName.LeftShoulder,
            "leftstick" => ButtonName.LeftStick,
            "rightshoulder" => ButtonName.RightShoulder,
            "rightstick" => ButtonName.RightStick,
            "start" => ButtonName.Start,
            "x" => ButtonName.X,
            "y" => ButtonName.Y,
            _ => throw new ArgumentOutOfRangeException(nameof(value))
        };
    }

    public static partial class Controller
    {
        public static bool IsButtonDown(int controllerId, ButtonName button)
        {
            return _IsButtonDown(controllerId, ButtonNameExtension.ToValue(button));
        }
        public static bool IsButtonUp(int controllerId, ButtonName button)
        {
            return _IsButtonUp(controllerId, ButtonNameExtension.ToValue(button));
        }
        public static bool IsButtonPressed(int controllerId, ButtonName button)
        {
            return _IsButtonPressed(controllerId, ButtonNameExtension.ToValue(button));
        }
        public static float GetAxis(int controllerId, AxisName axisName)
        {
            return _GetAxis(controllerId, AxisNameExtension.ToValue(axisName));
        }
    }

    public partial class Node
    {

        public delegate void ActionEndHandler(Action action, Node node);
        public void OnActionEnd(ActionEndHandler func)
        {
            this.Slot("ActionEnd", (stack) =>
            {
                var action = (Action)stack.PopObject();
                var node = (Node)stack.PopObject();
                func(action, node);
            });
        }

        public delegate void TapFilterHandler(Touch touch);
        public void OnTapFilter(TapFilterHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("TapFilter", (stack) =>
            {
                var touch = (Touch)stack.PopObject();
                func(touch);
            });
        }

        public delegate void TapBeganHandler(Touch touch);
        public void OnTapBegan(TapBeganHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("TapBegan", (stack) =>
            {
                var touch = (Touch)stack.PopObject();
                func(touch);
            });
        }

        public delegate void TapEndedHandler(Touch touch);
        public void OnTapEnded(TapEndedHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("TapEnded", (stack) =>
            {
                var touch = (Touch)stack.PopObject();
                func(touch);
            });
        }

        public delegate void TappedHandler(Touch touch);
        public void OnTapped(TappedHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("Tapped", (stack) =>
            {
                var touch = (Touch)stack.PopObject();
                func(touch);
            });
        }

        public delegate void TapMovedHandler(Touch touch);
        public void OnTapMoved(TapMovedHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("TapMoved", (stack) =>
            {
                var touch = (Touch)stack.PopObject();
                func(touch);
            });
        }

        public delegate void MouseWheelHandler(Vec2 delta);
        public void OnMouseWheel(MouseWheelHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("MouseWheel", (stack) =>
            {
                var delta = stack.PopVec2();
                func(delta);
            });
        }

        public delegate void GestureHandler(Vec2 center, int numFingers, float deltaDist, float deltaAngle);
        public void OnGesture(GestureHandler func)
        {
            this.IsTouchEnabled = true;
            this.Slot("Gesture", (stack) =>
            {
                var center = stack.PopVec2();
                var numFingers = stack.PopI32();
                var deltaDist = stack.PopF32();
                var deltaAngle = stack.PopF32();
                func(center, numFingers, deltaDist, deltaAngle);
            });
        }

        public delegate void EnterHandler();
        public void OnEnter(EnterHandler func)
        {
            this.Slot("Enter", (stack) =>
            {
                func();
            });
        }

        public delegate void ExitHandler();
        public void OnExit(ExitHandler func)
        {
            this.Slot("Exit", (stack) =>
            {
                func();
            });
        }

        public delegate void CleanupHandler();
        public void OnCleanup(CleanupHandler func)
        {
            this.Slot("Cleanup", (stack) =>
            {
                func();
            });
        }

        public delegate void KeyDownHandler(KeyName key);
        public void OnKeyDown(KeyDownHandler func)
        {
            this.IsKeyboardEnabled = true;
            this.Slot("KeyDown", (stack) =>
            {
                var key = KeyNameExtension.FromValue(stack.PopString());
                func(key);
            });
        }

        public delegate void KeyUpHandler(KeyName key);
        public void OnKeyUp(KeyUpHandler func)
        {
            this.IsKeyboardEnabled = true;
            this.Slot("KeyUp", (stack) =>
            {
                var key = KeyNameExtension.FromValue(stack.PopString());
                func(key);
            });
        }

        public delegate void KeyPressedHandler(KeyName key);
        public void OnKeyPressed(KeyPressedHandler func)
        {
            this.IsKeyboardEnabled = true;
            this.Slot("KeyPressed", (stack) =>
            {
                var key = KeyNameExtension.FromValue(stack.PopString());
                func(key);
            });
        }

        public delegate void AttachIMEHandler();
        public void OnAttachIME(AttachIMEHandler func)
        {
            this.Slot("AttachIME", (stack) =>
            {
                func();
            });
        }

        public delegate void DetachIMEHandler();
        public void OnDetachIME(DetachIMEHandler func)
        {
            this.Slot("DetachIME", (stack) =>
            {
                func();
            });
        }

        public delegate void TextInputHandler(string text);
        public void OnTextInput(TextInputHandler func)
        {
            this.Slot("TextInput", (stack) =>
            {
                var text = stack.PopString();
                func(text);
            });
        }

        public delegate void TextEditingHandler(string text, int startPos);
        public void OnTextEditing(TextEditingHandler func)
        {
            this.Slot("TextEditing", (stack) =>
            {
                var text = stack.PopString();
                var startPos = stack.PopI32();
                func(text, startPos);
            });
        }

        public delegate void ButtonDownHandler(int controllerId, ButtonName button);
        public void OnButtonDown(ButtonDownHandler func)
        {
            this.IsControllerEnabled = true;
            this.Slot("ButtonDown", (stack) =>
            {
                var controllerId = stack.PopI32();
                var button = ButtonNameExtension.FromValue(stack.PopString());
                func(controllerId, button);
            });
        }

        public delegate void ButtonUpHandler(int controllerId, ButtonName button);
        public void OnButtonUp(ButtonUpHandler func)
        {
            this.IsControllerEnabled = true;
            this.Slot("ButtonUp", (stack) =>
            {
                var controllerId = stack.PopI32();
                var button = ButtonNameExtension.FromValue(stack.PopString());
                func(controllerId, button);
            });
        }

        public delegate void ButtonPressedHandler(int controllerId, ButtonName button);
        public void OnButtonPressed(ButtonPressedHandler func)
        {
            this.IsControllerEnabled = true;
            this.Slot("ButtonPressed", (stack) =>
            {
                var controllerId = stack.PopI32();
                var button = ButtonNameExtension.FromValue(stack.PopString());
                func(controllerId, button);
            });
        }

        public delegate void AxisHandler(int controllerId, AxisName axis, float value);
        public void OnAxis(AxisHandler func)
        {
            this.IsControllerEnabled = true;
            this.Slot("Axis", (stack) =>
            {
                var controllerId = stack.PopI32();
                var axis = AxisNameExtension.FromValue(stack.PopString());
                var value = stack.PopF32();
                func(controllerId, axis, value);
            });
        }

        public delegate void AppEventHandler(string eventType);
        public void OnAppEvent(AppEventHandler func)
        {
            this.Slot("AppEvent", (stack) =>
            {
                var eventType = stack.PopString();
                func(eventType);
            });
        }

        public delegate void AppChangeHandler(string settingName);
        public void OnAppChange(AppChangeHandler func)
        {
            this.Slot("AppChange", (stack) =>
            {
                var settingName = stack.PopString();
                func(settingName);
            });
        }

        public delegate void AppWsHandler(string eventType, string msg);
        public void OnAppWs(AppWsHandler func)
        {
            this.Slot("AppWs", (stack) =>
            {
                var eventType = stack.PopString();
                var msg = stack.PopString();
                func(eventType, msg);
            });
        }
    }
    public partial class Playable
    {
        public delegate void AnimationEndHandler(string animationName, Playable target);
        public void OnAnimationEnd(AnimationEndHandler func)
        {
            this.Slot("AnimationEnd", (stack) =>
            {
                var animationName = stack.PopString();
                var target = (Playable)stack.PopObject();
                func(animationName, target);
            });
        }
    }

    public partial class Body
    {
        public delegate void BodyEnterHandler(Body other, int sensorTag);
        public void OnBodyEnter(BodyEnterHandler func)
        {
            this.Slot("BodyEnter", (stack) =>
            {
                var other = (Body)stack.PopObject();
                var sensorTag = stack.PopI32();
                func(other, sensorTag);
            });
        }

        public delegate void BodyLeaveHandler(Body other, int sensorTag);
        public void OnBodyLeave(BodyLeaveHandler func)
        {
            this.Slot("BodyLeave", (stack) =>
            {
                var other = (Body)stack.PopObject();
                var sensorTag = stack.PopI32();
                func(other, sensorTag);
            });
        }

        public delegate void ContactStartHandler(Body other, Vec2 point, Vec2 normal, bool enabled);
        public void OnContactStart(ContactStartHandler func)
        {
            this.IsReceivingContact = true;
            this.Slot("ContactStart", (stack) =>
            {
                var other = (Body)stack.PopObject();
                var point = stack.PopVec2();
                var normal = stack.PopVec2();
                var enabled = stack.PopBool();
                func(other, point, normal, enabled);
            });
        }

        public delegate void ContactEndHandler(Body other, Vec2 point, Vec2 normal);
        public void OnContactEnd(ContactEndHandler func)
        {
            this.IsReceivingContact = true;
            this.Slot("ContactEnd", (stack) =>
            {
                var other = (Body)stack.PopObject();
                var point = stack.PopVec2();
                var normal = stack.PopVec2();
                func(other, point, normal);
            });
        }
    }

    public partial class Particle
    {
        public delegate void FinishedHandler();
        public void OnFinished(FinishedHandler func)
        {
            this.Slot("Finished", (stack) =>
            {
                func();
            });
        }
    }

    public partial class AlignNode
    {
        public delegate void AlignLayoutHandler(float width, float height);
        public void OnAlignLayout(AlignLayoutHandler func)
        {
            this.Slot("AlignLayout", (stack) =>
            {
                var width = stack.PopF32();
                var height = stack.PopF32();
                func(width, height);
            });
        }
    }

    public partial class EffekNode
    {
        public delegate void EffekEndHandler(int handle);
        public void OnEffekEnd(EffekEndHandler func)
        {
            this.Slot("EffekEnd", (stack) =>
            {
                var handle = stack.PopI32();
                func(handle);
            });
        }
    }

    public static partial class Content
    {
        public static string? Load(string filename)
        {
            var result = Native.content_load(Bridge.FromString(filename));
            return result == 0 ? null : Bridge.ToString(result);
        }
    }

    public partial class Array
    {
        /// Sets the item at the given index.
        ///
        /// # Arguments
        ///
        /// * `index` - The index to set, should be 0 based.
        /// * `item` - The new item value.
        public void Set(int index, Value value)
        {
            if (index < 0 || index >= Count)
            {
                throw new IndexOutOfRangeException($"Index out of range: {index}");
            }
            Native.array_set(Raw, index, value.Raw);
        }
        /// Gets the item at the given index.
        ///
        /// # Arguments
        ///
        /// * `index` - The index to get, should be 0 based.
        ///
        /// # Returns
        ///
        /// * `Option<Value>` - The item value.
        public Value? Get(int index)
        {
            var raw = Native.array_get(Raw, index);
            return raw == 0 ? null : Value.From(raw);
        }
        /// The first item in the array.
        public Value? First()
        {
            var raw = Native.array_first(Raw);
            return raw == 0 ? null : Value.From(raw);
        }
        /// The last item in the array.
        public Value? Last()
        {
            var raw = Native.array_last(Raw);
            return raw == 0 ? null : Value.From(raw);
        }
        /// A random item from the array.
        public Value? RandomObject()
        {
            var raw = Native.array_random_object(Raw);
            return raw == 0 ? null : Value.From(raw);
        }
        /// Adds an item to the end of the array.
        ///
        /// # Arguments
        ///
        /// * `item` - The item to add.
        public void Add(Value value)
        {
            Native.array_add(Raw, value.Raw);
        }
        /// Inserts an item at the given index, shifting other items to the right.
        ///
        /// # Arguments
        ///
        /// * `index` - The index to insert at.
        /// * `item` - The item to insert.
        public void Insert(int index, Value value)
        {
            if (index < 0 || index >= Count)
            {
                throw new IndexOutOfRangeException($"Index out of range: {index}");
            }
            Native.array_insert(Raw, index, value.Raw);
        }
        /// Checks whether the array contains a given item.
        ///
        /// # Arguments
        ///
        /// * `item` - The item to check.
        ///
        /// # Returns
        ///
        /// * `bool` - True if the item is found, false otherwise.
        public bool Contains(Value value)
        {
            return Native.array_contains(Raw, value.Raw) != 0;
        }
        /// Gets the index of a given item.
        ///
        /// # Arguments
        ///
        /// * `item` - The item to search for.
        ///
        /// # Returns
        ///
        /// * `i32` - The index of the item, or -1 if it is not found.
        public int Index(Value value)
        {
            return Native.array_index(Raw, value.Raw);
        }
        /// Removes and returns the last item in the array.
        ///
        /// # Returns
        ///
        /// * `Option<Value>` - The last item removed from the array.
        public Value? RemoveLast()
        {
            var raw = Native.array_remove_last(Raw);
            return raw == 0 ? null : Value.From(raw);
        }
        /// Removes the first occurrence of a given item from the array without preserving order.
        ///
        /// # Arguments
        ///
        /// * `item` - The item to remove.
        ///
        /// # Returns
        ///
        /// * `bool` - True if the item was found and removed, false otherwise.
        public bool FastRemove(Value value)
        {
            return Native.array_fast_remove(Raw, value.Raw) != 0;
        }
    }

    public partial class Dictionary
    {
        /// A method for setting items in the dictionary.
        ///
        /// # Arguments
        ///
        /// * `key` - The key of the item to set.
        /// * `item` - The Item to set for the given key, set to None to delete this key-value pair.
        public void Set(string key, Value value)
        {
            Native.dictionary_set(Raw, Bridge.FromString(key), value.Raw);
        }
        /// A method for accessing items in the dictionary.
        ///
        /// # Arguments
        ///
        /// * `key` - The key of the item to retrieve.
        ///
        /// # Returns
        ///
        /// * `Option<Item>` - The Item with the given key, or None if it does not exist.
        public Value? Get(string key)
        {
            var raw = Native.dictionary_get(Raw, Bridge.FromString(key));
            return raw == 0 ? null : Value.From(raw);
        }
    }

    public partial class Entity
    {
        /// Sets a property of the entity to a given value.
        /// This function will trigger events for Observer objects.
        ///
        /// # Arguments
        ///
        /// * `key` - The name of the property to set.
        /// * `item` - The value to set the property to.
        public void Set(string key, Value value)
        {
            Native.entity_set(Raw, Bridge.FromString(key), value.Raw);
        }
        /// Retrieves the value of a property of the entity.
        ///
        /// # Arguments
        ///
        /// * `key` - The name of the property to retrieve the value of.
        ///
        /// # Returns
        ///
        /// * `Option<Value>` - The value of the specified property.
        public Value? Get(string key)
        {
            var raw = Native.entity_get(Raw, Bridge.FromString(key));
            return raw == 0 ? null : Value.From(raw);
        }
        /// Retrieves the previous value of a property of the entity.
        /// The old values are values before the last change of the component values of the Entity.
        ///
        /// # Arguments
        ///
        /// * `key` - The name of the property to retrieve the previous value of.
        ///
        /// # Returns
        ///
        /// * `Option<Value>` - The previous value of the specified property.
        public Value? GetOld(string key)
        {
            var raw = Native.entity_get_old(Raw, Bridge.FromString(key));
            return raw == 0 ? null : Value.From(raw);
        }
    }

    public partial class Group
    {
        /// Watches the group for changes to its entities, calling a function whenever an entity is added or changed.
        ///
        /// # Arguments
        ///
        /// * `callback` - The function to call when an entity is added or changed. Returns true to stop watching.
        ///
        /// # Returns
        ///
        /// * `Group` - The same group, for method chaining.
        public void Watch(Func<CallStack, bool> callback)
        {
            var stack = new CallStack();
            var stack_raw = stack.Raw;
            var func_id = Bridge.PushFunction(() =>
            {
                var result = callback(stack);
                stack.Push(result);
            });
            Native.group_watch(Raw, func_id, stack_raw);
        }
        /// Calls a function for each entity in the group.
        ///
        /// # Arguments
        ///
        /// * `visitor` - The function to call for each entity. Returning true inside the function will stop iteration.
        ///
        /// # Returns
        ///
        /// * `bool` - Returns false if all entities were processed, true if the iteration was interrupted.
        public bool Each(Func<Entity, bool> callback)
        {
            var entity = this.Find(callback);
            return entity != null;
        }
    }

    public partial class Observer
    {
	    /// Watches the components changes to entities that match the observer's component filter.
	    ///
	    /// # Arguments
	    ///
	    /// * `callback` - The function to call when a change occurs. Returns true to stop watching.
	    ///
	    /// # Returns
	    ///
	    /// * `Observer` - The same observer, for method chaining.
        public void Watch(Func<CallStack, bool> callback)
        {
            var stack = new CallStack();
            var stack_raw = stack.Raw;
            var func_id = Bridge.PushFunction(() =>
            {
                var result = callback(stack);
                stack.Push(result);
            });
            Native.observer_watch(Raw, func_id, stack_raw);
        }
    }

    public static partial class Director
    {
        /// Gets the scheduler for the director.
        /// The scheduler is used for scheduling tasks to run for the main game logic.
        ///
        /// # Returns
        ///
        /// * `Scheduler` - The scheduler for the director.
        public static Scheduler Scheduler => Scheduler.From(Native.director_get_scheduler());
        /// Gets the post scheduler for the director.
        /// The post scheduler is used for scheduling tasks that should run after the main scheduler has finished.
        ///
        /// # Returns
        ///
        /// * `Scheduler` - The post scheduler for the director.
        public static Scheduler PostScheduler => Scheduler.From(Native.director_get_post_scheduler());
    }

    namespace Platformer.Behavior
    {
        public partial class Blackboard
        {
            /// Sets a value in the blackboard.
            ///
            /// # Arguments
            /// * `key` - The key associated with the value.
            /// * `value` - The value to be set.
            ///
            /// # Example
            ///
            /// ```
            /// blackboard.set("score", 100);
            /// ```
            public void Set(string key, Value value)
            {
                Native.blackboard_set(Raw, Bridge.FromString(key), value.Raw);
            }
            /// Retrieves a value from the blackboard.
            ///
            /// # Arguments
            ///
            /// * `key` - The key associated with the value.
            ///
            /// # Returns
            ///
            /// An `Option` containing the value associated with the key, or `None` if the key does not exist.
            ///
            /// # Example
            ///
            /// ```
            /// if let Some(score) = blackboard.get("score") {
            ///     println!("Score: {}", score.into_i32().unwrap());
            /// } else {
            ///     println!("Score not found.");
            /// }
            /// ```
            public Value? Get(string key)
            {
                var raw = Native.blackboard_get(Raw, Bridge.FromString(key));
                return raw == 0 ? null : Value.From(raw);
            }
        }
    }

    [Flags]
    public enum ImGuiSliderFlag
    {
        Logarithmic = 1 << 5,
        NoRoundToFormat = 1 << 6,
        NoInput = 1 << 7,
        WrapAround = 1 << 8,
        ClampOnInput = 1 << 9,
        ClampZeroRange = 1 << 10,
        AlwaysClamp = ClampOnInput | ClampZeroRange,
    }

    [Flags]
    public enum ImGuiWindowFlag
    {
        NoTitleBar = 1 << 0,
        NoResize = 1 << 1,
        NoMove = 1 << 2,
        NoScrollbar = 1 << 3,
        NoScrollWithMouse = 1 << 4,
        NoCollapse = 1 << 5,
        AlwaysAutoResize = 1 << 6,
        NoBackground = 1 << 7,
        NoSavedSettings = 1 << 8,
        NoMouseInputs = 1 << 9,
        MenuBar = 1 << 10,
        HorizontalScrollbar = 1 << 11,
        NoFocusOnAppearing = 1 << 12,
        NoBringToFrontOnFocus = 1 << 13,
        AlwaysVerticalScrollbar = 1 << 14,
        AlwaysHorizontalScrollbar = 1 << 15,
        NoNavInputs = 1 << 16,
        NoNavFocus = 1 << 17,
        UnsavedDocument = 1 << 18,
        NoNav = NoNavInputs | NoNavFocus,
        NoDecoration = NoTitleBar | NoResize | NoScrollbar | NoCollapse,
        NoInputs = NoMouseInputs | NoNavInputs | NoNavFocus,
    }

    [Flags]
    public enum ImGuiChildFlag
    {
        Borders = 1 << 0,
        AlwaysUseWindowPadding = 1 << 1,
        ResizeX = 1 << 2,
        ResizeY = 1 << 3,
        AutoResizeX = 1 << 4,
        AutoResizeY = 1 << 5,
        AlwaysAutoResize = 1 << 6,
        FrameStyle = 1 << 7,
    }

    [Flags]
    public enum ImGuiInputTextFlag
    {
        CharsDecimal = 1 << 0,
        CharsHexadecimal = 1 << 1,
        CharsScientific = 1 << 2,
        CharsUppercase = 1 << 3,
        CharsNoBlank = 1 << 4,
        AllowTabInput = 1 << 5,
        EnterReturnsTrue = 1 << 6,
        EscapeClearsAll = 1 << 7,
        CtrlEnterForNewLine = 1 << 8,
        ReadOnly = 1 << 9,
        Password = 1 << 10,
        AlwaysOverwrite = 1 << 11,
        AutoSelectAll = 1 << 12,
        ParseEmptyRefVal = 1 << 13,
        DisplayEmptyRefVal = 1 << 14,
        NoHorizontalScroll = 1 << 15,
        NoUndoRedo = 1 << 16,
        ElideLeft = 1 << 17,
        CallbackCompletion = 1 << 18,
        CallbackHistory = 1 << 19,
        CallbackAlways = 1 << 20,
        CallbackCharFilter = 1 << 21,
        CallbackResize = 1 << 22,
        CallbackEdit = 1 << 23,
    }

    [Flags]
    public enum ImGuiTreeNodeFlag
    {
        Selected = 1 << 0,
        Framed = 1 << 1,
        AllowOverlap = 1 << 2,
        NoTreePushOnOpen = 1 << 3,
        NoAutoOpenOnLog = 1 << 4,
        DefaultOpen = 1 << 5,
        OpenOnDoubleClick = 1 << 6,
        OpenOnArrow = 1 << 7,
        Leaf = 1 << 8,
        Bullet = 1 << 9,
        FramePadding = 1 << 10,
        SpanAvailWidth = 1 << 11,
        SpanFullWidth = 1 << 12,
        SpanLabelWidth = 1 << 13,
        SpanAllColumns = 1 << 14,
        LabelSpanAllColumns = 1 << 15,
        NavLeftJumpsToParent = 1 << 17,
        CollapsingHeader = Framed | NoTreePushOnOpen | NoAutoOpenOnLog,
    }

    [Flags]
    public enum ImGuiSelectableFlag
    {
        DontClosePopups = 1 << 0,
        SpanAllColumns = 1 << 1,
        AllowDoubleClick = 1 << 2,
        Disabled = 1 << 3,
        AllowOverlap = 1 << 4,
    }

    public enum ImGuiCol
    {
        Text,
        TextDisabled,
        WindowBg,
        ChildBg,
        PopupBg,
        Border,
        BorderShadow,
        FrameBg,
        FrameBgHovered,
        FrameBgActive,
        TitleBg,
        TitleBgActive,
        TitleBgCollapsed,
        MenuBarBg,
        ScrollbarBg,
        ScrollbarGrab,
        ScrollbarGrabHovered,
        ScrollbarGrabActive,
        CheckMark,
        SliderGrab,
        SliderGrabActive,
        Button,
        ButtonHovered,
        ButtonActive,
        Header,
        HeaderHovered,
        HeaderActive,
        Separator,
        SeparatorHovered,
        SeparatorActive,
        ResizeGrip,
        ResizeGripHovered,
        ResizeGripActive,
        TabHovered,
        Tab,
        TabSelected,
        TabSelectedOverline,
        TabDimmed,
        TabDimmedSelected,
        TabDimmedSelectedOverline,
        PlotLines,
        PlotLinesHovered,
        PlotHistogram,
        PlotHistogramHovered,
        TableHeaderBg,
        TableBorderStrong,
        TableBorderLight,
        TableRowBg,
        TableRowBgAlt,
        TextLink,
        TextSelectedBg,
        DragDropTarget,
        NavCursor,
        NavWindowingHighlight,
        NavWindowingDimBg,
        ModalWindowDimBg,
    }

    [Flags]
    public enum ImGuiColorEditFlag
    {
        NoAlpha = 1 << 1,
        NoPicker = 1 << 2,
        NoOptions = 1 << 3,
        NoSmallPreview = 1 << 4,
        NoInputs = 1 << 5,
        NoTooltip = 1 << 6,
        NoLabel = 1 << 7,
        NoSidePreview = 1 << 8,
        NoDragDrop = 1 << 9,
        NoBorder = 1 << 10,
        AlphaOpaque = 1 << 11,
        AlphaNoBg = 1 << 12,
        AlphaPreviewHalf = 1 << 13,
        AlphaBar = 1 << 16,
        HDR = 1 << 19,
        DisplayRGB = 1 << 20,
        DisplayHSV = 1 << 21,
        DisplayHex = 1 << 22,
        Uint8 = 1 << 23,
        Float = 1 << 24,
        PickerHueBar = 1 << 25,
        PickerHueWheel = 1 << 26,
        InputRGB = 1 << 27,
        InputHSV = 1 << 28,
        DefaultOptions = Uint8 | DisplayRGB | InputRGB | PickerHueBar,
    }

    [Flags]
    public enum ImGuiCond
    {
        Always = 1 << 0,
        Once = 1 << 1,
        FirstUseEver = 1 << 2,
        Appearing = 1 << 3,
    }

    [Flags]
    public enum ImGuiTableFlag
    {
        Resizable = 1 << 0,
        Reorderable = 1 << 1,
        Hideable = 1 << 2,
        Sortable = 1 << 3,
        NoSavedSettings = 1 << 4,
        ContextMenuInBody = 1 << 5,
        RowBg = 1 << 6,
        BordersInnerH = 1 << 7,
        BordersOuterH = 1 << 8,
        BordersInnerV = 1 << 9,
        BordersOuterV = 1 << 10,
        NoBordersInBody = 1 << 11,
        NoBordersInBodyUntilResize = 1 << 12,
        SizingFixedFit = 1 << 13,
        SizingFixedSame = 1 << 14,
        SizingStretchSame = 1 << 15,
        NoHostExtendX = 1 << 16,
        NoHostExtendY = 1 << 17,
        NoKeepColumnsVisible = 1 << 18,
        PreciseWidths = 1 << 19,
        NoClip = 1 << 20,
        PadOuterX = 1 << 21,
        NoPadOuterX = 1 << 22,
        NoPadInnerX = 1 << 23,
        ScrollX = 1 << 24,
        ScrollY = 1 << 25,
        SortMulti = 1 << 26,
        SortTristate = 1 << 27,
        HighlightHoveredColumn = 1 << 28,
        BordersH = BordersInnerH | BordersOuterH,
        BordersV = BordersInnerV | BordersOuterV,
        BordersInner = BordersInnerV | BordersInnerH,
        BordersOuter = BordersOuterV | BordersOuterH,
        Borders = BordersInnerV | BordersInnerH | BordersOuterV | BordersOuterH,
        SizingStretchProp = SizingFixedFit | SizingFixedSame,
    }

    [Flags]
    public enum ImGuiTableColumnFlag
    {
        Disabled = 1 << 0,
        DefaultHide = 1 << 1,
        DefaultSort = 1 << 2,
        WidthStretch = 1 << 3,
        WidthFixed = 1 << 4,
        NoResize = 1 << 5,
        NoReorder = 1 << 6,
        NoHide = 1 << 7,
        NoClip = 1 << 8,
        NoSort = 1 << 9,
        NoSortAscending = 1 << 10,
        NoSortDescending = 1 << 11,
        NoHeaderLabel = 1 << 12,
        NoHeaderWidth = 1 << 13,
        PreferSortAscending = 1 << 14,
        PreferSortDescending = 1 << 15,
        IndentEnable = 1 << 16,
        IndentDisable = 1 << 17,
        AngledHeader = 1 << 18,
        IsEnabled = 1 << 24,
        IsVisible = 1 << 25,
        IsSorted = 1 << 26,
        IsHovered = 1 << 27,
    }

    public enum ImGuiPopupButton
    {
        MouseButtonLeft = 0,
        MouseButtonRight = 1,
        MouseButtonMiddle = 2,
    }

    [Flags]
    public enum ImGuiPopupFlag
    {
        NoReopen = 1 << 5,
        NoOpenOverExistingPopup = 1 << 7,
        NoOpenOverItems = 1 << 8,
        AnyPopupId = 1 << 10,
        AnyPopupLevel = 1 << 11,
        AnyPopup = AnyPopupId | AnyPopupLevel,
    }

    public enum ImGuiStyleVar
    {
        Alpha = 0,
        DisabledAlpha = 1,
        WindowRounding = 3,
        WindowBorderSize = 4,
        ChildRounding = 7,
        ChildBorderSize = 8,
        PopupRounding = 9,
        PopupBorderSize = 10,
        FrameRounding = 12,
        FrameBorderSize = 13,
        IndentSpacing = 16,
        ScrollbarSize = 18,
        ScrollbarRounding = 19,
        GrabMinSize = 20,
        GrabRounding = 21,
        TabRounding = 22,
        TabBarBorderSize = 23,
        SeparatorTextBorderSize = 26,
    }

    public enum ImGuiStyleVec2
    {
        WindowPadding = 2,
        WindowMinSize = 5,
        WindowTitleAlign = 6,
        FramePadding = 11,
        ItemSpacing = 14,
        ItemInnerSpacing = 15,
        CellPadding = 17,
        ButtonTextAlign = 24,
        SelectableTextAlign = 25,
        SeparatorTextAlign = 27,
        SeparatorTextPadding = 28,
    }

    [Flags]
    public enum ImGuiItemFlag
    {
        NoTabStop = 1 << 0,
        NoNav = 1 << 1,
        NoNavDefaultFocus = 1 << 2,
        ButtonRepeat = 1 << 3,
        AutoClosePopups = 1 << 4,
        AllowDuplicateId = 1 << 5,
    }

    public enum ImGuiTableRowFlag
    {
        Headers = 1 << 0,
    }

    [Flags]
    public enum ImGuiTabBarFlag
    {
        Reorderable = 1 << 0,
        AutoSelectNewTabs = 1 << 1,
        TabListPopupButton = 1 << 2,
        NoCloseWithMiddleMouseButton = 1 << 3,
        NoTabListScrollingButtons = 1 << 4,
        NoTooltip = 1 << 5,
        DrawSelectedOverline = 1 << 6,
        FittingPolicyShrink = 1 << 7,
        FittingPolicyScroll = 1 << 8,
    }

    [Flags]
    public enum ImGuiTabItemFlag
    {
        UnsavedDocument = 1 << 0,
        SetSelected = 1 << 1,
        NoCloseWithMiddleMouseButton = 1 << 2,
        NoPushId = 1 << 3,
        NoTooltip = 1 << 4,
        NoReorder = 1 << 5,
        Leading = 1 << 6,
        Trailing = 1 << 7,
        NoAssumedClosure = 1 << 8,
    }

    public static partial class ImGui
    {
        private static CallStack imguiStack = new CallStack();

        public static void Begin(string name, System.Action inside)
        {
            Begin(name, 0, inside);
        }
        public static void Begin(string name, ImGuiWindowFlag windowsFlags, System.Action inside)
        {
            if (_BeginOpts(name, (int)windowsFlags))
            {
                inside();
            }
            _End();
        }
        public static bool Begin(string name, ref bool opened, System.Action inside)
        {
            return Begin(name, ref opened, 0, inside);
        }
        public static bool Begin(string name, ref bool opened, ImGuiWindowFlag windowsFlags, System.Action inside)
        {
            imguiStack.Push(opened);
            var changed = _BeginRetOpts(name, imguiStack, (int)windowsFlags);
            opened = imguiStack.PopBool();
            if (changed)
            {
                inside();
            }
            _End();
            return changed;
        }
        public static void BeginChild(string str_id, System.Action inside)
        {
            BeginChild(str_id, 0, 0, inside);
        }
        public static void BeginChild(string str_id, ImGuiChildFlag childFlags, ImGuiWindowFlag windowFlags, System.Action inside)
        {
            BeginChild(str_id, Vec2.Zero, childFlags, windowFlags, inside);
        }
        public static void BeginChild(string str_id, Vec2 size, ImGuiChildFlag childFlags, ImGuiWindowFlag windowFlags, System.Action inside)
        {
            if (_BeginChildOpts(str_id, size, (int)childFlags, (int)windowFlags))
            {
                inside();
            }
            _EndChild();
        }
        public static void BeginChild(int id, System.Action inside)
        {
            BeginChild(id, Vec2.Zero, 0, 0, inside);
        }
        public static void BeginChild(int id, Vec2 size, ImGuiChildFlag childFlags, ImGuiWindowFlag windowFlags, System.Action inside)
        {
            if (_BeginChildWithIdOpts(id, size, (int)childFlags, (int)windowFlags))
            {
                inside();
            }
            _EndChild();
        }
        public static bool CollapsingHeader(string label, ref bool opened, System.Action inside)
        {
            return CollapsingHeader(label, ref opened, 0, inside);
        }
        public static bool CollapsingHeader(string label, ref bool opened, ImGuiTreeNodeFlag treeNodeFlags, System.Action inside)
        {
            imguiStack.Push(opened);
            var changed = _CollapsingHeaderRetOpts(label, imguiStack, (int)treeNodeFlags);
            opened = imguiStack.PopBool();
            if (changed)
            {
                inside();
            }
            _End();
            return changed;
        }
        public static bool Selectable(string label, ImGuiSelectableFlag selectableFlags = 0)
        {
            return _SelectableOpts(label, (int)selectableFlags);
        }
        public static bool Selectable(string label, ref bool selected, Vec2 size, ImGuiSelectableFlag selectableFlags, System.Action inside)
        {
            imguiStack.Push(selected);
            bool changed = _SelectableRetOpts(label, imguiStack, size, (int)selectableFlags);
            selected = imguiStack.PopBool();
            return changed;
        }
        public static bool Combo(string label, ref int currentItem, IEnumerable<string> items, int heightInItems = -1)
        {
            imguiStack.Push(currentItem);
            bool changed = _ComboRetOpts(label, imguiStack, items, heightInItems);
            currentItem = imguiStack.PopI32();
            return changed;
        }
        public static bool DragFloat(string label, ref float v, float vSpeed, float vMin, float vMax, string displayFormat = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _DragFloatRetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopF32();
            return changed;
        }
        public static bool DragFloat2(string label, ref float v1, ref float v2, float vSpeed, float vMin, float vMax, string displayFormat = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _DragFloat2RetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, (int)sliderFlags);
            v1 = imguiStack.PopF32();
            v2 = imguiStack.PopF32();
            return changed;
        }
        public static bool DragInt(string label, ref int v, float vSpeed, int vMin, int vMax, string displayFormat = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _DragIntRetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopI32();
            return changed;
        }
        public static bool DragInt2(string label, ref int v1, ref int v2, float vSpeed, int vMin, int vMax, string displayFormat = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _DragInt2RetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, (int)sliderFlags);
            v1 = imguiStack.PopI32();
            v2 = imguiStack.PopI32();
            return changed;
        }
        public static bool InputFloat(string label, ref float v, float step = 0.0f, float stepFast = 0.0f, string displayFormat = "%.2f", ImGuiInputTextFlag inputTextFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _InputFloatRetOpts(label, imguiStack, step, stepFast, displayFormat, (int)inputTextFlags);
            v = imguiStack.PopF32();
            return changed;
        }
        public static bool InputFloat2(string label, ref float v1, ref float v2, string displayFormat = "%.2f", ImGuiInputTextFlag inputTextFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _InputFloat2RetOpts(label, imguiStack, displayFormat, (int)inputTextFlags);
            v1 = imguiStack.PopF32();
            v2 = imguiStack.PopF32();
            return changed;
        }
        public static bool InputInt(string label, ref int v, int step = 1, int stepFast = 100, ImGuiInputTextFlag inputTextFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _InputIntRetOpts(label, imguiStack, step, stepFast, (int)inputTextFlags);
            v = imguiStack.PopI32();
            return changed;
        }
        public static bool InputInt2(string label, ref int v1, ref int v2, ImGuiInputTextFlag inputTextFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _InputInt2RetOpts(label, imguiStack, (int)inputTextFlags);
            v1 = imguiStack.PopI32();
            v2 = imguiStack.PopI32();
            return changed;
        }
        public static bool SliderFloat(string label, ref float v, float vMin, float vMax, string displayFormat = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _SliderFloatRetOpts(label, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopF32();
            return changed;
        }
        public static bool SliderFloat2(string label, ref float v1, ref float v2, float vMin, float vMax, string displayFormat = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _SliderFloat2RetOpts(label, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v1 = imguiStack.PopF32();
            v2 = imguiStack.PopF32();
            return changed;
        }
        public static bool DragFloatRange2(string label, ref float vCurrentMin, ref float vCurrentMax, float vSpeed, float vMin, float vMax, string displayFormat = "%.2f", string displayFormatMax = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(vCurrentMin);
            imguiStack.Push(vCurrentMax);
            bool changed = _DragFloatRange2RetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, displayFormatMax, (int)sliderFlags);
            vCurrentMin = imguiStack.PopF32();
            vCurrentMax = imguiStack.PopF32();
            return changed;
        }
        public static bool DragIntRange2(string label, ref int vCurrentMin, ref int vCurrentMax, float vSpeed, int vMin, int vMax, string displayFormat = "%d", string displayFormatMax = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(vCurrentMin);
            imguiStack.Push(vCurrentMax);
            bool changed = _DragIntRange2RetOpts(label, imguiStack, vSpeed, vMin, vMax, displayFormat, displayFormatMax, (int)sliderFlags);
            vCurrentMin = imguiStack.PopI32();
            vCurrentMax = imguiStack.PopI32();
            return changed;
        }
        public static bool SliderInt(string label, ref int v, int vMin, int vMax, string displayFormat = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _SliderIntRetOpts(label, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopI32();
            return changed;
        }
        public static bool SliderInt2(string label, ref int v1, ref int v2, int vMin, int vMax, string displayFormat = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v1);
            imguiStack.Push(v2);
            bool changed = _SliderInt2RetOpts(label, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v1 = imguiStack.PopI32();
            v2 = imguiStack.PopI32();
            return changed;
        }
        public static bool VSliderFloat(string label, Vec2 size, ref float v, float vMin, float vMax, string displayFormat = "%.2f", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _VSliderFloatRetOpts(label, size, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopF32();
            return changed;
        }
        public static bool VSliderInt(string label, Vec2 size, ref int v, int vMin, int vMax, string displayFormat = "%d", ImGuiSliderFlag sliderFlags = 0)
        {
            imguiStack.Push(v);
            bool changed = _VSliderIntRetOpts(label, size, imguiStack, vMin, vMax, displayFormat, (int)sliderFlags);
            v = imguiStack.PopI32();
            return changed;
        }
        public static bool ColorEdit3(string label, ref Color3 color3, ImGuiColorEditFlag colorEditFlags = 0)
        {
            imguiStack.Push(color3.ToRGB());
            bool changed = _ColorEdit3RetOpts(label, imguiStack, (int)colorEditFlags);
            color3 = new Color3((uint)imguiStack.PopI32());
            return changed;
        }
        public static bool ColorEdit4(string label, ref Color color, ImGuiColorEditFlag colorEditFlags = 0)
        {
            imguiStack.Push(color.ToARGB());
            bool changed = _ColorEdit4RetOpts(label, imguiStack, (int)colorEditFlags);
            color = new Color((uint)imguiStack.PopI32());
            return changed;
        }
        public static bool Checkbox(string label, ref bool check)
        {
            imguiStack.Push(check);
            bool changed = _CheckboxRet(label, imguiStack);
            check = imguiStack.PopBool();
            return changed;
        }
        public static bool RadioButton(string label, ref int value, int vButton)
        {
            imguiStack.Push(value);
            bool changed = _RadioButtonRet(label, imguiStack, vButton);
            value = imguiStack.PopI32();
            return changed;
        }
        public static bool ListBox(string label, ref int currentItem, IEnumerable<string> items, int heightInItems = -1)
        {
            imguiStack.Push(currentItem);
            bool changed = _ListBoxRetOpts(label, imguiStack, items, heightInItems);
            currentItem = imguiStack.PopI32();
            return changed;
        }
        public static void SetNextWindowPosCenter(ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetNextWindowPosCenterOpts((int)setCond);
        }
        public static void SetNextWindowSize(Vec2 size, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetNextWindowSizeOpts(size, (int)setCond);
        }
        public static void SetNextWindowCollapsed(bool collapsed, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetNextWindowCollapsedOpts(collapsed, (int)setCond);
        }
        public static void SetNextItemOpen(bool isOpen, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetNextItemOpenOpts(isOpen, (int)setCond);
        }
        public static void SetWindowPos(string name, Vec2 pos, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetWindowPosOpts(name, pos, (int)setCond);
        }
        public static void SetWindowSize(string name, Vec2 size, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetWindowSizeOpts(name, size, (int)setCond);
        }
        public static void SetWindowCollapsed(string name, bool collapsed, ImGuiCond setCond = ImGuiCond.Always)
        {
            _SetWindowCollapsedOpts(name, collapsed, (int)setCond);
        }
        public static void SetColorEditOptions(ImGuiColorEditFlag colorEditFlags)
        {
            _SetColorEditOptions((int)colorEditFlags);
        }
        public static bool InputText(string label, Buffer buffer, ImGuiInputTextFlag inputTextFlags = 0)
        {
            bool changed = _InputTextOpts(label, buffer, (int)inputTextFlags);
            return changed;
        }
        public static bool InputTextMultiline(string label, ref Buffer buffer, Vec2 size, ImGuiInputTextFlag inputTextFlags = 0)
        {
            bool changed = _InputTextMultilineOpts(label, buffer, size, (int)inputTextFlags);
            return changed;
        }
        public static void TreePush(string strId, System.Action inside)
        {
            _TreePush(strId);
            inside();
            _TreePop();
        }
        public static void TreeNode(string strId, string text, System.Action inside)
        {
            _TreeNodeExWithIdOpts(strId, text, 0);
            inside();
            _TreePop();
        }
        public static void TreeNodeEx(string label, System.Action inside)
        {
            _TreeNodeExOpts(label, 0);
            inside();
            _TreePop();
        }
        public static void TreeNodeEx(string label, ImGuiTreeNodeFlag treeNodeFlags, System.Action inside)
        {
            _TreeNodeExOpts(label, (int)treeNodeFlags);
            inside();
            _TreePop();
        }
        public static void TreeNodeEx(string strId, string text, System.Action inside)
        {
            _TreeNodeExWithIdOpts(strId, text, 0);
            inside();
            _TreePop();
        }
        public static void TreeNodeEx(string strId, string text, ImGuiTreeNodeFlag treeNodeFlags, System.Action inside)
        {
            _TreeNodeExWithIdOpts(strId, text, (int)treeNodeFlags);
            inside();
            _TreePop();
        }
        public static bool CollapsingHeader(string label, ImGuiTreeNodeFlag treeNodeFlags = 0)
        {
            return _CollapsingHeaderOpts(label, (int)treeNodeFlags);
        }
        public static void BeginPopup(string strId, System.Action inside)
        {
            if (_BeginPopup(strId))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupModal(string name, System.Action inside)
        {
            if (_BeginPopupModalOpts(name, 0))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupModal(string name, ImGuiWindowFlag windowsFlags, System.Action inside)
        {
            if (_BeginPopupModalOpts(name, (int)windowsFlags))
            {
                inside();
                _EndPopup();
            }
        }
        public static bool BeginPopupModal(string name, ref bool opened, System.Action inside)
        {
            return BeginPopupModal(name, ref opened, 0, inside);
        }
        public static bool BeginPopupModal(string name, ref bool opened, ImGuiWindowFlag windowsFlags, System.Action inside)
        {
            imguiStack.Push(opened);
            bool changed = _BeginPopupModalRetOpts(name, imguiStack, (int)windowsFlags);
            opened = imguiStack.PopBool();
            if (changed)
            {
                inside();
                _EndPopup();
            }
            return changed;
        }
        public static void BeginPopupContextItem(string name, System.Action inside)
        {
            if (_BeginPopupContextItemOpts(name, (int)ImGuiPopupButton.MouseButtonRight))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupContextItem(string name, ImGuiPopupButton button, System.Action inside)
        {
            if (_BeginPopupContextItemOpts(name, (int)button))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupContextWindow(string name, System.Action inside)
        {
            if (_BeginPopupContextWindowOpts(name, (int)ImGuiPopupButton.MouseButtonRight))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupContextWindow(string name, ImGuiPopupButton button, System.Action inside)
        {
            if (_BeginPopupContextWindowOpts(name, (int)button))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupContextVoid(string name, System.Action inside)
        {
            if (_BeginPopupContextVoidOpts(name, (int)ImGuiPopupButton.MouseButtonRight))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginPopupContextVoid(string name, ImGuiPopupButton button, System.Action inside)
        {
            if (_BeginPopupContextVoidOpts(name, (int)button))
            {
                inside();
                _EndPopup();
            }
        }
        public static void BeginTable(string strId, int column, System.Action inside)
        {
            if (_BeginTableOpts(strId, column, Vec2.Zero, -1.0f, 0))
            {
                inside();
                _EndTable();
            }
        }
        public static void BeginTable(string strId, int column, Vec2 outer_size, int inner_width, ImGuiTableFlag tableFlags, System.Action inside)
        {
            if (_BeginTableOpts(strId, column, outer_size, inner_width, (int)tableFlags))
            {
                inside();
                _EndTable();
            }
        }
        public static void TableSetupColumn(string label, int init_width_or_weight, ImGuiTableColumnFlag tableColumnFlags)
        {
            _TableSetupColumnOpts(label, init_width_or_weight, 0, (int)tableColumnFlags);
        }
        public static void TableSetupColumn(string label, int init_width_or_weight, int user_id, ImGuiTableColumnFlag tableColumnFlags)
        {
            _TableSetupColumnOpts(label, init_width_or_weight, user_id, (int)tableColumnFlags);
        }
        public static void SetNextWindowPos(Vec2 pos)
        {
            _SetNextWindowPosOpts(pos, (int)ImGuiCond.Always, Vec2.Zero);
        }
        public static void SetNextWindowPos(Vec2 pos, ImGuiCond setCond, Vec2 pivot)
        {
            _SetNextWindowPosOpts(pos, (int)setCond, pivot);
        }
        public static void PushStyleColor(ImGuiCol col, Color color)
        {
            _PushStyleColor((int)col, color);
        }
        public static void PushStyleFloat(ImGuiStyleVar style, float val)
        {
            _PushStyleFloat((int)style, val);
        }
        public static void PushStyleVec2(ImGuiStyleVec2 style, Vec2 val)
        {
            _PushStyleVec2((int)style, val);
        }
        public static bool ColorButton(string desc_id, Color col)
        {
            return _ColorButtonOpts(desc_id, col, 0, Vec2.Zero);
        }
        public static bool ColorButton(string desc_id, Color col, ImGuiColorEditFlag colorEditFlags, Vec2 size)
        {
            return _ColorButtonOpts(desc_id, col, (int)colorEditFlags, size);
        }
        public static bool SliderAngleRet(string label, ref float v, float vDegreesMin, float vDegreesMax)
        {
            imguiStack.Push(v);
            bool changed = _SliderAngleRet(label, imguiStack, vDegreesMin, vDegreesMax);
            v = imguiStack.PopF32();
            return changed;
        }
        public static bool ImageButton(string str_id, string clip_str, Vec2 size)
        {
            return ImageButtonOpts(str_id, clip_str, size, Color.Transparent, Color.White);
        }
        public static void TableNextRow(float minRowHeight = 0.0f, ImGuiTableRowFlag tableRowFlag = 0)
        {
            _TableNextRowOpts(minRowHeight, (int)tableRowFlag);
        }
        public static void BeginListBox(string label, Vec2 size, System.Action inside)
        {
            if (_BeginListBox(label, size))
            {
                inside();
                _EndListBox();
            }
        }
        public static void BeginGroup(System.Action inside)
        {
            _BeginGroup();
            inside();
            _EndGroup();
        }
        public static void BeginDisabled(System.Action inside)
        {
            _BeginDisabled();
            inside();
            _EndDisabled();
        }
        public static void BeginTooltip(System.Action inside)
        {
            if (_BeginTooltip())
            {
                inside();
                _EndTooltip();
            }
        }
        public static void BeginMainMenuBar(System.Action inside)
        {
            if (_BeginMainMenuBar())
            {
                inside();
                _EndMainMenuBar();
            }
        }
        public static void BeginMenuBar(System.Action inside)
        {
            if (_BeginMenuBar())
            {
                inside();
                _EndMenuBar();
            }
        }
        public static void BeginMenu(string label, bool enabled, System.Action inside)
        {
            if (_BeginMenu(label, enabled))
            {
                inside();
                _EndMenu();
            }
        }
        public static void PushItemWidth(float width, System.Action inside)
        {
            _PushItemWidth(width);
            inside();
            _PopItemWidth();
        }
        public static void PushTextWrapPos(float wrapPosX, System.Action inside)
        {
            _PushTextWrapPos(wrapPosX);
            inside();
            _PopTextWrapPos();
        }
        public static void PushItemFlag(ImGuiItemFlag flags, bool v, System.Action inside)
        {
            _PushItemFlag((int)flags, v);
            inside();
            _PopItemFlag();
        }
        public static void PushId(string strId, System.Action inside)
        {
            _PushId(strId);
            inside();
            _PopId();
        }
        public static void PushClipRect(Vec2 clipRectMin, Vec2 clipRectMax, bool intersectWithCurrentClipRect, System.Action inside)
        {
            _PushClipRect(clipRectMin, clipRectMax, intersectWithCurrentClipRect);
            inside();
            _PopClipRect();
        }
        public static void BeginTabBar(string strId, System.Action inside)
        {
            if (_BeginTabBar(strId))
            {
                inside();
                _EndTabBar();
            }
        }
        public static void BeginTabBar(string strId, ImGuiTabBarFlag flags, System.Action inside)
        {
            if (_BeginTabBarOpts(strId, (int)flags))
            {
                inside();
                _EndTabBar();
            }
        }
        public static void BeginTabItem(string label, System.Action inside)
        {
            if (_BeginTabItem(label))
            {
                inside();
                _EndTabItem();
            }
        }
        public static void BeginTabItem(string label, ImGuiTabItemFlag flags, System.Action inside)
        {
            if (_BeginTabItemOpts(label, (int)flags))
            {
                inside();
                _EndTabItem();
            }
        }
        public static bool BeginTabItem(string label, ref bool opened, System.Action inside)
        {
            return BeginTabItem(label, ref opened, 0, inside);
        }
        public static bool BeginTabItem(string label, ref bool opened, ImGuiTabItemFlag flags, System.Action inside)
        {
            imguiStack.Push(opened);
            bool changed = _BeginTabItemRetOpts(label, imguiStack, (int)flags);
            opened = imguiStack.PopBool();
            if (changed)
            {
                inside();
                _EndTabItem();
            }
            return changed;
        }
        public static bool TabItemButton(string label, ImGuiTabItemFlag flags)
        {
            return _TabItemButtonOpts(label, (int)flags);
        }
    }

    public enum NvgImageFlag
    {
        /// Generate mipmaps during creation of the image.
        GenerateMipmaps = 1 << 0,
        /// Repeat image in X direction.
        RepeatX = 1 << 1,
        /// Repeat image in Y direction.
        RepeatY = 1 << 2,
        /// Flips (inverses) image in Y direction when rendered.
        FlipY = 1 << 3,
        /// Image data has premultiplied alpha.
        Premultiplied = 1 << 4,
        /// Image interpolation is Nearest instead Linear
        Nearest = 1 << 5,
    }

    public enum NvgLineCap
    {
        Butt = 0,
        Round = 1,
        Square = 2,
    }

    public enum NvgLineJoin
    {
        Round = 1,
        Bevel = 3,
        Miter = 4,
    }

    public enum NvgWinding
    {
        /// Winding for solid shapes
        CCW = 1,
        /// Winding for holes
        CW = 2,
        Solid = CCW,
        Hole = CW,
    }

    public enum NvgArcDir
    {
        CCW = 1,
        CW = 2,
    }

    public enum NvgHAlign
    {
        /// Default, align text horizontally to left.
        Left = 1 << 0,
        /// Align text horizontally to center.
        Center = 1 << 1,
        /// Align text horizontally to right.
        Right = 1 << 2,
    }

    public enum NvgVAlign
    {
        /// Align text vertically to top.
        Top = 1 << 3,
        /// Align text vertically to middle.
        Middle = 1 << 4,
        /// Align text vertically to bottom.
        Bottom = 1 << 5,
        /// Default, align text vertically to baseline.
        BaseLine = 1 << 6,
    }

    public static partial class Nvg
    {
        public static int CreateImage(int w, int h, string filename, NvgImageFlag imageFlags)
        {
            return Native.nvg__create_image(w, h, Bridge.FromString(filename), (int)imageFlags);
        }
        public static void LineCap(NvgLineCap cap)
        {
            Native.nvg__line_cap((int)cap);
        }
        public static void LineJoin(NvgLineJoin join)
        {
            Native.nvg__line_join((int)join);
        }
        public static void PathWinding(NvgWinding winding)
        {
            Native.nvg__path_winding((int)winding);
        }
        public static void Arc(float x, float y, float r, float a0, float a1, NvgArcDir dir)
        {
            Native.nvg__arc(x, y, r, a0, a1, (int)dir);
        }
        public static void TextAlign(NvgHAlign hAlign, NvgVAlign vAlign)
        {
            Native.nvg__text_align((int)hAlign, (int)vAlign);
        }
    }

    public interface IYieldOp
    {
        void Tick(double dt);
        bool IsDone { get; }
    }

    public sealed class WaitForSeconds
    {
        public double Remaining;
        public WaitForSeconds(double seconds) => Remaining = seconds;
    }
    public sealed class WaitUntil
    {
        public Func<bool> Predicate;
        public WaitUntil(Func<bool> predicate) => Predicate = predicate;
    }
    public sealed class WaitWhile
    {
        public Func<bool> Predicate;
        public WaitWhile(Func<bool> predicate) => Predicate = predicate;
    }
    public sealed class CallbackAwait<T>(Action<Action<T>> _starter) : IYieldOp
    {
        private bool _started;
        public bool IsDone { get; private set; }
        public T Result { get; private set; } = default!;

        public void Tick(double dt)
        {
            if (_started) return;
            _started = true;
            _starter(val => { Result = val; IsDone = true; });
        }
    }
    public sealed class CallbackAwaitOptional<T> : IYieldOp
    {
        private readonly Action<Action<T?>> _starter;
        private bool _started;
        public bool IsDone { get; private set; }
        public T? Result { get; private set; }

        public CallbackAwaitOptional(Action<Action<T?>> starter) { _starter = starter; }

        public void Tick(double dt)
        {
            if (_started) return;
            _started = true;
            _starter(val => { Result = val; IsDone = true; });
        }
    }

    public static class Co
    {
        public static Func<double, bool> Loop(Func<IEnumerator> routineFactory)
        {
            IEnumerator loop()
            {
                while (true)
                {
                    yield return routineFactory();
                }
            }
            return Once(loop);
        }
        public static Func<double, bool> Once(Func<IEnumerator> routineFactory)
        {
            IEnumerator? root = null;
            var stack = new Stack<IEnumerator>();
            object? wait = null;
            bool done = false;

            return (double dt) =>
            {
                if (done) return true;

                if (root == null)
                {
                    root = routineFactory();
                    stack.Push(root);
                }

                if (wait is WaitForSeconds wfs)
                {
                    wfs.Remaining -= dt;
                    if (wfs.Remaining > 0.0) return false;
                    wait = null;
                }
                else if (wait is WaitUntil wu)
                {
                    if (!wu.Predicate()) return false;
                    wait = null;
                }
                else if (wait is WaitWhile ww)
                {
                    if (ww.Predicate()) return false;
                    wait = null;
                }
                else if (wait is IYieldOp yo)
                {
                    if (!yo.IsDone)
                    {
                        yo.Tick(dt);
                        if (!yo.IsDone) return false;
                    }
                    wait = null;
                }

                while (!done && wait == null && stack.Count > 0)
                {
                    var top = stack.Peek();
                    if (!top.MoveNext())
                    {
                        stack.Pop();
                        if (stack.Count == 0) { done = true; return true; }
                        continue;
                    }

                    var yielded = top.Current;
                    if (yielded == null)
                    {
                        wait = new WaitForSeconds(0.0);
                    }
                    else if (yielded is WaitForSeconds or WaitUntil or WaitWhile or IYieldOp)
                    {
                        wait = yielded;
                    }
                    else if (yielded is IEnumerator nested)
                    {
                        stack.Push(nested);
                    }
                    else
                    {
                        wait = new WaitForSeconds(0.0);
                    }
                }

                return done;
            };
        }
    }

    public static partial class Content
    {
        /// <summary>
        /// Asynchronously loads the content of the file with the specified filename.
        /// </summary>
        /// <param name="filename">The name of the file to load.</param>
        /// <returns>The awaiter object to get content of the loaded file.</returns>
        public static CallbackAwait<string> LoadAsync(string filename)
        {
            return new CallbackAwait<string>(cb => Content.LoadAsync(filename, cb));
        }

        /// <summary>
        /// Asynchronously copies a file or a folder from the source path to the destination path.
        /// </summary>
        /// <param name="srcFile">The path of the file or folder to copy.</param>
        /// <param name="targetFile">The destination path of the copied files.</param>
        /// <returns>The awaiter object to get `true` if the file or folder was copied successfully, `false` otherwise.</returns>
        public static CallbackAwait<bool> CopyAsync(string srcFile, string targetFile)
        {
            return new CallbackAwait<bool>(cb => Content.CopyAsync(srcFile, targetFile, cb));
        }
        /// <summary>
        /// Asynchronously saves the specified content to a file with the specified filename.
        /// </summary>
        /// <param name="filename">The name of the file to save.</param>
        /// <param name="content">The content to save to the file.</param>
        /// <returns>The awaiter object to get `true` if the content was saved successfully, `false` otherwise.</returns>
        public static CallbackAwait<bool> SaveAsync(string filename, string content)
        {
            return new CallbackAwait<bool>(cb => Content.SaveAsync(filename, content, cb));
        }
        /// <summary>
        /// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
        /// </summary>
        /// <param name="folderPath">The path of the folder to compress, should be under the asset writable path.</param>
        /// <param name="zipFile">The name of the ZIP archive to create.</param>
        /// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
        /// <returns>The awaiter object to get `true` if the folder was compressed successfully, `false` otherwise.</returns>
        public static CallbackAwait<bool> ZipAsync(string folderPath, string zipFile, Func<string, bool> filter)
        {
            return new CallbackAwait<bool>(cb => Content.ZipAsync(folderPath, zipFile, filter, cb));
        }
        /// <summary>
        /// Asynchronously decompresses a ZIP archive to the specified folder.
        /// </summary>
        /// <param name="zipFile">The name of the ZIP archive to decompress, should be a file under the asset writable path.</param>
        /// <param name="folderPath">The path of the folder to decompress to, should be under the asset writable path.</param>
        /// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
        /// <returns>The awaiter object to get `true` if the folder was decompressed successfully, `false` otherwise.</returns>
        public static CallbackAwait<bool> UnzipAsync(string zipFile, string folderPath, Func<string, bool> filter)
        {
            return new CallbackAwait<bool>(cb => Content.UnzipAsync(zipFile, folderPath, filter, cb));
        }
    }

    public static partial class Cache
    {
        /// <summary>
        /// Loads a file into the cache asynchronously.
        /// </summary>
        /// <param name="filename">The name of the file to load.</param>
        /// <returns>The awaiter object to get `true` if the asset was loaded successfully, `false` otherwise.</returns>
        public static CallbackAwait<bool> LoadAsync(string filename)
        {
            return new CallbackAwait<bool>(cb => Cache.LoadAsync(filename, cb));
        }
    }

    public static partial class DB
    {
        /// <summary>
        /// Executes a list of SQL statements as a single transaction asynchronously.
        /// </summary>
        /// <param name="query">A list of SQL statements to execute.</param>
        /// <returns>The awaiter object to get `true` if the transaction was successful, `false` otherwise.</returns>
        public static CallbackAwait<bool> TransactionAsync(DBQuery query)
        {
            return new CallbackAwait<bool>(cb => DB.TransactionAsync(query, cb));
        }
        /// <summary>
		/// Executes an SQL query asynchronously and returns the results as a list of rows.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="params_">Optional. A list of values to substitute into the SQL statement.</param>
		/// <param name="withColumns">Optional. Whether to include column names in the result. Default is `false`.</param>
		/// <returns>The awaiter object to get the results as a list of rows.</returns>
        public static CallbackAwait<DBRecord> QueryAsync(string sql, Array params_, bool withColumns)
        {
            return new CallbackAwait<DBRecord>(cb => DB.QueryAsync(sql, params_, withColumns, cb));
        }
        /// <summary>
		/// Inserts a row of data into a table within a transaction asynchronously.
		/// </summary>
		/// <param name="tableName">The name of the table to insert into.</param>
		/// <param name="values">The values to insert into the table.</param>
        /// <returns>The awaiter object to get the result of the insertion.</returns>
		public static CallbackAwait<bool> InsertAsync(string tableName, DBParams values)
        {
            return new CallbackAwait<bool>(cb => DB.InsertAsync(tableName, values, cb));
        }
        /// <summary>
		/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
		/// </summary>
		/// <param name="sql">The SQL statement to execute.</param>
		/// <param name="values">A list of values to substitute into the SQL statement.</param>
		/// <returns>The awaiter object to get the number of rows affected.</returns>
		public static CallbackAwait<long> ExecAsync(string sql, DBParams values)
        {
            return new CallbackAwait<long>(cb => DB.ExecAsync(sql, values, cb));
        }
    }

    public static partial class HttpClient
    {
        /// <summary>
        /// Sends a POST request to the specified URL and returns the response body.
        /// </summary>
        /// <param name="url">The URL to send the request to.</param>
        /// <param name="json">The JSON data to send in the request body.</param>
        /// <param name="timeout">The timeout in seconds for the request.</param>
        /// <returns>The awaiter object to get the response body as a parameter.</returns>
        public static CallbackAwaitOptional<string> PostAsync(string url, string json, float timeout)
        {
            return new CallbackAwaitOptional<string>(cb => HttpClient.PostAsync(url, json, timeout, cb));
        }
        /// <summary>
        /// Sends a GET request to the specified URL and returns the response body.
        /// </summary>
        /// <param name="url">The URL to send the request to.</param>
        /// <param name="timeout">The timeout in seconds for the request.</param>
        /// <returns>The awaiter object to get the response body as a parameter.</returns>
        public static CallbackAwaitOptional<string> GetAsync(string url, float timeout)
        {
            return new CallbackAwaitOptional<string>(cb => HttpClient.GetAsync(url, timeout, cb));
        }
    }

    public partial class RenderTarget
    {

        /// <summary>
        /// Saves the contents of the render target to a PNG file asynchronously.
        /// </summary>
        /// <param name="filename">The name of the file to save the contents to.</param>
        /// <returns>The awaiter object to get a boolean value indicating whether the save operation was successful.</returns>
        public CallbackAwait<bool> SaveAsync(string filename)
        {
            return new CallbackAwait<bool>(cb => this.SaveAsync(filename, cb));
        }
    }

    public static partial class App
    {
        [DllImport("kernel32.dll", SetLastError = false)]
        static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);

        public static void Run(System.Action main)
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