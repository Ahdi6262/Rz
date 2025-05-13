import React from 'react';
import { useParams, Link } from 'react-router-dom';

const BlogPost: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  
  // Sample blog post data - would be fetched from an API in a real application
  const blogPost = {
    id,
    title: 'Getting Started with Solana Development',
    content: `
      <p>
        Solana has rapidly emerged as one of the most promising layer-1 blockchain platforms,
        offering high throughput, low transaction costs, and a growing ecosystem of applications.
        In this guide, we'll walk through setting up your Solana development environment and
        creating your first simple program.
      </p>
      
      <h2>What is Solana?</h2>
      <p>
        Solana is a high-performance blockchain platform that aims to solve the blockchain
        trilemma of decentralization, security, and scalability. With a unique consensus
        mechanism called Proof of History (PoH) combined with Proof of Stake (PoS),
        Solana can process thousands of transactions per second with minimal fees.
      </p>
      
      <h2>Setting Up Your Development Environment</h2>
      <p>
        Before we start building, let's set up the necessary tools and dependencies:
      </p>
      
      <h3>1. Install Rust</h3>
      <p>
        Solana programs are primarily written in Rust, a systems programming language
        known for its performance and safety guarantees. To install Rust:
      </p>
      <pre><code>curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh</code></pre>
      
      <h3>2. Install Solana CLI</h3>
      <p>
        The Solana CLI allows you to interact with the Solana network, deploy programs,
        and manage accounts:
      </p>
      <pre><code>sh -c "$(curl -sSfL https://release.solana.com/v1.10.0/install)"</code></pre>
      
      <h3>3. Install Anchor Framework</h3>
      <p>
        Anchor is a framework that makes Solana development more accessible by providing
        higher-level abstractions:
      </p>
      <pre><code>cargo install --git https://github.com/project-serum/anchor anchor-cli --locked</code></pre>
      
      <h2>Creating Your First Solana Program</h2>
      <p>
        Let's create a simple "Hello World" program that stores a message on the blockchain:
      </p>
      
      <h3>1. Initialize a New Anchor Project</h3>
      <pre><code>anchor init hello_solana
cd hello_solana</code></pre>
      
      <p>
        This creates a new project with the following structure:
      </p>
      <ul>
        <li><code>programs/</code> - Contains your Solana programs</li>
        <li><code>app/</code> - Client-side code for interacting with your program</li>
        <li><code>tests/</code> - Test files</li>
      </ul>
      
      <h3>2. Implement Your Program</h3>
      <p>
        Open <code>programs/hello_solana/src/lib.rs</code> and replace its content with:
      </p>
      <pre><code>use anchor_lang::prelude::*;

declare_id!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod hello_solana {
    use super::*;
    pub fn initialize(ctx: Context<Initialize>, data: String) -> Result<()> {
        let greeting_account = &mut ctx.accounts.greeting_account;
        greeting_account.message = data;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = user, space = 8 + 32)]
    pub greeting_account: Account<'info, GreetingAccount>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct GreetingAccount {
    pub message: String,
}</code></pre>
      
      <h3>3. Build and Deploy</h3>
      <p>
        Now, let's build and deploy our program to the Solana devnet:
      </p>
      <pre><code>anchor build
solana config set --url devnet
solana airdrop 2
anchor deploy</code></pre>
      
      <h2>Testing Your Program</h2>
      <p>
        Let's create a simple test in <code>tests/hello_solana.js</code>:
      </p>
      <pre><code>const anchor = require('@project-serum/anchor');
const { SystemProgram } = anchor.web3;
const assert = require("assert");

describe('hello_solana', () => {
  const provider = anchor.Provider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.HelloSolana;
  
  it('Can create a greeting', async () => {
    const greetingAccount = anchor.web3.Keypair.generate();
    await program.rpc.initialize("Hello, Solana!", {
      accounts: {
        greetingAccount: greetingAccount.publicKey,
        user: provider.wallet.publicKey,
        systemProgram: SystemProgram.programId,
      },
      signers: [greetingAccount],
    });
    
    const account = await program.account.greetingAccount.fetch(greetingAccount.publicKey);
    assert.equal(account.message, "Hello, Solana!");
  });
});</code></pre>
      
      <p>
        Run the test with:
      </p>
      <pre><code>anchor test</code></pre>
      
      <h2>Next Steps</h2>
      <p>
        Congratulations on building your first Solana program! As you continue your Solana development journey, explore these topics:
      </p>
      <ul>
        <li>Program Derived Addresses (PDAs)</li>
        <li>Cross-Program Invocation (CPI)</li>
        <li>Token creation and management</li>
        <li>Building frontend applications with Solana wallet integration</li>
      </ul>
      
      <p>
        The Solana ecosystem is growing rapidly, with excellent documentation and a supportive community to help you build innovative decentralized applications.
      </p>
    `,
    author: 'Alex Johnson',
    authorTitle: 'Senior Blockchain Developer',
    date: 'April 15, 2023',
    readTime: '8 min read',
    category: 'Development',
    tags: ['Solana', 'Blockchain', 'Rust', 'Web3', 'Tutorial'],
    image: 'https://via.placeholder.com/1200x600',
    relatedPosts: [
      {
        id: 2,
        title: 'Web3 Authentication Methods Compared',
        excerpt: 'A comprehensive comparison of different authentication methods in Web3 applications.',
        image: 'https://via.placeholder.com/400x200'
      },
      {
        id: 5,
        title: 'Optimizing React Performance in Large Applications',
        excerpt: 'Practical techniques to improve the performance of complex React applications.',
        image: 'https://via.placeholder.com/400x200'
      }
    ]
  };

  return (
    <div className="container">
      <div className="blog-post-container">
        <div className="blog-post-header">
          <div className="post-meta">
            <span className="post-category">{blogPost.category}</span>
            <span className="post-date">{blogPost.date}</span>
            <span className="post-read-time">{blogPost.readTime}</span>
          </div>
          <h1 className="post-title">{blogPost.title}</h1>
          <div className="post-author">
            <div className="author-avatar">
              <img src="https://via.placeholder.com/50" alt={blogPost.author} />
            </div>
            <div className="author-info">
              <h4 className="author-name">{blogPost.author}</h4>
              <p className="author-title">{blogPost.authorTitle}</p>
            </div>
          </div>
        </div>
        
        <div className="blog-post-image">
          <img src={blogPost.image} alt={blogPost.title} />
        </div>
        
        <div className="blog-post-content">
          <div className="post-body" dangerouslySetInnerHTML={{ __html: blogPost.content }} />
          
          <div className="post-tags">
            {blogPost.tags.map((tag, index) => (
              <span key={index} className="tag">{tag}</span>
            ))}
          </div>
          
          <div className="post-share">
            <span>Share this post:</span>
            <div className="share-buttons">
              <button className="share-btn twitter">Twitter</button>
              <button className="share-btn facebook">Facebook</button>
              <button className="share-btn linkedin">LinkedIn</button>
            </div>
          </div>
        </div>
        
        <div className="related-posts">
          <h3 className="related-title">Related Posts</h3>
          <div className="related-grid">
            {blogPost.relatedPosts.map(post => (
              <div key={post.id} className="related-post">
                <Link to={`/blog/${post.id}`} className="related-post-link">
                  <div className="related-post-image">
                    <img src={post.image} alt={post.title} />
                  </div>
                  <h4 className="related-post-title">{post.title}</h4>
                </Link>
                <p className="related-post-excerpt">{post.excerpt}</p>
              </div>
            ))}
          </div>
        </div>
        
        <div className="post-navigation">
          <Link to="/blog" className="btn btn-outline">Back to Blog</Link>
        </div>
      </div>
    </div>
  );
};

export default BlogPost;