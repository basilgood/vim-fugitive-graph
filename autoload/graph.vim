" fugitive-graph.vim - A Git log --graph wrapper
" Maintainer:   Alberto Fanjul <albertofanjul@gmail.com>
" Version:      1.0

if exists('g:loaded_fugitive_graph')
  finish
endif
let g:loaded_fugitive_graph = 1

function! graph#Glogga()
  call graph#GlogGraph(1)
endfunction

function! graph#Glogg()
  call graph#GlogGraph(0)
endfunction

function! graph#GlogGraph(showAll)
  silent! wincmd P
  if !&previewwindow
    execute 'bo ' . &previewheight . ' new'
    set previewwindow
  endif

  execute "silent %delete_"

  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap

  let all = ""
  if a:showAll
    let all = " --all"
  endif
  let git_log_command = "git log --decorate --graph --date-order --oneline --color=always" . all
  execute "silent 0read !". git_log_command

  set nowrap
  if !AnsiEsc#IsAnsiEscEnabled(bufnr("%"))
    AnsiEsc
  endif
  normal 1G
  map <buffer> <Enter> :call graph#OpenCommit()<CR>
endfunction

function! graph#GotoWin(winnr)
  let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
                                     \ : 'wincmd ' . a:winnr
  execute cmd
endfunction

function! graph#OpenCommit()
  let line = getline(".")
  let commit = substitute(line, '.*\*\s\+\e[.\{-}m\(.\{-}\)\e.*', '\1', "g")

  "Open in another buffer (always same place)
  let commitwinnr = bufwinnr("__Commit__")
  if commitwinnr != -1
    call GotoWin(commitwinnr)
  else
    bo new
    file __Commit__
  endif
  execute "silent %delete_"

  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap

  execute 'edit' fnameescape(FugitiveFind(commit))
endfunction

