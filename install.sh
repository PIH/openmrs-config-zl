if [ $# -eq 0 ]; then
    echo "Please provide the name of the server to install to as a command line argument"
    echo "For example: './install.sh mirebalais'"
    exit 1
fi

# if there's a "config-pihemr" or "openmrs-config-pihemr" directory at the same level as this project,
# run the install for it
if [[ -f '../config-pihemr/install.sh' ]]; then
    (cd ../config-pihemr && ./install.sh)
elif [[ -f '../openmrs-config-pihemr/install.sh' ]]; then
    (cd ../openmrs-config-pihemr && ./install.sh)
else
  echo "Unable to find PIH-EMR config, skipping building it"
fi

mvn clean compile -DserverId=$1
