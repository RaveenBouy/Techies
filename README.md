# <center> **Techies** </center>

1.0 Introduction
-------------
Cloud computing is a recent technology paradigm aimed at providing Information Technology on-demand services. Aspects of scalability, elasticity, payment based on usage are the main reasons for the successful widespread adoption of cloud infrastructures. Cloud computing model aims to provide two beneﬁts: cost reduction and ﬂexibility. The ﬁrst one consists in to reduce the cost of acquisition and composition of all infrastructure required to meet the needs of businesses. Thereby, our clients do not need to acquire a complex infrastructure to host their applications. As we(Techies) have been providing client solutions around the globe for over 4 years, we promise to provide a world class customer experience. 


-------------

2.0 Conceptual architecture model
-------------


![](https://i.imgur.com/VLI7sTP.png) <center> Fig:1.1 - Architecture model </center>

The proposed conceptual solution architecture is based on a simplified yet
holistic approach towards an unintrupted solution that can scale according to the client's requirements.

**<H3><u>Architecture Breakdown</u></H3>**

The architecture has the following components:

- **Resource Group**: A resource group is a logical container for Azure resources.

- **App Service plan**: An App Service plan provides the managed virtual machines (VMs) that host your app. All apps associated with a plan run on the same VM instances. Therefore, In-order to deploy a service app, it is essential to configure the App Service plan first. 

- **Application Gateway**: Azure Application Gateway is a web traffic load balancer that enables the user to manage web applications. 

- **App Service app**: Azure App Service is a fully managed platform for creating and deploying cloud applications. Ability to use either docker containers or bare code. The application build for this scenario is based on Node.JS and is deployed as a docker container which could only be accessible by port 80.

- **Azure SQL Database**: SQL Database is a relational database-as-a-service in the cloud. SQL Database shares its code base with the Microsoft SQL Server database engine. Depending on your application requirements, you can also use Azure Database for MySQL or Azure Database for PostgreSQL. These are fully managed database services, based on the open-source MySQL Server and Postgres database engines, respectively.

- **Azure Virtual Network (VNet)**: Azure VNet is the fundamental building block for private IP network in azure. VNet brings with it additional benefits of Azure's infrastructure such as scale, availability, and isolation.

- **VPN Gateway**: A VPN gateway is a specific type of virtual network gateway that is used to send encrypted traffic between an Azure virtual network and an on-premises location over the public Internet. In this scenario, a VPN is established between the MySQL database and the on-premises to access the database.

3.0 Implementation through Terraform
-------------
**What is Terraform?**

- Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

**Why use Terraform?**
- Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

- The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

- Terraform was used for the implementation of this infrastructure as per the reasons mentioned above. 
  
<u>Sample code snippet</u>

```HCL
#Service plan
resource "azurerm_app_service_plan" "Techies-sp" {
  name                = "Techies-sp"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  reserved = true 
  kind = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

#App Service
resource "azurerm_app_service" "Techies-as" {
  name                = "Techies-as"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.Techies-sp.id}"

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|ravianxreaver/testnodeapp"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
  }
}
```
Snippet:1.0


The sample code snippet is responsible for creating a Service plan named as "Techies-sp" with a sku of S1 Standard.
```HCL
#Service plan
resource "azurerm_app_service_plan" "Techies-sp" {
  name                = "Techies-sp"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  reserved = true 
  kind = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }
}
```
Snippet:1.1


The sample code snippet creates a web app service using the service plan("Techies-sp") which is created by the code snippet:1.1
```HCL
#App Service
resource "azurerm_app_service" "Techies-as" {
  name                = "Techies-as"
  location            = "${azurerm_resource_group.Techies-rg.location}"
  resource_group_name = "${azurerm_resource_group.Techies-rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.Techies-sp.id}"

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|ravianxreaver/testnodeapp"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
  }
}
```
Snippet:1.2
