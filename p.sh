TARGET_ENV=rajeshkumar15191@gmail.com.idp
SOURCE_PATH=force-app

# constants
API_VERSION=52.0 # api version (same as in the sfdx-project.json)
DEFAULT_TEST_CLASS=MyTestClass # a passing test class

echo "Clean existing destructivePackage folder"
rm -rf deployment/destructivePackage &>/dev/null
mkdir -p deployment/destructivePackage &>/dev/null

echo "Converting Source format to Metadata API format"
sfdx force:source:convert -p ${SOURCE_PATH} -d deployment/destructivePackage

# copy package.xml to desctructiveChanges.xml
cp deployment/destructivePackage/package.xml deployment/destructivePackage/destructiveChanges.xml

# generate an empty (containing only the api version tag) package.xml
cat <<EOT > <?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <version>52.0</version>
</Package>
EOT

# deploying to the target org
echo "Deploying a destructive change to ${TARGET_ENV}"
echo "In Progress..."
sfdx force:mdapi:deploy -d deployment/destructivePackage -u ${TARGET_ENV} -l RunSpecifiedTests -r ${DEFAULT_TEST_CLASS} -w -1
if [ $? -eq 0 ]; then
    # green color
    echo -e "\e[32m************************** Success **************************"
else
    # red color
    echo -e "\e[31m************************** Error **************************"
fi