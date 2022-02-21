#' @export
default_config_file<- function(){
  system.file('extdata','config.yaml', package = "grassGEA")
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
override_config <- function( config_file = NULL, opts = NULL){
  if(is.null(config_file)){
    config_file = default_config_file()
  }
  config  <- configr::read.config(config_file)
  override_values(config, opts)
}

#' @export
override_opts <- function( opts = NULL, config_file =NULL){
  if(is.null(config_file)){
    config_file <- default_config_file()
  }
  file.exists(config_file)
  config  <- configr::read.config(config_file)
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

init_custom <- function( args = NULL, config_file = NULL){
  if (!is.null(config_file)){
    opts <- override_opts( opts = args$options, config_file = config_file)
    return(opts)
  } else {
    stop("No custom config file provided")
  }
}

init_cmd_line <- function( args = NULL, config_file = NULL){
  if (is.null(config_file)){
    opts <- override_config(config_file = args$options$config, opts = args$options)
  } else {
    opts <- override_config(config_file = config_file, opts = args$options)
  }
  return(opts)
}


init_deafult  <- function( args = NULL){
  if (args$options$config == default_config_file()){
    print(paste0("Using default config at\n", default_config_file()))
  } else {
    stop(paste0(args$options$config, "\n",
                "is not the default ",
                "grassGEA config file at\n",
                default_config_file())
    )
  }
}

#' @export
init_config <- function( args = args,
                         mode = c("custom","cmd_line","default"),
                         config_file = NULL){

  if(!is.yaml.file(args$options$config)){
    stop(paste0(args$options$config, " is not a valid yaml file\n"))
  }

  if(mode == "custom"){
    if(!is.yaml.file(config_file)){
      stop(paste0(config_file, " is not a valid yaml file\n"))
    }
    init <- init_custom(args, config_file)
  }else if(mode == "cmd_line"){
    init <- init_cmd_line(args)
  } else if(mode == "default"){
    init <- init_default(args)
  } else{ stop(paste0(mode," wrong config init mode specified"))}
 return(init)
}


# default_config <- function(x){
#   default_config <- configr::read.config(default_config_file())
#   default_value <- default_config[[x]]
#   if(!is.null(default_value)){
#     default_value
#   }else{
#     NULL
#   }
# }
