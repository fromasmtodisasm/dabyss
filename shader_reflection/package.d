module shader_reflection;

import app;
public import shader_reflection.reflection;

class Application : ApplicationBase
{
    Reflector reflector;
    this(string[] args)
    {
        super();
        reflector  = new Reflector(args);
    }

    override void update()
    {
    }

    void start()
    {
        reflector.process();
    }
}

import shader_reflection;
