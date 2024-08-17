alias zshconfig="code ~/.zshrc"
alias ss='source ~/.zshrc' # quick source
alias mkdir="mkdir -p"
alias l="ls -al"
alias ls="ls -GFh"
alias ll="ls -GFhl"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias o="open ./"
alias f="finder"
alias projects="cd ~/Code"
alias desktop="cd ~/Desktop"
# will copy folder contents, if folder ends in / will copy contents, not folder itself
alias copy="cp -r"
alias delete="rm -r"

# Inkscape
if [[ -f /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]]; then
  alias inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
fi
