
# get number of processes to run from cmd line

if [ -z $1 ]; then
	#default to 5
	MAX_CHILD_COUNT=5
else
	MAX_CHILD_COUNT=$1
fi

echo Running $MAX_CHILD_COUNT children

# force parent to wait
touch ./child.lock

. ./th.conf

unset SQLPATH

CHILD_COUNT=0
while [ $CHILD_COUNT -lt $MAX_CHILD_COUNT ]
do
	(( CHILD_COUNT = CHILD_COUNT + 1))
	sqlplus -s $USERNAME/$PASSWORD@$DATABASE @thc1.sql $CHILD_COUNT 2>/dev/null &
done

CHILD_COUNT=0
while [ $CHILD_COUNT -lt $MAX_CHILD_COUNT ]
do
	(( CHILD_COUNT = CHILD_COUNT + 1))
	LOCK_FILE=child_${CHILD_COUNT}.lock
	while [ ! -f $LOCK_FILE ]
	do
		sleep 1;
	done
	rm $LOCK_FILE
done

# only remove main lock file after all child lock
# files removed
rm ./child.lock


