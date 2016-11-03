# Use Antigen as zsh package manager
source $(brew --prefix)/share/antigen/antigen.zsh

# Load the oh-my-zsh's library
antigen use oh-my-zsh

antigen bundle git
antigen bundle github
antigen bundle osx
antigen bundle ruby
antigen bundle brew
antigen bundle node
antigen bundle npm
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle mafredri/zsh-async
antigen bundle sindresorhus/pure

antigen apply
