shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

/**
 * How blurry the result should be. Limited to 20 because of performance.
 */
uniform float strength : hint_range(1.0, 20.0) = 5.0;

/**
 * How dark the blur will be.
 */
uniform float mix_percentage : hint_range(0.0, 1.0) = 0.5;

float gaussian_distribution(float x, float STD) { // STD stands for standard deviation.
        return exp(-(x * x) / (2.0 * STD * STD)) / (sqrt(2.0 * PI) * STD);
}

vec3 gaussian_blur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigma_used, int radius) {
        vec3 blurred_pixel = vec3(0.0);
        float total_weight = 0.0;

        // Loop over the radius (tecnically its a square).
        for (int i = -radius; i <= radius; i++) {
                for (int j = -radius; j <= radius; j++) {
                        // Calculate the offset from the current pixel.
                        vec2 offset = vec2(float(i), float(j)) * pixel_size;
                        vec2 changed_pos = pos + offset;

                        // Calculate the weight based on the Gaussian distribution multiplying both
                        // dimentions (how far are X and Y form the center (pos)).
                        float weight = gaussian_distribution(
                                float(i), sigma_used) * gaussian_distribution(float(j), sigma_used);

                        // Add the weighted color value to the blurred pixel
                        blurred_pixel += texture(SCREEN_TEXTURE, changed_pos).rgb * weight;
                        total_weight += weight;
                }
        }

        // Normalize the blurred pixel color by the total weight.
        blurred_pixel /= total_weight;
        return blurred_pixel;
}

void fragment() {
        vec3 blurred_pixel = gaussian_blur(
                SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE,
                strength, int(round(3.0 * strength)));
        vec3 color = mix(blurred_pixel, vec3(0.0), mix_percentage);

        // The radius is 3 * strength because it is the point where the Gaussian weight is near zero.
        COLOR = vec4(color, 1.0);
}
