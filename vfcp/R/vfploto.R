#' @export vfploto
#' @importFrom graphics plot lines grid legend points
#'
vfploto <- function(cx, pro, fam, marg, xo, tht,
									 cdf=TRUE, plt=TRUE, rtn=FALSE, ped = TRUE)
{
	if (!plt & !rtn) stop(paste("plt =", plt, "and", "rtn =", rtn))
	ncx = length(cx)
	tp = ifelse(cdf == TRUE, "CDF", "Survival")
	if (any(pro[2:length(pro)] < 1) & any(pro >= 1)) stop("error: wrong 'pro'")
	if (pro[1] >= 1) stop("pro[1] >= 1")
	if (all(pro < 1)) pda = FALSE else pda = TRUE
	cz = list()
	if (plt | rtn){
		if (plt){
			if (pda){
				up = vfpripo(cx[1], pro)
				uk = vfpripo(cx[ncx], pro)
			#	print(up); print(uk)
			} else {
				up = vfprifo(cx[1], pro)
				uk = vfprifo(cx[ncx], pro)
			}
			# if (!cdf){up = 1 -up; uk = 1 - uk}
			vp = vfex(cx[1], up, th = tht, fm = fam)
			vk = vfex(cx[ncx], uk, th = tht, fm = fam)
		#	print(paste(vp, vk))
			xyxk = vfmrg(rdj = marg, i = 1, cosi = uk, yo = xo, cdf)
			xyxp = vfmrg(rdj = marg, i = 1, cosi = up, yo = xo, cdf)
			xyyk = vfmrg(rdj = marg, i = 2, cosi = vk, yo = xo, cdf)
			xyyp = vfmrg(rdj = marg, i = 2, cosi = vp, yo = xo, cdf)
			e = vfenuo(marg, xo)
			if (cdf){
				limx = c(min(0, xyxp), min(max(0, xyxk), 2.5*e[1]))
				limy = c(min(0, xyyp), min(max(0, xyyk), 3*e[2]))
			} else {
				limx = c(min(0, xyxk), max(0, xyxp))
				limy = c(min(0, xyyk), max(0, xyyp))
			}
			# print(limx); print(limy)
			e = c(NA, NA)
			if (ped){
				e = vfenuo(marg, xo)
				# points(e[1], e[2], pch = 19, col = 1)
				m2 = paste(" E[x, y] = {", round(e[1], 4), ", ",
									 round(e[2], 4), "}")
			} else { m2 = ""}

			plot(x=NULL, y=NULL, xlim=limx, ylim=limy,
					 xlab = paste(marg[1], " (", xo[1], ", ", xo[2], ")", sep = ""),
					 ylab = paste(marg[2], " (", xo[3], ", ", xo[4], ")", sep = ""),
					 main = paste(tp, fam, "tht =", tht, m2))
			legend("topright", legend = cx, text.col = c(1:length(cx)), bty = "n")
			grid(col = 2)
		}
		if (pda) slp = length(vfpripo(cx[1], pro)) else slp = length(vfprifo(cx[1], pro))
		u = array(NA, c(ncx, slp))
		v = array(NA, c(ncx, slp))
		for (k in 1:ncx){
			if (pda) u[k, ] = vfpripo(cx[k], pro) else u[k, ] = vfprifo(cx[1], pro)
			v[k, ] = vfex(cx[k], u[k, ], th = tht, fm = fam)
			xyx = vfmrg(rdj = marg, i = 1, cosi = u[k, ], yo = xo, cdf)
			xyy = vfmrg(rdj = marg, i = 2, cosi = v[k, ], yo = xo, cdf)
			if (plt){
				lines(xyx, xyy, col = k, type = "l")
			}
			# new ==
			# e = c(NA, NA)

			#========
			if (rtn){
				e = vfenuo(marg, xo)
				cz[[k]] = list(Type = tp, P = cx[k], x = xyx, y = xyy,
											 u = u[k, ], v = v[k, ], e = e)
			}
		}
		if (ped){
				# e = vfenuo(marg, xo)
				points(e[1], e[2], pch = 19, col = 1)
			}
	}
	return(cz)
}
