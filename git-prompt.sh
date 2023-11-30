# black_bold='\[\e[01;30m\]'
# red_bold='\[\e[01;31m\]'
# green_bold='\[\e[01;32m\]'
# yellow_bold='\[\e[01;33m\]'
# blue_bold='\[\e[01;34m\]'
# purple_bold='\[\e[01;35m\]'
# cyan_bold='\[\e[01;36m\]'
# white_bold='\[\e[01;37m\]'

NO_FORMAT="\e[0m"
F_BOLD="\e[1m"
F_DIM="\e[2m"
F_ITALIC="\e[3m"
F_UNDERLINED="\e[4m"
F_BLINK="\e[5m"
# F_BLINK="\e[6m" # also blink
F_INVERT="\e[7m"
F_HIDDEN="\e[8m"

blackBG='\e[40m'
redBG='\e[41m'
greenBG='\e[42m'
yellowBG='\e[43m'
blueBG='\e[44m'
purpleBG='\e[45m'
cyanBG='\e[46m'
whiteBG='\e[47m'
CB_GREEN4="\e[48;5;28m"
CB_GREENYELLOW="\e[48;5;154m"
CB_LIGHTSTEELBLUE="\e[48;5;147m"
CB_MAROON="\e[48;5;1m"
CB_ORANGERED1="\e[48;5;202m"
CB_ROYALBLUE1="\e[48;5;63m"
CB_SANDYBROWN="\e[48;5;215m"
CB_VIOLET="\e[48;5;177m"

black='\e[30m'
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
purple='\e[35m'
cyan='\e[36m'
white='\e[37m'
# orange="\e[38;5;202m"

C_DODGERBLUE1="\[\e[38;5;33m\]"
C_DODGERBLUE2="\[\e[38;5;27m\]"
C_GREEN4="\[\e[38;5;28m\]"
C_GREENYELLOW="\[\e[38;5;154m\]"
C_GREY54="\e[38;5;245m"
C_GREY62="\e[38;5;247m"
C_LIGHTSTEELBLUE="\[\e[38;5;147m\]"
C_MAROON="\e[38;5;1m"
C_ORANGERED1="\e[38;5;202m"
C_PURPLE4="\[\e[38;5;54m\]"
C_ROYALBLUE1="\[\e[38;5;63m\]"
C_SANDYBROWN="\e[38;5;215m"
C_VIOLET="\[\e[38;5;177m\]"

clear='\[\e[00m\]'

I_AHEAD=""
I_BEHIND=""
I_BRANCH=""
I_CALENDAR="󰸗" #nf-md-calendar_month
I_CONFLICT="󱓌"
I_DIRECTORY="" #nf-oct-file_directory_open_fill
I_GIT=""       #nf-fa-git
I_PLAY_ARROW=""
I_SEMICIRCLE_END=
I_SEMICIRCLE_START=
I_STAGED=""
I_UNSTAGED="󰚰"
# I_UNTRACKED="" # x
I_UNTRACKED="󰛑"

SEP="${C_GREY54}•"

###
day=$(date +"%d")
suffix_arr=("st" "nd" "rd")
if (((day >= 4 && day <= 20) || (day >= 24 && day <= 30))); then
	suffix="th"
else
	suffix_arr=("st" "nd" "rd")
	suffix=${suffix_arr[day % 10 - 1]}
fi
##################
git_info() {

	# Exit if not inside a Git repository
	! git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo "" && return

	# Git branch/tag, or name-rev if on detached head
	local GIT_LOCATION=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)
	local GIT_CHANGES=$(git status --short | wc -l)

	# Extract only the branch name
	#   GIT_LOCATION=$(basename "$GIT_LOCATION")
	if [ -z "$(git symbolic-ref -q HEAD)" ]; then
		GIT_LOCATION="(detach HEAD)${GIT_LOCATION}"
	else
		# Extract only the branch name
		GIT_LOCATION=$(basename "$GIT_LOCATION")
	fi

	local AHEAD="${green}${I_AHEAD} NUM"
	local BEHIND="${red}${I_BEHIND} NUM"
	local MERGING="${yellow}${I_CONFLICT}"
	local UNTRACKED=""
	local MODIFIED=""
	local STAGED=""
	# local UNTRACKED="${red}${I_UNTRACKED}"
	# local MODIFIED="${yellow}${I_UNSTAGED}"
	# local STAGED="${green}${I_STAGED}"

	# local DIVERGENCES=""

	local DIVERGENCES=""
	local FLAGS=""

	local NUM_AHEAD=$(git log --oneline @{u}.. 2>/dev/null | wc -l | tr -d ' ')
	if [ "$NUM_AHEAD" -gt 0 ]; then
		DIVERGENCES+=" ${AHEAD//NUM/$NUM_AHEAD}"
	fi

	local NUM_BEHIND=$(git log --oneline ..@{u} 2>/dev/null | wc -l | tr -d ' ')
	if [ "$NUM_BEHIND" -gt 0 ]; then
		if [ "$NUM_AHEAD" -gt 0 ]; then
			DIVERGENCES+=" ${SEP} "
		fi
		DIVERGENCES+="${BEHIND//NUM/$NUM_BEHIND}"
	fi

	local GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
	if [ -n "$GIT_DIR" ] && test -r "$GIT_DIR/MERGE_HEAD"; then
		if [ "$NUM_BEHIND" -gt 0 ]; then
			DIVERGENCES+=" ${SEP} "
		fi
		DIVERGENCES+="$MERGING"
	fi

	if [[ -n $(git ls-files --other --exclude-standard 2>/dev/null) ]]; then
		# FLAGS+=" $UNTRACKED"
		UNTRACKED="${red}${I_UNTRACKED}"
		FLAGS+="$UNTRACKED"
	fi

	if ! git diff --quiet 2>/dev/null; then
		# FLAGS+="$MODIFIED"
		if [ "$UNTRACKED" != "" ]; then
			FLAGS+=" $SEP "
		fi
		MODIFIED="${yellow}${I_UNSTAGED}"
		FLAGS+="$MODIFIED"
	fi

	if ! git diff --cached --quiet 2>/dev/null; then
		# FLAGS+="$STAGED"
		if [ "$MODIFIED" != "" ] || [ "$UNTRACKED" != "" ]; then
			FLAGS+=" $SEP "
		fi
		STAGED="${green}${I_STAGED}"
		FLAGS+="$STAGED"
	fi

	if [ "$GIT_CHANGES" -gt 0 ]; then
		GIT_CHANGES="${NO_FORMAT}${black}${F_ITALIC}${F_UNDERLINED}Changes $GIT_CHANGES${NO_FORMAT} ${black}${F_ITALIC}[${F_DIM}${FLAGS}${NO_FORMAT}${black}${F_ITALIC}${F_UNDERLINE}]"
	else
		GIT_CHANGES=''
	fi

	# local GAP="${NO_FORMAT}${F_DIM}${C_GREY62} -- "
	local GAP=" "
	if [ "$DIVERGENCES" == "" ]; then
		GAP=''
	fi

	GIT_TAG="${NO_FORMAT}${purple}${I_GIT} [${I_BRANCH} ${GIT_LOCATION}${GAP}${F_DIM}${DIVERGENCES}${NO_FORMAT}${purple}] ${GIT_CHANGES}"
	echo -e "${GIT_TAG}"

}

###################
PS1="$NO_FORMAT\n"
PS1="$PS1$NO_FORMAT$blue$F_ITALIC$F_DIM$I_CALENDAR \d$suffix${NO_FORMAT}${black} -- "
PS1="$PS1$green$I_DIRECTORY"' \[$(pwd | sed -E -e "s|^'"$HOME"'|~|" -e "s|^.*/([^/]*)/([^/]*)/.*(/[^/]*/[^/]*)|\1/\2/....\3|")\] '

PS1="$PS1\012"

if test -z "$WINELOADERNOEXEC"; then
	GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
	COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
	COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
	COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
	if test -f "$COMPLETION_PATH/git-prompt.sh"; then
		. "$COMPLETION_PATH/git-completion.bash"
		. "$COMPLETION_PATH/git-prompt.sh"
		PS1="$PS1"'$(git_info)'
	fi
fi

PS1="$PS1$NO_FORMAT$C_DODGERBLUE1\012\$\[$NO_FORMAT\] "

#######################
MSYS2_PS1="$PS1" # for detection by MSYS2 SDK's bash.basrc

# Evaluate all user-specific Bash completion scripts (if any)
if test -z "$WINELOADERNOEXEC"; then
	for c in "$HOME"/bash_completion.d/*.bash; do
		# Handle absence of any scripts (or the folder) gracefully
		test ! -f "$c" ||
			. "$c"
	done
fi
