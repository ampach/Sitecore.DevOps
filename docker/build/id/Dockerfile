# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${PARENT_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR C:\Identity

# Copy identity artifacts
COPY --from=solution /artifacts/identity/ ./

USER ContainerUser

ENTRYPOINT ["dotnet", "Sitecore.IdentityServer.Host.dll"]