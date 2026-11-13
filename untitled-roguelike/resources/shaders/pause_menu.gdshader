shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength: hint_range(0.0, 10, 0.1) = 2.0;


// Nvm, overcomplicated ,only needed a wayyyyy simpler shader


void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_strength);
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
