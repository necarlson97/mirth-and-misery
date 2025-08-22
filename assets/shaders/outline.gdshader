shader_type canvas_item;

uniform vec4  outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_px    : hint_range(0.0, 64.0) = 4.0;   // screen px

uniform sampler2D noise_tex;
uniform float noise_scale_px : hint_range(200.0, 1000.0) = 500.0; // feature size in screen px
uniform float noise_amp_px   : hint_range(0.0, 32.0)  = 3.0;  // added pixels
uniform vec2  noise_scroll_px = vec2(30.0, -20.0);            // px/sec
uniform float noise_power    : hint_range(0.0, 8.0) = 0.0;
uniform bool  only_grow = true;
uniform bool  debug_show_noise = false; // visualize the noise

const int DIR_COUNT = 16;
const float alpha_cutoff = 0.5;

void fragment() {
    vec4 base = COLOR;
    vec4 out_col = base;

    // screen->UV (for outline marching)
    vec2 dUVdx = dFdx(UV);
    vec2 dUVdy = dFdy(UV);
    mat2 J = mat2(dUVdx, dUVdy);

    // --- screen-space noise coords ---
    // Convert SCREEN_UV (0..1) to pixels, scroll in pixels, then scale to noise tex
    vec2 screen_px = SCREEN_UV / SCREEN_PIXEL_SIZE;
    vec2 n_uv = (screen_px + noise_scroll_px * TIME) / max(noise_scale_px, 1.0);

    // WRAP to 0..1 so we don't clamp
    n_uv = fract(n_uv);

    float n = texture(noise_tex, n_uv).r; // 0..1
    n = n * 2.0 - 1.0;                    // -1..1
    if (noise_power > 0.0) {
        float s = sign(n);
        n = s * pow(abs(n), noise_power);
    }

    float add_px = noise_amp_px * (only_grow ? max(n, 0.0) : n);
    float eff_outline_px = clamp(outline_px + add_px, 0.0, 128.0);

    if (debug_show_noise) {
        // visualize the field in transparent areas
        out_col = vec4(vec3((n * 0.5) + 0.5), base.a < alpha_cutoff ? 1.0 : base.a);
        COLOR = out_col;
    }

    if (eff_outline_px > 0.0 && base.a < alpha_cutoff) {
        for (int i = 0; i < DIR_COUNT; i++) {
            float ang = (6.28318530718 / float(DIR_COUNT)) * float(i);
            vec2 dir_screen = vec2(cos(ang), sin(ang));
            for (float r = 0.5; r <= eff_outline_px; r += 1.0) {
                vec2 uv_offset = (J * dir_screen) * r;
                if (texture(TEXTURE, UV + uv_offset).a >= alpha_cutoff) {
                    out_col = vec4(outline_color.rgb, outline_color.a);
                    i = DIR_COUNT; // break both loops
                    break;
                }
            }
        }
    }

    COLOR = out_col;
}
