import VersoManual

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

#doc (Manual) "Purpose" =>

This site is an amateur tour of [the foundations of geometry][foundations] in Lean (Lean 4). I'm not
an expert on geometry, proofs, or literate documentation. Instead, I'm a software engineer with a
PhD in biomechanics (in horses). Yes, I know it's weird.

This is a learning exercise.

Its scope is not intended to be a complete or responsible tour of the subject, but rather entirely
my own whim.

# Why axiomatic geometry?

Euclid's _Elements_ was one of the first texts to use mathematical proofs. But Euclid suffered from
a deplorable lack of modern education. He relied on unstated assumptions, such as facts read off
a diagram, rather than postulates.

This was remedied by modern geometers like [Hilbert][hilbert],
of whom I have little knowledge.

The challenge here was for me to take something basic, and fairly familiar, and turn it into a
formal set of proofs. Things like lines and points are familiar enough to me, so I went with them.

# Is it any good?

Nope!

Well maybe.

What is good mathematics anyway? I occasionally Googled stuff, read Wikipedia and asked LLMs what
I should do to make things idiomatic.

For the rest, provided I can make Lean say it's good, without contradictions in my hypotheses, and
without `sorry`, I'm happy.

# References

* [Foundations of Geometry][foundations], Wikipedia.
* [David Hilbert][hilbert], Wikipedia.

[foundations]: https://en.wikipedia.org/wiki/Foundations_of_geometry
[hilbert]: https://en.wikipedia.org/wiki/David_Hilbert
