CREATE DATABASE IF NOT EXISTS payment;
USE payment;

-- ========= CATÁLOGOS =========

-- Tabla de métodos de pago
CREATE TABLE C_PAYMENT_METHOD (
    c_payment_method_id CHAR(36) PRIMARY KEY,
    c_payment_method_name VARCHAR(50) NOT NULL CHECK (c_payment_method_name IN ('credit_card', 'paypal', 'transfer', 'cash')),
    UNIQUE KEY uk_payment_method_name (c_payment_method_name)
) ENGINE=InnoDB;

-- Tabla de estados de pago
CREATE TABLE C_PAYMENT_STATUS (
    c_payment_status_id CHAR(36) PRIMARY KEY,
    c_payment_status_name VARCHAR(50) NOT NULL CHECK (c_payment_status_name IN ('pending', 'completed', 'refunded', 'failed', 'partially_refunded')),
    UNIQUE KEY uk_payment_status_name (c_payment_status_name)
) ENGINE=InnoDB;

-- ========= TABLAS TRANSACCIONALES =========

-- Tabla principal de pagos
CREATE TABLE T_PAYMENT (
    t_payment_id CHAR(36) PRIMARY KEY,
    t_booking_id CHAR(36) NOT NULL,
    c_payment_method_id CHAR(36) NOT NULL,
    c_payment_status_id CHAR(36) NOT NULL,
    t_payment_amount DECIMAL(10,2) NOT NULL,
    t_payment_transaction_id VARCHAR(255),
    t_payment_processed_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT fk_payment_method FOREIGN KEY (c_payment_method_id) REFERENCES C_PAYMENT_METHOD(c_payment_method_id),
    CONSTRAINT fk_payment_status FOREIGN KEY (c_payment_status_id) REFERENCES C_PAYMENT_STATUS(c_payment_status_id)
) ENGINE=InnoDB;

-- Tabla de detalles de pago
CREATE TABLE T_PAYMENT_DETAIL (
    t_payment_detail_id CHAR(36) PRIMARY KEY,
    t_payment_id CHAR(36) NOT NULL,
    t_room_charges DECIMAL(10,2) NOT NULL DEFAULT 0,
    t_tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    t_service_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
    t_other_charges DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_payment_detail_payment FOREIGN KEY (t_payment_id) REFERENCES T_PAYMENT(t_payment_id)
) ENGINE=InnoDB;

-- Tabla de reembolsos
CREATE TABLE T_REFUND (
    t_refund_id CHAR(36) PRIMARY KEY,
    t_payment_id CHAR(36) NOT NULL,
    t_refund_amount DECIMAL(10,2) NOT NULL,
    t_refund_reason VARCHAR(255),
    t_refund_processed_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT fk_refund_payment FOREIGN KEY (t_payment_id) REFERENCES T_PAYMENT(t_payment_id)
) ENGINE=InnoDB;

-- Tabla de facturas
CREATE TABLE T_INVOICE (
    t_invoice_id CHAR(36) PRIMARY KEY,
    t_payment_id CHAR(36) NOT NULL,
    t_invoice_number VARCHAR(50) NOT NULL,
    t_invoice_details TEXT,
    t_invoice_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_payment FOREIGN KEY (t_payment_id) REFERENCES T_PAYMENT(t_payment_id),
    UNIQUE KEY uk_invoice_number (t_invoice_number)
) ENGINE=InnoDB;

-- ========= ÍNDICES ESENCIALES =========

-- Índices para T_PAYMENT
CREATE INDEX idx_payment_booking ON T_PAYMENT(t_booking_id);
CREATE INDEX idx_payment_status ON T_PAYMENT(c_payment_status_id);
CREATE INDEX idx_payment_processed_at ON T_PAYMENT(t_payment_processed_at);
CREATE INDEX idx_payment_transaction ON T_PAYMENT(t_payment_transaction_id);

-- Índice para T_REFUND
CREATE INDEX idx_refund_payment ON T_REFUND(t_payment_id);
CREATE INDEX idx_refund_processed_at ON T_REFUND(t_refund_processed_at);

-- Índice para T_INVOICE
CREATE INDEX idx_invoice_payment ON T_INVOICE(t_payment_id);
CREATE INDEX idx_invoice_issued_at ON T_INVOICE(t_invoice_issued_at);