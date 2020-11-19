#!/bin/bash

resource="https://management.azure.com"
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

cd /work/data

# login using predefined service principal
echo `date` '-------> Authenticating with az'
az login --service-principal -u ${USERNAME} -p ${PASSWORD} --tenant ${TENANT_ID} --only-show-errors

# get auth token for rest api calls
echo `date` '-------> Getting access token'
auth_token=`az account get-access-token --resource=${resource} --query accessToken --output tsv --only-show-errors`

# check if logic app files have been mounted in else pull the repo.
if [[ ! -d .git ]]; then
    echo `date` '-------> Cloning repo'
    git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO_URL} .
    git config user.email "${GITHUB_EMAIL}"
    git config user.name "${GITHUB_NAME}"
else
    echo `date` '-------> Pulling latest'
    git pull origin main
fi

# populate logicApps file if it has not been mounted in for debugging
if [[ ! -f ../logicApps.txt ]]; then
    echo `date` '-------> Fetching logicApps list'
    az resource list  --resource-type 'Microsoft.Logic/workflows' --query "[].{resource:resourceGroup, name:name}" -o table | grep -v 'Resource' | grep -v "\-\-" > logicApps.txt
else
    echo `date` '-------> Found logicApps list'
    cp ../logicApps.txt .
fi

# iterate through logicApps list
echo `date` '-------> Processing ' `cat logicApps.txt | wc -l` ' logicApp(s)'
while IFS= read line
do
	#echo ${line}
	resG=`echo $line | awk '{print $1}'`
	name=`echo $line | awk '{print $2}'`

	uri="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${resG}/providers/Microsoft.Logic/workflows/${name}"

    # get json output
    extract=`curl -s --location --request GET "${resource}${uri}?api-version=2016-06-01" --header "Authorization: Bearer ${auth_token}"`

    mkdir -p ${resG}

    echo ${extract} | jq '.name'
    
    # write json output to resourceGroup/LogicAppName.json
    echo ${extract} | jq '{"definition":.properties.definition, "parameters":.properties.parameters, "changedTime":.properties.changedTime, "tags":.tags, "version":.properties.version}' > ${resG}/${name}.json

    # check for file changes and push to github
    if ! git status ${resG}/${name}.json | grep 'nothing to commit'; then
        version=`echo ${extract} | jq '.properties.version'`
        git add ${resG}/${name}.json && git commit -m "${resG} - ${name} - ${version}" && git push --set-upstream origin
    fi

done < logicApps.txt
echo `date` '-------> All done - Processed ' `ls **/*.json |grep json| wc -l` ' logicApp(s)'
