## Introduction (Lecture 1)
- High performance computing works mainly with the array data structure
- Algorithmic thinking is required to solve problems, but parallelisation is almost an afterthought if the algorithms are designed and implemented well

### CPUs
- At a high level, CPUs fetch -> decode -> read memory -> execute -> write memory
- Modern CPUs have many optimisations to improve performance, e.g. pipelining, OOO execution etc.
- Caches were introduced to store memory speculatively - if we store some memory after the address we are requesting, there is a high chance our program has some sequential memory access pattern that will result in a cache hit
- Multicore CPUs were created to allow hardware parallelisation
  - More cores now share slow memory, caches need to be kept coherent between cores (false sharing problem)
- SMP (symmetric multi processor) - having multiple physically processor chips on a board
  - UMA (uniform memory access) for SMP - this means all processors share the same memory
- Asymmetric multi-processor was introduced to remedy this
  - Now each CPU socket has its own memory, they can access memory of other processors however there is a bigger latency cost for this

### First C++ Program
```cpp
#include <algorithm>
#include <print>
#include <vector>

int main() {
    std::vector<double> data = {1.0,2.0,3.0,4.0};
    // Default behaviour of reduce is to "+", however that is defined for your data type
    auto sum = std::reduce(data.begin(), data.end());
    std::print(std::stdout, "Sum: {}\n", sum);
    return 0;
}
```
