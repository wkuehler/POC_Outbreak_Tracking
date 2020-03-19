# POC Outbreak Tracking

My goals for this proof of concept was to demonstrate how to use Chart.js within Aura Lightning Components.  Given current events, i decided to use COVID-19 infection data from the Commonwealth of Pennsylvania for my dataset.

![image](https://user-images.githubusercontent.com/1509672/77087221-3e2a4a00-69d9-11ea-8f85-5da916c8fc9f.png)

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


#### buildStackedBar()
Constructs our stacked bar chart.
```javascript
buildStackedBar : function(cmp) {
  var infectiondata = cmp.get("v.infectiondata");

  var datas = JSON.parse(infectiondata.datas);
  var labels = JSON.parse(infectiondata.labels);
  
  var datasets = [];

  Object.keys(datas).forEach(function (item) {
      datasets.push(datas[item]); // value
  });
            
  var ctx = cmp.find("stackedbarchart").getElement();
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: labels,
          datasets: datasets,
      },
      options: {
          tooltips: {
          displayColors: true,
          callbacks:{
              mode: 'x',
          },
          },
          scales: {
          xAxes: [{
              stacked: true,
              gridLines: {
              display: false,
              }
          }],
          yAxes: [{
              stacked: true,
              ticks: {
              beginAtZero: true,
              },
              type: 'linear',
          }]
          },
              responsive: true,
              maintainAspectRatio: false,
              legend: { position: 'right' },
      }
  });       
}
```

### Apex Controller - InfectionMetricsController.cls

Our apex controller contains several key parts:

#### Metrics() subclass
This is where we will store our data for each county
```javascript
public class Metrics {
    String label;
    String backgroundColor;
    List<Integer> data;
    
    public Metrics(String a, String b, List<Integer> c) {
        label = a;
        backgroundColor = b;
        data = c;
    } 
}
```

#### hexCodeGenerator() method
This method is used to generate a random hexidecial color code for each county data set
```javascript
public static String hexCodeGenerator() {
    String hexval = '#';
    for(Integer i = 0 ; i < 6 ; i++) {
        Integer rannum = Integer.valueOf(Math.floor(Math.random()*16));
        String charval = '';
        switch on rannum {
            when 0 { charval = '0'; }
            when 1 { charval = '1'; }
            when 2 { charval = '2'; }
            when 3 { charval = '3'; }
            when 4 { charval = '4'; }
            when 5 { charval = '5'; }
            when 6 { charval = '6'; }
            when 7 { charval = '7'; }
            when 8 { charval = '8'; }
            when 9 { charval = '9'; }
            when 10 { charval = 'a'; }
            when 11 { charval = 'b'; }
            when 12 { charval = 'c'; }
            when 13 { charval = 'd'; }
            when 14 { charval = 'e'; }
            when 15 { charval = 'f'; }
        }
        
        hexval += charval;
    }
    
    return hexval;
}
```
