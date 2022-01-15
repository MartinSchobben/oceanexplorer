# text input + action button causes filtering

    Code
      code()
    Output
      filter_NOAA(NOAA, depth = 10, coord = list(lon = c(-120), lat = c(10)))

---

    Code
      map()
    Output
      stars object with 2 dimensions and 1 attribute
      attribute(s):
                Min.  1st Qu.   Median     Mean  3rd Qu.     Max.  NA's
      o_an  181.1851 208.6335 253.6073 270.1982 330.5857 476.6985 23712
      dimension(s):
          from  to offset delta                       refsys point values x/y
      lon    1 360   -180     1 +proj=longlat +a=6378137 ...    NA   NULL [x]
      lat    1 180    -90     1 +proj=longlat +a=6378137 ...    NA   NULL [y]

---

    Code
      coord()
    Output
      Simple feature collection with 1 feature and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -120 ymin: 10 xmax: -120 ymax: 10
      CRS:           +proj=longlat +a=6378137 +f=0.0033528105624174 +pm=0 +no_defs
            o_an depth        geometry
      1 206.1942    10 POINT (-120 10)

