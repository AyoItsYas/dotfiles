# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# if not running interactively, don't do anything

case $- in
*i*) ;;
*) return ;;
esac

# set a fancy prompt (non-color, unless we know we "want" color)

case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)

        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# if this is an xterm set the title to user@host:dir

case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto --hyperlink'
    alias dir='dir --color=auto --hyperlink'
    alias vdir='vdir --color=auto --hyperlink'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# options

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# variables

export PATH="/home/$USER/bin:/home/$USER/.local/bin:$PATH"
export PYTHONSTARTUP="$HOME/.pythonrc" # python startup file

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P' # configure `time` format
PROMPT_EOL_MARK=""                                # hide EOL sign ('%')
WORDCHARS=${WORDCHARS//\//}                       # Don't consider certain characters part of the word

# aliases

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias history="history 0"
alias apt="apt-fast"
alias apt-get="apt-fast"
alias cpilot="gh copilot"

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# history configuration

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory          # append history to the history file
setopt histignorealldups      # ignore duplicate commands history list
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_find_no_dups      # do not display a duplicate command
setopt hist_save_no_dups      # do not write a duplicate command to the history file
setopt hist_ignore_all_dups   # delete old recorded command if new command is a duplicate
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt sharehistory           # share command history data

# auto suggestions

autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*' menu no

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

# utility

if [ -f ./.venv/bin/activate ]; then
    source ./.venv/bin/activate                 # if a python virtual envirnment is found activate it automatically
    activate() { source ./.venv/bin/activate; } # utility command to easily activate the enviornment
fi

source /usr/share/nvm/init-nvm.sh

# export NVM_DIR="/usr/share/nvm"

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# NODE_GLOBALS=($(find $NVM_DIR/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq))
# NODE_GLOBALS+=("node" "pnpm" "yarn" "npm" "bun" "deno" "npx" "pnpx" "yarnx" "dlx" "bunx")

# _load_nvm() {
#     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
#     [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

#     node --version >/dev/null
# }

# for cmd in "${NODE_GLOBALS[@]}"; do
#     eval "function ${cmd}(){ unset -f ${NODE_GLOBALS[*]}; _load_nvm; unset -f _load_nvm; ${cmd} \$@; }"
# done

# unset cmd NODE_GLOBALS

# # pnpm
# export PNPM_HOME="/home/yasiru/.local/share/pnpm"
# case ":$PATH:" in
# *":$PNPM_HOME:"*) ;;
# *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# # pnpm end

# enable command-not-found if installed
# if [ -f /etc/zsh_command_not_found ]; then
#     . /etc/zsh_command_not_found
# fi

# go

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/yasiru/go/bin

# zsh plugins

# source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # !!! must be the last plugin sourced

source /usr/share/doc/find-the-command/ftc.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

copilot_suggestion() {
    BUFFER=$(gh-copilot-zsh-plugin suggest "$BUFFER" $CURSOR)
    CURSOR=${#BUFFER}
}

zle -N copilot_suggestion
bindkey '^A' copilot_suggestion

# eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"                                         # setting up zoxide
eval "$(oh-my-posh init zsh --config $HOME/.posh-theme.omp.json)" # enable completion features

# zinit

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

zinit cdreplay -q
