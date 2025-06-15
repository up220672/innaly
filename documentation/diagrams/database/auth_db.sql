CREATE DATABASE IF NOT EXISTS auth;
USE auth;

-- ========= CATALOGS =========

-- Create C_ROLE table
CREATE TABLE C_ROLE (
    c_role_id CHAR(36) PRIMARY KEY,
    c_role_type VARCHAR(50) NOT NULL CHECK (c_role_type IN ('admin', 'receptionist', 'manager'))
);

-- Create C_PERMISSION table
CREATE TABLE C_PERMISSION (
    c_permission_id CHAR(36) PRIMARY KEY,
    c_permission_name VARCHAR(100) NOT NULL
);

-- Create C_ROLE_PERMISSION junction table
CREATE TABLE C_ROLE_PERMISSION (
    c_role_id CHAR(36) NOT NULL,
    c_permission_id CHAR(36) NOT NULL,
    PRIMARY KEY (c_role_id, c_permission_id),
    FOREIGN KEY (c_role_id) REFERENCES C_ROLE(c_role_id),
    FOREIGN KEY (c_permission_id) REFERENCES C_PERMISSION(c_permission_id)
);

-- ========= STAFF (USERS) =========

-- Create T_STAFF table
CREATE TABLE T_STAFF (
    t_staff_id CHAR(36) PRIMARY KEY,
    t_staff_name VARCHAR(100) NOT NULL,
    t_staff_last_name VARCHAR(100) NOT NULL,
    t_staff_email VARCHAR(255) NOT NULL UNIQUE,
    t_staff_phone VARCHAR(20),
    t_staff_password VARCHAR(255) NOT NULL,
    c_role_id CHAR(36) NOT NULL,
    t_staff_status BOOLEAN NOT NULL DEFAULT TRUE,
    t_staff_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    t_staff_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (c_role_id) REFERENCES C_ROLE(c_role_id)
);

-- Create T_STAFF_LOGIN_HISTORY table
CREATE TABLE T_STAFF_LOGIN_HISTORY (
    t_login_id CHAR(36) PRIMARY KEY,
    t_staff_id CHAR(36) NOT NULL,
    t_login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    t_login_ip VARCHAR(45) NOT NULL,
    t_login_success BOOLEAN NOT NULL,
    FOREIGN KEY (t_staff_id) REFERENCES T_STAFF(t_staff_id)
);

-- Create indexes for better performance
CREATE INDEX idx_t_staff_email ON T_STAFF(t_staff_email);
CREATE INDEX idx_t_staff_role ON T_STAFF(c_role_id);
CREATE INDEX idx_login_history_staff ON T_STAFF_LOGIN_HISTORY(t_staff_id);
CREATE INDEX idx_login_history_time ON T_STAFF_LOGIN_HISTORY(t_login_time);