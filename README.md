
# Zorks

<!-- badges: start -->
<!-- badges: end -->

This is just for fun. This package lets you play zorks from the R console if you have an OpenAI key.

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

The function `begin()` has an otional `model` argument that lets you specify the model. The default is "text-curie-001", but you can specify any of the others, including "text-davinci-003". Careful! This can get expensive quickly; the game sends up to 600 tokens for each prompt.

If you don't have an accesible OpenAI key, you will be prompted to enter it when you begin a game. The key is saved in the environment variable `OPENAI_API_KEY`.

After you quit, the game will prompt you to save your game history; this is saved as a text file in your home directory.
