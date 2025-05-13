import React from 'react';
import { Link } from 'react-router-dom';

const Blog: React.FC = () => {
  // Sample blog posts - would be fetched from an API in a real application
  const blogPosts = [
    {
      id: 1,
      title: 'Getting Started with Solana Development',
      excerpt: 'Learn how to set up your development environment and build your first Solana program.',
      author: 'Alex Johnson',
      date: 'April 15, 2023',
      category: 'Development',
      image: 'https://via.placeholder.com/800x400',
      readTime: '8 min read'
    },
    {
      id: 2,
      title: 'Web3 Authentication Methods Compared',
      excerpt: 'A comprehensive comparison of different authentication methods in Web3 applications.',
      author: 'Maria Chen',
      date: 'March 28, 2023',
      category: 'Security',
      image: 'https://via.placeholder.com/800x400',
      readTime: '12 min read'
    },
    {
      id: 3,
      title: 'Building Effective Learning Platforms',
      excerpt: 'Essential components and best practices for creating engaging online learning experiences.',
      author: 'David Park',
      date: 'March 10, 2023',
      category: 'Education',
      image: 'https://via.placeholder.com/800x400',
      readTime: '10 min read'
    },
    {
      id: 4,
      title: 'The Future of Decentralized Finance',
      excerpt: 'Exploring emerging trends and innovations in the rapidly evolving DeFi landscape.',
      author: 'Sarah Williams',
      date: 'February 22, 2023',
      category: 'Finance',
      image: 'https://via.placeholder.com/800x400',
      readTime: '15 min read'
    },
    {
      id: 5,
      title: 'Optimizing React Performance in Large Applications',
      excerpt: 'Practical techniques to improve the performance of complex React applications.',
      author: 'Michael Lee',
      date: 'February 5, 2023',
      category: 'Development',
      image: 'https://via.placeholder.com/800x400',
      readTime: '11 min read'
    }
  ];

  const categories = ['All', 'Development', 'Security', 'Education', 'Finance', 'Web3'];

  return (
    <div className="container">
      <div className="blog-header">
        <h1 className="page-title">Blog</h1>
        <p className="page-subtitle">Insights, tutorials, and updates from our team</p>
      </div>
      
      <div className="blog-layout">
        <div className="blog-main">
          <div className="blog-filters">
            <div className="category-filters">
              {categories.map((category, index) => (
                <button key={index} className={`filter-btn ${index === 0 ? 'active' : ''}`}>
                  {category}
                </button>
              ))}
            </div>
            <div className="search-container">
              <input type="text" placeholder="Search articles..." className="search-input" />
              <button className="search-btn">Search</button>
            </div>
          </div>

          <div className="blog-posts">
            {blogPosts.map(post => (
              <div key={post.id} className="blog-card">
                <div className="blog-image">
                  <img src={post.image} alt={post.title} />
                  <div className="blog-category">{post.category}</div>
                </div>
                <div className="blog-content">
                  <h2 className="blog-title">
                    <Link to={`/blog/${post.id}`}>{post.title}</Link>
                  </h2>
                  <div className="blog-meta">
                    <span className="blog-author">By {post.author}</span>
                    <span className="blog-date">{post.date}</span>
                    <span className="blog-read-time">{post.readTime}</span>
                  </div>
                  <p className="blog-excerpt">{post.excerpt}</p>
                  <Link to={`/blog/${post.id}`} className="read-more">
                    Read More →
                  </Link>
                </div>
              </div>
            ))}
          </div>
          
          <div className="pagination">
            <button className="pagination-btn active">1</button>
            <button className="pagination-btn">2</button>
            <button className="pagination-btn">3</button>
            <button className="pagination-btn next">Next →</button>
          </div>
        </div>
        
        <div className="blog-sidebar">
          <div className="sidebar-widget">
            <h3 className="widget-title">Popular Posts</h3>
            <div className="popular-posts">
              {blogPosts.slice(0, 3).map(post => (
                <div key={post.id} className="popular-post">
                  <Link to={`/blog/${post.id}`} className="popular-post-title">
                    {post.title}
                  </Link>
                  <div className="popular-post-meta">
                    <span>{post.date}</span>
                    <span>{post.readTime}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="sidebar-widget">
            <h3 className="widget-title">Categories</h3>
            <ul className="categories-list">
              {categories.slice(1).map((category, index) => (
                <li key={index} className="category-item">
                  <a href="#" className="category-link">{category}</a>
                </li>
              ))}
            </ul>
          </div>
          
          <div className="sidebar-widget">
            <h3 className="widget-title">Subscribe</h3>
            <p>Get the latest posts delivered to your inbox</p>
            <form className="subscribe-form">
              <input 
                type="email" 
                placeholder="Your email address" 
                className="subscribe-input" 
                required 
              />
              <button type="submit" className="btn btn-primary btn-block">
                Subscribe
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Blog;