import React from 'react';
import { Link } from 'react-router-dom';

const Courses: React.FC = () => {
  return (
    <div className="container">
      <h1 className="page-title">Courses</h1>
      <p className="page-subtitle">Expand your knowledge with our comprehensive courses</p>
      
      <div className="courses-grid">
        {/* This will be replaced with dynamic data from API */}
        <div className="card course-card">
          <div className="card-badge">Popular</div>
          <img src="https://via.placeholder.com/300x200" alt="Introduction to Blockchain" className="card-img" />
          <div className="card-content">
            <h3 className="card-title">Introduction to Blockchain</h3>
            <p className="card-text">Learn the fundamentals of blockchain technology and its applications.</p>
            <div className="card-meta">
              <span className="price">Free</span>
              <span className="duration">8 weeks</span>
            </div>
            <Link to="/courses/1" className="btn btn-primary btn-block">View Course</Link>
          </div>
        </div>
        
        <div className="card course-card">
          <img src="https://via.placeholder.com/300x200" alt="Advanced React Development" className="card-img" />
          <div className="card-content">
            <h3 className="card-title">Advanced React Development</h3>
            <p className="card-text">Master modern React patterns and best practices for scalable applications.</p>
            <div className="card-meta">
              <span className="price">$49.99</span>
              <span className="duration">10 weeks</span>
            </div>
            <Link to="/courses/2" className="btn btn-primary btn-block">View Course</Link>
          </div>
        </div>
        
        <div className="card course-card">
          <div className="card-badge">New</div>
          <img src="https://via.placeholder.com/300x200" alt="Solana Development" className="card-img" />
          <div className="card-content">
            <h3 className="card-title">Solana Development</h3>
            <p className="card-text">Build scalable DApps on the Solana blockchain with Rust.</p>
            <div className="card-meta">
              <span className="price">$79.99</span>
              <span className="duration">12 weeks</span>
            </div>
            <Link to="/courses/3" className="btn btn-primary btn-block">View Course</Link>
          </div>
        </div>
        
        <div className="card course-card">
          <img src="https://via.placeholder.com/300x200" alt="Web3 Authentication" className="card-img" />
          <div className="card-content">
            <h3 className="card-title">Web3 Authentication</h3>
            <p className="card-text">Implement secure wallet-based authentication in your applications.</p>
            <div className="card-meta">
              <span className="price">$39.99</span>
              <span className="duration">6 weeks</span>
            </div>
            <Link to="/courses/4" className="btn btn-primary btn-block">View Course</Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Courses;