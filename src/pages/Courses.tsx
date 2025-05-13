import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import './Courses.css';

interface Course {
  id: number;
  title: string;
  description: string;
  image: string;
  price: string;
  duration: string;
  badge?: string;
  category: string;
  level: string;
}

const Courses: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState<Course[]>([]);
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedLevel, setSelectedLevel] = useState('All');
  const [isLoading, setIsLoading] = useState(false);
  
  // Sample course data - in a real app, this would come from an API
  const coursesData: Course[] = [
    {
      id: 1,
      title: 'Introduction to Blockchain',
      description: 'Learn the fundamentals of blockchain technology and its applications.',
      image: 'https://via.placeholder.com/300x200',
      price: 'Free',
      duration: '8 weeks',
      badge: 'Popular',
      category: 'Blockchain',
      level: 'Beginner'
    },
    {
      id: 2,
      title: 'Advanced React Development',
      description: 'Master modern React patterns and best practices for scalable applications.',
      image: 'https://via.placeholder.com/300x200',
      price: '$49.99',
      duration: '10 weeks',
      category: 'Web Development',
      level: 'Advanced'
    },
    {
      id: 3,
      title: 'Solana Development',
      description: 'Build scalable DApps on the Solana blockchain with Rust.',
      image: 'https://via.placeholder.com/300x200',
      price: '$79.99',
      duration: '12 weeks',
      badge: 'New',
      category: 'Blockchain',
      level: 'Intermediate'
    },
    {
      id: 4,
      title: 'Web3 Authentication',
      description: 'Implement secure wallet-based authentication in your applications.',
      image: 'https://via.placeholder.com/300x200',
      price: '$39.99',
      duration: '6 weeks',
      category: 'Security',
      level: 'Intermediate'
    },
    {
      id: 5,
      title: 'Rust for Systems Programming',
      description: 'Learn how to use Rust for high-performance systems programming tasks.',
      image: 'https://via.placeholder.com/300x200',
      price: '$59.99',
      duration: '8 weeks',
      category: 'Programming',
      level: 'Intermediate'
    },
    {
      id: 6,
      title: 'Smart Contract Development',
      description: 'Build secure and efficient smart contracts on multiple blockchain platforms.',
      image: 'https://via.placeholder.com/300x200',
      price: '$69.99',
      duration: '10 weeks',
      category: 'Blockchain',
      level: 'Advanced'
    }
  ];
  
  const categories = ['All', 'Blockchain', 'Web Development', 'Security', 'Programming'];
  const levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  
  // This would actually call our Rust backend API in a real implementation
  const searchCourses = async (term: string, category: string, level: string) => {
    setIsLoading(true);
    
    try {
      // Simulate API call to Rust backend
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Filter courses based on search criteria
      let results = [...coursesData];
      
      if (term) {
        const lowercaseTerm = term.toLowerCase();
        results = results.filter(course => 
          course.title.toLowerCase().includes(lowercaseTerm) || 
          course.description.toLowerCase().includes(lowercaseTerm)
        );
      }
      
      if (category !== 'All') {
        results = results.filter(course => course.category === category);
      }
      
      if (level !== 'All') {
        results = results.filter(course => course.level === level);
      }
      
      setSearchResults(results);
    } catch (error) {
      console.error('Error searching courses:', error);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Trigger search when any of the search criteria change
  useEffect(() => {
    searchCourses(searchTerm, selectedCategory, selectedLevel);
  }, [searchTerm, selectedCategory, selectedLevel]);
  
  return (
    <div className="container">
      <h1 className="page-title">Courses</h1>
      <p className="page-subtitle">Expand your knowledge with our comprehensive courses</p>
      
      <div className="search-container">
        <div className="search-box">
          <input 
            type="text" 
            placeholder="Search courses..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          <button className="search-button">
            <i className="fas fa-search"></i>
          </button>
        </div>
        
        <div className="filter-container">
          <div className="filter-group">
            <label htmlFor="category-filter">Category:</label>
            <select 
              id="category-filter" 
              className="filter-select"
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
            >
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>
          
          <div className="filter-group">
            <label htmlFor="level-filter">Level:</label>
            <select 
              id="level-filter" 
              className="filter-select"
              value={selectedLevel}
              onChange={(e) => setSelectedLevel(e.target.value)}
            >
              {levels.map(level => (
                <option key={level} value={level}>{level}</option>
              ))}
            </select>
          </div>
        </div>
      </div>
      
      {isLoading ? (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Searching courses...</p>
        </div>
      ) : searchResults.length === 0 ? (
        <div className="no-results">
          <p>No courses found matching your search criteria.</p>
          <button 
            className="btn btn-outline"
            onClick={() => {
              setSearchTerm('');
              setSelectedCategory('All');
              setSelectedLevel('All');
            }}
          >
            Clear Filters
          </button>
        </div>
      ) : (
        <div className="courses-grid">
          {searchResults.map(course => (
            <div key={course.id} className="card course-card">
              {course.badge && <div className="card-badge">{course.badge}</div>}
              <img src={course.image} alt={course.title} className="card-img" />
              <div className="card-content">
                <div className="card-tags">
                  <span className="card-tag">{course.category}</span>
                  <span className="card-tag">{course.level}</span>
                </div>
                <h3 className="card-title">{course.title}</h3>
                <p className="card-text">{course.description}</p>
                <div className="card-meta">
                  <span className="price">{course.price}</span>
                  <span className="duration">{course.duration}</span>
                </div>
                <Link to={`/courses/${course.id}`} className="btn btn-primary btn-block">View Course</Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Courses;