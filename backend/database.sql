-- Secure Vault Database Schema

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Vaults Table
CREATE TABLE vaults (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    encrypted_master_key TEXT NOT NULL, -- Encrypted with user's key
    salt BYTEA NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_accessed TIMESTAMP,
    is_synced BOOLEAN DEFAULT FALSE
);

-- Files Metadata Table
CREATE TABLE files_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vault_id UUID REFERENCES vaults(id) ON DELETE CASCADE,
    encrypted_name TEXT NOT NULL,
    file_type VARCHAR(50),
    size BIGINT,
    encrypted_path TEXT, -- Local path on device
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    device_id VARCHAR(255), -- Which device this file is on
    is_backed_up BOOLEAN DEFAULT FALSE -- If backed up to cloud
);

-- Indexes
CREATE INDEX idx_vaults_user_id ON vaults(user_id);
CREATE INDEX idx_files_vault_id ON files_metadata(vault_id);
CREATE INDEX idx_users_email ON users(email);
