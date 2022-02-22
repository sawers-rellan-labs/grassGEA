#' Appends "_x" to "string" if x is not a matching string
#' warns about the changes
#' @param string a named string: string = c(opt = "value")
#' @param x a string
#' @return "string_x"
#' @export
#'
no_match_append <- function(string,x){
  if(length(string) >1){stop("input not a string")}

  name <- names(string)
  string_match <- grepl(x, string)

  if(string_match){
    warning(paste0("\n\n", name, ": '", string,"'\n",
                "already contains the string: '",x,"'\n",
                name, " stays: ", x))
    string
  }else{
    new_string <- paste0(string,"_",x)
    warning(paste0("\n", name, ": ", string,"\n'",
                string, "' would switch to: '", new_string,"'."))
    new_string
  }
}
