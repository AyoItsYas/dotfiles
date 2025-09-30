# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# if not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P' # configure `time` format
PROMPT_EOL_MARK=""                                # hide EOL sign ('%')
WORDCHARS=${WORDCHARS//\//}                       # Don't consider certain characters part of the word

# shell theme
eval "$(oh-my-posh init zsh --config "$HOME/.posh-theme.omp.json")" # enable completion features

# set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/"

# make the dir if it doesn't exist
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
fi

# source/Load zinit
source /usr/share/zinit/zinit.zsh

# add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# keybindings
bindkey -e # emacs key bindings
bindkey "^ " autosuggest-accept
bindkey ' ' magic-space                        # do history expansion on space
bindkey '^U' backward-kill-line                # ctrl + U
bindkey '^[[3;5~' kill-word                    # ctrl + Supr
bindkey '^[[3~' delete-char                    # delete
bindkey '^[[1;5C' forward-word                 # ctrl + ->
bindkey '^[[1;5D' backward-word                # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history # page up
bindkey '^[[6~' end-of-buffer-or-history       # page down
bindkey '^[[H' beginning-of-line               # home
bindkey '^[[F' end-of-line                     # end
bindkey '^[[Z' undo                            # shift + tab undo last action
bindkey '^h' backward-kill-word                # ctrl + backspace to delete word

# history
HISTSIZE=999999999999999
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# history options
setopt APPEND_HISTORY
setopt sharehistory
setopt hist_ignore_space
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt HIST_IGNORE_SPACE

# other options
setopt noclobber           # prevent overwriting files with >
setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# completion styling
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# aliases

alias h='history'
alias j='jobs -l'
alias c='clear'
alias f='fastfetch'
alias z='cd'

alias _ls='ls'
alias l='ls -CF'      # list all files in columns
alias ls='ls --color' # list all files with color
alias la='ls -A'      # list all files including hidden files
alias ll='ls -alF'    # list all files with details

alias rm='rmtrash'
alias rmdir='rmdirtrash'

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

alias mkdir='mkdir -pv'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias grep='rg'
alias find='fd'

alias _vim='vim'
alias vim='nano'

alias _yay ='yay'
alias yay="nice -n 19 ionice -c3 yay"

alias copy-pwd="pwd | wl-copy"
alias please='sudo $(fc -ln -1)'

_check_root() {
  local file="$1"
  if [ -e "$file" ] && [ ! -w "$file" ]; then
    echo "admin:$file"
  else
    echo "$file"
  fi
}

gnano() {
  local files=()
  for f in "$@"; do
    if [[ "$f" == -* ]]; then
      files+=("$f")
    else
      files+=($(_check_root "$f"))
    fi
  done

  if ! pgrep -x gnome-text-editor 2> /dev/null; then
    gnome-text-editor 2> /dev/null &
    sleep 1
  fi

  gnome-text-editor "${files[@]}" 2> /dev/null
}

meld-merge() {
  local file="$1"
  local pacnew="$file.pacnew"

  if [ ! -e "$file" ] && [ ! -e "$pacnew" ]; then
    echo "Either $file or $pacnew doesn't exist."
    return 1
  fi

  local left=$(_check_root "$file")
  local right=$(_check_root "$pacnew")

  meld "$left" "$right"

  # Ask user via GUI if they want to delete the .pacnew file with privilege escalation
  if [ -e "$pacnew" ]; then
    if zenity --question --title="Delete .pacnew file?" --text="Do you want to delete $pacnew?" 2> /dev/null; then
      pkexec rm -f "$pacnew"
      zenity --info --text="$pacnew deleted." 2> /dev/null
    else
      zenity --info --text="$pacnew not deleted." 2> /dev/null
    fi
  fi
}

zpath() {
  fd -a --ignore-case --type f --hidden --follow --base-directory $(pwd) -d 10 -j 8 "$1" 2> /dev/null | fzf -e
}

zfz() {
  local dir
  dir=$(zoxide query -l | fzf) || return
  cd "$dir" || return
}

# custom keybindings

_insert_pair() {
  local left="$1"
  local right="$2"

  LBUFFER+="$left"
  RBUFFER="$right$RBUFFER"
  zle redisplay
}

zle -N _insert_pair

complete_dollar_parens() {
  _insert_pair '$(zpath ' ')'
}
zle -N complete_dollar_parens
bindkey '(' complete_dollar_parens

complete_double_quotes() {
  _insert_pair '"' '"'
}
zle -N complete_double_quotes
bindkey '"' complete_double_quotes

complete_single_quotes() {
  _insert_pair "'" "'"
}
zle -N complete_single_quotes
bindkey "'" complete_single_quotes

complete_curly_brackets() {
  _insert_pair '{' '}'
}
zle -N complete_curly_brackets
bindkey '{' complete_curly_brackets

complete_right_carrot() {
  _insert_pair '' ' 2> /dev/null &'
}
zle -N complete_right_carrot
bindkey '>' complete_right_carrot

complete_pipe() {
  _insert_pair ' | ' ''
}
zle -N complete_pipe
bindkey '|' complete_pipe

# shell integrations

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# dart shell completions
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true

# variables
export VISUAL="gnome-text-editor -s"
export EDITOR=nano
export GPG_TTY=$(tty)
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

export LIBCLANG_PATH="$HOME/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-18.1.2_20240912/esp-clang/lib"

# path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/toggle-scripts:$PATH"
export PATH="$HOME/.local/bin/batch-file-operations:$PATH"

export PATH="$PATH:$HOME/Development/Go/bin"

#esp32 rust toolchain
export PATH="$HOME/.rustup/toolchains/esp/xtensa-esp-elf/esp-14.2.0_20240906/xtensa-esp-elf/bin:$PATH"

source /usr/share/doc/find-the-command/ftc.zsh noupdate quiet
