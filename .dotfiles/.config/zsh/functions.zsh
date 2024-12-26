# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Function to display aliases help
function alias_help() {
    # Colors
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local BLUE='\033[0;34m'
    local YELLOW='\033[1;33m'
    local PURPLE='\033[0;35m'
    local NC='\033[0m' # No Color
    
    # Icons (Nerd Fonts)
    local TERMINAL_ICON=''
    local FILE_ICON=''
    local PACKAGE_ICON=''
    local GIT_ICON=''
    local FOLDER_ICON=''
    
    # Clear screen and print header
    clear
    echo -e "${BLUE}╭──────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│${YELLOW}        Available Aliases Help            ${BLUE}│${NC}"
    echo -e "${BLUE}╰──────────────────────────────────────────╯${NC}\n"
    
    # Terminal Operations
    echo -e "${GREEN}${TERMINAL_ICON} Terminal Operations${NC}"
    echo -e "${PURPLE}├─${NC} c     ${YELLOW}→${NC} Clear terminal screen"
    echo -e "${PURPLE}└─${NC} mkdir ${YELLOW}→${NC} Create directories with parents\n"
    
    # File Listing
    echo -e "${GREEN}${FILE_ICON} File Listing${NC}"
    echo -e "${PURPLE}├─${NC} l     ${YELLOW}→${NC} Long list with icons"
    echo -e "${PURPLE}├─${NC} ls    ${YELLOW}→${NC} Simple list with icons"
    echo -e "${PURPLE}├─${NC} ll    ${YELLOW}→${NC} Long list (all files) with icons"
    echo -e "${PURPLE}├─${NC} ld    ${YELLOW}→${NC} List directories only"
    echo -e "${PURPLE}└─${NC} lt    ${YELLOW}→${NC} List as tree\n"
    
    # Package Management
    echo -e "${GREEN}${PACKAGE_ICON} Package Management${NC}"
    echo -e "${PURPLE}├─${NC} pa    ${YELLOW}→${NC} List available packages"
    echo -e "${PURPLE}├─${NC} pl    ${YELLOW}→${NC} List installed packages"
    echo -e "${PURPLE}├─${NC} pc    ${YELLOW}→${NC} Remove unused cache"
    echo -e "${PURPLE}├─${NC} po    ${YELLOW}→${NC} Remove unused packages"
    echo -e "${PURPLE}├─${NC} un    ${YELLOW}→${NC} Uninstall package"
    echo -e "${PURPLE}└─${NC} up    ${YELLOW}→${NC} Update system/packages\n"
    
    # Git Operations
    echo -e "${GREEN}${GIT_ICON} Git Operations${NC}"
    echo -e "${PURPLE}├─${NC} gi    ${YELLOW}→${NC} Git init"
    echo -e "${PURPLE}├─${NC} gb    ${YELLOW}→${NC} Git branch"
    echo -e "${PURPLE}├─${NC} gbd   ${YELLOW}→${NC} Git branch -d"
    echo -e "${PURPLE}├─${NC} gc    ${YELLOW}→${NC} Git commit"
    echo -e "${PURPLE}├─${NC} gca   ${YELLOW}→${NC} Git commit --amend --no-edit"
    echo -e "${PURPLE}├─${NC} gcl   ${YELLOW}→${NC} Git clone"
    echo -e "${PURPLE}├─${NC} ga    ${YELLOW}→${NC} Git add"
    echo -e "${PURPLE}├─${NC} gaa   ${YELLOW}→${NC} Git add all"
    echo -e "${PURPLE}├─${NC} gco   ${YELLOW}→${NC} Git checkout"
    echo -e "${PURPLE}├─${NC} gdiff ${YELLOW}→${NC} Git diff"
    echo -e "${PURPLE}├─${NC} gl    ${YELLOW}→${NC} Git log"
    echo -e "${PURPLE}├─${NC} gp    ${YELLOW}→${NC} Git push"
    echo -e "${PURPLE}├─${NC} gpl   ${YELLOW}→${NC} Git pull"
    echo -e "${PURPLE}└─${NC} gsvl  ${YELLOW}→${NC} Git status -v > git-status.log\n"
    
    # Directory Navigation
    echo -e "${GREEN}${FOLDER_ICON} Directory Navigation${NC}"
    echo -e "${PURPLE}├─${NC} .3    ${YELLOW}→${NC} Go up three levels"
    echo -e "${PURPLE}├─${NC} .4    ${YELLOW}→${NC} Go up four levels"
    echo -e "${PURPLE}├─${NC} .5    ${YELLOW}→${NC} Go up five levels"
    echo -e "${PURPLE}├─${NC} ..    ${YELLOW}→${NC} Go up one level"
    echo -e "${PURPLE}├─${NC} ...   ${YELLOW}→${NC} Go up two levels"
    echo -e "${PURPLE}└─${NC} dev   ${YELLOW}→${NC} Go to coding directory\n"
    
    # Health Check Script
    echo -e "${GREEN}${PACKAGE_ICON} Health Check${NC}"
    echo -e "${PURPLE}└─${NC} health${YELLOW}→${NC} Run health check script\n"
}
