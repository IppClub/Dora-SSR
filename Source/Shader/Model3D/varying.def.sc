vec3 a_position : POSITION;
vec3 a_normal : NORMAL;
vec4 a_tangent : TANGENT;
vec2 a_texcoord0 : TEXCOORD0;
vec2 a_texcoord1 : TEXCOORD1;
vec4 a_color0 : COLOR0;
vec4 a_indices : BLENDINDICES;
vec4 a_weight : BLENDWEIGHT;

vec4 v_color0 : COLOR0 = vec4(1.0, 1.0, 1.0, 1.0);
vec4 v_texcoord01 : TEXCOORD0 = vec4(0.0, 0.0, 0.0, 0.0);
vec4 v_worldPos : TEXCOORD1 = vec4(0.0, 0.0, 0.0, 1.0);
vec4 v_worldNormal : TEXCOORD2 = vec4(0.0, 1.0, 0.0, 0.0);
vec4 v_worldTangent : TEXCOORD3 = vec4(1.0, 0.0, 0.0, 1.0);
