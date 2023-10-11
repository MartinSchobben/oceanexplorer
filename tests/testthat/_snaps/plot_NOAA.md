# box clipping works for stars

    Code
      clip_lat(NOAA, 3031)
    Output
      stars object with 2 dimensions and 1 attribute
      attribute(s):
                Min.  1st Qu.   Median     Mean  3rd Qu.     Max.  NA's
      o_an  181.1851 202.0076 213.0899 233.6797 251.1976 365.3462 15986
      dimension(s):
        from  to    offset   delta                       refsys x/y
      x    1 204 -12367396  121249 WGS 84 / Antarctic Polar ... [x]
      y    1 204  12367396 -121249 WGS 84 / Antarctic Polar ... [y]

# box clipping works for sf

    Code
      clip_lat(wmap, 3031)
    Output
      Simple feature collection with 86 features and 1 field
      Geometry type: GEOMETRY
      Dimension:     XY
      Bounding box:  xmin: -12500000 ymin: -12495420 xmax: 12500000 ymax: 12500000
      Projected CRS: WGS 84 / Antarctic Polar Stereographic
      First 10 features:
                                                                           ID
      Angola                                                           Angola
      Argentina                                                     Argentina
      American Samoa                                           American Samoa
      Antarctica                                                   Antarctica
      Australia                                                     Australia
      French Southern and Antarctic Lands French Southern and Antarctic Lands
      Burundi                                                         Burundi
      Bolivia                                                         Bolivia
      Brazil                                                           Brazil
      Brunei                                                           Brunei
                                                                    geom
      Angola                              MULTIPOLYGON (((4140035 929...
      Argentina                           MULTIPOLYGON (((-3756796 14...
      American Samoa                      POLYGON ((-1542521 -9491522...
      Antarctica                          MULTIPOLYGON (((-2328516 -2...
      Australia                           MULTIPOLYGON (((3558932 -70...
      French Southern and Antarctic Lands MULTIPOLYGON (((4335570 163...
      Burundi                             POLYGON ((6024308 10213507,...
      Bolivia                             POLYGON ((-7372089 4581594,...
      Brazil                              MULTIPOLYGON (((-10583993 7...
      Brunei                              MULTIPOLYGON (((12179881 -5...

