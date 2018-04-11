# Use Antigen as zsh package manager
source $(brew --prefix)/share/antigen/antigen.zsh

# Load the oh-my-zsh's library
antigen use oh-my-zsh

antigen bundles <<EOB
  git
  github
  osx
  ruby
  brew
  node
  npm

  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions

  b4b4r07/emoji-cli
EOB

antigen theme denysdovhan/spaceship-prompt spaceship

antigen apply
