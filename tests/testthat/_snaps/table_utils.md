# reformatted table works

    Code
      format_table(NOAA_point, "oxygen", 1, "annual")
    Output
          oxygen depth geometry longitude latitude spatial temporal
      1 206.6557    30    POINT      -130    10.12       1   annual
      2 207.1639    30    POINT   -120.54       12       1   annual

---

    Code
      format_table(NOAA_polygon, "oxygen", 1, "annual")
    Output
          oxygen depth geometry    longitude     latitude spatial temporal
      1 341.9289     0  POLYGON -53.1632.... 48.59155....       1   annual

