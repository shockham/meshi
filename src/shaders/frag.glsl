#version 330

#define M_PI 3.1415926535897932384626433832795

uniform float time;
uniform vec3 cam_pos;
uniform sampler2D tex;
uniform sampler2D normal_tex;
uniform sampler1D dir_lights;

in vec3 g_normal;
in vec3 g_pos;
in vec2 g_texture;
in vec2 g_diff;

out vec4 frag_output;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    int size = textureSize(dir_lights, 0);
    float lum = 0.0;
    float tex_lum = 0.0;
    for (int i = 0; i < size; i++) {
        vec3 light_norm = normalize(texture(dir_lights, i).xyz);
        lum += max(dot(normalize(g_normal), light_norm), 0.0);
        tex_lum += dot(normalize(vec3(texture(normal_tex, g_texture))), light_norm);
    }

    float avg_lum = (lum + tex_lum) / 2.0;

    float dist = abs(distance(cam_pos, g_pos)) / 80.0;

    float smoothed_diff = 1.0 - (
        smoothstep(0, 1, cos(g_diff.x * 1.5 * M_PI) + cos(g_diff.y * 1.5 * M_PI))
        * 0.1
    );
    float noise = smoothstep(0.0, 0.2, rand(g_pos.xy));

    vec4 lighting_col = vec4(vec3((0.6 * avg_lum) + (0.4 * dist)), 1.0);

    vec4 tex_col = texture(tex, g_texture);

    frag_output = vec4(tex_col.rgb * noise * smoothed_diff, tex_col.a) * lighting_col;
}
