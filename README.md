# POC Outbreak Tracking

My goals for this proof of concept was to demonstrate how to use Chart.js within Aura Lightning Components.  Given current events, i decided to use COVID-19 infection data from the Commonwealth of Pennsylvania for my dataset.

## Part 1: Creating the Infection Metrics custom object

This is the object that will hold all of our data.  Each record contains the Date, State, County, number of Infections and number of Deaths.  I created a custom tab and basic list views for this object as well.

## Part 2:  Uploading the Chart.js static resource

This is the Javascript library that we will use to render our chart.  In this example, we are using v2.3.0 which can be downloaded directly from https://www.chartjs.org/

## Part 3:  Creating our Aura Lightning Component

### Component

The component is pretty straight forward:  

We create an attribute that will hold the data retrieved from our controller.  Notice that the type is Object.
```
<aura:attribute access="private" name="infectiondata" type="Object" />
```

We load our static resource which contains the chart.js javascript library.  Once the library is loaded, we call our component controller's doInit method
```
<ltng:require scripts="{!$Resource.ChartJS23}" afterScriptsLoaded="{!c.doInit}" />
```

Finally, we create the neccessary markup to display our actual chart
```html
<lightning:card>
  <div>
    <div class="slds-text-heading--medium">Infections / Deaths Bar</div>
    <canvas aura:id="stackedbarchart" height="380"></canvas>
  </div>
</lightning:card>
```

### Component Controller
The controller is pretty straight forward and only contains our doInit method which calls our getInfectionData_js() helper method
```javascript
({
    doInit : function(cmp, event, helper) {
        helper.getInfectionData_js(cmp); 
    }
})
```


### Component Helper

Our helper contains two methods:

#### getInfectionData_js()
Calls our Apex controller to get the data 
```javascript
getInfectionData_js : function(cmp) {
    var action = cmp.get("c.getInfectionData");
    
    action.setCallback(this, function(response) {
        var state = response.getState();
        
        if (cmp.isValid() && state === "SUCCESS") {
            var infectiondata = response.getReturnValue();
            cmp.set("v.infectiondata", infectiondata);
            this.buildStackedBar(cmp);
        }
        else if (cmp.isValid() && state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message)
                    console.log("Error message: " + errors[0].message);
            }
            else
                console.log("Unknown error");
        }
    });
    
    $A.enqueueAction(action);
}
```


and buildStackedBar() which actually constructs our stacked bar chart.



### Org Development Model

The org development model allows you to connect directly to a non-source-tracked org (sandbox, Developer Edition (DE) org, Trailhead Playground, or even a production org) to retrieve and deploy code directly. This model is similar to the type of development you have done in the past using tools such as Force.com IDE or MavensMate.

To start developing with this model in Visual Studio Code, see [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model). For details about the model, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) Trailhead module.

If you are developing against non-source-tracked orgs, use the command `SFDX: Create Project with Manifest` (VS Code) or `sfdx force:project:create --manifest` (Salesforce CLI) to create your project. If you used another command, you might want to start over with this command to create a Salesforce DX project.

When working with non-source-tracked orgs, use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy` (Salesforce CLI) and `SFDX: Retrieve Source from Org` (VS Code) or `sfdx force:source:retrieve` (Salesforce CLI). The `Push` and `Pull` commands work only on orgs with source tracking (scratch orgs).

## The `sfdx-project.json` File

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

The most important parts of this file for getting started are the `sfdcLoginUrl` and `packageDirectories` properties.

The `sfdcLoginUrl` specifies the default login URL to use when authorizing an org.

The `packageDirectories` filepath tells VS Code and Salesforce CLI where the metadata files for your project are stored. You need at least one package directory set in your file. The default setting is shown below. If you set the value of the `packageDirectories` property called `path` to `force-app`, by default your metadata goes in the `force-app` directory. If you want to change that directory to something like `src`, simply change the `path` value and make sure the directory you’re pointing to exists.

```json
"packageDirectories" : [
    {
      "path": "force-app",
      "default": true
    }
]
```

## Part 2: Working with Source

For details about developing against scratch orgs, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) module on Trailhead or [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model).

For details about developing against orgs that don’t have source tracking, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) module on Trailhead or [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model).

## Part 3: Deploying to Production

Don’t deploy your code to production directly from Visual Studio Code. The deploy and retrieve commands do not support transactional operations, which means that a deployment can fail in a partial state. Also, the deploy and retrieve commands don’t run the tests needed for production deployments. The push and pull commands are disabled for orgs that don’t have source tracking, including production orgs.

Deploy your changes to production using [packaging](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm) or by [converting your source](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_source.htm#cli_reference_convert) into metadata format and using the [metadata deploy command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_mdapi.htm#cli_reference_deploy).