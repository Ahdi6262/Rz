import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import './Header.css';

const Header: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const location = useLocation();
  
  // Check if user is logged in - would be replaced with actual auth state
  const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
  
  // Handle scroll event to change header style
  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.scrollY;
      setIsScrolled(scrollPosition > 50);
    };
    
    window.addEventListener('scroll', handleScroll);
    
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);
  
  // Close mobile menu when route changes
  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [location]);
  
  // Toggle mobile menu
  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
  };
  
  // Check if a nav link is active
  const isActive = (path: string) => {
    return location.pathname === path;
  };
  
  return (
    <header className={`header ${isScrolled ? 'scrolled' : ''}`}>
      <div className="container header-container">
        <div className="logo">
          <Link to="/">
            <span className="logo-text">HEX THE ADD HUB</span>
          </Link>
        </div>
        
        <div className="mobile-toggle" onClick={toggleMobileMenu}>
          <div className={`hamburger ${isMobileMenuOpen ? 'open' : ''}`}>
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
        
        <nav className={`main-nav ${isMobileMenuOpen ? 'open' : ''}`}>
          <ul className="nav-links">
            <li className={isActive('/') ? 'active' : ''}>
              <Link to="/">Home</Link>
            </li>
            <li className={isActive('/courses') ? 'active' : ''}>
              <Link to="/courses">Courses</Link>
            </li>
            <li className={isActive('/portfolio') ? 'active' : ''}>
              <Link to="/portfolio">Portfolio</Link>
            </li>
            <li className={isActive('/blog') ? 'active' : ''}>
              <Link to="/blog">Blog</Link>
            </li>
          </ul>
          
          <div className="nav-buttons">
            {isLoggedIn ? (
              <>
                <Link to="/dashboard" className="btn btn-outline">Dashboard</Link>
                <button 
                  className="btn btn-outline" 
                  onClick={() => {
                    localStorage.removeItem('isLoggedIn');
                    window.location.href = '/';
                  }}
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="btn btn-outline">Login</Link>
                <Link to="/register" className="btn btn-primary">Register</Link>
              </>
            )}
          </div>
        </nav>
      </div>
    </header>
  );
};

export default Header;