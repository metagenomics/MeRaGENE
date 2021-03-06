
var linkFormatter = function(value, row){
        var path = window.location.href + "/../" + row['Gene ID'] + ".html";
        return '<a href='+ path +'>' + value + '</a>';
    }, seqFormatter = function(value, row, idx){
        return '<button id="' + idx + '" class="btn btn-primary">Show Sequence</button>';
    }, setUpNavbar = function(){

    var navbar = $('#navbar-main'),
        distance = navbar.offset().top,
        $window = $(window);

    $window.scroll(function() {
        if ($window.scrollTop() >= distance) {
            navbar.removeClass('navbar-fixed-top').addClass('navbar-fixed-top');
            $("body").css("padding-top", "70px");
        } else {
            navbar.removeClass('navbar-fixed-top');
            $("body").css("padding-top", "0px");
        }
    });
};

d3.tsv("overview_new.txt", function (error, data) {

    var table = $('#table'),
        isInRange = function(lower, value){
            var lowerPoint = lower * 10,
                upperPoint = lower * 10 + 10;

            if(value > lowerPoint && value <= upperPoint){
                return true;
            } else {
                return false;
            }
        },
        onBarClick = function(d,element){
            var lowerPoint = d.index,
                isSelected = d3.select(element).classed("_selected_");
            if(!isSelected) {
                $('#table').bootstrapTable('load', data);
            } else {
                $('#table').bootstrapTable('load', $.grep(data, function (row) {
                    return isInRange(lowerPoint, row["Identity"]);
                }));
            }
        },
        currRow = "",
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
                if(val=="Best blastp hit"){
                    return "<th data-filter-control='input' data-formatter='linkFormatter' data-field='" + val + "' data-sortable='true' >" + val + "</th>";
                } else if(val=="Subject titles") {
                    return "<th data-filter-control='input' class='title-col' data-field='" + val + "' data-sortable='true' >" + val + "</th>";
                } else if(val=="Gene sequence"){
                    return "<th data-formatter='seqFormatter' data-filter-control='input' class='seq-col' data-field='" + val + "' data-sortable='true' >" + val + "</th>";
                } else {
                    return "<th data-filter-control='input' data-align='center' data-field='" + val + "' data-sortable='true' >" + val + "</th>";
                }
            }), transformedData =  aggregateData(data),
            xAxis = ['x', '0-10', '10-20', '20-30', '30-40', '40-50', '50-60', '60-70', '70-80', '80-90', '90-100'];

    transformedData.unshift("data");
    table.find("tr").html(headerColumns);

    var chart = c3.generate({
        bindto: '#chart',
        data: {
            x : 'x',
            columns: [xAxis, transformedData],
            type: 'bar',
            onclick: onBarClick,
            selection: {
                enabled: true,
                multiple: false
            }
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

    $('table').on('click','button',function(event){
        currRow = data[$(event.target).attr('id')];
        $('#seqModal').modal('show').find('#sequences-text').text(currRow['Gene sequence']);
    });

    table.bootstrapTable({data: data});

    setUpNavbar();
});