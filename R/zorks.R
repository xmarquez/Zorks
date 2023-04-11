zorks <- function(prompt) {
  model <- getOption("zorks.model")
  zorks_resp <- openai::create_completion(model= model,
                                          max_tokens = 200,
                                          prompt = prompt,
                                          temperature =1)

  zorks_tokens <<- zorks_tokens + zorks_resp$usage$total_tokens

  if(grepl("ada", model)) {
    approx_running_cost <<- zorks_tokens * 0.0004/1000
  }
  if(grepl("babbage", model)) {
    approx_running_cost <<- zorks_tokens * 0.0005/1000
  }
  if(grepl("curie", model)) {
    approx_running_cost <<- zorks_tokens * 0.0020/1000
  }
  if(grepl("davinci", model)) {
    approx_running_cost <<- zorks_tokens * 0.020/1000
  }
  zorks_resp$choices$text
}


.onLoad <- function(libname, pkgname) {
  op <- options()
  op.zorks <- list(zorks.initial.prompt = "Let's play zorks. You are in a maze of twisty passages, all alike. It smells strongly of Grue..."
  )
  toset <- !(names(op.zorks) %in% names(op))
  if(any(toset)) options(op.zorks[toset])
  zorks_hist <<- character(0)
  zorks_tokens <<- 0
  approx_running_cost <<- 0

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
#' @param model The model to use. The default is "text-curie-001". But you can
#'   use any of the GPT-3 models, including "text-davinci-003", the most
#'   powerful. Careful! Davinci-003 can quickly get expensive.
#'
#' @export
#'
begin <- function(model = "text-curie-001") {

  options(zorks.model = model)
  message("Using ", getOption("zorks.model"))

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
    return(invisible())
  }
  if(!grepl("[:punct:]$", user_resp)) {
    user_resp <- paste0(user_resp, ".")
  }
  zorks_hist <<- paste(zorks_hist, zorks_resp, user_resp, sep = "\n")
  new_prompt <- keep_last_n_words(zorks_hist)
  zorks_prompt <- zorks(new_prompt)
  prompt(zorks_prompt)
}
