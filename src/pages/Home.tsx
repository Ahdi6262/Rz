import React from 'react';
import { Link } from 'react-router-dom';
import './Home.css';

const Home: React.FC = () => {
  return (
    <div className="home-page">
      {/* Hero Section */}
      <section className="hero">
        <div className="container hero-container">
          <div className="hero-content">
            <h1>Welcome to HEX THE ADD HUB</h1>
            <p>A cross-platform hub integrating Web2 and Web3 technologies, featuring portfolio management, courses, and blog functionality.</p>
            <div className="hero-buttons">
              <Link to="/courses" className="btn btn-primary">Explore Courses</Link>
              <Link to="/register" className="btn btn-outline">Get Started</Link>
            </div>
          </div>
          <div className="hero-image">
            <div className="hexagon-container">
              <div className="hexagon"></div>
              <div className="hexagon"></div>
              <div className="hexagon"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features">
        <div className="container">
          <h2 className="section-title">Our Features</h2>
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">
                <i className="fas fa-briefcase"></i>
              </div>
              <h3>Portfolio Management</h3>
              <p>Track and showcase your projects, skills, and achievements in a professional portfolio.</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">
                <i className="fas fa-graduation-cap"></i>
              </div>
              <h3>Interactive Courses</h3>
              <p>Learn at your own pace with our interactive and comprehensive courses.</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">
                <i className="fas fa-blog"></i>
              </div>
              <h3>Community Blog</h3>
              <p>Share your knowledge and insights with the community through our blog platform.</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">
                <i className="fas fa-wallet"></i>
              </div>
              <h3>Web3 Integration</h3>
              <p>Connect your Solana wallet for Web3 authentication and token-gated content.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Courses Section */}
      <section className="featured-courses">
        <div className="container">
          <h2 className="section-title">Featured Courses</h2>
          <div className="courses-grid">
            {/* Course cards would be dynamically generated from API data */}
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
          </div>
          <div className="view-all-container">
            <Link to="/courses" className="btn btn-outline">View All Courses</Link>
          </div>
        </div>
      </section>

      {/* Call to Action Section */}
      <section className="cta">
        <div className="container">
          <div className="cta-content">
            <h2>Ready to Start Your Journey?</h2>
            <p>Join our community of learners and builders today.</p>
            <Link to="/register" className="btn btn-primary">Get Started Now</Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;