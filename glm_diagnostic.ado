*! version 0.0.1 Percy Soto-Becerra 06Aug2021
program define glm_diagnostic
	version 17.0
	syntax varlist(default = none) [if] [in] [, linearity influence]
	/*Quantile residual for normal linear regression (by Ordinary Least Square 
	or Maximum Likelihood estimation*/
	tempvar qres_std idvar
	if "`e(cmd)'" == "regress" | ("`e(cmd)'" == "glm" & "`e(varfunct)'" == "Gaussian") {
		qresid2 double `qres_std', standardized diag_glm 
		local labelY: variable label `qres_std'
		local work: variable label workresp
		local cook: variable label cooksd
		local xb: variable label  xb
		local hat: variable label hat_lever
		local dev: variable label dev_student
		twoway scatter `qres_std' mu_scaled, ytitle(`labelY') || /// 
			lowess `qres_std' mu_scaled, /// 
			legend(off) nodraw name(g0, replace)
		twoway scatter xb workresp, ytitle(`work') || lfit xb workresp, legend(off) nodraw name(g1, replace)
		qnorm `qres_std', nodraw name(g2, replace)
		gen `idvar' = _n
		twoway scatter cooksd `idvar', ytitle(`cook') legend(off) mlabel(`idvar') nodraw name(g3, replace)
		graph combine g0 g1 g2 g3, saving("Overall_Asses.gph", replace)
		
		if "`lin_assess'" == "lin_assess" {
		    local i = 0
			local gname ""
		    foreach numvar of varlist `varlist' {
				twoway scatter `qres_std' `var', ytitle(`labelY') yline(0) || /// 
					lowess `qres_std' `var', /// 
					legend(off) nodraw name(ling`i', replace)
				local i = `i' + 1
				local gname "`gname'" "ling`i'.gph"
			}
		graph combine "`gname'", saving("Linearity_Asses.gph", replace)
		}
		
		if "`influ_assess'" == "influ_assess" {
		    twoway scatter dev_student `idvar', ytitle(`dev') legend(off) mlabel(`idvar') nodraw name(g4, replace)
			twoway scatter hat_lever `idvar', ytitle(`hat') legend(off) mlabel(`idvar') nodraw name(g5, replace)
			graph combine g3 g4 g5, saving("Influence_Asses.gph", replace)
		}
	}
	/*Quantile residual for bernoulli/binomial logistic regression 
	(GLM, family = Bernoulli/Binomial, link = any admissible)*/
	else if "`e(cmd)'" == "logit" | "`e(cmd)'" == "logistic" | /// 
		("`e(cmd)'" == "glm" & ("`e(varfunct)'" == "Bernoulli" | /// 
		"`e(varfunct)'" == "Binomial"))  {
		qresid2 double `qres', standardized diag_glm nqres(int 4)
		local labelY: variable label `qres_std1'
		local work: variable label workresp
		local cook: variable label cooksd
		local xb: variable label  xb
		local hat: variable label hat_lever
		local dev: variable label dev_student
		twoway scatter `qres_std1' mu_scaled, ytitle(`labelY') || /// 
			lowess `qres_std1' mu_scaled, /// 
			legend(off) nodraw name(g0, replace)
		twoway scatter xb workresp, ytitle(`work') || lfit xb workresp, legend(off) nodraw name(g1, replace)
		qnorm `qres_std1', nodraw name(g2, replace)
		gen `idvar' = _n
		twoway scatter cooksd `idvar', ytitle(`cook') legend(off) mlabel(`idvar') nodraw name(g3, replace)
		graph combine g0 g1 g2 g3, saving("Overall_Asses.gph", replace)
		
		if "`lin_assess'" == "lin_assess" {
		    local i = 0
			local gname ""
		    foreach numvar of varlist `varlist' {
				twoway scatter `qres_std1' `var', ytitle(`labelY') yline(0) || /// 
					lowess `qres_std1' `var', /// 
					legend(off) nodraw name(ling`i', replace)
				local i = `i' + 1
				local gname "`gname'" "ling`i'.gph"
			}
		graph combine "`gname'", saving("Linearity_Asses.gph", replace)
		}
		
		if "`influ_assess'" == "influ_assess" {
		    twoway scatter dev_student `idvar', ytitle(`dev') legend(off) mlabel(`idvar') nodraw name(g4, replace)
			twoway scatter hat_lever `idvar', ytitle(`hat') legend(off) mlabel(`idvar') nodraw name(g5, replace)
			graph combine g3 g4 g5, saving("Influence_Asses.gph", replace)
		}
	} 
	/*
	/*Quantile residual for Poisson regression 
	(GLM, family = Poisson, link = any admissible)*/
	else if "`e(cmd)'" == "poisson" {
		qresid2 double `qres', standardized diag_glm nqres(int 4)
	}
	else if "`e(cmd)'" == "glm" & "`e(varfunct)'" == "Poisson" {
		qresid2 double `qres', standardized diag_glm nqres(int 4)
	}
	/*Quantile residual for Negative Binomial Regression 
	(GLM, family = nbinomial, link = any admissible)*/
	else if "`e(cmd)'" == "glm" & "`e(varfunct)'" == "Neg. Binomial" {
		qresid2 double `qres', standardized diag_glm nqres(int 4)
	}
	else if "`e(cmd)'" == "nbreg" {

	} */
	else {
		display "It is not a valid GLM"
	}

end