# Monitor configuration managment differences with RedHat Satellite 5.x
#!/bin/sh

COLUMN=rhn		# Name of the column
COLOR=green		# By default, everything is OK

RHNVERIFY=$(sudo /usr/bin/rhncfg-client verify 2>&1|/bin/grep -v "^[ ]\+\/" 2>&1)

outputLines=$(echo "$RHNVERIFY"|wc -l)

if [ $outputLines -eq 1 ]; then
	MSG="Configuration is clean."
else
	RHNDIFF=$(sudo /usr/bin/rhncfg-client diff -d  2>&1)
	MSG="Configuration dffers with server. $outputLines"
	COLOR=red
fi

# Tell Xymon about it
$XYMON $XYMSRV "status $MACHINE.$COLUMN $COLOR `date`

RedHat Satellite status

${MSG}

${RHNVERIFY}

${RHNDIFF}
"

exit 0
