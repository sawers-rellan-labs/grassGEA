
get_config<- function(
  file = system.file(system.file('extdata','config.yaml', getPackageName()))
){
  config  <- configr::read.config(file = file)
  return(config)
}


write_config <- function(x, file = 'config.yaml'){
  configr::write.config(x, write.type = "yaml")
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


get_opt_from_config <- function(config){
  config_opt <-  get_tips(config)

  option_list <- lapply(names(config_opt), FUN = function(x){
    opt_string =  paste0("--", gsub("\\.","_",x))
    make_option( opt_string , default = config_opt[[x]]
    )
  })
  option_list
}

#' @export
init_option_list <- function(
  file = system.file('config.yaml',package= getPackageName())
){

  option_list <- get_opt_from_config(
    get_config(file = file)
  )

  option_list <-c(option_list,
                  optparse::make_option(
                    "--config", type = "character", default = file,
                    help= "configuration file, YAML format",
                    metavar = "character")
  )

}



init_option_parser <- function(usage = NULL, opt_list = NULL, ...) {

  # Initialize opts from deafult configuration file from pglipid package

  opt_parser <- optparse::OptionParser(
    usage = usage,
    option_list = opt_list
  )

  args <- optparse::parse_args2(opt_parser)

  opts <- args$options

  # Initialize opts from command line provided options

  if(opts$config != system.file('extdata','config.yaml', getPackageName())){

    opt_list <- init_option_list(file = opts$config)

    opt_parser <- optparse::OptionParser(
      usage = usage,
      option_list = opt_list,
      ...
    )
  }
  return(opt_parser)
}

