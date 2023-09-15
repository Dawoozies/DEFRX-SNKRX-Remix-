vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  return vec4(0.05, 0.05, 0.05, Texel(texture, tc).a*0.5);
}
