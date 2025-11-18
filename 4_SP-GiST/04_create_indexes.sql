-- Создание SP-GiST индексов
SET search_path TO SPGiST;

-- Индекс 1: SP-GiST для пространственных данных (квадродерево)
CREATE INDEX CONCURRENTLY idx_spatial_coordinates_spgist ON spatial_data USING SPGIST (coordinates);

-- Индекс 2: SP-GiST для многомерных данных (k-d дерево)
CREATE INDEX CONCURRENTLY idx_multidimensional_point_spgist ON multidimensional_data USING SPGIST (data_point);

-- Индекс 3: SP-GiST для текстовых данных (префиксное дерево)
CREATE INDEX CONCURRENTLY idx_text_word_spgist ON text_data USING SPGIST (word);

-- Индекс 4: SP-GiST для сетевых данных (радиальное дерево)
CREATE INDEX CONCURRENTLY idx_network_ip_spgist ON network_data USING SPGIST (ip_address);

-- Индекс 5: SP-GiST для прямоугольников
CREATE INDEX CONCURRENTLY idx_bbox_spgist ON bounding_boxes USING SPGIST (bbox);

-- Для сравнения: создаем B-tree индексы на тех же полях
CREATE INDEX CONCURRENTLY idx_text_word_btree ON text_data USING BTREE (word);
CREATE INDEX CONCURRENTLY idx_network_ip_btree ON network_data USING BTREE (ip_address);

-- Составные SP-GiST индексы для демонстрации
CREATE INDEX CONCURRENTLY idx_spatial_composite_spgist ON spatial_data USING SPGIST (coordinates, object_type);

-- Анализ таблиц для обновления статистики
ANALYZE spatial_data;
ANALYZE multidimensional_data;
ANALYZE text_data;
ANALYZE network_data;
ANALYZE bounding_boxes;