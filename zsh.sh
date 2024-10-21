#!/bin/zsh

yay --batchinstall --sudoloop --noconfirm -S zsh \
    zsh-theme-powerlevel10k \
    fzf-tab-source \
    fd \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    oh-my-zsh-git \
    starship

chsh -s /bin/zsh
cat << 'EOF' > ~/.zshrc
# Zsh Configuration

# Powerlevel10k Instant Prompt
# This should stay close to the top of ~/.zshrc.
# Initialization code requiring console input must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh Configuration
export ZSH="/Users/p.petryszen/.oh-my-zsh"

# Zsh Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Theme Setup
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable fzf-tab
[ -f /usr/share/fzf-tab/fzf-tab.zsh ] && source /usr/share/fzf-tab/fzf-tab.zsh

# Enable Completion System
autoload -Uz compinit
compinit

# Load Zsh Modules (commented out for now)
# zmodload zsh/zle
# zmodload zsh/zpty
# zmodload zsh/complist

# Initialize Colors
autoload -Uz colors
colors

# General Completion Behavior
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*' complete true
zstyle ':completion:*' complete-options true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' menu select
zstyle ':completion:*' list-grouped false
zstyle ':completion:*' list-separator
zstyle ':completion:*' group-name
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' sort false
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:eza' sort false
zstyle ':completion:complete:*:options' sort false
zstyle ':completion:files' sort false

# fzf-tab Configuration
zstyle ':fzf-tab:complete:*:*' fzf-preview 'eza --icons -a --group-directories-first -1 --color=always $realpath'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' fzf-min-height 100
zstyle ':fzf-tab:*' switch-group ',' '.'

# Terminal Application Mode for ZLE
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# History Options
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_expire_dups_first
setopt hist_verify

# Source Powerlevel10k Configuration
source ~/.p10k.zsh

# Custom Completion Functions
_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        ssh) fzf --preview 'dig {}' "$@" ;;
        *) fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}

# Aliases
alias c="clear"
alias cat="bat"
alias diff="delta --diff-so-fancy --side-by-side"
alias less="bat"
alias py="python"
alias dsize="du -hs"
alias open="xdg-open"
alias space="ncdu"
alias man="BAT_THEME='default' batman"
alias l="eza --icons -a --group-directories-first -1"
alias ll="eza --icons -a --group-directories-first -1 --no-user --long"
alias tree="eza --icons --tree --group-directories-first"
alias piv="python -m venv .venv"
alias psv="source .venv/bin/activate"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

# Bun Configuration
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# pnpm Configuration
export PNPM_HOME="/home/corax/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
EOF

# Reload Zsh configuration
echo "Reloading Zsh configuration..."
source ~/.zshrc

echo "Zsh setup completed successfully!"
