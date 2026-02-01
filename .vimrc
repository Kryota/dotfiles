" --------------------------------------------------------
" 文字コードの設定
" --------------------------------------------------------

set encoding=utf-8 " ファイル読み込み時の文字コードの設定
scriptencoding utf-8 " vim script内でマルチバイト文字を使う場合の設定
set fileencoding=utf-8 " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別 " 左側が優先
set fileformats=unix,dos,mac " 改行コードの自動判別 " 左側が優先
set ambiwidth=double " □や○文字が崩れる問題を解決

" --------------------------------------------------------
" タブ・インデント
" --------------------------------------------------------

set expandtab " タブ入力を複数の空白入力に置き換える
set tabstop=4 " 画面上でタブ文字が占める幅
set softtabstop=4 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックして次の行のインデントを増減させる
set shiftwidth=4 " smartindentで増減する幅

" --------------------------------------------------------
" ファイル形式の検出を有効化
" --------------------------------------------------------

filetype on

autocmd BufNewFile,BufRead *.conf setfiletype conf

" --------------------------------------------------------
" ファイル形式によってインデント幅を変える
" --------------------------------------------------------

augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.rb setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.erb setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.yml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.scss setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" --------------------------------------------------------
"  テンプレート設定
" --------------------------------------------------------

autocmd BufNewFile *.py 0r $HOME/.vim/template/python_temp.txt
autocmd BufNewFile *.html 0r $HOME/.vim/template/html_temp.txt

" --------------------------------------------------------
" 文字列検索
" --------------------------------------------------------

set incsearch " インクリメンタルサーチ " 1文字入力する毎に検索
set ignorecase " 検索パターンに大文字・小文字を区別しない
set smartcase " 検索パターンに大文字を含んでいれば大文字・小文字を区別する
set hlsearch " 検索結果をハイライト

" --------------------------------------------------------
" カーソル
" --------------------------------------------------------

set whichwrap=b,s,h,l,<,>,[,],~ " カーソルの左右移動で行末から次の行の行頭への移動が可能
set number " 行番号を表示
set cursorline " カーソルラインをハイライト

" 行番号の色を指定
autocmd ColorScheme * highlight LineNr ctermfg=239

" 行が折り返し表示されていた場合、行単位ではなく表示単位でカーソル移動
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk

" バックスペースキーの有効化
set backspace=indent,eol,start

" --------------------------------------------------------
"  背景色
" --------------------------------------------------------
" autocmd ColorScheme * highlight Normal ctermbg=none
" autocmd ColorScheme * highlight NonText ctermbg=none
" autocmd ColorScheme * highlight CursorLine cterm=underline ctermfg=none ctermbg=none
" autocmd ColorScheme * highlight Pmenu ctermbg=none
" autocmd ColorScheme * highlight PmenuSel ctermbg=gray

" --------------------------------------------------------
" カッコ・タグジャンプ
" --------------------------------------------------------

set showmatch " カッコの対応関係を一瞬表示
source $VIMRUNTIME/macros/matchit.vim " vimの%を拡張

" --------------------------------------------------------
" コマンド補完
" --------------------------------------------------------

set wildmenu " コマンドモードの補完
set history=5000 " 保存するコマンド履歴の数

" --------------------------------------------------------
" マウスの有効化
" --------------------------------------------------------

" if has('mouse')
"     set mouse=a
"     if has('mouse_sgr')
"         set ttymouse=sgr
"     elseif v:version > 703 || v:version is 703 && has('patch632')
"         set ttymouse=sgr
"     else
"         set ttymouse=xterm2
"     endif
" endif

set mouse=a
set ttymouse=xterm2

" --------------------------------------------------------
" クリップボード共有設定
" --------------------------------------------------------

set clipboard+=unnamed,autoselect

" --------------------------------------------------------
" ペースト設定
" --------------------------------------------------------

if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function! XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    noremap <special><expr><Esc>[200~ XTermPasteBegin("0i")
    inoremap <special><expr><Esc>[200~ XTermPasteBegin("")
    cnoremap <special><expr><Esc>[200~ <nop>
    cnoremap <special><expr><Esc>[201~ <nop>
endif

" --------------------------------------------------------
" JSONのダブルクォーテーション設定
" --------------------------------------------------------

set conceallevel=0
let g:vim_json_syntax_conceal = 0

" --------------------------------------------------------
"  deinの設定
" --------------------------------------------------------

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " プラグインリストを収めたTOMLファイル
  " 予めTOMLファイルを用意しておく
  let g:rc_dir    = expand('~/.vim/rc')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " deinのpluginのupdate設定
  let g:dein#install_github_api_token = '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'
  call dein#check_update(v:true)

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

filetype plugin indent on

" 以下deinで導入したプラグインの設定

"----------------------------------------------------------
" jellybeansの設定
"----------------------------------------------------------

syntax enable
colorscheme jellybeans
set t_Co=256

"----------------------------------------------------------
" ステータスラインの設定
"----------------------------------------------------------

set laststatus=2 " ステータスラインを常に表示
set showmode " 現在のモードを表示
set showcmd " 打ったコマンドをステータスラインの下に表示
set ruler " ステータスラインの右側にカーソルの現在位置を表示する

"----------------------------------------------------------
" cron使用時にtmpディレクトリでバックアップを行わない
"----------------------------------------------------------
set backupskip=/tmp/*,/private/tmp/*

"----------------------------------------------------------
" Beep音の削除
"----------------------------------------------------------
set belloff=all

"----------------------------------------------------------
" neocomplete・neosnippetの設定
"----------------------------------------------------------

" Vim起動時にneocompleteを有効にする
let g:neocomplete#enable_at_startup = 1
" smartcase有効化. 大文字が入力されるまで大文字小文字の区別を無視する
let g:neocomplete#enable_smart_case = 1
" 3文字以上の単語に対して補完を有効にする
let g:neocomplete#min_keyword_length = 3
" 区切り文字まで補完する
let g:neocomplete#enable_auto_delimiter = 1
" 1文字目の入力から補完のポップアップを表示
let g:neocomplete#auto_completion_start_length = 1
" バックスペースで補完のポップアップを閉じる
inoremap <expr><BS> neocomplete#smart_close_popup()."<C-h>"

" エンターキーで補完候補の確定. スニペットの展開もエンターキーで確定・・・・・・②
imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
" タブキーで補完候補の選択. スニペット内のジャンプもタブキーでジャンプ・・・・・・③
imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"

"----------------------------------------------------------
" CtrlPの設定
"----------------------------------------------------------

" let g:ctrlp_match_window = 'order:ttb,min:20,max:20,results:100' " マッチウインドウの設定. 「下部に表示, 大きさ20行で固定, 検索結果100件」
" let g:ctrlp_show_hidden = 1 " .(ドット)から始まるファイルも検索対象にする
" let g:ctrlp_types = ['fil'] "ファイル検索のみ使用
" let g:ctrlp_extensions = ['funky', 'commandline'] " CtrlPの拡張として「funky」と「commandline」を使用
"
" " CtrlPCommandLineの有効化
" command! CtrlPCommandLine call ctrlp#init(ctrlp#commandline#id())
"
" " CtrlPFunkyの有効化
" let g:ctrlp_funky_matchtype = 'path'

"----------------------------------------------------------
" ag.vimの設定
"----------------------------------------------------------

" if executable('ag') " agが使える環境の場合
"   let g:ctrlp_use_caching=0 " CtrlPのキャッシュを使わない
"   let g:ctrlp_user_command='ag %s -i --hidden -g ""' " 「ag」の検索設定
" endif

"----------------------------------------------------------
" vim-indent-guidesの設定
"----------------------------------------------------------

"set tabstop=4 shiftwidth=4 expandtab
"let mapleader = ","
let g:indent_guides_enable_on_vim_startup = 1
"let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2

"----------------------------------------------------------
" tcommentの設定(今後やるかも)
"----------------------------------------------------------
if !exists('g:tcomment_types')
    let g:tcomment_types = {}
endif
let g:tcomment_types['conf'] = '# %s'
"----------------------------------------------------------
" vim-terraformの設定
"----------------------------------------------------------
let g:terraform_fmt_on_save=1 " 保存時に自動フォーマット

"----------------------------------------------------------
" fzfの設定
" ---------------------------------------------------------

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

"----------------------------------------------------------
" vim-jsonの設定
"----------------------------------------------------------
let g:vim_json_syntax_conceal = 0 " jsonのシンタックスを上書きして無効化
