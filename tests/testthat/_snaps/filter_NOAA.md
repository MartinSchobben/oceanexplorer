# multiple depth entries of the same index create new data output

    Code
      filter_NOAA(NOAA, depth = c(0, 0, 0), coord = list(lon = c(-116.3041, -40.58253,
        -9.306224), lat = c(-31.98888, 17.39477, -31.98888)))
    Output
      Simple feature collection with 3 features and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3041 ymin: -31.98888 xmax: -9.306224 ymax: 17.39477
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
                 t_an depth                    geometry
      1 20.34319 [°C]     0 POINT (-116.3041 -31.98888)
      2 25.45511 [°C]     0  POINT (-40.58253 17.39477)
      3 19.95131 [°C]     0 POINT (-9.306224 -31.98888)

# epsg conversion works

    Code
      filter_NOAA(NOAA, depth = 0, coord = list(lon = c(-116.3041, 117.12998), lat = c(
        -31.98888, 17.39477)), epsg = 4326)
    Output
      Simple feature collection with 2 features and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3041 ymin: -31.98888 xmax: 117.13 ymax: 17.39477
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
                 t_an depth                    geometry
      1 20.34319 [°C]     0 POINT (-116.3041 -31.98888)
      2 27.48980 [°C]     0     POINT (117.13 17.39477)

