(*************************************************************************)
(* Coq-Polyhedra: formalizing convex polyhedra in Coq/SSReflect          *)
(*                                                                       *)
(* (c) Copyright 2016, Xavier Allamigeon (xavier.allamigeon at inria.fr) *)
(*                     Ricardo D. Katz (katz at cifasis-conicet.gov.ar)  *)
(* All rights reserved.                                                  *)
(* You may distribute this file under the terms of the CeCILL-B license  *)
(*************************************************************************)

Require Import Recdef.
From mathcomp Require Import all_ssreflect ssralg ssrnum zmodp perm matrix mxalgebra vector.
Require Import extra_misc inner_product vector_order extra_matrix row_submx polyhedron.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Local Open Scope ring_scope.
Import GRing.Theory Num.Theory.

Section Simplex.

Variable R: realFieldType.
Variable m n: nat.

Variable A : 'M[R]_(m,n).
Variable b : 'cV[R]_m.

Section Prebasis.

Inductive prebasis : predArgType := Prebasis (pb: {set 'I_m}) of (#|pb| == n)%N.

Coercion set_of_prebasis pb := let: Prebasis s _ := pb in s.
Canonical prebasis_subType := [subType for set_of_prebasis].
Definition prebasis_eqMixin := Eval hnf in [eqMixin of prebasis by <:].
Canonical prebasis_eqType := Eval hnf in EqType prebasis prebasis_eqMixin.
Definition prebasis_choiceMixin := [choiceMixin of prebasis by <:].
Canonical prebasis_choiceType := Eval hnf in ChoiceType prebasis prebasis_choiceMixin.
Definition prebasis_countMixin := [countMixin of prebasis by <:].
Canonical prebasis_countType := Eval hnf in CountType prebasis prebasis_countMixin.
Canonical prebasis_subCountType := [subCountType of prebasis].

Lemma prebasis_card (pb: prebasis) : #|pb| = n.
Proof.
by move/eqP: (valP pb).
Qed.

Definition matrix_of_prebasis (p: nat) (M: 'M[R]_(m,p)) (bas: prebasis) :=
  (castmx (prebasis_card bas, erefl p) (row_submx M bas)).

Definition prebasis_enum : seq prebasis := pmap insub (enum [set pb: {set 'I_m} | #|pb| == n]).

Lemma prebasis_enum_uniq : uniq prebasis_enum.
Proof.
by apply: pmap_sub_uniq; apply: enum_uniq.
Qed.

Lemma mem_prebasis_enum pb : pb \in prebasis_enum.
Proof.
rewrite mem_pmap_sub mem_enum in_set.
by move/eqP: (prebasis_card pb).
Qed.

Definition prebasis_finMixin :=
  Eval hnf in UniqFinMixin prebasis_enum_uniq mem_prebasis_enum.
Canonical prebasis_finType := Eval hnf in FinType prebasis prebasis_finMixin.
Canonical prebasis_subFinType := Eval hnf in [subFinType of prebasis].

End Prebasis.

Section Basis.

Definition is_basis (bas: prebasis) := (matrix_of_prebasis A bas) \in unitmx.

Inductive basis : predArgType := Basis (bas: prebasis) of is_basis bas.
Coercion prebasis_of_basis bas := let: Basis s _ := bas in s.
Canonical basis_subType := [subType for prebasis_of_basis].
Definition basis_eqMixin := Eval hnf in [eqMixin of basis by <:].
Canonical basis_eqType := Eval hnf in EqType basis basis_eqMixin.
Definition basis_choiceMixin := [choiceMixin of basis by <:].
Canonical basis_choiceType := Eval hnf in ChoiceType basis basis_choiceMixin.
Definition basis_countMixin := [countMixin of basis by <:].
Canonical basis_countType := Eval hnf in CountType basis basis_countMixin.
Canonical basis_subCountType := [subCountType of basis].

Lemma matrix_of_basis_in_unitmx (bas: basis) : (matrix_of_prebasis A bas) \in unitmx.
Proof.
by apply: (valP bas).
Qed.

Definition point_of_basis (bas: basis) :=
  (invmx (matrix_of_prebasis A bas)) *m (matrix_of_prebasis b bas).

Definition is_feasible (bas: basis) :=
  let: v := point_of_basis bas in
  (v \in (polyhedron A b)).

Definition basis_enum : seq basis := pmap insub [seq bas <- prebasis_enum | is_basis bas].

Lemma basis_enum_uniq : uniq basis_enum.
Proof.
by apply: pmap_sub_uniq; apply: filter_uniq; apply: prebasis_enum_uniq.
Qed.

Lemma mem_basis_enum pb : pb \in basis_enum.
Proof.
rewrite mem_pmap_sub mem_filter.
apply/andP; split; last by apply: mem_prebasis_enum.
by apply: matrix_of_basis_in_unitmx.
Qed.

Definition basis_finMixin :=
  Eval hnf in UniqFinMixin basis_enum_uniq mem_basis_enum.
Canonical basis_finType := Eval hnf in FinType basis basis_finMixin.
Canonical basis_subFinType := Eval hnf in [subFinType of basis].

End Basis.

Section FeasibleBasis.

Inductive feasible_basis : predArgType := FeasibleBasis (bas: basis) of is_feasible bas.

Coercion basis_of_feasible_basis bas := let: FeasibleBasis s _ := bas in s.
Canonical feasible_basis_subType := [subType for basis_of_feasible_basis].
Definition feasible_basis_eqMixin := Eval hnf in [eqMixin of feasible_basis by <:].
Canonical feasible_basis_eqType := Eval hnf in EqType feasible_basis feasible_basis_eqMixin.
Definition feasible_basis_choiceMixin := [choiceMixin of feasible_basis by <:].
Canonical feasible_basis_choiceType := Eval hnf in ChoiceType feasible_basis feasible_basis_choiceMixin.
Definition feasible_basis_countMixin := [countMixin of feasible_basis by <:].
Canonical feasible_basis_countType := Eval hnf in CountType feasible_basis feasible_basis_countMixin.
Canonical feasible_basis_subCountType := [subCountType of feasible_basis].

Lemma feasible_basis_is_feasible (bas : feasible_basis) :
  is_feasible bas.
Proof.
by apply: (valP bas).
Qed.

Lemma feasible_basis_feasibility (bas : feasible_basis): feasible A b.
Proof.
move: (feasible_basis_is_feasible bas).
by exists (point_of_basis bas).
Qed.

Definition feasible_basis_enum : seq feasible_basis := pmap insub [seq bas <- basis_enum | is_feasible bas].

Lemma feasible_basis_enum_uniq : uniq feasible_basis_enum.
Proof.
by apply: pmap_sub_uniq; apply: filter_uniq; apply: basis_enum_uniq.
Qed.

Lemma mem_feasible_basis_enum bas : bas \in feasible_basis_enum.
Proof.
rewrite mem_pmap_sub mem_filter.
apply/andP; split; last by apply: mem_basis_enum.
by apply: feasible_basis_is_feasible.
Qed.

Definition feasible_basis_finMixin :=
  Eval hnf in UniqFinMixin feasible_basis_enum_uniq mem_feasible_basis_enum.
Canonical feasible_basis_finType := Eval hnf in FinType feasible_basis feasible_basis_finMixin.
Canonical feasible_basis_subFinType := Eval hnf in [subFinType of feasible_basis].

Lemma basis_subset_of_active_ineq (bas : basis) :
   (bas \subset (active_ineq A b (point_of_basis bas))).
Proof.
set x := point_of_basis bas.
apply/subsetP => i Hi.
rewrite inE; apply/eqP.
have H: (matrix_of_prebasis A bas) *m x = (matrix_of_prebasis b bas).
- rewrite mulmxA mulmxV; last by apply: matrix_of_basis_in_unitmx.
  by rewrite mul1mx.
move/matrixP/(_ (cast_ord (prebasis_card bas) (enum_rank_in Hi i)) 0): H. 
rewrite castmxE cast_ordK cast_ord_id row_submx_mxE enum_rankK_in //.
by rewrite -{1}[x](castmx_id (erefl n, erefl 1%N)) -castmx_mul castmxE /= cast_ordK cast_ord_id -row_submx_mul row_submx_mxE enum_rankK_in //.
Qed.

Lemma active_ineq_in_point_of_basis (bas : basis) :
  (matrix_of_prebasis A bas <= active_ineq_mx A b (point_of_basis bas))%MS.
Proof.
rewrite eqmx_cast; apply/row_subP => i.
rewrite row_submx_row.
move/subsetP/(_ _ (enum_valP i)): (basis_subset_of_active_ineq bas) => Hbas_i.
suff ->: row (enum_val i) A = row (enum_rank_in Hbas_i (enum_val i)) (active_ineq_mx A b (point_of_basis bas)) by apply: row_sub.
by rewrite row_submx_row enum_rankK_in //.
Qed.

Lemma feasible_point_of_basis_is_extreme (bas : basis) :
    is_feasible bas -> is_extreme (point_of_basis bas) (polyhedron A b: _ -> bool).
Proof.
rewrite /is_feasible.
move => Hfeas.
apply/extremality_active_ineq/andP; split; first by done.
- apply/eqP; move: (mxrank_unit (matrix_of_basis_in_unitmx bas)).
  apply: contra_eq => HrkAI.
  have H: (\rank (active_ineq_mx A b (point_of_basis bas)) < n)%N.
  + rewrite ltn_neqAle; apply/andP.
    split; by [done | apply: (rank_leq_col (active_ineq_mx A b (point_of_basis bas)))].
  move/leq_of_leqif: (mxrank_leqif_eq (active_ineq_in_point_of_basis bas)) => H'.
  by move: (leq_ltn_trans H' H); rewrite ltn_neqAle; move/andP => [? _].
Qed.

Lemma basis_extraction (I : {set 'I_m}) :
    \rank (row_submx A I) = n -> exists bas: basis, (bas \subset I).
Proof.
move => Hrk.
move: (leqnn n); rewrite -{2}Hrk; move/row_base_correctness.
set bas := (build_row_base _ _ _); move => [? /eqP Hcard Hrk'].
pose pb := Prebasis Hcard.
have Hbas : is_basis pb.
- by rewrite /is_basis -row_free_unit -row_leq_rank rank_castmx Hrk' leqnn.
by exists (Basis Hbas).
Qed.

Lemma basis_subset_active_ineq_eq (bas : basis) (x : 'cV[R]_n) :
  bas \subset (active_ineq A b x) -> x = point_of_basis bas.
Proof.
move => H.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
suff: (matrix_of_prebasis A bas) *m x = matrix_of_prebasis b bas.
- by move/(congr1 (mulmx (invmx (matrix_of_prebasis A bas)))); rewrite mulmxA mulVmx // mul1mx.
- apply/row_matrixP => i.
  rewrite row_mul row_castmx /= row_submx_row -row_mul row_castmx /= row_submx_row.
  set i' := enum_val _; move/subsetP/(_ i' (enum_valP _)): H.
  by apply: active_ineq_eq.
Qed.

Lemma extreme_point_is_feasible_point_of_basis (x : 'cV[R]_n) :
    is_extreme x (polyhedron A b: _ -> bool) -> exists bas: feasible_basis, x = point_of_basis bas.
Proof.
move/extremality_active_ineq/andP => [H /eqP/basis_extraction [bas /basis_subset_active_ineq_eq H']].
move: (H); rewrite {}H' => Hbas.
by exists (FeasibleBasis Hbas).
Qed.

End FeasibleBasis.

Section Cost.

Implicit Types c : 'cV[R]_n.
Implicit Types bas : basis.
Implicit Types x : 'cV[R]_n.
Implicit Types u : 'cV[R]_m.

Definition reduced_cost_of_basis c bas :=
  (invmx (matrix_of_prebasis A bas)^T) *m c.

Definition reduced_cost_of_basis_def c bas :
  (matrix_of_prebasis A bas)^T *m (reduced_cost_of_basis c bas) = c.
Proof.
rewrite /reduced_cost_of_basis mulmxA mulmxV; last by rewrite unitmx_tr; apply: (matrix_of_basis_in_unitmx bas).
by rewrite mul1mx.
Qed.

Definition ext_reduced_cost_of_basis c bas :=
  let: u := reduced_cost_of_basis c bas in
  \col_i (if (@idP (i \in bas)) is ReflectT Hi then
            u (cast_ord (prebasis_card bas) (enum_rank_in Hi i)) 0
          else 0).

Lemma ext_reduced_cost_of_basis_in_bas c bas i (Hi : (i \in bas)) :
  let: j := cast_ord (prebasis_card bas) (enum_rank_in Hi i) in
  (ext_reduced_cost_of_basis c bas) i 0 = (reduced_cost_of_basis c bas) j 0.
Proof.
rewrite /ext_reduced_cost_of_basis mxE.
case: {-}_ /idP => [Hi' |]; last by done.
suff ->: enum_rank_in Hi i = enum_rank_in Hi' i by done.
- apply: enum_val_inj; by do 2![rewrite enum_rankK_in //].
Qed.

Lemma ext_reduced_cost_of_basis_notin_bas c bas i :
  (i \notin bas) -> (ext_reduced_cost_of_basis c bas) i 0 = 0.
Proof.
move/negP => H; rewrite /ext_reduced_cost_of_basis mxE.
by case: {-}_ /idP => [ ? | _].
Qed.

Lemma non_neg_reduced_cost_equiv c bas :
  ((ext_reduced_cost_of_basis c bas) >=m 0) = ((reduced_cost_of_basis c bas) >=m 0).
Proof.
apply/idP/idP => [/forallP H | /forallP H].
- apply/forallP => i; rewrite mxE.
  set j := cast_ord (esym (prebasis_card bas)) i.
  move: (ext_reduced_cost_of_basis_in_bas c (enum_valP j)).
  rewrite enum_valK_in /j cast_ordKV => <-.
  by move/(_ (enum_val j)): H; rewrite mxE.
- apply/forallP => i; rewrite mxE; case: (boolP (i \in bas)) => [Hi | Hi].
  + rewrite (ext_reduced_cost_of_basis_in_bas c Hi).
    by set j := cast_ord _ _; move/(_ j): H; rewrite mxE.
  + by rewrite (ext_reduced_cost_of_basis_notin_bas c Hi).
Qed.

Lemma ext_reduced_cost_of_basis_def c bas :
  A^T *m (ext_reduced_cost_of_basis c bas) = c.
Proof.
apply/colP => i; rewrite !mxE.
rewrite (bigID (fun j => j \in bas)) /= [X in _ + X]big1;
  last by move => j /ext_reduced_cost_of_basis_notin_bas ->; rewrite mulr0.
rewrite addr0.
rewrite (reindex (@enum_val _ (mem bas))) /=;
        last by apply: (enum_val_bij_in (enum_valP (cast_ord (esym (prebasis_card bas)) i))).

rewrite (eq_bigl predT) /=; last by move => k /=; apply: (enum_valP k).
rewrite (reindex (cast_ord (esym (prebasis_card bas)))) /=; last first.
- apply: onW_bij; apply: inj_card_bij;
  by [apply: cast_ord_inj | rewrite 2!card_ord (prebasis_card bas)].
 
rewrite -[in RHS](reduced_cost_of_basis_def c bas) mxE.
apply: eq_bigr => j _; apply: congr2.
- by rewrite trmx_cast /= castmxE /= cast_ord_id !mxE.
- set k := cast_ord _ _; rewrite (ext_reduced_cost_of_basis_in_bas c (enum_valP k)).
  by rewrite enum_valK_in cast_ordKV.
Qed.


Lemma ext_reduced_cost_dual_feasible c bas :
  let: u := ext_reduced_cost_of_basis c bas in
  (reduced_cost_of_basis c bas) >=m 0 = (u \in dual_polyhedron A c).
Proof.
rewrite inE.
move/eqP: (ext_reduced_cost_of_basis_def c bas) ->; rewrite /=.
by symmetry; apply: non_neg_reduced_cost_equiv.
Qed.

Lemma compl_slack_cond_on_basis c bas :
  let: x := point_of_basis bas in
  let: u := ext_reduced_cost_of_basis c bas in
  compl_slack_cond A b x u.
Proof.
set x := point_of_basis bas.
set u := ext_reduced_cost_of_basis c bas.
apply/compl_slack_condP => i.
case: (boolP (i \in bas)) => [Hi | Hi].
- by move/subsetP/(_ i Hi): (basis_subset_of_active_ineq bas); rewrite inE => /eqP ->; right.
- by move: (ext_reduced_cost_of_basis_notin_bas c Hi) => ->; left.
Qed.

Lemma optimal_basis c (bas : feasible_basis) :
  let: x := point_of_basis bas in
  (reduced_cost_of_basis c bas) >=m 0 -> optimal_solution A b c x.
Proof.
set x := point_of_basis bas.
set u := ext_reduced_cost_of_basis c bas.
rewrite ext_reduced_cost_dual_feasible => Hu.
apply: (duality_gap_eq0_optimality (feasible_basis_is_feasible bas) Hu).
move: Hu; rewrite inE; move/andP => [/eqP Hu _].
rewrite (compl_slack_cond_duality_gap_eq0 Hu) //.
by apply: compl_slack_cond_on_basis.
Qed.

Definition direction bas i :=
  let: ei := (delta_mx i 0):'cV_n in
  (invmx (matrix_of_prebasis A bas)) *m ei.

Lemma direction_neq0 bas i: direction bas i != 0.
Proof.
apply: contraT; rewrite negbK.
move/eqP/(congr1 (mulmx (matrix_of_prebasis A bas))).
rewrite mulmxA mulmxV; last by apply: matrix_of_basis_in_unitmx.
rewrite mul1mx mulmx0.
move/matrixP/(_ i 0); rewrite !mxE !eq_refl /=.
move/eqP; rewrite pnatr_eq0.
by move: (oner_neq0 R).
Qed.

Lemma direction_improvement c bas i:
  let: u := reduced_cost_of_basis c bas in
  let: d := direction bas i in
  u i 0 < 0 -> '[c, direction bas i] < 0.
Proof.
by rewrite vdot_mulmx trmx_inv vdot_delta_mx.
Qed.

Lemma unbounded_certificate_on_basis c (bas : feasible_basis) i:
  let: u := reduced_cost_of_basis c bas in
  let: d := direction bas i in
  feasible_direction A d -> u i 0 < 0 -> unbounded A b c.
Proof.
set d := direction _ _.
move => Hd Hui. 
apply: (unbounded_certificate (d:=d)); try by [ apply: (feasible_basis_feasibility bas) | done].
by rewrite /d vdot_mulmx trmx_inv vdot_delta_mx.
Qed. 

Lemma direction_prop (bas : basis) (i : 'I_n) (j : 'I_m) :
  let: d := direction bas i in
  j \in bas -> (A *m d) j 0 = (j == enum_val (cast_ord (esym (prebasis_card bas)) i))%:R.
Proof.
set d := direction bas i.
move => Hj.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
suff ->: (A *m d) j 0 = ((matrix_of_prebasis A bas) *m d) (cast_ord (prebasis_card bas) (enum_rank_in Hj j)) 0.
- rewrite /d /direction mulmxA mulmxV // mul1mx mxE /= andbT.
  rewrite -{1}[i](cast_ordKV (prebasis_card bas)).
  apply/(congr1 (fun y => (nat_of_bool y)%:R)); apply/idP/idP.
  + move/eqP/cast_ord_inj <-; by rewrite enum_rankK_in //.
  + by move/eqP => H; rewrite {}[X in enum_rank_in _ X]H enum_valK_in.
rewrite /matrix_of_prebasis -{2}[d](castmx_id (erefl n, erefl (1%N))).
by rewrite -castmx_mul castmxE /= cast_ordK cast_ord_id -row_submx_mul row_submx_mxE enum_rankK_in //.
Qed.

Lemma mulmx_direction (bas : basis) (i : 'I_n):
  let: d := direction bas i in
  (row_submx A (bas :\ enum_val (cast_ord (esym (prebasis_card bas)) i))) *m d = 0.
Proof.
rewrite -row_submx_mul.
apply/colP => j; rewrite mxE [X in _ = X]mxE.
move: (enum_valP j); rewrite in_setD1; move/andP => [Hj Hj'].
rewrite direction_prop //.
by move/negbTE: Hj ->.
Qed.

End Cost.

Section Lexicographic_rule.

Variable s : 'S_m.

Definition b_aux := row_mx b (-(perm_mx s)).

Definition point_of_basis_aux bas :=
  (invmx (matrix_of_prebasis A bas)) *m (matrix_of_prebasis b_aux bas).

Lemma rel_points_of_basis bas :
  point_of_basis bas = col 0 (point_of_basis_aux bas).
Proof.
rewrite /point_of_basis_aux col_mul /matrix_of_prebasis.
rewrite row_submx_row_mx cast_row_mx.
set M := (row_mx _ _).
suff ->: (col 0 M) = castmx (prebasis_card bas, erefl 1%N) (row_submx b bas);
  first by done.
by apply/colP => i; rewrite 2!mxE split1 unlift_none.
Qed.

Section LexFeasibleBasis.

Definition is_lex_feasible (bas : basis) := 
  let: x := point_of_basis_aux bas in 
  [forall i, ((row i A) *m x) >=lex (row i b_aux)].

Inductive lex_feasible_basis : predArgType := LexFeasibleBasis (bas: basis) of is_lex_feasible bas.
Coercion basis_of_lex_feasible_basis bas := let: LexFeasibleBasis s _ := bas in s.
Canonical lex_feasible_basis_subType := [subType for basis_of_lex_feasible_basis].
Definition lex_feasible_basis_eqMixin := Eval hnf in [eqMixin of lex_feasible_basis by <:].
Canonical lex_feasible_basis_eqType := Eval hnf in EqType lex_feasible_basis lex_feasible_basis_eqMixin.
Definition lex_feasible_basis_choiceMixin := [choiceMixin of lex_feasible_basis by <:].
Canonical lex_feasible_basis_choiceType := Eval hnf in ChoiceType lex_feasible_basis lex_feasible_basis_choiceMixin.
Definition lex_feasible_basis_countMixin := [countMixin of lex_feasible_basis by <:].
Canonical lex_feasible_basis_countType := Eval hnf in CountType lex_feasible_basis lex_feasible_basis_countMixin.
Canonical lex_feasible_basis_subCountType := [subCountType of lex_feasible_basis].

Lemma lex_feasible_basis_is_lex_feasible (bas : lex_feasible_basis) :
  is_lex_feasible bas.
Proof.
by apply: (valP bas).
Qed.

Lemma lex_feasible_basis_is_feasible (bas : lex_feasible_basis) :
  is_feasible bas.
Proof.
rewrite /is_feasible (rel_points_of_basis bas).
apply/forallP => i; rewrite -col_mul mxE.
move/forallP/(_ i)/lex_ord0: (lex_feasible_basis_is_lex_feasible bas).
by rewrite -row_mul mxE [X in _ <= X]mxE mxE split1 unlift_none /=.
Qed.

Definition lex_feasible_basis_enum : seq lex_feasible_basis := pmap insub [seq bas <- basis_enum | is_lex_feasible bas].

Lemma lex_feasible_basis_enum_uniq : uniq lex_feasible_basis_enum.
Proof.
by apply: pmap_sub_uniq; apply: filter_uniq; apply: basis_enum_uniq.
Qed.

Lemma mem_lex_feasible_basis_enum bas : bas \in lex_feasible_basis_enum.
Proof.
rewrite mem_pmap_sub mem_filter.
apply/andP; split; last by apply: mem_basis_enum.
by apply: lex_feasible_basis_is_lex_feasible.
Qed.

Definition lex_feasible_basis_finMixin :=
  Eval hnf in UniqFinMixin lex_feasible_basis_enum_uniq mem_lex_feasible_basis_enum.
Canonical lex_feasible_basis_finType := Eval hnf in FinType lex_feasible_basis lex_feasible_basis_finMixin.
Canonical lex_feasible_basis_subFinType := Eval hnf in [subFinType of lex_feasible_basis].

End LexFeasibleBasis.

Variable c : 'cV[R]_n.

Implicit Types bas : lex_feasible_basis.

Lemma lex_optimal_basis bas :
  let: v := point_of_basis_aux bas in
  let: u := reduced_cost_of_basis c bas in
  u >=m 0 ->
  forall x, ([forall i, ((row i A) *m x) >=lex (row i b_aux)] ->
  (c^T *m x) >=lex (c^T *m v)).
Proof.
set u := reduced_cost_of_basis c bas.
set v := point_of_basis bas.
move => Hu x Hx.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
have ->: c = (matrix_of_prebasis A bas)^T *m u
  by rewrite mulmxA mulmxV;
     [rewrite mul1mx | rewrite unitmx_tr].
rewrite trmx_mul trmxK -mulmxA [X in _ *m X]mulmxA mulmxV // mul1mx.
rewrite -mulmxA 2!mulmx_sum_row big_seq [X in _ <=lex X]big_seq.
apply: (big_ind2 (fun u v => u <=lex v)); try do [apply: lex_refl | apply: lex_add].
- move => i _; rewrite mxE; apply: lex_nnscalar.
  + by move/forallP/(_ i): Hu; rewrite mxE.
  + rewrite row_mul row_castmx [X in (X *m _)]row_castmx 2!castmx_id 2!row_submx_row.
    by move/forallP: Hx.
Qed.

Definition lex_gap bas (d:'cV_n) j :=
  let: x := point_of_basis_aux bas in
  ((A *m d) j 0)^-1 *: ((row j b_aux) - ((row j A) *m x)).

Definition lex_min_gap_lex_nat bas i :=
  let: d := direction bas i in
  let: J := [ seq j <- (enum 'I_m) | (A *m d) j 0 < 0 ] in
  let: lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- J] in
  find (fun j => (j \in J) && (lex_min_gap == lex_gap bas d j)) (enum 'I_m).

Lemma lex_min_gap_lex_bound bas i :
  let: d := direction bas i in
  ~~ (feasible_direction A d) -> (lex_min_gap_lex_nat bas i < m)%N.
Proof.
move => /existsP [k Hk].
rewrite mxE in Hk.
rewrite -[X in (_ < X)%N]size_enum_ord -has_find.
set d := direction bas i.
set J := filter (fun j => (A *m d) j 0 < 0) (enum 'I_m).
set lex_gaps := [seq lex_gap bas d j | j <- J].
have Hlex_gaps : lex_gaps != [::].
+ rewrite -size_eq0 size_map size_eq0 -has_filter.
  apply/hasP; exists k; first by rewrite mem_enum.
  by rewrite ltrNge.
apply/hasP.
move/hasP: (lex_min_seq_eq Hlex_gaps) => [x /mapP [j' Hj' ->]] /= /eqP ->.
exists j'; by [rewrite mem_enum | apply/andP].
Qed.

Variable bas : lex_feasible_basis.
Variable i : 'I_n.
Hypothesis infeas_dir : ~~(feasible_direction A (direction bas i)).

Definition lex_min_gap_lex := Ordinal (lex_min_gap_lex_bound infeas_dir).

Lemma lex_min_gap_lex_properties :
  let: d := direction bas i in
  let: J := [ seq j <- (enum 'I_m) | (A *m d) j 0 < 0 ] in
  let: lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- J] in
  let: j := lex_min_gap_lex in
  (j \in J) && (lex_min_gap == lex_gap bas d j).
Proof.
set d := direction bas i.
set J := filter (fun j => (A *m d) j 0 < 0) (enum 'I_m).
set lex_gaps := [seq lex_gap bas d j | j <- J].
set j_nat := lex_min_gap_lex_nat bas i.
set j := lex_min_gap_lex.
move: (lex_min_gap_lex_bound infeas_dir).
rewrite -[X in (_ < X)%N]size_enum_ord -has_find.
move/(nth_find j).
move: (nth_enum_ord j (lex_min_gap_lex_bound infeas_dir)).
rewrite -/j_nat.
have ->: j_nat = (nat_of_ord j) by rewrite /=.
move/ord_inj ->.
move/andP => [Hj /eqP <-].
by rewrite eq_refl Hj /=.
Qed.

Definition lex_rule :=
  let: j := lex_min_gap_lex in
  j |: (bas :\ (enum_val (cast_ord (esym (prebasis_card bas)) i))).

Lemma lex_min_gap_lex_not_in_basis:
  lex_min_gap_lex \notin bas.
Proof.
set d := direction bas i.
set j := lex_min_gap_lex.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
apply: contraT; rewrite negbK.
move => Hj.
set k := enum_rank_in Hj j.
have Hk: j = enum_val (A := mem bas) k
  by rewrite (enum_rankK_in Hj).
have H: (matrix_of_prebasis A bas *m d) (cast_ord (prebasis_card bas) k) 0 >= 0.
- rewrite mulmxA mulmxV // mul1mx mxE.
  by apply: ler0n.
move: H.
rewrite /matrix_of_prebasis -[d](castmx_id (erefl n, erefl (1%N))).
rewrite -castmx_mul castmxE cast_ordK cast_ord_id -row_submx_mul row_submx_mxE -{}Hk.
move => H.
move/andP: lex_min_gap_lex_properties => [H' _].
move: H'; rewrite -/j mem_filter -/d; move/andP => [H' _].
move/andP: (conj H H').
by rewrite ler_lt_asym.
Qed.

Lemma lex_rule_card : #|lex_rule| == n.
Proof.
rewrite cardsU1 in_setD1 negb_and lex_min_gap_lex_not_in_basis orbT /=.
rewrite cardsD.
move: (enum_valP (cast_ord (esym (prebasis_card bas)) i)).
rewrite -sub1set => Hibas.
move/subset_leq_card: (Hibas).
move/setIidPr: Hibas ->; rewrite cards1 => Hbas.
by rewrite subn1 addnC addn1 prednK // (prebasis_card bas).
Qed.

Definition lex_rule_prebasis := Prebasis lex_rule_card.

Lemma lex_rule_is_basis : is_basis lex_rule_prebasis.
Proof.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
set d := direction bas i.
set j := lex_min_gap_lex.
set J := lex_rule.
 
move/andP: lex_min_gap_lex_properties => [Hj /eqP Hj'].
move: Hj; rewrite mem_filter; move/andP => [Hj _].
rewrite -/j -/d in Hj, Hj'.
 
move: Hbas.
rewrite /is_basis -!row_free_unit -!row_leq_rank !rank_castmx.
rewrite (row_submx_spanD1 A (enum_valP (cast_ord (esym (prebasis_card bas)) i))).
set AIi := row_submx A (bas :\ enum_val (cast_ord (esym (prebasis_card bas)) i)).
set Ai := row (enum_val (cast_ord (esym (prebasis_card bas)) i)) A.
move => HrkI.
 
have HrkIi: (n <= 1+\rank AIi)%N.
+ move: (leq_trans HrkI (leq_of_leqif (mxrank_adds_leqif Ai AIi))).
  move/(leq_add (rank_leq_row Ai)).
  by rewrite addnA [X in (_ <= X + _)%N]addnC -addnA leq_add2l addnC.
 
set Aj := row j A.
rewrite row_submx_spanU1 -/AIi -/j -/Aj;
  last by move: lex_min_gap_lex_not_in_basis;
  apply: contra; rewrite in_setD1; move/andP => [_].
 
have Hw_inter_AIi : (Aj :&: AIi <= (0:'M_n))%MS.
+ apply/rV_subP => ?; rewrite submx0 sub_capmx.
  move/andP => [/sub_rVP [a ->] /submxP [z]].
  move/(congr1 (mulmx^~ d)).
  rewrite -mulmxA -scalemxAl mulmx_direction // mulmx0.
  move/rowP/(_ 0); rewrite mxE [X in _ = X]mxE -row_mul mxE.
  move/eqP; rewrite mulf_eq0.
  move/ltr0_neq0/negbTE: Hj ->; rewrite orbF.
  by move/eqP ->; rewrite scale0r eq_refl.
 
move/leqifP: (mxrank_adds_leqif Aj AIi).
rewrite ifT //; move/eqP ->.
rewrite rank_rV.
suff ->: (Aj != 0); first by done.
+ apply:contraT; rewrite negbK; move/eqP.
  move/(congr1 (mulmx^~ d)); rewrite mul0mx.
  move/rowP/(_ 0); rewrite [X in _ = X]mxE -row_mul mxE => H'.
  by move/ltr0_neq0: Hj; rewrite H' eq_refl.
Qed.

Definition lex_rule_basis := Basis lex_rule_is_basis.

Lemma lex_rule_rel_succ_points :
let: d := direction bas i in
let: v := point_of_basis_aux bas in
let: bas' := lex_rule_basis in
let: v' := point_of_basis_aux bas' in
let: lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0] in
 v' = v + d *m lex_min_gap.
Proof.
set d := direction bas i.
set j := lex_min_gap_lex.
set bas' := lex_rule_basis.
set v := point_of_basis_aux bas.
set v' := point_of_basis_aux bas'.
set lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0].
set u := v + d *m lex_min_gap.
move: (matrix_of_basis_in_unitmx bas) => Hbas.
move: (matrix_of_basis_in_unitmx bas') => Hbas'.
move/andP: lex_min_gap_lex_properties => [Hj /eqP Hj'].
move: Hj; rewrite mem_filter; move/andP => [Hj _].
rewrite -/j -/d in Hj, Hj'.
have Hv: (matrix_of_prebasis A bas) *m v = (matrix_of_prebasis b_aux bas)
  by rewrite mulmxA mulmxV // mul1mx.
move: Hv; rewrite -[v](castmx_id (erefl n, erefl ((1+m)%N))) -castmx_mul.
move/(congr1 (castmx (esym (prebasis_card bas), esym (erefl ((1+m)%N))))); rewrite 2!castmxK => Hv.
 
have Hu': (matrix_of_prebasis A bas') *m u = (matrix_of_prebasis b_aux bas').
- rewrite -[u](castmx_id (erefl n, erefl (1+m)%N)) -castmx_mul.
  apply/(congr1 (castmx (_, _)))/row_matrixP => h.
  rewrite row_mul 2!row_submx_row.
  set k := enum_val h.
  rewrite mulmxDr.
 
  case: (altP (k =P j)) => [-> | H].
  + rewrite -[X in _ + X]row_mul.
    rewrite [X in _ + row _ X]mulmxA row_mul.
    rewrite [X in _ + X *m _]mx11_scalar mul_scalar_mx mxE.
    rewrite /lex_min_gap Hj' scalerA mulfV; last by apply: ltr0_neq0.
    by rewrite scale1r addrC -addrA addNr addr0.
 
  + have HkI: (k \in bas :\ enum_val (cast_ord (esym (prebasis_card bas)) i)).
    * move: (enum_valP h); rewrite in_setU1; move/negbTE: H ->.
      by rewrite /=.
    have HkI': (k \in bas) by move: HkI; rewrite in_setD1; move/andP => [_].
    move/row_matrixP/(_ (enum_rank_in HkI' k)): Hv.
    rewrite row_mul 2!row_submx_row enum_rankK_in // => ->.
    move/row_matrixP/(_ (enum_rank_in HkI k)): (mulmx_direction bas i).
    rewrite row_mul row_submx_row enum_rankK_in // row0 [X in _ + X]mulmxA => ->.
    by rewrite mul0mx addr0.
 
set B := invmx (matrix_of_prebasis A bas').
move/(congr1 (mulmx B)): Hu'.
by rewrite mulmxA mulVmx // mul1mx.
Qed.

Lemma lex_min_gap_lex_pos :
let: d := direction bas i in
let: j := lex_min_gap_lex in
let: lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0] in
   0 <=lex lex_min_gap.
Proof.
set d := direction bas i.
set j := lex_min_gap_lex.
set lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0].
move: (lex_feasible_basis_is_lex_feasible bas) => Hfeas.
move/andP: lex_min_gap_lex_properties => [Hj /eqP Hj'].
move: Hj; rewrite mem_filter; move/andP => [Hj _].
rewrite -/j -/d in Hj, Hj'.
rewrite /lex_min_gap Hj' /lex_gap.
rewrite -[0](scaler0 _ ((A *m d) j 0)^-1).
move: (Hj); rewrite -oppr_gt0 => Hj''.
rewrite -(lex_pscalar Hj'') 2!scalerA -mulN1r -mulrA mulfV; last by apply: ltr0_neq0.
rewrite scaler0 mulr1 scaleN1r oppv_gelex0 -(lex_add2r (row j A *m point_of_basis_aux bas)) -addrA addNr addr0 add0r.
by move/forallP: Hfeas.
Qed.

Lemma lex_min_gap_lex_prop (h : 'I_m) :
let: d := direction bas i in
let: v := point_of_basis_aux bas in
let: lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0] in
   (A *m d) h 0 < 0 -> (row h b_aux) <=lex (row h A *m v + (A *m d) h 0 *: lex_min_gap).
Proof.
set d := direction bas i.
set v := point_of_basis_aux bas.
set lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0].
move => H.
move: (H); rewrite -invr_lt0 => H'.
rewrite lex_subr_addr (lex_negscalar (row h b_aux - row h A *m v) ((A *m d) h 0 *: lex_min_gap) H') scalerA mulVr;
  last by rewrite unitfE; apply: (ltr0_neq0 H).
rewrite scale1r.
apply: lex_min_seq_ler; apply: map_f.
rewrite mem_filter; apply/andP; split; by rewrite ?mem_enum.
Qed.

Lemma lex_rule_lex_feasibility : is_lex_feasible lex_rule_basis.
Proof.
set d := direction bas i.
set j := lex_min_gap_lex.
set bas' := lex_rule_basis.
set v := point_of_basis_aux bas.
set lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0].
set u := v + d *m lex_min_gap.
move: (lex_feasible_basis_is_lex_feasible bas) => Hfeas.
move: lex_min_gap_lex_pos => Hmin_gap.
move: lex_rule_rel_succ_points => Hvu.
rewrite -/u in Hvu.
have Hu: [forall j, ((row j A) *m u) >=lex (row j b_aux)].
- apply/forallP => h.
  rewrite mulmxDr [X in _ + X]mulmxA -[X in _ + X *m _]row_mul.
  rewrite [X in _ + X *m _]mx11_scalar mul_scalar_mx mxE.
  case: (ltrgt0P ((A *m d) h 0)) => [H | H | ->].
  + rewrite -[X in X <=lex _]addr0.
    apply: (@lex_trans _ _ (row h A *m v + 0)).
    - rewrite lex_add2r; by move/forallP: Hfeas.
    - rewrite lex_add2l -[0](scaler0 _ ((A *m d) h 0)) lex_pscalar //.
  + by apply: (lex_min_gap_lex_prop H).
  + by rewrite scale0r addr0; move/forallP: Hfeas.
by rewrite -Hvu in Hu.
Qed.

Definition lex_rule_lex_feasible_basis := LexFeasibleBasis lex_rule_lex_feasibility.

Lemma lex_rule_inc :
  let: bas' := lex_rule_lex_feasible_basis in
  let: u := reduced_cost_of_basis c bas in
  u i 0 < 0 -> (c^T *m point_of_basis_aux bas') <lex (c^T *m point_of_basis_aux bas).
Proof.
set d := direction bas i.
set j := lex_min_gap_lex.
set bas' := lex_rule_basis.
set v := point_of_basis_aux bas.
set v' := point_of_basis_aux bas'.
set lex_min_gap := lex_min_seq [ seq lex_gap bas d j | j <- enum 'I_m & (A *m d) j 0 < 0].
set u := v + d *m lex_min_gap.
 
move => Hui.
move: lex_rule_rel_succ_points => Hv'u.
rewrite -/u -/v' in Hv'u.
rewrite Hv'u /u mulmxDr lex_ltrNge -subv_gelex0 addrC addrA addNr add0r -lex_ltrNge mulmxA.
rewrite -vdot_def vdotC mul_scalar_mx.
rewrite lex_ltrNge -[X in X *: _]opprK scaleNr -scalerN -[0](scaler0 _ (-'[c,d])).
rewrite lex_pscalar; last by rewrite oppr_gt0; apply: (direction_improvement Hui).
- rewrite -lex_ltrNge.
  apply/andP; split; last first.
  + rewrite -oppv_gelex0 opprK.
    by apply: lex_min_gap_lex_pos.
  + move/andP: lex_min_gap_lex_properties => [Hj /eqP Hj'].
    move: Hj; rewrite mem_filter; move/andP => [Hj _].
    rewrite -/j -/d in Hj, Hj'.
    rewrite /lex_min_gap Hj' /lex_gap -/d -/j oppr_eq0 scaler_eq0.
    move/invr_neq0/negbTE: (ltr0_neq0 Hj) ->.
    rewrite /= row_row_mx /point_of_basis_aux.
    rewrite /matrix_of_prebasis row_submx_row_mx castmx_row !mul_mx_row.
    rewrite opp_row_mx add_row_mx -row_mx0.
    apply: contraT; rewrite negbK; move/eqP/eq_row_mx => [_ /matrixP/(_ 0 (s j))].
    rewrite !mxE eq_refl /=.
    rewrite big1.
    * rewrite mulr1n subr0; move/eqP; rewrite oppr_eq0; move/eqP => Hcontra.
      by move: (oner_neq0 R); rewrite Hcontra eq_refl.
    * move => ? _.
      rewrite !mxE; rewrite big1; first by rewrite mulr0.
      move => l _; rewrite castmxE !mxE /=.
      have: (enum_val (cast_ord (esym (prebasis_card bas)) l)) !=
                          cast_ord (erefl m) j.
      - move/memPn: lex_min_gap_lex_not_in_basis.
        by move/(_ (enum_val (cast_ord (esym (prebasis_card bas)) l)) (enum_valP _)).
      rewrite -(inj_eq (@perm_inj _ s)) 2!cast_ord_id; move/negbTE ->.
      by rewrite /= mulr0n oppr0 mulr0.
Qed.

End Lexicographic_rule.

Section LexPhase2.

Variable s : 'S_m.

Inductive lex_final_result :=
| Lex_res_unbounded of (lex_feasible_basis s) * 'I_n
| Lex_res_optimal_basis of (lex_feasible_basis s).

Inductive lex_intermediate_result :=
| Lex_final of lex_final_result
| Lex_next_basis of (lex_feasible_basis s).

Variable c : 'cV[R]_n.
Implicit Types bas : (lex_feasible_basis s).

Definition iterate bas :=
  let u := reduced_cost_of_basis c bas in
  if [pick i | u i 0 < 0] is Some i then
    let d := direction bas i in
    if (@idPn (feasible_direction A d)) is ReflectT infeas_dir then
      Lex_next_basis (lex_rule_lex_feasible_basis infeas_dir)
    else Lex_final (Lex_res_unbounded (bas, i))
  else
    Lex_final (Lex_res_optimal_basis bas).

Definition basis_height bas :=
  #| [ set bas': (lex_feasible_basis s) | (c^T *m (point_of_basis_aux s bas')) <lex (c^T *m (point_of_basis_aux s bas)) ] |.

Function lex_phase2 bas {measure basis_height bas} :=
  match iterate bas with
  | Lex_final final_res => final_res
  | Lex_next_basis bas' => lex_phase2 bas'
  end.
Proof.
move => bas bas'.
move => Hbas.
apply/leP.
pose u := reduced_cost_of_basis c bas.
 
move: Hbas; rewrite /iterate.
case: pickP => [i |]; last by done.
rewrite -/u; move => Hui.
case: {-}_ /idPn => [infeas_dir [] Hbas'|]; last by done.
 
move: (lex_rule_inc infeas_dir Hui) => Hc; rewrite Hbas' in Hc.
apply: proper_card.
set Sbas' := [set _ | _]; set Sbas := [set _ | _].
rewrite properEneq; apply/andP; split; last first.
- apply/subsetP; move => bas''.
  rewrite !inE; move/andP => [_ Hbas''].
  by apply:(lex_le_ltr_trans Hbas'' Hc).
- apply: contraT; rewrite negbK; move/eqP => Hcontra.
  have H1: bas' \notin (Sbas').
  + rewrite inE negb_and; apply/orP; left.
    by rewrite negbK eq_refl.
  have H2: bas' \in (Sbas) by rewrite inE.
  move/setP/(_ bas'): Hcontra.
  by move/negbTE: H1 ->; rewrite H2.
Qed.

CoInductive lex_phase2_spec bas0 : lex_final_result -> Type :=
| Lex_unbounded (p: (lex_feasible_basis s) * 'I_n) of (reduced_cost_of_basis c p.1) p.2 0 < 0 /\ feasible_direction A (direction p.1 p.2) : lex_phase2_spec bas0 (Lex_res_unbounded p)
| Lex_optimal_basis (bas: lex_feasible_basis s) of (reduced_cost_of_basis c bas) >=m 0 : lex_phase2_spec bas0 (Lex_res_optimal_basis bas).

Lemma lex_phase2P bas0 : lex_phase2_spec bas0 (lex_phase2 bas0).
Proof.
pose P bas' res := (lex_phase2_spec bas0 res).
suff /(_ bas0): (forall bas, P bas (lex_phase2 bas)) by done.
apply: lex_phase2_rect; last by done.
- move => bas1 res; rewrite /iterate.
  case: pickP => [i Hi| Hu [] <-].
  + case: {-}_ /idPn => [? |/negP Hd [] /= <-]; try by done.
    * by rewrite negbK in Hd; constructor.
  + constructor; apply/forallP => i; rewrite mxE.
    move/(_ i)/negbT: Hu.
    by rewrite lerNgt.
Qed.

End LexPhase2.

Section Phase2.

Variable bas0 : feasible_basis.

Lemma n_leq_m : ((m - n) + n = m)%N.
Proof.
move: (max_card (pred_of_set bas0)).
rewrite (prebasis_card bas0) cardE size_enum_ord => ?.
rewrite subnK //.
Qed.

Definition cbas0 := ~: bas0.

Lemma card_cbas0 :  #|~: bas0| = (m-n)%N.
Proof.
move: (cardsC bas0).
rewrite (prebasis_card bas0) [RHS]cardE size_enum_ord -[RHS]n_leq_m.
by rewrite [RHS]addnC; move/addnI.
Qed.

Lemma in_setC' : forall i, ~ (i \in bas0) -> (i \in cbas0).
Proof.
by move=> i; move/setCP; rewrite in_setC.
Qed.

Definition perm0_fun i :=
  cast_ord n_leq_m
           (match (@idP (i \in bas0)) with
            | ReflectT Hi => rshift (m-n)%N (cast_ord (prebasis_card bas0) (enum_rank_in Hi i))
            | ReflectF Hi => lshift n (cast_ord card_cbas0 (enum_rank_in (@in_setC' i Hi) i))
            end).

Definition perm0_inj : injective perm0_fun.
Proof.
move => i j /cast_ord_inj.
case: {-}_ /idP => [Hi | Hi]; case: {-}_ /idP => [Hj | Hj].
- move/rshift_inj/cast_ord_inj/(congr1 enum_val).
  do 2![rewrite enum_rankK_in //].
- set k := rshift _ _; set l := lshift _ _; move => Hkl.
  have Hk: (k \in [set rshift (m-n) i | i : 'I_n]).
  + by apply/imsetP; exists (cast_ord (prebasis_card bas0) (enum_rank_in Hi i)).
    have Hl: (l \in [set lshift n i | i : 'I_(m-n)]).
  + by apply/imsetP; exists (cast_ord card_cbas0 (enum_rank_in (in_setC' Hj) j)).
    by rewrite -rshift_compl -Hkl in_setC Hk /= in Hl.
- set k := rshift _ _; set l := lshift _ _; move => Hkl.
  have Hk: (k \in [set rshift (m-n) i | i : 'I_n]).
  + by apply/imsetP; exists (cast_ord (prebasis_card bas0) (enum_rank_in Hj j)).
    have Hl: (l \in [set lshift n i | i : 'I_(m-n)]).
  + by apply/imsetP; exists (cast_ord card_cbas0 (enum_rank_in (in_setC' Hi) i)).
    by rewrite -rshift_compl Hkl in_setC Hk /= in Hl.
  + move/lshift_inj/cast_ord_inj/(congr1 enum_val).
    do 2![rewrite enum_rankK_in //; last by rewrite in_setC; apply/negP].
Qed.

Definition perm0 := perm perm0_inj.

Lemma ineq_in_basis_satisfied (i : 'I_m) (perm : 'S_m) (bas : basis) :
let: u' := point_of_basis_aux perm bas in
  i \in bas -> (row i (b_aux perm)) <=lex ((row i A) *m u').
Proof.
move => Hi.
have /row_matrixP/(_ (cast_ord (prebasis_card bas) (enum_rank_in Hi i))): (matrix_of_prebasis A bas) *m point_of_basis_aux perm bas = matrix_of_prebasis (b_aux perm) bas.
  rewrite mulmxA mulmxV; last by apply: matrix_of_basis_in_unitmx.
  by rewrite mul1mx.
rewrite -[point_of_basis_aux _ _](castmx_id (erefl _, erefl _)) -castmx_mul;
do 2![rewrite row_castmx castmx_id cast_ordK].
rewrite -row_submx_mul 2!row_submx_row enum_rankK_in //.
by move <-; rewrite -row_mul; apply: lex_refl.
Qed.

Lemma feasible_to_lex_feasible :
  is_lex_feasible perm0 bas0.
Proof.
pose b' := b_aux perm0.
have Hb: forall j, col (rshift 1 (cast_ord n_leq_m (lshift n j))) (matrix_of_prebasis b' bas0) = 0.
- move => j.
  rewrite /matrix_of_prebasis.
  rewrite row_submx_row_mx castmx_row colKr.
  apply/colP => k; rewrite !mxE castmxE /= cast_ord_id row_submx_mxE !mxE.
  set l := cast_ord _ _; rewrite permE.
  suff /negbTE ->: (perm0_fun (enum_val l) != cast_ord n_leq_m (lshift n j))
    by rewrite mulr0n oppr0.
  + rewrite /perm0_fun (inj_eq (@cast_ord_inj _ _ n_leq_m)).
    move: (enum_valP l) => Hl; case: {-}_ /idP => [Hl' |]; last by done.
    * rewrite enum_valK_in; set k' := rshift _ _; set l' := lshift _ _.
      have H1: (k' \in [set rshift (m-n) i | i : 'I_n]).
      - by apply/imsetP; exists (cast_ord (prebasis_card bas0) l).
      have H2: (l' \in [set lshift n i | i : 'I_(m-n)]).
      - by apply/imsetP; exists j.
      apply: contraT; rewrite negbK => /eqP Hkl'.
        by rewrite -rshift_compl in_setC -Hkl' H1 /= in H2.
apply/forallP => i.
- set rowi := (_ *m _).
  have Hcol : forall j, col (rshift 1 (cast_ord n_leq_m (lshift n j))) rowi = 0.
  + by move => j; rewrite 2!col_mul (Hb j) 2!mulmx0.
  case: (boolP (i \in bas0)) => [Hi | Hi]; last first.
  + apply: lex_ltrW; apply: (@lex_lev_strict _ _ _ _ (rshift 1 (perm0_fun i))).
    rewrite /perm0_fun; case: {-}_ /idP => [ Hi' | Hi' ]; first by rewrite Hi' in Hi.
      set k := (cast_ord card_cbas0 _).
    apply/andP; split; last first.
    * move/colP/(_ 0): (Hcol k); rewrite mxE [RHS]mxE; move ->.
      rewrite mxE row_mxEr !mxE.
      suff ->: perm0 i == cast_ord n_leq_m (lshift n k).
      - by rewrite /= mulr1n; apply: ltrN10.
      - apply/eqP; rewrite permE /perm0_fun.
        apply/(congr1 (cast_ord n_leq_m)); case: {-}_ /idP => [ Hi'' | Hi'' ]; first by done.
        apply/(congr1 (lshift _))/(congr1 (cast_ord _)); apply: enum_val_inj.
        by rewrite -in_setC in Hi; do 2![rewrite enum_rankK_in //].
    * apply/forallP => j.
      case: (boolP (j \in [set rshift 1 j | j: 'I_m])); last first.
      - rewrite -in_setC rshift_compl; move/imsetP => [l _ ->].
        rewrite row_row_mx row_mxEl [X in X <= _]mxE.
        rewrite /rowi  /point_of_basis_aux -row_mul [X in _ <= X]mxE.
        rewrite mulmxA {2}/matrix_of_prebasis.
        rewrite row_submx_row_mx cast_row_mx mul_mx_row row_mxEl.
        rewrite -mulmxA.
        suff ->: (l = 0) by move/forallP/(_ i): (feasible_basis_is_feasible bas0).
        + by apply: ord_inj; move: (ltn_ord l); rewrite ltnS leqn0; move/eqP.
      - move/imsetP => [l _ Hjl].
        apply/implyP; rewrite {1}Hjl /=.
        rewrite ltn_add2l => Hl.
        move: (ltn_ord (enum_rank_in (in_setC' Hi') i)); rewrite {2}card_cbas0.
        move/(ltn_trans Hl) => Hl0.
        pose l0 := Ordinal Hl0.
        have Hj: j = rshift 1 (cast_ord n_leq_m (lshift n l0)).
          by apply:ord_inj; rewrite Hjl /=.
        rewrite {Hjl Hl}.
        move/colP/(_ 0): (Hcol l0); rewrite mxE [RHS]mxE -Hj; move ->.
        rewrite row_row_mx Hj row_mxEr !mxE.
        by rewrite oppr_le0 ler0n.
  + by apply: (ineq_in_basis_satisfied perm0 Hi).
Qed.

Variable c : 'cV[R]_n.

Inductive phase2_final_result :=
| Phase2_res_unbounded of feasible_basis * 'I_n
| Phase2_res_optimal_basis of feasible_basis.

Definition lex_to_phase2_final_result res :=
  match res with
  | Lex_res_unbounded (bas, i) => Phase2_res_unbounded (FeasibleBasis ((@lex_feasible_basis_is_feasible perm0) bas), i)
  | Lex_res_optimal_basis bas => Phase2_res_optimal_basis (FeasibleBasis ((@lex_feasible_basis_is_feasible perm0)  bas))
  end.

Definition phase2 :=
  lex_to_phase2_final_result ((@lex_phase2 perm0) c (LexFeasibleBasis (feasible_to_lex_feasible))).

Implicit Types bas : feasible_basis.

CoInductive phase2_spec : phase2_final_result -> Type :=
| Phase2_unbounded (p: feasible_basis * 'I_n) of (reduced_cost_of_basis c p.1) p.2 0 < 0 /\ feasible_direction A (direction p.1 p.2) : phase2_spec (Phase2_res_unbounded p)
| Phase2_optimal_basis (bas: feasible_basis) of (reduced_cost_of_basis c bas) >=m 0 : phase2_spec (Phase2_res_optimal_basis bas).

Lemma phase2P : phase2_spec phase2.
Proof.
rewrite /phase2 /lex_to_phase2_final_result.
case: lex_phase2P => [[bas d]|]; try by constructor.
Qed.

End Phase2.

End Simplex.

Section Pos_simplex. (* a simplex method which applies to LP of the form min '[c,x] s.t. A *m x >=m b, x >=m 0 *)

Variable R: realFieldType.
Variable m n : nat.

Variable A : 'M[R]_(m,n).
Variable b : 'cV[R]_m.

(*To restate the initial problem as an equivalent one with positivity constraints*)
Definition A' := col_mx A (1%:M).
Definition b' := col_mx b (0:'cV_n).

Lemma mem_polyhedron_pos_constraint x : (x \in polyhedron A' b') = (x \in polyhedron A b) && (x >=m 0).
Proof.
by rewrite inE /A' /b' mul_col_mx mul1mx col_mx_lev.
Qed.

(*To implement phase 1 of schrijver book*)

Definition pos_idx := [ set i: 'I_m | b i 0 > 0 ].
Definition neg_idx := [ set i: 'I_m | b i 0 <= 0 ].

Definition Apos := (row_submx A pos_idx).
Definition Aneg := (row_submx A neg_idx).

Definition bpos := (row_submx b pos_idx).
Definition bneg := (row_submx b neg_idx).

Definition Aposext := row_mx (-Apos) (1%:M).
Definition Anegext := row_mx Aneg (0:'M_(#|neg_idx|, #|pos_idx|)).

Definition Aext := col_mx (col_mx Aposext Anegext) (1%:M).
Definition bext := col_mx (col_mx (-bpos) bneg) (0:'cV_(n + #|pos_idx|)).

Definition initial_set := [set (rshift (#|pos_idx| + #|neg_idx|) i) | i :'I_(n+(#|pos_idx|))].

Lemma initial_set_card : (#|initial_set| == n+(#|pos_idx|))%N.
Proof.
by apply/eqP; apply: rshift_card.
Qed.

Definition initial_pb := Prebasis (initial_set_card).

Lemma initial_pb_is_basis : (is_basis Aext initial_pb).
Proof.
rewrite /is_basis -row_free_unit -row_leq_rank rank_castmx row_submx_col_mx.
by rewrite rank_castmx mxrank1 leqnn.
Qed.

Definition initial_basis := Basis initial_pb_is_basis.

Lemma point_of_basis_initial_basis : (point_of_basis bext initial_basis) = 0.
Proof.
by rewrite /point_of_basis [matrix_of_prebasis bext initial_basis]/matrix_of_prebasis row_submx_col_mx !castmx_const mulmx0.
Qed.

Lemma initial_basis_is_feasible : (is_feasible bext initial_basis).
Proof.
rewrite /is_feasible point_of_basis_initial_basis.
apply/forallP => i.
rewrite mulmx0 mxE.
case: splitP => [ j _ | j _ ]; last by rewrite !mxE; apply: lerr.
  - rewrite mxE.
    case: splitP => [ k _ | k _ ].
      + by rewrite /bpos !mxE oppr_le0; move:(enum_valP k); rewrite inE; apply: ltrW.
      + by rewrite /bneg !mxE; move:(enum_valP k); rewrite inE.
Qed.

Definition initial_feasible_basis := FeasibleBasis initial_basis_is_feasible.

Definition cext := \sum_i (row i Aposext)^T.
Definition cextopt := \sum_i (-bpos) i 0.

Lemma pos_neg_lev_decomp x :
      (b <=m (A *m x)) = ((bpos <=m (Apos *m x)) && (bneg <=m (Aneg *m x))).
Proof.
suff H: neg_idx = ~: pos_idx by move: (lev_decomp b (A *m x) pos_idx); rewrite -H !row_submx_mul.
apply:eqP; rewrite eqEsubset.
apply/andP; split.
  - by apply/subsetP => i; rewrite !inE ltrNge negbK.
  - by apply/subsetP => i; move/setCP; rewrite !inE lerNgt; move/negP.
Qed.

Lemma cext_min_values_aux x :
      '[cext, x] = \sum_i (Aposext *m x) i 0 .
Proof.
rewrite vdotC /cext.
rewrite (((big_morph (fun w => '[x,w])) 0%R) +%R).
  - apply: eq_bigr => i _; rewrite /vdot mxE.
    by apply: eq_bigr => j _; rewrite !mxE mulrC.
  - by apply: vdotDr.
  - by apply: vdot0r.
Qed.

Lemma cext_min_value x :
  (x \in polyhedron Aext bext) -> '[cext, x] >= cextopt.
Proof.
rewrite inE -[x]vsubmxK mul_col_mx col_mx_lev mul1mx; move/andP/proj1.
rewrite mul_col_mx col_mx_lev /Aposext mul_row_col mul1mx; move/andP/proj1.
rewrite /cextopt cext_min_values_aux mul_row_col mul1mx => Hx.
apply: ler_sum => i _.
by move/forallP: Hx.
Qed.

Lemma cext_min_value_attained_prop  x :
  (x \in polyhedron Aext bext) -> '[cext, x] = cextopt -> -bpos = (Aposext *m x).
Proof.
move => Hx Hx'.
rewrite inE mul_col_mx col_mx_lev mul1mx in Hx; move/andP/proj1: Hx => Hx.
rewrite mul_col_mx col_mx_lev in Hx; move/andP/proj1/forallP: Hx => Hx.
rewrite /cextopt cext_min_values_aux in Hx'.
have Haux: (forall x0 : ordinal_finType #|pos_idx|, x0 \in  ordinal_finType #|pos_idx| -> 0 <= (Aposext *m x) x0 0 - (- bpos)x0 0)
  by move => j; move: (Hx j); rewrite -subr_ge0.
move/eqP in Hx'; rewrite -subr_eq0 in Hx'; move/eqP in Hx'; rewrite -sumrB in Hx'.
move: (psumr_eq0P Haux Hx') => Haux'.
have Haux'': forall i : ordinal_finType #|pos_idx|, i \in ordinal_finType #|pos_idx| -> (- bpos) i 0 = (Aposext *m x) i 0
  by move => j _; apply/eqP; rewrite eq_sym -subr_eq0; apply/eqP; apply: (Haux' j).
apply/colP => j.
by apply: (Haux'' j).
Qed.

Lemma feasible_cext_eq_min_value x :
  x \in polyhedron A' b' ->
        let: z := col_mx x (Apos *m x - bpos) in
        (z \in polyhedron Aext bext) /\ ('[cext,z] = cextopt).
Proof.
rewrite mem_polyhedron_pos_constraint => /andP [Hx1 Hx2].
set x':= Apos *m x -bpos.
split.
- rewrite /polyhedron inE mul_col_mx col_mx_lev.
  apply/andP; split.
  + rewrite mul_col_mx col_mx_lev.
    apply/andP; split.
    * rewrite mul_row_col mul1mx /x' [(- Apos *m x + (Apos *m x - bpos))]addmxA mulNmx addNmx add0mx.
      by apply: lev_refl.
    * rewrite mul_row_col mul0mx addr0 -row_submx_mul.
      by apply: (row_submx_lev neg_idx Hx1).
  + rewrite mul1mx -col_mx0 col_mx_lev.
    apply/andP; split; first by done.
    * rewrite /x' subv_ge0 -row_submx_mul.
      by apply: (row_submx_lev pos_idx Hx1).
- by rewrite cext_min_values_aux mul_row_col mul1mx /x' [(- Apos *m x + (Apos *m x - bpos))]addmxA mulNmx addNmx add0mx.
Qed.

Lemma feasible_cext_eq_min_active x :
  ((x \in polyhedron Aext bext) /\ ('[cext,x] = cextopt)) ->
  let: y := usubmx x in
  (y \in polyhedron A' b').
Proof.
move => [Hx1 Hx2].
move: (cext_min_value_attained_prop Hx1 Hx2) => Hx3.
rewrite -[x]vsubmxK mul_row_col mul1mx in Hx3.
rewrite /polyhedron inE -[x]vsubmxK !mul_col_mx !mul_row_col !mul1mx mul0mx addr0 col_mx_lev in Hx1.
move/andP: Hx1 => [Hx1' Hx1''].
rewrite mem_polyhedron_pos_constraint.
apply/andP; split; last by rewrite -col_mx0 col_mx_lev in Hx1''; move/andP/proj1: Hx1''.
- rewrite col_mx_lev in Hx1'.
  rewrite inE pos_neg_lev_decomp.
  apply/andP; split; last by move/andP/proj2: Hx1'.
  + rewrite -subv_ge0 Hx3 mulNmx addrA addrN add0r.
    by rewrite -col_mx0 col_mx_lev in Hx1''; move/andP/proj2: Hx1''.
Qed.

Lemma extremality_ext x :
  is_extreme x (polyhedron Aext bext: _ -> bool) -> ('[cext,x] = cextopt) -> 
    let: y := usubmx x in
    is_extreme y (polyhedron A' b': _ -> bool).
Proof.
move => [H1x H2x] H3x.
split; first by move: (feasible_cext_eq_min_active (conj H1x H3x)).
move => y1 y2 lambda Hy1 Hy2 Hlambda Hy.
move: (feasible_cext_eq_min_value Hy1) => [Hx1 _].
set x1 := (col_mx y1 (Apos *m y1 - bpos)).
move: (feasible_cext_eq_min_value Hy2) => [Hx2 _].
set x2 := (col_mx y2 (Apos *m y2 - bpos)).
have Hx_bary: x = lambda *: x1 + (1 - lambda) *: x2.
- rewrite -[x]vsubmxK 2!scale_col_mx add_col_mx.
  apply: congr2; first by done.
  + move: (cext_min_value_attained_prop H1x H3x) => H; rewrite -[x]vsubmxK mul_row_col mul1mx addrC mulNmx in H.
    by rewrite 2!scalerBr addrA [X in (X + _)]addrC addrA 2!scalemxAr -mulmxDr [_ *: y2 + _ *: y1]addrC -Hy scalerBl opprB addrA addrC -addrA addNr addr0 scale1r H -addrA addNr addr0.
move: (H2x x1 x2 lambda Hx1 Hx2 Hlambda Hx_bary) => [Hxx1 Hxx2].
split; by [rewrite Hxx1 col_mxKu | rewrite Hxx2 col_mxKu].
Qed.

Variable c : 'cV[R]_n.

Inductive pos_final_result :=
| Pos_res_infeasible
| Pos_res_unbounded of (feasible_basis A' b') * 'I_n
| Pos_res_optimal_basis of (feasible_basis A' b').

Definition pos_simplex :=
  match phase2 initial_feasible_basis cext with
  | Phase2_res_unbounded _ => Pos_res_infeasible (* this case should not happen *)
  | Phase2_res_optimal_basis _ =>
    if [pick bas: feasible_basis A' b'] is Some bas then
      match phase2 bas c with
      | Phase2_res_unbounded (bas', i) => Pos_res_unbounded (bas', i)
      | Phase2_res_optimal_basis bas' => Pos_res_optimal_basis bas'
      end
    else
      Pos_res_infeasible
  end.

CoInductive pos_simplex_spec : pos_final_result -> Type :=
| Pos_infeasible of ~ (feasible A' b') : pos_simplex_spec Pos_res_infeasible
| Pos_unbounded (p: feasible_basis A' b' * 'I_n) of (reduced_cost_of_basis c p.1) p.2 0 < 0 /\ feasible_direction A' (direction p.1 p.2) : pos_simplex_spec (Pos_res_unbounded p)
| Pos_optimal_point (bas: feasible_basis A' b') of (reduced_cost_of_basis c bas) >=m 0 : pos_simplex_spec (Pos_res_optimal_basis bas).

Lemma pos_simplexP : pos_simplex_spec pos_simplex.
Proof.
rewrite /pos_simplex.
case: phase2P => [[bas i] /= [Hd Hd']| bas Hbas].
- move: (unbounded_certificate_on_basis Hd' Hd) => Hunbounded.
  suff: (~ (unbounded Aext bext cext)) by done.
  + by apply: bounded_is_not_unbounded; exists cextopt; apply: cext_min_value.
- case: pickP => [bas0 _ | H]. 
  + case: phase2P => [[bas' d] /=|]; by constructor.
  + constructor; move => [x Hx].
    set z := point_of_basis bext bas.
    move: (feasible_basis_is_feasible bas) => Hfeas.
    move: (optimal_basis Hbas) => Hopt.
    move/feasible_cext_eq_min_value: Hx; set z' := (col_mx _ _); move => [Hz'1 Hz'2].
    move/(_ z' Hz'1 ): (proj2 Hopt); rewrite {}Hz'2 => Hcextopt.
    move/cext_min_value: Hfeas => Hcextopt'.
    move/andP: (conj Hcextopt Hcextopt'); rewrite lter_anti {Hcextopt Hcextopt'}; move/eqP => Hcextopt.
    move/feasible_point_of_basis_is_extreme: (feasible_basis_is_feasible bas) => Hextr.
    move/extreme_point_is_feasible_point_of_basis: (extremality_ext Hextr Hcextopt) => [bas' _].
    by move/(_ bas'): H.
Qed.

End Pos_simplex.

Section General_simplex.

Variable R: realFieldType.
Variable m n : nat.

Variable A : 'M[R]_(m,n).
Variable b : 'cV[R]_m.
Variable c : 'cV[R]_n.

Definition Aaux' := A' (row_mx A (-A)).
Definition baux' := b' (n+n) b.
Definition caux' := col_mx c (-c).

Lemma feasibility_general_to_pos x :
  x \in polyhedron A b -> col_mx (pos_part x) (neg_part x) \in polyhedron Aaux' baux'.
Proof.
rewrite !inE mul_col_mx mul1mx.
rewrite mul_row_col mulNmx -mulmxN -mulmxDr add_pos_neg_part.
by rewrite col_mx_lev -col_mx0 col_mx_lev pos_part_gev0 neg_part_gev0 /= andbT.
Qed.

Definition v2gen (x : 'cV[R]_(n+n)) := (usubmx x) - (dsubmx x).

Definition mulmxAv2gen (x : 'cV[R]_(n+n)):
  (row_mx A (-A)) *m x = A *m (v2gen x).
Proof.
by rewrite -{1}[x]vsubmxK mul_row_col mulNmx -mulmxN -mulmxDr.
Qed.

Definition cost2gen (x : 'cV[R]_(n+n)):
  '[caux', x] = '[c,v2gen x].
Proof.
by rewrite -{1}[x]vsubmxK vdot_col_mx vdotNl vdotBr.
Qed.

Definition ext_reduced_cost2gen (bas : basis Aaux') :=
  usubmx (ext_reduced_cost_of_basis caux' bas).

Lemma ext_reduced_cost2gen_dual_feasible (bas : basis Aaux') :
  (reduced_cost_of_basis caux' bas) >=m 0 -> (ext_reduced_cost2gen bas \in dual_polyhedron A c).
Proof.
rewrite /ext_reduced_cost2gen -non_neg_reduced_cost_equiv.
set u := ext_reduced_cost_of_basis _ _.
rewrite -{1}[u](vsubmxK) -[0](col_mx0) col_mx_lev => /andP [Hu Hu'].
rewrite inE; apply/andP; split; last by done.
- apply/eqP.
  move: (ext_reduced_cost_of_basis_def caux' bas); rewrite -/u.
  rewrite /Aaux' /A' -{1}[u](vsubmxK) tr_col_mx mul_row_col tr_row_mx mul_col_mx linearN /= mulNmx.
  rewrite trmx1 mul1mx.
  set t := col_mx _ _.
  move/(congr1 (fun z => -t + z)); rewrite addrA addNr add0r => Ht. (* DIRTY *)
  rewrite Ht addrC subv_ge0 in Hu'.
  move: Hu'; rewrite /t /caux' col_mx_lev => /andP [H H'].
  rewrite lev_opp2 in H'.
  by apply: lev_antisym; apply/andP.
Qed.

Lemma feasibility_pos_to_general x :
  x \in polyhedron Aaux' baux' -> v2gen x \in polyhedron A b.
Proof.
rewrite inE mul_col_mx col_mx_lev => /andP [? _].
by rewrite inE -mulmxAv2gen.
Qed.

Lemma feasibility_equiv : feasible A b <-> feasible Aaux' baux'.
Proof.
split.
- move => [x] /feasibility_general_to_pos.
  by set z := col_mx _ _; exists z.
- move => [x] /feasibility_pos_to_general.
  by rewrite /v2gen; set z := _ - _; exists z.
Qed.

Inductive simplex_final_result :=
| Simplex_infeasible
| Simplex_unbounded of 'cV[R]_n * 'cV[R]_n
| Simplex_optimal_basis of 'cV[R]_n * 'cV[R]_m.

Definition simplex :=
  match pos_simplex (row_mx A (-A)) b caux' with 
  | Pos_res_infeasible => Simplex_infeasible
  | Pos_res_unbounded (bas, i) =>
    let d := direction bas i in
    Simplex_unbounded (v2gen (point_of_basis baux' bas), v2gen d)
  | Pos_res_optimal_basis bas =>
    Simplex_optimal_basis (v2gen (point_of_basis baux' bas), ext_reduced_cost2gen bas)
  end.

Lemma value_equiv (K : R) :
  (exists x, (x \in polyhedron A b) /\ ('[c,x] = K)) <-> (exists y, (y \in polyhedron Aaux' baux') /\ ('[caux',y] = K)).
Proof.
split.
- move => [x [Hx HxK]].
  exists (col_mx (pos_part x) (neg_part x)).
  split; first by apply: (feasibility_general_to_pos Hx).
    + by rewrite vdot_col_mx vdotNl -vdotNr -vdotDr add_pos_neg_part.
- move => [y [Hy HyK]].
  exists (usubmx y - dsubmx y).
  split; first by apply: (feasibility_pos_to_general Hy).
    + by rewrite vdotDr vdotNr -vdotNl -vdot_col_mx vsubmxK.
Qed.

CoInductive simplex_spec : simplex_final_result -> Type :=
| Infeasible of ~ (feasible A b) : simplex_spec Simplex_infeasible
| Unbounded p of [/\ (p.1 \in polyhedron A b), (feasible_direction A p.2) & ('[c,p.2] < 0)] : simplex_spec (Simplex_unbounded p)
| Optimal_point p of [/\ (p.1 \in polyhedron A b), (p.2 \in dual_polyhedron A c) & (compl_slack_cond A b p.1 p.2)] : simplex_spec (Simplex_optimal_basis p).

Lemma simplexP: simplex_spec simplex.
Proof.
rewrite /simplex.
case: pos_simplexP => [/feasibility_equiv | [bas i] /= [H H']| bas Hu]; constructor; try by done.
- split.
  + move: (feasible_basis_is_feasible bas); rewrite /is_feasible.
    by move/feasibility_pos_to_general.
  + rewrite /feasible_direction -mulmxAv2gen.
    rewrite /feasible_direction /A' -[0]col_mx0 mul_col_mx col_mx_lev in H'.
    by move/andP: H' => [? _].
  + by rewrite -cost2gen /direction vdot_mulmx vdot_delta_mx trmx_inv.
- split.
  + move: (feasible_basis_is_feasible bas); rewrite /is_feasible.
    by move/feasibility_pos_to_general.
  + by apply:ext_reduced_cost2gen_dual_feasible.
  + apply/compl_slack_condP => i.
    rewrite /ext_reduced_cost_of_basis [in X in X = 0]mxE.
    suff /compl_slack_condP/(_ (lshift (n+n) i)) :
      (compl_slack_cond Aaux' baux' (point_of_basis baux' bas) (ext_reduced_cost_of_basis caux' bas)).
    * by rewrite /Aaux' /A' /baux' /b' mul_col_mx 2!col_mxEu mulmxAv2gen.
    * by apply: compl_slack_cond_on_basis.
Qed.

End General_simplex.
