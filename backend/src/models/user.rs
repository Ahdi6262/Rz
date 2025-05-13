use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    #[serde(skip_serializing)]
    pub password_hash: Option<String>,
    pub full_name: String,
    pub is_admin: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub web3_wallet: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateUserRequest {
    pub email: String,
    pub password: Option<String>,
    pub full_name: String,
    pub web3_wallet: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Web3LoginRequest {
    pub wallet_address: String,
    pub message: String,
    pub signature: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AuthResponse {
    pub token: String,
    pub user: User,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserProfile {
    pub user_id: Uuid,
    pub bio: Option<String>,
    pub profile_picture: Option<String>,
    pub social_links: SocialLinks,
    pub skills: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SocialLinks {
    pub twitter: Option<String>,
    pub linkedin: Option<String>,
    pub github: Option<String>,
    pub website: Option<String>,
}

impl User {
    pub fn new(
        email: String, 
        password_hash: Option<String>, 
        full_name: String,
        web3_wallet: Option<String>
    ) -> Self {
        User {
            id: Uuid::new_v4(),
            email,
            password_hash,
            full_name,
            is_admin: false,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            web3_wallet,
        }
    }
}
