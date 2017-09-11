select distinct 'b' || rm.record_num || 'a' as "RECORD #(BIBLIO)"
							, ph.index_entry as "001"
							, (SELECT STRING_AGG(brl.location_code, ', ')
									FROM sierra_view.bib_record_location brl
									WHERE brl.bib_record_id = b.id
									and brl.location_code != 'multi'
								) AS "LOCATION"
from sierra_view.phrase_entry ph
inner join sierra_view.bib_record b on b.id = ph.record_id
inner join sierra_view.record_metadata rm on rm.id = b.id
where (ph.index_tag || ph.index_entry) ~ '^oss(e|eb)[0-9]+$'