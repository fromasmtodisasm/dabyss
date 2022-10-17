module app;

import bindbc.sdl;
import bindbc.opengl;

import std.stdio;
import std.string;

import scene;

extern (System) void glDebugOutput(GLenum source,
	GLenum type,
	GLuint id,
	GLenum severity,
	GLsizei length,
	const char* message,
	const void* userParam) nothrow
{
	import std.conv;

	// ignore non-significant error/warning codes
	static if (false)
	{
		if (id == 13_1169 || id == 13_1185 || id == 13_1218 || id == 13_1204)
			return;

	}

	try
	{
		writeln("---------------");
		writeln("Debug message (" ~ id.to!string ~ "): " ~ message.to!string);

		final switch (source)
		{
		case GL_DEBUG_SOURCE_API:
			writeln("Source: API");
			break;
		case GL_DEBUG_SOURCE_WINDOW_SYSTEM:
			writeln("Source: Window System");
			break;
		case GL_DEBUG_SOURCE_SHADER_COMPILER:
			writeln("Source: Shader Compiler");
			break;
		case GL_DEBUG_SOURCE_THIRD_PARTY:
			writeln("Source: Third Party");
			break;
		case GL_DEBUG_SOURCE_APPLICATION:
			writeln("Source: Application");
			break;
		case GL_DEBUG_SOURCE_OTHER:
			writeln("Source: Other");
			break;
		}

		final switch (type)
		{
		case GL_DEBUG_TYPE_ERROR:
			writeln("Type: Error");
			break;
		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR:
			writeln("Type: Deprecated Behaviour");
			break;
		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:
			writeln("Type: Undefined Behaviour");
			break;
		case GL_DEBUG_TYPE_PORTABILITY:
			writeln("Type: Portability");
			break;
		case GL_DEBUG_TYPE_PERFORMANCE:
			writeln("Type: Performance");
			break;
		case GL_DEBUG_TYPE_MARKER:
			writeln("Type: Marker");
			break;
		case GL_DEBUG_TYPE_PUSH_GROUP:
			writeln("Type: Push Group");
			break;
		case GL_DEBUG_TYPE_POP_GROUP:
			writeln("Type: Pop Group");
			break;
		case GL_DEBUG_TYPE_OTHER:
			writeln("Type: Other");
			break;
		}

		final switch (severity)
		{
		case GL_DEBUG_SEVERITY_HIGH:
			writeln("Severity: high");
			break;
		case GL_DEBUG_SEVERITY_MEDIUM:
			writeln("Severity: medium");
			break;
		case GL_DEBUG_SEVERITY_LOW:
			writeln("Severity: low");
			break;
		case GL_DEBUG_SEVERITY_NOTIFICATION:
			writeln("Severity: notification");
			break;
		}

	}
	catch (Exception e)
	{

	}
}

class ApplicationBase
{
	SDL_Window* window;
	bool bQuit = false;
	this()
	{
		import std.conv;

		writeln("1");

		SDLSupport sdlStatus = loadSDL();
		if (sdlStatus != sdlSupport)
		{
			throw new Exception("Failed loading SDL: " ~ sdlStatus.to!string);
		}

		if (SDL_Init(SDL_INIT_VIDEO) < 0)
			throw new SDLException();

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 6);

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG);

		auto flags = SDL_WINDOW_OPENGL;
		version (reflect_shaders)
		{
			flags |= SDL_WINDOW_HIDDEN;
		}

		window = SDL_CreateWindow("OpenGL 3.2 App", SDL_WINDOWPOS_UNDEFINED,
			SDL_WINDOWPOS_UNDEFINED, 400, 300, flags);
		if (!window)
			throw new SDLException();

		const context = SDL_GL_CreateContext(window);
		if (!context)
			throw new SDLException();

		if (SDL_GL_SetSwapInterval(1) < 0)
			throw new Exception("Failed to set VSync");

		GLSupport glStatus = loadOpenGL();
		if (glStatus < glSupport)
		{
			throw new Exception(
				"Failed loading minimum required OpenGL version: " ~ glStatus.to!string);
		}

		glEnable(GL_DEBUG_OUTPUT);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		glDebugMessageCallback(&glDebugOutput, null);
		glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, GL_TRUE);

	}

	void update()
	{
	}

	void quit()
	{
		bQuit = true;
	}

	void mainLoop()
	{

		SDL_Event event;
		while (!bQuit)
		{
			while (SDL_PollEvent(&event))
			{
				switch (event.type)
				{
				case SDL_QUIT:
					quit();
					break;
				default:
					break;
				}
			}

			update();

			SDL_GL_SwapWindow(window);
		}
	}
}

/// Exception for SDL related issues
class SDLException : Exception
{
	/// Creates an exception from SDL_GetError()
	this(string file = __FILE__, size_t line = __LINE__) nothrow @nogc
	{
		super(cast(string) SDL_GetError().fromStringz, file, line);
	}
}
