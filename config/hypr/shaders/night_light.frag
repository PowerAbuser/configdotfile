#version 300 es
// Night light: a warm screen, roughly 4000 K. Toggled by
// ~/.config/quickshell/utils/night-light.sh; confs/decoration.lua applies it.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    fragColor = vec4(c.r, c.g * 0.82, c.b * 0.58, c.a);
}
