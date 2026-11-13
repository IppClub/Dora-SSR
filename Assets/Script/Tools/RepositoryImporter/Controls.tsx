import { React } from "DoraX";
import { Vec2 } from "Dora";
// Use native draw nodes so the panel, clip area and text share one render queue.
const vertices = (width: number, height: number, radius = 14) => {
 const result: Vec2.Type[] = [];
 for (const corner of [{x: width-radius,y: radius,start: -math.pi/2},{x: width-radius,y: height-radius,start: 0},{x: radius,y: height-radius,start: math.pi/2},{x: radius,y: radius,start: math.pi}]) {
  for (let i=0;i<=6;i++) { const angle=corner.start+i*math.pi/12; result.push(Vec2(corner.x+math.cos(angle)*radius,corner.y+math.sin(angle)*radius)); }
 }
 return result;
};
export function MobilePanelSurface(props: {width: number; height: number; renderOrder?: number}) {
 return <draw-node renderOrder={props.renderOrder}><polygon-shape verts={vertices(props.width,props.height,24)} fillColor={0xff1b2330} borderWidth={1} borderColor={0xff4a5568} /></draw-node>;
}
export function MobileButton(props: {x:number;y:number;width:number;height?:number;text:string;tag?:string;fontSize?:number;primary?:boolean;renderOrder?:number;onTapped():void}) {
 const height=props.height??48;
 return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={props.onTapped}>
  <draw-node renderOrder={props.renderOrder}><polygon-shape verts={vertices(props.width,height)} fillColor={props.primary?0xffffcc33:0xff293140} borderWidth={1} borderColor={props.primary?0xffffdd63:0xff4a5568} /></draw-node>
  <label x={props.width/2} y={height/2} renderOrder={0} fontName="sarasa-mono-sc-regular" fontSize={props.fontSize??17} text={props.text} color3={props.primary?0x17130a:0xf4f1e8} />
 </node>;
}

export function RoundedSurface(props: {width:number;height:number;radius:number;topColor:number;bottomColor?:number}) {
 return <draw-node><polygon-shape verts={vertices(props.width,props.height,props.radius)} fillColor={props.topColor} /></draw-node>;
}
