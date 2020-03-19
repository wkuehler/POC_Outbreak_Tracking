# POC Outbreak Tracking
My goals for this proof of concept was to demonstrate how to use Chart.js within Aura Lightning Components.  Given current events, i decided to use COVID-19 infection data from the Commonwealth of Pennsylvania for my dataset.  The final result can be seen in the following public community here:  https://rha-outbreak-tracking-developer-edition.na111.force.com/s/

![image](https://user-images.githubusercontent.com/1509672/77087221-3e2a4a00-69d9-11ea-8f85-5da916c8fc9f.png)

## Part 1: Creating the Infection Metrics custom object
This is the object that will hold all of our data.  Each record contains the Date, State, County, number of Infections and number of Deaths.  I created a custom tab and basic list views for this object as well.

## Part 2:  Uploading the Chart.js static resource
This is the Javascript library that we will use to render our chart.  In this example, we are using v2.3.0 which can be downloaded directly from https://www.chartjs.org/

## Part 3:  Creating our Aura Lightning Component
While i think that the component is pretty straight forward, it could absolutely be simplified by combining all methods into the doInit controller method and doing away with the helper altogether.  That said, i though that keeping everything separated would allow for easy expansion later.

### Component
We create an attribute that will hold the data retrieved from our controller.  Notice that the type is Object.
```html
<aura:attribute access="private" name="infectiondata" type="Object" />
```

We load our static resource which contains the chart.js javascript library.  Once the library is loaded, we call our component controller's doInit method
```html
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
The controller contains a single function, doInit(), which calls our getInfectionData_js() helper function.
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
This is where we execute the callout to our auraenabled apex controller method. If the call is successful, we set our infectiondata component attribute and then call the buildStackedBar function.
```javascript
var infectiondata = response.getReturnValue();
cmp.set("v.infectiondata", infectiondata);
this.buildStackedBar(cmp);
```

#### buildStackedBar()
This function is where we actually build our stacked bar chart.  First, we get our infectiondata attribute and put it into a local variable:
```javascript
var infectiondata = cmp.get("v.infectiondata");
```

These two lines convert our serialized json into separate labels and data objects that we can work with:
```javascript
var datas = JSON.parse(infectiondata.datas);
var labels = JSON.parse(infectiondata.labels);
```

We then iterate through our data and build the dataset that is needed for our chart:
```javascript
var datasets = [];

Object.keys(datas).forEach(function (item) {
    datasets.push(datas[item]); // value
});
```

Before we create our chart, we need to find the html component that it will hold it
```javascript
var ctx = cmp.find("stackedbarchart").getElement();
```

Then, finally, we construct our chart.js chart.
```javascript
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
```




## Apex Controller - InfectionMetricsController.cls

Our apex controller contains several key parts:

#### Metrics() subclass
This is where we will store the data for each county
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
While we could hardcode a list of colors for each county in our dataset, this is not a very scalable option if we wanted to add additional states later.  For this reason, I created the following method to generate a random hexidecial color code for each county data set
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

#### getInfectionData() method
This is the auraEnabled method that we are calling from out lightning component.  We begin by querying our data.  The order by clause is important to ensure that data displays in the same order in each stacked bar.
```javascript
List<Infection_Metric__c> ims = [SELECT Id, Name, County__c, State__c, Infections__c, Deaths__c, Date__c
                                 FROM Infection_Metric__c
                                 ORDER BY Date__c, State__c, County__c];
```

We then generate unique sets of Dates and Counties
```javascript
Set<Date> datesset = new Set<Date>();
Set<String> counties = new Set<String>();
for(Infection_Metric__c im : ims) {
    datesset.add(im.Date__c);
    counties.add(im.County__c);
}
```

We then convert our unique set of dates to an ordered list.
```javascript
List<Date> dateslist = new List<Date>(datesset);
dateslist.sort();
```

We then create our final data structure and initialize all data values to zero.
```javascript
Map<String, Metrics> metriclist = new Map<String, Metrics>();

for(String county : counties) {
    List<Integer> tempints = new List<Integer>();
    for(Date d : dateslist) {
        tempints.add(i);
    }

    metriclist.put(county, new Metrics(county, hexCodeGenerator(), tempints));
}
```

Note that we use a map for the final data structure so that we can easily determine which Metric object relates to each County
```javascript
metriclist.put(county, new Metrics(county, hexCodeGenerator(), tempints));
```

We then iterate through our list of infection metrics that we queried earlier and update our data structure with the actual Infection__c values.
```javascript
for(Infection_Metric__c im : ims) {
    metriclist.get(im.County__c).data[dateslist.indexOf(im.Date__c)] = Integer.valueOf(im.Infections__c);
}
```

Finally, we serialize our objects into strings and return them to our lightning component
```javascript
Map<String, String> labelsandmetrics = new Map<String, String>();
labelsandmetrics.put('labels', JSON.serialize(dateslist));
labelsandmetrics.put('datas', JSON.serialize(metriclist));

return labelsandmetrics;
```
