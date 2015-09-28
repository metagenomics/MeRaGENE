d3.tsv("overview_new.txt", function (error, data) {

    var table = $('#table'),
        aggregateData = function(data) {

            var aggregation = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

            for(var i in data) {
                var id = data[i].Identity;
                switch (true) {
                    case id <= 10:
                        aggregation[0]++;
                        break;
                    case id <= 20:
                        aggregation[1]++;
                        break;
                    case id <= 30:
                        aggregation[2]++;
                        break;
                    case id <= 40:
                        aggregation[3]++;
                        break;
                    case id <= 50:
                        aggregation[4]++;
                        break;
                    case id <= 60:
                        aggregation[5]++;
                        break;
                    case id <= 70:
                        aggregation[6]++;
                        break;
                    case id <= 80:
                        aggregation[7]++;
                        break;
                    case id <= 90:
                        aggregation[8]++;
                        break;
                    case id <= 100:
                        aggregation[9]++;
                        break;
                    default:
                        break;
                }
            }
            return aggregation;
        },
        headerColumns = $.map(Object.keys(data[0]),
            function (val) {
                return "<th data-field='" + val + "' data-sortable='true' >" + val + "</th>";
            }), transformedData =  aggregateData(data),
            xAxis = ['x', '0-10', '10-20', '20-30', '30-40', '40-50', '50-60', '60-70', '70-80', '80-90', '90-100'];

    transformedData.unshift("data");
    table.find("tr").html(headerColumns);

    var chart = c3.generate({
        bindto: '#chart',
        data: {
            x : 'x',
            columns: [xAxis, transformedData],
            type: 'bar'
        },
        axis:{
            x: {
                type: 'category',
                label: {
                    text: 'hits identity to pHMM [%]',
                    position: 'outer-right'
                }
            },
            y: {
                label: {
                    text: 'Number of hits',
                    position: 'outer-top'
                }
            }
        },
        bar: {
            width: {
                ratio: 0.5
            }
        }
    });

    table.bootstrapTable({data: data});
});