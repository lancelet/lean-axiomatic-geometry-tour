import VersoManual

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

#doc (Manual) "Affine Planes 1" =>

This chapter follows Eric Moorhouse's notes
_Affine Planes: An Introduction to Axiomatic Geometry_.

# Primitives

To start with, we have two types, `Point` and `Line`:

```lean
-- One module, but Verso elaborates each block separately, so a `variable`
-- declared here and used in a later block trips the unused-variable linter.
-- Disable it for the whole chapter.
set_option linter.unusedVariables false

variable { Point : Type }
variable { Line  : Type }
```

We don't know what types they are specifically at this stage, except that they
are indeed types. The specific types would depend on what instance of an affine
plane we are describing, and at this stage we want to keep things generic, so
no further refinement is necessary.

# Definitions

Let's now start with some defintions that we need in the axioms. First the notion
collinearity. Three points are collinear if some line lines on all three. We
don't yet know what the notion of "lies on" or "coincidence" actually means, so
we leave it as a proposition that a given point and line may satisfy:

```lean
def Collinear
  (LiesOn : Point → Line → Prop)
  (A B C : Point) : Prop :=
  ∃ line,
    (LiesOn A line) ∧
    (LiesOn B line) ∧
    (LiesOn C line)
```

For example, three collinear points $`A`, $`B` and $`C` all lie on one common line:

![Three collinear points A, B and C on a common line](figures/collinear.svg)

Next, let's talk about the intersection or meeting of lines. Two lines meet if
they share at least one point:

```lean
def Meets
  (LiesOn : Point → Line → Prop)
  (line1 line2 : Line) : Prop :=
  ∃ point,
    (LiesOn point line1) ∧
    (LiesOn point line2)
```

And, conversely, lines are non-intersecting if they do not meet:

```lean
def NonIntersecting
  (LiesOn : Point → Line → Prop)
  (line1 line2 : Line): Prop :=
    ¬ (Meets LiesOn line1 line2)
```

In an affine plane two lines are parallel if they:

* are the same line
* do not intersect

This only works for an affine plane. Consider that in 3D space, two lines can be
non-intersecting but non-parallel.

```lean
def Parallel
  (LiesOn : Point → Line → Prop)
  (line1 line2 : Line) : Prop :=
    (line1 = line2) ∨
    (NonIntersecting LiesOn line1 line2)
```

We have a couple of small definitions; four points that are all distinct:

```lean
def AllDistinct4 (A B C D : Point) : Prop :=
  (A ≠ B) ∧
  (A ≠ C) ∧
  (A ≠ D) ∧
  (B ≠ C) ∧
  (B ≠ D) ∧
  (C ≠ D)
```

And that no three of any four points are collinear:

```lean
def No3Collinear4
  (LiesOn : Point → Line → Prop)
  (A B C D : Point) : Prop :=
  ¬ (Collinear LiesOn A B C) ∧
  ¬ (Collinear LiesOn A B D) ∧
  ¬ (Collinear LiesOn A C D) ∧
  ¬ (Collinear LiesOn B C D)
```

Before we proceed below, we also need a definition of uniqueness. This is part of
Lean's mathlib, but we want to work from first principles:

```lean
def ExistsUnique {α : Sort u} (p : α → Prop) : Prop :=
  ∃ x, (p x) ∧ (∀ y, p y → y = x)

open Lean in
macro "∃! " xs:explicitBinders ", " b:term : term => do
  return ⟨← expandExplicitBinders ``ExistsUnique xs b⟩
```

And let's also define `lemma` as an alias for `theorem`, to match mathlib:

```lean
syntax (name := lemmaCommand)
  declModifiers "lemma " declId declSig declVal : command

open Lean in
macro_rules
  | `($mods:declModifiers lemma $id:declId $sig:declSig $val:declVal) =>
      `($mods:declModifiers theorem $id:declId $sig:declSig $val:declVal)
```

# Axioms

Now we are ready to state the affine plane axioms.

First: any two distinct points lie on a unique common line:

```lean
def UniqueJoiningLine
  (LiesOn : Point → Line → Prop) : Prop :=
  ∀ A B : Point, A ≠ B →
    ∃! line,
      (LiesOn A line) ∧ (LiesOn B line)
```

Second: Given a line and a point not on that line, there is a unique line through
the point parallel to the original line.

```lean
def ParallelPostulate
  (LiesOn : Point → Line → Prop) : Prop :=
  ∀ line P, ¬ (LiesOn P line) →
    ∃! parallelLine,
      (LiesOn P parallelLine) ∧
      (Parallel LiesOn line parallelLine)
```

Third: There exist four distinct points, no three of which are collinear.

```lean
def NonDegeneracy
  (LiesOn : Point → Line → Prop) : Prop :=
  ∃ A B C D : Point,
    (AllDistinct4 A B C D) ∧
    (No3Collinear4 LiesOn A B C D)
```

We can combine these three axioms to define an affine plane:

```lean
def IsAffinePlane
  (LiesOn : Point → Line → Prop) : Prop :=
  (UniqueJoiningLine LiesOn) ∧
  (ParallelPostulate LiesOn) ∧
  (NonDegeneracy LiesOn)
```

# Theorems

## Theorem 1: Parallelism is an Equivalence Relation

Moorhouse focuses on transitivity, and says that reflexivity and
symmetry follow from the definition. However, in our treatment below,
we'll provide complete proofs for all three.

We want to show that parallelism is an equivalence relation on lines.
Parallelism is:

* reflexive: every line is parallel to itself
* symmetric: if `line1` is paralle to `line2` then `line2` is parallel
  to `line1`
* transitive: if `line1` is parallel to `line2`, and `line2` is parallel
  to `line3`, then `line1` is parallel to `line3`

Reflexivity can be proven very simply as a property of the definition
of parallelism, recalling that a line is parallel to itself:

```lean
lemma parallel_reflexivity
  (LiesOn : Point → Line → Prop)
  (line : Line) :
  Parallel LiesOn line line := by
    rw [Parallel]
    left
    rfl
```

The symmetric property:

```lean
lemma nonintersecting_symmetry
  (LiesOn : Point → Line → Prop)
  (line1 line2 : Line)
  (h_n12 : NonIntersecting LiesOn line1 line2) :
  NonIntersecting LiesOn line2 line1 := by
    rw [NonIntersecting] at h_n12
    rw [NonIntersecting]
    rw [Meets] at h_n12
    rw [Meets]
    intro h_meet21
    apply h_n12
    rcases h_meet21 with ⟨point, hp2, hp1⟩
    exact ⟨point, hp1, hp2⟩

lemma parallel_symmetry
  (LiesOn : Point → Line → Prop)
  (line1 line2 : Line)
  (h_p12 : Parallel LiesOn line1 line2) :
  Parallel LiesOn line2 line1 := by
    rw [Parallel] at h_p12
    rw [Parallel]
    rcases h_p12 with h_eq | h_nonintersecting
    . left
      exact h_eq.symm
    . right
      exact (nonintersecting_symmetry
               LiesOn
               line1 line2
               h_nonintersecting)
```

And finally, transitivity:

```lean
lemma parallel_transitivity
  (LiesOn : Point → Line → Prop)
  (h_parallel : ParallelPostulate LiesOn)
  (line1 line2 line3 : Line)
  (h_p12 : Parallel LiesOn line1 line2)
  (h_p23 : Parallel LiesOn line2 line3) :
  Parallel LiesOn line1 line3 := by
  sorry
```

We can use all three properties to build the full equivalence relation,
which is defined inside Lean to collect the three properties.

```lean
theorem parallel_equivalence
  (LiesOn : Point → Line → Prop)
  (h_parallel : ParallelPostulate LiesOn) :
  Equivalence (Parallel LiesOn) := by
    constructor
    . exact parallel_reflexivity LiesOn
    . intro line1 line2
      exact parallel_symmetry LiesOn line1 line2
    . intro line1 line2 line3
      exact parallel_transitivity
        LiesOn h_parallel
        line1 line2 line3
```

# References

* Eric Moorhouse, [_Affine Planes: An Introduction to Axiomatic Geometry_](https://ericmoorhouse.org/handouts/affine_planes.pdf), course notes, University of Wyoming.
