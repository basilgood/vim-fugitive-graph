# fugitive-graph.vim

If you miss to explore git log graph from vim this plugin is for you

`:Glogg` Explore history from current HEAD
`:Glogga` Explore all the history for repo

## Credits

AnsiEsc
fugitive.vim

## Screencasts

* ![Navigate through history](https://github.com/albfan/vim-fugitive-graph/raw/master/etc/screencast.gif)

## Installation

Use vim-plug:

    cd ~/.vim/bundle
    git clone https://github.com/albfan/vim-fugitive-graph.git

Add a new plugin on `.vimrc`

    Plugin "albfan/vim-fugitive-graph"

## FAQ

> Why this is not part of vim-fugitive?

Graph buffers are hard to maintain and fugitive maintainer is reluctant to
add this to vim-fugitive

> Can you add `--simplify-by-decoration`

I just need to figure out how to do it, but yes, suggestions are wellcome.
