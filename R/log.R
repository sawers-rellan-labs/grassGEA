# probalby this will be replaced with an actuual log library

#' @export
time_suffix <- function(){ format(Sys.time(), "%Y%m%d_%H_%M")}

#' @export
name_log<-function(dir = NULL,
                   prefix = "grassGEA",
                   suffix = time_suffix() ){

  log_file <- paste0(prefix,"_", suffix, ".log")
  if(is.null(dir)){
    log_file
  } else{
    file.path(dir, log_file)
  }
}

#' @export
#'
log_opts<- function(opts, file = NULL){
  if(is.null(file)){
    file <-  stderr()
  }
  cat(
  "===================RUNNING OPTIONS=====================",
  "\n\n", file = file)

  cat(yaml::as.yaml(opts), file = stderr())

  cat("\n", file = file)
}

#' @export
#'
log_time<- function(file = NULL ){
  if(is.null(file)){
    file <-  stderr()
  }
  cat(time_suffix(),"\n\n",  file = file)
}

#' @export
#'
log_done<- function(file = NULL ){
  if(is.null(file)){
    file <-  stderr()
  }
  cat("========================DONE===========================",
      "\n\n", file = file)
}


