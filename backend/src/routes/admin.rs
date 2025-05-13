use actix_web::{web, HttpResponse, Responder};
use serde_json::json;
use uuid::Uuid;

use crate::middleware::auth::AdminUser;
use crate::models::user::User;
use crate::AppState;

// Get all users (admin only)
pub async fn get_all_users(
    _admin_user: AdminUser,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for all users
    match client
        .query(
            "SELECT id, email, full_name, is_admin, created_at, updated_at, web3_wallet FROM users ORDER BY created_at DESC",
            &[],
        )
        .await
    {
        Ok(rows) => {
            let users: Vec<User> = rows
                .iter()
                .map(|row| User {
                    id: row.get("id"),
                    email: row.get("email"),
                    password_hash: None, // Don't return password hash
                    full_name: row.get("full_name"),
                    is_admin: row.get("is_admin"),
                    created_at: row.get("created_at"),
                    updated_at: row.get("updated_at"),
                    web3_wallet: row.get("web3_wallet"),
                })
                .collect();
            
            HttpResponse::Ok().json(users)
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Get user by ID (admin only)
pub async fn get_user_by_id(
    _admin_user: AdminUser,
    id: web::Path<Uuid>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for the user
    match client
        .query_opt(
            "SELECT id, email, full_name, is_admin, created_at, updated_at, web3_wallet FROM users WHERE id = $1",
            &[&id.into_inner()],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => {
                let user = User {
                    id: row.get("id"),
                    email: row.get("email"),
                    password_hash: None, // Don't return password hash
                    full_name: row.get("full_name"),
                    is_admin: row.get("is_admin"),
                    created_at: row.get("created_at"),
                    updated_at: row.get("updated_at"),
                    web3_wallet: row.get("web3_wallet"),
                };
                
                HttpResponse::Ok().json(user)
            }
            None => {
                HttpResponse::NotFound().json(json!({
                    "error": "User not found"
                }))
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Update user (admin only)
pub async fn update_user(
    _admin_user: AdminUser,
    id: web::Path<Uuid>,
    user_data: web::Json<serde_json::Value>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Check if user exists
    let user_exists = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM users WHERE id = $1)",
            &[&id.into_inner()],
        )
        .await
    {
        Ok(row) => row.get::<_, bool>(0),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    if !user_exists {
        return HttpResponse::NotFound().json(json!({
            "error": "User not found"
        }));
    }
    
    // Build update query
    let mut query = String::from("UPDATE users SET updated_at = NOW()");
    let mut params: Vec<&(dyn tokio_postgres::types::ToSql + Sync)> = Vec::new();
    let mut param_count = 1;
    
    if let Some(full_name) = user_data.get("full_name").and_then(|v| v.as_str()) {
        query.push_str(&format!(", full_name = ${}", param_count));
        params.push(&full_name);
        param_count += 1;
    }
    
    if let Some(email) = user_data.get("email").and_then(|v| v.as_str()) {
        query.push_str(&format!(", email = ${}", param_count));
        params.push(&email);
        param_count += 1;
    }
    
    if let Some(is_admin) = user_data.get("is_admin").and_then(|v| v.as_bool()) {
        query.push_str(&format!(", is_admin = ${}", param_count));
        params.push(&is_admin);
        param_count += 1;
    }
    
    if let Some(web3_wallet) = user_data.get("web3_wallet").and_then(|v| v.as_str()) {
        query.push_str(&format!(", web3_wallet = ${}", param_count));
        params.push(&web3_wallet);
        param_count += 1;
    }
    
    query.push_str(&format!(" WHERE id = ${}", param_count));
    params.push(&id);
    
    // Execute update
    match client.execute(&query, &params).await {
        Ok(_) => (),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for the updated user to return
    match client
        .query_one(
            "SELECT id, email, full_name, is_admin, created_at, updated_at, web3_wallet FROM users WHERE id = $1",
            &[&id],
        )
        .await
    {
        Ok(row) => {
            let user = User {
                id: row.get("id"),
                email: row.get("email"),
                password_hash: None, // Don't return password hash
                full_name: row.get("full_name"),
                is_admin: row.get("is_admin"),
                created_at: row.get("created_at"),
                updated_at: row.get("updated_at"),
                web3_wallet: row.get("web3_wallet"),
            };
            
            HttpResponse::Ok().json(user)
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Delete user (admin only)
pub async fn delete_user(
    _admin_user: AdminUser,
    id: web::Path<Uuid>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Delete user
    match client
        .execute("DELETE FROM users WHERE id = $1", &[&id.into_inner()])
        .await
    {
        Ok(count) => {
            if count == 0 {
                HttpResponse::NotFound().json(json!({
                    "error": "User not found"
                }))
            } else {
                HttpResponse::Ok().json(json!({
                    "message": "User deleted successfully"
                }))
            }
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Get admin statistics
pub async fn get_stats(
    _admin_user: AdminUser,
    data: web::Data<AppState>,
) -> impl Responder {
    let pg_db = &data.pg_pool;
    let mongo_db = &data.mongo_client.database("hex_the_add_hub");
    
    let client = match pg_db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get user count
    let user_count = match client
        .query_one("SELECT COUNT(*) FROM users", &[])
        .await
    {
        Ok(row) => row.get::<_, i64>(0),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get course count
    let course_count = match client
        .query_one("SELECT COUNT(*) FROM courses", &[])
        .await
    {
        Ok(row) => row.get::<_, i64>(0),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get enrollment count
    let enrollment_count = match client
        .query_one("SELECT COUNT(*) FROM user_enrollments", &[])
        .await
    {
        Ok(row) => row.get::<_, i64>(0),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get portfolio count from MongoDB
    let portfolio_count = match mongo_db
        .collection::<serde_json::Value>("portfolios")
        .count_documents(None, None)
        .await
    {
        Ok(count) => count,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get blog post count from MongoDB
    let blog_post_count = match mongo_db
        .collection::<serde_json::Value>("blog_posts")
        .count_documents(None, None)
        .await
    {
        Ok(count) => count,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get comment count from MongoDB
    let comment_count = match mongo_db
        .collection::<serde_json::Value>("blog_comments")
        .count_documents(None, None)
        .await
    {
        Ok(count) => count,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    HttpResponse::Ok().json(json!({
        "user_count": user_count,
        "course_count": course_count,
        "enrollment_count": enrollment_count,
        "portfolio_count": portfolio_count,
        "blog_post_count": blog_post_count,
        "comment_count": comment_count
    }))
}
