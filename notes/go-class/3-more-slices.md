## More on Slices (Video 10)
```go
// The following shows some different slices, with information on them given below

var s []int
t := []int{}
u := make([]int, 5)
v := make([]int, 0, 5)
w := []int{1,2,3,4,5}
```

- Before explaining each slice we define the slice descriptor (an internal thing) as a tuple of (length, capacity, arrAddr) 
  - Length is the amount of elements stored in the slice
  - Capacity is the size of the underlying array storing the values
  - `arrAddr` is a pointer to the underlying array
- `s` is an uninitialised or nil slice
  - It has 0 length, 0 cap and a nil pointer in `arrAddr`
- `t` is an initialised but empty slice
  - It has 0 length and 0 capacity and `arrAddr` points to a special sentinel _`struct{}`_ value (again an internal thing that is basically a nothing value but not nil)
  - This is because it has 0 capacity so it can't point to a concrete array of 0 length - this sentinel value is an internal language thing that isn't exposed
- `u` is an initialised slice with 5 length and 5 capacity
  - It will be storing 5 of the zero value of it's slice type - e.g. for int it would be [0,0,0,0,0]
  - **This is an important thing to remember - appending to this list will create a list of 6 elements not 1!!**
- `v` is an initialised slice with 0 length and 5 capacity
  - The underlying array will have a size of 5 but won't be storing anything - attempting to read from this will cause a panic since the length is 0

### The Slice Operator
- The slice operator allows you to take a view of a slice
- It looks like `a[0:2]` - which will take the 0 and 1 elements of `a` (it is exclusive for the _to_ side)

#### The Slice Capacity Issue
- The slice operator basically just creates a _view_ into the underlying array of a slice
- This means that when slicing a slice of e.g. size 5 to get `0:2`, you get back a slice descriptor with length 2 but capacity 5 (since the underlying array is the same and has length 5)
- You can then legally slice this slice at e.g. `0:3` and you'll get back a slice descriptor of length 3 - which will contain the value at index 2 of the original slice!!!
- **This is an important thing to remember**
- This design is maybe not ideal but it is what it is. To fix this the slice with capacity operator was introduced
- This looks like `a[0:2:2]` - this will create a slice descriptor of length 2 AND CAPACITY 2
  - This means if you append to this slice Go will have to allocate a new array with new size and importantly a new memory address so the append works properly and doesn't touch the underlying array of the original slice
- Slices are basically aliases to underlying arrays

### Array and Slice APIs [From Here](https://go.dev/blog/slices-intro)
- To create an array from an array literal you can do `b := [2]string{"Hello", "world"}`, and you can do `b := [...]string` to let Go determine the size of the array for you based on the proceeding literal
- Slices are made with the `make` function (`func make([]T, len, cap) []T`)
- `len` and `cap` functions can be used to retrieve the length and capacity of a slice
- You can take an array `arr` and create a slice referencing (or providing a view of) the storage of `arr` using `s := arr[:]`
- If you slice an array (or slice) with capacity 5, not from the 0th element, then the resulting slice will have a capacity equal to the original capacity minus the length of the specified slice range. This is a variation on the slice capacity issue above
  - You can grow the slice to the end of the backing array's length using `s = s[:cap(s)]`
- Growing a slice can be done by making a larger slice and copying the data into it

```go
s := make([]int, 5)

// This is basically the internal implementation of slice growing that Go uses when appending to a slice that has reached it's max capacity
t := make([]int, len(s), (cap(s)+1)*2)
copy(t, s)
s = t
```

- As mentioned a slice will be automatically grown when it's length reaches its capacity
  - `append(s []T, x ...T) []T`
- You can append a slice into another slice by using the `...` operator to expand the second arg into a list of args
  - `append(s, x...)` for `s []T` and `x []T`
- The zero value of a slice (nil) acts like a zero length slice so you can declare a slice variable (without initialising it) and then append to it in a loop:

```go

func filter(s []int, fn func(int) bool) {
  var res []int // == nil
  for _, v := range s {
    if fn(v) {
      res = append(res, v)
    } 
  }

  return res
}
```

- One gotcha with slices is re-slicing doesn't make a copy of the underlying array, so you could accidentally keep the underlying array around when only a small piece of the data is actually needed
  - To remedy this, make a new slice and copy only the useful data into it and the garbage collector will sort out the rest