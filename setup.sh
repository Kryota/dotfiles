DOT_FILES=(.vimrc .tmux.conf .zshrc .switch_proxy .vim)

for file in ${DOT_FILES[@]}
do
	ln -s $HOME/dotfiles/$file $HOME/$file
done
