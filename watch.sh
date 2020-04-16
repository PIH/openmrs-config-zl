
# NOTE: this "watchs" the directory and rebuilds on changes, so it will run indefinitely until you "Ctrl-C"

if [ $# -eq 0 ]; then
    echo "Please provide the name of the server to install to as a command line argument"
    echo "For example: './install.sh mirebalais'"
    exit 1
fi

# if there's a "config-pihemr" or "openmrs-config-pihemr" directory at the same level as this project,
# run the watch for it as well
if [[ -f '../config-pihemr/watch.sh' ]]; then
    (cd ../config-pihemr && ./watch.sh &)
elif [[ -f '../openmrs-config-pihemr/watch.sh' ]]; then
    (cd ../openmrs-config-pihemr && ./watch.sh &)
else
  echo "Unable to find PIH-EMR config, skipping watching it"
fi

mvn clean openmrs-packager:watch -DserverId=$1 -DdelaySeconds=1
