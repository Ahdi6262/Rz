use actix_web::{
    dev::ServiceRequest,
    error::Error,
    web,
    HttpMessage,
};
use actix_web_httpauth::extractors::{
    bearer::{BearerAuth, Config},
    AuthenticationError,
};
use jsonwebtoken::{decode, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use std::env;

use crate::AppState;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,
    pub exp: usize,
    pub role: String,
}

// Middleware validator function for JWT token authentication
pub async fn jwt_validator(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, Error> {
    let jwt_secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set");
    let config = req
        .app_data::<Config>()
        .cloned()
        .unwrap_or_else(Default::default);

    match validate_token(credentials.token(), &jwt_secret) {
        Ok(claims) => {
            req.extensions_mut().insert(claims);
            Ok(req)
        }
        Err(_) => {
            Err(AuthenticationError::from(config).into())
        }
    }
}

// Validate JWT token and extract claims
fn validate_token(token: &str, secret: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    let validation = Validation::default();
    let key = DecodingKey::from_secret(secret.as_bytes());
    let token_data = decode::<Claims>(token, &key, &validation)?;
    Ok(token_data.claims)
}

// Extract user ID from request
pub fn extract_user_id(req: &ServiceRequest) -> Option<String> {
    req.extensions().get::<Claims>().map(|claims| claims.sub.clone())
}

// Check if user has admin role
pub fn is_admin(req: &ServiceRequest) -> bool {
    req.extensions()
        .get::<Claims>()
        .map(|claims| claims.role == "admin")
        .unwrap_or(false)
}