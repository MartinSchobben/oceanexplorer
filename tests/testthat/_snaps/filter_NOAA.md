# that different coord classes generate the same results

    Code
      ls_NOAA
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

---

    Code
      mat_NOAA
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

---

    Code
      sfc_NOAA
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

# epsg conversion works with character vector

    Code
      filter_NOAA(NOAA, depth = 0, coord = list(lon = c(-116.3041, 117.12998), lat = c(
        -31.98888, 17.39477)), epsg = "4326")
    Output
      Simple feature collection with 2 features and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3041 ymin: -31.98888 xmax: 117.13 ymax: 17.39477
      Geodetic CRS:  WGS 84
                 t_an depth                    geometry
      1 20.34319 [°C]     0 POINT (-116.3041 -31.98888)
      2 27.48980 [°C]     0     POINT (117.13 17.39477)

# epsg conversion works with 'original' keyword

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
      extract_coords(plane, coords1, 0, sf::st_crs(NOAA), 0)
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
      extract_coords(plane, coords2, 0, sf::st_crs(NOAA), 0)
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
      extract_coords(plane, coords2, 0, sf::st_crs(NOAA), 100)
    Output
      Simple feature collection with 1 feature and 2 fields
      Active geometry column: geometry
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -52.79878 ymin: 47.72121 xmax: -52.79878 ymax: 47.72121
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
      # A tibble: 1 x 4
        t_an depth             geometry                                geometry_search
        [°C] <dbl>          <POINT [°]>                                  <POLYGON [°]>
      1 3.45     0 (-52.79878 47.72121) ((-53.16325 48.59155, -53.17687 48.59661, -53~

---

    Code
      extract_coords(plane, rbind(coords1, coords2), 0, sf::st_crs(NOAA), 100)
    Output
      Simple feature collection with 2 features and 2 fields
      Active geometry column: geometry
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -116.3 ymin: -31.98 xmax: -52.79878 ymax: 47.72121
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
      # A tibble: 2 x 4
         t_an depth             geometry                               geometry_search
         [°C] <dbl>          <POINT [°]>                                <GEOMETRY [°]>
      1 20.3      0      (-116.3 -31.98)                         POINT (-116.3 -31.98)
      2  3.45     0 (-52.79878 47.72121) POLYGON ((-53.16325 48.59155, -53.17687 48.5~

