use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Course {
    pub id: Uuid,
    pub title: String,
    pub description: String,
    pub price: f64,
    pub is_free: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub created_by: Uuid,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct CourseSection {
    pub id: Uuid,
    pub course_id: Uuid,
    pub title: String,
    pub description: Option<String>,
    pub position: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct CourseLesson {
    pub id: Uuid,
    pub section_id: Uuid,
    pub title: String,
    pub content: Option<String>,
    pub video_url: Option<String>,
    pub position: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserEnrollment {
    pub user_id: Uuid,
    pub course_id: Uuid,
    pub enrolled_at: DateTime<Utc>,
    pub completed_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserLessonProgress {
    pub user_id: Uuid,
    pub lesson_id: Uuid,
    pub completed: bool,
    pub last_accessed: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCourseRequest {
    pub title: String,
    pub description: String,
    pub price: f64,
    pub is_free: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateCourseRequest {
    pub title: Option<String>,
    pub description: Option<String>,
    pub price: Option<f64>,
    pub is_free: Option<bool>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateSectionRequest {
    pub course_id: Uuid,
    pub title: String,
    pub description: Option<String>,
    pub position: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateLessonRequest {
    pub section_id: Uuid,
    pub title: String,
    pub content: Option<String>,
    pub video_url: Option<String>,
    pub position: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateProgressRequest {
    pub completed: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CourseWithSections {
    pub course: Course,
    pub sections: Vec<SectionWithLessons>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SectionWithLessons {
    pub section: CourseSection,
    pub lessons: Vec<CourseLesson>,
}

impl Course {
    pub fn new(
        title: String,
        description: String,
        price: f64,
        is_free: bool,
        created_by: Uuid,
    ) -> Self {
        Course {
            id: Uuid::new_v4(),
            title,
            description,
            price,
            is_free,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            created_by,
        }
    }
}

impl CourseSection {
    pub fn new(
        course_id: Uuid,
        title: String,
        description: Option<String>,
        position: i32,
    ) -> Self {
        CourseSection {
            id: Uuid::new_v4(),
            course_id,
            title,
            description,
            position,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }
}

impl CourseLesson {
    pub fn new(
        section_id: Uuid,
        title: String,
        content: Option<String>,
        video_url: Option<String>,
        position: i32,
    ) -> Self {
        CourseLesson {
            id: Uuid::new_v4(),
            section_id,
            title,
            content,
            video_url,
            position,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }
}
