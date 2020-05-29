mod shaders;

use caper::types::{RenderItemBuilder, TransformBuilder, MaterialBuilder, DefaultTag};
use caper::game::*;
use caper::imgui::Ui;
use caper::input::Key;
use caper::mesh::{gen_sphere, gen_quad};
use caper::posteffect::PostShaderOptionsBuilder;
use caper::utils::handle_fp_inputs;
use caper::load_texture;


fn main() {
    let (mut game, event_loop) = Game::<DefaultTag>::new();
    let mut debug_mode = false;

    // initial setup
    {
        shaders::add_custom_shaders(&mut game);

        game.renderer.post_effect.post_shader_options = PostShaderOptionsBuilder::default()
            .chrom_amt(1f32)
            .blur_amt(2f32)
            .blur_radius(2f32)
            .bokeh(true)
            .bokeh_focal_depth(0.45f32)
            .bokeh_focal_width(0.4f32)
            .color_offset((1f32, 1f32, 1f32, 1f32))
            .build()
            .unwrap();

        game.renderer.shaders.textures.insert(
            "wil",
            load_texture!("../assets/wil.png", &game.renderer.display)
        );
        game.renderer.shaders.textures.insert(
            "jqa",
            load_texture!("../assets/junior_qa.png", &game.renderer.display)
        );
        game.renderer.shaders.textures.insert(
            "pete",
            load_texture!("../assets/petey.png", &game.renderer.display)
        );

        game.renderer
            .lighting
            .add_directional_light("one".to_string(), (-0.2, 0.8, 0.1));
        game.renderer
            .lighting
            .add_directional_light("two".to_string(), (1.0, 0.0, 0.0));
        game.renderer
            .lighting
            .add_directional_light("three".to_string(), (0.0, 1.0, 0.0));
    }

    // create a vector of render items
    game.add_render_item(
        RenderItemBuilder::default()
            .vertices(gen_sphere())
            .material(
                MaterialBuilder::default()
                    .shader_name("points".to_string())
                    .texture_name(Some("jqa".to_string()))
                    .build()
                    .unwrap(),
            )
            .instance_transforms(vec![
                TransformBuilder::default()
                    .pos((0f32, 0f32, 0f32))
                    .rot((0f32, 0f32, 0f32, 1f32))
                    .scale((5f32, 5f32, 5f32))
                    .build()
                    .unwrap(),
            ])
            .build()
            .unwrap(),
    );
    game.add_render_item(
        RenderItemBuilder::default()
            .vertices(gen_quad())
            .material(
                MaterialBuilder::default()
                    .shader_name("points".to_string())
                    .texture_name(Some("wil".to_string()))
                    .build()
                    .unwrap(),
            )
            .instance_transforms(vec![
                TransformBuilder::default()
                    .pos((0f32, 10f32, 0f32))
                    .rot((0f32, 0f32, 0f32, 1f32))
                    .scale((10f32, 10f32, 1f32))
                    .build()
                    .unwrap(),
            ])
            .build()
            .unwrap(),
    );

    // run the engine update
    start_loop(event_loop, move |events| {
        game.update(
            |_: &Ui| {},
            |game: &mut Game<DefaultTag>| -> UpdateStatus {

                // update the first person inputs
                if game.input.hide_mouse {
                    handle_fp_inputs(&mut game.input, &mut game.cams[0]);
                }

                // screenshot
                if game.input.keys_pressed.contains(&Key::P) {
                    game.renderer.save_screenshot();
                }

                // editor shortcuts
                if game.input.keys_down.contains(&Key::LShift) {
                    if game.input.keys_down.contains(&Key::L) {
                        debug_mode = true;
                    }
                    if game.input.keys_down.contains(&Key::K) {
                        debug_mode = false;
                    }
                    game.input.hide_mouse = !game.input.keys_down.contains(&Key::M);
                }
                game.renderer.show_editor = debug_mode;

                // quit
                if game.input.keys_down.contains(&Key::Escape) {
                    return UpdateStatus::Finish;
                }

                UpdateStatus::Continue
            },
            events,
        )
    });
}
