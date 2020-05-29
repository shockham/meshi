#version 400

uniform mat4 projection_matrix;
uniform mat4 modelview_matrix;
uniform sampler2D tex;

layout(triangles, equal_spacing, ccw) in;

in vec3 tc_normal[];
in vec2 tc_texture[];

out vec3 te_normal;
out vec3 te_pos;
out vec2 te_texture;

vec3 tess_calc (vec3 one, vec3 two, vec3 three) {
    return ((gl_TessCoord.x) * one) +
                    ((gl_TessCoord.y) * two) +
                    ((gl_TessCoord.z) * three);
}

vec2 tex_calc (vec2 one, vec2 two, vec2 three) {
    return ((gl_TessCoord.x) * one) +
                    ((gl_TessCoord.y) * two) +
                    ((gl_TessCoord.z) * three);
}

void main () {
    te_normal = tess_calc(tc_normal[0], tc_normal[1], tc_normal[2]);

    vec3 position = tess_calc(gl_in[0].gl_Position.xyz,
        gl_in[1].gl_Position.xyz,
        gl_in[2].gl_Position.xyz);

    vec2 tex_pos = tex_calc(tc_texture[0], tc_texture[1], tc_texture[2]);

    float col_offset = length(texture(tex, tex_pos)) * 2;

    position += vec3(0, 0, col_offset);
    te_pos = position;
    te_texture = tex_pos;
    gl_Position = projection_matrix *
        modelview_matrix *
        vec4(position, 1.0);
}
