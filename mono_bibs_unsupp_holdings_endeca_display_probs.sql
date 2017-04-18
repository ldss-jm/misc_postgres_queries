SELECT DISTINCT
  'b' || rmb.record_num || 'a' as bnum,
  'c' || rmc.record_num || 'a' as cnum,
  --bh.bib_record_id,
  --bh.holding_record_id,
  hL.location_code as problem_location,
  'http://search.lib.unc.edu/search?R=UNCb' || rmb.record_num as url
  --holddisp.location_code as holdings_display
FROM
  sierra_view.bib_record_holding_record_link bh
INNER JOIN sierra_view.holding_record hr ON hr. ID = bh.holding_record_id
  AND hr.is_suppressed = 'f'
INNER JOIN sierra_view.holding_record_location hL ON hL.holding_record_id = bh.holding_record_id
  AND hL.location_code not like 'n%'
  AND hL.location_code not like 'k%'
  AND hL.location_code not like '%z'
INNER JOIN sierra_view.bib_record br ON br. ID = bh.bib_record_id
  AND br.is_suppressed = 'f'
  AND br.bcode1 = 'm'
INNER JOIN sierra_view.record_metadata rmb ON rmb.id = bh.bib_record_id
INNER JOIN sierra_view.record_metadata rmc ON rmc.id = bh.holding_record_id
INNER JOIN ( select ibh.bib_record_id, ihL.location_code
            from
              sierra_view.bib_record_holding_record_link ibh
            INNER JOIN sierra_view.holding_record ihr ON ihr. ID = ibh.holding_record_id
              AND ihr.is_suppressed = 'f'
            INNER JOIN sierra_view.holding_record_location ihL ON ihL.holding_record_id = ibh.holding_record_id
            WHERE
               ihL.location_code like 'mm%'
            or ihL.location_code like 'n%'
            or ihL.location_code like 'k%' ) holddisp on holddisp.bib_record_id = bh.bib_record_id
WHERE NOT EXISTS(
      SELECT *
      FROM sierra_view.holding_record_item_record_link hi --hi!
      INNER JOIN sierra_view.item_record ir on ir.id = hi.item_record_id
        AND ir.is_suppressed = 'f'
      WHERE hr.id = hi.holding_record_id
      )
ORDER BY hL.location_code ASC
