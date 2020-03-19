({
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
    },


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
})