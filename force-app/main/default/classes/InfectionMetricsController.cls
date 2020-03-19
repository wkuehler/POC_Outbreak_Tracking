public class InfectionMetricsController {   
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



    @auraEnabled
    public Static Map<String, String> getInfectionData(){
        
        //Get all of our infection records
        List<Infection_Metric__c> ims = [SELECT Id, Name, County__c, State__c, Infections__c, Deaths__c, Date__c
                                         FROM Infection_Metric__c
                                         ORDER BY Date__c, State__c, County__c];
        
        //Build a set of unique dates and counties
        Set<Date> datesset = new Set<Date>();
        Set<String> counties = new Set<String>();
        for(Infection_Metric__c im : ims) {
            datesset.add(im.Date__c);
            counties.add(im.County__c);
        }
        
        //Convert our date set to an ordered list
        List<Date> dateslist = new List<Date>(datesset);
        dateslist.sort();

        //Create and generate our list 
        Map<String, Metrics> metriclist = new Map<String, Metrics>();

        for(String county : counties) {
            Integer i = 0;
            List<Integer> tempints = new List<Integer>();
            for(Date d : dateslist) {
                tempints.add(i);
                i++;
            }

            metriclist.put(county, new Metrics(county, hexCodeGenerator(), tempints));
        }

        for(Infection_Metric__c im : ims) {
            metriclist.get(im.County__c).data[dateslist.indexOf(im.Date__c)] = Integer.valueOf(im.Infections__c);
        }

        Map<String, String> labelsandmetrics = new Map<String, String>();
        labelsandmetrics.put('labels', JSON.serialize(dateslist));
        labelsandmetrics.put('datas', JSON.serialize(metriclist));
        
        return labelsandmetrics;
    }
    
}