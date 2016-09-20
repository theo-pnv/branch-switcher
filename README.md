# branch-switcher
Ever experienced various problems with php/composer/symfony/mySql when switching from a git branch with old Composer dependencies to your newest branch ? You may need to maintain this old branch, if you work with various git environments, and switch from an environment to an other very fast, without having to manage composer or symfony configuration.

# This bash script allows you to :
     - Manage multiple Symfony vendor/ folders at a time
     - Install, reinstall differents versions of dependencies for each one
     - Update your doctrine database

# Installation on Linux/OsX

You need to create a vendors folder which will be external to your git project.
You also need to open once the script, and add the name of your branches in the config array.

```
$ chmod 755 branch_switcher.sh
$ mv branch_switcher.sh /usr/local/bin/branch_switcher
$ mkdir <exernal_vendors_folder>
$ branch_switcher <name_of_git_branch> <path/to/external/vendors/folder>
```

# Authors
* Theo Penavaire

# Inspiration
In my company we use to work on a website with 3 different environments - Devel, Staging and Prod - which are also sub-divised. While one environment's master was still on Symfony 2.8, and needed maintenance (the client used it), we jumped to Symfony 3.1 on other environments. That's why I needed something to quickly switch, and not waste 20min each time.

Hope it'll be useful to someone, that's my first bash script.

