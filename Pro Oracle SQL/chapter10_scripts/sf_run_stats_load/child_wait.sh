
while :
do
	if [ -f ./child.lock ]; then
		sleep 1;
	else
		exit
	fi
done
