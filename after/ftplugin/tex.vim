" =============================================================================
" File: ftplugin/tex.vim
" Description: Provide foldexpr and foldtext for TeX files
" Author: Matthias Vogelgesang <github.com/matze>
"
" =============================================================================

"{{{ Globals

if !exists('g:tex_fold_sec_char')
    let g:tex_fold_sec_char = '➜'
endif

if !exists('g:tex_fold_env_char')
    let g:tex_fold_env_char = '✎'
endif

if !exists('g:tex_fold_override_foldtext')
    let g:tex_fold_override_foldtext = 1
endif

if !exists('g:tex_fold_allow_marker')
    let g:tex_fold_allow_marker = 1
endif

if !exists('g:tex_fold_additional_envs')
    let g:tex_fold_additional_envs = []
endif

if !exists('g:tex_fold_use_default_envs')
    let g:tex_fold_use_default_envs = 1
endif

if !exists('g:tex_fold_ignore_envs')
    let g:tex_fold_ignore_envs = 0
endif

"}}}
"{{{ Fold options

setlocal foldmethod=expr
setlocal foldexpr=TeXFold(v:lnum)

if g:tex_fold_override_foldtext
    setlocal foldtext=TeXFoldText()
endif

"}}}
"{{{ Functions

function! TeXFold(lnum)
    let line = getline(a:lnum)
    let default_envs = g:tex_fold_use_default_envs?
        \['frame', 'table', 'figure', 'align', 'lstlisting']: []
    let envs = '\(' . join(default_envs + g:tex_fold_additional_envs, '\|') . '\)'

    if line =~ '^\s*\\section'
        return '>1'
    endif

    if line =~ '^\s*\\subsection'
        return '>2'
    endif

    if line =~ '^\s*\\subsubsection'
        return '>3'
    endif

    if !g:tex_fold_ignore_envs
        if line =~ '^\s*\\begin{' . envs
            return 'a1'
        endif

        if line =~ '^\s*\\end{' . envs
            return 's1'
        endif
    endif

    if g:tex_fold_allow_marker
        if line =~ '^[^%]*%[^{]*{{{'
            return 'a1'
        endif

        if line =~ '^[^%]*%[^}]*}}}'
            return 's1'
        endif
    endif

    return '='
endfunction

function! TeXFoldText() 

	let s:middot='·'
	let s:raquo='»'
	let s:small_l='ℓ'
    let fold_line = getline(v:foldstart)

    if fold_line =~ '^\s*\\\(sub\)*section'
        let pattern = '\\\(sub\)*section\*\={\([^}]*\)}'
        let repl = '' . g:tex_fold_sec_char . ' \2'
    elseif fold_line =~ '^\s*\\begin'
        let pattern = '\\begin{\([^}]*\)}'
        let repl = '' . g:tex_fold_env_char . ' \1'
    elseif fold_line =~ '^[^%]*%[^{]*{{{'
        let pattern = '^[^{]*{' . '{{\([.]*\)'
        let repl = '\1'
    endif
    let line = strpart(substitute(fold_line, pattern, repl, '') . ' ', 0, 48)

	let lines_count = v:foldend - v:foldstart + 1
	let lines_count_text = '[' . printf("%4s", lines_count . s:small_l) . ']'
	let foldtextend = lines_count_text . repeat(" ", 8)
	let foldtextstart = strpart(s:raquo . repeat(" ", v:foldlevel*2) . line , 0, (60*2)/3)
	let foldtextlength = strlen(substitute(line . foldtextend, '.', 'x', 'g')) + &foldcolumn

	return foldtextstart . repeat(s:middot, 60-foldtextlength) . foldtextend . repeat(" ", 1000)

endfunction


"}}}
"{{{ Undo

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext<"
else
  let b:undo_ftplugin = "setl foldexpr< foldmethod< foldtext<"
endif
"}}}
