shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength: hint_range(0.0, 10, 0.1) = 2.0;
uniform sampler2D NOISE_TEXTURE : filter_linear_mipmap ;
varying vec2 pos;

// Nvm, overcomplicated ,only needed a wayyyyy simpler shader


void fragment() {
	float noise_color = texture(NOISE_TEXTURE, SCREEN_UV).r;
	vec4 color2= textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.3);
	vec4 color1 = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_strength*(1.0-noise_color)*3.0);

	
	
	COLOR = mix(color1, color2, 0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
