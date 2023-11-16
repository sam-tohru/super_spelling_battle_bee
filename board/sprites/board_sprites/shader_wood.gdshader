shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV) * color;
	
	COLOR = pixelColor;
}
