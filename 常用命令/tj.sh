cat 0055.src | awk -F '|' '{ print "," $10 "," $13}' | sort | uniq -c > 0055.csv
