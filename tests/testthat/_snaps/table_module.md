# table out is formatted correctly

    Code
      output$table
    Output
      {"x":{"filter":"none","vertical":false,"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>oxygen<\/th>\n      <th>depth<\/th>\n      <th>coordinates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"serverSide":true,"processing":true},"selection":{"mode":"multiple","selected":null,"target":"row","selectable":null}},"evals":[],"jsHooks":[],"deps":[{"name":"jquery","version":"3.6.0","src":{"href":"jquery-3.6.0"},"meta":null,"script":"jquery-3.6.0.min.js","stylesheet":null,"head":null,"attachment":null,"all_files":true},{"name":"dt-core","version":"1.11.3","src":{"href":"dt-core-1.11.3"},"meta":null,"script":"js/jquery.dataTables.min.js","stylesheet":["css/jquery.dataTables.min.css","css/jquery.dataTables.extra.css"],"head":null,"attachment":null,"package":null,"all_files":false},{"name":"crosstalk","version":"1.2.0","src":{"href":"crosstalk-1.2.0"},"meta":null,"script":"js/crosstalk.min.js","stylesheet":"css/crosstalk.min.css","head":null,"attachment":null,"all_files":true}]} 

# reformatted table works

    Code
      format_table(NOAA, "oxygen")
    Output
      # A tibble: 1 x 3
        oxygen depth coordinates    
         <dbl> <dbl> <chr>          
      1   205.    30 POINT (-120 10)

