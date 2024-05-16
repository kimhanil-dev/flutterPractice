#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;
precision highp sampler2D;



out vec4 out_color;

uniform vec2 uSize;
uniform float uProgress;
uniform float uSmoothness;
uniform sampler2D uImage;
uniform sampler2D uFade;

void main(){

    vec2 uv =  FlutterFragCoord().xy / uSize;
    vec4 fadeColor = texture(uFade, uv);
    vec4 color = texture(uImage,uv);
    fadeColor = smoothstep(uProgress,uProgress + uSmoothness,fadeColor);
    
    out_color = color * fadeColor;
}