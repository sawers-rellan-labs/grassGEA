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
    cat(yaml::as.yaml(opts), file = stderr())
}

#' @export
#'
log_time<- function(file = NULL ){
  if(is.null(file)){
    file <-  stderr()
  }
nano
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
?cat

