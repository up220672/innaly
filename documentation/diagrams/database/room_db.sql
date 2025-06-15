CREATE DATABASE IF NOT EXISTS room;
USE room;

-- ========= CATÁLOGOS =========

-- Tabla de tipos de habitación
CREATE TABLE C_ROOM_TYPE (
    c_room_type_id CHAR(36) PRIMARY KEY,
    c_room_type_name VARCHAR(100) NOT NULL,
    c_room_type_base_price DECIMAL(10,2) NOT NULL,
    c_room_type_capacity INT NOT NULL,
    c_room_type_description TEXT,
    UNIQUE KEY uk_room_type_name (c_room_type_name)
) ENGINE=InnoDB;

-- Tabla de amenidades
CREATE TABLE C_AMENITY (
    c_amenity_id CHAR(36) PRIMARY KEY,
    c_amenity_name VARCHAR(100) NOT NULL,
    UNIQUE KEY uk_amenity_name (c_amenity_name)
) ENGINE=InnoDB;

-- Tabla de estados de habitación
CREATE TABLE C_ROOM_STATUS (
    c_room_status_id CHAR(36) PRIMARY KEY,
    c_room_status_name VARCHAR(50) NOT NULL CHECK (c_room_status_name IN ('available', 'occupied', 'maintenance', 'cleaning')),
    UNIQUE KEY uk_room_status_name (c_room_status_name)
) ENGINE=InnoDB;

-- ========= TABLAS TRANSACCIONALES =========

-- Tabla de habitaciones
CREATE TABLE T_ROOM (
    t_room_id CHAR(36) PRIMARY KEY,
    c_room_type_id CHAR(36) NOT NULL,
    c_room_status_id CHAR(36) NOT NULL,
    t_room_number VARCHAR(20) NOT NULL,
    t_room_floor INT NOT NULL,
    t_room_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_type FOREIGN KEY (c_room_type_id) REFERENCES C_ROOM_TYPE(c_room_type_id),
    CONSTRAINT fk_room_status FOREIGN KEY (c_room_status_id) REFERENCES C_ROOM_STATUS(c_room_status_id),
    UNIQUE KEY uk_room_number (t_room_number)
) ENGINE=InnoDB;

-- Tabla de relación tipo de habitación-amenidad
CREATE TABLE T_ROOM_TYPE_AMENITY (
    t_room_type_amenity_id CHAR(36) PRIMARY KEY,
    c_room_type_id CHAR(36) NOT NULL,
    c_amenity_id CHAR(36) NOT NULL,
    CONSTRAINT fk_rta_room_type FOREIGN KEY (c_room_type_id) REFERENCES C_ROOM_TYPE(c_room_type_id),
    CONSTRAINT fk_rta_amenity FOREIGN KEY (c_amenity_id) REFERENCES C_AMENITY(c_amenity_id),
    UNIQUE KEY uk_room_type_amenity (c_room_type_id, c_amenity_id)
) ENGINE=InnoDB;

-- Tabla de imágenes de habitaciones
CREATE TABLE T_ROOM_IMAGE (
    t_room_image_id CHAR(36) PRIMARY KEY,
    c_room_type_id CHAR(36) NOT NULL,
    t_image_url VARCHAR(255) NOT NULL,
    t_image_order INT NOT NULL,
    t_is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_image_room_type FOREIGN KEY (c_room_type_id) REFERENCES C_ROOM_TYPE(c_room_type_id)
) ENGINE=InnoDB;

-- Tabla de mantenimiento de habitaciones
CREATE TABLE T_ROOM_MAINTENANCE (
    t_maintenance_id CHAR(36) PRIMARY KEY,
    t_room_id CHAR(36) NOT NULL,
    t_maintenance_reason VARCHAR(255) NOT NULL,
    t_maintenance_start TIMESTAMP NOT NULL,
    t_maintenance_end TIMESTAMP NOT NULL,
    t_maintenance_status VARCHAR(20) NOT NULL CHECK (t_maintenance_status IN ('scheduled', 'in_progress', 'completed')),
    CONSTRAINT fk_maintenance_room FOREIGN KEY (t_room_id) REFERENCES T_ROOM(t_room_id),
    CONSTRAINT chk_valid_maintenance_dates CHECK (t_maintenance_end > t_maintenance_start)
) ENGINE=InnoDB;

-- ========= ÍNDICES ESENCIALES =========

-- Índices para T_ROOM
CREATE INDEX idx_room_status ON T_ROOM(c_room_status_id);
CREATE INDEX idx_room_floor ON T_ROOM(t_room_floor);
CREATE INDEX idx_room_type ON T_ROOM(c_room_type_id);

-- Índices para T_ROOM_TYPE_AMENITY
CREATE INDEX idx_rta_amenity ON T_ROOM_TYPE_AMENITY(c_amenity_id);

-- Índices para T_ROOM_IMAGE
CREATE INDEX idx_image_room_type ON T_ROOM_IMAGE(c_room_type_id);
CREATE INDEX idx_image_order ON T_ROOM_IMAGE(t_image_order);
CREATE INDEX idx_image_primary ON T_ROOM_IMAGE(t_is_primary);

-- Índices para T_ROOM_MAINTENANCE
CREATE INDEX idx_maintenance_room ON T_ROOM_MAINTENANCE(t_room_id);
CREATE INDEX idx_maintenance_status ON T_ROOM_MAINTENANCE(t_maintenance_status);
CREATE INDEX idx_maintenance_dates ON T_ROOM_MAINTENANCE(t_maintenance_start, t_maintenance_end);