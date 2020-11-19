FROM mcr.microsoft.com/azure-cli

LABEL maintainer="Alex Pullen <catilre@gmail.com>"

WORKDIR /work

ENV TENANT_ID='123987654321'
ENV SUBSCRIPTION_ID='1234567890854321'
ENV USERNAME='application-id'
ENV PASSWORD='client-secret'
ENV GITHUB_REPO_URL='acme-org/some-repo'
ENV GITHUB_TOKEN='some-secret-personal-access-token'
ENV GITHUB_EMAIL='devops@acme.org'
ENV GITHUB_NAME='Acme Devops'

RUN mkdir -p /work/data

VOLUME /work/data/

COPY pushLogicAppsToGithub.sh .

CMD /work/pushLogicAppsToGithub.sh
