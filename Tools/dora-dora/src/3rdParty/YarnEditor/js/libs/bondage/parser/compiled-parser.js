var o=function(k,v,o,l){for(o=o||{},l=k.length;l--;o[k[l]]=v);return o},$V0=[1,6],$V1=[1,17],$V2=[1,18],$V3=[1,13],$V4=[1,20],$V5=[1,19],$V6=[5,8,18,19,23,34,36,77],$V7=[1,24],$V8=[5,18,19,23,34,36,77],$V9=[1,25],$Va=[1,27],$Vb=[1,28],$Vc=[5,8,9,18,19,21,23,34,36,77],$Vd=[1,32],$Ve=[1,36],$Vf=[1,37],$Vg=[1,38],$Vh=[1,39],$Vi=[5,8,9,18,19,21,23,26,34,36,77],$Vj=[1,52],$Vk=[1,51],$Vl=[1,46],$Vm=[1,47],$Vn=[1,48],$Vo=[1,53],$Vp=[1,54],$Vq=[1,55],$Vr=[1,56],$Vs=[1,57],$Vt=[5,8,9,18,19,23,34,36,77],$Vu=[1,73],$Vv=[1,74],$Vw=[1,75],$Vx=[1,76],$Vy=[1,77],$Vz=[1,78],$VA=[1,79],$VB=[1,80],$VC=[1,81],$VD=[1,82],$VE=[1,83],$VF=[1,84],$VG=[1,85],$VH=[1,86],$VI=[1,87],$VJ=[26,46,51,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,70,78],$VK=[26,46,51,53,54,55,56,57,60,61,62,63,64,65,66,67,68,70,78],$VL=[26,46,51,70,78],$VM=[1,124],$VN=[1,125],$VO=[26,46,51,53,54,60,61,62,63,64,65,66,67,68,70,78],$VP=[26,46,51,60,61,62,63,64,65,66,67,68,70,78],$VQ=[51,70],$VR=[8,9,18,19,23,34,77];
var parser = {trace: function trace () { },
yy: {},
symbols_: {"error":2,"node":3,"statements":4,"EndOfInput":5,"conditionalBlock":6,"statement":7,"Comment":8,"EndOfLine":9,"text":10,"shortcut":11,"genericCommand":12,"assignmentCommand":13,"jumpCommand":14,"stopCommand":15,"hashtags":16,"textNode":17,"Text":18,"EscapedCharacter":19,"inlineExpression":20,"Hashtag":21,"conditional":22,"BeginCommand":23,"If":24,"expression":25,"EndCommand":26,"EndIf":27,"additionalConditionalBlocks":28,"else":29,"Else":30,"elseif":31,"ElseIf":32,"shortcutOption":33,"ShortcutOption":34,"Indent":35,"Dedent":36,"Jump":37,"Identifier":38,"Stop":39,"setCommandInner":40,"declareCommandInner":41,"Set":42,"Variable":43,"EqualToOrAssign":44,"Declare":45,"As":46,"ExplicitType":47,"functionArgument":48,"functionCall":49,"LeftParen":50,"RightParen":51,"UnaryMinus":52,"Add":53,"Minus":54,"Exponent":55,"Multiply":56,"Divide":57,"Modulo":58,"Not":59,"Or":60,"And":61,"Xor":62,"EqualTo":63,"NotEqualTo":64,"GreaterThan":65,"GreaterThanOrEqualTo":66,"LessThan":67,"LessThanOrEqualTo":68,"parenExpressionArgs":69,"Comma":70,"literal":71,"True":72,"False":73,"Number":74,"String":75,"Null":76,"BeginInlineExp":77,"EndInlineExp":78,"$accept":0,"$end":1},
terminals_: {2:"error",5:"EndOfInput",8:"Comment",9:"EndOfLine",18:"Text",19:"EscapedCharacter",21:"Hashtag",23:"BeginCommand",24:"If",26:"EndCommand",27:"EndIf",30:"Else",32:"ElseIf",34:"ShortcutOption",35:"Indent",36:"Dedent",37:"Jump",38:"Identifier",39:"Stop",42:"Set",43:"Variable",44:"EqualToOrAssign",45:"Declare",46:"As",47:"ExplicitType",50:"LeftParen",51:"RightParen",52:"UnaryMinus",53:"Add",54:"Minus",55:"Exponent",56:"Multiply",57:"Divide",58:"Modulo",59:"Not",60:"Or",61:"And",62:"Xor",63:"EqualTo",64:"NotEqualTo",65:"GreaterThan",66:"GreaterThanOrEqualTo",67:"LessThan",68:"LessThanOrEqualTo",70:"Comma",72:"True",73:"False",74:"Number",75:"String",76:"Null",77:"BeginInlineExp",78:"EndInlineExp"},
productions_: [0,[3,2],[4,1],[4,2],[4,1],[4,2],[7,2],[7,1],[7,1],[7,1],[7,1],[7,1],[7,1],[7,2],[7,2],[7,2],[17,1],[17,1],[10,1],[10,1],[10,2],[16,1],[16,2],[22,4],[6,6],[6,4],[6,2],[29,3],[29,2],[31,4],[31,2],[28,5],[28,5],[28,3],[33,2],[33,3],[33,2],[33,2],[33,3],[33,2],[11,1],[11,5],[12,3],[14,4],[14,4],[15,3],[13,3],[13,3],[40,4],[41,4],[41,6],[25,1],[25,1],[25,3],[25,2],[25,3],[25,3],[25,3],[25,3],[25,3],[25,3],[25,2],[25,3],[25,3],[25,3],[25,3],[25,3],[25,3],[25,3],[25,3],[25,3],[49,3],[49,4],[69,3],[69,1],[48,1],[48,1],[48,1],[71,1],[71,1],[71,1],[71,1],[71,1],[20,3]],
performAction: function anonymous(yytext, yyleng, yylineno, yy, yystate /* action[1] */, $$ /* vstack */, _$ /* lstack */) {
/* this == yyval */

var $0 = $$.length - 1;
switch (yystate) {
case 1:
return $$[$0-1].flat();
break;
case 2: case 4: case 8: case 9: case 10: case 11: case 12: case 18: case 19: case 74:
this.$ = [$$[$0]];
break;
case 3: case 20:
this.$ = $$[$0-1].concat($$[$0]);
break;
case 5:
this.$ = $$[$0-1].concat([$$[$0]]);
break;
case 6: case 27: case 28:
this.$ = undefined
break;
case 7: case 52:
this.$ = $$[$0]
break;
case 13: case 15: case 26: case 29: case 30: case 46: case 53:
this.$ = $$[$0-1];
break;
case 14:
this.$ = $$[$0-1].map(s => Object.assign(s, { hashtags: $$[$0] }));
break;
case 16:
this.$ = new yy.TextNode($$[$0], this._$);
break;
case 17:
this.$ = new yy.EscapedCharacterNode($$[$0], this._$);
break;
case 21:
this.$ = [$$[$0].substring(1)];
break;
case 22:
this.$ = [$$[$0-1].substring(1)].concat($$[$0]);
break;
case 23: case 37: case 39:
this.$ = $$[$0-1]
break;
case 24:
this.$ = new yy.IfNode($$[$0-5], $$[$0-3].flat());
break;
case 25:
this.$ = new yy.IfElseNode($$[$0-3], $$[$0-1].flat(), $$[$0]);
break;
case 31:
this.$ = new yy.ElseNode($$[$0-3].flat());
break;
case 32:
this.$ = new yy.ElseIfNode($$[$0-4], $$[$0-3].flat());
break;
case 33:
this.$ = new yy.ElseIfNode($$[$0-2], $$[$0-1].flat(), $$[$0]);
break;
case 34:
this.$ = { text: $$[$0] };
break;
case 35:
this.$ = { text: $$[$0-1], conditional: $$[$0] };
break;
case 36:
this.$ = { ...$$[$0-1], hashtags: $$[$0] }
break;
case 38:
this.$ = { ...$$[$0-2], hashtags: $$[$0-1] }
break;
case 40:
this.$ = new yy.DialogShortcutNode($$[$0].text, undefined, this._$, $$[$0].hashtags, $$[$0].conditional);
break;
case 41:
this.$ = new yy.DialogShortcutNode($$[$0-4].text, $$[$0-1].flat(), this._$, $$[$0-4].hashtags, $$[$0-4].conditional);
break;
case 42:
this.$ = new yy.GenericCommandNode($$[$0-1], this._$);
break;
case 43: case 44:
this.$ = new yy.JumpCommandNode($$[$0-1]);
break;
case 45:
this.$ = new yy.StopCommandNode();
break;
case 47:
this.$ = null
break;
case 48:
this.$ = new yy.SetVariableEqualToNode($$[$0-2].substring(1), $$[$0]);
break;
case 49:
this.$ = null;yy.registerDeclaration($$[$0-2].substring(1), $$[$0])
break;
case 50:
this.$ = null;yy.registerDeclaration($$[$0-4].substring(1), $$[$0-2], $$[$0])
break;
case 51: case 75: case 76:
this.$ = $$[$0];
break;
case 54:
this.$ = new yy.UnaryMinusExpressionNode($$[$0]);
break;
case 55:
this.$ = new yy.ArithmeticExpressionAddNode($$[$0-2], $$[$0]);
break;
case 56:
this.$ = new yy.ArithmeticExpressionMinusNode($$[$0-2], $$[$0]);
break;
case 57:
this.$ = new yy.ArithmeticExpressionExponentNode($$[$0-2], $$[$0]);
break;
case 58:
this.$ = new yy.ArithmeticExpressionMultiplyNode($$[$0-2], $$[$0]);
break;
case 59:
this.$ = new yy.ArithmeticExpressionDivideNode($$[$0-2], $$[$0]);
break;
case 60:
this.$ = new yy.ArithmeticExpressionModuloNode($$[$0-2], $$[$0]);
break;
case 61:
this.$ = new yy.NegatedBooleanExpressionNode($$[$0]);
break;
case 62:
this.$ = new yy.BooleanOrExpressionNode($$[$0-2], $$[$0]);
break;
case 63:
this.$ = new yy.BooleanAndExpressionNode($$[$0-2], $$[$0]);
break;
case 64:
this.$ = new yy.BooleanXorExpressionNode($$[$0-2], $$[$0]);
break;
case 65:
this.$ = new yy.EqualToExpressionNode($$[$0-2], $$[$0]);
break;
case 66:
this.$ = new yy.NotEqualToExpressionNode($$[$0-2], $$[$0]);
break;
case 67:
this.$ = new yy.GreaterThanExpressionNode($$[$0-2], $$[$0]);
break;
case 68:
this.$ = new yy.GreaterThanOrEqualToExpressionNode($$[$0-2], $$[$0]);
break;
case 69:
this.$ = new yy.LessThanExpressionNode($$[$0-2], $$[$0]);
break;
case 70:
this.$ = new yy.LessThanOrEqualToExpressionNode($$[$0-2], $$[$0]);
break;
case 71:
this.$ = new yy.FunctionCallNode($$[$0-2], [], this._$);
break;
case 72:
this.$ = new yy.FunctionCallNode($$[$0-3], $$[$0-1], this._$);
break;
case 73:
this.$ = $$[$0-2].concat([$$[$0]]);
break;
case 77:
this.$ = new yy.VariableNode($$[$0].substring(1));
break;
case 78: case 79:
this.$ = new yy.BooleanLiteralNode($$[$0]);
break;
case 80:
this.$ = new yy.NumericLiteralNode($$[$0]);
break;
case 81:
this.$ = new yy.StringLiteralNode($$[$0]);
break;
case 82:
this.$ = new yy.NullLiteralNode($$[$0]);
break;
case 83:
this.$ = new yy.InlineExpressionNode($$[$0-1], this._$);
break;
}
},
table: [{3:1,4:2,6:3,7:4,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},{1:[3]},{5:[1,21],6:22,7:23,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},o($V6,[2,2],{9:$V7}),o($V8,[2,4],{16:26,8:$V9,9:$Va,21:$Vb}),{9:[1,29]},{9:[1,30]},o([5,8,9,21,23,34,36],[2,7],{17:14,20:15,10:31,18:$V1,19:$V2,77:$V5}),o($Vc,[2,8]),o($Vc,[2,9]),o($Vc,[2,10]),o($Vc,[2,11]),o($Vc,[2,12]),{10:33,17:14,18:$V1,19:$V2,20:15,24:$Vd,37:$Ve,39:$Vf,40:34,41:35,42:$Vg,45:$Vh,77:$V5},o($Vi,[2,18]),o($Vi,[2,19]),o($V8,[2,40],{16:41,8:[1,42],9:[1,40],21:$Vb}),o($Vi,[2,16]),o($Vi,[2,17]),{20:49,25:43,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{10:58,17:14,18:$V1,19:$V2,20:15,77:$V5},{1:[2,1]},o($V6,[2,3],{9:$V7}),o($V8,[2,5],{16:26,8:$V9,9:$Va,21:$Vb}),o($Vt,[2,26]),o($Vc,[2,13]),o($Vc,[2,14]),o($Vc,[2,15]),o($Vt,[2,21],{16:59,21:$Vb}),{4:60,6:3,7:4,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},o($Vc,[2,6]),o([5,8,9,21,23,26,34,36],[2,20],{17:14,20:15,10:31,18:$V1,19:$V2,77:$V5}),{20:49,25:61,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{10:31,17:14,18:$V1,19:$V2,20:15,26:[1,62],77:$V5},{26:[1,63]},{26:[1,64]},{20:66,38:[1,65],77:$V5},{26:[1,67]},{43:[1,68]},{43:[1,69]},o($Vc,[2,39],{35:[1,70]}),o([5,9,18,19,21,23,34,36,77],[2,36],{8:[1,71]}),o($Vc,[2,37]),{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI,78:[1,72]},o($VJ,[2,51]),o($VJ,[2,52]),{20:49,25:88,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:89,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:90,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},o($VJ,[2,75]),o($VJ,[2,76]),o($VJ,[2,77]),{50:[1,91]},o($VJ,[2,78]),o($VJ,[2,79]),o($VJ,[2,80]),o($VJ,[2,81]),o($VJ,[2,82]),o([5,8,9,21,34,36],[2,34],{17:14,20:15,10:31,22:92,18:$V1,19:$V2,23:[1,93],77:$V5}),o($Vc,[2,22]),{6:22,7:23,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:[1,94],28:95,29:96,31:97,33:16,34:$V4,77:$V5},{26:[1,98],53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI},o($Vc,[2,42]),o($Vc,[2,46]),o($Vc,[2,47]),{26:[1,99]},{26:[1,100]},o($Vc,[2,45]),{44:[1,101]},{44:[1,102]},{4:103,6:3,7:4,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},o($Vc,[2,38]),o([5,8,9,18,19,21,23,26,34,36,46,51,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,70,77,78],[2,83]),{20:49,25:104,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:105,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:106,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:107,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:108,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:109,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:110,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:111,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:112,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:113,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:114,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:115,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:116,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:117,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:118,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{51:[1,119],53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI},o($VK,[2,54],{58:$Vz}),o($VL,[2,61],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),{20:49,25:122,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,51:[1,120],52:$Vm,59:$Vn,69:121,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},o($Vc,[2,35]),{24:$Vd},{10:33,17:14,18:$V1,19:$V2,20:15,24:$Vd,27:[1,123],30:$VM,32:$VN,37:$Ve,39:$Vf,40:34,41:35,42:$Vg,45:$Vh,77:$V5},o($Vt,[2,25]),{4:126,6:3,7:4,8:$V0,9:[1,127],10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},{4:128,6:3,7:4,8:$V0,9:[1,129],10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,77:$V5},o($Vc,[2,23]),o($Vc,[2,43]),o($Vc,[2,44]),{20:49,25:130,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{20:49,25:131,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{6:22,7:23,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:$V3,33:16,34:$V4,36:[1,132],77:$V5},o($VO,[2,55],{55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VO,[2,56],{55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VK,[2,57],{58:$Vz}),o($VK,[2,58],{58:$Vz}),o($VK,[2,59],{58:$Vz}),o($VL,[2,60],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),o([26,46,51,60,70,78],[2,62],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),o([26,46,51,60,61,70,78],[2,63],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),o([26,46,51,60,61,62,70,78],[2,64],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),o($VP,[2,65],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VP,[2,66],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VP,[2,67],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VP,[2,68],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VP,[2,69],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VP,[2,70],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz}),o($VJ,[2,53]),o($VJ,[2,71]),{51:[1,133],70:[1,134]},o($VQ,[2,74],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),{26:[1,135]},{26:[1,136]},{20:49,25:137,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},{6:22,7:23,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:[1,138],33:16,34:$V4,77:$V5},o($VR,[2,28]),{6:22,7:23,8:$V0,10:7,11:8,12:9,13:10,14:11,15:12,17:14,18:$V1,19:$V2,20:15,22:5,23:[1,139],28:140,29:96,31:97,33:16,34:$V4,77:$V5},o($VR,[2,30]),{26:[2,48],53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI},{26:[2,49],46:[1,141],53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI},o($Vc,[2,41]),o($VJ,[2,72]),{20:49,25:142,38:$Vj,43:$Vk,48:44,49:45,50:$Vl,52:$Vm,59:$Vn,71:50,72:$Vo,73:$Vp,74:$Vq,75:$Vr,76:$Vs,77:$V5},o($Vt,[2,24]),o($VR,[2,27]),{26:[1,143],53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI},{10:33,17:14,18:$V1,19:$V2,20:15,24:$Vd,27:[1,144],37:$Ve,39:$Vf,40:34,41:35,42:$Vg,45:$Vh,77:$V5},{10:33,17:14,18:$V1,19:$V2,20:15,24:$Vd,27:[1,145],30:$VM,32:$VN,37:$Ve,39:$Vf,40:34,41:35,42:$Vg,45:$Vh,77:$V5},o($Vt,[2,33]),{47:[1,146]},o($VQ,[2,73],{53:$Vu,54:$Vv,55:$Vw,56:$Vx,57:$Vy,58:$Vz,60:$VA,61:$VB,62:$VC,63:$VD,64:$VE,65:$VF,66:$VG,67:$VH,68:$VI}),o($VR,[2,29]),{26:[1,147]},{26:[1,148]},{26:[2,50]},o($Vt,[2,31]),o($Vt,[2,32])],
defaultActions: {21:[2,1],146:[2,50]},
parseError: function parseError (str, hash) {
    if (hash.recoverable) {
        this.trace(str);
    } else {
        var error = new Error(str);
        error.hash = hash;
        throw error;
    }
},
parse: function parse(input) {
    var self = this, stack = [0], tstack = [], vstack = [null], lstack = [], table = this.table, yytext = '', yylineno = 0, yyleng = 0, recovering = 0, TERROR = 2, EOF = 1;
    var args = lstack.slice.call(arguments, 1);
    var lexer = Object.create(this.lexer);
    var sharedState = { yy: {} };
    for (var k in this.yy) {
        if (Object.prototype.hasOwnProperty.call(this.yy, k)) {
            sharedState.yy[k] = this.yy[k];
        }
    }
    lexer.setInput(input, sharedState.yy);
    sharedState.yy.lexer = lexer;
    sharedState.yy.parser = this;
    if (typeof lexer.yylloc == 'undefined') {
        lexer.yylloc = {};
    }
    var yyloc = lexer.yylloc;
    lstack.push(yyloc);
    var ranges = lexer.options && lexer.options.ranges;
    if (typeof sharedState.yy.parseError === 'function') {
        this.parseError = sharedState.yy.parseError;
    } else {
        this.parseError = Object.getPrototypeOf(this).parseError;
    }
    function popStack(n) {
        stack.length = stack.length - 2 * n;
        vstack.length = vstack.length - n;
        lstack.length = lstack.length - n;
    }
    _token_stack:
        var lex = function () {
            var token;
            token = lexer.lex() || EOF;
            if (typeof token !== 'number') {
                token = self.symbols_[token] || token;
            }
            return token;
        };
    var symbol, preErrorSymbol, state, action, a, r, yyval = {}, p, len, newState, expected;
    while (true) {
        state = stack[stack.length - 1];
        if (this.defaultActions[state]) {
            action = this.defaultActions[state];
        } else {
            if (symbol === null || typeof symbol == 'undefined') {
                symbol = lex();
            }
            action = table[state] && table[state][symbol];
        }
                    if (typeof action === 'undefined' || !action.length || !action[0]) {
                var errStr = '';
                expected = [];
                for (p in table[state]) {
                    if (this.terminals_[p] && p > TERROR) {
                        expected.push('\'' + this.terminals_[p] + '\'');
                    }
                }
                if (lexer.showPosition) {
                    errStr = 'Parse error on line ' + (yylineno + 1) + ':\n' + lexer.showPosition() + '\nExpecting ' + expected.join(', ') + ', got \'' + (this.terminals_[symbol] || symbol) + '\'';
                } else {
                    errStr = 'Parse error on line ' + (yylineno + 1) + ': Unexpected ' + (symbol == EOF ? 'end of input' : '\'' + (this.terminals_[symbol] || symbol) + '\'');
                }
                this.parseError(errStr, {
                    text: lexer.match,
                    token: this.terminals_[symbol] || symbol,
                    line: lexer.yylineno,
                    loc: yyloc,
                    expected: expected
                });
            }
        if (action[0] instanceof Array && action.length > 1) {
            throw new Error('Parse Error: multiple actions possible at state: ' + state + ', token: ' + symbol);
        }
        switch (action[0]) {
        case 1:
            stack.push(symbol);
            vstack.push(lexer.yytext);
            lstack.push(lexer.yylloc);
            stack.push(action[1]);
            symbol = null;
            if (!preErrorSymbol) {
                yyleng = lexer.yyleng;
                yytext = lexer.yytext;
                yylineno = lexer.yylineno;
                yyloc = lexer.yylloc;
                if (recovering > 0) {
                    recovering--;
                }
            } else {
                symbol = preErrorSymbol;
                preErrorSymbol = null;
            }
            break;
        case 2:
            len = this.productions_[action[1]][1];
            yyval.$ = vstack[vstack.length - len];
            yyval._$ = {
                first_line: lstack[lstack.length - (len || 1)].first_line,
                last_line: lstack[lstack.length - 1].last_line,
                first_column: lstack[lstack.length - (len || 1)].first_column,
                last_column: lstack[lstack.length - 1].last_column
            };
            if (ranges) {
                yyval._$.range = [
                    lstack[lstack.length - (len || 1)].range[0],
                    lstack[lstack.length - 1].range[1]
                ];
            }
            r = this.performAction.apply(yyval, [
                yytext,
                yyleng,
                yylineno,
                sharedState.yy,
                action[1],
                vstack,
                lstack
            ].concat(args));
            if (typeof r !== 'undefined') {
                return r;
            }
            if (len) {
                stack = stack.slice(0, -1 * len * 2);
                vstack = vstack.slice(0, -1 * len);
                lstack = lstack.slice(0, -1 * len);
            }
            stack.push(this.productions_[action[1]][0]);
            vstack.push(yyval.$);
            lstack.push(yyval._$);
            newState = table[stack[stack.length - 2]][stack[stack.length - 1]];
            stack.push(newState);
            break;
        case 3:
            return true;
        }
    }
    return true;
}};

function Parser() { this.yy = {} };
Parser.prototype = parser;
parser.Parser = Parser;
export {parser, Parser};