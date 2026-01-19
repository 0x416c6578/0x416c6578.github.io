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

- C++ offers parallel algorithms, this task and data parallelism splits tasks across cores and divides arrays into chunks that are processed in parallel
- To make our above example parallelised, we can pass in `std::execution::par` into the first parameter in `std::reduce` - this is a directive to say "parallelise this if you can"
  - The task scheduler maps tasks to execution resources, deferring to a platform runtime like MSVC or libraries like TBB/OpenMP, details are implementation specific
  - It hints to the library that this loop can be executed out of order
  - In this case this is fine since the default behaviour of `reduce` is to `+` which is associative, but for non associative operations more care must be taken

### HPX
- HPX is a library that enhances the standard library with extra features

```cpp
// ...
hpx::execution::experimental::num_cores nc(2);
auto sum = hpx::reduce(hpx::execution::par.with(nc), data.begin(), data.end())
// ...
```

- In this example only two cores are used for parallelisation

### Equality vs Ordering
- Say we wanted to find the number of unique elements in a vector of numbers
- The canonical way is to use a set, however this is quite inefficient since set is implemented using RB trees, which despite being `O(nlogn)`, has a large constant coefficient
  - This is because the data structure has to be re-sorted for each insertion worst case
- Equality vs sorting - it seems like finding unique elems doesn't require ordering, only equality
  - However equality gives us `O(n)` search (going down the list and checking each element) whereas sorting gives us `O(logn)` binary search which is more efficient
- `std::unique` is a better solution - it removes consecutively equal elements from a range in place and returns an iterator to the new logical end
  - You need to sort first to get the solution to the problem at hand, but in practice this is more efficient than using a set since we only sort once, then `std::unique` is `O(n)` 
- For high performance computing, vectors (arrays) are the only real valid data structure; any others tend to have worse performance
  - This is because arrays can best utilise spacial locality of elements - elements will be cached and the nature of arrays means we are likely to use those cached values in the future rather than chasing pointers in different areas of memory
