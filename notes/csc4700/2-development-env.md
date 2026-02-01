## Development Environment and C++ Basics (Lecture 2)
- C++ is of course a compiled language
- The compilation first makes an *object* file, which is then *linked* to shared libraries
- CMake is commonly used to remove a lot of the boilerplate required for compiling C++ programs
  - It is used to generate makefiles to automatically build and test code
- `CMakeLists.txt` is where you would store your build script

```cmake
cmake_minimum_required(VERSION 3.0)
project(Demo1)
add_executable(Demo1 demo1.cpp)
```

- Above is a minimal working example for a demo project
- CMake will generate makefiles that you can run with `make`

### Namespaces
- Namespaces provide a scope to the identifiers (types, functions, variables etc.) inside it; used to organise code into logical groupings and prevent naming collisions

```cpp
namespace someNamespace {
  double value = 3.14;
}

int main() {
  std::print("Value: {}", someNamespace::value)
  return 0
}
```

- You can also specify `using namespace someNamespace` to make everything in that namespace appear as if it was in the global namespace, helpful to remove syntactic cluttering
- C++ has pass by value semantics by default, we can make it pass by reference by using `&`, e.g. `double sqrt(double& y)`
  - We can use `double const& y` to promise that the argument isn't changed
