import VersoManual
import AxiomaticGeometry.Purpose
-- import AxiomaticGeometry.AffinePlanes
import AxiomaticGeometry.AffinePlanes2

open Verso.Genre Manual

set_option pp.rawOnError true

#doc (Manual) "Axiomatic Geometry" =>

A literate Lean 4 tour of axiomatic geometry. I go where the wind takes me. Every proof in the text
is checked by Lean as part of the build.

{include 1 AxiomaticGeometry.Purpose}
{include 1 AxiomaticGeometry.AffinePlanes2}
