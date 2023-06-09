% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zorks.R
\name{begin}
\alias{begin}
\title{Begin the game.}
\usage{
begin(
  model = "text-curie-001",
  initial_prompt = "Let's play zorks. You are in a maze of twisty passages, all alike...",
  max_context_length = 400,
  temperature = 1,
  max_resp_tokens = 200
)
}
\arguments{
\item{model}{The model to use. The default is "text-curie-001". But you can
use any of the GPT-3 models, including "text-davinci-003", the most
powerful. Careful! Davinci-003 can quickly get expensive. See pricing info
at https://openai.com/pricing (scroll down to the Instruct GPT models).}

\item{initial_prompt}{The initial prompt to start a game or a conversation.
The default is "Let's play zorks. You are in a maze of twisty passages, all
alike..."}

\item{max_context_length}{The maximum number of words to pass as context to
the model each turn. The default is 400 words (approx 533 tokens); larger
contexts mean more memory, but also more cost. For the non-davinci model,
the maximum context is set at 1500 words (approx. 2000 tokens); the davinci
model can take up to 3000 words (approx. 4000 tokens).}

\item{temperature}{The temperature parameter for the model. Default is 1, for
creative tasks; set it close to 0 for more analytical tasks.}

\item{max_resp_tokens}{The maximum number of response tokens. Default is 200.}
}
\description{
Type begin() to begin a game after loading a library, Q to quit. Otherwise
just use natural language. If you don't have an OpenAPI key, the package will
prompt you for one and save it in the `OPENAI_API_KEY` environment variable.
}
\details{
The game tracks your token use and approximate cost in two global variables,
visible in your environment pane in RStudio, `zorks_tokens` and
`approx_running_cost`. These are reset with each new game.
}
