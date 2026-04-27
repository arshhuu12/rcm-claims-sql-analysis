CREATE DATABASE IF NOT EXISTS rcm_claims;
USE rcm_claims;

-- Table 1: Providers (physicians)
CREATE TABLE providers (
    provider_id INT PRIMARY KEY,
    provider_name VARCHAR(100),
    specialization VARCHAR(100),
    department VARCHAR(100)
);

-- Table 2: Payers (insurance companies)
CREATE TABLE payers (
    payer_id INT PRIMARY KEY,
    payer_name VARCHAR(100),
    payer_type VARCHAR(50)
);

-- Table 3: Claims (main table)
CREATE TABLE claims (
    claim_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20),
    provider_id INT,
    payer_id INT,
    service_date DATE,
    submission_date DATE,
    billed_amount DECIMAL(10,2),
    paid_amount DECIMAL(10,2),
    adjustment_amount DECIMAL(10,2),
    status VARCHAR(20),
    denial_reason VARCHAR(100),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    FOREIGN KEY (payer_id) REFERENCES payers(payer_id)
);