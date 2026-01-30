# enable colors
autoload -Uz colors
colors

# prompt substitution
setopt PROMPT_SUBST

# real_time
real_time() {
  local color="%{$fg_no_bold[cyan]%}"
  local time="[$(date +%H:%M:%S)]"
  local color_reset="%{$reset_color%}"
  echo "${color}${time}${color_reset}"
}

# directory
directory() {
  local color="%{$fg_no_bold[cyan]%}"
  local dir="${PWD/#$HOME/~}"
  local color_reset="%{$reset_color%}"
  echo "${color}[${dir}]${color_reset}"
}

# replace Oh My Zsh git status
git_status() {
  local branch
  if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
    local dirty=""
    if ! git diff --quiet --ignore-submodules --; then
      dirty=" ✖"
    fi
    echo " [%{$fg_no_bold[cyan]%}${branch}${dirty}%{$reset_color%}]"
  fi
}

# command status arrow
update_command_status() {
  local arrow
  if (( $1 == 0 )); then
    arrow="%{$fg_bold[green]%}❱%{$fg_bold[yellow]%}❱%{$fg_bold[green]%}❱"
  else
    arrow="%{$fg_bold[red]%}❱❱❱"
  fi
  COMMAND_STATUS="${arrow}%{$reset_color%}"
}
command_status() { echo "${COMMAND_STATUS}"; }

preexec() { COMMAND_TIME_BEGIN="$(date +%s.%3N)"; }
precmd() {
  local last=$?
  update_command_status $last
}

# build prompt
PROMPT='$(real_time) $(directory)$(git_status)$(command_status) '

