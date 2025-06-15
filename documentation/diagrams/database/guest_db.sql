CREATE DATABASE IF NOT EXISTS guest;
USE guest;

-- ========= CATÁLOGOS =========

-- Tabla de tipos de identificación
CREATE TABLE C_IDENTIFICATION_TYPE (
    c_id_type_id CHAR(36) PRIMARY KEY,
    c_id_type_name VARCHAR(50) NOT NULL CHECK (c_id_type_name IN ('passport', 'driver_license', 'national_id')),
    CONSTRAINT uk_id_type_name UNIQUE (c_id_type_name)
);

-- Tabla de países
CREATE TABLE C_COUNTRY (
    c_country_id CHAR(36) PRIMARY KEY,
    c_country_name VARCHAR(100) NOT NULL,
    c_country_code VARCHAR(3) NOT NULL,
    CONSTRAINT uk_country_code UNIQUE (c_country_code),
    CONSTRAINT uk_country_name UNIQUE (c_country_name)
);

-- ========= TABLAS DE HUÉSPEDES =========

-- Tabla principal de huéspedes
CREATE TABLE T_GUEST (
    t_guest_id CHAR(36) PRIMARY KEY,
    t_guest_first_name VARCHAR(100) NOT NULL,
    t_guest_last_name VARCHAR(100) NOT NULL,
    t_guest_email VARCHAR(255) NOT NULL,
    t_guest_phone VARCHAR(50),
    t_guest_birthdate DATE,
    c_country_id CHAR(36) NOT NULL,
    t_guest_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_guest_country FOREIGN KEY (c_country_id) REFERENCES C_COUNTRY(c_country_id),
    CONSTRAINT uk_guest_email UNIQUE (t_guest_email)
);

-- Tabla de identificaciones de huéspedes
CREATE TABLE T_GUEST_IDENTIFICATION (
    t_guest_id_id CHAR(36) PRIMARY KEY,
    t_guest_id CHAR(36) NOT NULL,
    c_id_type_id CHAR(36) NOT NULL,
    t_id_number VARCHAR(50) NOT NULL,
    t_id_image_url VARCHAR(255),
    t_id_expiration_date DATE,
    CONSTRAINT fk_identification_guest FOREIGN KEY (t_guest_id) REFERENCES T_GUEST(t_guest_id),
    CONSTRAINT fk_identification_type FOREIGN KEY (c_id_type_id) REFERENCES C_IDENTIFICATION_TYPE(c_id_type_id),
    CONSTRAINT uk_guest_id_number UNIQUE (t_id_number, c_id_type_id)
);

-- Tabla de direcciones de huéspedes
CREATE TABLE T_GUEST_ADDRESS (
    t_address_id CHAR(36) PRIMARY KEY,
    t_guest_id CHAR(36) NOT NULL,
    t_address_street VARCHAR(255) NOT NULL,
    t_address_city VARCHAR(100) NOT NULL,
    t_address_state VARCHAR(100),
    t_address_postal_code VARCHAR(20),
    t_address_country VARCHAR(100) NOT NULL,
    CONSTRAINT fk_address_guest FOREIGN KEY (t_guest_id) REFERENCES T_GUEST(t_guest_id)
);

-- ========= ÍNDICES ESENCIALES =========

-- Índice para búsqueda de huéspedes por nombre/email
CREATE INDEX idx_guest_name ON T_GUEST(t_guest_last_name, t_guest_first_name);
CREATE INDEX idx_guest_email ON T_GUEST(t_guest_email);

-- Índice para búsqueda de identificaciones por número
CREATE INDEX idx_guest_id_number ON T_GUEST_IDENTIFICATION(t_id_number);

-- Índice para búsqueda de direcciones por país/ciudad
CREATE INDEX idx_address_location ON T_GUEST_ADDRESS(t_address_country, t_address_city);