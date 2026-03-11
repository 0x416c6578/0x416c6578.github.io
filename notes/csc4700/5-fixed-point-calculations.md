## Fixed Point Calculations and Finding Roots
### Fixed Points
- `c` is a fixed point in a function `f` if
  - `c` belongs to the domain and codomain of `f`
  - `f(c) = c`
  - The function returns the same value of its argument
- This can be calcuated by iterating a number of times and looking for convergence
- We can interpret this as ƒinding the intercept with `y=x`

<figure>
<img loading="lazy" width="500" src="../../Images/csc4700/fixed-point-graph.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Example of fixed point of cosx
</figcaption>
</figure>

```cpp
double fixed_point(double f(double), int max_it, double init) {
  double x = init;
  for (int i = 0; i < max_it; i++) 
    x = f(x);
  return x;
}
```

- The code above shows a higher order fixed point calculation function - see the syntax for higher order functional arguments in C++

```cpp
fixed_point([](double x) -> double { return std::cos(x); }, 100, 0.75) // calculating the fixed point of the cosine function
```

- Again seeing lambda function syntax in C++

### Finding Roots of Equations Iteratively
- To find the roots of an equation `y=f(x)` (the points where `f(x) = 0`) iteratively, we can:
  - Convert it to a form `x=g(x)`
  - Start with an initial guess `x0~=r`
  - Iterate; `x_(n+1) = g(x_n)` for `n=1,2,3...`
- If this sequence converges to a limit `r` and the function `g` is contiguous at `x=r` then the limit `r` is a root of the equation

```cpp
double fixed_point(double f(double), int max_it, double init, double epsilon = 1e-10) {
  double x = init;

  for (int i = 0; i < max_iterations; i++) {
    double x1 = f(x);

    double error = fabs(x1-x);
    if (error < epsilon)
      break

    x = x1;
  }

  return x
}
```

- We introduce a new parameter `epsilon` which measures the difference between the last and current iteration, breaking when this gets small enough
- C++ has default arguments!
- If we want to get more accuracy in our calculation, we can't rely on `double`, hence there are libraries like Boost that offer replacement types with higher accuracy, e.g. `boost::multiprecision::cpp_bin_float_100`
  - This requires a template function

### Template Functions
- Template classes were discussed in the previous lecture, now we have templated (generic) functions

```cpp
template <typename Float>
Float fixed_point(Float f(Float), int max_it, Float init, Float epsilon = 1e-10) {
    Float x = init;
    for (int i = 0; i < max_it; i++) {
        Float x1 = f(x);
        if (fabs(x1-x) < epsilon) break;
        x = x1; 
    }
    return x;
}
```

- This uses a generic type variable Float

```cpp
template <typename Data>
std::pair<Data, int> fixed_point(Data f(Data), bool cond(Data, Data), int n, Data init) {
    Data x = init;
    for (int i = 0; i < n; i++) {
        Data x1 = f(x);
        if (cond(x, x1)) return {x1, i}; // we also generalise the break condition for flexibility
        x1 = x;
    }
    return {x, n};
}

// example of using this final fixed point function
using float_type = double;
fixed_point(
    [](float_type x) { return cbrt(sin(x)); },
    [](float_type prev, float_type curr) { return fabs(curr - prev) < 1e-10; },
    1000,
    float_type(1.0)
)
```

- We can improve further by generalising the convergence condition and returning the number of iterations run

### Finding Square Roots
- The square root of a number `a` can be found by iteratively averaging the current value and `a/current val`; `0.5(xn+a/xn)`
- When `xn=a^0.5`, we have `0.5(a^0.5+a/a^0.5)` = `0.5(2a^0.5)` = `a^0.5` = `sqrt(a)`
- This can be calculated using the fixed point algorithm

```cpp
template <typename Float>

Float sqrt(Float a, int n, Float init) {
    return fixed_point([a](Float x) { return average(x,a/x); }, n, init);
}
```

### Other Methods for Finding Roots
- There are also some other methods for finding roots of equations other than the iterative approach outlined above
- These are:
  - Newton Rhapson
