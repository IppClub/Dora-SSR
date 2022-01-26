//-------------------------------------------------------------------------
//
// Copyright (C) 2004-2005 Yingle Jia
//
// Permission to copy, use, modify, sell and distribute this software is 
// granted provided this copyright notice appears in all copies. 
// This software is provided "as is" without express or implied warranty, 
// and with no claim as to its suitability for any purpose.
//
// AcfDelegate.h
//

#ifndef __Acf_Delegate__
#define __Acf_Delegate__

#include <utility> // for std::pair
#include <functional> // for std::function

namespace Acf {

template <class T>
inline T _HandleInvalidCall()
{
	return T();
}

template <>
inline void _HandleInvalidCall<void>() { }

template <class TSignature>
class Delegate; // no body

//-------------------------------------------------------------------------
// class Delegate<R (T1, T2, ..., TN)>
template <class R , class... Args>
class Delegate<R (Args...)>
{
// Declaractions
private:
	class DelegateImplBase
	{
	// Fields
	public:
		DelegateImplBase* Previous; // singly-linked list

	// Constructor/Destructor
	protected:
		DelegateImplBase() : Previous(nullptr) { }
		DelegateImplBase(const DelegateImplBase& other) : Previous(nullptr) { }
	public:
		virtual ~DelegateImplBase() { }

	// Methods
	public:
		virtual DelegateImplBase* Clone() const = 0;
		virtual R Invoke(Args ...args) const = 0;
	};

	template <class TFunctor>
	struct Invoker
	{
		static R Invoke(const TFunctor& f , Args ...args)
		{
			return (const_cast<TFunctor&>(f))(args...);
		}
	};

	template <class TPtr, class TFunctionPtr>
	struct Invoker<std::pair<TPtr, TFunctionPtr> >
	{
		static R Invoke(const std::pair<TPtr, TFunctionPtr>& mf , Args ...args)
		{
			return ((*mf.first).*mf.second)(args...);
		}
	};

	template <class TFunctor>
	class DelegateImpl : public DelegateImplBase
	{
	// Fields
	public:
		TFunctor Functor;

	// Constructor
	public:
		DelegateImpl(const TFunctor& f) : Functor(f) { }
		DelegateImpl(const DelegateImpl& other) : Functor(other.Functor) { }

	// Methods
	public:
		virtual DelegateImplBase* Clone() const
		{
			return new DelegateImpl(*this);
		}
		virtual R Invoke(Args ...args) const
		{
			return Invoker<TFunctor>::Invoke(this->Functor , args...);
		}
	};

// Fields
private:
	DelegateImplBase* _last;

// Constructor/Destructor
public:
	Delegate()
	{
		this->_last = nullptr;
	}

	Delegate(std::nullptr_t)
	{
		this->_last = nullptr;
	}

	template <class TFunctor>
	Delegate(const TFunctor& f)
	{
		this->_last = nullptr;
		*this = f;
	}

	template<class TPtr, class TFunctionPtr>
	Delegate(const TPtr& obj, const TFunctionPtr& mfp)
	{
		this->_last = nullptr;
		*this = std::make_pair(obj, mfp);
	}

	Delegate(const Delegate& d)
	{
		this->_last = nullptr;
		*this = d;
	}

	~Delegate()
	{
		Clear();
	}

// Properties
public:
	bool IsEmpty() const
	{
		return (this->_last == nullptr);
	}

	bool IsMulticast() const
	{
		return (this->_last != nullptr && this->_last->Previous != nullptr);
	}

// Static Methods
private:
	static DelegateImplBase* CloneDelegateList(DelegateImplBase* list, /*out*/ DelegateImplBase** first)
	{
		DelegateImplBase* list2 = list;
		DelegateImplBase* newList = nullptr;
		DelegateImplBase** pp = &newList;
		DelegateImplBase* temp = nullptr;

		try
		{
			while (list2 != nullptr)
			{
				temp = list2->Clone();
				*pp = temp;
				pp = &temp->Previous;
				list2 = list2->Previous;
			}
		}
		catch (...)
		{
			FreeDelegateList(newList);
			throw;
		}

		if (first != nullptr)
		{
			*first = temp;
		}
		return newList;
	}

	static void FreeDelegateList(DelegateImplBase* list)
	{
		DelegateImplBase* temp = nullptr;
		while (list != nullptr)
		{
			temp = list->Previous;
			delete list;
			list = temp;
		}
	}

	static void InvokeDelegateList(DelegateImplBase* list , Args ...args)
	{
		if (list != nullptr)
		{
			if (list->Previous != nullptr)
			{
				InvokeDelegateList(list->Previous , args...);
			}
			list->Invoke(args...);
		}
	}

// Methods
public:
	template <class TFunctor>
	void Add(const TFunctor& f)
	{
		DelegateImplBase* d = new DelegateImpl<TFunctor>(f);
		d->Previous = this->_last;
		this->_last = d;
	}

	template<class TPtr, class TFunctionPtr>
	void Add(const TPtr& obj, const TFunctionPtr& mfp)
	{
		DelegateImplBase* d = new DelegateImpl<std::pair<TPtr, TFunctionPtr>>(std::make_pair(obj, mfp));
		d->Previous = this->_last;
		this->_last = d;
	}

	template <class TFunctor>
	bool Remove(const TFunctor& f)
	{
		DelegateImplBase* d = this->_last;
		DelegateImplBase** pp = &this->_last;
		DelegateImpl<TFunctor>* impl = nullptr;

		while (d != nullptr)
		{
			impl = dynamic_cast<DelegateImpl<TFunctor>*>(d);
			if (impl != nullptr && impl->Functor == f)
			{
				*pp = d->Previous;
				delete impl;
				return true;
			}
			pp = &d->Previous;
			d = d->Previous;
		}
		return false;
	}

	template<class TPtr, class TFunctionPtr>
	bool Remove(const TPtr& obj, const TFunctionPtr& mfp)
	{
		return Remove(std::make_pair(obj, mfp));
	}

	void Clear()
	{
		FreeDelegateList(this->_last);
		this->_last = nullptr;
	}

private:
	template <class TFunctor>
	bool Equals(const TFunctor& f) const
	{
		if (this->_last == nullptr || this->_last->Previous != nullptr)
		{
			return false;
		}
		DelegateImpl<TFunctor>* impl =
			dynamic_cast<DelegateImpl<TFunctor>*>(this->_last);
		if (impl == nullptr)
		{
			return false;
		}
		return (impl->Functor == f);
	}

// Operators
public:
	operator bool() const
	{
		return !IsEmpty();
	}

	bool operator!() const
	{
		return IsEmpty();
	}

	template <class TFunctor>
	Delegate& operator=(const TFunctor& f)
	{
		DelegateImplBase* d = new DelegateImpl<TFunctor>(f);
		FreeDelegateList(this->_last);
		this->_last = d;
		return *this;
	}

	Delegate& operator=(const Delegate& d)
	{
		if (this != &d)
		{
			DelegateImplBase* list = CloneDelegateList(d._last, nullptr);
			FreeDelegateList(this->_last);
			this->_last = list;
		}
		return *this;
	}

	Delegate& operator=(std::nullptr_t)
	{
		Clear();
		return *this;
	}

	template <class TFunctor>
	Delegate& operator+=(const TFunctor& f)
	{
		Add(f);
		return *this;
	}

	template <class TFunctor>
	friend Delegate operator+(const Delegate& d, const TFunctor& f)
	{
		return (Delegate(d) += f);
	}

	template <class TFunctor>
	friend Delegate operator+(const TFunctor& f, const Delegate& d)
	{
		return (d + f);
	}

	template <class TFunctor>
	Delegate& operator-=(const TFunctor& f)
	{
		Remove(f);
		return *this;
	}

	template <class TFunctor>
	Delegate operator-(const TFunctor& f) const
	{
		return (Delegate(*this) -= f);
	}

	friend bool operator==(const Delegate& d, const Delegate& other)
	{
		return d.Equals(other);
	}

	template <class TFunctor>
	friend bool operator==(const Delegate& d, const TFunctor& f)
	{
		return d.Equals(f);
	}

	template <class TFunctor>
	friend bool operator==(const TFunctor& f, const Delegate& d)
	{
		return (d == f);
	}

	template <class TFunctor>
	friend bool operator!=(const Delegate& d, const TFunctor& f)
	{
		return !(d == f);
	}

	template <class TFunctor>
	friend bool operator!=(const TFunctor& f, const Delegate& d)
	{
		return (d != f);
	}

	R operator()(Args ...args) const
	{
		if (this->_last == nullptr)
		{
			return _HandleInvalidCall<R>();
		}
		else if (this->_last->Previous != nullptr)
		{
			InvokeDelegateList(this->_last->Previous , args...);
		}
		return this->_last->Invoke(args...);
	}
};

} // namespace Acf

#endif // #ifndef __Acf_Delegate__
