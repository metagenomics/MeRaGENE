d3.tsv("overview_new.txt", function(error, data) {

    var table = $('#table'),
    headerColumns = $.map( Object.keys(data[0]), function(val) {
        return "<th data-field='" + val + "' data-sortable='true' >" + val + "</th>";
    });

    table.find("tr").html(headerColumns);
    table.bootstrapTable({data: data});
});