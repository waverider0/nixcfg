export CLICOLOR=1
export PS1=$'%n@%m:%{\e[01;32m%}%~%{\e[0m%}$ '

alias vi='nvim'
alias vim='nvim'
export MANPAGER='nvim +Man!'
set -o vi

fcd() {
  local dir
  dir=$(find . -type d 2> /dev/null | fzf) && cd "$dir"
  zle reset-prompt
}
zle -N fcd
bindkey '^F' fcd

fvi() {
  local file
  file=$(find . -type f 2> /dev/null | fzf) && vi "$file"
  zle reset-prompt
}
zle -N fvi
bindkey '^T' fvi

eval "$(direnv hook zsh)"
