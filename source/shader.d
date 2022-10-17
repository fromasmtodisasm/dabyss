module shader;

import bindbc.opengl;
import std.string;
import std.algorithm.iteration : map;
import std.file : readText;

import math;

class GlObject
{
    GLuint id;
}

class ShaderSource
{
    string text;
    string path;
    this(string path)
    {
        this.path = path;
        text = readText(path);
    }
}

class Shader : GlObject
{
    enum Stage
    {
        Vertex,
        Pixel,
        Compute
    }

    class CreateException : Exception
    {
        this(string why)
        {
            super(msg);
        }
    }

    this(string[] source, uint type)
    {
        import std.conv, std.stdio;

        // compile shaders

        int infoLogLength;
        int result;
        id = glCreateShader(type);
        //auto strings = stringize(source);
        const(char*)[] strings;
        alias stringize = map!(a => strings ~= a.toStringz);

        foreach (s; source)
        {
            strings ~= s.toStringz;
            //writeln(s);

        }

        foreach (const(char*) str; strings)
        {
            writeln(str);
        }

        glShaderSource(id, cast(int) strings.length, strings.ptr, null);
        glCompileShader(id);
        glGetShaderiv(id, GL_COMPILE_STATUS, &result);
        glGetShaderiv(id, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char* errorMessage;
            glGetShaderInfoLog(id, infoLogLength, null, errorMessage);
            throw new CreateException(errorMessage[0 .. infoLogLength].to!string);
        }
    }
}

class ShaderProgram : GlObject
{
    import std.stdio;

    class CreateException : Exception
    {
        this(string why)
        {
            super(msg);
        }
    }

    this(ShaderSource source)
    {
        this(source.text);
    }

    this(string source)
    {
        //auto source = readText(format("views/%s.glsl", shader)) /*.toStringz*/ ;
        auto vertexShader = new Shader([
            "#version 330 core\n", "#define __VERTEX__\n", source
        ], GL_VERTEX_SHADER);
        auto fragmentShader = new Shader([
            "#version 330 core\n", "#define __PIXEL__\n", source
        ], GL_FRAGMENT_SHADER);

        // link shaders
        int result;
        int infoLogLength;
        id = glCreateProgram();
        glAttachShader(id, vertexShader.id);
        glAttachShader(id, fragmentShader.id);
        glLinkProgram(id);
        glGetProgramiv(id, GL_LINK_STATUS, &result);
        glGetProgramiv(id, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            import std.conv;

            char* errorMessage;
            glGetProgramInfoLog(id, infoLogLength, null, errorMessage);
            writeln(errorMessage[0 .. infoLogLength].to!string);
            throw new CreateException(errorMessage[0 .. infoLogLength].to!string);
        }

        // Delete unused compiled shaders because program is linked already
        glDetachShader(id, vertexShader.id);
        glDetachShader(id, fragmentShader.id);

        glDeleteShader(vertexShader.id);
        glDeleteShader(fragmentShader.id);

    }

    ~this()
    {
        glDeleteProgram(id);
    }

    void use()
    {
        glUseProgram(id);
    }

}

class ShaderManager
{
    ShaderProgram[string] programs;
}

string underscoresToCamelCase(string str)
{
    import std.uni;

    return str.toUpper;
}

class ShaderParameters
{
    import std.stdio;

    auto opDispatch(string m, Args...)(Args args)
    {
        static if (args.length == 0)
            print("test");
        return mixin("this." ~ underscoresToCamelCase(m) ~ "(args)");
    }

    int DOSOMETHINGCOOL(int x, int у)
    {
        writeln("123");
        return 0;
    }

    int t()
    {
        return 1234;
    }
}

unittest
{
    import std.stdio;

    auto a = new ShaderParameters();
    a.dosomethingcool(1, 1);
    writeln(a.t);
}
