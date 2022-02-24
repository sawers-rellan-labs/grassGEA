#' @export
default_config_file<- function(){
  system.file('extdata','config.yaml', package = "grassGEA")
}


#' @export
get_script_config<- function(script=get_script_name(),
                             from = default_config_file()){
  config_file <- from
  config  <- configr::read.config(file = config_file)

  if(is.null(script)){
    return(config$shared)
  }

  if(!script %in% c(names(config))){
    return(NA)
    # get_script_config() will be called at loading time from:
    # config.R
    # DECRIPTION
    # and maybe other files
    # So this warning would always appear during loading time
    # I just commented it, itt annoyed me.
    # warning(paste0(script," is not a script key in config file:\n",
    #              config_file,"\n",
    #              "Returning NA"))
  }
  c(config$shared,config[[script]])
}


#utils::modifyList is the right way to go
# override_values<-function( a = NULL, b = NULL){
#   a[names(b)] <- b
#   a
# }


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

# This functions provide mainly user input validation, and warnings
# the gist of all is:
# init <- modifyList(
#   get_script_config(from= config_file),
#   args$options)

init_custom <- function(config_file = NULL){
  if (!is.null(config_file)){
    if(config_file !=   default_config_file()){
    warning(paste0("\nOveriding config from:\n",
                   default_config_file(), "\n",
                  "With config coming from:\n",
                  config_file, "\n",
                  "See  complete options at the end of run."))
    }
    # The intention of 'custom' mode is to test config files in Rstudio
    # no command line arguments are used.
    warning(paste0("\nOmitting command line arguments!! \n",
                   "The purpose of 'custom' mode is to directly ",
                   "test config files in Rstudio. "))
      init <- get_script_config(from = config_file)
    return(init)
  } else {
    stop("No 'config_file' provided for 'custom' mode.")
  }
}


config_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
get_script_config(from = config_file)

init_cmd_line <-  function( args = NULL){

  config_file <- args$options$config_file

  if(config_file !=   default_config_file()){
    warning(
      paste0("\nOveriding config from:\n",
             default_config_file(), "\n",
             "With config from dommand line option:\n",
             config_file, "\n",
             "See complete options at the end of run"))
  }

  warning(
    paste0("\nOveriding config from:\n", config_file, "\n",
           "With command line options.",
           "See complete options at the end of run"))

  if (is.null(config_file)){
    config_file <- default_config()
  }
  init <- modifyList(
    get_script_config(from = config_file),
    args$options)
  return(init)
}


init_default  <- function( args = NULL){

   config_file <- args$options$config_file

  if ( config_file == default_config_file()){
    init <- get_script_config(from = config_file)
    warning(
      paste0( "\nAll grassGEA options set to default,",
              "proceeding from config file:\n", config_file)
    )
    return(init)
  } else {
    stop(paste0("Default mode requested but \n", args$options$config, "\n",
                "is not the default grassGEA config file:\n",
                default_config_file())
    )
  }
}



#' @export
init_config <- function( args = args,
                         mode = c("cmd_line","custom","default"),
                         config_file = NULL){
  if(mode != "custom"){
    config_file <-  args$options$config_file
  }else{
    if(!is.yaml.file(config_file)){
      stop(paste0(config_file, " is not a valid yaml file\n"))
    }
  }
  if(mode == "custom" & !is.null(config_file)){
    init <- init_custom(config_file = config_file)
  } else if(mode == "cmd_line") {
    init <- init_cmd_line(args)
  } else if(mode == "default"){
    init <- init_default(args)
  } else{ stop(paste0(
               mode,": wrong config init mode specified.",
               "In 'custom' mode you must provide 'config_file'."))}
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
