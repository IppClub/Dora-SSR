namespace Dora
{
    public class Node : Object
    {
        public static (int typeId, CreateFunc func) GetTypeInfo()
        {
            return (Native.node_type(), (long raw) => new Node(raw));
        }

        public Node() : base(Native.node_new()) { }

        private Node(long raw) : base(raw) { }

        public string Tag
        {
            get => Bridge.ToString(Native.node_get_tag(Raw));
            set => Native.node_set_tag(Raw, Bridge.FromString(value));
        }

        public Color Color
        {
            get => new Color((uint)Native.node_get_color(Raw));
            set => Native.node_set_color(Raw, (int)value.ToArgb());
        }

        public float X
        {
            get => Native.node_get_x(Raw);
            set => Native.node_set_x(Raw, value);
        }

        public float Y
        {
            get => Native.node_get_y(Raw);
            set => Native.node_set_y(Raw, value);
        }
    }
}
