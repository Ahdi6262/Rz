use actix_web::{web, HttpResponse, Responder};
use mongodb::bson::{self, doc, oid::ObjectId};
use serde_json::json;

use crate::models::blog::{BlogComment, BlogPost, CreateBlogPostRequest, CreateCommentRequest, UpdateBlogPostRequest};
use crate::middleware::auth::{AdminUser, AuthenticatedUser};
use crate::AppState;

// Get all published blog posts
pub async fn get_all_posts(data: web::Data<AppState>) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<BlogPost>("blog_posts");
    
    // Query for all published posts
    let filter = doc! { "published": true };
    let options = mongodb::options::FindOptions::builder()
        .sort(doc! { "created_at": -1 })
        .build();
    
    match collection.find(filter, options).await {
        Ok(cursor) => {
            // Convert cursor to vector of blog posts
            match cursor.try_collect::<Vec<_>>().await {
                Ok(posts) => HttpResponse::Ok().json(posts),
                Err(e) => {
                    HttpResponse::InternalServerError().json(json!({
                        "error": format!("Failed to collect blog posts: {}", e)
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

// Get a specific blog post by ID
pub async fn get_post_by_id(id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<BlogPost>("blog_posts");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Query for the specific post
    let filter = doc! {
        "_id": object_id,
        "published": true
    };
    
    match collection.find_one(filter, None).await {
        Ok(maybe_post) => {
            match maybe_post {
                Some(post) => HttpResponse::Ok().json(post),
                None => {
                    HttpResponse::NotFound().json(json!({
                        "error": "Blog post not found"
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

// Create a new blog post (admin only)
pub async fn create_post(
    admin_user: AdminUser,
    post_data: web::Json<CreateBlogPostRequest>,
    data: web::Data<AppState>,
) -> impl Responder {
    let mongo_db = &data.mongo_client.database("hex_the_add_hub");
    let collection = mongo_db.collection::<BlogPost>("blog_posts");
    
    let pg_db = &data.pg_pool;
    
    // Get admin user details
    let client = match pg_db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Get admin user's name
    let user_row = match client
        .query_opt(
            "SELECT full_name FROM users WHERE id = $1",
            &[&admin_user.user_id],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::InternalServerError().json(json!({
                    "error": "Admin user not found"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    let author_name: String = user_row.get("full_name");
    
    // Create new blog post
    let blog_post = BlogPost::new(
        post_data.title.clone(),
        post_data.content.clone(),
        admin_user.user_id,
        author_name,
        post_data.tags.clone(),
        post_data.published,
        post_data.featured_image.clone(),
    );
    
    // Insert into database
    match collection.insert_one(blog_post, None).await {
        Ok(result) => {
            // Fetch the inserted post to return
            let filter = doc! { "_id": result.inserted_id };
            
            match collection.find_one(filter, None).await {
                Ok(maybe_post) => {
                    match maybe_post {
                        Some(post) => HttpResponse::Created().json(post),
                        None => {
                            HttpResponse::InternalServerError().json(json!({
                                "error": "Post created but could not be retrieved"
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
                "error": format!("Failed to create blog post: {}", e)
            }))
        }
    }
}

// Update a blog post (admin only)
pub async fn update_post(
    admin_user: AdminUser,
    id: web::Path<String>,
    update_data: web::Json<UpdateBlogPostRequest>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<BlogPost>("blog_posts");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Check if post exists
    let filter = doc! { "_id": object_id };
    
    match collection.find_one(filter.clone(), None).await {
        Ok(maybe_post) => {
            if maybe_post.is_none() {
                return HttpResponse::NotFound().json(json!({
                    "error": "Blog post not found"
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
    
    if let Some(content) = &update_data.content {
        update_doc.insert("content", content);
    }
    
    if let Some(tags) = &update_data.tags {
        update_doc.insert("tags", tags);
    }
    
    if let Some(published) = &update_data.published {
        update_doc.insert("published", published);
    }
    
    if let Some(featured_image) = &update_data.featured_image {
        update_doc.insert("featured_image", featured_image);
    }
    
    // Add updated_at timestamp
    update_doc.insert("updated_at", chrono::Utc::now());
    
    // Update in database
    let update = doc! { "$set": update_doc };
    
    match collection.update_one(filter.clone(), update, None).await {
        Ok(result) => {
            if result.modified_count == 0 {
                HttpResponse::NotModified().json(json!({
                    "message": "No changes were made"
                }))
            } else {
                // Fetch the updated post to return
                match collection.find_one(filter, None).await {
                    Ok(maybe_post) => {
                        match maybe_post {
                            Some(post) => HttpResponse::Ok().json(post),
                            None => {
                                HttpResponse::InternalServerError().json(json!({
                                    "error": "Post updated but could not be retrieved"
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
                "error": format!("Failed to update blog post: {}", e)
            }))
        }
    }
}

// Delete a blog post (admin only)
pub async fn delete_post(
    admin_user: AdminUser,
    id: web::Path<String>,
    data: web::Data<AppState>,
) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let posts_collection = db.collection::<BlogPost>("blog_posts");
    let comments_collection = db.collection::<BlogComment>("blog_comments");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Check if post exists
    let filter = doc! { "_id": object_id };
    
    match posts_collection.find_one(filter.clone(), None).await {
        Ok(maybe_post) => {
            if maybe_post.is_none() {
                return HttpResponse::NotFound().json(json!({
                    "error": "Blog post not found"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    }
    
    // Delete all comments for the post
    let comments_filter = doc! { "post_id": object_id };
    
    match comments_collection.delete_many(comments_filter, None).await {
        Ok(_) => (),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to delete comments: {}", e)
            }));
        }
    }
    
    // Delete the post
    match posts_collection.delete_one(filter, None).await {
        Ok(result) => {
            if result.deleted_count == 0 {
                HttpResponse::NotFound().json(json!({
                    "error": "Blog post not found"
                }))
            } else {
                HttpResponse::Ok().json(json!({
                    "message": "Blog post and comments deleted successfully"
                }))
            }
        },
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Failed to delete blog post: {}", e)
            }))
        }
    }
}

// Get comments for a blog post
pub async fn get_comments(id: web::Path<String>, data: web::Data<AppState>) -> impl Responder {
    let db = &data.mongo_client.database("hex_the_add_hub");
    let collection = db.collection::<BlogComment>("blog_comments");
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Query for comments for the post
    let filter = doc! { "post_id": object_id };
    let options = mongodb::options::FindOptions::builder()
        .sort(doc! { "created_at": 1 })
        .build();
    
    match collection.find(filter, options).await {
        Ok(cursor) => {
            // Convert cursor to vector of comments
            match cursor.try_collect::<Vec<_>>().await {
                Ok(comments) => HttpResponse::Ok().json(comments),
                Err(e) => {
                    HttpResponse::InternalServerError().json(json!({
                        "error": format!("Failed to collect comments: {}", e)
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

// Add a comment to a blog post
pub async fn add_comment(
    auth_user: AuthenticatedUser,
    id: web::Path<String>,
    comment_data: web::Json<CreateCommentRequest>,
    data: web::Data<AppState>,
) -> impl Responder {
    let mongo_db = &data.mongo_client.database("hex_the_add_hub");
    let posts_collection = mongo_db.collection::<BlogPost>("blog_posts");
    let comments_collection = mongo_db.collection::<BlogComment>("blog_comments");
    
    let pg_db = &data.pg_pool;
    
    // Parse ObjectId from path
    let object_id = match ObjectId::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return HttpResponse::BadRequest().json(json!({
                "error": "Invalid ID format"
            }));
        }
    };
    
    // Check if post exists and is published
    let filter = doc! { 
        "_id": object_id,
        "published": true
    };
    
    match posts_collection.find_one(filter, None).await {
        Ok(maybe_post) => {
            if maybe_post.is_none() {
                return HttpResponse::NotFound().json(json!({
                    "error": "Blog post not found or not published"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    }
    
    // Get user's name
    let client = match pg_db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    let user_row = match client
        .query_opt(
            "SELECT full_name FROM users WHERE id = $1",
            &[&auth_user.user_id],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::InternalServerError().json(json!({
                    "error": "User not found"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    let user_name: String = user_row.get("full_name");
    
    // Create new comment
    let comment = BlogComment::new(
        object_id,
        auth_user.user_id,
        user_name,
        comment_data.content.clone(),
    );
    
    // Insert into database
    match comments_collection.insert_one(comment, None).await {
        Ok(result) => {
            // Fetch the inserted comment to return
            let filter = doc! { "_id": result.inserted_id };
            
            match comments_collection.find_one(filter, None).await {
                Ok(maybe_comment) => {
                    match maybe_comment {
                        Some(comment) => HttpResponse::Created().json(comment),
                        None => {
                            HttpResponse::InternalServerError().json(json!({
                                "error": "Comment created but could not be retrieved"
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
                "error": format!("Failed to create comment: {}", e)
            }))
        }
    }
}
