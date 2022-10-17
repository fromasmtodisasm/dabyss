module main;

import app;
import scene;

version (reflect_shaders)
{
    import shader_reflection;

    int main(string[] args)
    {

        auto app = new Application(args);

        app.start();
        return 0;
    }

}
else
{
    class Application : ApplicationBase
    {
        Scene scene;
        this()
        {
            super();
            scene = new Scene("test_scene");
            scene.load();
        }

        override void update()
        {
            scene.render();
        }
    }

    int main(string[] args)
    {

        auto app = new Application;

        app.mainLoop();
        return 0;
    }

}
