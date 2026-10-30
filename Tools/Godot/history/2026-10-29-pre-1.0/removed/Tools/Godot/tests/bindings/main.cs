// Real .NET -> generated P/Invoke bindings -> GodotNode GPU regression fixture.
using Dora;
using System.Runtime.InteropServices;

internal static class GodotBindingFixture
{
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    private delegate int CreateNode();
    [DllImport("Dora", CallingConvention = CallingConvention.Cdecl)]
    private static extern void dora_godot_binding_set_create(CreateNode create);
    [DllImport("Dora", CallingConvention = CallingConvention.Cdecl)]
    private static extern int dora_godot_node_test_main();
    private static readonly CreateNode Factory = Create;
    private static void Check(bool condition) {
        if (!condition) throw new InvalidOperationException("C# Godot binding assertion failed");
    }
    private static int Create() {
        try {
            Check(GodotNode.GetUnsupportedReason() == "");
            Console.WriteLine("GODOT_BINDING CSharp unsupported_reason_empty=1");
            Check(Director.SystemUI.Raw != 0);
            Director.ClearSystemUI();
            Audio.Listener = null;
            Console.WriteLine("GODOT_BINDING CSharp abi_helpers=1");
            var project = Environment.GetEnvironmentVariable("DORA_GODOT_TEST_PROJECT")!;
            if (Environment.GetEnvironmentVariable("DORA_GODOT_BINDING_REJECTIONS") == "1") {
                foreach (var (width, height, buffers) in new[] { (0, 360, 3), (640, 0, 3), (8193, 360, 3), (640, 360, 1), (640, 360, 5) }) {
                    Check(GodotNode.TryCreate(project, "", width, height, buffers) == null);
                }
                Check(GodotNode.TryCreate("/dora-godot-intentionally-missing-project", "", 640, 360, 3) == null);
                Console.WriteLine("GODOT_BINDING CSharp constructor_rejections=6");
            }
            var node = new GodotNode(project, "res://main.tscn", 640, 360, 3);
            Check(node.ProjectPath == project && node.SceneFile == "res://main.tscn" && node.LastError == "");
            Check(node.ViewportSize.Width == 640 && node.ViewportSize.Height == 360);
            node.Pause(); Check(node.IsPaused);
            node.ScaleX = 1.25f; node.ScaleY = 1.25f;
            node.Tag = "GodotBindingNode"; node.AddTo(Director.UI);
            var control = new Node(); control.Tag = "GodotBindingControl"; control.AddTo(Director.UI);
            control.Gslot("GodotBindingTest", stack => {
                try {
                    var command = stack.PopString();
                    switch (command) {
                        case "probe": node.SendKey("F9", true); node.SendKey("F9", false); break;
                        case "resume": node.Resume(); Check(!node.IsPaused); break;
                        case "pause": node.Pause(); Check(node.IsPaused); break;
                        case "verify": Check(node.IsRunning && node.LastError == ""); break;
                        case "input":
                            node.Resume(); node.SendPointerMove(240, 310);
                            node.SendPointer(240, 310, 1, true); node.SendPointer(240, 310, 1, false);
                            node.SendText("Dora"); node.SendKey("Space", true); node.SendKey("Space", false); break;
                        case "held": node.SendKey("F8", true); node.SendPointer(20, 20, 1, true); break;
                        case "restart": Check(node.Restart()); break;
                        case "resize_large": Check(node.ResizeViewport(800, 450)); Check(!node.ResizeViewport(801, 450)); break;
                        case "resize_small": Check(node.ResizeViewport(320, 180)); Check(!node.ResizeViewport(321, 180)); break;
                        case "resize_restore": Check(node.ResizeViewport(640, 360)); Check(!node.ResizeViewport(641, 360)); break;
                        case "verify_large": VerifySize(node, 800, 450); break;
                        case "verify_small": VerifySize(node, 320, 180); break;
                        case "verify_restore": VerifySize(node, 640, 360); break;
                        case "resize_pause": node.Pause(); Check(node.IsPaused); break;
                        case "resize_resume": node.Resume(); Check(!node.IsPaused); break;
                        case "resize_invalid":
                            Check(!node.ResizeViewport(0, 180) && !node.ResizeViewport(-1, 360)
                                && !node.ResizeViewport(640, 8193) && node.IsRunning); break;
                        case "resize_cancel": Check(node.ResizeViewport(1024, 576)); break;
                        default: throw new InvalidOperationException("Unknown command: " + command);
                    }
                    Console.WriteLine("GODOT_BINDING CSharp command=" + command);
                } catch (Exception error) { Fail(error); }
            });
            Console.WriteLine("GODOT_BINDING CSharp created=1");
            return 1;
        } catch (Exception error) { Fail(error); return 0; }
    }
    private static void VerifySize(GodotNode node, int width, int height) {
        var size = node.ViewportSize;
        Check(size.Width == width && size.Height == height && node.ResizeViewport(width, height));
    }
    private static void Fail(Exception error) {
        Console.Error.WriteLine("GODOT_BINDING CSharp failure=" + error);
        Environment.Exit(2); // Never unwind a managed exception across a native callback.
    }
    public static void Main() {
        Check(OperatingSystem.IsWindows()); // Current public App.Run uses the Windows host.
        var library = NativeLibrary.Load(Environment.GetEnvironmentVariable("DORA_GODOT_CSHARP_NATIVE_LIBRARY")!);
        NativeLibrary.SetDllImportResolver(typeof(GodotBindingFixture).Assembly,
            (name, assembly, searchPath) => name == "Dora" ? library : IntPtr.Zero);
        Content.AssetPath = Environment.GetEnvironmentVariable("DORA_GODOT_CSHARP_ASSETS")!;
        App.Run(() => {
            try {
                dora_godot_binding_set_create(Factory);
                Check(dora_godot_node_test_main() == 1);
            } catch (Exception error) { Fail(error); }
        });
        GC.KeepAlive(Factory);
    }
}
