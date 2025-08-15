shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_px : hint_range(0.0, 32.0) = 2.0;   // thickness (in texture pixels)

// 16 evenly spaced directions around the unit circle
const int DIR_COUNT = 16;
const float alpha_cutoff = 0.5;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    vec4 out_col = base;

    if (outline_px > 0.0 && base.a < alpha_cutoff) {
        vec2 texel = TEXTURE_PIXEL_SIZE;

        // Find min radius (in pixels) to a solid neighbor in any direction
        float min_r = 1e9;

        for (int i = 0; i < DIR_COUNT; i++) {
            float ang = (6.28318530718 / float(DIR_COUNT)) * float(i);
            vec2 dir = vec2(cos(ang), sin(ang));

            // march outward up to outline_px
            // start at 0.5 so we sample “between” texels nicely
            for (float r = 0.5; r <= outline_px; r += 1.0) {
                float a = texture(TEXTURE, UV + dir * texel * r).a;
                if (a >= alpha_cutoff) {
                    if (r < min_r) min_r = r;
                    break;
                }
            }
        }

        if (min_r < 1e9) {
            out_col = vec4(outline_color.rgb, outline_color.a);
        }
    }

    COLOR = out_col;
}
