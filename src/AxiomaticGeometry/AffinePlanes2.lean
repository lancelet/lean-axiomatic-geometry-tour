import VersoManual

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

#doc (Manual) "Affine Planes" =>

This chapter is a development of the [incidence geometry][incidence_geometry] representation of
an [affine plane][affine_plane].

An [affine plane][affine_plane] is ordinary flat geometry stripped down to points, lines and
parallelism. There are no distances or angles. There are also no coordinate systems yet. Instead,
we'll be dealing only with the primitive mathematical objects.

# Primitives

Let's start by defining an [incidence structure][incidence_structure], which describes the types
of our points and lines, and what it means for a point to be incident on a line.

```lean
structure IncidenceStructure where
  Point  : Type
  Line   : Type
  LiesOn : Point → Line → Prop
```

In Lean, this means:
* `Point` is some type, but we are not saying which type exactly.
* `Line` is also some type, without saying which.
* `LiesOn` is the incidence relation of the structure: a point may or may not lie on a line.

![Basic objects on an affine plane](figures/incidence.svg)

They are grouped into a structure so that Lean knows that the types for `Point` and `Line` do not
change while we're referencing that structure. It's possible to construct things without this, but
everything becomes more verbose.

`LiesOn` deserves extra attention. Its type, `Point → Line → Prop` means it takes a point and a line
and returns a `Prop`. `Prop`, short for proposition, is Lean's type for statements that are either
true or false. So `LiesOn A ℓ` isn't a value you compute, but rather the claim "point `A` lies on
the line `ℓ`". It's something we prove or assume, never calculate.

## Variable names

In this chapter, I'll use:
* `A`, `B`, `C`, … for points.
* `ℓ`, `m`, `n`, … for lines.

But you can mouse-over the Lean code blocks to see the types if they are ever uncertain.

# Definitions

Before we can talk about axioms, we need some definitions that we use to describe them.

## Collinearity of points

Three points are collinear if all of them lie on the same line. For example, in the illustration
below, `A`, `B`, and `C` all lie on one common line, `ℓ`:

![Three collinear points A, B and C on a common line](figures/collinear.svg)

We can describe this in Lean by an existential statement whose body is a logical conjunction. There
exists a line, `ℓ`, such that `A` lies on the line _and_ `B` lies on the line _and_ `C` lies on the line:

```lean
def Collinear {G : IncidenceStructure}
  (A B C : G.Point) : Prop :=
    ∃ ℓ,
      (G.LiesOn A ℓ) ∧
      (G.LiesOn B ℓ) ∧
      (G.LiesOn C ℓ)
```

The new Lean notation here is relatively self-explanatory:
* `{G : IncidenceStructure}`: `G` is passed as an implicit parameter.
* `(A B C : G.Point)`: `A`, `B`, and `C` are all points in the incidence structure.
* `∃ ℓ`: there exists a line `ℓ`. `∃` is the existential quantifier.
* `∧`: "and", or logical conjunction.

## Intersection of lines

Two lines intersect when there is a point that lies on both.

![Two intersecting lines](figures/intersection.svg)

Again this is an existential whose body is a logical conjunction. There exists a point that lies on
both lines.

```lean
def Intersecting {G : IncidenceStructure}
  (ℓ m : G.Line) : Prop :=
    ∃ A,
      (G.LiesOn A ℓ) ∧
      (G.LiesOn A m)
```

A subtlety here is that the point `A` does not have to be unique. For example, a line intersects
itself at every point on the line.

## Non-intersection of lines

Taking the negation, lines are non-intersecting if they do not intersect:

```lean
def NonIntersecting {G : IncidenceStructure}
  (ℓ m : G.Line) : Prop :=
    ¬ (Intersecting ℓ m)
```

The new notation here is `¬`, which means "not", or logical negation.

## Parallel lines

Next we have parallelism. In a plane, two lines are parallel if they:
* are the same line, or
* do not intersect.

This is not always true of lines in other spaces. For example, two lines in 3D space may be
non-parallel yet fail to intersect. But it is true for the affine plane.

```lean
def Parallel {G : IncidenceStructure}
  (ℓ m : G.Line) : Prop :=
    (ℓ = m) ∨
    (NonIntersecting ℓ m)
```

The new notation here is `∨`, which means "or", or logical disjunction.

## Helper definitions

Finally, we have some small definitions that help with the axioms but are more straightforward.

First, four points that are all distinct (i.e. no point is equal to any of the others):

```lean
def AllDistinct4 {G : IncidenceStructure}
  (A B C D : G.Point) : Prop :=
    (A ≠ B) ∧
    (A ≠ C) ∧
    (A ≠ D) ∧
    (B ≠ C) ∧
    (B ≠ D) ∧
    (C ≠ D)
```

And the statement that no three of any four points are collinear:

```lean
def No3Collinear4 {G : IncidenceStructure}
  (A B C D : G.Point) : Prop :=
    ¬ (Collinear A B C) ∧
    ¬ (Collinear A B D) ∧
    ¬ (Collinear A C D) ∧
    ¬ (Collinear B C D)
```

And unique existence. This is something I've redefined based on the example in Lean's mathlib. It is
the existential quantifier strengthened with uniqueness:

```lean
def ExistsUnique {α : Sort u} (p : α → Prop) : Prop :=
  ∃ x, (p x) ∧ (∀ y, p y → y = x)

open Lean in
macro "∃! " xs:explicitBinders ", " b:term : term => do
  return ⟨← expandExplicitBinders ``ExistsUnique xs b⟩
```

"There exists exactly one value such that…"

# Axioms

We now have the machinery we need to state the affine plane axioms.

## A unique line joins two distinct points axiom

Given any two distinct points, they are joined by a unique line.

![Two points are joined by a unique line](figures/joining_line.svg)

```lean
def UniqueJoiningLine (G : IncidenceStructure) : Prop :=
  ∀ A B, A ≠ B →
    ∃! ℓ,
      (G.LiesOn A ℓ) ∧
      (G.LiesOn B ℓ)
```

## The parallel axiom

Given a line and a point not on that line, there is a unique line through the point which
is parallel to the original line.

![The unique line m through A, parallel to ℓ](figures/parallel.svg)

```lean
def ParallelAxiom (G : IncidenceStructure) : Prop :=
  ∀ ℓ A, ¬ (G.LiesOn A ℓ) →
    ∃! m,
      (G.LiesOn A m) ∧
      (Parallel ℓ m)
```

## Non-degeneracy axiom

In an affine plane, there exist four distinct points, no three of which are collinear.

![Four points, no three collinear](figures/nondegeneracy.svg)

```lean
def NonDegeneracy (G : IncidenceStructure) : Prop :=
  ∃ A B C D : G.Point,
    (AllDistinct4  A B C D) ∧
    (No3Collinear4 A B C D)
```

## Affine plane definition

We can combine the three axioms to produce the full definition of an affine plane.

```lean
def IsAffinePlane {G : IncidenceStructure} : Prop :=
  (UniqueJoiningLine G) ∧
  (ParallelAxiom     G) ∧
  (NonDegeneracy     G)
```

# Theorems

Theorems are correct logical claims that we can derive from the axioms by logical deduction.

## Parallelism is an equivalence relation

Parallelism is an equivalence relation on lines. That means parallelism is:
* reflexive: every line is parallel to itself.
* symmetric: if `ℓ` is parallel to `m` then `m` is parallel to `ℓ`.
* transitive: if `ℓ` is parallel to `m` and `m` is parallel to `n`, then `ℓ` is parallel to `n`.

We can prove each of these separately and then combine them into an equivalence relation.

Overall this depends on the `ParallelAxiom` and the basic definitions.

### Reflexivity

Reflexivity comes from the definition of parallelism, because a line is parallel to itself.

```lean
theorem parallel_refl {G : IncidenceStructure}
  (ℓ : G.Line)
  : Parallel ℓ ℓ := by
    left
    rfl
```

This is a Lean tactic, constructing a term of type `Parallel ℓ ℓ`. Tactics are too complicated
a topic to describe fully here. Please see the Lean documentation.

The important thing to understand is that we are constructing a value of type `Parallel ℓ ℓ`.
A value of this type is a proof that, in an incidence structure, under the affine plane definition
of parallelism, a line is parallel to itself.

### Symmetry

Symmetry of parallelism depends primarily on symmetry of intersecting lines. So we can start
by proving that intersection and non-intersection are symmetric properties. These are
smaller lemmas we use in the larger proof of symmetry.

We can prove that intersection is symmetric by swapping the order of the lines in the relation.

```lean
theorem intersecting_symm {G : IncidenceStructure}
  (ℓ m : G.Line)
  (hℓm : Intersecting ℓ m)
  : Intersecting m ℓ := by
    obtain ⟨A, hAℓ, hAm⟩ := hℓm
    exact ⟨A, hAm, hAℓ⟩
```

At its core, we have constructed a proof that `Intersecting ℓ m → Intersecting m ℓ`.

We can extend this trivially to the symmetry of non-intersecting lines.

```lean
theorem non_intersecting_symm {G : IncidenceStructure}
  (ℓ m : G.Line)
  (hℓm : NonIntersecting ℓ m)
  : NonIntersecting m ℓ := by
    intro hmℓ
    exact hℓm (intersecting_symm m ℓ hmℓ)
```

Once again, the core proof here is that `NonIntersecting ℓ m → NonIntersecting m ℓ`.

Now the parallelism property is symmetric by two routes: either by the line being parallel to
itself or by the symmetry of non-intersecting lines.

```lean
theorem parallel_symm {G : IncidenceStructure}
  (ℓ m : G.Line)
  (hℓm : Parallel ℓ m)
  : Parallel m ℓ := by
    rcases hℓm with heq | hni
    -- left branch: the lines are equal
    . left
      exact heq.symm
    -- right branch: non-intersection symmetry
    . right
      exact non_intersecting_symm ℓ m hni
```

As before, the core proof is that `Parallel ℓ m → Parallel m ℓ`.

### Transitivity

Again we need a few small lemmas for the final proof.

First, we can prove that if two lines do not intersect, then a point which is on one line is not on
the other.

```lean
theorem not_on_parallel {G : IncidenceStructure}
  (ℓ m : G.Line)
  (A : G.Point)
  (hni : NonIntersecting ℓ m)
  (hAℓ : G.LiesOn A ℓ)
  : ¬ (G.LiesOn A m) := by
    intro hAm
    exact hni ⟨A, hAℓ, hAm⟩
```

Next we prove that a parallel line through a point is unique. This is done by positing two
parallel lines and showing they are equal.

```lean
theorem unique_parallel {G : IncidenceStructure}
    (hp : ParallelAxiom G)
    (ℓ m n : G.Line)
    (A : G.Point)
    (hAℓ : ¬ G.LiesOn A ℓ)
    (hm : G.LiesOn A m)
    (hparm : Parallel ℓ m)
    (hn : G.LiesOn A n)
    (hparn : Parallel ℓ n)
    : m = n := by
      obtain ⟨_, _, huniq⟩ := hp ℓ A hAℓ
      exact
        (huniq m ⟨hm, hparm⟩).trans
        (huniq n ⟨hn, hparn⟩).symm
```

(TODO: Factor out transitivity of non-intersection.)

We can then combine these to prove that parallelism is transitive.

```lean
theorem parallel_trans {G : IncidenceStructure}
  (ℓ m n : G.Line)
  (hp : ParallelAxiom G)
  (hℓm : Parallel ℓ m)
  (hmn : Parallel m n)
  : Parallel ℓ n := by
    rcases hℓm with rfl | hni
    . exact hmn
    . rcases hmn with rfl | hmn
      . right
        exact hni
      . by_cases hℓn : ℓ = n
        . left
          exact hℓn
        . right
          intro hmeet
          obtain ⟨A, hAℓ, hAn⟩ := hmeet
          have hAm : ¬ G.LiesOn A m :=
            not_on_parallel ℓ m A hni hAℓ
          exact hℓn
            (unique_parallel hp m ℓ n A hAm
              hAℓ (parallel_symm _ _ (Or.inr hni))
              hAn (Or.inr hmn))
```

### Equivalence relation

We can combine reflexivity, symmetry and transitivity into the full equivalence relation by
just constructing it in Lean.

```lean
theorem parallel_equiv
  (G : IncidenceStructure)
  (hp : ParallelAxiom G)
  : Equivalence (Parallel (G := G)) :=
    { refl  := parallel_refl
      symm  := fun hℓm => parallel_symm _ _ hℓm
      trans := fun hℓm hmn =>
                 parallel_trans _ _ _ hp hℓm hmn }
```

# References

* [Incidence geometry][incidence_geometry], Wikipedia.
* [Incidence structure][incidence_structure], Wikipedia.
* [Affine plane][affine_plane], Wikipedia.

[incidence_geometry]: https://en.wikipedia.org/wiki/Incidence_geometry
[incidence_structure]: https://en.wikipedia.org/wiki/Incidence_structure
[affine_plane]: https://en.wikipedia.org/wiki/Affine_plane
