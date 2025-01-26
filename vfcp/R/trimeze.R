#' @export trimeze
#'
trimeze <- function(C1, C23){
as123 = data.frame(s1 = 1 - C1, s2 = 1 - C23)
ac123 = data.frame(c1 = C1, c2 = C23)
# nas = length(as123$s2)
# if (as123$s2[nas] > ac123$c2[1]) ac123$c2[1] = as123$s2[nas]
inx = max(which(as123$s1 <= min(ac123$c1))) # x1, x2 and y1, y2 for tlc
xnx = max(which(ac123$c1 <= max(as123$s1))) # x1, x2 and y1, y2 for brc
iny = max(which((ac123$c2) >= max(as123$s2))) # x4, x3 and y4, y3 for tlc
xny = min(which((as123$s2) >= min(ac123$c2))) # x3, x4 and y3, y4 for brc
#== top left corner =====================
ixt = c(inx, inx - 1, iny+1, iny)
xt = c(as123$s1[ixt[1:2]], ac123$c1[ixt[3:4]])
yt = c(as123$s2[ixt[1:2]], ac123$c2[ixt[3:4]])
tlc = prunikus(xt, yt)
# print(tlc)
#== bottom right corner ========================
iyt = c(xnx, xnx + 1, xny-1, xny)
xb = c(ac123$c1[iyt[1:2]], as123$s1[iyt[3:4]])
yb = c(ac123$c2[iyt[1:2]], as123$s2[iyt[3:4]])
brc = prunikus(xb, yb)
# print(brc)
gss = which(as123[, 1] <= tlc[2] & as123[, 1] >= brc[2])
gcc = which(ac123[, 1] >= tlc[1] & ac123[, 1] <= brc[1])
sp = rbind(tlc, as123[gss, 2:1], brc)
# print("sp"); print(sp)
cp = rbind(tlc, ac123[gcc, ], brc)
return(list(tlc = tlc, brc = brc, sp = sp, cp = cp))
}
