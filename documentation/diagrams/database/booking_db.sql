CREATE DATABASE IF NOT EXISTS booking;
USE booking;

-- ========= CATÁLOGOS =========
CREATE TABLE C_BOOKING_SOURCE (
    c_booking_source_id CHAR(36) PRIMARY KEY,
    c_booking_source_name VARCHAR(50) NOT NULL CHECK (c_booking_source_name IN ('website', 'reception'))
);

CREATE TABLE C_BOOKING_STATUS (
    c_booking_status_id CHAR(36) PRIMARY KEY,
    c_booking_status_name VARCHAR(50) NOT NULL CHECK (c_booking_status_name IN ('pending', 'confirmed', 'cancelled', 'completed', 'no_show'))
);

-- ========= TABLAS TRANSACCIONALES =========
CREATE TABLE T_BOOKING (
    t_booking_id CHAR(36) PRIMARY KEY,
    t_guest_id CHAR(36) NOT NULL,
    c_booking_source_id CHAR(36) NOT NULL,
    c_booking_status_id CHAR(36) NOT NULL,
    t_booking_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    t_booking_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_source FOREIGN KEY (c_booking_source_id) REFERENCES C_BOOKING_SOURCE(c_booking_source_id),
    CONSTRAINT fk_booking_status FOREIGN KEY (c_booking_status_id) REFERENCES C_BOOKING_STATUS(c_booking_status_id)
);

-- ÚNICO índice realmente esencial para T_BOOKING (búsquedas por huésped)
CREATE INDEX idx_booking_guest ON T_BOOKING(t_guest_id);

CREATE TABLE T_BOOKING_DETAIL (
    t_booking_detail_id CHAR(36) PRIMARY KEY,
    t_booking_id CHAR(36) NOT NULL,
    t_room_id CHAR(36) NOT NULL,
    t_check_in DATE NOT NULL,
    t_check_out DATE NOT NULL,
    t_nightly_price DECIMAL(10, 2) NOT NULL,
    t_adult_count INTEGER NOT NULL CHECK (t_adult_count > 0),
    t_child_count INTEGER NOT NULL DEFAULT 0 CHECK (t_child_count >= 0),
    t_special_requests TEXT,
    CONSTRAINT fk_booking_detail_booking FOREIGN KEY (t_booking_id) REFERENCES T_BOOKING(t_booking_id),
    CONSTRAINT chk_valid_dates CHECK (t_check_out > t_check_in)
);

-- ÚNICO índice esencial para T_BOOKING_DETAIL (consultas de disponibilidad)
CREATE INDEX idx_booking_detail_dates ON T_BOOKING_DETAIL(t_check_in, t_check_out);

CREATE TABLE T_BOOKING_HISTORY (
    t_history_id CHAR(36) PRIMARY KEY,
    t_booking_id CHAR(36) NOT NULL,
    t_staff_id CHAR(36),
    t_action VARCHAR(50) NOT NULL CHECK (t_action IN ('created', 'modified', 'cancelled', 'status_change')),
    t_action_details VARCHAR(255),
    t_action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_booking FOREIGN KEY (t_booking_id) REFERENCES T_BOOKING(t_booking_id)
);

-- Trigger para actualizar timestamp
DELIMITER $$
CREATE TRIGGER trg_update_booking_timestamp
BEFORE UPDATE ON T_BOOKING
FOR EACH ROW
BEGIN
    SET NEW.t_booking_updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;