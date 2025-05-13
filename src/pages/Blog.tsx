import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import './Blog.css';

interface BlogPost {
  id: number;
  title: string;
  excerpt: string;
  author: string;
  date: string;
  category: string;
  image: string;
  readTime: string;
  tags?: string[];
}

const Blog: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [filteredPosts, setFilteredPosts] = useState<BlogPost[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  
  // Sample blog posts - would be fetched from an API in a real application
  const blogPosts: BlogPost[] = [
    {
      id: 1,
      title: 'Getting Started with Solana Development',
      excerpt: 'Learn how to set up your development environment and build your first Solana program.',
      author: 'Alex Johnson',
      date: 'April 15, 2023',
      category: 'Development',
      image: 'https://via.placeholder.com/800x400',
      readTime: '8 min read',
      tags: ['Solana', 'Rust', 'Blockchain', 'Web3']
    },
    {
      id: 2,
      title: 'Web3 Authentication Methods Compared',
      excerpt: 'A comprehensive comparison of different authentication methods in Web3 applications.',
      author: 'Maria Chen',
      date: 'March 28, 2023',
      category: 'Security',
      image: 'https://via.placeholder.com/800x400',
      readTime: '12 min read',
      tags: ['Authentication', 'Web3', 'Security', 'Wallet']
    },
    {
      id: 3,
      title: 'Building Effective Learning Platforms',
      excerpt: 'Essential components and best practices for creating engaging online learning experiences.',
      author: 'David Park',
      date: 'March 10, 2023',
      category: 'Education',
      image: 'https://via.placeholder.com/800x400',
      readTime: '10 min read',
      tags: ['Learning', 'Education', 'UX', 'Design']
    },
    {
      id: 4,
      title: 'The Future of Decentralized Finance',
      excerpt: 'Exploring emerging trends and innovations in the rapidly evolving DeFi landscape.',
      author: 'Sarah Williams',
      date: 'February 22, 2023',
      category: 'Finance',
      image: 'https://via.placeholder.com/800x400',
      readTime: '15 min read',
      tags: ['DeFi', 'Finance', 'Blockchain', 'Crypto']
    },
    {
      id: 5,
      title: 'Optimizing React Performance in Large Applications',
      excerpt: 'Practical techniques to improve the performance of complex React applications.',
      author: 'Michael Lee',
      date: 'February 5, 2023',
      category: 'Development',
      image: 'https://via.placeholder.com/800x400',
      readTime: '11 min read',
      tags: ['React', 'Performance', 'JavaScript', 'Web Development']
    }
  ];

  const categories = ['All', 'Development', 'Security', 'Education', 'Finance', 'Web3'];
  
  // Search functionality that would call our Rust backend API in a real implementation
  const searchBlogPosts = async () => {
    setIsLoading(true);
    
    try {
      // Simulate API call to Rust backend
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Filter blog posts based on search criteria
      let results = [...blogPosts];
      
      if (searchTerm) {
        const lowercaseTerm = searchTerm.toLowerCase();
        results = results.filter(post => 
          post.title.toLowerCase().includes(lowercaseTerm) || 
          post.excerpt.toLowerCase().includes(lowercaseTerm) ||
          post.tags?.some(tag => tag.toLowerCase().includes(lowercaseTerm))
        );
      }
      
      if (selectedCategory !== 'All') {
        results = results.filter(post => post.category === selectedCategory);
      }
      
      setFilteredPosts(results);
    } catch (error) {
      console.error('Error searching blog posts:', error);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Run search when any search criteria change
  useEffect(() => {
    searchBlogPosts();
  }, [searchTerm, selectedCategory]);
  
  // Handle search input
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    searchBlogPosts();
  };
  
  // Handle category filter click
  const handleCategoryClick = (category: string) => {
    setSelectedCategory(category);
  };

  return (
    <div className="container">
      <div className="blog-header">
        <h1 className="page-title">Blog</h1>
        <p className="page-subtitle">Insights, tutorials, and updates from our team</p>
      </div>
      
      <div className="search-container blog-search">
        <form onSubmit={handleSearch} className="search-form">
          <div className="search-box">
            <input 
              type="text" 
              placeholder="Search articles, topics, or tags..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
            <button type="submit" className="search-button">
              <i className="fas fa-search"></i>
            </button>
          </div>
        </form>
      </div>
      
      <div className="blog-layout">
        <div className="blog-main">
          <div className="blog-filters">
            <div className="category-filters">
              {categories.map((category, index) => (
                <button 
                  key={index} 
                  className={`filter-btn ${selectedCategory === category ? 'active' : ''}`}
                  onClick={() => handleCategoryClick(category)}
                >
                  {category}
                </button>
              ))}
            </div>
          </div>

          {isLoading ? (
            <div className="loading-container">
              <div className="loading-spinner"></div>
              <p>Searching articles...</p>
            </div>
          ) : filteredPosts.length === 0 ? (
            <div className="no-results">
              <p>No articles found matching your search criteria.</p>
              <button 
                className="btn btn-outline"
                onClick={() => {
                  setSearchTerm('');
                  setSelectedCategory('All');
                }}
              >
                Clear Filters
              </button>
            </div>
          ) : (
            <>
              <div className="blog-posts">
                {filteredPosts.map(post => (
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
                      {post.tags && (
                        <div className="blog-tags">
                          {post.tags.map((tag, index) => (
                            <span 
                              key={index} 
                              className="blog-tag"
                              onClick={() => setSearchTerm(tag)}
                            >
                              {tag}
                            </span>
                          ))}
                        </div>
                      )}
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
            </>
          )}
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
                <li 
                  key={index} 
                  className={`category-item ${selectedCategory === category ? 'active' : ''}`}
                >
                  <a 
                    href="#" 
                    className="category-link"
                    onClick={(e) => {
                      e.preventDefault();
                      handleCategoryClick(category);
                    }}
                  >
                    {category}
                  </a>
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