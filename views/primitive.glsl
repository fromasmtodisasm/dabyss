// @
#ifdef __VERTEX__

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_color;

uniform vec3 u_color;
uniform vec3 u_1;
uniform vec3 u_2;

out vec3 color;

void main() {
	gl_Position = vec4(in_position, 1);
	color = in_color + u_color + u_1 + u_2;
}

#endif

#ifdef __PIXEL__

in vec3 color;
out vec3 out_color;

void main() {
  out_color = color;
}

#endif