# Sitecore.DevOps

## Github Workflow Secrets

Current deployment process is designed as multi-environment where each environment have own list of secrets to support deployments into different subscriptions/resource groups/clusters.

The table below is represent a list of required environment secrets:

| Name  | Description | Default value |
| ------------- | ------------- | ------------- |
| AZURE_KV_NAME  | The name for a key vault in the Microsoft Azure Key Vault service.  |   |
| AZURE_KV_TENANT_ID  | Azure Key Vault is always associated with some Subscription. In the same time, each subscription has a tenant ID associated with it, and there are a few ways you can find the tenant ID for your subscription: [Azure documentation](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/how-to-find-tenant) |   |
| CLUSTER_NAME  | Specify names for the Azure Kubernetes Services resource.  |  |
| ENVIRONMENT_NAMESPACE  | Name of kubernetes namespace that Sitecore will be installed to. | default  |
| FEDERATED_IDENTITY_NAME  | Name of federated identity that creates credential between the managed identity, service account issuer, and subject  | aks-federated-identity  |
| RESOURCE_GROUP  | Name of Azure Resource Group where you have created your Kubernetes cluster (AKS). |  |
| SERVICE_ACCOUNT_NAME  | Name of Kubernetes Service account which uses a user assigned identity to to authenticate connection between AKS and Azure Key Vault. | sitecore-default-sa  |
| SUBSCRIPTION_ID  | ID of Subscription where you have created your Resource Group. |   |
| USER_ASSIGNED_IDENTITY_NAME  | Name for user assigned identity. Workloads deployed in Kubernetes clusters require Azure AD application credentials or managed identities to access Azure AD protected resources, such as Azure Key Vault.  | aks_uami  |



| Name  | Description | Default value |
| ------------- | ------------- | ------------- |
| AZURE_CREDENTIALS  | This secret strores service principal json object which is used to authenticate GitHub Actions to communicate with Azure resources. To create a Create a service principal follow the [instructions](README.md#create-a-service-principal).  | Content Cell  |
| CLOUDFLARE_API_TOKEN  | Content Cell  | Content Cell  |

# Create a service principal

In this example, you will create a secret named AZURE_CREDENTIALS that you can use to authenticate with Azure.

1. Open [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview) in the Azure portal or [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) locally.
2. [Create a new service principal](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) in the Azure portal for your app. The service principal must be assigned with an appropriate role.
   
```az ad sp create-for-rbac --name "myApp" --role contributor \
                                --scopes  /subscriptions/{subscription-id} \
                                --json-auth```

The parameter `--json-auth` outputs the result dictionary accepted by the login action, accessible in Azure CLI versions >= 2.51.0. Versions prior to this use `--sdk-auth` with a deprecation warning.

3. Copy the JSON object for your service principal and put into AZURE_CREDENTIALS secret of you repository.

```{
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
}```

4. In addition to above, we need to add extra roles to our Service Principal. Execute the following commands one by one, where {clientId} is and client id from json above:

```az role assignment create --assignee {clientId} --role "Key Vault Administrator" --scope  /subscriptions/{subscription-id}
   az role assignment create --assignee {clientId} --role "Role Based Access Control Administrator (Preview)" --scope  /subscriptions/{subscription-id}
```
