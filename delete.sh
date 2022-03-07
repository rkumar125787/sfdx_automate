#Preparing the metadata exclusion list

MDT="classes"
echo "$MDT"
INCLUSIONLIST=""
inclusionarr=$(echo $MDT | tr "," "\n")
for mdt in $inclusionarr
do
    FILENAME="force-app/main/default/$mdt"
    INCLUSIONLIST="$INCLUSIONLIST $FILENAME"
done

echo $INCLUSIONLIST

#*****Checkout to Git Source Branch and Find the difference of a file in comma seprated way
git checkout master
git  diff --diff-filter=D --name-status origin/master...origin/sfdx $INCLUSIONLIST
git  diff --diff-filter=D --name-only origin/master...origin/sfdx $INCLUSIONLIST | tr '\n' ',' | sed 's/\(.*\),/\1 /' > delDir.txt
#Check if difference exist using file contents
if [ -s delDir.txt ]
then
       #Check the deploymode if it is through package.xml or path
    git diff --diff-filter=D --name-only --pretty="" origin/master...origin/devlop $INCLUSIONLIST | paste -d, -s - | xargs -0 ${sfdx} force:source:convert -r force-app -d delDir -p
    ls -la delDir/classes
    #echo "*****Begin Package.xml*******"
    mv delDir/package.xml delDir/destructiveChanges.xml
    echo '<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <version>54.0</version>
</Package>' > delDir/package.xml

    cat delDir/destructiveChanges.xml
    echo "-----------------------------------"
    cat delDir/package.xml
    mkdir dpl
    cp delDir/destructiveChanges.xml dpl/destructiveChanges.xml
    cp delDir/destructiveChanges.xml dpl/package.xml
    #echo "*****End Package.xml*******"
    ${sfdx} force:mdapi:deploy -d dpl -u rajeshkumar15191@gmail.com.idp -w 40
    if [ $? -eq 0 ]; then
        echo -e "\e[32m************************** Success **************************"
    else
       echo -e "\e[31m************************** Error **************************"
    fi
else
       echo "No Changes found between master ➔ devlop"
       exit 1
fi


