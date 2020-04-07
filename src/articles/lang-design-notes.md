title: Notes on Programming Language Design
published: 2020-01-05
tag: computing
tag: design
tag: notes


# Nautilus

I want to build a systems programming language suitable for implementing runtime systems.
The goal is to be platform-agnostic, have theory-motivated parametricity, exitwhen (incl. exiting out of functions), clear semantics for built-in arithmetic, and good control of individual bits, all with a more coherent ergonomic design than C (and esp. better than C++).

## Some interesting numbers

An octet has 8 bits.
What is the smallest addressable unit of memory in a machine?
This is often, but not always an octet (e.g. digital signal processors, historical computers).
In common usage a byte is often understood as an octet, but the term has a longer history as the name for the smallest addresable unit.

So far, this assumes that a machine has only one memory bank.
In general, though, a machine might have different numbers for different types of memory (e.g. main memory, various video memories, peripheral device interfaces exposed as memory).

Since only bits are theoretically indivisible units of (classical) information, they should be used as a foundation.
Octets, bytes, and other concepts must be built on top of them.

## Sizeof/Alignof Lives at the Kind Level

I've noticed that C is interested in opaque vs. concrete types, and that the error messages behave like kind errors.
Here's a proposed kind system for doing this analysis in a more theoretically-motivated way.

```
i, j ∈ ℕ
κ ::= TYPE r
r ::= Opaque
    | Concrete { size = i, align = j }
    | BitPack σ { size = i }
σ ::= Signed | Unsigned

*  ===  TYPE Opaque    // The unit kind in type theory is just the kind of opaque types.
```

The thing I may have to think more about is bit-packing.
Of course the alignment is nothing (i.e. single-bit), but the reason I have σ in there is b/c
    I think the compiler will need to know how to unpack the value into a register: sign- or zero-extend.

## Portable Pointer Techniques

In general, pointers might not be straightforward integers.
For example, you might expect all pointers (perhaps of some type, i.e. ptrs to gc objects) to be 16-octet aligned.
A octet-addressable platform might represent these as always having four low-order bits be zero, but a system which can only address 4-octet words might have only two low-order bits zero.
Long story short, you shouldn't to pack too big a tag into a tagged pointer, but the space you have available is system-dependent.
The C technique of casting `void*` to `uintptr_t`, masking, and casting back to `void*` to extract the pointer form a tagged pointer is technically undefined.

Normal C pointer arithmetic is only in increments of the size of the pointed-to data.
Pointer arithmetic in terms of bytes is sometimes needed as well, and for this C programmers will cast to `char*` before doing arithmetic.
While compliant, it's not what I'd call friendly.
Besides which, packed dependent tuples may require pointer arithmetic on _bits_, for which I know of no compliant technique.

Perhaps what I'm getting at is that there are a number of pointer types, each of which with a different alignment and with possibly different representations.
For example, packing four bits into a 16-octet-aligned pointer into `N` bits if that pointer would be represented with `N - 4` non-zero (implicit or explicit) zero bits.

So then, even pointer types are parameterized by a representation.

```
Ptr : ∀(a : ∃r × TYPE r) → ∀(ρ : PtrRep) -> a -> TYPE ρ.represent
PtrFmt = record
  { size : ℕ
  , lowzeros : ℕ
  , implicitzeros : ℕ
  }
```

So, for example,

```
struct Taggedptr<a> {
  ptr: Ptr {size = 60, lowz = 4, implicitz = 3} a
  tag: Bit⁴
}
```

packs a tag into the four low-order bits of a pointer.
Extracting the pointer requries those four bits to be interpreted as zero regardless of the tag.
Then, since this is a pointer to an octet, the address of the bit it points to is 8 times larger, adding three implicit zeros.
The pointer itself can hold addresses up to `2^64` octets.

One remaining class of operation is `containerof`.
Essentially, if you know you have a member of a known struct, you can backsolve to find the containing struct.
Similarly, a pointer to garbage collected memory might have a header at the beginning of the block that helps describe the pointer, so aligning the pointer backwards can give a predictable pointed-to type.


## Compiling Exit-When With `always` Clauses

```
exit {                                  | 
    if foo                              | jz $foo @else
        {                               | @then
            aFunc(exit a)               |   push @a
                                        |   call aFunc
        }                               |   jmp @endif
        {                               | @else:
            bFunc(exit b)               |   push @bIntercept
                                        |   call bFunc
        }                               |   jmp @endif
                                        |   @bIntercept
                                        |     push @b
                                        |     call @always
                                        |     call @b
                                        | @endif:
                                        | push @endexit
                                        | call @always
}                                       | 
when {                                  | 
    a(x) {                              | @a:       ;; stack is …,x
        doA(x);                         |   call doA
                                        |   push @endexit
    }                                   |   jmp @always
    always {                            | @always:  ;; stack is …,<continuation>
        cleanup();                      |   call cleanup
    }                                   |   pop $k
                                        |   jmp $k
    b(y) {                              | @b        ;; stack is …,y
        doB(y);                         |   call doB
    }                                   |   jmp @endexit
}                                       | @endexit:
```


Of course, the thing is that any given function call might save registers in the prologue.
In which case, we'll have to insert an `always` (i.e. finally) clause in the epilogue to restore those registers.
In any function with such an epilogue, we'll have to pass interceptions for any exit that came in as an argument.
Actually, I'm pretty sure the `sp` (and where present the `fp`) will always need saving;
    so it's any time an exit is piped through a function,
    which means that exiting essentially unravels the stack frame-by-frame.
That might not be bad, though:
    the alternate strategy is to pass an encoded value/exit structure back up;
    with this strategy, the non-exit case won't have to do any decoding.
Also, if you FFI into another lang, then FFI back and exit, the other lang won't have to worry about getting skipped over.

Also, I've explicity passed the exit points, but in the final language, it might be nice to infer them (or override the inference by passing explicitly).


# Haskell-like Stuff

Sometimes I'm using Haskell and I want a thing.
Sometimes it might even be an idea that is almost good enough to cover the opportunity cost.

## Kind-of Dual to `These`

We already have a library for

```
:::haskell
data These a b --  a + b + ab = Either + Pair
    = This a
    | That b
    | These a b
```

But I've occaisionally wanted:

```
:::haskell
data Neither a b -- a + b + 1 = Either + Const (Const 1)
    = One a
    | Another b
    | Neither
```

## Is this a Useful Technique?

Create a class that not only says what it operates on, but what sort of monad-y thing it might operate in?
I've taken some liberties with type-level programming here, but associated types might work just as well,
    depending on what restrictions the type checker has.

```
class Updatable f x (~>) | f -> x, f -> (~>) where
    update :: f x -> Int -> x ~> f x

instance Updatable [] a (->) where
    update xs i x' = take i xs ++ x' ++ drop (i + 1) xs

instace Updatable (IOArray Int) a (λα, β. α -> IO β) where
    update xs i x' = do
        writeIOArray xs i x'
```


## Standalone Methods

This isn't a serious suggestion, but just a note that classes could be broken down severely in theory.

```
method show on a :: a -> String
method read on a :: String -> Error (a, String)

type Debug a => (HasMethod show a, HasMethod read a)
-- LAW: forall x :: a. read (show x) === Ok (x, "")


method show on Int where
    show i | i < 0 = '-' <| show (neg i)
    show i = (i.divRem 10) .λcase:
        (0,0) -> ""
        (0,r) -> digit r
        (d,r) -> show d |> digit r 
    digit = λ(['0'..'9'][_]) -- this is local
```
