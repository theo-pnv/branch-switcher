#!/usr/bin/env bash
# Author : Theo Penavaire
# v1.0.1

# Configure this array to add your git branches
BRANCHES=(
    #"prod-sf2.8"
    #"devel-sf3.1"
    #"..."
)

#=========== DO NOT MODIFY SCRIPT BEYOND ===========

# Global variables
START="\033[1;32m
Started to synchronize your environments.
\033[0m"

ASK_DELETE_VDR="\033[1;33m
Confirm suppression of existing vendor folder (y/n).\n
You'll be able to reinstall dependencies later, but if you don't want to,\n
I suggest to copy it in your backup folder and name it 'vendor_<name_of_branch>'
\033[0m"
ASK_INSTALL="\033[1;33m
Do you want to install new dependencies with composer ? (y/n)
\033[0m"
ASK_UPD_SQL="\033[1;33m
An update of your database may be necessary.\n
Do you want to make the eventual printed changes ? (y/n)
\033[0m"

DELETED_VDR="\033[1;37m
Deleted vendor link or folder
\033[0m"
CREATED_DIR="\033[1;37m
Created external vendor folder, corresponding to current git branch.
\033[0m"
CREATED_SYMLINK="\033[1;37m
Created symbolic(s) link(s)
\033[0m"

INSTALLING_DEP="\033[1;37m
Installing dependencies...
\033[0m"

ERR_MISPELLED="\033[1;31m
Wrong name of branch
\033[0m"
ERR_CACHE="\033[1;31m
Something went wrong, try to manually clear your cache
\033[0m"
ERR_DEP="\033[1;31m
Something went wrong, try to clear your cache, or to reinstall your dependencies.
\033[0m"

END="\033[1;32m
Successfully imported the environment on this $SWITCHED_BRANCH branch. Good luck !
\033[0m"


# Functions
usage()
{
    cat <<EOF
Usage: $(basename "$0") <name_of_switched_branch> <path_to_backup_folder>

Script to synchronize a Symfony project with composer dependencies, 
depending on your current git branch.
Please create an external backup folder in which you will either 
store the different vendor folders depending on your branches, 
or let the script reinstall them for you.

Example : 
$ mkdir ~/Desktop/Backup_vendors
$ $(basename "$0")
EOF
    exit 0;
}

# Delete vendor folder if it already exists
delete_vendor()
{
    if [ -e "vendor" ] ; then
	# If directory
	if [ -d "vendor" ] && [ ! -L "vendor" ] ; then
	    echo -e $ASK_DELETE_VDR
	    read ANSWER
	    if [ ! "$ANSWER" = "y" ] ; then
		exit 0;
	    fi
	fi
	rm -rf vendor
	echo -e $DELETED_VDR
    fi
}

# Create symlinks to external vendor folder
create_symlinks()
{
    ERR=0
    for i in ${!BRANCHES[@]}; do
	if [ "$SWITCHED_BRANCH" = "${BRANCHES[i]}" ] ; then
	    if [ ! -d $BACKUP_FOLDER/vendor_$SWITCHED_BRANCH ] ; then
		echo -e $CREATED_DIR
		mkdir $BACKUP_FOLDER/vendor_$SWITCHED_BRANCH
	    fi
	    ln -s $BACKUP_FOLDER/vendor_$SWITCHED_BRANCH vendor
	    echo -e $CREATED_SYMLINK
	    ((ERR++))
	fi
    done

    # If user mispelled switched branch's name
    if [ "$ERR" -eq 0 ] ; then
	echo -e $ERR_MISPELLED
	exit 1;
    fi
}

# Eventually install composer dependencies
install_dependencies()
{
    ERR_CODE=$?
    if [ "$ERR_CODE" -eq 0 ] ; then
	echo -e $ASK_INSTALL
	read ANSWER
	if [ "$ANSWER" = "y" ] ; then
	    echo -e $INSTALLING_DEP
	    composer install
	    if [ "$?" -ne 0 ] ; then
		echo -e $ERR_CACHE
		exit
	    fi
	fi
    fi
}

# Update Mysql Database
update_sql()
{
    if [ "$ERR_CODE" -eq 0 ] ; then
	echo "..."
	php app/console doc:sch:upd --dump-sql
	if [ "$?" -eq 0 ] ; then
	    echo -e $ASK_UPD_SQL
	    read ANSWER
	    if [ "$ANSWER" = "y" ] ; then
		php app/console doc:sch:upd --force
	    fi
	else
	    echo -e $ERR_DEP
	    exit
	fi
    fi
}

main()
{
    SWITCHED_BRANCH=$1
    BACKUP_FOLDER=$2

    if [ -z $1 ] || [ -z $2 ] || [ $3 ]  ; then
	usage
	
    elif [ $1 ] ; then
	echo -e $START
	delete_vendor
	create_symlinks
	install_dependencies
	update_sql
    fi

    # Good luck !
    if [ "$?" -eq 0 ] ; then
	echo -e $END
    fi
    exit 0;
}

main "$@"

# End
