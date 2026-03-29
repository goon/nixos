#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ----- Exports 

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export PATH="$HOME/.local/bin:$PATH"
export NH_FLAKE="$HOME/.nixos"

# ----- History 

export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# ----- Aliases 

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias nhs='nh os switch'
alias nht='nh os test'
alias nhc='nh clean all --keep 8'
alias nhu='nh os switch -u'

alias y='yazi'
alias f='fzf'

alias partitions='lsblk -f'

alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias lg='lazygit'

alias v='nvim'
alias nv='nvim'
alias vim='nvim'

alias ls='eza --icons --git'
alias cat='bat'
alias cd='z'

alias rm='rm -i'

alias rqs='pkill quickshell; quickshell & disown'

# ----- Initialises 'fzf' 

[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash

# ----- Bash Completion 

[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

# ----- Cheatsheet

cheat() {
    curl "https://cheat.sh/$1"
}

# ----- Starship 

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init bash)"

# ----- Zoxide 

eval "$(zoxide init bash)"

# ----- Auto Run 

krabby random 1-3 --no-title
