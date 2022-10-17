module scene;

import render;
import std.stdio;

class Scene
{
    //dfmt on

    string name;
    RenderNode[] nodes;

    this(string name)
    {
        this.name = name;
    }

    ~this()
    {
        unload();
    }

    void load()
    {
        auto obj = cast(RenderObject)createNode(RenderNodeType.Object);
        
        nodes ~= obj;

        obj.load("test");
    }

    void unload()
    {
    }

    void render()
    {
        import bindbc.opengl;

        glClear(GL_COLOR_BUFFER_BIT);

        foreach (RenderNode node; nodes)
        {
            node.render();
        }
    }

    ////////////////////

    RenderNode createNode(RenderNodeType type)
    {
        switch (type)
        {
        case RenderNodeType.Object:
            return new RenderObject;
        default:
            assert(0);
        }
    }
}
