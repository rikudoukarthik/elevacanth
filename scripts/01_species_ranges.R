elev_ranges <- bird_data |> 
  group_by(SPEC.CODE) |> 
  reframe(ELEV.MIN = min(PLACE.ELEV),
          ELEV.MAX = max(PLACE.ELEV)) |> 
  mutate(ELEV.BREADTH = ELEV.MAX - ELEV.MIN) |> 
  left_join(spec_codes |> dplyr::select(-GENUS, -SPECIES))

# maybe do the same but group_by(SEASON, SPEC.CODE)