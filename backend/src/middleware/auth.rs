use actix_web::{
    dev::Payload, error::ErrorUnauthorized, http, web, Error, FromRequest, HttpRequest,
};
use chrono::{Duration, Utc};
use futures::future::{err, ok, Ready};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::env;
use uuid::Uuid;

use crate::models::user::User;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // User ID
    pub exp: i64,    // Expiration time
    pub iat: i64,    // Issued at
    pub admin: bool, // Is admin
}

pub struct AuthenticatedUser {
    pub user_id: Uuid,
    pub is_admin: bool,
}

impl FromRequest for AuthenticatedUser {
    type Error = Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        // Get authorization header
        let auth_header = match req.headers().get(http::header::AUTHORIZATION) {
            Some(header) => header,
            None => return err(ErrorUnauthorized("Missing authorization header")),
        };

        // Convert to string
        let auth_str = match auth_header.to_str() {
            Ok(s) => s,
            Err(_) => return err(ErrorUnauthorized("Invalid authorization header")),
        };

        // Check if it's a bearer token
        if !auth_str.starts_with("Bearer ") {
            return err(ErrorUnauthorized("Invalid authorization scheme"));
        }

        // Extract the token
        let token = &auth_str[7..];

        // Decode and validate token
        match validate_token(token) {
            Ok(claims) => {
                let user_id = match Uuid::parse_str(&claims.sub) {
                    Ok(id) => id,
                    Err(_) => return err(ErrorUnauthorized("Invalid user ID in token")),
                };

                ok(AuthenticatedUser {
                    user_id,
                    is_admin: claims.admin,
                })
            }
            Err(_) => err(ErrorUnauthorized("Invalid or expired token")),
        }
    }
}

pub fn validate_token(token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    let secret = env::var("JWT_SECRET").unwrap_or_else(|_| "default_secret".to_string());
    let key = DecodingKey::from_secret(secret.as_bytes());
    
    let validation = Validation::default();
    
    let token_data = decode::<Claims>(token, &key, &validation)?;
    
    Ok(token_data.claims)
}

pub fn generate_token(user: &User) -> Result<String, jsonwebtoken::errors::Error> {
    let secret = env::var("JWT_SECRET").unwrap_or_else(|_| "default_secret".to_string());
    let key = EncodingKey::from_secret(secret.as_bytes());
    
    let now = Utc::now();
    let expires_at = now + Duration::days(7);
    
    let claims = Claims {
        sub: user.id.to_string(),
        exp: expires_at.timestamp(),
        iat: now.timestamp(),
        admin: user.is_admin,
    };
    
    encode(&Header::default(), &claims, &key)
}

pub struct AdminUser {
    pub user_id: Uuid,
}

impl FromRequest for AdminUser {
    type Error = Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        // Get authenticated user
        let auth_user = match AuthenticatedUser::from_request(req, &mut Payload::None).into_inner() {
            Ok(user) => user,
            Err(e) => return err(e),
        };

        // Check if user is admin
        if !auth_user.is_admin {
            return err(ErrorUnauthorized("Admin privileges required"));
        }

        ok(AdminUser {
            user_id: auth_user.user_id,
        })
    }
}
