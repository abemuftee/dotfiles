### EXPORT ###
export TERMINAL="st"
export EDITOR="emacsclient -c"              # $EDITOR use Emacs in terminal
export BROWSER="google-chrome-stable"
export PINENTRY_USER_DATA="gtk"
export BAT_THEME="Nord"
export LC_ALL=en_US.UTF-8

### SET MANPAGER

# "bat" as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

### OH MY ZSH & POWERLEVEL10K ###

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="/home/ibrahim/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="gentoo"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# Sourcing oh-my-zsh
source $ZSH/oh-my-zsh.sh

### GLOBAL PATH ###

# Add Doom Emacs bin to $PATH
export PATH="$PATH:/home/ibrahim/.emacs.doom/bin"

# Add ~/.local/bin to $PATH
export PATH="$PATH:/home/ibrahim/.local/bin"

# Add ~/.local/bin/statusbar to $PATH
export PATH="$PATH:/home/ibrahim/.local/bin/statusbar"

### ALIASES ####

# Restart Emacs systemd daemon
alias sre='systemctl restart --user emacs'

# Dotfiles repo vars
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Rsync command to update website
alias webup="rsync -rtvzP ~/Repos/website/ ibrahim@ibrahimmuftee.net:/var/www/ibrahimmuftee.net"

# Use neovim for vim if present.
[ -x "$(command -v nvim)" ] && alias vim="nvim" vimdiff="nvim -d"

# Verbosity and settings that you pretty much just always are going to want.
alias yt="youtube-dl --add-metadata -i"      # youtube-dl download normal video
alias yta="yt -x -f bestaudio/best"          # youtube-dl download audio file of video
alias ducks='du -cks * | sort -rn | head'    # Size in bytes of files and directories
alias mutt='neomutt'

# These common commands are just too long! Abbreviate them.
alias ka="killall"
alias g="git"
alias sdn="sudo shutdown -h now"
alias e="$EDITOR"
alias v="$EDITOR"
alias p="sudo pacman"
alias z="zathura"
alias archive="sudo mount -t cifs //192.168.1.125/archive /archive/ -o username=family"

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

### MAIN ###

# Set autocd
setopt auto_cd

# History in cache directory
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" >/dev/null
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

bindkey -s '^a' 'bc -lq\n'

bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Encrypt and Decrypt easier

function secret {  # list preferred id last
  output="${HOME}/$(basename ${1}).$(date +%F).enc"
  gpg --encrypt --armor \
    --output ${output} \
    -r 0xA735D93ABBFAB330 \
    -r ibrahim@ibrahimmuftee.net \
    "${1}" && echo "${1} -> ${output}"
}

function reveal {
  output=$(echo "${1}" | rev | cut -c16- | rev)
  gpg --decrypt --output ${output} "${1}" \
    && echo "${1} -> ${output}"
}

# Generate and deploy my static website
function generate {
    cd ~/code/website
    rm -f dst/.files
    ssg6 src dst \
	 "Ibrahim Muftee\'s Website" \
	 "http://ibrahimmuftee.net"
}

function deploy {
    rsync \
	-rtvzP --delete-after \
	~/code/website/dst/ \
	root@ibrahimmuftee.net:/var/www/ibrahimmuftee
}

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Vterm shell-side configuration
vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# eval "$(starship init zsh)"
