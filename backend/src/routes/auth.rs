use actix_web::{web, HttpResponse, Responder};
use bcrypt::{hash, verify, DEFAULT_COST};
use chrono::Utc;
use uuid::Uuid;

use crate::models::user::{
    AuthResponse, CreateUserRequest, LoginRequest, User, Web3LoginRequest,
};
use crate::middleware::auth::generate_token;
use crate::AppState;

// Register a new user
pub async fn register(
    data: web::Data<AppState>,
    user_data: web::Json<CreateUserRequest>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Check if user already exists
    let email_exists = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)",
            &[&user_data.email],
        )
        .await
    {
        Ok(row) => row.get::<_, bool>(0),
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    if email_exists {
        return HttpResponse::BadRequest().json(serde_json::json!({
            "error": "Email already exists"
        }));
    }
    
    // Check if wallet already exists (if provided)
    if let Some(wallet) = &user_data.web3_wallet {
        let wallet_exists = match client
            .query_one(
                "SELECT EXISTS(SELECT 1 FROM users WHERE web3_wallet = $1)",
                &[&wallet],
            )
            .await
        {
            Ok(row) => row.get::<_, bool>(0),
            Err(e) => {
                return HttpResponse::InternalServerError().json(serde_json::json!({
                    "error": format!("Database error: {}", e)
                }));
            }
        };
        
        if wallet_exists {
            return HttpResponse::BadRequest().json(serde_json::json!({
                "error": "Wallet address already registered"
            }));
        }
    }
    
    // Hash password if provided
    let password_hash = match &user_data.password {
        Some(password) => {
            match hash(password, DEFAULT_COST) {
                Ok(hashed) => Some(hashed),
                Err(_) => {
                    return HttpResponse::InternalServerError().json(serde_json::json!({
                        "error": "Failed to hash password"
                    }));
                }
            }
        }
        None => None,
    };
    
    // If no password and no wallet, return error
    if password_hash.is_none() && user_data.web3_wallet.is_none() {
        return HttpResponse::BadRequest().json(serde_json::json!({
            "error": "Either password or web3 wallet must be provided"
        }));
    }
    
    // Create new user
    let user_id = Uuid::new_v4();
    let now = Utc::now();
    
    // Insert user into database
    match client
        .execute(
            "INSERT INTO users (id, email, password_hash, full_name, is_admin, created_at, updated_at, web3_wallet) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
            &[
                &user_id,
                &user_data.email,
                &password_hash,
                &user_data.full_name,
                &false, // is_admin
                &now,
                &now,
                &user_data.web3_wallet,
            ],
        )
        .await
    {
        Ok(_) => (),
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Create user object
    let user = User {
        id: user_id,
        email: user_data.email.clone(),
        password_hash: None, // Don't return password hash
        full_name: user_data.full_name.clone(),
        is_admin: false,
        created_at: now,
        updated_at: now,
        web3_wallet: user_data.web3_wallet.clone(),
    };
    
    // Generate JWT token
    let token = match generate_token(&user) {
        Ok(token) => token,
        Err(_) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to generate token"
            }));
        }
    };
    
    HttpResponse::Created().json(AuthResponse { token, user })
}

// Login with email and password
pub async fn login(
    data: web::Data<AppState>,
    login_data: web::Json<LoginRequest>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Find user by email
    let user_row = match client
        .query_opt(
            "SELECT id, email, password_hash, full_name, is_admin, created_at, updated_at, web3_wallet FROM users WHERE email = $1",
            &[&login_data.email],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::Unauthorized().json(serde_json::json!({
                    "error": "Invalid email or password"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Verify password
    let password_hash: Option<String> = user_row.get("password_hash");
    
    match password_hash {
        Some(hash) => {
            let is_valid = match verify(&login_data.password, &hash) {
                Ok(valid) => valid,
                Err(_) => {
                    return HttpResponse::InternalServerError().json(serde_json::json!({
                        "error": "Password verification failed"
                    }));
                }
            };
            
            if !is_valid {
                return HttpResponse::Unauthorized().json(serde_json::json!({
                    "error": "Invalid email or password"
                }));
            }
        }
        None => {
            return HttpResponse::Unauthorized().json(serde_json::json!({
                "error": "This account does not have a password set"
            }));
        }
    }
    
    // Create user object
    let user = User {
        id: user_row.get("id"),
        email: user_row.get("email"),
        password_hash: None, // Don't return password hash
        full_name: user_row.get("full_name"),
        is_admin: user_row.get("is_admin"),
        created_at: user_row.get("created_at"),
        updated_at: user_row.get("updated_at"),
        web3_wallet: user_row.get("web3_wallet"),
    };
    
    // Generate JWT token
    let token = match generate_token(&user) {
        Ok(token) => token,
        Err(_) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to generate token"
            }));
        }
    };
    
    HttpResponse::Ok().json(AuthResponse { token, user })
}

// Web3 login with Solana wallet
pub async fn web3_login(
    data: web::Data<AppState>,
    login_data: web::Json<Web3LoginRequest>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    // This is a simplified web3 login that would normally validate a signed message
    // In a real implementation, you would use Solana's libraries to verify the signature
    
    // For now, we're just checking if the wallet exists in our database
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Find user by wallet address
    let user_row = match client
        .query_opt(
            "SELECT id, email, password_hash, full_name, is_admin, created_at, updated_at, web3_wallet FROM users WHERE web3_wallet = $1",
            &[&login_data.wallet_address],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::Unauthorized().json(serde_json::json!({
                    "error": "Wallet not registered"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // In a real-world application, you would verify the signature here
    // This would involve using Solana's libraries to verify that the signature
    // was created by the wallet address and matches the expected message
    
    // Create user object
    let user = User {
        id: user_row.get("id"),
        email: user_row.get("email"),
        password_hash: None, // Don't return password hash
        full_name: user_row.get("full_name"),
        is_admin: user_row.get("is_admin"),
        created_at: user_row.get("created_at"),
        updated_at: user_row.get("updated_at"),
        web3_wallet: user_row.get("web3_wallet"),
    };
    
    // Generate JWT token
    let token = match generate_token(&user) {
        Ok(token) => token,
        Err(_) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to generate token"
            }));
        }
    };
    
    HttpResponse::Ok().json(AuthResponse { token, user })
}

// Logout (client-side only)
pub async fn logout() -> impl Responder {
    // This is a client-side logout - just return success
    HttpResponse::Ok().json(serde_json::json!({
        "message": "Logged out successfully"
    }))
}

// Get current user
pub async fn get_current_user(
    auth_user: crate::middleware::auth::AuthenticatedUser,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Find user by ID
    let user_row = match client
        .query_opt(
            "SELECT id, email, password_hash, full_name, is_admin, created_at, updated_at, web3_wallet FROM users WHERE id = $1",
            &[&auth_user.user_id],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::NotFound().json(serde_json::json!({
                    "error": "User not found"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(serde_json::json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Create user object
    let user = User {
        id: user_row.get("id"),
        email: user_row.get("email"),
        password_hash: None, // Don't return password hash
        full_name: user_row.get("full_name"),
        is_admin: user_row.get("is_admin"),
        created_at: user_row.get("created_at"),
        updated_at: user_row.get("updated_at"),
        web3_wallet: user_row.get("web3_wallet"),
    };
    
    HttpResponse::Ok().json(user)
}
