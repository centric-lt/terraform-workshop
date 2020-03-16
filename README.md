# Introduction 
Terraform 101 workshop

# Prerequisites
1. Your favorite terminal (Cmd, Powershell, bash etc.)
2. Service principal keys (will be distributed during event)

# Install Terraform
- Chocolatey users: `choco install terraform`
- Windows alternative: visit [Terraform Download Page](https://www.terraform.io/downloads.html) and pickout version relevant for you
- WSL/Linux Debian: visit https://learn.hashicorp.com/terraform/getting-started/install.html and follow instructions to download Terraform, Unzip, and put in on the PATH

# Setup `PATH` variable (if you installed Terraform manually)
- Windows users in Powershell `$env:PATH += "C:/path/to/your/terraform/binary"`
- Linux users in bash `export PATH="/path/to/your/terraform/binary:$PATH"`

# Install Azure CLI (not mandatory but recommended)
- Windows users `choco install azure-cli`
- Windows alternative `https://aka.ms/installazurecliwindows`
- Linux user `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

# (Optional) Login using Az CLI
- To login to Azure with service principal using CLI type 
```powershell
az login --service-principal -u $clientId -p $clientSecret -t $tenantId
```
- Do note the `id` property we will need it

# Start Terraforming
- Create an empty folder this will contain our terraform project
- Create new file, name it `main.tf`
- Define `provider` block, name it `azurerm` (it has to be exact to work properly)
    - Input `subscription_id`
    - Input `client_id`
    - Input `client_secret`
    - Input `tenant_id`

```
provider "azurerm" {
  key  = "value"
  key2 = "value2"
}
```

- Define few variables `prefix` and `tags`
    - Variable block does not have to contain any arguments although best practice is to maintain them properly
    - Set default value for prefix variable, it has to be something unique for you to know your resource
    - Set the type for variable tags it will be `map(string)`
    - Set default value for tags variable it has to contain `Application`, `CreatedBy`, `Department`, `EnvironmentType` keys

example:
```
variable "server_count" {
  type = map(number)
  default = {
    Dev        = 2
    Test       = 2
    Acceptance = 3
    Production = 3
  }
}
```

- Let's define a data resource to query our resource group
    - Much like before the block is defined similarly, just has more caveat it has an internal name
    - Input the resource group you are working with (given along with service principals)

example:
```
data "azurerm_resource_group" "rg" {
  name = "rg-tf-workshop"
}
```

- In Azure all App Services need a Service Plan let's create that resource
    - Create a `azurerm_app_service_plan` resource, set a short and smart internal name you will need to reference it further on
    - In the new resource we need quite a few variables defined: `name`, `location`, `resource_group_name`, `kind`, `reserved`, `tags`
    - For `name` user variable expresion in a string format to use your defined prefix and attach a string to it `"${var.prefix}-asp"`
    - `kind` has to be set as `"Linux"`
    - `reserved` need to be set to `false`
    - For `location` and `resource_group_name` reference our resource group data resource: `data.azurerm_resource_group.rg.name` for RG name property
    - we need to define `sku` block as well inside `sku` block define `tier` and `size` variables according to the example below

```
resource "azurerm_app_service_plan" "asp" {
  ...
  ...

  sku {
    tier = "Standard"
    size = "S1"
  }
}

```

- Now we can create the App Service itself
    - Define a resource `azurerm_app_service` give it local name of "production"
    - Here we need to define 5 variables: `name`, `location`, `resource_group_name`, `app_service_plan_id`, `tags` and `app_settings` (`app_settings` is a `map` type variable)
    - To reference App Service Plan that we defined earlier type path to it `azurerm_app_service_plan.<APP_SERVICE_PLAN_LOCAL_NAME>.id`
    - `app_settings` variable needs to be defined in a map format (keep it exact as below)
    ```
    app_settings = {
        "DEPLOYMENT_SLOT" = "Production"
    }
    ```
    - In addtion to that we need to define a `site_config` block
        - In it we need to specify what we will deploy in this instance `linux_fx_version = "DOCKER|nilsas/tf-go-docker:71"` (type it exactly as noted)

- Right now we only have Production service slot, let's create one for staging
    - Create a resource `azurerm_app_service_slot` give it a local name of "staging"
    - Variables are similar to the `azurerm_app_service` which we just created
        - We just need to add a reference back to App Service so: `app_service_name = azurerm_app_service.production.name`
        - "DEPLOYMENT_SLOT" variable value now needs to be "Staging"
    - Everything else should look like the App Service we defined in previous step

- Lets define Outputs
    - Defining `output` blocks helps us retrieve information from Terraform state after it finished building our resources
    ```
    output "app_service_default_hostname" {
      value = "https://${azurerm_app_service.production.default_site_hostname}"
    }

    output "app_service_slot_hostname" {
      value = "https://${azurerm_app_service_slot.staging.default_site_hostname}"
    }
    ```

- Now that we have our code written let's run it
    - Open terminal
    - Navigate to your project folder
    - Run `terraform init`
    - Run `terraform plan`
    - Review the plan in the console
    - Run `terraform apply`
    - When prompted for input, type `yes`
    - Wait until Terraform finishes
    - Visit the URLs outputed by terraform
    - Production App Service should clearly state that it is in Production slot
    - Staging App Service slot should be accessible and state that it is a Staging slot


### BONUS

- For bonus task we should be done with main procedure
- Create additional resource in our main.tf called `azurerm_app_service_active_slot`
    - It requires only 3 variables `resource_group_name`, `app_service_name` and `app_service_slot_name`
    - Use referencing techniques to correctly reference our resources
    - Run `terraform plan`
    - Review the plan output
    - Run `terraform apply` you can use argument `-auto-approve` to force through the prompt (only use when you really know what you're doing)
    - Visit the URLs for our app services again, now we have Production URL saying it is in Staging deployment slot, which means we successfully promoted Staging slot to Production

## To Cleanup run `terraform destroy`

## Thank you for attending this workshop!