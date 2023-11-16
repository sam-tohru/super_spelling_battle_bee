shader_type canvas_item;

uniform vec4 color: source_color;
uniform float amt:hint_range(0.0, 1.0);

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV) * color;
	
	if (distance(UV, vec2(0.5,0.5)) > amt/1.0)
	{
		COLOR = vec4(0.0);
	}
	else
	{
		COLOR = pixelColor;
	}
	
	// COLOR = pixelColor;
}