#!/bin/bash

export runDirectory=$(pwd)
export svnUrl=<SVN_URL>
export svnUserMappingsPath=../COMPLETE_mapping.txt
export svnUserName=<SVN_USER_NAME>
export gitUrl=<GIT_URL>
export gitUserName=migration@test.com
export gitUserEmail=Migration Tool
export tempDirectoryPath=$runDirectory/temp
export repoPath=$tempDirectoryPath/repository
export bareRepositoryLocation=$tempDirectoryPath/new-bare.git

# Preparations
echo $bareRepositoryLocation
rm -r -f $bareRepositoryLocation
cd $repoPath

# Git SVN Clone
echo Git SVN Clone STARTED
git svn clone $svnUrl --no-metadata -A $svnUserMappingsPath --stdlayout $repoPath --username=%svnUserName%
echo Git SVN Clone FINISHED
read -p "SVN Clone is finished. But there are some more things that needs to be performed. Press [Enter] to continue"

echo Convert svn:ignore properties to .gitignore STARTED
git config user.name "$gitUserEmail"
git config user.email "$gitUserName"
git svn show-ignore -i origin/trunk > .gitignore
git add .gitignore
git commit --reset-author --amend -m 'Convert svn:ignore properties to .gitignore.'
echo Convert svn:ignore properties to .gitignore FINISHED

# Push repository to a bare git repository
echo Push repository to a bare git repository STARTED
git init --bare $bareRepositoryLocation 
cd $bareRepositoryLocation 
git symbolic-ref HEAD refs/heads/trunk
cd $repoPath 
git remote remove bare
git remote add bare $bareRepositoryLocation 
git config remote.bare.push 'refs/remotes/origin/*:refs/heads/*'

git push bare
echo Push repository to a bare git repository FINISHED

# Renaming trunk branch to master
echo Rename trunk branch to master STARTED
cd $bareRepositoryLocation 
git branch -m trunk master
echo Rename trunk branch to master FINISHED

echo Clean up branches and tags STARTED
cd $bareRepositoryLocation 
git for-each-ref --format='%(refname)' refs/heads/tags | cut -d / -f 4 |
while read ref
do
 git tag -a "$ref" -m "Tag: $ref" "refs/heads/tags/$ref";
 git branch -D "tags/$ref";
done
echo Clean up branches and tags FINISHED

echo Pushing the repository STARTED
git config http.sslVerify "false"
git remote add origin $gitUrl
git push --all
git push --tags
echo Pushing the repository FINISHED

cd $runDirectory
