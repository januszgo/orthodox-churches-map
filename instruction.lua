local pois = osm2pgsql.define_table({
    name = 'churches',
    ids = { type = 'any', type_column = 'osm_type', id_column = 'osm_id' },
    columns = {
        { column = 'name', not_null = true },
        { column = 'denomination', not_null = true },
        { column = 'postcode'},
        { column = 'city'},
        { column = 'street'},
        { column = 'housenumber'},
        { column = 'website'},
        { column = 'geom', type = 'point', not_null = true },
}})

function process_poi(object, geom)
    local a = {
        name = object.tags.name,
        denomination = object.tags.denomination,
        geom = geom
	}
		
	a.postcode = object.tags['addr:postcode']
	a.housenumber = object.tags['addr:housenumber']
	a.website = object.tags.website
	if object.tags['addr:street'] then
		a.city = object.tags['addr:city']
		a.street = object.tags['addr:street']
	else
		a.city = object.tags['addr:place']
		a.street = object.tags['addr:place']
	end

    pois:insert(a)
end

function osm2pgsql.process_node(object)
	if object.tags.religion=='christian' then
   		process_poi(object, object:as_point())
	end
end

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.building and object.tags.religion=='christian' then
        process_poi(object, object:as_polygon():centroid())
    end
end

