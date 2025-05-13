use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BlogPost {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<bson::oid::ObjectId>,
    pub title: String,
    pub content: String,
    pub author_id: Uuid,
    pub author_name: String,
    pub tags: Vec<String>,
    pub published: bool,
    pub featured_image: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BlogComment {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<bson::oid::ObjectId>,
    pub post_id: bson::oid::ObjectId,
    pub user_id: Uuid,
    pub user_name: String,
    pub content: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateBlogPostRequest {
    pub title: String,
    pub content: String,
    pub tags: Vec<String>,
    pub published: bool,
    pub featured_image: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateBlogPostRequest {
    pub title: Option<String>,
    pub content: Option<String>,
    pub tags: Option<Vec<String>>,
    pub published: Option<bool>,
    pub featured_image: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCommentRequest {
    pub content: String,
}

impl BlogPost {
    pub fn new(
        title: String,
        content: String,
        author_id: Uuid,
        author_name: String,
        tags: Vec<String>,
        published: bool,
        featured_image: Option<String>,
    ) -> Self {
        BlogPost {
            id: None,
            title,
            content,
            author_id,
            author_name,
            tags,
            published,
            featured_image,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }
}

impl BlogComment {
    pub fn new(
        post_id: bson::oid::ObjectId,
        user_id: Uuid,
        user_name: String,
        content: String,
    ) -> Self {
        BlogComment {
            id: None,
            post_id,
            user_id,
            user_name,
            content,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }
}
