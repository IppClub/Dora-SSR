/*

Original work Copyright (c) 2014-2018 Jonathan B. Coe
Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#ifndef JBCOE_PROPAGATE_CONST_INCLUDED
#define JBCOE_PROPAGATE_CONST_INCLUDED

#include <functional>
#include <type_traits>
#include <utility>

#ifndef _MSC_VER
#define PROPAGATE_CONST_CONSTEXPR constexpr
#else
#if _MSC_VER <= 1900 // MSVS 2015 and earlier
#define PROPAGATE_CONST_CONSTEXPR
#define PROPAGATE_CONST_HAS_NO_EXPRESSION_SFINAE
#else
#define PROPAGATE_CONST_CONSTEXPR constexpr
#endif
#endif

namespace playrho {

/// @brief Constant propagating template wrapper type.
template <class T>
class propagate_const {
 public:
     
 /// @brief Element type detecting trait.
 template<class U>
 struct detect_element_type {
   /// @brief Detected element type alias.
   using type = typename U::element_type;
 };

 /// @brief Element type detecting trait.
 template<class U>
 struct detect_element_type<U*> {
   /// @brief Detected element type alias.
   using type = U;
 };

 /// @brief Element type alias.
 using element_type = typename detect_element_type<T>::type;

 private:
  /// @brief Gets pointer.
  template <class U>
  static element_type* get_pointer(U* u) {
    return u;
  }

  /// @brief Gets pointer.
  template <class U>
  static element_type* get_pointer(U& u) {
    return get_pointer(u.get());
  }

  /// @brief Gets pointer.
  template <class U>
  static const element_type* get_pointer(const U* u) {
    return u;
  }

  /// @brief Gets pointer.
  template <class U>
  static const element_type* get_pointer(const U& u) {
    return get_pointer(u.get());
  }

  /// @brief Trait for detecting that the given type is not this one.
  template <class U>
  struct is_propagate_const : ::std::false_type {};

  /// @brief Trait for detecting that the given type is this one.
  template <class U>
  struct is_propagate_const<propagate_const<U>> : ::std::true_type {};

 public:
  // [propagate_const.ctor], constructors
  /// @brief Default constructor.
  PROPAGATE_CONST_CONSTEXPR propagate_const() = default;

  /// @brief Explicityly deleted copy constructor.
  propagate_const(const propagate_const& p) = delete;

  /// @brief Move constructor.
  PROPAGATE_CONST_CONSTEXPR propagate_const(propagate_const&& p) = default;

#ifdef PROPAGATE_CONST_HAS_NO_EXPRESSION_SFINAE
  //
  // Make converting constructors explicit as we cannot use SFINAE to check.
  //

  template <class U, class = std::enable_if_t<is_constructible<T, U&&>::value>>
  explicit PROPAGATE_CONST_CONSTEXPR propagate_const(propagate_const<U>&& pu)
      : t_(std::move(pu.t_))
  {
  }

  template <class U,
            class = std::enable_if_t<is_constructible<T, U&&>::value &&
                                !is_propagate_const<std::decay_t<U>>::value>>
  explicit PROPAGATE_CONST_CONSTEXPR propagate_const(U&& u)
      : t_(std::forward<U>(u))
  {
  }
#else
  //
  // Use SFINAE to check if converting constructor should be explicit.
  //

  /// @brief Move constructor.
  template <class U, std::enable_if_t<!std::is_convertible<U&&, T>::value &&
                                     std::is_constructible<T, U&&>::value,
                                 bool> = true>
  explicit PROPAGATE_CONST_CONSTEXPR propagate_const(propagate_const<U>&& pu)
      : t_(std::move(pu.t_)) {}

  /// @brief Move constructor.
  template <class U, std::enable_if_t<std::is_convertible<U&&, T>::value &&
                                     std::is_constructible<T, U&&>::value,
                                 bool> = false>
  PROPAGATE_CONST_CONSTEXPR propagate_const(propagate_const<U>&& pu) : t_(std::move(pu.t_)) {}

  /// @brief Move constructor.
  template <class U, std::enable_if_t<!std::is_convertible<U&&, T>::value &&
                                     std::is_constructible<T, U&&>::value &&
                                     !is_propagate_const<std::decay_t<U>>::value,
                                 bool> = true>
  explicit PROPAGATE_CONST_CONSTEXPR propagate_const(U&& u) : t_(std::forward<U>(u)) {}

  /// @brief Move constructor.
  template <class U, std::enable_if_t<std::is_convertible<U&&, T>::value &&
                                     std::is_constructible<T, U&&>::value &&
                                     !is_propagate_const<std::decay_t<U>>::value,
                                 bool> = false>
  PROPAGATE_CONST_CONSTEXPR propagate_const(U&& u) : t_(std::forward<U>(u)) {}
#endif

  // [propagate_const.assignment], assignment
  /// @brief Explicitly deleted copy assignment.
  propagate_const& operator=(const propagate_const& p) = delete;

  /// @brief Move assignment operator.
  PROPAGATE_CONST_CONSTEXPR propagate_const& operator=(propagate_const&& p) = default;

  /// @brief Move assignment operator for compatible <code>propagate_const</code> types.
  template <class U>
  PROPAGATE_CONST_CONSTEXPR propagate_const& operator=(propagate_const<U>&& pu) {
    t_ = std::move(pu.t_);
    return *this;
  }

  /// @brief Move assignment operator for compatible types.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  PROPAGATE_CONST_CONSTEXPR propagate_const& operator=(U&& u) {
    t_ = std::move(u);
    return *this;
  }

  // [propagate_const.const_observers], const observers
  /// @brief Boolean observer operator.
  explicit PROPAGATE_CONST_CONSTEXPR operator bool() const { return get() != nullptr; }

  /// @brief Member-of operator support.
  PROPAGATE_CONST_CONSTEXPR const element_type* operator->() const { return get(); }

  /// @brief Const-conversion operator support.
  template <class T_ = T, class U = std::enable_if_t<std::is_convertible<
                              const T_, const element_type*>::value>>
  PROPAGATE_CONST_CONSTEXPR operator const element_type*() const  // Not always defined
  {
    return get();
  }

  /// @brief Indirection operator support.
  PROPAGATE_CONST_CONSTEXPR const element_type& operator*() const { return *get(); }

  /// @brief Gets pointer content.
  PROPAGATE_CONST_CONSTEXPR const element_type* get() const { return get_pointer(t_); }

  // [propagate_const.non_const_observers], non-const observers
  /// @brief Member-of operator support.
  PROPAGATE_CONST_CONSTEXPR element_type* operator->() { return get(); }

  /// @brief Indirection operator support.
  template <class T_ = T,
            class U = std::enable_if_t<std::is_convertible<T_, element_type*>::value>>
  PROPAGATE_CONST_CONSTEXPR operator element_type*()  // Not always defined
  {
    return get();
  }

  /// @brief Indirection operator support.
  PROPAGATE_CONST_CONSTEXPR element_type& operator*() { return *get(); }

  /// @brief Gets pointer content.
  PROPAGATE_CONST_CONSTEXPR element_type* get() { return get_pointer(t_); }
  
  // [propagate_const.modifiers], modifiers
  /// @brief Swap support.
  PROPAGATE_CONST_CONSTEXPR void swap(propagate_const& pt) noexcept(
      noexcept(swap(std::declval<T&>(), std::declval<T&>()))) {
    swap(t_, pt.t_);
  }

 private:
  T t_; ///< Underlying data.

  friend struct std::hash<propagate_const<T>>;
  friend struct std::equal_to<propagate_const<T>>;
  friend struct std::not_equal_to<propagate_const<T>>;
  friend struct std::greater<propagate_const<T>>;
  friend struct std::less<propagate_const<T>>;
  friend struct std::greater_equal<propagate_const<T>>;
  friend struct std::less_equal<propagate_const<T>>;

  // [propagate_const.relational], relational operators

  /// @brief Equals operator.
  friend PROPAGATE_CONST_CONSTEXPR bool operator==(const propagate_const& pt, std::nullptr_t) {
    return pt.t_ == nullptr;
  }

  /// @brief Equals operator.
  friend PROPAGATE_CONST_CONSTEXPR bool operator==(std::nullptr_t, const propagate_const& pu) {
    return nullptr == pu.t_;
  }

  /// @brief Not-equals operator.
  friend PROPAGATE_CONST_CONSTEXPR bool operator!=(const propagate_const& pt, std::nullptr_t) {
    return pt.t_ != nullptr;
  }

  /// @brief Not-equals operator.
  friend PROPAGATE_CONST_CONSTEXPR bool operator!=(std::nullptr_t, const propagate_const& pu) {
    return nullptr != pu.t_;
  }

  /// @brief Equals operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator==(const propagate_const& pt,
                                   const propagate_const<U>& pu) {
    return pt.t_ == pu.t_;
  }

  /// @brief Not-equals operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator!=(const propagate_const& pt,
                                   const propagate_const<U>& pu) {
    return pt.t_ != pu.t_;
  }

  /// @brief Less-than operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<(const propagate_const& pt,
                                  const propagate_const<U>& pu) {
    return pt.t_ < pu.t_;
  }

  /// @brief Greater-than operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>(const propagate_const& pt,
                                  const propagate_const<U>& pu) {
    return pt.t_ > pu.t_;
  }

  /// @brief Less-than or equal-to operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<=(const propagate_const& pt,
                                   const propagate_const<U>& pu) {
    return pt.t_ <= pu.t_;
  }

  /// @brief Greater-than or equal-to operator.
  template <class U>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>=(const propagate_const& pt,
                                   const propagate_const<U>& pu) {
    return pt.t_ >= pu.t_;
  }

  /// @brief Equals operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator==(const propagate_const& pt, const U& u) {
    return pt.t_ == u;
  }

  /// @brief Not-equals operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator!=(const propagate_const& pt, const U& u) {
    return pt.t_ != u;
  }

  /// @brief Less-than operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<(const propagate_const& pt, const U& u) {
    return pt.t_ < u;
  }

  /// @brief Greater-than operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>(const propagate_const& pt, const U& u) {
    return pt.t_ > u;
  }

  /// @brief Less-than or equal-to operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<=(const propagate_const& pt, const U& u) {
    return pt.t_ <= u;
  }

  /// @brief Greater-than or equal-to operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>=(const propagate_const& pt, const U& u) {
    return pt.t_ >= u;
  }

  /// @brief Equals operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator==(const U& u, const propagate_const& pu) {
    return u == pu.t_;
  }

  /// @brief Not-equals operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator!=(const U& u, const propagate_const& pu) {
    return u != pu.t_;
  }

  /// @brief Less-than operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<(const U& u, const propagate_const& pu) {
    return u < pu.t_;
  }

  /// @brief Greater-than operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>(const U& u, const propagate_const& pu) {
    return u > pu.t_;
  }

  /// @brief Less-than or equal-to operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator<=(const U& u, const propagate_const& pu) {
    return u <= pu.t_;
  }

  /// @brief Greater-than or equal-to operator.
  template <class U,
            class = std::enable_if_t<!is_propagate_const<std::decay_t<U>>::value>>
  friend PROPAGATE_CONST_CONSTEXPR bool operator>=(const U& u, const propagate_const& pu) {
    return u >= pu.t_;
  }
};


// [propagate_const.algorithms], specialized algorithms

/// @brief Support for swap operation.
template <class T>
PROPAGATE_CONST_CONSTEXPR void swap(propagate_const<T>& pt, propagate_const<T>& pu) noexcept(
    noexcept(swap(std::declval<T&>(), std::declval<T&>())))
{
  swap(pt.underlying_ptr(), pu.underlying_ptr());
}

}  // end namespace playrho

namespace std {

// [propagate_const.hash], hash support

/// @brief Support for hash operation.
template <class T>
struct hash<::playrho::propagate_const<T>> {
  typedef size_t result_type; ///< Result type.
  typedef ::playrho::propagate_const<T> argument_type; ///< Argument type.

  /// @brief Hash operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc) const {
    return std::hash<T>()(pc.t_);
  }
};

// [propagate_const.comparison_function_objects], comparison function objects

/// @brief Support for equal-to operations.
template <class T>
struct equal_to<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Equal-to operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::equal_to<T>()(pc1.t_, pc2.t_);
  }
};

/// @brief Support for not-equal-to operations.
template <class T>
struct not_equal_to<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Not-equal-to operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::not_equal_to<T>()(pc1.t_, pc2.t_);
  }
};

/// @brief Support for less than operations.
template <class T>
struct less<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Less-than operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::less<T>()(pc1.t_, pc2.t_);
  }
};

/// @brief Support for greater than operations.
template <class T>
struct greater<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Greater-than operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::greater<T>()(pc1.t_, pc2.t_);
  }
};

/// @brief Support for less than or equal operations.
template <class T>
struct less_equal<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Lesser-than operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::less_equal<T>()(pc1.t_, pc2.t_);
  }
};

/// @brief Support for greater than or equal operations.
template <class T>
struct greater_equal<::playrho::propagate_const<T>> {
  typedef ::playrho::propagate_const<T> first_argument_type; ///< First argument type.
  typedef ::playrho::propagate_const<T> second_argument_type; ///< Second argument type.

  /// @brief Greater-than operation functor.
  bool operator()(
      const ::playrho::propagate_const<T>& pc1,
      const ::playrho::propagate_const<T>& pc2) const {
    return std::greater_equal<T>()(pc1.t_, pc2.t_);
  }
};

}  // end namespace playrho

#undef PROPAGATE_CONST_CONSTEXPR
#endif // JBCOE_PROPAGATE_CONST_INCLUDED
