# box clipping works for stars

    Code
      clip_lat(NOAAatlas, 3031)
    Output
      stars object with 2 dimensions and 1 attribute
      attribute(s):
                Min.  1st Qu.   Median     Mean  3rd Qu.     Max. NA's
      o_an  285.4861 327.0987 336.3388 333.5045 341.7997 390.5813 6797
      dimension(s):
          from  to offset delta                       refsys point
      lon    1 360     NA    NA WGS 84 / Antarctic Polar ...    NA
      lat    1  35     NA    NA WGS 84 / Antarctic Polar ...    NA
                                 values x/y
      lon [360x35] -3861309,...,3861309 [x]
      lat [360x35] -3861309,...,3861309 [y]
      curvilinear grid

# box clipping works for sf

    Code
      clip_lat(wmap, 3031)
    Output
      Geometry set for 10 features 
      Geometry type: GEOMETRY
      Dimension:     XY
      Bounding box:  xmin: -4e+06 ymin: -3718173 xmax: 3988812 ymax: 3891697
      Projected CRS: WGS 84 / Antarctic Polar Stereographic
      First 5 geometries:
    Message <simpleMessage>
      MULTIPOLYGON (((-3570921 1699482, -3565152 1705...
      MULTIPOLYGON (((-231385.1 -711867.5, -226752.4 ...
      POLYGON ((1425325 -3689749, 1425790 -3684527, 1...
      POLYGON ((3904154 3068454, 3899384 3072733, 389...
      MULTIPOLYGON (((-3526735 1455402, -3527430 1453...

