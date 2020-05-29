use caper::game::Game;
use caper::shader::{default, texture};
use caper::types::DefaultTag;

pub fn add_custom_shaders(game: &mut Game<DefaultTag>) {
    let shaders = &mut game.renderer.shaders;
    let display = &game.renderer.display;

    let _ = shaders.add_shader(
        display,
        "points",
        default::gl330::VERT,
        texture::gl330::FRAG,
        points::GEOM,
        points::TESS_CONTROL,
        points::TESS_EVAL,
    );
}

mod points {
    /// tessellation control shader
    pub const TESS_CONTROL: &'static str = include_str!("./tess_control.glsl");
    /// tessellation evaluation shader
    pub const TESS_EVAL: &'static str = include_str!("./tess_eval.glsl");
    /// geometry shader
    pub const GEOM: &'static str = include_str!("./geom.glsl");
}
