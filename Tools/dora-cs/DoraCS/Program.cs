using System;
using System.Runtime.InteropServices;

internal static class Native
{
    // 与 C 端 typedef 对应：int (*)()
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate int MainFunc();

    // 动态库名按平台分别是 Dora.dll
    [DllImport("Dora", CallingConvention = CallingConvention.Cdecl)]
    public static extern int dora_run(MainFunc mainFunc);
}
class Program
{
    // 保持委托存活（静态字段）
    private static readonly Native.MainFunc s_main = () =>
    {
        Console.WriteLine("Hello from C#");
        return 1;
    };

    static void Main()
    {
        int rc = Native.dora_run(s_main);
        GC.KeepAlive(s_main); // 双保险
        Console.WriteLine($"dora_run returned {rc}");
    }
}