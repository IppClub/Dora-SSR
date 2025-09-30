using Dora;

App.Run(() =>
{
    App.WinSize = new Size(640 * App.DevicePixelRatio, 480 * App.DevicePixelRatio);
    var node = new Sprite(Nvg.GetDoraSSR(1.0f));
    node.Tag = "Dora Node";
    node.PerformDef(ActionDef.Sequence(
    [
        ActionDef.Scale(1.0f, 0.3f, 0.5f, EaseType.OutBack),
        ActionDef.Scale(1.0f, 0.5f, 0.3f, EaseType.InBack),
    ]), true);
    node.Schedule(Co.Once(MyCoroutine));
    System.Collections.IEnumerator MyCoroutine()
    {
        Log.Print("start");
        yield return new WaitForSeconds(5.0);
        Log.Print("after 5s");
        node.RemoveFromParent(true);
    }
node.OnTapped((touch) =>
    {
        Log.Print($"{touch.Location.X} x {touch.Location.Y}");
    });
    Log.Print($"Hello from C#! {node.Tag} {node.Color.G}");
});
