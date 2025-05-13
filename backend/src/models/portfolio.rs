use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct PortfolioItem {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<bson::oid::ObjectId>,
    pub user_id: Uuid,
    pub title: String,
    pub description: String,
    pub technologies: Vec<String>,
    pub image_urls: Vec<String>,
    pub project_url: Option<String>,
    pub github_url: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreatePortfolioItemRequest {
    pub title: String,
    pub description: String,
    pub technologies: Vec<String>,
    pub image_urls: Vec<String>,
    pub project_url: Option<String>,
    pub github_url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdatePortfolioItemRequest {
    pub title: Option<String>,
    pub description: Option<String>,
    pub technologies: Option<Vec<String>>,
    pub image_urls: Option<Vec<String>>,
    pub project_url: Option<String>,
    pub github_url: Option<String>,
}

impl PortfolioItem {
    pub fn new(
        user_id: Uuid,
        title: String,
        description: String,
        technologies: Vec<String>,
        image_urls: Vec<String>,
        project_url: Option<String>,
        github_url: Option<String>,
    ) -> Self {
        PortfolioItem {
            id: None,
            user_id,
            title,
            description,
            technologies,
            image_urls,
            project_url,
            github_url,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }
}
