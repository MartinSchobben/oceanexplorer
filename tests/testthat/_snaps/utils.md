# stereographic projections plot click values can be converted

    Code
      convert_stereo(9332793, 7376573, 3031)
    Output
             lon       lat
      1 51.67741 -2.241017

# point is clipped when re-projected to 3031

    Code
      clip_lat(points, "3031")
    Output
      Simple feature collection with 1 feature and 2 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -6168778 ymin: -3049349 xmax: -6168778 ymax: -3049349
      Projected CRS: WGS 84 / Antarctic Polar Stereographic
            t_an depth                  geometry
      1 20.34319     0 POINT (-6168778 -3049349)

