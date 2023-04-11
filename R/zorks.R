zorks <- function(prompt) {
  zorks_resp <- openai::create_completion(model= "text-davinci-003",
                                          max_tokens = 200,
                                          prompt = prompt,
                                          temperature =1)
  zorks_resp$choices$text
}


.onLoad <- function(libname, pkgname) {
  op <- options()
  op.zorks <- list(zorks.initial.prompt = "Let's play zorks. You are in a maze of twisty passages, all alike. It smells strongly of Grue..."
  )
  toset <- !(names(op.zorks) %in% names(op))
  if(any(toset)) options(op.zorks[toset])
  zorks_hist <<- character(0)

  invisible()

}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Let's play Zorks! Type begin() to begin, Q to quit, otherwise use natural language.")

}

#' Begin the game.
#'
#' Type begin() to begin a game after loading a library, Q to quit. Otherwise
#' just use natural language. If you don't have an OpenAPI key, the package will
#' prompt you for one and save it in the `OPENAI_API_KEY` environment variable.
#'
#' @export
#'
begin <- function() {
  if(is.null(Sys.getenv("OPENAI_API_KEY"))) {
    key <- readline(prompt = "Enter your OpenAI key: ")
    Sys.setenv(OPENAI_API_KEY = key)
  }
  initial_prompt <- getOption("zorks.initial.prompt")
  zorks_resp <- zorks(initial_prompt)
  zorks_resp <- paste(initial_prompt, zorks_resp)
  prompt(zorks_resp)

}

#' @importFrom utils tail
keep_last_n_words <- function(sentence, n = 400) {
  # Split the sentence into words
  words <- strsplit(sentence, " ")[[1]]

  # If the sentence is already n words or fewer, return it as-is
  if (length(words) <= n) {
    return(sentence)
  }

  # Otherwise, keep only the last n words
  return(paste(tail(words, n), collapse = " "))
}

prompt <- function(zorks_resp) {
  cat(zorks_resp)
  user_resp <- readline(prompt = "> ")
  if(user_resp == "Q") {
    save_game <- readline(prompt = "Save story? Y/N:")
    if(save_game == "Y") {
      writeLines(zorks_hist, "zorks.txt")
    }
    return()
  }
  if(!grepl("[:punct:]$", user_resp)) {
    user_resp <- paste0(user_resp, ".")
  }
  zorks_hist <<- paste(zorks_hist, zorks_resp, user_resp, sep = "\n")
  zorks_prompt <- zorks(keep_last_n_words(zorks_hist, 800))
  prompt(zorks_prompt)
}
