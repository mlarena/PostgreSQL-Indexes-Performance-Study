-- Создание GiST индексов
SET search_path TO GiST;

-- Индекс 1: Полнотекстовый поиск по документам (ОСНОВНОЙ GiST)
CREATE INDEX CONCURRENTLY idx_documents_search_vector_gist ON documents USING GIST (search_vector);

-- Индекс 2: Индекс для временных диапазонов
CREATE INDEX CONCURRENTLY idx_events_period_gist ON events USING GIST (event_period);

-- Индекс 3: Индекс для сетевых адресов
CREATE INDEX CONCURRENTLY idx_network_ip_range_gist ON network_devices USING GIST (ip_range);

-- Индекс 4: Индекс для массивов тегов (используя GiST для операций с массивами)
CREATE INDEX CONCURRENTLY idx_documents_tags_gist ON documents USING GIST (tags);

-- Индекс 5: Составной GiST индекс для координат (используем box тип)
CREATE INDEX CONCURRENTLY idx_locations_coords_gist ON simple_locations USING GIST (
    point(x_coord, y_coord)
);

-- Для сравнения: B-tree индексы на тех же полях
CREATE INDEX CONCURRENTLY idx_documents_publication_date_btree ON documents USING BTREE (publication_date);
CREATE INDEX CONCURRENTLY idx_events_location_btree ON events USING BTREE (location);
CREATE INDEX CONCURRENTLY idx_network_location_btree ON network_devices USING BTREE (location);

-- Анализ таблиц для обновления статистики
ANALYZE documents;
ANALYZE events;
ANALYZE network_devices;
ANALYZE simple_locations;