# escape=`

ARG BASE_IMAGE
ARG SOLUTION_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${BASE_IMAGE} AS prep
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./server /temp/
COPY ./docker /temp/docker
RUN Invoke-Expression 'robocopy C:/temp/src C:/serialization/src /s /ndl /njh /njs *.module.json'
RUN Invoke-Expression 'robocopy C:/temp C:/serialization /s /ndl /njh /njs sitecore.json'
RUN Invoke-Expression 'robocopy C:/temp/.config C:/serialization/.config /s /ndl /njh /njs dotnet-tools.json'
RUN Invoke-Expression 'robocopy C:/temp/docker/build/items C:/serialization /s /ndl /njh /njs Entry.ps1'
RUN C:/temp/docker/build/items/CopyItems.ps1

# Save the artifacts for copying into other images (see 'cm' and 'rendering' Dockerfiles).
FROM ${BASE_IMAGE}

ARG JFROG_USERNAME
ARG JFROG_PASSWORD

ENV JFROG_USERNAME=$JFROG_USERNAME
ENV JFROG_PASSWORD=$JFROG_PASSWORD

WORKDIR /artifacts

# Copy content packages from solution build
COPY --from=solution /artifacts/sitecore/App_Data/SitecorePackages ./SitecorePackages

# Copy final build artifacts
COPY --from=prep ./serialization  ./

ENTRYPOINT ["powershell.exe", ".\\Entry.ps1"]