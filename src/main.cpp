#define GLFW_INCLUDE_NONE
#include <glad/include/glad.h>
#include <GLFW/glfw3.h>

#include <stdexcept>


void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

int main() {
    if (!glfwInit()) {
        throw std::runtime_error("failed to initialize glfw!");
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(800, 600, "Tetrix", nullptr, nullptr);
    if (!window) {
        throw std::runtime_error("failed to create window!");
    }

    if (!gladLoaderGLLoader((GLADloadproc)glfwGetProcAddress)) {
        throw std::runtime_error("failed to load GLAD");
    }

    glViewport(0, 0, 800, 600);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    while(!glfwWindowShouldClose(window)) {
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}