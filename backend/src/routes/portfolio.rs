use actix_web::{web, HttpResponse, Responder};
use mongodb::bson::{self, doc, oid::ObjectId};
use serde_json::json;

use crate::models::portfolio::{CreatePortfolioItemRequest, PortfolioItem, UpdatePortfolioItemRequest};
use crate::middleware::auth::AuthenticatedUser;
use crate::AppState;

// Get all projects for the authenticated user
pub async fn get_all_projects(
    auth_user: AuthenticatedUser,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<PortfolioItem>("portfolios");
    
    // Query for all projects belonging to the authenticated user
    let filter = doc! { "user_id": auth_user.user_id.to_string() };
    
    match collection.find(filter, None).await {
        Ok(cursor) => {
            // Convert cursor to vector of portfolio items
            match cursor.try_collect::<Vec<_>>().await {
                Ok(items) => HttpResponse::Ok().json(items),
                Err(e) => {
                    HttpResponse::InternalServerError().json(json!({
                        "error": format!("Failed to collect portfolio items: {}", e)
                    }))
                }
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Get a specific project by ID
pub async fn get_project_by_id(
    auth_user: AuthenticatedUser,
    id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<PortfolioItem>("portfolios");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Query for the specific project
    let filter = doc! {
        "_id": object_id,
        "user_id": auth_user.user_id.to_string()
    };
    
    match collection.find_one(filter, None).await {
        Ok(maybe_item) => {
            match maybe_item {
                Some(item) => HttpResponse::Ok().json(item),
                None => {
                    HttpResponse::NotFound().json(json!({
                        "error": "Portfolio item not found"
                    }))
                }
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Create a new project
pub async fn create_project(
    auth_user: AuthenticatedUser,
    project_data: web::Json<CreatePortfolioItemRequest>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<PortfolioItem>("portfolios");
    
    // Create new portfolio item
    let portfolio_item = PortfolioItem::new(
        auth_user.user_id,
        project_data.title.clone(),
        project_data.description.clone(),
        project_data.technologies.clone(),
        project_data.image_urls.clone(),
        project_data.project_url.clone(),
        project_data.github_url.clone(),
    );
    
    // Insert into database
    match collection.insert_one(portfolio_item, None).await {
        Ok(result) => {
            // Fetch the inserted item to return
            let filter = doc! { "_id": result.inserted_id };
            
            match collection.find_one(filter, None).await {
                Ok(maybe_item) => {
                    match maybe_item {
                        Some(item) => HttpResponse::Created().json(item),
                        None => {
                            HttpResponse::InternalServerError().json(json!({
                                "error": "Item created but could not be retrieved"
                            }))
                        }
                    }
                },
                Err(e) => {
                    HttpResponse::InternalServerError().json(json!({
                        "error": format!("Database error: {}", e)
                    }))
                }
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to create portfolio item: {}", e)
            }))
        }
    }
}

// Update a project
pub async fn update_project(
    auth_user: AuthenticatedUser,
    id: web::Path<String>,
    update_data: web::Json<UpdatePortfolioItemRequest>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<PortfolioItem>("portfolios");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Check if item exists and belongs to user
    let filter = doc! {
        "_id": object_id,
        "user_id": auth_user.user_id.to_string()
    };
    
    match collection.find_one(filter.clone(), None).await {
        Ok(maybe_item) => {
            if maybe_item.is_none() {
                return HttpResponse::NotFound().json(json!({
                    "error": "Portfolio item not found or you don't have permission to update it"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    }
    
    // Build update document
    let mut update_doc = doc! {};
    
    if let Some(title) = &update_data.title {
        update_doc.insert("title", title);
    }
    
    if let Some(description) = &update_data.description {
        update_doc.insert("description", description);
    }
    
    if let Some(technologies) = &update_data.technologies {
        update_doc.insert("technologies", technologies);
    }
    
    if let Some(image_urls) = &update_data.image_urls {
        update_doc.insert("image_urls", image_urls);
    }
    
    if let Some(project_url) = &update_data.project_url {
        update_doc.insert("project_url", project_url);
    }
    
    if let Some(github_url) = &update_data.github_url {
        update_doc.insert("github_url", github_url);
    }
    
    // Add updated_at timestamp
    update_doc.insert("updated_at", chrono::Utc::now());
    
    // Update in database
    let update = doc! { "$set": update_doc };
    
    match collection.update_one(filter, update, None).await {
        Ok(result) => {
            if result.modified_count == 0 {
                HttpResponse::NotModified().json(json!({
                    "message": "No changes were made"
                }))
            } else {
                // Fetch the updated item to return
                let filter = doc! { "_id": object_id };
                
                match collection.find_one(filter, None).await {
                    Ok(maybe_item) => {
                        match maybe_item {
                            Some(item) => HttpResponse::Ok().json(item),
                            None => {
                                HttpResponse::InternalServerError().json(json!({
                                    "error": "Item updated but could not be retrieved"
                                }))
                            }
                        }
                    },
                    Err(e) => {
                        HttpResponse::InternalServerError().json(json!({
                            "error": format!("Database error: {}", e)
                        }))
                    }
                }
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to update portfolio item: {}", e)
            }))
        }
    }
}

// Delete a project
pub async fn delete_project(
    auth_user: AuthenticatedUser,
    id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<PortfolioItem>("portfolios");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Check if item exists and belongs to user
    let filter = doc! {
        "_id": object_id,
        "user_id": auth_user.user_id.to_string()
    };
    
    // Delete from database
    match collection.delete_one(filter, None).await {
        Ok(result) => {
            if result.deleted_count == 0 {
                HttpResponse::NotFound().json(json!({
                    "error": "Portfolio item not found or you don't have permission to delete it"
                }))
            } else {
                HttpResponse::Ok().json(json!({
                    "message": "Portfolio item deleted successfully"
                }))
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to delete portfolio item: {}", e)
            }))
        }
    }
}
