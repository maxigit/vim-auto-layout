" Computes the layout key depending on the number and type of windows
" example one window : b
" example one window + quick : bq
" 2 windows + preview : bp

function LayoutKey()
  let windows = getwininfo()
  let keys = []
  for w in windows
    if w.loclist 
       call insert(keys, "l")
    elseif w.quickfix
      call insert(keys,"q")
    elseif w.terminal
      call insert(keys, "t")
    else
      call insert(keys, "b")
    endif
  endfor
  return join (sort(keys), '')
endfunction

function s:windowFormat()
  if b:mode != 'A'
    return b:mode
  endif
  if &columns > &lines*2.5
    return "L" " landscape
  else
    return "P"
  endif
endfunction

" Apply the command corresponding to the rules 
" matching the layout
"
function ApplyLayoutRules(rules)
  let layoutKey = s:windowFormat() . LayoutKey() 
  let currentWindow = winnr()
  echo layoutKey
  for rule in a:rules
    echo rule
    if (layoutKey =~ rule.regex)
      echo "Matched" rule
      execute rule.command
      "if rule.break
      "  break
      "endif
    endif
  endfor

  exe currentWindow . "wincmd w"
endfunction

let b:mode = 'A'

function s:setMode(mode)
  let b:mode = a:mode
  ApplyLayoutRules
endfunction

command Portrait :call s:setMode('P')
command Landscape  :call s:setMode('L')
command AutoLayout  :call s:setMode('A')
command NoLayout  :call s:setMode('X')

" generate a sucessesion of :wincmd
" from a string
function FromWinCmds(s)
  let cmds = []
  for c in str2list(a:s)
    call add(cmds, "wincmd " . nr2char(c))
  endfor
  return  join(cmds,  " | ")
endfunction
let s:portrait2 = FromWinCmds('=tK')
let s:landscape2 = FromWinCmds('=tH')
let s:myrules = [ {'regex': "P..", 'command':s:portrait2 } 
               \,{'regex': "L..", 'command':s:landscape2 }
               \]

command ApplyLayoutRules :call ApplyLayoutRules(s:myrules)
nnoremap <C-W>z :ApplyLayoutRules<CR>

au VimResized * ApplyLayoutRules
au WinNew * ApplyLayoutRules
