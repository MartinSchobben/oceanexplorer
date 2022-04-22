# box clipping works for stars

    Code
      clip_lat(NOAAatlas, 3031)
    Output
      stars object with 2 dimensions and 1 attribute
      attribute(s):
                Min.  1st Qu.   Median     Mean  3rd Qu.     Max.  NA's
      o_an  181.1851 212.1127 254.0271 264.3293 322.4746 390.5813 10120
      dimension(s):
          from  to offset delta                       refsys point
      lon    1 360     NA    NA WGS 84 / Antarctic Polar ...    NA
      lat    1  90     NA    NA WGS 84 / Antarctic Polar ...    NA
                                   values x/y
      lon [360x90] -12260188,...,12260188 [x]
      lat [360x90] -12260188,...,12260188 [y]
      curvilinear grid

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
                                          ID                           geom
      3                               Angola MULTIPOLYGON (((4155886 934...
      9                            Argentina MULTIPOLYGON (((-3570921 16...
      11                      American Samoa POLYGON ((-1549877 -9491823...
      12                          Antarctica MULTIPOLYGON (((-231385.1 -...
      13                           Australia MULTIPOLYGON (((8290931 -55...
      14 French Southern and Antarctic Lands MULTIPOLYGON (((4340119 164...
      19                             Burundi POLYGON ((6030597 10216051,...
      32                             Bolivia POLYGON ((-7351121 4565038,...
      33                              Brazil MULTIPOLYGON (((-5607467 49...
      35                              Brunei MULTIPOLYGON (((12201003 -5...

