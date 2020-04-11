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
  if &columns > &lines
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
  echo layoutKey
  for rule in a:rules
    echo rule
    if (rule.regex =~ layoutKey)
      echo "Matched" rule
      execute rule.command
      "if rule.break
      "  break
      "endif
    endif
  endfor
endfunction

let s:portrait2 = "echomsg 'portrait'"
let s:landscape2 = "echomsg 'landscape'"
let s:myrules = [ {'regex': "Pbb", 'command':s:portrait2 } , {'regex': "Lbb", 'command':s:landscape2 } ]

command ApplyLayoutRules :call ApplyLayoutRules(s:myrules)
nnoremap <C-W>z :ApplyLayoutRules<CR>

