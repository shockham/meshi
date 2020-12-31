#version 330

uniform vec2 viewport;
uniform sampler2D tex;
const float SIZE = 0.26;
const float ROUNDING = 0.7;

layout(triangles) in;
layout(triangle_strip, max_vertices=24) out;

in vec3 te_normal[];
in vec3 te_pos[];
in vec2 te_texture[];

out vec3 g_normal;
out vec3 g_pos;
out vec2 g_texture;

void emit (int i, vec4 diff) {
    g_normal = te_normal[i];
    g_pos = te_pos[i] + diff.xyz;
    g_texture = te_texture[i];
    gl_Position = gl_in[i].gl_Position + diff;
    EmitVertex();
}

void prim (int i, float x, float y, vec4 col) {
    float s_x = x * ROUNDING;
    float s_y = y * ROUNDING;

    emit(i, vec4(0));
    emit(i, vec4(x, 0, 0, 0));
    emit(i, vec4(s_x, s_y, 0, 0));
    EndPrimitive();

    emit(i, vec4(0));
    emit(i, vec4(s_x, s_y, 0, 0));
    emit(i, vec4(0, y, 0, 0));
    EndPrimitive();
}

void i_prim (int i, float x, float y, vec4 col) {
    float s_x = x * ROUNDING;
    float s_y = y * ROUNDING;

    emit(i, vec4(s_x, s_y, 0, 0));
    emit(i, vec4(x, 0, 0, 0));
    emit(i, vec4(0));
    EndPrimitive();

    emit(i, vec4(0, y, 0, 0));
    emit(i, vec4(s_x, s_y, 0, 0));
    emit(i, vec4(0));
    EndPrimitive();
}

void main(void) {
    float vy_size = SIZE * (viewport.x / viewport.y);

    for(int i = 0; i < gl_in.length(); i++){
        vec4 col = texture(tex, te_texture[i]);

        float x_size = SIZE * (length(col.xy) * 0.4 + 0.8);
        vy_size *= length(col.yz) * 0.4 + 0.8;

        prim(i, x_size, vy_size, col);
        i_prim(i, -x_size, vy_size, col);
        i_prim(i, x_size, -vy_size, col);
        prim(i, -x_size, -vy_size, col);
    }
}
