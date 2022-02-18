
default_config_file<- function(){
  system.file('extdata','config.yaml', package = getPackageName())
}


get_config<- function(file = NULL){
  if(is.null(file)){
    file = default_config_file()
  }
  config  <- configr::read.config(file = file)
  return(config)
}

override_values<-function( a = NULL, b = NULL){
  a[names(b)] <- b
  a
}

#' @export
override_config <- function( opts = NULL){
  file <- opts$config
  if(is.null(file)){
    file = default_config_file()
  }
  config  <- configr::read.config(file = file)
  override_values(config, opts)
}

#' @export
override_opts <- function( opts = NULL){
  file <- opts$config
  if(is.null(file)){
    file = default_config_file()
  }
  config  <- configr::read.config(file = file)
  override_values(opts, config)
}


# "https://stackoverflow.com/questions/54840918/how-to-unlist-nested-lists-while-keeping-vectors"

keep_vector <- function(x){
  if(is.atomic(x)){
    list(x)
  }else{
    x
  }
}


get_tips <- function(L){
  out <- unlist(lapply(L, keep_vector), recursive=FALSE)
  while(any(sapply(out, is.list))){
    out <- get_tips(out)
  }
  out
}
