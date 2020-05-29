#version 400

layout(vertices = 3) out;

in vec3 v_normal[];
in vec2 v_texture[];

out vec3 tc_normal[];
out vec2 tc_texture[];

uniform vec3 cam_pos;
const float outer = 1.0;
const float inner_range = 100.0;

void main() {
    tc_normal[gl_InvocationID] = v_normal[gl_InvocationID];
    tc_texture[gl_InvocationID] = v_texture[gl_InvocationID];
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    float dist = abs(distance(cam_pos, vec3(gl_in[gl_InvocationID].gl_Position)));
    float dist_t =
        (step(dist, inner_range) * (((inner_range - dist) / inner_range) * 10.0));

    float d_01 = distance(gl_out[0].gl_Position, gl_out[1].gl_Position);
    float d_02 = distance(gl_out[0].gl_Position, gl_out[2].gl_Position);
    float d_12 = distance(gl_out[1].gl_Position, gl_out[2].gl_Position);
    float spacing_t = max(d_01, max(d_02, d_12)) / 0.22;

    float inner_t = (dist_t + spacing_t) / 2.0;

    gl_TessLevelOuter[0] = outer;
    gl_TessLevelOuter[1] = outer;
    gl_TessLevelOuter[2] = outer;
    gl_TessLevelInner[0] = inner_t;
}
