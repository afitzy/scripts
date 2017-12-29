#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"


# Example:
# groupName fitzy sambashare
function groupName () {
  find . -group $1 -exec chgrp -h $2 {} \;
}

# Example:
# groupName fitzy sambashare
function groupNameSudo () {
  find . -group $1 -exec sudo chgrp -h $2 {} \;
}

# Example:
# groupName 1004 sambashare
function groupId () {
  find . -gid $1 -exec chgrp -h $2 {} \;
}

# Example:
# groupName 1004 sambashare
function groupIdSudo () {
  find . -gid $1 -exec sudo chgrp -h $2 {} \;
}
