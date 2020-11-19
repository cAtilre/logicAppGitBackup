# Logic App backup tool
![Docker Pulls](https://img.shields.io/docker/pulls/catilre/logicappbackup.svg)

This is a docker container that will fetch all logic apps from a specified Azure instance and push them into a designated github repository.

## Prerequisits
You are going to need to setup a service principal (App registration is AzureAD) in order for the container to authenticate and access Azure Logic App resources.

Additionally you are going to need to create a Github Personal Access Token to push updates. The token requires repo and user permissions.

## Build the container image

```
docker build .
```

## Run the container

```
docker run --rm --name logicAppBackup \
-e TENANT_ID='acme-tenant-id' \
-e SUBSCRIPTION_ID='acme-sub-scrip-tion-id' \
-e USERNAME='app-lica-tion-id' \
-e PASSWORD='cli-ent-sec-ret' \
-e GITHUB_REPO_URL='github-url-to-backup-to.git' \
-e GITHUB_TOKEN='yousupersecretgithubpat' \
-e GITHUB_EMAIL='devops@acme.org' \
-e GITHUB_NAME='Acme DevOps' \
catilre/logicappbackup:latest
```

To persist the logic app data across runs, add a working folder volume/bind like this
```
-v ${PWD}/tmp:/work/data/ \
```

To debug with a smaller set of logicApps bind mount file in like this:
```
-v ${PWD}/logicApps.txt:/work/logicApps.txt \
```
