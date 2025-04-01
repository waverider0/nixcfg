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

ctrl_q_action() {
  case $IN_NIX_SHELL in
    pure)
      echo "You are in a PURE Nix shell"
      ;;
    impure)
      echo "You are in an IMPURE Nix shell"
      ;;
    *)
      echo "You are NOT in a Nix shell"
      ;;
  esac
  zle reset-prompt
}
zle -N ctrl_q_action
bindkey '^Q' ctrl_q_action

eval "$(direnv hook zsh)"
