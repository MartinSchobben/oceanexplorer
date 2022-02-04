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

---

    Code
      filter_NOAA(NOAA, depth = 0, coord = list(lon = c(-116.3041, 117.12998), lat = c(
        -31.98888, 17.39477)), epsg = "4326")
    Output
      Simple feature collection with 2 features and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3041 ymin: -31.98888 xmax: 117.13 ymax: 17.39477
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
                 t_an depth                    geometry
      1 20.34319 [°C]     0 POINT (-116.3041 -31.98888)
      2 27.48980 [°C]     0     POINT (117.13 17.39477)

---

    Code
      filter_NOAA(NOAA, depth = 0, coord = list(lon = c(-116.3041, 117.12998), lat = c(
        -31.98888, 17.39477)), epsg = "original")
    Output
      Simple feature collection with 2 features and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3041 ymin: -31.98888 xmax: 117.13 ymax: 17.39477
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
                 t_an depth                    geometry
      1 20.34319 [°C]     0 POINT (-116.3041 -31.98888)
      2 27.48980 [°C]     0     POINT (117.13 17.39477)

# extraction of coords can use fuzzy search

    Code
      extract_coords(plane, coords1, 0, 0)
    Output
      Simple feature collection with 1 feature and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3 ymin: -31.98 xmax: -116.3 ymax: -31.98
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
                 t_an depth              geometry
      1 20.34319 [°C]     0 POINT (-116.3 -31.98)

---

    Code
      extract_coords(plane, coords2, 0, 0)
    Output
      Simple feature collection with 1 feature and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -52.79878 ymin: 47.72121 xmax: -52.79878 ymax: 47.72121
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
           t_an depth                   geometry
      1 NA [°C]     0 POINT (-52.79878 47.72121)

---

    Code
      extract_coords(plane, coords2, 0, 100)
    Output
      Simple feature collection with 1 feature and 2 fields
      Geometry type: POLYGON
      Dimension:     XY
      Bounding box:  xmin: -54.15675 ymin: 46.81397 xmax: -51.44278 ymax: 48.62896
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
      # A tibble: 1 x 3
        t_an depth                                                            geometry
        [°C] <dbl>                                                       <POLYGON [°]>
      1 3.45     0 ((-53.16325 48.59155, -53.17687 48.59661, -53.19924 48.58178, -53.~

---

    Code
      extract_coords(plane, append(coords1, coords2), 0, 100)
    Output
      Simple feature collection with 2 features and 2 fields
      Geometry type: GEOMETRY
      Dimension:     XY
      Bounding box:  xmin: -116.3 ymin: -31.98 xmax: -51.44278 ymax: 48.62896
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
      # A tibble: 2 x 3
         t_an depth                                                           geometry
         [°C] <dbl>                                                     <GEOMETRY [°]>
      1 20.3      0                                              POINT (-116.3 -31.98)
      2  3.45     0 POLYGON ((-53.16325 48.59155, -53.17687 48.59661, -53.19924 48.58~

