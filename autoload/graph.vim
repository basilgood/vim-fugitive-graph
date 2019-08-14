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
  let git_log_command = "git log --decorate --graph --oneline --color=always" . all
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

   execute "silent 0read !git show" commit
  set filetype=git
  set foldmethod=syntax

   map <buffer> <Enter> :call graph#OpenRealFile(0)<CR>
  map <buffer> <S-Enter> :call graph#OpenRealFile(1)<CR>
endfunction

function! graph#OpenRealFile(openFrom)
  let lnum = line(".")
  let selectedLnum = lnum
  while lnum > 0
    let line = getline(lnum)
    if line =~# '^diff --git \%(a/.*\|/dev/null\) \%(b/.*\|/dev/null\)'
      let sr = substitute(line, '^diff --git \(a/.*\|/dev/null\) \(b/.*\|/dev/null\)',
          \ 'let fromfile = "\1" | let tofile = "\2"', '')
      if sr != line
        execute sr
        if a:openFrom
          let noprefixfromfile = substitute(fromfile, '^..', '', '')
          if fromfile == "/dev/null"
            echom "file created: no from-file"
          elseif !filereadable(noprefixfromfile)
            echom "file " . noprefixfromfile . ": not exists"
          else
            exe "vsplit " . noprefixfromfile
            exe  "normal " . fromline . "G"
          endif
        else
          let noprefixtofile = substitute(tofile, '^..', '', '')
          if tofile == "/dev/null"
            echom "file deleted: no to-file"
          elseif !filereadable(noprefixtofile)
            echom "file " . noprefixtofile . ": not exists"
          else
            exe "vsplit " . noprefixtofile
            exe "normal " . toline . "G"
          endif
        endif
        break
      endif
    elseif line =~# '^@@ -\d\+,\d\+ +\d\+,\d\+'
      let sr = substitute(line, '^@@ -\(\d\+\),\(\d\+\) +\(\d\+\),\(\d\+\).*',
                \ 'let fromline = \1 | let fromcol = \2 | let toline = \3 | let tocol = \4', '')
      if line != sr
         echo sr
        exe sr
        let offsetline = selectedLnum - lnum - 1
        let fromline += offsetline
        let toline += offsetline
      endif
    endif
    let lnum -= 1
  endwhile
endfunction

