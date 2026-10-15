import ts from 'typescript';

/** Compile the shared declaration subset; unknown TypeScript syntax fails closed. */
export function buildAgentSessionSchema(declarations, root = 'AgentSessionPatch') {
  const source=ts.createSourceFile('session-patches.d.ts',declarations,ts.ScriptTarget.Latest,true);
  const definitions=new Map(source.statements.filter(node=>ts.isInterfaceDeclaration(node)||ts.isTypeAliasDeclaration(node)).map(node=>[node.name.text,node]));
  const defs={};
  const object=members=>{
    const properties={},required=[];
    for(const member of members){
      if(!ts.isPropertySignature(member)||!member.type||!member.name||(!ts.isIdentifier(member.name)&&!ts.isStringLiteral(member.name))) throw new Error('Unsupported Agent schema member');
      const name=member.name.text;
      properties[name]=convert(member.type);
      if(!member.questionToken)required.push(name);
    }
    return {type:'object',properties,required,additionalProperties:true};
  };
  const reference=name=>{
    if(!Object.hasOwn(defs,name)){
      const node=definitions.get(name);
      if(!node)throw new Error(`Unresolved Agent schema type: ${name}`);
      defs[name]={};
      if(ts.isInterfaceDeclaration(node)){
        if(node.heritageClauses?.length||node.typeParameters?.length)throw new Error('Agent schema inheritance requires review');
        defs[name]=object(node.members);
      }else defs[name]=convert(node.type);
    }
    return {$ref:'#/$defs/'+name};
  };
  const convert=node=>{
    switch(node.kind){
      case ts.SyntaxKind.StringKeyword:return {type:'string'};
      case ts.SyntaxKind.NumberKeyword:return {type:'number'};
      case ts.SyntaxKind.BooleanKeyword:return {type:'boolean'};
      case ts.SyntaxKind.UnknownKeyword:return {};
    }
    if(ts.isLiteralTypeNode(node)){
      if(ts.isStringLiteral(node.literal))return {const:node.literal.text};
      if(ts.isNumericLiteral(node.literal))return {const:Number(node.literal.text)};
      if(node.literal.kind===ts.SyntaxKind.TrueKeyword)return {const:true};
      if(node.literal.kind===ts.SyntaxKind.FalseKeyword)return {const:false};
    }
    if(ts.isArrayTypeNode(node))return {type:'array',items:convert(node.elementType)};
    if(ts.isUnionTypeNode(node))return {anyOf:node.types.map(convert)};
    if(ts.isTypeLiteralNode(node))return object(node.members);
    if(ts.isTypeReferenceNode(node)&&ts.isIdentifier(node.typeName)){
      if(node.typeName.text==='Record' && node.typeArguments?.length===2 && node.typeArguments[0].kind===ts.SyntaxKind.StringKeyword)return {type:'object',additionalProperties:convert(node.typeArguments[1])};
      if(!node.typeArguments?.length)return reference(node.typeName.text);
    }
    throw new Error(`Unsupported Agent schema syntax: ${node.getText(source)}`);
  };
  return {...reference(root),$defs:defs};
}
