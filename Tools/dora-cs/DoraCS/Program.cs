using System;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;

internal static class Native
{
    private const string Dll = "Dora";

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate int MainFunc();

    [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
    public static extern int dora_run(MainFunc mainFunc);

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

    [DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
    internal static extern void dora_print(long var);
}

public static class Bridge
{
    public static string ToStringAndFree(long str)
    {
        int len = Native.str_len(str);
        if (len <= 0)
        {
            Native.str_release(str);
            return string.Empty;
        }

        byte[] buf = new byte[len];
        unsafe
        {
            fixed (byte* p = buf)
            {
                Native.str_read((IntPtr)p, str);
            }
        }
        Native.str_release(str);
        return Encoding.UTF8.GetString(buf);
    }

    public static long FromString(string s)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(s ?? string.Empty);
        long h = Native.str_new(bytes.Length);

        if (bytes.Length > 0)
        {
            unsafe
            {
                fixed (byte* p = bytes)
                {
                    Native.str_write(h, (IntPtr)p);
                }
            }
        }
        return h;
    }
}

class Program
{
    // 保持委托存活（静态字段）
    private static readonly Native.MainFunc s_main = () =>
    {
        Native.dora_print(Bridge.FromString("Hello from C#"));
        return 1;
    };

    static void Main()
    {
        try
        {
            Native.dora_run(s_main);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.ToString());
        }
    }
}