module render;

import bindbc.opengl;
import shader;

enum RenderNodeType
{
    Object,
    Decal,
    Water,
    Sky,
    Terrain
}

class RenderNode
{
    RenderNodeType type;
    string name;

    //glm::vec3 position;
    //glm::vec3 rotation;
    //glm::vec3 scale;

    RenderNode parent;
    RenderNode[] children;

    void render()
    {
    }
}

class Buffer
{

}

class RenderMesh
{
    GLuint vertexBuffer;
    GLuint colorBuffer;
    ShaderProgram testShader;
    GLuint vertexArrayID;

    ~this()
    {
        unload();
    }

    bool load(string path)
    {
        //dfmt off
        const float[] vertexBufferPositions = [
            -0.5f, -0.5f, 0,
            0.5f, -0.5f, 0,
            0, 0.5f, 0
        ];
        const float[] vertexBufferColors = [
            1, 0, 0,
            0, 1, 0,
            0, 0, 1
        ];

        // create OpenGL buffers for vertex position and color data
        glGenVertexArrays(1, &vertexArrayID);
        glBindVertexArray(vertexArrayID);

        // load position data
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferPositions.length,
            vertexBufferPositions.ptr, GL_STATIC_DRAW);

        // load color data
        glGenBuffers(1, &colorBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferColors.length,
            vertexBufferColors.ptr, GL_STATIC_DRAW);

        testShader = new ShaderProgram("primitive");

        return true;
    }

    void unload()
    {
        glDeleteBuffers(1, &vertexBuffer);
        glDeleteBuffers(1, &colorBuffer);
        glDeleteVertexArrays(1, &vertexArrayID);
    }

    void render()
    {
        testShader.use();

        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glVertexAttribPointer(0, // attribute 0. No particular reason for 0, but must match the layout in the shader.
            3, // size
            GL_FLOAT, // type
            false, // normalized?
            0, // stride
            null  // array buffer offset

            

        );
        glEnableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
        glVertexAttribPointer(1, // attribute 1
            3, // size
            GL_FLOAT, // type
            false, // normalized?
            0, // stride
            null  // array buffer offset

            

        );
        // Draw the triangle!
        glDrawArrays(GL_TRIANGLES, 0, 3); // Starting from vertex 0; 3 vertices total -> 1 triangle
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);

    }
}

class RenderObject : RenderNode
{
    RenderMesh mesh = new RenderMesh;
    bool load(string path)
    {
        return mesh.load(path);
    }

    override void render() 
    {
        mesh.render();
    }
}
