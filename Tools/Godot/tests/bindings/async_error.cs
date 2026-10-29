// Actual .NET -> generated public P/Invoke asynchronous Godot error probe.
using Dora;
using System.Runtime.InteropServices;

internal static class GodotBindingAsyncError
{
    private static string Required(string name) => Environment.GetEnvironmentVariable(name)
        ?? throw new InvalidOperationException("Missing " + name);
    private static void Check(bool condition) {
        if (!condition) throw new InvalidOperationException("C# asynchronous binding assertion failed");
    }
    private static void Fail(Exception error) {
        Console.Error.WriteLine("GODOT_BINDING_ASYNC CSharp failure=" + error);
        Environment.Exit(2); // Managed exceptions must never unwind across a native callback.
    }
    private static void Create() {
        Check(GodotNode.GetUnsupportedReason() == "");
        var node = new GodotNode(Required("DORA_GODOT_TEST_PROJECT"), Required("DORA_GODOT_BINDING_ERROR_SCENE"), 640, 360, 3);
        Check(node.LastError == "" && !node.IsRunning);
        node.AddTo(Director.UI);
        var control = new Node();
        control.AddTo(Director.UI);
        var elapsed = 0.0;
        Console.WriteLine("GODOT_BINDING_ASYNC CSharp accepted=1 running=0 error_empty=1");
        control.Schedule(dt => {
            try {
                elapsed += dt;
                Check(elapsed < 20);
                var error = node.LastError;
                if (error == "") return false;
                Check(!node.IsRunning && error.Contains(Required("DORA_GODOT_BINDING_EXPECTED_ERROR"), StringComparison.Ordinal));
                Console.WriteLine("GODOT_BINDING_ASYNC CSharp error=" + error);
                node.RemoveFromParent();
                Dora.Event.Emit("GodotBindingAsyncError", "CSharp", error);
                return true;
            } catch (Exception error) { Fail(error); return true; }
        });
    }
    public static void Main() {
        Check(OperatingSystem.IsWindows());
        var library = NativeLibrary.Load(Required("DORA_GODOT_CSHARP_NATIVE_LIBRARY"));
        NativeLibrary.SetDllImportResolver(typeof(GodotBindingAsyncError).Assembly,
            (name, assembly, path) => name == "Dora" ? library : IntPtr.Zero);
        Content.AssetPath = Required("DORA_GODOT_CSHARP_ASSETS");
        App.Run(() => {
            try { Create(); } catch (Exception error) { Fail(error); }
        });
    }
}
