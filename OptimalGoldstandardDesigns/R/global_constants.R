# Has 2 levels: [[stage]][[TP / TC]]
projection_components <- list()
projection_components[[2]] <- list()
projection_components[[1]][["TP"]] <- matrix(c(1, 0, 0, 0), nrow = 1, byrow = T)
projection_components[[2]][["TP"]] <- matrix(c(0, 1, 0, 0), nrow = 1, byrow = T)
projection_components[[1]][["TC"]] <- matrix(c(0, 0, 1, 0), nrow = 1, byrow = T)
projection_components[[2]][["TC"]] <- matrix(c(0, 0, 0, 1), nrow = 1, byrow = T)

projection <- list()
projection[["TP1"]] <- projection_components[[1]][["TP"]]
projection[["TP12"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[2]][["TP"]]
)
projection[["TC1"]] <- projection_components[[1]][["TC"]]
projection[["TC12"]] <- rbind(
  projection_components[[1]][["TC"]],
  projection_components[[2]][["TC"]]
)
projection[["TC2"]] <- rbind(projection_components[[2]][["TC"]])

projection[["TP1_TC1"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[1]][["TC"]]
)
projection[["TP1_TC12"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[1]][["TC"]],
  projection_components[[2]][["TC"]]
)
projection[["TP12_TC1"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[2]][["TP"]],
  projection_components[[1]][["TC"]]
)
projection[["TP12_TC2"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[2]][["TP"]],
  projection_components[[2]][["TC"]]
)
projection[["TP12_TC12"]] <- rbind(
  projection_components[[1]][["TP"]],
  projection_components[[2]][["TP"]],
  projection_components[[1]][["TC"]],
  projection_components[[2]][["TC"]]
)
# .skip_slow_test <- TRUE
