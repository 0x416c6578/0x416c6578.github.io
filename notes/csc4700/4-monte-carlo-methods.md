## Monte-Carlo Methods
### Pseudorandom Numbers
- Are deterministic but have statistical properties resembling true random
- They should have the properties:
  - Long period before repeat
  - Efficient
  - Repeatable
  - Portable
- C++ has some good PRNG generators in the standard library, for example `std::uniform_int_distribution<int>`
- C `rand()` is not threadsafe, therefore we should use C++ `<random>` for better safety and performance

```cpp
#include <print>
#include <random>

int main() {
    std::random_device rd; // This is a true random source that uses sources of entropy from your computer, e.g. kernel entropy source, mouse movements, system state etc.
    
    std::mt19937 gen(rd()); // We can then use this source of true random to seed a standard PRNG. random_device is quite expensive so shouldn't be used frequently
    
    std::uniform_int_distribution<int> dis(1,6);
    std::uniform_real_distribution<double> disd(1,6);
    
    std::println("random int: {}, real {}", dis(gen), disd(gen)) // The created distributions use the generator to generate the random number with the statistical properties of that distribution
}
```

### Histogram Class
```cpp
template <typename T>
class histogram {
    std::vector<size_t> bucket_data;
    T min_value, max_value;
    
public:
    /*
     * Constructor; uses direct member initialisation for efficiency. We have two extra buckets;
     * one for values smaller than the min and one for larger than the max
     */
    histogram(size_t num buckets, T smallest, T largest)
        : bucket_data(num_buckets + 2)
        , min_value(smallest)
        , max_value(largest) {}

    // add a new value to a bucket in our histogram
    void add_val(T value) {
        size_t idx = 0;

        if (value > max_value) {
            idx = bucket_data.size() - 1; // out of range larger than maximum last bucket
        } else if (value >= min_value) {
            // otherwise calculate correct index:
            auto bucket_size = (max_value - min_value) / (bucket_data.size() - 2);
            idx = static_cast<size_t>((value - min_value) / bucket_size) + 1;
        }
        
        ++bucket_data[idx];
    }
    
    // return a vector of all the bucket midpoints, min and max buckets
    std::vector<T> buckets() const {
        // set up return vector
        std::vector<T> buckets;
        buckets.reserve(bucket_data.size() - 2);
        
        // add min value bucket
        buckets.push_back(min_value);
        
        // calculate the midpoints of our buckets
        T delta = (max_value - min_value) / (bucket_data.size() - 2);
        for (size_t i = 0; i != bucket_data.size() - 2; ++i)
            buckets.push_back(min_value + (i * delta) + (0.5 * delta))
            
        // add max value bucket
        buckets.push_back(max_value);
        
        return buckets;
    }
    
    // return a vector of the normalised histogram
    std::vector<size_t> normalised_data() const {
        std::vector<double> data;
        data.reserve(bucket_data.size());
        
        // max_element returns an iterator to the max element in the vector
        auto max = std::max_element(bucket_data.begin(), bucket_data.end());
        std::transform(
            bucket_data.begin(), bucket_data.end(),
            std::back_inserter(data),
            [&](size_t value) { return double(value) / *max; });
        
        return data;
    }
};
```

#### C++ Lambda Syntax
- C++ makes you define which variables from the surrounding function a lambda should close over, in this case `&` means capture all variables in the surrounding scope available inside the lambda *by reference*
  - We could equally do `[&max]` to reduce to closing over just the `max` iterator by reference
  - Alternatively lambdas can also have different capture clauses: `[]` captures nothing, `[=]` captures everything by value (makes a copy of all local variables), `[max]` captures just `max` by value
- In the above example `max` is an iterator; we must dereference it in the lambda to get the value it points to

### Plotting our Histogram
- C++ has a nice wrapper around matplotlib we can use to plot our histograms:

```cpp
plt:figure_size(1280, 960);

for (int max_attempts = 17; max_attempts < 21; ++max_attempts) {
    int const n_total = 1 << max_attempts; // 2^n
    
    histogram<double> hist(100, 0.0, 1.0);
    for (int n = 0; n < n_total; ++n) 
        hist_add_val(get_random_number()) // get_random_number defined elsewhere, can use different distributions
    
    plt::plot(hist.buckets(), hist.normalised_data());
}

plt::save("random_numbers.png")
```
