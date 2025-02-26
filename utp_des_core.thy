theory utp_des_core
  imports UTP2.utp_wlp
begin 

alphabet des_vars = 
  ok :: bool

type_synonym ('s\<^sub>1, 's\<^sub>2) des_rel = "'s\<^sub>1 des_vars_scheme \<leftrightarrow> 's\<^sub>2 des_vars_scheme"
type_synonym ('s\<^sub>1) des_hrel = "'s\<^sub>1 des_vars_scheme \<leftrightarrow> 's\<^sub>1 des_vars_scheme"

definition design where
[rel]: "design P Q = ((ok\<^sup><)\<^sub>u \<and> P \<Rightarrow> (ok\<^sup>>)\<^sub>u \<and> Q)"

definition rdesign :: "('s\<^sub>1 \<leftrightarrow> 's\<^sub>2) \<Rightarrow> ('s\<^sub>1 \<leftrightarrow> 's\<^sub>2) \<Rightarrow> ('s\<^sub>1, 's\<^sub>2) des_rel" where
[rel]: "rdesign P Q = design (P \<up> more\<^sub>L\<^sup>2) (Q \<up> more\<^sub>L\<^sup>2)"

syntax 
  "_design"  :: "logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<turnstile>" 85)
  "_rdesign" :: "logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<turnstile>\<^sub>r" 85)
  "_ndesign" :: "logic \<Rightarrow> logic \<Rightarrow> logic" (infix "\<turnstile>\<^sub>n" 85)

translations 
  "P \<turnstile> Q" == "CONST design P Q"
  "P \<turnstile>\<^sub>r Q" == "CONST rdesign P Q"
  "p \<turnstile>\<^sub>n Q" == "(p\<^sup><)\<^sub>u \<turnstile>\<^sub>r Q"

syntax
  "_svid_des_alpha"  :: "svid" ("\<^bold>v\<^sub>D")

translations
  "_svid_des_alpha" => "CONST des_vars.more\<^sub>L"



lemma "false \<turnstile> true = true"
  by rel_auto

lemma "true \<turnstile> false = (\<not> $ok\<^sup><)\<^sub>u"
  by rel_auto

lemma design_union: "(P\<^sub>1 \<turnstile> Q\<^sub>1) \<union> (P\<^sub>2 \<turnstile> Q\<^sub>2) = ((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (Q\<^sub>1 \<or> Q\<^sub>2))"
  by rel_auto

lemma design_cond: "(P\<^sub>1 \<turnstile> Q\<^sub>1) \<lhd> b \<rhd> (P\<^sub>2 \<turnstile> Q\<^sub>2) = (P\<^sub>1 \<lhd> b \<rhd> P\<^sub>2) \<turnstile> (Q\<^sub>1 \<lhd> b \<rhd> Q\<^sub>2)"
  by rel_auto

theorem design_composition_subst:
  assumes
    "$ok\<^sup>> \<sharp> P1" "$ok\<^sup>< \<sharp> P2"
  shows "((P1 \<turnstile> Q1) \<^bold>; (P2 \<turnstile> Q2)) =
         (((\<not> ((\<not> P1) \<Zcomp> true)) \<and> \<not> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<^bold>; (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> Q2\<lbrakk>true/ok\<^sup><\<rbrakk>))"
proof -
  have "((P1 \<turnstile> Q1) \<Zcomp> (P2 \<turnstile> Q2)) = (\<Union> ok\<^sub>0. ((P1 \<turnstile> Q1)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/ok\<^sup>>\<rbrakk> \<Zcomp> (P2 \<turnstile> Q2)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/ok\<^sup><\<rbrakk>))"
    by (rule seqr_middle, simp)
  also have " ...
        = (((P1 \<turnstile> Q1)\<lbrakk>false/ok\<^sup>>\<rbrakk> \<Zcomp> (P2 \<turnstile> Q2)\<lbrakk>false/ok\<^sup><\<rbrakk>)
            \<or> ((P1 \<turnstile> Q1)\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> (P2 \<turnstile> Q2)\<lbrakk>true/ok\<^sup><\<rbrakk>))"
    by (rel_auto; metis (full_types))
  also from assms
  have "... = ((((ok\<^sup><)\<^sub>u \<and> P1 \<Rightarrow> Q1\<lbrakk>true/ok\<^sup>>\<rbrakk>) \<Zcomp> (P2 \<Rightarrow> (ok\<^sup>>)\<^sub>u \<and> Q2\<lbrakk>true/ok\<^sup><\<rbrakk>)) \<or> ((\<not> ((ok\<^sup><)\<^sub>u \<and> P1)) \<Zcomp> true))"
    by (simp add: design_def usubst usubst_eval, rel_auto)
  also have "... = (((\<not>ok\<^sup><)\<^sub>u \<Zcomp> true\<^sub>h) \<or> ((\<not>P1) \<Zcomp> true) \<or> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> (\<not>P2)) \<or> ((ok\<^sup>>)\<^sub>u \<and> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> Q2\<lbrakk>true/ok\<^sup><\<rbrakk>)))"
    by (rel_auto)
  also have "... = (((\<not> ((\<not> P1) \<Zcomp> true)) \<and> \<not> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/ok\<^sup>>\<rbrakk> \<Zcomp> Q2\<lbrakk>true/ok\<^sup><\<rbrakk>))"
    unfolding design_def by (rel_auto)
  finally show ?thesis .
qed

lemma design_composition:
  assumes "$ok\<^sup>> \<sharp> P1" "$ok\<^sup>< \<sharp> P2" "$ok\<^sup>> \<sharp> Q1" "$ok\<^sup>< \<sharp> Q2"
  shows "((P1 \<turnstile> Q1) \<^bold>; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) \<^bold>; true)) \<and> \<not> (Q1 \<^bold>; (\<not> P2))) \<turnstile> (Q1 \<^bold>; Q2))"
  using assms
  by (simp add: design_composition_subst usubst)

theorem rdesign_composition:
  "((P1 \<turnstile>\<^sub>r Q1) \<^bold>; (P2 \<turnstile>\<^sub>r Q2)) = (((\<not> ((\<not> P1) \<^bold>; true)) \<and> \<not> (Q1 \<^bold>; (\<not> P2))) \<turnstile>\<^sub>r (Q1 \<^bold>; Q2))"
  by (simp add: rdesign_def design_composition unrest usubst, rel_auto)

theorem ndesign_composition_wlp:
  "(p\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>1) \<Zcomp> (p\<^sub>2 \<turnstile>\<^sub>n Q\<^sub>2) = (p\<^sub>1 \<and> Q\<^sub>1 wlp p\<^sub>2) \<turnstile>\<^sub>n (Q\<^sub>1 \<Zcomp> Q\<^sub>2)"
  by (simp add: rdesign_composition unrest, rel_auto)

definition skip_d :: "('\<alpha>,'\<alpha>) des_rel" ("II\<^sub>D") where 
  [rel]: "II\<^sub>D \<equiv> (true \<turnstile>\<^sub>r II)"

definition bot_d :: "('\<alpha>, '\<beta>) des_rel" ("\<bottom>\<^sub>D") where
  [rel]: "\<bottom>\<^sub>D = (false \<turnstile> false)"

definition top_d :: "('\<alpha>, '\<beta>) des_rel" ("\<top>\<^sub>D") where
  [rel]: "\<top>\<^sub>D = (true \<turnstile> false)"

lemma top_d_not_ok:
  "\<top>\<^sub>D = (\<not> ok\<^sup><)\<^sub>u"
  unfolding top_d_def design_def by (expr_simp, simp add: Collect_neg_eq not_pred_def)

definition pre_design :: "('\<alpha>, '\<beta>) des_rel \<Rightarrow> ('\<alpha> \<leftrightarrow> '\<beta>)" ("pre\<^sub>D") where
  [rel]: "pre\<^sub>D(P) =  (\<not>P\<lbrakk>true,false/ok\<^sup><,ok\<^sup>>\<rbrakk>) \<down> more\<^sub>L\<^sup>2"

definition post_design :: "('\<alpha>, '\<beta>) des_rel \<Rightarrow> ('\<alpha> \<leftrightarrow> '\<beta>)" ("post\<^sub>D") where
  [rel]: "post\<^sub>D(P) = P\<lbrakk>true,true/ok\<^sup><,ok\<^sup>>\<rbrakk> \<down> more\<^sub>L\<^sup>2"

syntax
  "_ok_f"  :: "logic \<Rightarrow> logic" ("_\<^sup>f" [1000] 1000)
  "_ok_t"  :: "logic \<Rightarrow> logic" ("_\<^sup>t" [1000] 1000)

translations
  "P\<^sup>f" \<rightharpoonup> "_subst P false (_svid_post (CONST ok))"
  "P\<^sup>t" \<rightharpoonup> "_subst P true (_svid_post (CONST ok))"

end