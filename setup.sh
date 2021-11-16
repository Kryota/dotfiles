DOT_FILES=(.vimrc .tmux.conf .zshrc .vim .tmux)

for file in ${DOT_FILES[@]}
do
	ln -s $HOME/dotfiles/$file $HOME/$file
done
