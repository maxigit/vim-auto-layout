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
  if s:mode != 'A'
    return s:mode
  endif
  if &columns > 240
    return "X" "XL
  elseif &columns > 150
    return "L" " Large
  elseif &columns > 120
    return "M" " Medium
  else
    return "S" " Small
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
      echo "Matched" layoutKey rule
      execute rule.command
      break
    endif
  endfor

  exe currentWindow . "wincmd w"
endfunction

let s:mode = 'A'

function s:setMode(mode)
  let s:mode = a:mode
  ApplyLayoutRules
endfunction

command XLarge :call s:setMode('X')
command Large  :call s:setMode('L')
command Medium  :call s:setMode('M')
command Small  :call s:setMode('S')
command AutoLayout  :call s:setMode('A')
command NoLayout  :call s:setMode('-')

" generate a sucessesion of :wincmd
" from a string
function FromWinCmds(s)
  let cmds = []
  for i in str2list(a:s)
    let c = nr2char(i)
    if (c <= '1' && c >= '9')
      let cmd = c . "wincmd 2" " switch to windwo n
    elseif c == '<'
      let cmd = 'wincmd H'
    elseif c == '>'
      let cmd = 'wincmd L'
    elseif c == '^'
      let cmd = 'wincmd K'
    elseif c == 'v'
      let cmd = 'wincmd J'
    else
      let  cmd = "wincmd " . c
    endif
    call add(cmds, cmd)
  endfor
  return  join(cmds,  " | ")
endfunction
let s:portrait2 = FromWinCmds('=1^')
let s:landscape2 = FromWinCmds('=1<')
let s:myrules = [ {'regex': "^[SM]..$", 'command':s:portrait2 } 
               \,{'regex': "^...$", 'command':s:landscape2 }
               \,{'regex': "^S...", 'command': FromWinCmds("bJtK") . " | ResizeMax 3 25 10 | wincmd =" }
               \,{'regex': "^M...", 'command': FromWinCmds("=bJtH") . " | ResizeMax 3 25 10 | wincmd =" }
               \,{'regex': "^....", 'command': FromWinCmds("bLtH") }
               \]

command ApplyLayoutRules :call ApplyLayoutRules(s:myrules)
nnoremap <C-W>z :ApplyLayoutRules<CR>

au VimResized * ApplyLayoutRules
au WinNew * ApplyLayoutRules



function ResizeMax(nr, percent, lines)
s echo a:nr a:percent a:lines
  execute a:nr . "resize " . max([a:percent*&lines/100,a:lines])
endfunction
function ResizeMin(nr, percent, lines)
  execute a:nr "resize " min([a:percent*&lines/100,a:lines])
endfunction

command -bar -nargs=+ ResizeMax :call ResizeMax(<f-args>)
command -bar -nargs=+ ResizeMin :call ResizeMin(<f-args>)
