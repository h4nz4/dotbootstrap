export EDITOR=nvim
export VISUAL=nvim
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# useful zsh aliases
alias cls='clear'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias f='fd'
alias rg='rg --smart-case'
alias btop='btop --utf-force'
alias nv='nvim'
alias v='nvim'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

eval "$(zoxide init zsh)"
