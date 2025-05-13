import React from 'react';
import { useParams, Link } from 'react-router-dom';

const CourseDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  
  // Placeholder course data - this would be fetched from an API in a real application
  const course = {
    id,
    title: 'Introduction to Blockchain',
    description: 'Learn the fundamentals of blockchain technology and its applications.',
    longDescription: `
      This comprehensive course covers the core concepts of blockchain technology, 
      from the basics of distributed ledgers to advanced topics like consensus algorithms 
      and smart contracts. You'll gain hands-on experience building simple blockchain 
      applications and understand how this revolutionary technology is changing 
      various industries.
    `,
    price: 'Free',
    duration: '8 weeks',
    instructor: 'Alex Johnson',
    instructorTitle: 'Blockchain Developer',
    instructorBio: 'Alex has been developing blockchain applications for over 5 years and has contributed to several major projects.',
    topics: [
      'Blockchain Fundamentals',
      'Cryptography Basics',
      'Consensus Mechanisms',
      'Smart Contracts',
      'Decentralized Applications',
      'Blockchain Use Cases',
      'Future of Blockchain'
    ],
    modules: [
      {
        title: 'Introduction to Blockchain',
        lessons: [
          'What is Blockchain?',
          'History of Blockchain',
          'Blockchain vs. Traditional Databases'
        ]
      },
      {
        title: 'Cryptography Fundamentals',
        lessons: [
          'Hashing Functions',
          'Public/Private Keys',
          'Digital Signatures'
        ]
      },
      {
        title: 'Consensus Mechanisms',
        lessons: [
          'Proof of Work',
          'Proof of Stake',
          'Alternative Consensus Methods'
        ]
      }
    ]
  };
  
  return (
    <div className="container">
      <div className="course-detail">
        <div className="course-header">
          <h1 className="course-title">{course.title}</h1>
          <div className="course-meta">
            <span className="price">{course.price}</span>
            <span className="duration">{course.duration}</span>
          </div>
          <button className="btn btn-primary">Enroll Now</button>
        </div>
        
        <div className="course-content">
          <div className="course-main">
            <div className="course-section">
              <h2>About This Course</h2>
              <p>{course.longDescription}</p>
            </div>
            
            <div className="course-section">
              <h2>What You'll Learn</h2>
              <ul className="topics-list">
                {course.topics.map((topic, index) => (
                  <li key={index}>{topic}</li>
                ))}
              </ul>
            </div>
            
            <div className="course-section">
              <h2>Course Content</h2>
              <div className="modules-list">
                {course.modules.map((module, index) => (
                  <div key={index} className="module-item">
                    <h3 className="module-title">{module.title}</h3>
                    <ul className="lessons-list">
                      {module.lessons.map((lesson, lessonIndex) => (
                        <li key={lessonIndex}>{lesson}</li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          </div>
          
          <div className="course-sidebar">
            <div className="instructor-card">
              <h3>Your Instructor</h3>
              <div className="instructor-info">
                <div className="instructor-avatar">
                  <img src="https://via.placeholder.com/100" alt={course.instructor} />
                </div>
                <div className="instructor-details">
                  <h4>{course.instructor}</h4>
                  <p className="instructor-title">{course.instructorTitle}</p>
                </div>
              </div>
              <p className="instructor-bio">{course.instructorBio}</p>
            </div>
          </div>
        </div>
      </div>
      
      <div className="course-actions">
        <Link to="/courses" className="btn btn-outline">Back to Courses</Link>
      </div>
    </div>
  );
};

export default CourseDetail;