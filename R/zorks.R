zorks <- function(prompt) {
  model <- getOption("zorks.model")
  zorks_resp <- openai::create_completion(model= model,
                                          max_tokens = getOption("zorks.resp.tokens"),
                                          prompt = prompt,
                                          temperature = getOption("zorks.temperature"))

  zorks_tokens <<- zorks_tokens + zorks_resp$usage$total_tokens

  approx_running_cost <<- zorks_tokens * getOption("zorks.cost")/1000
  current_resp <<- zorks_resp$choices$text
  zorks_resp$choices$text
}


.onLoad <- function(libname, pkgname) {
  zorks_hist <<- character(0)
  zorks_tokens <<- 0
  approx_running_cost <<- 0
  current_resp <<- character(0)

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
#' The game tracks your token use and approximate cost in two global variables,
#' visible in your environment pane in RStudio, `zorks_tokens` and
#' `approx_running_cost`. These are reset with each new game.
#'
#' @param model The model to use. The default is "text-curie-001". But you can
#'   use any of the GPT-3 models, including "text-davinci-003", the most
#'   powerful. Careful! Davinci-003 can quickly get expensive. See pricing info
#'   at https://openai.com/pricing (scroll down to the Instruct GPT models).
#' @param initial_prompt The initial prompt to start a game or a conversation.
#'   The default is "Let's play zorks. You are in a maze of twisty passages, all
#'   alike. It smells strongly of Grue..."
#' @param max_context_length The maximum number of words to pass as context to
#'   the model each turn. The default is 400 words (approx 533 tokens); larger
#'   contexts mean more memory, but also more cost. For the non-davinci model,
#'   the maximum context is set at 1500 words (approx. 2000 tokens); the davinci
#'   model can take up to 3000 words (approx. 4000 tokens).
#' @param temperature The temperature parameter for the model. Default is 1, for
#'   creative tasks; set it close to 0 for more analytical tasks.
#' @param max_resp_tokens The maximum number of response tokens. Default is 200.
#'
#' @export
#'
begin <- function(model = "text-curie-001",
                  initial_prompt = "Let's play zorks. You are in a maze of twisty passages, all alike. It smells strongly of Grue...",
                  max_context_length = 400,
                  temperature = 1,
                  max_resp_tokens = 200) {
  if(!grepl("davinci", model)) {
    if(max_context_length > 1500) {
      message("Context length is too large. Truncating to 1500 words max.")
      max_context_length <- 1500
    }
  } else {
    if(max_context_length > 3000) {
      message("Context length is too large. Truncating to 3000 words max.")
      max_context_length <- 3000
    }

  }
  if(grepl("ada", model)) {
    options("zorks.cost" = 0.0004)
  }
  if(grepl("babbage", model)) {
    options("zorks.cost" = 0.0005)
  }
  if(grepl("curie", model)) {
    options("zorks.cost" = 0.0020)
  }
  if(grepl("davinci", model)) {
    options("zorks.cost" = 0.020)
  }

  max_context_length

  options(zorks.model = model)
  options(zorks.context = max_context_length)
  options(zorks.temperature = temperature)
  options(zorks.resp.tokens = max_resp_tokens)
  message("Using ", getOption("zorks.model"), " with ",
          max_context_length, " words of context (approx. ",
          round(max_context_length*1000/750), " tokens). This will cost you ",
          "about $", getOption("zorks.cost"), " per 1000 tokens.")

  if(is.null(Sys.getenv("OPENAI_API_KEY"))) {
    key <- readline(prompt = "Enter your OpenAI key: ")
    Sys.setenv(OPENAI_API_KEY = key)
  }
  initial_prompt <- keep_last_n_words(initial_prompt, max_context_length)
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
  if(!grepl("[[:punct:]]$", user_resp)) {
    user_resp <- paste0(user_resp, ".")
  }
  zorks_hist <<- paste(zorks_hist, zorks_resp, user_resp, sep = "\n")
  if(user_resp == "Q.") {
    save_game <- readline(prompt = "Save story? Y/N:")
    if(save_game == "Y") {
      rstudioapi::selectFile(caption = "Select Directory to Save")
      writeLines(zorks_hist, "zorks.txt")
    }
    return(invisible())
  }
  new_prompt <- keep_last_n_words(zorks_hist, getOption("zorks.context"))
  zorks_prompt <- zorks(new_prompt)
  prompt(zorks_prompt)
}
