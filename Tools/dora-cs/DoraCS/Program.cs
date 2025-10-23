using Dora;
using System.Collections;

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
    node.Schedule(Co.Loop(MyCoroutine));
    IEnumerator MyCoroutine()
    {
        Log.Print("start");
        var awaiter = Content.LoadAsync("non-existed.txt");
        yield return awaiter;
        Log.Print(awaiter.Result);
        yield return new WaitForSeconds(3.0);
        Log.Print("after 3s");
        node.RemoveFromParent();
        //Log.Print("destroyed sprite");
    }
    node.OnTapped((touch) =>
    {
        Log.Print($"{touch.Location.X} x {touch.Location.Y}");
    });
    Log.Print($"Hello from C#! {node.Tag} {node.Color.G}");
});
