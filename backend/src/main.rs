mod db;
mod middleware;
mod models;
mod routes;

use actix_cors::Cors;
use actix_web::{http, middleware::Logger, web, App, HttpServer};
use dotenv::dotenv;
use log::info;
use std::env;

use crate::db::{mongodb::init_mongodb, postgres::init_postgres};
use crate::routes::{admin, auth, blog, courses, portfolio};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Load environment variables
    dotenv().ok();
    env_logger::init();

    // Initialize database connections
    let pg_pool = init_postgres().await.expect("Failed to initialize PostgreSQL");
    let mongo_client = init_mongodb().await.expect("Failed to initialize MongoDB");

    // Create app data
    let app_data = web::Data::new(AppState {
        pg_pool: pg_pool.clone(),
        mongo_client: mongo_client.clone(),
    });

    info!("Starting HTTP server at http://0.0.0.0:8000");

    // Start HTTP server
    HttpServer::new(move || {
        let cors = Cors::default()
            .allowed_origin("http://localhost:5000")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
            .allowed_headers(vec![http::header::AUTHORIZATION, http::header::ACCEPT])
            .allowed_header(http::header::CONTENT_TYPE)
            .max_age(3600);

        App::new()
            .wrap(cors)
            .wrap(Logger::default())
            .app_data(app_data.clone())
            // Auth routes
            .service(
                web::scope("/api/auth")
                    .route("/register", web::post().to(auth::register))
                    .route("/login", web::post().to(auth::login))
                    .route("/web3/login", web::post().to(auth::web3_login))
                    .route("/logout", web::post().to(auth::logout))
                    .route("/me", web::get().to(auth::get_current_user)),
            )
            // Portfolio routes
            .service(
                web::scope("/api/portfolio")
                    .route("", web::get().to(portfolio::get_all_projects))
                    .route("/{id}", web::get().to(portfolio::get_project_by_id))
                    .route("", web::post().to(portfolio::create_project))
                    .route("/{id}", web::put().to(portfolio::update_project))
                    .route("/{id}", web::delete().to(portfolio::delete_project)),
            )
            // Course routes
            .service(
                web::scope("/api/courses")
                    .route("", web::get().to(courses::get_all_courses))
                    .route("/{id}", web::get().to(courses::get_course_by_id))
                    .route("", web::post().to(courses::create_course))
                    .route("/{id}", web::put().to(courses::update_course))
                    .route("/{id}", web::delete().to(courses::delete_course))
                    .route("/enroll/{id}", web::post().to(courses::enroll_in_course))
                    .route("/progress/{id}", web::post().to(courses::update_progress)),
            )
            // Blog routes
            .service(
                web::scope("/api/blog")
                    .route("", web::get().to(blog::get_all_posts))
                    .route("/{id}", web::get().to(blog::get_post_by_id))
                    .route("", web::post().to(blog::create_post))
                    .route("/{id}", web::put().to(blog::update_post))
                    .route("/{id}", web::delete().to(blog::delete_post))
                    .route("/{id}/comments", web::get().to(blog::get_comments))
                    .route("/{id}/comments", web::post().to(blog::add_comment)),
            )
            // Admin routes
            .service(
                web::scope("/api/admin")
                    .route("/users", web::get().to(admin::get_all_users))
                    .route("/users/{id}", web::get().to(admin::get_user_by_id))
                    .route("/users/{id}", web::put().to(admin::update_user))
                    .route("/users/{id}", web::delete().to(admin::delete_user))
                    .route("/stats", web::get().to(admin::get_stats)),
            )
    })
    .bind(("0.0.0.0", 8000))?
    .run()
    .await
}

pub struct AppState {
    pg_pool: deadpool_postgres::Pool,
    mongo_client: mongodb::Client,
}
