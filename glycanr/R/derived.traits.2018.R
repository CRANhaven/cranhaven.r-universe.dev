# Derived traits for Glycan peaks in Plasma for UPLC
# based on a paper from 2018.
#
# @references
# Irena Trbojevic-Akmacic et al.
# "Plasma N-glycome composition associates with chronic low back pain"
# \doi{10.1016/j.bbagen.2018.07.003}
plasma.hplc.derived.traits.2018 <- function(data, print.exp.names=FALSE) {
    if(print.exp.names){
        return(paste0("GP", 1:39))
    }
    
    # derived traits

    dteh(data$LB <- with(data, GP1 + GP2 + GP3 + GP4 + GP5 + GP6 + GP8 + GP9 + GP10 + GP11 + GP13 + GP14 + GP15 + GP16 + GP17 + GP18 + GP20 + GP21 + GP22 + GP23))
    dteh(data$HB <- with(data, GP24 + GP25 + GP26 + GP27 + GP28 + GP29 + GP30 + GP31 + GP32 + GP33 + GP34 + GP35 + GP36 + GP37 + GP38 + GP39))
    dteh(data$S0 <- with(data, GP1 + GP2 + GP3 + GP4 + GP5 + GP6 + GP8 + GP9 + GP10 + GP11))
    dteh(data$S1 <- with(data, GP13 + GP14 + GP15 + GP16 + GP17))
    dteh(data$S2 <- with(data, GP18 + GP20 + GP21 + GP22 + GP23 + GP24 + GP25 + GP26 + GP27))
    dteh(data$S3 <- with(data, GP28 + GP29 + GP30 + GP31 + GP32 + GP33 + GP34 + GP35 + GP36))
    dteh(data$S4 <- with(data, GP37 + GP38 + GP39))
    dteh(data$G0 <- with(data, GP1 + GP2))
    dteh(data$G1 <- with(data, GP3 + GP4 + GP5 + GP6 + GP13))
    dteh(data$G2 <- with(data, GP8 + GP9 + GP10 + GP11 + GP14 + GP15 + GP16 + GP17 + GP18 + GP20 + GP21 + GP22 + GP23))
    dteh(data$G3 <- with(data, GP24 + GP25 + GP26 + GP27 + GP28 + GP29 + GP30 + GP31 + GP32 + GP33 + GP34 + GP35))
    dteh(data$G4 <- with(data, GP36 + GP37 + GP38 + GP39))
    dteh(data$HM <- with(data, GP7 + GP12 + GP19))
    dteh(data$B <- with(data, GP2 + GP3 + GP6 + GP9 + GP11 + GP15 + GP17 + GP23))
    dteh(data$CF <- with(data, GP1 + GP2 + GP4 + GP5 + GP6 + GP10 + GP11 + GP13 + GP16 + GP17 + GP22 + GP23 + GP31 + GP34 + GP35))
    dteh(data$AF <- with(data, GP27 + GP33 + GP35 + GP39))

    return(data)
}
