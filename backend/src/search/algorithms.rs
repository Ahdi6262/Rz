use std::collections::HashMap;
use serde::{Serialize, Deserialize};
use unicode_segmentation::UnicodeSegmentation;
use std::cmp::Ordering;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchDocument {
    pub id: String,
    pub title: String,
    pub content: String,
    pub metadata: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchResult {
    pub document_id: String,
    pub score: f64,
    pub highlights: Vec<String>,
}

// Inverted index for efficient searching
pub struct InvertedIndex {
    index: HashMap<String, Vec<(String, f64)>>,
    documents: HashMap<String, SearchDocument>,
}

impl InvertedIndex {
    pub fn new() -> Self {
        InvertedIndex {
            index: HashMap::new(),
            documents: HashMap::new(),
        }
    }

    // Add a document to the index
    pub fn add_document(&mut self, document: SearchDocument) {
        let doc_id = document.id.clone();
        
        // Process the title and content
        let title_tokens = tokenize(&document.title);
        let content_tokens = tokenize(&document.content);
        
        // Calculate term frequency for title tokens (with higher weight)
        let mut term_frequencies = HashMap::new();
        for token in title_tokens {
            *term_frequencies.entry(token).or_insert(0.0) += 2.0; // Higher weight for title terms
        }
        
        // Calculate term frequency for content tokens
        for token in content_tokens {
            *term_frequencies.entry(token).or_insert(0.0) += 1.0;
        }
        
        // Add terms to inverted index
        for (term, frequency) in term_frequencies {
            self.index
                .entry(term)
                .or_insert_with(Vec::new)
                .push((doc_id.clone(), frequency));
        }
        
        // Store the document
        self.documents.insert(doc_id, document);
    }
    
    // Search for documents matching the query
    pub fn search(&self, query: &str, limit: usize) -> Vec<SearchResult> {
        let query_tokens = tokenize(query);
        let mut scores = HashMap::new();
        
        // For each token in the query
        for token in query_tokens {
            // Find documents containing the token
            if let Some(postings) = self.index.get(&token) {
                for (doc_id, score) in postings {
                    *scores.entry(doc_id.clone()).or_insert(0.0) += score;
                }
            }
        }
        
        // Convert scores to search results
        let mut results: Vec<SearchResult> = scores
            .into_iter()
            .map(|(doc_id, score)| {
                let document = self.documents.get(&doc_id).unwrap();
                let highlights = extract_highlights(document, query);
                
                SearchResult {
                    document_id: doc_id,
                    score,
                    highlights,
                }
            })
            .collect();
        
        // Sort by score in descending order
        results.sort_by(|a, b| {
            b.score.partial_cmp(&a.score).unwrap_or(Ordering::Equal)
        });
        
        // Limit the number of results
        results.truncate(limit);
        
        results
    }
    
    // Filter search results by metadata
    pub fn filter_by_metadata(
        &self, 
        results: Vec<SearchResult>, 
        filters: &HashMap<String, String>
    ) -> Vec<SearchResult> {
        if filters.is_empty() {
            return results;
        }
        
        results
            .into_iter()
            .filter(|result| {
                if let Some(document) = self.documents.get(&result.document_id) {
                    for (key, value) in filters {
                        if !document.metadata.get(key).map_or(false, |v| v == value) {
                            return false;
                        }
                    }
                    true
                } else {
                    false
                }
            })
            .collect()
    }
    
    // Get full document by ID
    pub fn get_document(&self, id: &str) -> Option<&SearchDocument> {
        self.documents.get(id)
    }
}

// Helper function to tokenize text
fn tokenize(text: &str) -> Vec<String> {
    text.to_lowercase()
        .unicode_words()
        .map(|word| word.to_string())
        .collect()
}

// Helper function to extract relevant snippets for highlighting
fn extract_highlights(document: &SearchDocument, query: &str) -> Vec<String> {
    let content = &document.content;
    let query_tokens: Vec<&str> = query.to_lowercase().unicode_words().collect();
    let mut highlights = Vec::new();
    
    // Simple algorithm to extract snippets around query terms
    for token in query_tokens {
        if let Some(pos) = content.to_lowercase().find(token) {
            let start = if pos > 30 { pos - 30 } else { 0 };
            let end = (pos + token.len() + 30).min(content.len());
            let snippet = &content[start..end];
            highlights.push(format!("...{}...", snippet));
        }
    }
    
    // If no highlights found, return a snippet from the beginning
    if highlights.is_empty() && !content.is_empty() {
        let end = content.len().min(100);
        highlights.push(format!("{}...", &content[0..end]));
    }
    
    highlights
}

// Fuzzy search implementation using Levenshtein distance
pub fn fuzzy_search(query: &str, text: &str, threshold: usize) -> bool {
    let query = query.to_lowercase();
    let text = text.to_lowercase();
    
    // For short queries, use exact matching
    if query.len() <= 3 {
        return text.contains(&query);
    }
    
    // For longer queries, use Levenshtein distance
    let words: Vec<&str> = text.unicode_words().collect();
    for word in words {
        if word.len() >= query.len() && levenshtein_distance(&query, word) <= threshold {
            return true;
        }
    }
    
    false
}

// Calculate Levenshtein distance between two strings
fn levenshtein_distance(s1: &str, s2: &str) -> usize {
    let s1_chars: Vec<char> = s1.chars().collect();
    let s2_chars: Vec<char> = s2.chars().collect();
    
    let m = s1_chars.len();
    let n = s2_chars.len();
    
    // Create distance matrix
    let mut matrix = vec![vec![0; n + 1]; m + 1];
    
    // Initialize first row and column
    for i in 0..=m {
        matrix[i][0] = i;
    }
    
    for j in 0..=n {
        matrix[0][j] = j;
    }
    
    // Fill the matrix
    for i in 1..=m {
        for j in 1..=n {
            let cost = if s1_chars[i - 1] == s2_chars[j - 1] { 0 } else { 1 };
            
            matrix[i][j] = std::cmp::min(
                matrix[i - 1][j] + 1,                // deletion
                std::cmp::min(
                    matrix[i][j - 1] + 1,            // insertion
                    matrix[i - 1][j - 1] + cost      // substitution
                )
            );
        }
    }
    
    matrix[m][n]
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_inverted_index() {
        let mut index = InvertedIndex::new();
        
        let doc1 = SearchDocument {
            id: "1".to_string(),
            title: "Rust Programming Language".to_string(),
            content: "Rust is a systems programming language that runs blazingly fast".to_string(),
            metadata: {
                let mut map = HashMap::new();
                map.insert("category".to_string(), "Programming".to_string());
                map
            }
        };
        
        let doc2 = SearchDocument {
            id: "2".to_string(),
            title: "Web Development with React".to_string(),
            content: "React is a JavaScript library for building user interfaces".to_string(),
            metadata: {
                let mut map = HashMap::new();
                map.insert("category".to_string(), "Web Development".to_string());
                map
            }
        };
        
        index.add_document(doc1);
        index.add_document(doc2);
        
        let results = index.search("rust programming", 10);
        assert!(!results.is_empty());
        assert_eq!(results[0].document_id, "1");
        
        let results = index.search("javascript react", 10);
        assert!(!results.is_empty());
        assert_eq!(results[0].document_id, "2");
    }
    
    #[test]
    fn test_fuzzy_search() {
        assert!(fuzzy_search("rust", "Rust is a programming language", 1));
        assert!(fuzzy_search("progamming", "Rust is a programming language", 2)); // Typo in query
        assert!(!fuzzy_search("javascript", "Rust is a programming language", 2));
    }
}