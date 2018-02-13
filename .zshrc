export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:/usr/sbin

# zplugが無いときはgit cloneしてくる
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh


# 文字コードの指定
export LANG=ja_JP.UTF-8

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# 自動補完を有効にする
autoload -U compinit
compinit

# gitに関するエイリアス（gaなど）を追加する
# oh-my-zshをサービスとしてそこからインストール
# zplug "plugins/git", from:oh-my-zsh

# zshのテーマ
# zplug "yous/lime", as:theme

# zsh のコマンドラインに色付けをするやつ
# compinit 以降に読み込むようにロードの優先度を変更する（10~19にすれば良い）
zplug "zsh-users/zsh-syntax-highlighting"

# zsh のヒストリサーチを便利にするやつ
zplug "zsh-users/zsh-history-substring-search"

# Vim でいう Unite.vim にあたるような存在
# zplug "mollifier/anyframe"

# 簡単に git ルートへ cd するや
# zplug "mollifier/cd-gitroot"

# 移動系強化プラグイン
zplug "b4b4r07/enhancd", use:init.sh

# インタラクティブフィルタ
# fzf-bin にホスティングされているので注意
# またファイル名が fzf-bin となっているので file:fzf としてリネームする
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf

# tmux 用の拡張
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux

# 補完関数の表示を強化する
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 大文字小文字を区別しない

# マッチ種別を別々に表示
zstyle ':completion:*' group-name ''

# セパレータを設定する
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true

# 名前で色を付けるようにする
autoload colors
colors

PS1="%F{magenta}[${USER}@${HOST%%.*}%f %F{cyan}%1~%f%F{magenta}]%f%(!.#.$) "

# ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status

  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}

# プロンプトの右側(RPS1)にメソッドの結果を表示させる
RPS1='`rprompt-git-current-branch`'

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

zstyle ':completion:*default' menu select=2

# LS_COLORSを設定しておく
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

alias ls='gls -Fh --color'

if ! zplug check --verbose; then
    printf "Intall [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load --verbose

export PATH=/usr/local/bin:$PATH # python3用のパス
# export PATH=/usr/local/bin/lib/python/site-packages:$PATH # pip3 install --userで入れたパッケージへのパス
export PATH=/usr/local/bin/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH # ruby用のパス
eval "$(rbenv init - zsh)" # rbenvの初期化

export PYTHONUSERBASE=/usr/local/bin
