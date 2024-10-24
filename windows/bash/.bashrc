is_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

parse_git_branch() {
  # check git repo
  if is_git_repo; then
    git rev-parse --abbrev-ref HEAD 2>/dev/null
  fi
}

parse_git_status() {
  # check git repo
  if is_git_repo; then
    local status=''
    local ahead=$(git rev-list --count --left-only @{u}...HEAD 2>/dev/null || echo 0)
    local behind=$(git rev-list --count --right-only @{u}...HEAD 2>/dev/null || echo 0)

    if [ -n "$(git status --porcelain)" ]; then
      status="${status}*"
    fi

    if [ "$ahead" -gt 0 ]; then
      status="${status}↑$ahead"
    fi

    if [ "$behind" -gt 0 ]; then
      status="${status}↓$behind"
    fi

    echo "$status"
  fi
}

get_git_info() {
  local branch=$(parse_git_branch)
  local status=$(parse_git_status)

  if [ -n "$branch" ] || [ -n "$status" ]; then
    echo "$status (${branch})"
  fi
}

shorten_pwd() {
  local fullpath="$PWD"
  
  if [[ "$fullpath" == "$HOME"* ]]; then
    fullpath="~${fullpath#$HOME}"
  fi

  local path_count=$(echo "$fullpath" | awk -F'/' '{print NF-1}')
  
  if [ $path_count -gt 3 ]; then
    if [[ "$fullpath" == ~* ]]; then
      echo "~/.../$(basename $(dirname $(dirname "$fullpath")))/$(basename $(dirname "$fullpath"))/$(basename "$fullpath")"
    else
      echo ".../$(basename $(dirname $(dirname "$fullpath")))/$(basename $(dirname "$fullpath"))/$(basename "$fullpath")"
    fi
  else
    echo "$fullpath"
  fi
}

goto_git_root() {
  if is_git_repo; then
    cd "$(git rev-parse --show-toplevel)"
  fi
}

export PS1='\[\e[35m\]\h \[\e[32m\][\t] \[\e[34m\]$(shorten_pwd) \[\e[31m\]$(get_git_info)\[\e[0m\] \$ '

# alias
alias ls='ls --color=never'
alias ll='ls -la'
alias gs='git status'
alias gc='git commit -m'
alias open='explorer'
alias gtop='goto_git_root'

# history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# completion
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'