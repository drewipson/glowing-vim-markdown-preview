" ========== Simple Markdown Preview Plugin ==========

function! ToggleMarkdownPreview()
  " Check if preview window exists
  for winnr in range(1, winnr('$'))
    if getwinvar(winnr, 'is_markdown_preview', 0)
      " Found preview window, close it and return to source
      let l:source_winnr = getwinvar(winnr, 'source_winnr', 0)
      execute winnr . 'wincmd w'
      
      " Force close the window and its buffer
      quit!
      
      " Return to source window if it exists
      if l:source_winnr > 0 && l:source_winnr <= winnr('$')
        execute l:source_winnr . 'wincmd w'
      endif
      return
    endif
  endfor
  
  " No preview found, create one
  let l:source_winnr = winnr()
  let l:width = float2nr(&columns * 0.4)
  
  if executable('glow') && has('terminal')
    " Create terminal directly with glow
    let l:temp_file = tempname() . '.md'
    let l:content = getline(1, '$')
    call writefile(l:content, l:temp_file)
    
    execute 'rightbelow vertical terminal glow -s dark -w ' . (l:width - 4) . ' ' . l:temp_file
    execute 'vertical resize ' . l:width
    
    " Clean up temp file after delay
    call timer_start(2000, {-> delete(l:temp_file)})
  else
    " Basic fallback - create buffer with content directly
    execute 'rightbelow vnew'
    execute 'vertical resize ' . l:width
    
    setlocal buftype=nofile noswapfile nobuflisted
    let l:content = getbufline('#', 1, '$')
    call setline(1, l:content)
    setlocal ft=markdown readonly nomodifiable
  endif
  
  " Mark this window as preview and store source
  let w:is_markdown_preview = 1
  let w:source_winnr = l:source_winnr
  
  " Simple quit mapping - just close window and return to source
  nnoremap <buffer> q :call ToggleMarkdownPreview()<CR>
  if has('terminal') && &buftype == 'terminal'
    tnoremap <buffer> q <C-\><C-n>:call ToggleMarkdownPreview()<CR>
  endif
endfunction

" Command and mapping
command! MarkdownPreviewToggle call ToggleMarkdownPreview()
nnoremap \m :MarkdownPreviewToggle<CR>