module shader_reflection.reflection;

import std.conv : to;
import std.getopt;
import std.json;
import std.path;
import std.stdio;
import std.format;

import shader;
import bindbc.opengl;

struct Uniform
{
    char[] name;
    uint type;
    uint location;
}

struct ProgramInterface
{
    Uniform[] uniforms;
}

struct ReflectedShader
{
    ProgramInterface programInterface;
}

class Reflector
{
    string root;
    this(string[] args)
    {
        auto helpInformation = getopt(args,
            "shaders", &root
        );
        if (helpInformation.helpWanted)
        {
            defaultGetoptPrinter("Shader reflector.",
                helpInformation.options);
        }
    }

    void process()
    {
        import std.file;

        auto desc = root ~ "/shaders.json";
        if (desc.exists)
        {
            writeln("Processing shaders...");

            auto descStr = readText(desc);
            JSONValue j = parseJSON(descStr);

            ReflectedShader[string] reflectedShaders;

            foreach (shader; j["shaders"].array)
            {
                auto name = shader["name"].get!string;
                writeln("Parse " ~ name);
                auto program = loadProgram(name);
                auto prog = program.id;

                //GL_PROGRAM_INPUT
                ReflectedShader reflectedShader;
                {
                    auto programInterfaces = [
                        GL_UNIFORM,
                        GL_UNIFORM_BLOCK,
                        GL_ATOMIC_COUNTER_BUFFER,
                        GL_PROGRAM_INPUT

                    ];

                    foreach (key; programInterfaces)
                    {
                        GLint numResources = 0;
                        //auto interfaceParams = [

                        //];
                        glGetProgramInterfaceiv(prog, key, GL_ACTIVE_RESOURCES, &numResources);
                        switch (key)
                        {
                        case GL_UNIFORM:
                            {
                                auto properties = [
                                    GL_BLOCK_INDEX, GL_TYPE, GL_NAME_LENGTH,
                                    GL_LOCATION
                                ];

                                for (int unif = 0; unif < numResources; ++unif)
                                {
                                    GLint[4] values;
                                    Uniform uniform; //reflectedShader.programInterface.uniforms;
                                    glGetProgramResourceiv(prog,
                                        GL_UNIFORM,
                                        unif,
                                        cast(int) values.length,
                                        properties.ptr,
                                        cast(int) properties.length,
                                        null, values.ptr
                                    );

                                    // Skip any uniforms that are in a block.
                                    if (values[0] != -1)
                                        continue;

                                    // Get the name. Must use a std::vector rather than a std::string for C++03 standards issues.
                                    // C++11 would let you use a std::string directly.
                                    uniform.name.length = values[2];
                                    glGetProgramResourceName(
                                        prog,
                                        GL_UNIFORM,
                                        unif,
                                        cast(int) uniform.name.length,
                                        null,
                                        uniform.name.ptr
                                    );
                                    reflectedShader.programInterface.uniforms ~= uniform;
                                    //writeln("uniform layout(location = %d) %s;".format(values[3], uniformName));
                                }

                            }
                            break;

                        case GL_UNIFORM_BLOCK:
                            {

                            }
                            break;
                        case GL_ATOMIC_COUNTER_BUFFER:
                            {

                            }
                            break;
                        case GL_PROGRAM_INPUT:
                            {

                            }
                            break;

                        default:
                            assert(0);
                        }
                    }

                }

                reflectedShaders[name] = reflectedShader;
            }
            foreach (shaderName, shader; reflectedShaders)
            {
                writeln("Interface for %s shader".format(shaderName));

                

                foreach (uniform; shader.programInterface.uniforms)
                {
                    writeln("\tuniform layout(location = %d) %s;".format(uniform.location, uniform
                            .name));
                }
            }

            throw new Exception("Force stop");
        }
        else
        {
            throw new Exception(desc ~ " do not exists");
        }

    }

    ShaderProgram loadProgram(string shaderPath)
    {
        return new ShaderProgram(new ShaderSource(buildPath(root, shaderPath).setExtension("glsl")));
    }
    //GL_PROGRAM_INPUT
}
