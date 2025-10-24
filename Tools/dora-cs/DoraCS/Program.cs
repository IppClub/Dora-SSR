using Dora;
using System.Collections;

App.Run(() =>
{
    App.WinSize = new Size(640 * App.DevicePixelRatio, 480 * App.DevicePixelRatio);
    var node = new Sprite(Nvg.GetDoraSSR());
    node.Tag = "Dora Node";
    node.Perform(ActionDef.Sequence(
    [
        ActionDef.Scale(1.0f, 0.3f, 0.5f, EaseType.OutBack),
        ActionDef.Scale(1.0f, 0.5f, 0.3f, EaseType.InBack),
    ]), true);
    node.OnUpdate((dt) =>
    {
        if (Keyboard.IsKeyDown(KeyName.Escape))
        {
            App.Shutdown();
        }
        return false;
    });
    node.OnUpdate(Co.Once(MyCoroutine));
    IEnumerator MyCoroutine()
    {
        Log.Info("start");
        yield return Co.Cycle(2, (time) =>
        {
            node.X = 500 * (float)time;
        });
        var awaiter = Content.LoadAsync("non-existed.txt");
        yield return awaiter;
        if (awaiter.Result != "")
        {
            Log.Info(awaiter.Result);
        }
        yield return Co.Seconds(3.0);
        Log.Info("after 3s");
        node.Perform(ActionDef.Scale(0.5f, node.ScaleX, 0));
        yield return Co.Seconds(0.5);
        node.RemoveFromParent();
        Log.Info("destroyed sprite");
        yield return Co.Frames(1);
    }
    node.OnTapped((touch) =>
    {
        Log.Info($"{touch.Location.X} x {touch.Location.Y}");
    });
    Log.Info($"Hello from C#! {node.Tag} {node.Color.G}");
});
