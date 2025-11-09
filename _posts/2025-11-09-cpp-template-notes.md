---
layout: post
title: Study notes on the C++ template
---

overload > specialization > general template

specialization:
~~~cpp
// special version of compare to handle pointers to character arrays
template <>
int compare(const char* const &p1, const char* const &p2)
{
return strcmp(p1, p2);
}

// this is also specialization:
template <class T>
struct ValidityError;
template <>
struct ValidityError<core::Signal*> {
  enum { value = HSA_STATUS_ERROR_INVALID_SIGNAL };
};

template <>
struct ValidityError<core::Agent*> {
  enum { value = HSA_STATUS_ERROR_INVALID_AGENT };
};
~~~
It is an error for a program to use a specialization and an instantiation of the original template with the same set of template arguments. However, it is an error that the compiler is unlikely to detect.

Templates and their specializations should be declared in the same header file. Declarations for all the templates with a given name should appear first, followed by any specializations of those templates.

pack expansion
this:
```cpp
return print(os, debug_rep(rest)...);
```
is this:
```cpp
print(os,debug_rep(a1),debug_rep(a2),...,debug_rep(an)
```
and this:
```cpp
print(os, debug_rep(rest...));
```
is this:
```cpp
print(os, debug_reg(a1, a2, ..., an))
```

how to write a reference to an array:
~~~cpp
    char (&b)[100] = a;
~~~

~~~cpp
template <typename T> void f(T&&); // binds to non-const rvalues
template <typename T> void f(const T&); // lvalues and const rvalues
~~~

~~~cpp
const T& and T& matches everything includes rvalue ref, const rvalue ref, lvalue ref, const lvalue ref.
but not for rvalue (not reference), you cannot pass an rvalue directly to it
~~~

T&& is a universal reference that matches everything, but int&& only
binds to rvalue (it does not bind to rvalue reference)

if you pass const int to
~~~cpp
template <typename T>
void g8(T val)
{
    std::cout << std::is_same<int, T>::value << std::endl;
}
~~~
then T will be int, the const is dropped

however, if T&& is used, it preserves the constness and lvalue/rvalue property
of its corresponding argument.

~~~cpp
template <class T = int> class Numbers {
...
};

Numbers<> average_precision; // empty <>says we want the default type
~~~

If a member function isn't used, it is not instantiated.
A member of an instantiated class template is instantiated only if the member
is used.

In
~~~cpp
template <typename T> class BlobPtr {
    BlobPtr& operator++();
}
~~~
we don't need to specify BlobPtr<T>&, cause compiler knows

{% include comment_section.html %}
