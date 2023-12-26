#! /bin/sh

# Terminal styling codes
reset=$(tput sgr0)
bold=$(tput bold)
underline=$(tput smul)
nounderline=$(tput rmul)
reverse=$(tput rev)
standout=$(tput smso)
nostandout=$(tput rmso)
dim=$(tput dim)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

bgred=$(tput setab 1)
bggreen=$(tput setab 2)
bgyellow=$(tput setab 3)
bgblue=$(tput setab 4)
bgmagenta=$(tput setab 5)
bgcyan=$(tput setab 6)
bgwhite=$(tput setab 7)

# Set up the stage counter
stage=1

# Useful functions
title() {
    echo "${bold}${white}${bgmagenta}==================== ${*} ====================${reset}"
    # Set the terminal emulator title
    printf "\033]0;%s\a" "${*}"
}

header() {
    echo "${bold}${cyan}---------- ${*} ----------${reset}"
}

stage() {
    echo "${bold}${blue}=> ${underline}Stage ${stage}: ${*}${reset}"
    stage=$((stage + 1))
}

error() {
    echo "${bold}${red}Error: ${*}${reset}" >&2
}

warning() {
    echo "${bold}${yellow}Warning: ${*}${reset}" >&2
}

info() {
    echo "${cyan}${*}${reset}"
}

success() {
    echo "${bold}${green}${*}${reset}"
}
