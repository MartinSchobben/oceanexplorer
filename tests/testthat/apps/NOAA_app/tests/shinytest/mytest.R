app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

app$snapshot()
app$setInputs(`NOAA-go` = "click")
# Input 'waiter_shown' was set, but doesn't have an input binding.
# Input 'waiter_hidden' was set, but doesn't have an input binding.
app$snapshot()
# Input '`worldmap-plot_click`' was set, but doesn't have an input binding.
# Input '`worldmap-plot_click`' was set, but doesn't have an input binding.
# Input '`worldmap-plot_click`' was set, but doesn't have an input binding.
# Input '`table-table_rows_current`' was set, but doesn't have an input binding.
# Input '`table-table_rows_all`' was set, but doesn't have an input binding.
# Input '`table-table_state`' was set, but doesn't have an input binding.
app$snapshot()
