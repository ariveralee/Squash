#!/bin/bash 

#ensures it's on a new line to prevent errors in .bashrc
ALIASSTRING="\nalias squash=/usr/local/bin/squash.sh"
SOURCEFILE="$HOME/.bashrc"

# with updates we can run build.sh again, prevents dups written to .bashrc
if CHECK="$(grep 'alias squash=/usr/local/bin/squash.sh' ${SOURCEFILE})"; then
  echo "Updating squash"
  cp ./squash.sh /usr/local/bin/
else
  echo "Setting everything up..."
  echo -e $ALIASSTRING >> $SOURCEFILE
  cp ./squash.sh /usr/local/bin/
  source ~/.bashrc
fi
echo "Done! you can use 'squash help' for usage"