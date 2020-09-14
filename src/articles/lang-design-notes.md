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


### Not So Fast!

Something that I think will come up as I compile to assembly is that every function call will need an epilogue to restore callee-save registers.
As such, passing up through several functions to a faraway exit point still has a fair cost: each function in the way will have to rewrite the exit point to inject some epilogue as you call in, and as you exit out each epilogue has to be invoked and the previous exit point jumped to.
Obviously, this isn't much more efficient than just checking a discriminated union that encodes success/error information.

If I do want to get performance from exits across multiple function calls, then the function with the handler needs to save _all_ its registers, even in code that might not exit often.
That's some cost I probably don't want to default to.
Therefore, I'd probably have to resort to two kinds of exit: near-exits—which incur the cost of being manipulated by every function in the stack—, and far exits—which incur the cost of saving normally callee-save registers at handler installation.

Is it worth this complexity?



## Exitwhen Enables Custom Control Structures

```
fn myIf[a : type](pred : bool, exit consequent(), exit alternate()) -> noreturn {
  if pred {
    exit consequent()
  }
  else {
    exit alternate()
  }
}

fn main() {
  exit {
    myIf(foo)
    deadcode() // this is a compile warning/error since myIf is noreturn
  } when {
    consequent {
      doOnTrue()
    }
    alternate {
      doOnFalse()
    }
  }
}
```

Now that I''m looking at it again, though, it seems to only handle branching, not loops.

I think it might be useful to find a more-general structure than scopes, functions, turning statements into expressions, and exits.
A "block" could be something with a name, arguments, and code (and possibly exits?).
We can manipulate these blocks fist-class at compile-time.
The idea is that we can have a compiletime function (macro) which takes blocks and generates code.

```
macro foreach({size_t len, byte* buf} arr, block:_(byte elem), block:else()) {
  loop {
    when (arr.len-- == 0) { exit else(); }
    goto _(arr.buf++);
  }
}

fn dump(size_t len, byte* bytes) {
  foreach({len, bytes}) (elem):{
    char hi, lo = byte2chars(elem);
    putc(hi);
    putc(lo);
    putc(' ');
  }
  else(): {}
}
```

Of course, I'll need to bikeshed it:
optional blocks, some way to unify the first block with additional blocks, skip unneeded parentheses, &c.
All the while, it needs to be reasonably-easily lexable by the human brain.

## Return Needn't be a Keyword

You know, I'm annoyed by the dedicated `this` keyword, but once there are multiple continuations, why shouldn't I be annoyed at a dedicated `return` as well?

A function might have only one way to return:

```
fn normalFunction(a : int8) -> return(b : int8) {...}
fn equivalentFunction(a : int8) -> done(b : int8) {...}
fn returnNamesAreForDocumentation(a : int8) -> ret(int8) {...}
```

Or many, separated by commas:

```
fn checkedAdd(a : uint8, b : uint8) -> return(r : uint8), overflow(lo : uint8, carry : uint1) {...}
```

Or none, if the function won't return to the caller:

```
fn die(msg : string, errorCode : uint8) {...}
```

But don't confuse that with a procedure, which returns but not with a value:

```
fn increment(counter : ptr int) -> return() {...}
```

The thing I'll have to consider is how to decide which return is "default" and which are to be use with exit-when?
Besides, if I can use these for control structures, then I'll sometimes need multiple exits, but not default return.

## Spaghetti

Although state-machines can be a looped-switch, threaded code is faster, if not structured.
I propose a control spaghetti structure which essentially just allows gotos back in, but where variables are slightly more controlled.

```
fn parseStr(char* in, char* out) -> offset_t {
  char* orig_in = in;
  fn getc() -> char {
    return *in++; // yes, I'm using post-increment and that's not a good addition, but for an example, meh
  }
  fn putc(char c) -> () {
    *out++ = c;
  }
  spaghetti (getc, putc) {
    get(): {
      char c = getc();
      goto {
        (c == '\\'): escaped();
        (c == '\"'): done();
        else: plain(c);
      }
    }
    plain(char c): {
      putc(c);
      goto get();
    }
    escaped(): {
      putc(getc());
      goto get();
    }
    done(): {
      return in - orig_in;
    }
  }
}
```

A spaghetti statement has a list of named blocks with arguments (each with their own local scope, obvs).
Also, it is mandated that a spaghetti block declare the variables its scope inherits (a.k.a. scope limiting).
The last statement in a spaghetti block must be a `goto` or an `exit` (or exit-like, e.g. `return`).
A `goto`, in turn, is a list of conditioned arms, each arm being the name of another block in the same spaghetti along with arguments.



This of course means that there are no fall-throughs, no implicit looping, and the user is shoved towards keeping the scope of their variables as small as possible.
All this means that spaghetti might end up relatively understandable.
In fact, it should be relatively easy to compile to a readable flow-chart!


## Arithmetic Primitives

I want to allow for portability, but generally assume the target architectures are "sane".
For addition, I can think of a few modes off the top of my head:

  * wrap: as provided by nearly every ISA's `add` instruction
  * carry: add with carry (the carry bit provided in a bool)
  * trap: fail if the result doesn't fit
  * clamp: on overflow (underflow), produce the max (min) value
  * unsafe: use whatever the fastest instruction is on the target architecture: i.e. overflow behavior is undefined
  * safe: in a dependently-typed language, provide a proof that the result will not overflow

In addition, the representation of a numerical type also determines the result.
I can think of:

  * twos complement
  * ones complement
  * signed magnitude
  * offset binary

though I also know more forms have been used in encodings.
In fact, signed magnitude is more generally useful as well.
In particular, I recall that sometimes N bits hold a number between 1 and 2^N inclusive.
This would be a biased representation with bias -1 (as opposed to a more normal signed offset, which for 4 bits would have bias 8 and range from -8 to 7 inclusive).

Of course, the size in bits also matters, but often there are also scaled-by-power-of-two representations.
For example, if an integer need only take values from multiples of 4096, we can use a representation that drops 12 bits from the end; converting this into a normal integer would require a shift left operation.
I might notate these sizes as `<N>x<A>` for an `N`-bit number packed into `N - A` bits with the lowest `A` bits assumed zero.
Obviously, when `A = 0`, the size would just be written `<N>`.
I'm not sure how this interacts with representations other than twos-complement.
These "aligned-number" sizes fit nicely with fixed-point reals, but I'm not ready to unify them in the types exactly.
In particular, I think integral and rational/real numbers should remain fairly separate in the type system, since they are used for very different purposes most of the time.
In particular, dependent types like `struct string { len : size_t; chars : char[len] }` will only use integral types, though the representation should be fully configurable.
For example, a string that always contains a multiple of eight bytes could be `struct string8 { len : u32x3; chars : char[len] }`, which would leave room for three extra tag bits.

The template for arithmetic instructions should be something like `<operation>-<representation><size>-<mode>`.
Since twos-complement is so widespread, I'll use `i64` &c for twos-complement representations, and come up with something for the others.
For example, `add-i64-trap` should probably be the default unsigned addition operation, since overflow is rarely intended.
However, `add-i64-wrap` is probably what most programmers expect their computers to perform, and `add-i64-unsafe` is probably fine when iterating over an array.

### While I'm at it…

Exact numbers cover a natural mathematical range exactly.
For example, u64 covers naturals mod 2^64.
Big numbers may consume as much memory as necessary to represent arbitrarily large/detailed numbers;
in contrast, finite-width numbers consume a constant maximum amount of memory.
Inexact numbers do not cover a natural range exactly, but instead may drop "less-important" information.
Whether a numerical type includes complex components (or quarternionic, or whatever!) is orthogonal to exact/big.
Whether a numerical type contains integers or fractions is orthogonal as well.
Similarly, whether the mathematical set covered (or approximated) is discrete or continuous is orthogonal.
There are multiple fixed-size inexact numbers (remember VAX floating point?), though the most common will of course be the IEEE754 formats and occasionally their derivatives.

Note that this distinction between exact and inexact is somewhat subjective thanks to that weasel-word "natural" stuck in its definition.
Obviously, there is _some_ mathematical structure that floating point numbers match up with exactly, but are programmers likely to think in terms of the complexities of IEEE754, or are they more likely to think "oh, these are numbers in ℝ!".
Predictably, our brains gravitate towards ℝ rather than the verbose IEEE standards.


# Haskell-like Stuff

Sometimes I'm using Haskell and I want a thing.
Sometimes it might even be an idea that is almost good enough to cover the opportunity cost.

## Kind-of Dual to `These`

We already have a library for

```haskell
data These a b --  a + b + ab = Either + Pair
    = This a
    | That b
    | These a b
```

But I've occaisionally wanted:

```haskell
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

type Debug a = (HasMethod show a, HasMethod read a)
-- LAW: forall x :: a. read (show x) === Ok (x, "")


method show on Int where
    show i | i < 0 = '-' <| show (neg i)
    show i = (i.divRem 10) .λcase:
        (0,0) -> ""
        (0,r) -> digit r
        (d,r) -> show d |> digit r 
    digit = λ(['0'..'9'][_]) -- this is local
```
