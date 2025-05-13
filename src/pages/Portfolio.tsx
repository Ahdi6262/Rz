import React from 'react';

const Portfolio: React.FC = () => {
  // Sample portfolio items - would be fetched from an API in a real application
  const portfolioItems = [
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

  return (
    <div className="container">
      <div className="portfolio-header">
        <h1 className="page-title">Portfolio</h1>
        <p className="page-subtitle">Explore our projects and applications</p>
      </div>
      
      <div className="portfolio-filters">
        <button className="filter-btn active">All</button>
        <button className="filter-btn">Web3</button>
        <button className="filter-btn">Blockchain</button>
        <button className="filter-btn">Education</button>
        <button className="filter-btn">Other</button>
      </div>
      
      <div className="portfolio-grid">
        {portfolioItems.map(item => (
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
                  <span key={index} className="tech-tag">{tech}</span>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Portfolio;