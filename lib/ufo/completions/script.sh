_ufo() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    local completions=$(ufo completions)
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    # echo "\${words[@]} ${words[@]}" >> /tmp/a.log
    # echo "COMP_CWORD $COMP_CWORD" >> /tmp/a.log
    local completions=$(ufo completions ${words[@]})
    # echo "completions ${completions[@]}" >> /tmp/a.log
    # echo "" >> /tmp/a.log
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _ufo ufo
