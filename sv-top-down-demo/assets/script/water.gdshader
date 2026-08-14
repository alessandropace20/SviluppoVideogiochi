shader_type canvas_item;

// We'll use a screen texture to render-what is underwater
uniform sampler2D screen_texture: hint_screen_texture;

// A noise texture will be used to apply the distortion effect
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

// Speed of the water waves
uniform vec2 speed = vec2(0.5,0.2);
// Wave Strenght
uniform float wave_strength = 0.0;

// Strength of the distortion effect uniform float distortion•= 0.01;
uniform float distortion = 0.001;

// Called for every vertex the material is visible on.
void vertex () {

}

// Called for every pixel the material is visible on.
void fragment () {
	// Change the UV over time to make the water-move
	vec2 uv = UV + speed * TIME;
	// Get a noise value in the [-1, 1] range
	vec2 noise = 2.0 * texture(noise_texture, uv). rg - vec2(1.0);
	//Sample the water texture
	COLOR = texture (TEXTURE, UV + noise * wave_strength);
	// Multinly the color with the screen texture
	COLOR *= texture(screen_texture, SCREEN_UV + noise * distortion);
}