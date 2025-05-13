use deadpool_postgres::{Config, ManagerConfig, Pool, RecyclingMethod, Runtime};
use std::env;
use tokio_postgres::NoTls;

pub async fn init_postgres() -> Result<Pool, Box<dyn std::error::Error>> {
    let mut cfg = Config::new();
    
    cfg.host = Some(env::var("PGHOST").unwrap_or_else(|_| "localhost".to_string()));
    cfg.port = Some(env::var("PGPORT").unwrap_or_else(|_| "5432".to_string()).parse::<u16>()?);
    cfg.user = Some(env::var("PGUSER").unwrap_or_else(|_| "postgres".to_string()));
    cfg.password = Some(env::var("PGPASSWORD").unwrap_or_else(|_| "password".to_string()));
    cfg.dbname = Some(env::var("PGDATABASE").unwrap_or_else(|_| "hex_the_add_hub".to_string()));
    
    cfg.manager = Some(ManagerConfig {
        recycling_method: RecyclingMethod::Fast,
    });
    
    let pool = cfg.create_pool(Some(Runtime::Tokio1), NoTls)?;
    
    // Test connection
    let client = pool.get().await?;
    let result = client.query("SELECT 1", &[]).await?;
    
    if result.len() != 1 {
        return Err("Failed to connect to PostgreSQL".into());
    }
    
    // Initialize schema if needed
    let client = pool.get().await?;
    
    client.batch_execute("
        -- Users table
        CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255),
            full_name VARCHAR(255) NOT NULL,
            is_admin BOOLEAN NOT NULL DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            web3_wallet VARCHAR(255) UNIQUE
        );
        
        -- Course table
        CREATE TABLE IF NOT EXISTS courses (
            id UUID PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            price DECIMAL(10, 2) NOT NULL DEFAULT 0,
            is_free BOOLEAN NOT NULL DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            created_by UUID REFERENCES users(id)
        );
        
        -- Course sections table
        CREATE TABLE IF NOT EXISTS course_sections (
            id UUID PRIMARY KEY,
            course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            position INTEGER NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
        );
        
        -- Course lessons table
        CREATE TABLE IF NOT EXISTS course_lessons (
            id UUID PRIMARY KEY,
            section_id UUID REFERENCES course_sections(id) ON DELETE CASCADE,
            title VARCHAR(255) NOT NULL,
            content TEXT,
            video_url VARCHAR(255),
            position INTEGER NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
        );
        
        -- User course enrollments
        CREATE TABLE IF NOT EXISTS user_enrollments (
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
            enrolled_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            completed_at TIMESTAMP WITH TIME ZONE,
            PRIMARY KEY (user_id, course_id)
        );
        
        -- User lesson progress
        CREATE TABLE IF NOT EXISTS user_lesson_progress (
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            lesson_id UUID REFERENCES course_lessons(id) ON DELETE CASCADE,
            completed BOOLEAN NOT NULL DEFAULT false,
            last_accessed TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            PRIMARY KEY (user_id, lesson_id)
        );
    ").await?;
    
    Ok(pool)
}
