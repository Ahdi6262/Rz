use actix_web::{web, HttpResponse, Responder};
use serde_json::json;
use uuid::Uuid;

use crate::models::course::{
    Course, CourseLesson, CourseSection, CourseWithSections, CreateCourseRequest,
    CreateLessonRequest, CreateSectionRequest, SectionWithLessons, UpdateCourseRequest,
    UpdateProgressRequest,
};
use crate::middleware::auth::{AdminUser, AuthenticatedUser};
use crate::AppState;

// Get all courses
pub async fn get_all_courses(data: web::Data<AppState>) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for all courses
    match client
        .query(
            "SELECT id, title, description, price, is_free, created_at, updated_at, created_by FROM courses ORDER BY created_at DESC",
            &[],
        )
        .await
    {
        Ok(rows) => {
            let courses: Vec<Course> = rows
                .iter()
                .map(|row| Course {
                    id: row.get("id"),
                    title: row.get("title"),
                    description: row.get("description"),
                    price: row.get("price"),
                    is_free: row.get("is_free"),
                    created_at: row.get("created_at"),
                    updated_at: row.get("updated_at"),
                    created_by: row.get("created_by"),
                })
                .collect();
            
            HttpResponse::Ok().json(courses)
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Get course by ID with sections and lessons
pub async fn get_course_by_id(id: web::Path<Uuid>, data: web::Data<AppState>) -> impl Responder {
    let db = &data.pg_pool;
    
    let client = match db.get().await {
        Ok(client) => client,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for the course
    let course_row = match client
        .query_opt(
            "SELECT id, title, description, price, is_free, created_at, updated_at, created_by FROM courses WHERE id = $1",
            &[&id.into_inner()],
        )
        .await
    {
        Ok(maybe_row) => match maybe_row {
            Some(row) => row,
            None => {
                return HttpResponse::NotFound().json(json!({
                    "error": "Course not found"
                }));
            }
        },
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Parse the course data
    let course = Course {
        id: course_row.get("id"),
        title: course_row.get("title"),
        description: course_row.get("description"),
        price: course_row.get("price"),
        is_free: course_row.get("is_free"),
        created_at: course_row.get("created_at"),
        updated_at: course_row.get("updated_at"),
        created_by: course_row.get("created_by"),
    };
    
    // Query for sections
    let section_rows = match client
        .query(
            "SELECT id, course_id, title, description, position, created_at, updated_at FROM course_sections WHERE course_id = $1 ORDER BY position",
            &[&course.id],
        )
        .await
    {
        Ok(rows) => rows,
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Parse sections and fetch lessons for each
    let mut sections_with_lessons: Vec<SectionWithLessons> = Vec::new();
    
    for section_row in section_rows {
        let section = CourseSection {
            id: section_row.get("id"),
            course_id: section_row.get("course_id"),
            title: section_row.get("title"),
            description: section_row.get("description"),
            position: section_row.get("position"),
            created_at: section_row.get("created_at"),
            updated_at: section_row.get("updated_at"),
        };
        
        // Query for lessons
        let lesson_rows = match client
            .query(
                "SELECT id, section_id, title, content, video_url, position, created_at, updated_at FROM course_lessons WHERE section_id = $1 ORDER BY position",
                &[&section.id],
            )
            .await
        {
            Ok(rows) => rows,
            Err(e) => {
                return HttpResponse::InternalServerError().json(json!({
                    "error": format!("Database error: {}", e)
                }));
            }
        };
        
        // Parse lessons
        let lessons: Vec<CourseLesson> = lesson_rows
            .iter()
            .map(|row| CourseLesson {
                id: row.get("id"),
                section_id: row.get("section_id"),
                title: row.get("title"),
                content: row.get("content"),
                video_url: row.get("video_url"),
                position: row.get("position"),
                created_at: row.get("created_at"),
                updated_at: row.get("updated_at"),
            })
            .collect();
        
        sections_with_lessons.push(SectionWithLessons { section, lessons });
    }
    
    // Create the full course response
    let course_with_sections = CourseWithSections {
        course,
        sections: sections_with_lessons,
    };
    
    HttpResponse::Ok().json(course_with_sections)
}

// Create a course (admin only)
pub async fn create_course(
    admin_user: AdminUser,
    course_data: web::Json<CreateCourseRequest>,
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
    
    // Create new course
    let course_id = Uuid::new_v4();
    let now = chrono::Utc::now();
    
    // Insert course into database
    match client
        .execute(
            "INSERT INTO courses (id, title, description, price, is_free, created_at, updated_at, created_by) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
            &[
                &course_id,
                &course_data.title,
                &course_data.description,
                &course_data.price,
                &course_data.is_free,
                &now,
                &now,
                &admin_user.user_id,
            ],
        )
        .await
    {
        Ok(_) => (),
        Err(e) => {
            return HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }));
        }
    };
    
    // Query for the inserted course to return
    match client
        .query_one(
            "SELECT id, title, description, price, is_free, created_at, updated_at, created_by FROM courses WHERE id = $1",
            &[&course_id],
        )
        .await
    {
        Ok(row) => {
            let course = Course {
                id: row.get("id"),
                title: row.get("title"),
                description: row.get("description"),
                price: row.get("price"),
                is_free: row.get("is_free"),
                created_at: row.get("created_at"),
                updated_at: row.get("updated_at"),
                created_by: row.get("created_by"),
            };
            
            HttpResponse::Created().json(course)
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Update a course (admin only)
pub async fn update_course(
    admin_user: AdminUser,
    id: web::Path<Uuid>,
    update_data: web::Json<UpdateCourseRequest>,
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
    
    // Check if course exists
    let course_exists = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM courses WHERE id = $1)",
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
    
    if !course_exists {
        return HttpResponse::NotFound().json(json!({
            "error": "Course not found"
        }));
    }
    
    // Build update query
    let mut query = String::from("UPDATE courses SET updated_at = NOW()");
    let mut params: Vec<&(dyn tokio_postgres::types::ToSql + Sync)> = Vec::new();
    let mut param_count = 1;
    
    if let Some(title) = &update_data.title {
        query.push_str(&format!(", title = ${}", param_count));
        params.push(title);
        param_count += 1;
    }
    
    if let Some(description) = &update_data.description {
        query.push_str(&format!(", description = ${}", param_count));
        params.push(description);
        param_count += 1;
    }
    
    if let Some(price) = &update_data.price {
        query.push_str(&format!(", price = ${}", param_count));
        params.push(price);
        param_count += 1;
    }
    
    if let Some(is_free) = &update_data.is_free {
        query.push_str(&format!(", is_free = ${}", param_count));
        params.push(is_free);
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
    
    // Query for the updated course to return
    match client
        .query_one(
            "SELECT id, title, description, price, is_free, created_at, updated_at, created_by FROM courses WHERE id = $1",
            &[&id],
        )
        .await
    {
        Ok(row) => {
            let course = Course {
                id: row.get("id"),
                title: row.get("title"),
                description: row.get("description"),
                price: row.get("price"),
                is_free: row.get("is_free"),
                created_at: row.get("created_at"),
                updated_at: row.get("updated_at"),
                created_by: row.get("created_by"),
            };
            
            HttpResponse::Ok().json(course)
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Delete a course (admin only)
pub async fn delete_course(
    admin_user: AdminUser,
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
    
    // Delete course and all associated sections and lessons through cascading
    match client
        .execute("DELETE FROM courses WHERE id = $1", &[&id.into_inner()])
        .await
    {
        Ok(count) => {
            if count == 0 {
                HttpResponse::NotFound().json(json!({
                    "error": "Course not found"
                }))
            } else {
                HttpResponse::Ok().json(json!({
                    "message": "Course deleted successfully"
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

// Enroll in a course
pub async fn enroll_in_course(
    auth_user: AuthenticatedUser,
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
    
    // Check if course exists
    let course_exists = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM courses WHERE id = $1)",
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
    
    if !course_exists {
        return HttpResponse::NotFound().json(json!({
            "error": "Course not found"
        }));
    }
    
    // Check if user is already enrolled
    let already_enrolled = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM user_enrollments WHERE user_id = $1 AND course_id = $2)",
            &[&auth_user.user_id, &id],
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
    
    if already_enrolled {
        return HttpResponse::BadRequest().json(json!({
            "error": "You are already enrolled in this course"
        }));
    }
    
    // Enroll the user
    match client
        .execute(
            "INSERT INTO user_enrollments (user_id, course_id, enrolled_at) VALUES ($1, $2, NOW())",
            &[&auth_user.user_id, &id],
        )
        .await
    {
        Ok(_) => {
            HttpResponse::Created().json(json!({
                "message": "Enrolled in course successfully"
            }))
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}

// Update lesson progress
pub async fn update_progress(
    auth_user: AuthenticatedUser,
    id: web::Path<Uuid>,
    progress_data: web::Json<UpdateProgressRequest>,
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
    
    // Check if lesson exists
    let lesson_exists = match client
        .query_one(
            "SELECT EXISTS(SELECT 1 FROM course_lessons WHERE id = $1)",
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
    
    if !lesson_exists {
        return HttpResponse::NotFound().json(json!({
            "error": "Lesson not found"
        }));
    }
    
    // Check if the user is enrolled in the course that contains this lesson
    let is_enrolled = match client
        .query_one(
            "SELECT EXISTS(
                SELECT 1 FROM user_enrollments ue 
                JOIN course_sections cs ON ue.course_id = cs.course_id
                JOIN course_lessons cl ON cs.id = cl.section_id
                WHERE ue.user_id = $1 AND cl.id = $2
            )",
            &[&auth_user.user_id, &id],
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
    
    if !is_enrolled {
        return HttpResponse::Forbidden().json(json!({
            "error": "You are not enrolled in the course that contains this lesson"
        }));
    }
    
    // Update progress
    match client
        .execute(
            "INSERT INTO user_lesson_progress (user_id, lesson_id, completed, last_accessed) 
             VALUES ($1, $2, $3, NOW())
             ON CONFLICT (user_id, lesson_id) 
             DO UPDATE SET completed = $3, last_accessed = NOW()",
            &[&auth_user.user_id, &id, &progress_data.completed],
        )
        .await
    {
        Ok(_) => {
            HttpResponse::Ok().json(json!({
                "message": "Progress updated successfully"
            }))
        }
        Err(e) => {
            HttpResponse::InternalServerError().json(json!({
                "error": format!("Database error: {}", e)
            }))
        }
    }
}
