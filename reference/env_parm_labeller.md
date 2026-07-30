# Parsing expressions for plot labels

Conveniently converts NOAA world ocean atlas parameter names into full
oceanographic variable names including units for parsing in plot labels.

## Usage

``` r
env_parm_labeller(var, prefix = character(1), postfix = character(1))
```

## Arguments

- var:

  Environmental parameter.

- prefix:

  Prefix.

- postfix:

  Postfix.

## Value

Expression

## Examples

``` r

# expression
env_parm_labeller("t_an")
#> expression( ~ "Temperature (" * degree ~ C * ")" ~ )

# plot with temperature axis label
library(ggplot2)

ggplot() +
 geom_blank() +
 ylab(env_parm_labeller("t_an"))


```
