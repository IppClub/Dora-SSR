using Dora;

App.Run(() =>
{
    var node = new Node();
    node.Tag = "Dora Node";
    node.Color = new Color(0xff00ffff);
    Log.Print($"Hello from C#! {node.Tag} {node.Color.G}");
});
