# Where Connection URL's with Alias's will be written to
CREDENTIALS_FILE=.mongo_credentials
#Saves original state for string manipulation later (line 56)
prevIFS=IFS
# While there are not 0 arguments
while [ ! $# -eq 0 ]
do
		case "$1" in
			# User wants to saved mongodb credentials to file
			add-cred)
				if [ "$2" != "--url"] && [ "$4" != "--alias"]
				then
					echo "Correct Usage for storing a DB is: add-cred --url 'dburl' --alias 'alias'"
					exit 1
				else
					CONNECT_URL=$3
					DATABASE_ALIAS=$5
					#creates if it does not exist and appends credentials if it does in format alias=dbURL
					echo "$DATABASE_ALIAS=$CONNECT_URL" >>$CREDENTIALS_FILE
					echo "Sucessfully added credentials to $CREDENTIALS_FILE"
				fi
				exit
				;;
			
			# adding a user requires a dbURL, username, pass, database name and roles
			add-user)
			shift 1
			if [ "$1" != "--use" ] && [ "$3" != "--user" ] && [ "$5" != "--pass" ] && [ "$7" != "--db" ] && [ "$9" != "--roles" ]
			then
				echo "Correct usage for adding a user is: add-user --use 'dburl' --user 'username' --pass 'password' --db 'database' --roles 'role1,role2'"
				exit 1
			else
				shift 1
				DBALIAS=$1
				# this is where we should see if the alias can be found
				if TEMP=`grep $DBALIAS $CREDENTIALS_FILE` 
				then
					# basically, keep everything after the last = character, in this case it's our db string for connecting.
					TEMP=${TEMP##*=}
					echo "$TEMP"
				else
					echo "Database URL not found, please use add-cred for adding mongo urls"
					exit 1
				fi
				#This point we know that we have the URL so we grab everything else
				shift 2
				USER=$1
				shift 2
				PASS=$1
				shift 2
				DBNAME=$1
				shift 2
				#reads the roles into the ROLES array comma delimited.
				IFS=', ' read -ra ROLES <<<"$1"
				#We want to build a string with commas, so we restore to previous state
				IFS=$prevIFS
				
				ROLE_STRING=""
				COUNTER=1
				for i in ${ROLES[@]}
				do
					if [ $COUNTER == ${#ROLES[@]} ];
					then
						ROLE_STRING=$ROLE_STRING"'$i'"
					else 
						ROLE_STRING=$ROLE_STRING"'$i',"
						((COUNTER++))
					fi
				done
				echo $ROLESTR
				# lee=${ROLES[0]}
				# ROLES[0]="'$lee'"
				# lee=${ROLES[1]}
				# ROLES[1]="'$lee'"
				# poll=""
				# echo $poll
				# poll=$poll"'hello',"
				# echo $poll
				# poll=$poll"'world',"
				# echo $poll
				# # ROLES <<< echo $(printf "'%s'" "${ROLES[@]}")
				# echo ${ROLES[0]}
				# echo ${ROLES[1]}
				# q="'readWrite','dbAdmin'"
				# echo $q
				#finally, excute the mongo command to add a user
				mongo $TEMP --eval "db.getSiblingDB('$DBNAME').createUser({ user: '$USER', pwd: '$PASS', roles: [$ROLE_STRING] });"
			fi
			exit
		esac
done