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
# orangeBG="\e[48;5;202m"
CB_ROYALBLUE1="\e[48;5;63m"
CB_VIOLET="\e[48;5;177m"
CB_LIGHTSTEELBLUE="\e[48;5;147m"
CB_GREENYELLOW="\e[48;5;154m"
CB_GREEN4="\e[48;5;28m"

black='\e[30m\]'
red='\e[31m\]'
green='\e[32m\]'
yellow='\e[33m\]'
blue='\e[34m\]'
purple='\e[35m\]'
cyan='\e[36m\]'
white='\e[37m\]'
# orange="\e[38;5;202m"
C_PURPLE4="\e[38;5;54m"
C_VIOLET="\e[38;5;177m"
C_ROYALBLUE1="\e[38;5;63m"
C_LIGHTSTEELBLUE="\e[38;5;147m"
C_GREEN4="\e[38;5;28m"
C_GREENYELLOW="\e[38;5;154m"
C_DODGERBLUE2="\e[38;5;27m"

C_MAROON="\e[38;5;1m"
C_ORANGERED1="\e[38;5;202m"
CB_MAROON="\e[48;5;1m"
CB_ORANGERED1="\e[48;5;202m"

clear='\[\e[00m\]'

I_GIT=""       #nf-fa-git
I_DIRECTORY="" #nf-oct-file_directory_open_fill
I_CALENDAR="󰸗"  #nf-md-calendar_month
I_BRANCH=""
I_PLAY_ARROW=""
I_SEMICIRCLE_START=
I_SEMICIRCLE_END=
day=$(date +"%d")
suffix_arr=("st" "nd" "rd")

if (((day >= 4 && day <= 20) || (day >= 24 && day <= 30))); then
	suffix="th"
else
	suffix_arr=("st" "nd" "rd")
	suffix=${suffix_arr[day % 10 - 1]}
fi

###################
# PS1='\[\e]0;$TITLEPREFIX:$PWD\007\]' # set window title
PS1="\n$C_LIGHTSTEELBLUE$I_SEMICIRCLE_START"
PS1="$PS1$CB_LIGHTSTEELBLUE"
PS1="$PS1$C_ROYALBLUE1$I_CALENDAR"' '
PS1="$PS1$NO_FORMAT$CB_ROYALBLUE1"' '
PS1="$PS1$C_ROYALBLUE1$CB_LIGHTSTEELBLUE"' \d'$suffix' | \@ '
PS1="$PS1$NO_FORMAT$C_LIGHTSTEELBLUE$I_SEMICIRCLE_END"

PS1="$PS1 "

PS1="$PS1$NO_FORMAT$C_GREENYELLOW$I_SEMICIRCLE_START"
PS1="$PS1$CB_GREENYELLOW$C_GREEN4$I_DIRECTORY"' '
PS1="$PS1$NO_FORMAT$CB_GREEN4"' '
PS1="$PS1$C_GREEN4$CB_GREENYELLOW"' \[$(pwd | sed -E -e "s|^'"$HOME"'|~|" -e "s|^.*/([^/]*)/([^/]*)/.*(/[^/]*/[^/]*)|\1/\2/....\3|")\] '
PS1="$PS1$NO_FORMAT$C_GREENYELLOW$I_SEMICIRCLE_END"

PS1="$PS1 "

if test -z "$WINELOADERNOEXEC"; then
	GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
	COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
	COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
	COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
	if test -f "$COMPLETION_PATH/git-prompt.sh"; then
		. "$COMPLETION_PATH/git-completion.bash"
		. "$COMPLETION_PATH/git-prompt.sh"

		# if [ -d ".git" ] || git rev-parse --git-dir &>/dev/null; then
			PS1="$PS1$NO_FORMAT$C_ORANGERED1$I_SEMICIRCLE_START"
			PS1="$PS1$CB_ORANGERED1$C_MAROON$I_GIT"' '
			PS1="$PS1$NO_FORMAT$CB_MAROON"' '
			PS1="$PS1$C_MAROON$CB_ORANGERED1"' $(__git_ps1 "(%s)")'
			PS1="$PS1"'%{$fg[magenta]%}%~%u $(git_info)'
			# PS1="$PS1$C_MAROON$CB_ORANGERED1"' $(git status --porcelain)'
			PS1="$PS1$NO_FORMAT$C_ORANGERED1$I_SEMICIRCLE_END"
		# fi
		# PS1="$PS1"'`__git_ps1`'   # bash function
	fi
fi

PS1="$PS1$C_DODGERBLUE2"'$'

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