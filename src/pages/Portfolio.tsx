import React, { useState, useEffect } from 'react';
import './Portfolio.css';

interface PortfolioItem {
  id: number;
  title: string;
  category: string;
  image: string;
  description: string;
  technologies: string[];
}

const Portfolio: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedTechnology, setSelectedTechnology] = useState('All');
  const [filteredItems, setFilteredItems] = useState<PortfolioItem[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  
  // Sample portfolio items - would be fetched from an API in a real application
  const portfolioItems: PortfolioItem[] = [
    {
      id: 1,
      title: 'DeFi Dashboard',
      category: 'Web3',
      image: 'https://via.placeholder.com/400x300',
      description: 'A comprehensive dashboard for DeFi users to track their investments across multiple protocols.',
      technologies: ['React', 'TypeScript', 'Solana', 'Web3.js']
    },
    {
      id: 2,
      title: 'NFT Marketplace',
      category: 'Blockchain',
      image: 'https://via.placeholder.com/400x300',
      description: 'A fully-featured NFT marketplace built on Solana with trading and minting capabilities.',
      technologies: ['Rust', 'Anchor', 'React', 'Solana']
    },
    {
      id: 3,
      title: 'Learning Management System',
      category: 'Education',
      image: 'https://via.placeholder.com/400x300',
      description: 'A feature-rich LMS with course creation, enrollment, and progress tracking.',
      technologies: ['TypeScript', 'React', 'Node.js', 'PostgreSQL']
    },
    {
      id: 4,
      title: 'Web3 Authentication Service',
      category: 'Security',
      image: 'https://via.placeholder.com/400x300',
      description: 'A reusable authentication service supporting both traditional and wallet-based auth.',
      technologies: ['Rust', 'React', 'Solana', 'JWT']
    },
    {
      id: 5,
      title: 'Decentralized Blog Platform',
      category: 'Content',
      image: 'https://via.placeholder.com/400x300',
      description: 'A blog platform with decentralized content storage and token-gated premium articles.',
      technologies: ['React', 'IPFS', 'Solana', 'TypeScript']
    },
    {
      id: 6,
      title: 'DAO Governance Portal',
      category: 'Governance',
      image: 'https://via.placeholder.com/400x300',
      description: 'A governance portal for DAOs to manage proposals and voting on Solana.',
      technologies: ['React', 'Rust', 'Anchor', 'Solana']
    }
  ];
  
  // Extract unique categories and technologies
  const categories = ['All', ...new Set(portfolioItems.map(item => item.category))];
  const technologies = ['All', ...new Set(portfolioItems.flatMap(item => item.technologies))];
  
  // Search function that would normally call the Rust backend API
  const searchPortfolio = async () => {
    setIsLoading(true);
    
    try {
      // Simulate API call to Rust backend
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Filter items based on search criteria
      let results = [...portfolioItems];
      
      if (searchTerm) {
        const lowercaseTerm = searchTerm.toLowerCase();
        results = results.filter(item => 
          item.title.toLowerCase().includes(lowercaseTerm) || 
          item.description.toLowerCase().includes(lowercaseTerm)
        );
      }
      
      if (selectedCategory !== 'All') {
        results = results.filter(item => item.category === selectedCategory);
      }
      
      if (selectedTechnology !== 'All') {
        results = results.filter(item => item.technologies.includes(selectedTechnology));
      }
      
      setFilteredItems(results);
    } catch (error) {
      console.error('Error searching portfolio:', error);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Run search when any of the search criteria change
  useEffect(() => {
    searchPortfolio();
  }, [searchTerm, selectedCategory, selectedTechnology]);
  
  // Handle filter button click
  const handleCategoryFilter = (category: string) => {
    setSelectedCategory(category);
  };

  return (
    <div className="container">
      <div className="portfolio-header">
        <h1 className="page-title">Portfolio</h1>
        <p className="page-subtitle">Explore our projects and applications</p>
      </div>
      
      <div className="search-container portfolio-search">
        <div className="search-box">
          <input 
            type="text" 
            placeholder="Search portfolio projects..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          <button className="search-button">
            <i className="fas fa-search"></i>
          </button>
        </div>
        
        <div className="advanced-filters">
          <div className="filter-group">
            <label htmlFor="tech-filter">Technology:</label>
            <select 
              id="tech-filter" 
              className="filter-select"
              value={selectedTechnology}
              onChange={(e) => setSelectedTechnology(e.target.value)}
            >
              {technologies.map(tech => (
                <option key={tech} value={tech}>{tech}</option>
              ))}
            </select>
          </div>
        </div>
      </div>
      
      <div className="portfolio-filters">
        {categories.map(category => (
          <button 
            key={category}
            className={`filter-btn ${selectedCategory === category ? 'active' : ''}`}
            onClick={() => handleCategoryFilter(category)}
          >
            {category}
          </button>
        ))}
      </div>
      
      {isLoading ? (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Searching projects...</p>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="no-results">
          <p>No portfolio items found matching your search criteria.</p>
          <button 
            className="btn btn-outline"
            onClick={() => {
              setSearchTerm('');
              setSelectedCategory('All');
              setSelectedTechnology('All');
            }}
          >
            Clear Filters
          </button>
        </div>
      ) : (
        <div className="portfolio-grid">
          {filteredItems.map(item => (
            <div key={item.id} className="portfolio-item">
              <div className="portfolio-image">
                <img src={item.image} alt={item.title} />
                <div className="portfolio-overlay">
                  <div className="portfolio-category">{item.category}</div>
                  <button className="portfolio-btn">View Details</button>
                </div>
              </div>
              <div className="portfolio-content">
                <h3 className="portfolio-title">{item.title}</h3>
                <p className="portfolio-description">{item.description}</p>
                <div className="portfolio-tech">
                  {item.technologies.map((tech, index) => (
                    <span 
                      key={index} 
                      className={`tech-tag ${selectedTechnology === tech ? 'active' : ''}`}
                      onClick={() => setSelectedTechnology(tech)}
                    >
                      {tech}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Portfolio;