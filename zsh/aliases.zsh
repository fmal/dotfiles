alias zshconfig="choc ~/.zshrc"
alias edit="atom"
alias ss='source ~/.zshrc' # quick source
alias mkdir="mkdir -p"
alias l="ls -al"
alias ls="ls -GFh"
alias ll="ls -GFhl"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias projects="cd ~/Projects"
alias desktop="cd ~/Desktop"
# will copy folder contents, if folder ends in / will copy contents, not folder itself
alias copy="cp -r"
alias delete="rm -r"
# http://martineau.tv/blog/2013/12/more-efficient-grunt-workflows/
alias npmui="npm-check-updates -u && npm install"

# Inkscape
if [[ -f /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]]; then
    alias inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
fi
