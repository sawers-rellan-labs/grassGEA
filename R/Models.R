#' @export
simple_GLM <- function(tasObj = NULL , trait = NULL){

  formula <- as.formula(paste(trait,"~ ."))

  rTASSEL::assocModelFitter(
    tasObj = tasObj,          # <- our prior TASSEL object
    formula = formula,      # <- only phenotype
    fitMarkers = TRUE,      # <- set this to TRUE for GLM
    kinship = NULL,
    fastAssociation = FALSE
  )
}
