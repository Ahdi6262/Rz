import React from 'react';
import { Link } from 'react-router-dom';
import './Footer.css';

const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();
  
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-grid">
          <div className="footer-column">
            <div className="footer-logo">
              <h3 className="logo-text">HEX THE ADD HUB</h3>
            </div>
            <p className="footer-description">
              A cross-platform hub integrating Web2 and Web3 technologies, 
              featuring portfolio management, courses, and blog functionality.
            </p>
            <div className="social-links">
              <a href="#" className="social-link" aria-label="Twitter">
                <i className="fab fa-twitter"></i>
              </a>
              <a href="#" className="social-link" aria-label="Discord">
                <i className="fab fa-discord"></i>
              </a>
              <a href="#" className="social-link" aria-label="GitHub">
                <i className="fab fa-github"></i>
              </a>
              <a href="#" className="social-link" aria-label="Telegram">
                <i className="fab fa-telegram"></i>
              </a>
            </div>
          </div>
          
          <div className="footer-column">
            <h4 className="footer-heading">Navigate</h4>
            <ul className="footer-links">
              <li><Link to="/">Home</Link></li>
              <li><Link to="/courses">Courses</Link></li>
              <li><Link to="/portfolio">Portfolio</Link></li>
              <li><Link to="/blog">Blog</Link></li>
            </ul>
          </div>
          
          <div className="footer-column">
            <h4 className="footer-heading">Resources</h4>
            <ul className="footer-links">
              <li><Link to="/faq">FAQ</Link></li>
              <li><Link to="/documentation">Documentation</Link></li>
              <li><Link to="/tutorials">Tutorials</Link></li>
              <li><Link to="/community">Community</Link></li>
            </ul>
          </div>
          
          <div className="footer-column">
            <h4 className="footer-heading">Contact</h4>
            <p className="contact-info">
              <i className="fas fa-envelope"></i> info@hextheaddhub.com
            </p>
            <p className="contact-info">
              <i className="fas fa-map-marker-alt"></i> 123 Blockchain Avenue, Crypto City
            </p>
            
            <form className="subscribe-form">
              <input 
                type="email" 
                placeholder="Your email address" 
                required 
                className="subscribe-input"
              />
              <button type="submit" className="subscribe-btn">
                Subscribe
              </button>
            </form>
          </div>
        </div>
        
        <div className="footer-bottom">
          <div className="copyright">
            &copy; {currentYear} HEX THE ADD HUB. All rights reserved.
          </div>
          <div className="footer-bottom-links">
            <Link to="/privacy">Privacy Policy</Link>
            <Link to="/terms">Terms of Service</Link>
            <Link to="/cookies">Cookie Policy</Link>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;