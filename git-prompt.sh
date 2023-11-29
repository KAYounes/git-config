# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)

  # Extract only the branch name
  GIT_LOCATION=$(basename "$GIT_LOCATION")

  local AHEAD="AHEAD"
  local BEHIND="BEHIND"
  local MERGING="MERGING"
  local UNTRACKED="UNTRACKED"
  local MODIFIED="MODIFIED"
  local STAGED="STAGED"

  local DIVERGENCES=""
  local FLAGS=""

  local NUM_AHEAD=$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=" ${AHEAD//NUM/$NUM_AHEAD}"
  fi

  local NUM_BEHIND=$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=" ${BEHIND//NUM/$NUM_BEHIND}"
  fi

  local GIT_DIR=$(git rev-parse --git-dir 2> /dev/null)
  if [ -n "$GIT_DIR" ] && test -r "$GIT_DIR/MERGE_HEAD"; then
    FLAGS+=" $MERGING"
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=" $UNTRACKED"
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=" $MODIFIED"
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=" $STAGED"
  fi

  echo "${GIT_LOCATION}${DIVERGENCES}${FLAGS}" #±

}

# Use ❯ as the non-root prompt character; # for root
# Change the prompt character if the last command had a nonzero exit code
PS1='$(git_info) '
