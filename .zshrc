export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin
export PATH=$HOME/.local/share/aquaproj-aqua/bin:$PATH

# zplugが無いときはgit cloneしてくる
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# 文字コードの指定
export LANG=ja_JP.UTF-8
# コマンド履歴のメモリ保存数
export HISTSIZE=1000
# 履歴から重複削除
setopt hist_ignore_dups
# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# *とか?とか[]をグロブ展開しないようにする
setopt nonomatch
# ビープ音をオフ
setopt no_beep

# 自動補完を有効にする
autoload -U compinit
compinit

# デフォルトエディタの設定
export EDITOR='vim'
# Emacs風のキーバインド(Ctrl-A, Ctrl-E, Ctrl-Pなど)
bindkey -e

# Claude Codeの設定
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID="dmm-search-admin"

# zsh のコマンドラインに色付けをするやつ
# compinit 以降に読み込むようにロードの優先度を変更する（10~19にすれば良い）
zplug "zsh-users/zsh-syntax-highlighting"
# 移動系強化プラグイン
zplug "b4b4r07/enhancd", use:init.sh
# インタラクティブフィルタ
# fzf-bin にホスティングされているので注意
# またファイル名が fzf-bin となっているので file:fzf としてリネームする
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
# tmux 用の拡張
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
# catの便利ツール
zplug "sharkdp/bat", as:command, from:gh-r, rename-to:bat
alias cat='bat'

# fzfでhistory search
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history
# fzfのレイアウト
export FZF_DEFAULT_OPTS='--height 60% --border'

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

zstyle ':completion:*default' menu select=2
# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 名前で色を付けるようにする
autoload colors
colors

# gitでmasterとmainをよしなに変換する
git() {
  # 引数がなければ通常のgitコマンドを実行
  if [[ $# -eq 0 ]]; then
    command git
    return
  fi

  # 引数の中にmainかmasterが含まれているかチェック
  local args=("$@")
  local found_branch=false

  local has_main=$(command git rev-parse --verify main >/dev/null 2>&1 && echo true || echo false)
  local has_master=$(command git rev-parse --verify master >/dev/null 2>&1 && echo true || echo false)

  for i in {1..$#args}; do
    if [[ "${args[$i]}" == "main" && "$has_main" != "true" && "$has_master" == "true" ]]; then
      args[$i]="master"
      found_branch=true
    elif [[ "${args[$i]}" == "master" && "$has_master" != "true" && "has_main" == "true" ]]; then
      args[$i]="main"
      found_branch=true
    fi
  done

  command git "${args[@]}"
}

# デフォルトブランチに一発で戻るエイリアス
alias gcd='git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")'

# プロンプトの設定
PS1="%F{magenta}[${USER} %F{cyan}%1~%f%F{magenta}]%f%(!.#.$) "
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

# LS_COLORSを設定しておく
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
alias ls='gls -Fh --color'

# nvimコマンドの省略化
alias nvim='~/nvim-macos/bin/nvim'

if ! zplug check --verbose; then
    printf "Intall [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load --verbose

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export CC="/usr/bin/gcc"
export XDG_CONFIG_HOME=~/.config

eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/koyama-ryota/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/koyama-ryota/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/koyama-ryota/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/koyama-ryota/google-cloud-sdk/completion.zsh.inc'; fi
