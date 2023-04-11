
# Zorks

<!-- badges: start -->
<!-- badges: end -->

This package lets you play zork from the R console if you have an OpenAI key. It will also let you just converse with any of the [Instruct GPT](https://platform.openai.com/docs/models/gpt-3) models of OpenAI and save your chat afterwards in a text file; it's like using the [OpenAI playground](https://platform.openai.com/playground) but from your R console. These models are for text completion; they are not exactly like ChatGPT (and have fewer guardrails; for one thing, ChatGPT won't play Zork). 

## Installation

Install from github like this:

``` r
remotes::install_github("xmarquez/Zorks")
```

## Playing

To play, simply load the library and type `begin()`. To quit a game, type Q. Otherwise, just use natural language.

``` r
library(Zorks)
begin()
```

The function `begin()` has an optional `model` argument that lets you specify the model. The default is "text-curie-001", but you can specify any of the others, including "text-davinci-003". (See the available models [here](https://platform.openai.com/docs/models/gpt-3)). 

Careful! This can get expensive quickly; the game sends by default up to ~530 tokens for each turn. Your token usage and cost per session is tracked in a couple of global variables visible in the "Environment" pane of RStudio and available after the end of the game. 

If you wanted to use a fully open-source model that you can run on a high-end machine without paying OpenAI, you may want to try [llama.cpp](https://github.com/ggerganov/llama.cpp).

``` r
library(Zorks)
begin(model = "text-davinci-003")
```

If you don't have an accesible OpenAI key, you will be prompted to enter it when you begin a game. The key is saved in the environment variable `OPENAI_API_KEY`. You can also follow the instructions in the [openai](https://irudnyts.github.io/openai/) package to save the key to your `.Renviron` file.

The function also has an `initial_prompt` argument that you can use to play a different game, or just use whatever model you are using in an interactive session.

``` r
library(Zorks)
begin(initial_prompt = "What is the capital of Bulgaria?")
```

Finally, you can also adjust the "temperature" parameter; it is by default set to 1 (useful for more creative tasks) but you can set it close to zero for more analytical tasks that are more deterministic. (I have found that a temperature of 1.5 or more quickly leads to nonsense).

``` r
library(Zorks)
begin(initial_prompt = "What is the capital of Bulgaria?", temperature = 0.2)
```

After you quit, the game will prompt you to save your game history as a text file. 
