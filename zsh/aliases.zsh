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
alias projects="cd ~/Projects"
alias desktop="cd ~/Desktop"
# hidden files management
alias see="defaults write com.apple.finder AppleShowAllFiles YES;
killall Finder /System/Library/CoreServices/Finder.app"
alias unsee="defaults write com.apple.finder AppleShowAllFiles NO;
killall Finder /System/Library/CoreServices/Finder.app"
# will copy folder contents, if folder ends in / will copy contents, not folder itself
alias copy="cp -r"
alias delete="rm -r"
# http://martineau.tv/blog/2013/12/more-efficient-grunt-workflows/
alias nui="npm-check-updates -u && npm install"
alias nis="npm install --save"
alias nid="npm install --save-dev"
alias nf="npm cache clean && rm -rf node_modules && npm install"

# Inkscape
if [[ -f /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]]; then
    alias inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
fi
