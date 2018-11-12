#!/bin/bash
PM=''
OS=''
CTAGS_PARA=''
CURDIR=''
Get_Dist_Name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='sudo yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='sudo yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='sudo yum' 
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then 
        DISTRO='Fedora'
        PM='sudo yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='sudo apt-get'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='sudo apt-get'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='sudo apt-get'
    else
        DISTRO='unknow'
    fi
    echo $DISTRO,$PM
}

check_os(){
    os=`uname -a | cut -d ' ' -f 1` 
    if [ $os = "Linux" ]
    then
        INFO=$(Get_Dist_Name)
        echo $INFO
        OS=`echo $INFO | cut -d \, -f 1`
        PM=`echo $INFO | cut -d \, -f 2`
        CTAGS_PARA='-R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++'
    elif [ $os = "Darwin" ]
    then
        OS="Mac"
        PM="brew"
        CTAGS_PARA=''
    fi

}
check_and_install(){
    if [ $# -lt 1 ]
    then 
        echo "No command input, input error !!!"
        return 
    fi
    $1 -h >/dev/null 2>&1
    if [ $? -eq 127 ]
    then
        $PM install $1
    fi
    echo "$1 installed"
}


CURDIR=`pwd`
check_os
echo "Operating os is $OS"
echo "install tool is $PM"
if [ -z "$PM" ]
then 
    echo "currently not support $OS, exit!!!"
    exit
fi
# first backup old vim configuration folder and 
# mkdir .vim and copy vimrc
if [ -e ~/.vim ]
then
    rm -fr ~/.vim_back
    mv ~/.vim ~/.vim_back
fi
mkdir -p  ~/.vim
cp vimrc ~/.vim/vimrc
# install software that must be installed
if [ $OS = 'Mac' ]
then
    brew help 2>&1
    if [ $? = '127' ]
    then
        ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    fi
fi
check_and_install git
check_and_install curl 
check_and_install ctags

# install autoload
echo "install autoload..."
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
# install auto pair
echo "install autopair..."
git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs

# install nerdtree
echo "install nerdtree..."
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

# install taglist
echo "install taglist..."
cd ~/.vim/bundle && wget "http://www.vim.org/scripts/download_script.php?src_id=19574" -O taglist.zip && unzip taglist.zip -d taglist
# install omnicppcomplete
echo "install omnicppcomplete..."
cd ~/.vim/bundle && wget "http://www.vim.org/scripts/download_script.php?src_id=7722" -O omnicppcomplete.zip && unzip omnicppcomplete.zip -d omnicppcomplete
# install cpp std library
echo "install c++ std library..."
mkdir -p ~/.vim/tags && cd ~/.vim/tags && wget "http://www.vim.org/scripts/download_script.php?src_id=9178" -O - | tar jxf -

# generate tags for cpp std library 
cd cpp_src/
ctags $CTAGS_PARA 

# install supertab to use tab to autocomplete
echo "install supertab..."
cd ~/.vim/bundle && git clone https://github.com/ervandew/supertab.git

cd $CURDIR
echo "vim configuration  finished"
