use mongodb::{Client, options::ClientOptions};
use std::env;

pub async fn init_mongodb() -> Result<Client, mongodb::error::Error> {
    // Get MongoDB connection string from environment variables or use default
    let mongo_uri = env::var("MONGODB_URI").unwrap_or_else(|_| "mongodb://localhost:27017".to_string());
    
    // Parse a connection string into an options struct
    let mut client_options = ClientOptions::parse(&mongo_uri).await?;
    
    // Manually set an option
    client_options.app_name = Some("hex_the_add_hub".to_string());
    
    // Create a new client and connect to the server
    let client = Client::with_options(client_options)?;
    
    // Ping the server to see if you can connect to the database
    client
        .database("admin")
        .run_command(mongodb::bson::doc! {"ping": 1}, None)
        .await?;
    
    println!("Connected to MongoDB successfully");
    
    // Create collections if they don't exist
    let db = client.database("hex_the_add_hub");
    
    // This will create the collections if they don't exist when we first insert a document
    // For now, we're just listing the collections we plan to use
    let collections = ["portfolios", "blog_posts", "blog_comments", "user_profiles"];
    
    for collection in collections.iter() {
        match db.collection::<mongodb::bson::Document>(collection).count_documents(None, None).await {
            Ok(_) => println!("Collection '{}' exists", collection),
            Err(e) => println!("Error checking collection '{}': {}", collection, e),
        }
    }
    
    Ok(client)
}
