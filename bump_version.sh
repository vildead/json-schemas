#!/bin/bash

# Thanks goes to @pete-otaqui for the initial gist:
# https://gist.github.com/pete-otaqui/4188238
#
# Original version modified by Marek Suscak
#
# works with a file called VERSION in the current directory,
# the contents of which should be a semantic version number
# such as "1.2.3" or even "1.2.3-beta+001.ab"

# this script will display the current version, automatically
# suggest a "minor" version update, and ask for input to use
# the suggestion, or a newly entered value.

# once the new version number is determined, the script will
# pull a list of changes from git history, prepend this to
# a file called CHANGELOG.md (under the title of the new version
# number), give user a chance to review and update the changelist
# manually if needed and create a GIT tag.

NOW="$(date +'%B %d, %Y')"
RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

LATEST_HASH=`git log --pretty=format:'%h' -n 1`

QUESTION_FLAG="${GREEN}?"
WARNING_FLAG="${YELLOW}!"
NOTICE_FLAG="${CYAN}❯"


# Check presence of VERSION file
[ ! -f VERSION ] && echo -e "${RED}No VERSION file found. It should be present with string matching '[0-9].[0-9].[0-9]'" && exit

# Check there are no changes
git update-index --refresh 
git diff-index --quiet HEAD --
[  $? -ne 0 ] && echo -e "${RED}Uncommited changes were found. Please commit all changes first or stash them." && exit

# Get new version
BASE_STRING=`cat VERSION`

# Check that VERSION is the same as latest tag
TAG_VERSION=$(git describe --abbrev=0)
[[ "$TAG_VERSION" != "v$BASE_STRING" ]] && echo -e "${WARNING_FLAG}Latest tag on current branch ($TAG_VERSION) is not matching version in VERSION file ($BASE_STRING). Version from VERSION file will be used."

BASE_LIST=(`echo $BASE_STRING | tr '.' ' '`)
V_MAJOR=${BASE_LIST[0]}
V_MINOR=${BASE_LIST[1]}
V_PATCH=${BASE_LIST[2]}
echo -e "${NOTICE_FLAG} Current version: ${WHITE}$BASE_STRING"
echo -e "${NOTICE_FLAG} Latest commit hash: ${WHITE}$LATEST_HASH"
V_PATCH=$((V_PATCH + 1))
SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
echo -ne "${QUESTION_FLAG} ${CYAN}Enter a version number [${WHITE}$SUGGESTED_VERSION${CYAN}]: "
read INPUT_STRING
if [ "$INPUT_STRING" = "" ]; then
    INPUT_STRING=$SUGGESTED_VERSION
fi
echo -e "${NOTICE_FLAG} Will set new version to be ${WHITE}$INPUT_STRING"
echo $INPUT_STRING > VERSION
#echo "## $INPUT_STRING ($NOW)" > tmpfile
#git log --pretty=format:"  - %s" "v$BASE_STRING"...HEAD >> tmpfile
#echo "" >> tmpfile
#echo "" >> tmpfile
#cat CHANGELOG.md >> tmpfile
#mv tmpfile CHANGELOG.md
#ADJUSTMENTS_MSG="${QUESTION_FLAG} ${CYAN}Now you can make adjustments to ${WHITE}CHANGELOG.md${CYAN}. Then press enter to continue."
#PUSHING_MSG="${NOTICE_FLAG} Pushing new version to the ${WHITE}origin${CYAN}..."
#echo -e "$ADJUSTMENTS_MSG"
#read
#echo -e "$PUSHING_MSG"

# change the URLs inside schemas
echo -e "${WHITE}Updating all URLs in schemas to point to tag v$INPUT_STRING"
BASE_URI='https:\/\/raw.githubusercontent.com\/elixir-luxembourg\/json-schemas'
find schemas/ -type f -exec sed -i "s/$BASE_URI\/v$BASE_STRING/https:\/\/raw.githubusercontent.com\/elixir-luxembourg\/json-schemas\/v$INPUT_STRING/g" {} \;
find tests/ -type f -exec sed -i "s/$BASE_URI\/v$BASE_STRING/https:\/\/raw.githubusercontent.com\/elixir-luxembourg\/json-schemas\/v$INPUT_STRING/g" {} \;
git add schemas/. tests/.
git add VERSION
# Commit all changes
#git add CHANGELOG.md VERSION
git commit -m "Bump version to ${INPUT_STRING}."
git tag "v$INPUT_STRING"


echo -e "${NOTICE_FLAG} Finished. Run 'git push origin --tag' to push changes to remote repository."
