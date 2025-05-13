use actix_web::{web, HttpResponse, Error};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Mutex;
use crate::AppState;
use super::algorithms::{InvertedIndex, SearchDocument, SearchResult};

// Shared state for the search index
pub struct SearchState {
    pub courses_index: Mutex<InvertedIndex>,
    pub portfolio_index: Mutex<InvertedIndex>,
    pub blog_index: Mutex<InvertedIndex>,
}

impl SearchState {
    pub fn new() -> Self {
        SearchState {
            courses_index: Mutex::new(InvertedIndex::new()),
            portfolio_index: Mutex::new(InvertedIndex::new()),
            blog_index: Mutex::new(InvertedIndex::new()),
        }
    }
}

// Search request model
#[derive(Debug, Deserialize)]
pub struct SearchRequest {
    pub query: String,
    pub filters: Option<HashMap<String, String>>,
    pub limit: Option<usize>,
}

// Search response model
#[derive(Debug, Serialize)]
pub struct SearchResponse {
    pub results: Vec<SearchResult>,
    pub total: usize,
}

// Initialize the search indices
pub async fn initialize_search_indices(app_state: &web::Data<AppState>, search_state: &web::Data<SearchState>) -> Result<(), Error> {
    // Initialize courses index
    let courses = get_courses_data(app_state).await?;
    let mut courses_index = search_state.courses_index.lock().unwrap();
    for course in courses {
        courses_index.add_document(course);
    }
    
    // Initialize portfolio index
    let portfolio_items = get_portfolio_data(app_state).await?;
    let mut portfolio_index = search_state.portfolio_index.lock().unwrap();
    for item in portfolio_items {
        portfolio_index.add_document(item);
    }
    
    // Initialize blog index
    let blog_posts = get_blog_data(app_state).await?;
    let mut blog_index = search_state.blog_index.lock().unwrap();
    for post in blog_posts {
        blog_index.add_document(post);
    }
    
    Ok(())
}

// Retrieve courses data from database
async fn get_courses_data(app_state: &web::Data<AppState>) -> Result<Vec<SearchDocument>, Error> {
    // In a real application, this would query the database
    // For now, we'll return some sample data
    let pg_pool = &app_state.pg_pool;
    
    // Sample SQL query:
    // let client = pg_pool.get().await.map_err(|e| {
    //     eprintln!("Error connecting to database: {}", e);
    //     HttpResponse::InternalServerError().finish()
    // })?;
    //
    // let rows = client
    //     .query("SELECT id, title, description, level, category FROM courses", &[])
    //     .await
    //     .map_err(|e| {
    //         eprintln!("Error querying database: {}", e);
    //         HttpResponse::InternalServerError().finish()
    //     })?;
    
    // Here we're returning mock data instead of actual DB data
    let mut courses = Vec::new();
    
    // Sample course 1
    let mut metadata1 = HashMap::new();
    metadata1.insert("category".to_string(), "Blockchain".to_string());
    metadata1.insert("level".to_string(), "Beginner".to_string());
    courses.push(SearchDocument {
        id: "1".to_string(),
        title: "Introduction to Blockchain".to_string(),
        content: "Learn the fundamentals of blockchain technology and its applications. This course covers the basic concepts of distributed ledgers, consensus mechanisms, and smart contracts.".to_string(),
        metadata: metadata1,
    });
    
    // Sample course 2
    let mut metadata2 = HashMap::new();
    metadata2.insert("category".to_string(), "Web Development".to_string());
    metadata2.insert("level".to_string(), "Advanced".to_string());
    courses.push(SearchDocument {
        id: "2".to_string(),
        title: "Advanced React Development".to_string(),
        content: "Master modern React patterns and best practices for scalable applications. Topics include component patterns, state management, performance optimization, and testing strategies.".to_string(),
        metadata: metadata2,
    });
    
    // Sample course 3
    let mut metadata3 = HashMap::new();
    metadata3.insert("category".to_string(), "Blockchain".to_string());
    metadata3.insert("level".to_string(), "Intermediate".to_string());
    courses.push(SearchDocument {
        id: "3".to_string(),
        title: "Solana Development".to_string(),
        content: "Build scalable DApps on the Solana blockchain with Rust. Learn about Solana's programming model, account structure, and how to create secure and efficient smart contracts.".to_string(),
        metadata: metadata3,
    });
    
    Ok(courses)
}

// Retrieve portfolio data from database
async fn get_portfolio_data(app_state: &web::Data<AppState>) -> Result<Vec<SearchDocument>, Error> {
    // Similar to get_courses_data, this would query the database in a real app
    let mut portfolio_items = Vec::new();
    
    // Sample portfolio item 1
    let mut metadata1 = HashMap::new();
    metadata1.insert("category".to_string(), "Web3".to_string());
    metadata1.insert("technology".to_string(), "Solana, React, TypeScript".to_string());
    portfolio_items.push(SearchDocument {
        id: "1".to_string(),
        title: "DeFi Dashboard".to_string(),
        content: "A comprehensive dashboard for DeFi users to track their investments across multiple protocols. Features include portfolio tracking, historical performance, yield farming analytics, and risk assessment tools.".to_string(),
        metadata: metadata1,
    });
    
    // Sample portfolio item 2
    let mut metadata2 = HashMap::new();
    metadata2.insert("category".to_string(), "Blockchain".to_string());
    metadata2.insert("technology".to_string(), "Rust, Anchor, React, Solana".to_string());
    portfolio_items.push(SearchDocument {
        id: "2".to_string(),
        title: "NFT Marketplace".to_string(),
        content: "A fully-featured NFT marketplace built on Solana with trading and minting capabilities. Users can create, buy, sell, and auction digital collectibles with low transaction fees and carbon-neutral operations.".to_string(),
        metadata: metadata2,
    });
    
    Ok(portfolio_items)
}

// Retrieve blog data from database
async fn get_blog_data(app_state: &web::Data<AppState>) -> Result<Vec<SearchDocument>, Error> {
    // Similar to above, this would query the database in a real app
    let mut blog_posts = Vec::new();
    
    // Sample blog post 1
    let mut metadata1 = HashMap::new();
    metadata1.insert("category".to_string(), "Development".to_string());
    metadata1.insert("tags".to_string(), "Solana, Rust, Blockchain, Web3".to_string());
    blog_posts.push(SearchDocument {
        id: "1".to_string(),
        title: "Getting Started with Solana Development".to_string(),
        content: "Learn how to set up your development environment and build your first Solana program. This guide walks through the process of installing the Solana CLI, setting up your development environment, and creating a simple smart contract using the Rust programming language and the Anchor framework.".to_string(),
        metadata: metadata1,
    });
    
    // Sample blog post 2
    let mut metadata2 = HashMap::new();
    metadata2.insert("category".to_string(), "Security".to_string());
    metadata2.insert("tags".to_string(), "Authentication, Web3, Security, Wallet".to_string());
    blog_posts.push(SearchDocument {
        id: "2".to_string(),
        title: "Web3 Authentication Methods Compared".to_string(),
        content: "A comprehensive comparison of different authentication methods in Web3 applications. We examine traditional username/password systems versus wallet-based authentication, exploring the security implications, user experience considerations, and implementation complexity of each approach.".to_string(),
        metadata: metadata2,
    });
    
    Ok(blog_posts)
}

// Search courses endpoint
pub async fn search_courses(
    app_state: web::Data<AppState>,
    search_state: web::Data<SearchState>,
    req: web::Json<SearchRequest>,
) -> Result<HttpResponse, Error> {
    let courses_index = search_state.courses_index.lock().unwrap();
    
    let limit = req.limit.unwrap_or(10);
    let mut results = courses_index.search(&req.query, limit);
    
    // Apply filters if any
    if let Some(ref filters) = req.filters {
        results = courses_index.filter_by_metadata(results, filters);
    }
    
    Ok(HttpResponse::Ok().json(SearchResponse {
        results,
        total: results.len(),
    }))
}

// Search portfolio endpoint
pub async fn search_portfolio(
    app_state: web::Data<AppState>,
    search_state: web::Data<SearchState>,
    req: web::Json<SearchRequest>,
) -> Result<HttpResponse, Error> {
    let portfolio_index = search_state.portfolio_index.lock().unwrap();
    
    let limit = req.limit.unwrap_or(10);
    let mut results = portfolio_index.search(&req.query, limit);
    
    // Apply filters if any
    if let Some(ref filters) = req.filters {
        results = portfolio_index.filter_by_metadata(results, filters);
    }
    
    Ok(HttpResponse::Ok().json(SearchResponse {
        results,
        total: results.len(),
    }))
}

// Search blog endpoint
pub async fn search_blog(
    app_state: web::Data<AppState>,
    search_state: web::Data<SearchState>,
    req: web::Json<SearchRequest>,
) -> Result<HttpResponse, Error> {
    let blog_index = search_state.blog_index.lock().unwrap();
    
    let limit = req.limit.unwrap_or(10);
    let mut results = blog_index.search(&req.query, limit);
    
    // Apply filters if any
    if let Some(ref filters) = req.filters {
        results = blog_index.filter_by_metadata(results, filters);
    }
    
    Ok(HttpResponse::Ok().json(SearchResponse {
        results,
        total: results.len(),
    }))
}

// Global search endpoint (searches across all indices)
pub async fn search_all(
    app_state: web::Data<AppState>,
    search_state: web::Data<SearchState>,
    req: web::Json<SearchRequest>,
) -> Result<HttpResponse, Error> {
    let courses_index = search_state.courses_index.lock().unwrap();
    let portfolio_index = search_state.portfolio_index.lock().unwrap();
    let blog_index = search_state.blog_index.lock().unwrap();
    
    let limit = req.limit.unwrap_or(30); // Higher limit for global search
    
    // Search each index
    let mut course_results = courses_index.search(&req.query, limit / 3);
    let mut portfolio_results = portfolio_index.search(&req.query, limit / 3);
    let mut blog_results = blog_index.search(&req.query, limit / 3);
    
    // Apply filters if any
    if let Some(ref filters) = req.filters {
        course_results = courses_index.filter_by_metadata(course_results, filters);
        portfolio_results = portfolio_index.filter_by_metadata(portfolio_results, filters);
        blog_results = blog_index.filter_by_metadata(blog_results, filters);
    }
    
    // Combine results
    let mut combined_results = Vec::new();
    combined_results.extend(course_results);
    combined_results.extend(portfolio_results);
    combined_results.extend(blog_results);
    
    // Sort by score (descending)
    combined_results.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap_or(std::cmp::Ordering::Equal));
    
    // Limit the number of results
    combined_results.truncate(limit);
    
    Ok(HttpResponse::Ok().json(SearchResponse {
        results: combined_results,
        total: combined_results.len(),
    }))
}