#' @export
fit_simple_GLM <- function(tasObj = NULL , trait = NULL){

  formula <- as.formula(paste(trait,"~ ."))

  rTASSEL::assocModelFitter(
    tasObj = tasObj,          # <- our prior TASSEL object
    formula = formula,        # <- only phenotype
    fitMarkers = TRUE,        # <- set this to TRUE for GLM
    kinship = NULL,
    fastAssociation = FALSE
  )
}


# fit_kinship_MLM <- function(tasObj = NULL ,
#                        trait = NULL,
#                        kinship = NULL){
#
#   formula <- as.formula(paste(trait,"~ ."))
#   rTASSEL::assocModelFitter(
#     tasObj = tasObj,          # <- our prior TASSEL object
#     formula = formula,       # <- only phenotype
#     kinship = kinship)
# }

