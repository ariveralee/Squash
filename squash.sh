# Where Connection URL's with Alias's will be written to
CREDENTIALS_FILE=.mongo_credentials
TEMP_FILE=.mongo_credentials.tmp
#Saves original state for string manipulation later (line 82)
prevIFS=IFS
# While there are not 0 arguments
while [[ ! $# -eq 0 ]]; do
  case "$1" in
		# User wants to saved mongodb credentials to file
		add-cred)
			shift
			ARGCOUNT=0
			while [[ ! $# -eq 0 ]] && [[ "$1" = --* ]]; do
				flag="$1"
				((ARGCOUNT++))
				shift
				case "$flag" in
					"--url")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --url flag"
							exit 1
						else
							CONNECT_URL="$1"
							shift
						fi;;
					"--alias")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --alias flag"
							exit 1
						else
							DATABASE_ALIAS="$1"
							shift
						fi;;
				esac
			done # end of while loop for add-cred args
			
			if [[ ! ARGCOUNT -eq 2 ]]; then
				echo "not enough args"
				exit 1
			else
				echo "$DATABASE_ALIAS=$CONNECT_URL" >>$CREDENTIALS_FILE
				echo "Sucessfully added credentials to $CREDENTIALS_FILE"
			fi
		exit
		;;
		
		# User wants to remove mongo credential
		del-cred)
			shift
			ARGCOUNT=0
			while [[ ! $# -eq 0 ]] && [[ "$1" = --* ]]; do
				flag="$1"
				((ARGCOUNT++))
				shift
				case "$flag" in
					"--alias")
						if [[ -z $1 ]]; then
							echo "must provide an alias to remove"
							exit 1
						else 
							DATABASE_ALIAS="$1"
							# We want to make sure the DBALIAS exists in the cred file
							if ALIAS_URL=`grep -w ${DATABASE_ALIAS} ${CREDENTIALS_FILE}`; then
								ALIAS_URL=${ALIAS_URL##*=}
							else
								echo "Database URL not found! Check to see if you have the right alias"
								exit 1
							fi
							shift
						fi
				esac
			done # While loop looking for args 
			
			if [[ ! $ARGCOUNT -eq 1 ]]; then
				echo "not enough args"
				exit 1
			fi
			
			# Lets confirm this is the record they want to erase
      echo "Are you sure you want to delete ${DATABASE_ALIAS}: ${ALIAS_URL}?
      [ y | n ] then press ENTER"
      read ANSWER
      if [[ "${ANSWER}" == "n" ]]; then
      	echo "exiting..."
      	exit 1
      else
      	TEMP=$TEMP"${DATABASE_ALIAS}=""${ALIAS_URL}"
      	echo "${TEMP}"
      	touch "${TEMP_FILE}"
      	grep -Fv "${TEMP}" "${CREDENTIALS_FILE}" > "${TEMP_FILE}"
      	mv "${TEMP_FILE}" "${CREDENTIALS_FILE}"
      	echo "Removed entry"
      fi
		exit;; # Exit delete cred case
		
		# Case that we want to add a user to the Database
		add-user)
			shift
			ARGCOUNT=0
			while [[ ! $# -eq 0 ]] && [[ "$1" = --* ]]; do
				flag="$1"
				((ARGCOUNT++))
				shift			
				case "$flag" in
					"--use")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --use flag"
							exit 1
						else
							DATABASE_ALIAS="$1"
							shift
						fi;;
					"--user")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --user flag"
							exit 1
						else
							USER="$1"
							shift
						fi;;
					"--pass")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --pass flag"
							exit 1
						else
							PASS="$1"
							shift
						fi;;
					"--db")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --db flag"
							exit 1
						else
							DBNAME="$1"
							shift
						fi;;
					"--roles")
						if [[ "$1" = --* ]]; then
							echo "must supply an argument for --roles flag"
							exit 1
						else
							IFS=', ' read -ra ROLES <<<"$1"
							shift
						fi;;
				esac
			done # end while loop checking for flags	
				
			# If we get here then flags have been provided with proper arguments but we want all 5 args.
			if [[ ! $ARGCOUNT -eq 5 ]]; then
				echo "not enough args"
				exit 1
			fi

			# We want to make sure the DBALIAS exists in the cred file
			if ALIAS_URL="$(grep -w "$(DATABASE_ALIAS)" "$(CREDENTIALS_FILE)")"; then
				ALIAS_URL=${ALIAS_URL##*=}
			else
				echo "Database URL not found, please use add-cred to store mongo url and alias"
				exit 1
			fi

			# Restore to prevIFS to build string with commas
			IFS=$prevIFS
			ROLE_STRING=""
			# builds the string for roles to be sent in the eval
			for i in ${ROLES[@]}; do
				ROLE_STRING=$ROLE_STRING"'$i',"	
			done
				
			ROLE_STRING="${ROLE_STRING%?}"
			# Finally, execute the mongo command to add a user
			mongo $ALIAS_URL --eval "db.getSiblingDB('$DBNAME').createUser({ user: '$USER', pwd: '$PASS', roles: [$ROLE_STRING] });"
			
		exit # exit add-user case
	esac
done